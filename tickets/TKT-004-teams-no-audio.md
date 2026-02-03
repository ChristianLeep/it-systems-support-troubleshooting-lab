# TKT-004 – Teams Meeting Has No Microphone Audio

## User intake form
- Who: Prof. Daniel Rivera / daniel.rivera@university.edu
- What: Joined a Teams meeting, but participants reported they could not hear me. 
- When: Issue noticed at the start of a scheduled virtual class session
- Where: Health Sciences Campus – Room 3C-221
- Why: Unable to communicate with students during live lecture
- How: Unknown
- Urgency: High

---

## IT input/verification
- Who: Prof. Daniel Rivera / daniel.rivera@university.edu
- What: Confirmed Teams meeting was active, but no audio was being transmitted from the instructor's laptop microphone.
- When: Verified immediately upon arrival to classroom
- Where: Health Sciences Campus – Room 3C-221
- Why: Teams client not detecting correct microphone input device
- How: System defaulted to incorrect or disabled microphonwe
- Urgency: High

---

## Initial Assessment
- Scope: Single instructor workstation affected
- Recent changes: Instructor connected USB headset before class
- Hypothesis: Incorrect microphone selected in Teams or mic muted.

---

## Troubleshooting Timeline

### 1) Replicated the issue  
Joined the active Teams meeting and confirmed microphone showed no activity when speaking.

![Mic not working](../evidence/TKT-004/01.png)

---

### 2) Checked Teams audio settings 
Opened Windows display settings and confirmed system was not duplicating or extending display.

![Checked teams settings](../evidence/TKT-004/02.png)

---

### 3) Verified OS microphone settings
Opened Windows Sound Settings and confirmed laptop was using internal microphone instead of USB headset.

---

### 4) Tested microphone input
Spoke into USB headseat mic and confirmed input levels responded once correct device selected. 

## Root Cause
Teams was configured to use the incorrect microphone device. The instructor had connect a USB headset, but Teams and Windows were still set to the laptop's internhal microphone, which was muted or not picking up sound.

---

## Resolution Steps

### 1) Selected correct microphone in Teams 
Set USB headset as defailt input device in Windows Sound Settings.

![Teams Mic](../evidence/TKT-004/03_.png)

---

### 2) Verified Windows input device 
Set USB headseat as default input device in Windows Sound Settings.

![Verified Input](../evidence/TKT-004/04_.png)

---

## Prevention / Best Practice
- Encourage instructors to verify microphone settings before joining class
- Label classroom USB headsets and ports clearly
- Provide quick-start AV guides in classrooms

---

## Escalation Decision
Not escalated. Issue was resolved at the endpoint by adjusting software and system audio settings.

---

## Lessons Learned
This scenario reinforced the importance of:
- Checking both application-level and OS-level audio settings
- Understanding how conferencing software selects input devices
- Testing audio before live sessions

---

**Status: Resolved**
