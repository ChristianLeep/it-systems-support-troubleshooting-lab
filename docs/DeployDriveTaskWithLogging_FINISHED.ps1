# ============================================================
# Intune Network Drive Deployment
# Maps S: to \\10.0.0.7\data for each user at logon
# ============================================================

$ScriptFolder = "C:\ProgramData\EnterpriseManagement"
$ScriptPath   = Join-Path $ScriptFolder "MapDrives.ps1"
$TaskName     = "AutoMapNetworkDrives"

# Create the local folder that stores the user mapping script
if (-not (Test-Path $ScriptFolder)) {
    New-Item -Path $ScriptFolder -ItemType Directory -Force | Out-Null
}

# ------------------------------------------------------------
# Create the script that runs in the logged-on user's context
# ------------------------------------------------------------
$MappingScriptContent = @'
$DriveLetter = "S:"
$NetworkPath = "\\10.0.0.7\data"

# Store logs in the current user's LocalAppData folder
$LogFolder = Join-Path $env:LOCALAPPDATA "EnterpriseManagement"
$LogPath   = Join-Path $LogFolder "MapNetworkDrive_Log.txt"

if (-not (Test-Path $LogFolder)) {
    New-Item -Path $LogFolder -ItemType Directory -Force | Out-Null
}

function Write-Log {
    param([string]$Message)

    $TimeStamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "[$TimeStamp] $Message" | Out-File -FilePath $LogPath -Append -Encoding utf8
}

Write-Log "--- Drive Mapping Started ---"
Write-Log "Running as user: $env:USERNAME"
Write-Log "Target Drive: $DriveLetter"
Write-Log "Target Path: $NetworkPath"

try {
    $Network = New-Object -ComObject WScript.Network

    # Remove an existing network mapping for S: if one exists.
    # If S: is not currently mapped, the error is expected and ignored.
    try {
        $Network.RemoveNetworkDrive($DriveLetter, $true, $true)
        Write-Log "Removed existing network mapping for $DriveLetter."
        Start-Sleep -Seconds 1
    }
    catch {
        Write-Log "No removable network mapping currently exists for $DriveLetter."
    }

    # Create a persistent drive mapping.
    # Authentication uses the currently logged-on user's Windows credentials.
    Write-Log "Attempting to map $DriveLetter to $NetworkPath..."

    $Network.MapNetworkDrive(
        $DriveLetter,
        $NetworkPath,
        $true
    )

    Write-Log "SUCCESS: Mapping command completed for $DriveLetter to $NetworkPath."
    Write-Log "--- Drive Mapping Finished (SUCCESS) ---"
    exit 0
}
catch {
    Write-Log "ERROR: Failed to map $DriveLetter to $NetworkPath."
    Write-Log "ERROR DETAILS: $($_.Exception.Message)"
    Write-Log "--- Drive Mapping Finished (FAILED) ---"
    exit 1
}
'@

# Write/update the per-user mapping script
$MappingScriptContent |
    Out-File -FilePath $ScriptPath -Force -Encoding utf8

# ------------------------------------------------------------
# Create scheduled task that runs at every user logon
# ------------------------------------------------------------

$Action = New-ScheduledTaskAction `
    -Execute "powershell.exe" `
    -Argument "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$ScriptPath`""

$Trigger = New-ScheduledTaskTrigger -AtLogOn

# Built-in Users group
# Allows the task to run for whichever user logs into the PC
$Principal = New-ScheduledTaskPrincipal `
    -GroupId "S-1-5-32-545" `
    -RunLevel Limited

$Settings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -StartWhenAvailable

Register-ScheduledTask `
    -TaskName $TaskName `
    -Action $Action `
    -Trigger $Trigger `
    -Principal $Principal `
    -Settings $Settings `
    -Force | Out-Null

Write-Output "Installed network drive deployment successfully."
Write-Output "Scheduled task: $TaskName"
Write-Output "Mapping script: $ScriptPath"
Write-Output "Drive mapping: S: -> \\10.0.0.7\data"
