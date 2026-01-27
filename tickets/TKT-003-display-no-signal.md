# TKT-003 – Classroom Display Shows "No Signal"

## User intake form
- Who: Dr. Emily Chen / emily.chen@university.edu
- What: Classroom projector displays "No Signal" when laptop is connected. Lecture slides not appearing on screen.
- When: Issue noticed at the start of scheduled class (approx. 10 minutes before class began)
- Where: Health Sciences Campus – Room 2B-114
- Why: Unable to present lecture materials to students
- How: Unknown
- Urgency: High

---

## IT input/verification
- Who: Dr. Emily Chen / emily.chen@university.edu
- What: Instructor laptop connected via HDMI adapter, but classroom display not detecting input.
- When: Verified immediately upon arrival to classroom
- Where: Health Sciences Campus – Room 2B-114
- Why: AV system not receiving video signal from instructor device
- How: Possible incorrect display mode or input source
- Urgency: High

---

## Initial Assessment
- Scope: Single classroom affected
- Recent changes: Instructor connected work laptop using HDMI adapter
- Hypothesis: Incorrect input source, loose/bad cable, or incorrect display mode

---

## Troubleshooting Timeline

### 1) Replicated the issue  
Connected instructor laptop to classroom HDMI cable and confirmed display showed "No Signal".

![No Signal Display](../evidence/TKT-003/01_no_signal_display.png)

---

### 2) Checked physical connections  
Verified HDMI cable was securely connected to laptop adapter and wall plate.

![Checked HDMI Connection](../evidence/TKT-003/02_hdmi_connection.png)

---

### 3) Verified projector input source  
Confirmed projector was set to the correct HDMI input.

![Projector Input Source](../evidence/TKT-003/03_projector_input.png)

---

### 4) Checked laptop display settings  
Opened Windows display settings and confirmed system was not duplicating or extending display.

![Display Settings](../evidence/TKT-003/04_display_settings.png)

---

### 5) Changed display mode  
Used keyboard shortcut `Windows + P` and selected **Duplicate** display.

![Windows P Menu](../evidence/TKT-003/05_windows_p_duplicate.png)

---

### 6) Confirmed signal restored  
Classroom display began showing laptop screen successfully.

![Display Restored](../evidence/TKT-003/06_display_restored.png)

---

## Root Cause
The instructor’s laptop was not set to duplicate or extend its display to the external monitor. As a result, the classroom projector did not receive a video signal, displaying "No Signal."

---

## Resolution Steps
1. Verified HDMI cable and adapter connections  
2. Confirmed projector input source was correct  
3. Adjusted laptop display settings using `Windows + P`  
4. Selected **Duplicate Display** mode

---

## Verification
- Test performed:
  - Display output mirrored to projector
  - Presentation slides visible on classroom screen
- Result:
  - Instructor successfully presented lecture materials

---

## Prevention / Best Practice
- Provide quick reference guides in classrooms for connecting laptops
- Encourage instructors to test AV setup before class begins
- Label classroom input sources clearly

---

## Escalation Decision
Not escalated. Issue was resolved at the endpoint and classroom AV connection level.

---

## Lessons Learned
This scenario reinforced the importance of:
- Checking both physical and software display settings
- Understanding how operating systems handle multiple displays
- Using quick keyboard shortcuts (`Windows + P`) for rapid AV troubleshooting

---

**Status: Resolved**
