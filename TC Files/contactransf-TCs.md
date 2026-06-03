# Multi-CRM: Contact Transfer — QA Test Cases

**Epic:** CXIFW-381  
**Feature:** Multi-CRM Contact Transfer  
**Date:** May 2026
**Total TCs:** 21

---

## Group 1 — Transfer Data Retrieval (4 TCs)

---

**TC1** `[AGTINT][CXA][Multi-CRM][ContactTransfer][Voice] Two CRMs active during transfer → transfer data loads and displays correctly for both CRMs independently`

**Preconditions:**
- Multi-CRM feature toggle is ON
- Two CRMs configured and active (e.g. Salesforce and ServiceNow)
- Agent is on a live voice contact
- Transfer target is available

**Steps:**
1. Accept an inbound voice contact with two CRMs active
2. Initiate a contact transfer
3. Observe the CRM panels for both CRMs during the transfer process
4. Complete the transfer

**Expected Result:** Both CRM panels display their respective transfer data. Each CRM card loads its own data independently. Data from one CRM does not appear in the other CRM's panel. Both panels are populated — neither is blank or stuck in a loading state.

---

**TC2** `[AGTINT][CXA][Multi-CRM][ContactTransfer][Digital] Two CRMs active during transfer → transfer data loads and displays correctly for both CRMs independently`

**Preconditions:**
- Multi-CRM feature toggle is ON
- Two CRMs configured and active
- Agent is on a live digital contact
- Transfer target is available

**Steps:**
1. Accept an inbound digital contact with two CRMs active
2. Initiate a contact transfer
3. Observe both CRM panels during the transfer process
4. Complete the transfer

**Expected Result:** Both CRM panels display their respective transfer data correctly for the digital contact type. Each CRM card is populated independently and neither is blank or in error.

---

**TC3** `[AGTINT][CXA][Multi-CRM][ContactTransfer][Voice] Transfer response contains multiple records per CRM → all records are displayed, not just the first`

**Preconditions:**
- Multi-CRM feature toggle is ON
- At least one CRM is configured and returns multiple records in the transfer response
- Agent is on a live voice contact

**Steps:**
1. Accept an inbound voice contact
2. Initiate a contact transfer where the CRM is expected to return multiple records
3. Observe the CRM panel after transfer data is retrieved

**Expected Result:** All records returned in the transfer response are displayed in the CRM panel. No records are silently dropped or truncated. The full result set is reflected in the UI.

---

**TC4** `[AGTINT][CXA][Multi-CRM][ContactTransfer][Voice] Three CRMs active during transfer → transfer data loads for all three CRMs simultaneously`

**Preconditions:**
- Multi-CRM feature toggle is ON
- Three CRMs configured and active
- Agent is on a live voice contact

**Steps:**
1. Accept an inbound voice contact with three CRMs active
2. Initiate a contact transfer
3. Observe all three CRM panels during and after the transfer

**Expected Result:** All three CRM panels independently load and display their respective transfer data. No CRM panel is skipped, stuck loading, or displaying another CRM's data.

---

## Group 2 — Per-CRM Pinned Records (2 TCs)

---

**TC5** `[AGTINT][CXA][Multi-CRM][ContactTransfer][Voice] Record pinned in CRM-A before transfer → pin is preserved and correct in CRM-A after transfer completes`

**Preconditions:**
- Multi-CRM feature toggle is ON
- Two CRMs configured and active
- A record has been pinned in CRM-A prior to transfer

**Steps:**
1. Accept an inbound voice contact with two CRMs active
2. Pin a record in CRM-A's panel
3. Initiate and complete a contact transfer
4. Observe CRM-A's pinned record after the transfer completes

**Expected Result:** The record that was pinned in CRM-A before the transfer remains pinned and correctly displayed after the transfer. The pin is not lost, reset, or replaced with a different record.

---

**TC6** `[AGTINT][CXA][Multi-CRM][ContactTransfer][Voice] Both CRMs have pinned records → each CRM displays only its own pinned record after transfer`

**Preconditions:**
- Multi-CRM feature toggle is ON
- Two CRMs configured and active
- A record is pinned in CRM-A and a different record is pinned in CRM-B

**Steps:**
1. Accept an inbound voice contact with two CRMs active
2. Pin a record in CRM-A and a different record in CRM-B
3. Initiate and complete a contact transfer
4. Observe the pinned record for each CRM after transfer

**Expected Result:** CRM-A displays its own pinned record. CRM-B displays its own pinned record. Neither CRM shows the other's pinned record. Pin states are maintained independently through the transfer.

---

## Group 3 — Keep-Alive Session Continuity (3 TCs)

---

**TC7** `[AGTINT][CXA][Multi-CRM][ContactTransfer][Voice] Contact transfer initiated → keep-alive polling continues uninterrupted throughout the transfer`

**Preconditions:**
- Multi-CRM feature toggle is ON
- At least one CRM configured and active
- Agent is on a live voice contact with keep-alive active
- Browser network tab is accessible for monitoring requests

**Steps:**
1. Accept an inbound voice contact and confirm keep-alive polling is active
2. Initiate a contact transfer
3. Monitor keep-alive polling requests in the browser network tab during the transfer
4. Complete the transfer and continue monitoring briefly

**Expected Result:** Keep-alive polling requests continue at the expected interval throughout the entire transfer process with no gaps, interruptions, or errors. The session does not drop or time out during transfer.

---

**TC8** `[AGTINT][CXA][Multi-CRM][ContactTransfer][Digital] Contact transfer initiated → keep-alive polling continues uninterrupted throughout the transfer`

**Preconditions:**
- Multi-CRM feature toggle is ON
- At least one CRM configured and active
- Agent is on a live digital contact with keep-alive active

**Steps:**
1. Accept an inbound digital contact and confirm keep-alive polling is active
2. Initiate a contact transfer
3. Monitor keep-alive requests during the transfer
4. Complete the transfer

**Expected Result:** Keep-alive polling requests continue uninterrupted for the digital contact transfer. No session timeout or polling gap occurs during the transfer process.

---

**TC9** `[AGTINT][CXA][Multi-CRM][ContactTransfer][Voice] Transfer completes and contact ends → keep-alive polling stops and session resources are cleaned up`

**Preconditions:**
- Multi-CRM feature toggle is ON
- At least one CRM configured and active
- Agent is on a live voice contact with keep-alive active

**Steps:**
1. Accept an inbound voice contact
2. Initiate and complete a contact transfer
3. End the contact after the transfer completes
4. Monitor keep-alive polling requests after the contact ends

**Expected Result:** Keep-alive polling stops after the contact ends. No lingering polling requests fire after session cleanup. No errors or unhandled exceptions appear in the console.

---

## Group 4 — Single-CRM & Legacy Compatibility (2 TCs)

---

**TC10** `[AGTINT][CXA][Multi-CRM][ContactTransfer][Voice] Single CRM configured → transfer behavior is identical to pre-multi-CRM behavior`

**Preconditions:**
- Multi-CRM feature toggle is ON
- Only one CRM is configured (single-CRM mode)
- Agent is on a live voice contact

**Steps:**
1. Accept an inbound voice contact with one CRM configured
2. Initiate and complete a contact transfer
3. Observe the CRM panel and Contact Assignment panel behavior
4. Compare behavior to expected legacy single-CRM transfer behavior

**Expected Result:** Transfer completes normally with identical behavior to legacy single-CRM transfer. No regressions in data display, panel rendering, or workflow execution. The Contact Assignment panel shows accurate and current data.

---

**TC11** `[AGTINT][CXA][Multi-CRM][ContactTransfer][Digital] Single CRM configured → transfer behavior is identical to pre-multi-CRM behavior`

**Preconditions:**
- Multi-CRM feature toggle is ON
- Only one CRM is configured (single-CRM mode)
- Agent is on a live digital contact

**Steps:**
1. Accept an inbound digital contact with one CRM configured
2. Initiate and complete a contact transfer
3. Observe the CRM panel and Contact Assignment panel behavior

**Expected Result:** Transfer completes normally with no regressions. Contact Assignment panel displays accurate data. Behavior matches the pre-multi-CRM digital transfer experience.

---

## Group 5 — State Cleanup (2 TCs)

---

**TC12** `[AGTINT][CXA][Multi-CRM][ContactTransfer][Voice] Transfer ends and contact closes → all per-CRM transfer data is cleared before the next contact arrives`

**Preconditions:**
- Multi-CRM feature toggle is ON
- Two CRMs configured and active
- A contact with transfer data has just ended

**Steps:**
1. Accept an inbound voice contact with two CRMs active
2. Initiate and complete a contact transfer
3. End the contact
4. Accept a new inbound voice contact
5. Observe both CRM panels at the start of the new contact

**Expected Result:** Both CRM panels start clean for the new contact. No transfer data, pinned records, or error state from the previous contact persists into the new contact session.

---

**TC13** `[AGTINT][CXA][Multi-CRM][ContactTransfer][Voice] New contact arrives after a multi-CRM transfer → no residual transfer data from the previous contact is visible`

**Preconditions:**
- Multi-CRM feature toggle is ON
- Two CRMs configured and active
- Previous contact involved a multi-CRM transfer with visible data

**Steps:**
1. Complete a contact with an active multi-CRM transfer
2. End the contact and wait for it to fully close
3. Accept a new inbound voice contact
4. Inspect both CRM panels at the start of the new contact — prior to any data loading for the new contact

**Expected Result:** No transfer data records, pinned records, or error indicators from the previous contact are shown in either CRM panel at the start of the new contact. Both panels start in a clean, initial state.

---

## Group 6 — Agent Workflow Config During Transfer (2 TCs)

---

**TC14** `[AGTINT][CXA][Multi-CRM][ContactTransfer][Voice] Contact transfer initiated → Agent Workflow Config data is present in the transfer network request`

**Preconditions:**
- Multi-CRM feature toggle is ON
- At least one CRM configured and active
- Agent is on a live voice contact
- Browser network tab is accessible for monitoring requests

**Steps:**
1. Accept an inbound voice contact
2. Open the browser network tab and filter for transfer-related requests
3. Initiate a contact transfer
4. Capture and inspect the outbound network request payload at the time of transfer

**Expected Result:** The Agent Workflow Config data is present in the transfer network request payload. The config fields are correctly populated and match the expected configuration for the interaction. No config fields are missing or null.

---

**TC15** `[AGTINT][CXA][Multi-CRM][ContactTransfer][Voice] Contact transfer initiated → Agent Workflow Config data is persisted in local storage for the interaction`

**Preconditions:**
- Multi-CRM feature toggle is ON
- At least one CRM configured and active
- Agent is on a live voice contact

**Steps:**
1. Accept an inbound voice contact
2. Initiate a contact transfer
3. Open browser DevTools and inspect local storage after the transfer is initiated
4. Locate the entry corresponding to the current interaction

**Expected Result:** The Agent Workflow Config data is persisted in local storage for the interaction. The stored value matches the config data sent in the network request. The entry is scoped to the current interaction and is not shared with or overwritten by other interactions.

---

## Group 7 — Data Memorialization on Transfer (4 TCs)

---

**TC16** `[AGTINT][CXA][Multi-CRM][ContactTransfer][Voice] Contact is transferred → Data Memorialization call fires for the originating contact upon transfer completion`

**Preconditions:**
- Multi-CRM feature toggle is ON
- Two CRMs configured and active
- Agent is on a live voice contact
- Browser network tab is accessible for monitoring DM requests

**Steps:**
1. Accept an inbound voice contact
2. Initiate and complete a contact transfer
3. Confirm the contact ends upon transfer

**Expected Result:** Once the call is tranferred it should be treated as an ended
call. The data should be memorialized based on your data mapping.

---

**TC17** `[AGTINT][CXA][Multi-CRM][ContactTransfer][Digital] Contact is transferred → Data Memorialization call fires for the originating contact upon transfer completion`

**Preconditions:**
- Multi-CRM feature toggle is ON
- Two CRMs configured and active
- Ensure timeline workflow is included in the config
- Agent is on a live digital contact
- Browser network tab is accessible for monitoring DM requests

**Steps:**
1. Receive an inbound digital contact
2. Initiate and complete a contact transfer
3. Confirm the contact ends upon transfer
4. Check the network tab for DM payload firing
5. Ensure data memorializes as configured, including timeline

**Expected Result:** Once the call is tranferred it should be treated as an ended
call. The data should be memorialized based on your data mapping.

---

**TC18** `[AGTINT][CXA][Multi-CRM][ContactTransfer][Voice] Receiving agent ends the transferred contact → Data Memorialization call fires for the transferred-to contact`

**Preconditions:**
- Multi-CRM feature toggle is ON
- Two CRMs configured and active
- Ensure timeline workflow is included in the config
- A contact has been successfully transferred to a receiving agent
- Receiving agent's session is active and the transferred contact is live
- Browser network tab is accessible for monitoring DM requests

**Steps:**
1. Complete a contact transfer so the receiving agent has the active contact
2. Monitor network requests on the receiving agent's session
3. Have the receiving agent end the contact
4. Observe the DM network request triggered on contact end
5. Ensure data memorializes as configured, including timeline

**Expected Result:** A Data Memorialization network call fires for the transferred-to contact when the receiving agent ends the call.