# Multi-CRM: RelatesTo — QA Test Cases

**Epic:** CXIFW-379
**Test Plan:** CXIFW-771
**Feature:** Multi-CRM RelatesTo
**Date:** June 2026
**Total TCs:** 14

> **Scope note:** All test cases require **two or more CRMs configured and active simultaneously**. Single-CRM RelatesTo coverage already exists and is out of scope here.

---

## Group 1 — Core RelatesTo Behavior with Two CRMs (4 TCs)

---

**TC1** `[AGTINT][CXA][Multi-CRM][RelatesTo][Voice] Two CRMs configured → RelatesTo on CRM-A pinned record succeeds and records are related in CRM-A only`

**Preconditions:**
- Multi-CRM feature toggle is ON
- Two CRMs configured (e.g. Salesforce + ServiceNow), each with a Search and Create workflow
- Create workflow for both CRMs: Pinned Record = true, relatesTo = true
- Both CRMs have a RelatesTo DM workflow configured

**Steps:**
1. Launch Agent and mark as Available
2. Receive an inbound voice contact
3. Both CRMs return search results and a pinned record in Current Interactions
4. Click the RelatesTo button on the CRM-A (Salesforce) pinned record
5. Select the entity to relate from the popover
6. Verify the RelatesTo button changes state (e.g. turns green)
7. Go to Salesforce and look up the entities that were related
8. Go to ServiceNow and verify no unintended relationship was created

**Expected Result:** The selected entities are now related in Salesforce. ServiceNow records are unaffected.

---

**TC2** `[AGTINT][CXA][Multi-CRM][RelatesTo][Voice] Two CRMs configured → RelatesTo on CRM-B pinned record succeeds and records are related in CRM-B only`

**Preconditions:**
- Multi-CRM feature toggle is ON
- Two CRMs configured (e.g. Salesforce + ServiceNow), each with a Search and Create workflow
- Create workflow for both CRMs: Pinned Record = true, relatesTo = true
- Both CRMs have a RelatesTo DM workflow configured

**Steps:**
1. Launch Agent and mark as Available
2. Receive an inbound voice contact
3. Both CRMs return search results and a pinned record in Current Interactions
4. Click the RelatesTo button on the CRM-B (ServiceNow) pinned record
5. Select the entity to relate from the popover
6. Verify the RelatesTo button changes state
7. Go to ServiceNow and look up the entities that were related
8. Go to Salesforce and verify no unintended relationship was created

**Expected Result:** The selected entities are now related in ServiceNow. Salesforce records are unaffected.

---

**TC3** `[AGTINT][CXA][Multi-CRM][RelatesTo][Voice] Two CRMs configured → RelatesTo can be performed in both CRMs independently on the same contact`

**Preconditions:**
- Multi-CRM feature toggle is ON
- Two CRMs configured (e.g. Salesforce + ServiceNow), each with Search and Create workflows
- Create workflow for both CRMs: Pinned Record = true, relatesTo = true
- Both CRMs have a RelatesTo DM workflow configured

**Steps:**
1. Launch Agent and mark as Available
2. Receive an inbound voice contact
3. Both CRMs return search results and a pinned record in Current Interactions
4. Click the RelatesTo button on the CRM-A pinned record, select an entity, and confirm success
5. Click the RelatesTo button on the CRM-B pinned record, select an entity, and confirm success
6. Go to each CRM and verify the respective relationships were created

**Expected Result:** Both CRMs independently show the new relationship for their respective records. Each RelatesTo action succeeds without interfering with the other.

---

**TC4** `[AGTINT][CXA][Multi-CRM][RelatesTo][Voice] Three CRMs configured (SF + SNOW + MSD) → RelatesTo can be performed in all three CRMs on the same contact`

**Preconditions:**
- Multi-CRM feature toggle is ON
- Salesforce, ServiceNow, and Microsoft Dynamics configured concurrently, each with Search and Create workflows
- Create workflow for all CRMs: Pinned Record = true, relatesTo = true (MSD: Phone Call entity)
- All three CRMs have a RelatesTo DM workflow configured

**Steps:**
1. Launch Agent and mark as Available
2. Receive an inbound voice contact
3. All three CRMs return search results and a pinned record in Current Interactions
4. Click RelatesTo on the SF pinned record, select an entity, confirm success
5. Click RelatesTo on the SNOW pinned record, select an entity, confirm success
6. Click RelatesTo on the MSD pinned record, select an entity, confirm success
7. Verify in each CRM that the respective relationship was created

**Expected Result:** All three CRMs independently show the new relationship for their respective records. No CRM is skipped or errored.

---

## Group 2 — Popover Shows Correct Per-CRM Entities (2 TCs)

---

**TC5** `[AGTINT][CXA][Multi-CRM][RelatesTo][Voice] Two CRMs configured → CRM-A RelatesTo popover shows only CRM-A's relatable entities`

**Preconditions:**
- Multi-CRM feature toggle is ON
- Two CRMs configured concurrently, both returning multiple Related Interactions
- Create workflow for both CRMs: Pinned Record = true, relatesTo = true

**Steps:**
1. Launch Agent and mark as Available
2. Receive an inbound voice contact that returns multiple Related Interactions for each CRM
3. Click the RelatesTo button on the CRM-A pinned record
4. Note the entities listed in the popover

**Expected Result:** The popover shows only entities from CRM-A's Related Interactions. No CRM-B records appear in the CRM-A popover.

---

**TC6** `[AGTINT][CXA][Multi-CRM][RelatesTo][Voice] Two CRMs configured → CRM-B RelatesTo popover shows only CRM-B's relatable entities`

**Preconditions:**
- Multi-CRM feature toggle is ON
- Two CRMs configured concurrently, both returning multiple Related Interactions
- Create workflow for both CRMs: Pinned Record = true, relatesTo = true

**Steps:**
1. Launch Agent and mark as Available
2. Receive an inbound voice contact that returns multiple Related Interactions for each CRM
3. Click the RelatesTo button on the CRM-B pinned record
4. Note the entities listed in the popover

**Expected Result:** The popover shows only entities from CRM-B's Related Interactions. No CRM-A records appear in the CRM-B popover.

---

## Group 3 — Loading State and Error Isolation (2 TCs)

---

**TC7** `[AGTINT][CXA][Multi-CRM][RelatesTo][Voice] Two CRMs configured → RelatesTo loading state is scoped to the clicked CRM's button only`

**Preconditions:**
- Multi-CRM feature toggle is ON
- Two CRMs configured concurrently, each with a pinned RelatesTo-enabled record

**Steps:**
1. Launch Agent and mark as Available
2. Receive an inbound voice contact; both CRMs produce a pinned record
3. Click the RelatesTo button on the CRM-A pinned record
4. Immediately observe both the CRM-A RelatesTo button and the CRM-B RelatesTo button

**Expected Result:** A loading indicator appears on the CRM-A RelatesTo button only. The CRM-B button remains in its normal idle state.

---

## Group 4 — State Doesn't Bleed Between Contacts or CRMs (2 TCs)

---

**TC8** `[AGTINT][CXA][Multi-CRM][RelatesTo][Voice] Two CRMs configured → after contact ends, RelatesTo state from that contact does not appear on the next contact`

**Preconditions:**
- Multi-CRM feature toggle is ON
- Two CRMs configured concurrently, each with a pinned RelatesTo-enabled record

**Steps:**
1. Launch Agent and mark as Available
2. Receive an inbound voice contact; perform a RelatesTo action in both CRMs
3. End the contact and complete ACW
4. Receive a new inbound voice contact
5. Observe the RelatesTo buttons and popovers for both CRMs on the new contact

**Expected Result:** The new contact's RelatesTo buttons appear in their default idle state. No related entity from the previous contact is pre-selected or carried over in either CRM's popover.

---

## Group 5 — Digital Channel (2 TCs)

---

**TC9** `[AGTINT][CXA][Multi-CRM][RelatesTo][Digital] Two CRMs configured → RelatesTo on CRM-A pinned record succeeds on a digital contact`

**Preconditions:**
- Multi-CRM feature toggle is ON
- Two CRMs configured (e.g. Salesforce + ServiceNow), each with a Search and Create workflow for Digital
- Create workflow for both CRMs: Pinned Record = true, relatesTo = true
- Digital chat is set up

**Steps:**
1. Launch Agent and mark as Available
2. Set up a digital chat and connect to a contact
3. Both CRMs return search results and a pinned record in Current Interactions
4. Click the RelatesTo button on the CRM-A pinned record
5. Select the entity to relate from the popover
6. Verify the RelatesTo button changes state
7. Go to CRM-A and verify the entities are now related

**Expected Result:** The selected entities are related in CRM-A. CRM-B is unaffected.

---

**TC10** `[AGTINT][CXA][Multi-CRM][RelatesTo][Digital] Two CRMs configured → RelatesTo can be performed in both CRMs independently on the same digital contact`

**Preconditions:**
- Multi-CRM feature toggle is ON
- Two CRMs configured concurrently for Digital, each with Search and Create workflows
- Create workflow for both CRMs: Pinned Record = true, relatesTo = true
- Digital chat is set up

**Steps:**
1. Launch Agent and mark as Available
2. Set up a digital chat and connect to a contact
3. Both CRMs return search results and a pinned record in Current Interactions
4. Click RelatesTo on the CRM-A pinned record, select an entity, confirm success
5. Click RelatesTo on the CRM-B pinned record, select an entity, confirm success
6. Go to each CRM and verify the respective relationships were created

**Expected Result:** Both CRMs independently show the new relationship for their respective records. Each RelatesTo action succeeds without interfering with the other.

---

## Group 6 — relatesTo Config Combinations (4 TCs)

---

**TC11** `[AGTINT][CXA][Multi-CRM][RelatesTo][Voice] Two CRMs — CRM-A: relatesTo = true, CRM-B: relatesTo = false → RelatesTo button appears for CRM-A only; CRM-B has no RelatesTo button`

**Preconditions:**
- Multi-CRM feature toggle is ON
- Two CRMs configured (e.g. Salesforce + ServiceNow), each with a Search and Create workflow
- Create workflow: CRM-A has Pinned Record = true, **relatesTo = true**; CRM-B has Pinned Record = true, **relatesTo = false**
- Agent logged into CX Agent

**Steps:**
1. Launch Agent and mark as Available
2. Receive an inbound voice contact
3. Both CRMs return search results and a pinned record in Current Interactions
4. Observe the CRM-A pinned record card — check for the presence of a RelatesTo button
5. Observe the CRM-B pinned record card — check for the presence of a RelatesTo button

**Expected Result:** The RelatesTo button is visible and interactable on the CRM-A pinned record. No RelatesTo button appears on the CRM-B pinned record. CRM-B's card renders normally in all other respects.

---

**TC12** `[AGTINT][CXA][Multi-CRM][RelatesTo][Voice] Two CRMs — both relatesTo = false → no RelatesTo buttons appear on either CRM's pinned record`

**Preconditions:**
- Multi-CRM feature toggle is ON
- Two CRMs configured, each with a Search and Create workflow
- Create workflow for **both** CRMs: Pinned Record = true, **relatesTo = false**
- Agent logged into CX Agent

**Steps:**
1. Launch Agent and mark as Available
2. Receive an inbound voice contact
3. Both CRMs return search results and a pinned record in Current Interactions
4. Observe both CRM pinned record cards for the presence of any RelatesTo button

**Expected Result:** No RelatesTo button appears on either CRM's pinned record card. Both cards render normally with no RelatesTo UI element present. No errors or unexpected elements in the console.

---

**TC13** `[AGTINT][CXA][Multi-CRM][RelatesTo][Voice] Three CRMs — CRM-A: relatesTo = true, CRM-B: relatesTo = false, CRM-C: relatesTo = true → RelatesTo available in CRM-A and CRM-C; absent in CRM-B`

**Preconditions:**
- Multi-CRM feature toggle is ON
- Three CRMs configured (e.g. Salesforce + ServiceNow + Dynamics), each with a Search and Create workflow
- Create workflow: CRM-A Pinned Record = true, **relatesTo = true**; CRM-B Pinned Record = true, **relatesTo = false**; CRM-C Pinned Record = true, **relatesTo = true**
- CRM-A and CRM-C have a RelatesTo DM workflow configured; CRM-B does not
- Agent logged into CX Agent

**Steps:**
1. Launch Agent and mark as Available
2. Receive an inbound voice contact
3. All three CRMs return search results and a pinned record in Current Interactions
4. Observe the CRM-A pinned record card for a RelatesTo button
5. Observe the CRM-B pinned record card for a RelatesTo button
6. Observe the CRM-C pinned record card for a RelatesTo button
7. Click the RelatesTo button on CRM-A, select an entity, and confirm success
8. Click the RelatesTo button on CRM-C, select an entity, and confirm success

**Expected Result:** RelatesTo buttons are present and functional on CRM-A and CRM-C. No RelatesTo button appears on CRM-B's card. The RelatesTo actions on CRM-A and CRM-C complete successfully and independently. CRM-B is unaffected by either action.

---

**TC14** `[AGTINT][CXA][Multi-CRM][RelatesTo][Voice] Two CRMs — CRM-A: relatesTo = false, CRM-B: relatesTo = true → RelatesTo action on CRM-B succeeds; CRM-A remains unaffected with no RelatesTo button`

**Preconditions:**
- Multi-CRM feature toggle is ON
- Two CRMs configured, each with a Search and Create workflow
- Create workflow: CRM-A Pinned Record = true, **relatesTo = false**; CRM-B Pinned Record = true, **relatesTo = true**
- CRM-B has a RelatesTo DM workflow configured
- Agent logged into CX Agent

**Steps:**
1. Launch Agent and mark as Available
2. Receive an inbound voice contact
3. Both CRMs return search results and a pinned record in Current Interactions
4. Confirm no RelatesTo button is present on the CRM-A card
5. Click the RelatesTo button on the CRM-B pinned record
6. Select the entity to relate from the popover
7. Verify the RelatesTo button on CRM-B changes state (e.g. turns green)
8. Go to CRM-B and look up the entities that were related
9. Confirm no unintended relationship was created in CRM-A

**Expected Result:** No RelatesTo button is present on CRM-A's card. The RelatesTo action on CRM-B completes successfully and the relationship is created in CRM-B. CRM-A records are entirely unaffected.

---
