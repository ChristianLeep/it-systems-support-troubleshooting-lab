# TKT-006 – Printer Job Stuck in Queue (Print Spooler Service Issue)

## User intake form
- Who: Prof. Daniel Rivera / daniel.rivera@university.edu  
- What: Printer shows documents in queue but nothing is printing. Jobs remain stuck with status "Printing."  
- When: Issue noticed while attempting to print lecture materials before class  
- Where: Faculty office workstation  
- Why: Unable to print required documents  
- How: Unknown  
- Urgency: Medium  

---

## IT input/verification
- Who: Prof. Daniel Rivera / daniel.rivera@university.edu  
- What: Confirmed print jobs remain in queue and printer is unresponsive  
- When: Verified immediately after ticket intake  
- Where: Faculty office device  
- Why: Print spooler appears unable to process queued jobs  
- How: Suspected stalled print spooler service  
- Urgency: Medium  

---

## Initial Assessment
- Scope: Single endpoint and printer affected  
- Recent changes: None reported  
- Hypothesis: Print spooler service hung or corrupted print queue  

---

## Troubleshooting Timeline

### 1) Replicated the issue  
Opened **Devices and Printers** and confirmed multiple print jobs stuck in the queue.

![Stuck Print Queue](../evidence/TKT-006/01_print_queue_stuck.png)

---

### 2) Checked printer status  
Verified printer was online and set as default, ruling out connectivity or selection issues.

![Printer Online](../evidence/TKT-006/02_printer_status.png)

---

### 3) Restarted Print Spooler service  
Opened **Services (services.msc)** and located **Print Spooler** service.  
Service was running but unresponsive.

Restarted the service.

![Restart Spooler](../evidence/TKT-006/03_restart_spooler.png)

---

### 4) Cleared print spooler cache manually  
Opened Command Prompt as Administrator and ran:
net stop spooler
del /Q /F %systemroot%\System32\spool\PRINTERS*
net start spooler


This removed stuck print job files and restarted the spooler service.

![Clear Spooler Cache](../evidence/TKT-006/04_clear_spooler.png)

---

## Root Cause
The Windows Print Spooler service became stuck while processing a previous print job. This prevented subsequent jobs from being processed and caused the queue to remain in a “printing” state indefinitely.

---

## Resolution Steps

### 1) Sent a test print  
Printed a test page to confirm normal functionality.

![Test Page Printed](../evidence/TKT-006/05_test_print.png)

---

## Verification
- Print queue cleared successfully  
- Test document printed  
- No further jobs stuck in queue  

---

## Prevention / Best Practice
- Cancel stalled print jobs promptly  
- Restart print spooler service if queue becomes unresponsive  
- Keep printer drivers updated  

---

## Escalation Decision
Not escalated. Issue was resolved at the endpoint by clearing the spooler cache and restarting the service.

---

## Lessons Learned
This scenario reinforced the importance of:
- Understanding Windows service dependencies  
- Using command-line tools to repair system services  
- Knowing how to manually clear spooler files when GUI methods fail  

---

**Status: Resolved**

