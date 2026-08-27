# DeployDriveTaskWithLogging_FINISHED.ps1
# Purpose: Install a per-user scheduled task that maps S: to \\10.0.0.7\data
# Intended deployment: Microsoft Intune, run as SYSTEM/admin so it can create the task and local script.
# The scheduled task itself runs at user logon under the built-in Users group context.

$ErrorActionPreference = 'Stop'

# -----------------------------------------------------------------------------
# Installer settings
# -----------------------------------------------------------------------------
$ScriptFolder = 'C:\ProgramData\EnterpriseManagement'
$ScriptPath   = Join-Path $ScriptFolder 'MapDrives.ps1'
$TaskName     = 'AutoMapNetworkDrives'

if (-not (Test-Path -LiteralPath $ScriptFolder)) {
    New-Item -Path $ScriptFolder -ItemType Directory -Force | Out-Null
}

# -----------------------------------------------------------------------------
# Create the actual per-user drive-mapping script.
# This runs at every user logon.
# -----------------------------------------------------------------------------
$MappingScriptContent = @'
$ErrorActionPreference = 'Stop'

$DriveLetter = 'S:'
$DriveName   = 'S'
$Server      = '10.0.0.7'
$NetworkPath = '\\10.0.0.7\data'
$LogFolder   = Join-Path $env:LOCALAPPDATA 'EnterpriseManagement'
$LogPath     = Join-Path $LogFolder 'MapNetworkDrive_Log.txt'

if (-not (Test-Path -LiteralPath $LogFolder)) {
    New-Item -Path $LogFolder -ItemType Directory -Force | Out-Null
}

function Write-Log {
    param([Parameter(Mandatory)][string]$Message)

    $TimeStamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    "[$TimeStamp] $Message" | Out-File -FilePath $LogPath -Append -Encoding utf8
}

function Get-NetworkDriveMapping {
    param([Parameter(Mandatory)][string]$Letter)

    # Map the drive
try {
    Write-Log "Attempting to map $DriveLetter to $NetworkPath..."

    $network = New-Object -ComObject WScript.Network
    $network.MapNetworkDrive($DriveLetter, $NetworkPath, $true)

    Start-Sleep -Seconds 2

    # Verify the mapping using NET USE
    $mapping = cmd.exe /c "net use $DriveLetter" 2>&1

    if ($mapping -match [regex]::Escape($NetworkPath)) {
        Write-Log "SUCCESS: $DriveLetter is mapped to $NetworkPath."
        Write-Log "--- Drive Mapping Finished (SUCCESS) ---"
        exit 0
    }
    else {
        Write-Log "ERROR: Mapping command completed, but verification failed."
        Write-Log "NET USE returned: $($mapping -join ' ')"
        Write-Log "--- Drive Mapping Finished (FAILED) ---"
        exit 1
    }
}
catch {
    Write-Log "ERROR: Failed to map $DriveLetter to $NetworkPath. $($_.Exception.Message)"
    Write-Log "--- Drive Mapping Finished (FAILED) ---"
    exit 1
}

Write-Log '--- Drive Mapping Started ---'
Write-Log "User: $env:USERDOMAIN\$env:USERNAME"
Write-Log "Target: $DriveLetter -> $NetworkPath"

# Wait for SMB (TCP 445) to become reachable. This checks network reachability
# separately from share permissions/authentication.
$maxRetries = 15
$retryDelaySeconds = 2
$serverReachable = $false

for ($attempt = 1; $attempt -le $maxRetries; $attempt++) {
    try {
        $test = Test-NetConnection -ComputerName $Server -Port 445 -WarningAction SilentlyContinue
        if ($test.TcpTestSucceeded) {
            $serverReachable = $true
            Write-Log "SMB is reachable on $Server`:445."
            break
        }
    }
    catch {
        Write-Log "SMB connectivity check failed on attempt $attempt`: $($_.Exception.Message)"
    }

    Write-Log "SMB not reachable yet. Retrying in $retryDelaySeconds seconds... (Attempt $attempt/$maxRetries)"
    Start-Sleep -Seconds $retryDelaySeconds
}

if (-not $serverReachable) {
    Write-Log "ERROR: Timed out waiting for SMB on $Server`:445. The device may be off-LAN or VPN is not connected."
    Write-Log '--- Drive Mapping Finished (FAILED) ---'
    exit 1
}

try {
    $currentNetworkPath = Get-NetworkDriveMapping -Letter $DriveLetter

    if ($currentNetworkPath) {
        if ($currentNetworkPath -ieq $NetworkPath) {
            Write-Log "SUCCESS: $DriveLetter is already mapped correctly to $NetworkPath."
            Write-Log '--- Drive Mapping Finished ---'
            exit 0
        }

        Write-Log "Drive $DriveLetter is currently mapped to $currentNetworkPath. Removing the old network mapping."
        $network = New-Object -ComObject WScript.Network
        $network.RemoveNetworkDrive($DriveLetter, $true, $true)
        Start-Sleep -Seconds 1
    }
    elseif (Test-Path -LiteralPath $DriveLetter) {
        # A local/removable drive is using S:. Do not remove it.
        Write-Log "ERROR: $DriveLetter is already in use by a non-network drive. Mapping was not changed."
        Write-Log '--- Drive Mapping Finished (FAILED) ---'
        exit 2
    }

    Write-Log "Attempting to map $DriveLetter to $NetworkPath..."

    $network = New-Object -ComObject WScript.Network
    $network.MapNetworkDrive($DriveLetter, $NetworkPath, $true)

    # Give Windows a few seconds to publish the new mapping before verifying it.
    $verifiedPath = $null
    for ($verifyAttempt = 1; $verifyAttempt -le 5; $verifyAttempt++) {
        Start-Sleep -Seconds 1
        $verifiedPath = Get-NetworkDriveMapping -Letter $DriveLetter

        if ($verifiedPath -ieq $NetworkPath) {
            Write-Log "SUCCESS: Mapped $DriveLetter to $NetworkPath."
            Write-Log '--- Drive Mapping Finished ---'
            exit 0
        }

        Write-Log "Verification attempt $verifyAttempt/5 did not yet see the expected mapping. Current mapping: '$verifiedPath'"
    }

    Write-Log "ERROR: Mapping command completed, but verification failed after 5 attempts. Current mapping: '$verifiedPath'"
    Write-Log '--- Drive Mapping Finished (FAILED) ---'
    exit 3
}
catch {
    Write-Log "ERROR: Mapping failed: $($_.Exception.Message)"
    Write-Log 'Common causes: user lacks share/NTFS permission, credentials are unavailable, SMB is blocked, or the server requires domain authentication.'
    Write-Log '--- Drive Mapping Finished (FAILED) ---'
    exit 4
}
'@

Set-Content -Path $ScriptPath -Value $MappingScriptContent -Force -Encoding UTF8

# -----------------------------------------------------------------------------
# Create/update scheduled task.
# Microsoft documents using an AtLogOn scheduled task for mapped-drive recovery.
# The built-in Users group lets the task execute for whoever signs in.
# -----------------------------------------------------------------------------
$Action = New-ScheduledTaskAction `
    -Execute 'powershell.exe' `
    -Argument "-NoProfile -NonInteractive -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$ScriptPath`""

$Trigger = New-ScheduledTaskTrigger -AtLogOn

$Principal = New-ScheduledTaskPrincipal `
    -GroupId 'S-1-5-32-545' `
    -RunLevel Limited

$Settings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -StartWhenAvailable `
    -ExecutionTimeLimit (New-TimeSpan -Minutes 5)

Register-ScheduledTask `
    -TaskName $TaskName `
    -Action $Action `
    -Trigger $Trigger `
    -Principal $Principal `
    -Settings $Settings `
    -Description 'Maps S: to \\10.0.0.7\data for users at logon.' `
    -Force | Out-Null

Write-Output "Installed mapping script: $ScriptPath"
Write-Output "Registered scheduled task: $TaskName"
Write-Output 'Target drive: S:'
Write-Output 'Target share: \\10.0.0.7\data'
