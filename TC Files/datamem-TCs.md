## Group 1 — Feature Toggle State (2 TCs)

---

**TC1** `[AGTINT][CXA][Multi-CRM][DataMemorialization][Voice] Toggle OFF → no multi-CRM DM calls fire on voice contact end`

**Preconditions:**
- Multi-CRM feature toggle is OFF
- At least one CRM is configured with Data Memorialization enabled
- Agent logged into CX Agent

**Steps:**
1. Accept an inbound voice contact
2. End the call
3. Open the browser network tab and filter for `DataMemorialization` requests

**Expected Result:** The legacy single-CRM DM call fires as normal. No multi-CRM `DataMemorialization` calls fire. The multi-CRM CRM panel UI is not present.

---

**TC2** `[AGTINT][CXA][Multi-CRM][DataMemorialization][Digital] Toggle OFF → no multi-CRM DM calls fire on digital contact close`

**Preconditions:**
- Multi-CRM feature toggle is OFF
- At least one CRM is configured with Data Memorialization enabled
- Agent logged into CX Agent

**Steps:**
1. Accept an inbound digital contact
2. Close the contact
3. Open the browser network tab and filter for `DataMemorialization` requests

**Expected Result:** The legacy single-CRM DM call fires as normal. No multi-CRM `DataMemorialization` calls fire.

---

## Group 2 — Linked Entity Filtering (4 TCs)

---

**TC3** `[AGTINT][CXA][Multi-CRM][DataMemorialization] All DM-configured CRMs have linked entities → all show a link button and DM fires once for each CRM`

**Preconditions:**
- Multi-CRM feature toggle is ON
- All configured CRMs (e.g., 3) have DM in their workflow event and at least one entity linked
- Agent logged into CX Agent

**Steps:**
1. Accept a contact
2. Open the CRM panel for each DM-configured CRM and confirm a link/unlink button is present
3. Confirm at least one entity is linked in each panel
4. End or close the contact
5. Monitor the browser network tab for `DataMemorialization` requests

**Expected Result:** Each DM-configured CRM panel displays a link button. One DM call fires per DM-configured CRM. Total DM call count equals the number of CRMs with DM configured. No calls are missing or duplicated.

---

**TC4** `[AGTINT][CXA][Multi-CRM][DataMemorialization] Some CRMs have linked entities, others do not → DM fires only for the linked CRMs`

**Preconditions:**
- Multi-CRM feature toggle is ON
- Mixed configuration: at least one CRM with DM enabled and a linked entity, and at least one CRM with DM enabled but no linked entity
- Agent logged into CX Agent

**Steps:**
1. Accept a contact
2. In the CRM panels with linked entities, confirm at least one entity is checked
3. In the CRM panels without linked entities, confirm no entity is checked
4. End or close the contact
5. Monitor the browser network tab for `DataMemorialization` requests

**Expected Result:** DM fires only for CRMs that have DM configured AND at least one linked entity. No DM call fires for CRMs with no linked entity.

---

**TC5** `[AGTINT][CXA][Multi-CRM][DataMemorialization] No CRM has a linked entity → no DM calls fire`

**Preconditions:**
- Multi-CRM feature toggle is ON
- CRMs have DM configured but no entities are linked in any CRM panel
- Agent logged into CX Agent

**Steps:**
1. Accept a contact
2. Confirm that no entity is linked in any CRM panel
3. End or close the contact
4. Monitor the browser network tab for `DataMemorialization` requests

**Expected Result:** No DM calls fire. The agent is not blocked from continuing work.

---

**TC6** `[AGTINT][CXA][Multi-CRM][DataMemorialization] CRMs without DM configured → no DM call fires for those CRMs`

**Preconditions:**
- Multi-CRM feature toggle is ON
- Mixed configuration: at least one CRM with DM and linked entity, and at least one CRM without DM configured
- Agent logged into CX Agent

**Steps:**
1. Accept a contact
2. End or close the contact with linked entities in the DM-configured CRMs
3. Monitor the browser network tab for `DataMemorialization` requests

**Expected Result:** No DM call fires for CRMs without DM configured. DM fires normally for any CRM that has DM configured and at least one linked entity.

---

## Group 3 — Default Pin Record Behavior (2 TCs)

---

**TC7** `[AGTINT][CXA][Multi-CRM][DataMemorialization] Pin records are linked by default on contact arrival → DM payload includes them without agent action`

**Preconditions:**
- Multi-CRM feature toggle is ON
- CRMs configured with DM and pin records
- Agent logged into CX Agent

**Steps:**
1. Accept a new contact
2. Open the CRM panel immediately — do not interact with the link toggle
3. Observe the linked state of the pin records
4. End the contact without unlinking any pin records
5. Inspect the DM request payload in the browser network tab

**Expected Result:** Pin records appear in a linked/checked state automatically when the contact arrives, without any agent action. DM fires and the payload includes the pin records.

---

**TC8** `[AGTINT][CXA][Multi-CRM][DataMemorialization] Agent unlinks a default-linked pin record → unlinked records excluded from DM payload`

**Preconditions:**
- Multi-CRM feature toggle is ON
- CRMs configured with DM and pin records
- Agent logged into CX Agent

**Steps:**
1. Accept a contact
2. In the CRM panel, unlink one or more pin records using the link toggle
3. End the contact
4. Inspect the DM request payload in the browser network tab

**Expected Result:** DM fires for the CRM. The unlinked pin records are not present in the DM payload. If all records (pin and regular) are unlinked, DM does not fire for that CRM.

---

## Group 4 — Voice Interaction Triggers (4 TCs)

---

**TC9** `[AGTINT][CXA][Multi-CRM][DataMemorialization][Voice] Voice disconnect + no disposition configured → DM fires per DM-configured CRM on call end`

**Preconditions:**
- Multi-CRM feature toggle is ON
- CRMs configured with Data Memorialization
- Skill/queue has no disposition configured
- Agent logged into CX Agent

**Steps:**
1. Accept an inbound voice contact
2. Link at least one entity per DM-configured CRM
3. End the call
4. Monitor the browser network tab for `DataMemorialization` requests

**Expected Result:** One DM call fires per DM-configured CRM with linked entities on voice disconnect. Legacy single-CRM DM does not fire.

---

**TC10** `[AGTINT][CXA][Multi-CRM][DataMemorialization][Voice] Voice disconnect + disposition enabled but not required → DM fires on disconnect without waiting for disposition save`

**Preconditions:**
- Multi-CRM feature toggle is ON
- CRMs configured with Data Memorialization
- Skill/queue has disposition enabled but not required
- Agent logged into CX Agent

**Steps:**
1. Accept an inbound voice contact
2. Link at least one entity per DM-configured CRM
3. End the call without clicking Save in the disposition panel
4. Monitor the browser network tab for `DataMemorialization` requests

**Expected Result:** DM fires once per DM-configured CRM with linked entities on voice disconnect. DM fires even though the agent did not save the disposition.

---

**TC11** `[AGTINT][CXA][Multi-CRM][DataMemorialization][Voice] Voice disconnect + disposition required → DM fires only after contact is ended AND required disposition is saved`

**Preconditions:**
- Multi-CRM feature toggle is ON
- CRMs configured with Data Memorialization
- Skill/queue has disposition enabled and required
- Agent logged into CX Agent

**Steps:**
1. Accept an inbound voice contact
2. Link at least one entity per DM-configured CRM
3. End the call
4. Monitor the browser network tab immediately on disconnect — note whether any DM calls fire at this step
5. Complete and save the required disposition in the ACW panel
6. Monitor the browser network tab again

**Expected Result:** No DM call fires on voice disconnect alone (step 3) when disposition is required but not yet saved. DM fires once per DM-configured CRM with linked entities only after the required disposition is saved (step 5).

---

**TC12** `[AGTINT][CXA][Multi-CRM][DataMemorialization][Voice] Voice transfer → DM fires per DM-configured CRM with linked entities`

**Preconditions:**
- Multi-CRM feature toggle is ON
- CRMs configured with Data Memorialization
- Agent logged into CX Agent

**Steps:**
1. Accept an inbound voice contact
2. Link at least one entity per DM-configured CRM
3. Transfer the call to another agent or queue
4. Monitor the browser network tab for `DataMemorialization` requests

**Expected Result:** DM fires once per DM-configured CRM with linked entities. Legacy single-CRM DM does not fire.

---

## Group 5 — Digital Interaction Triggers (8 TCs)

---

**TC13** `[AGTINT][CXA][Multi-CRM][DataMemorialization][Digital] Digital contact closed + no disposition configured → DM fires when contact reaches Closed status`

**Preconditions:**
- Multi-CRM feature toggle is ON
- CRMs configured with Data Memorialization
- Skill/queue has no disposition configured
- Agent logged into CX Agent

**Steps:**
1. Accept a digital contact
2. Link at least one entity per DM-configured CRM
3. Close the contact
4. Monitor the browser network tab for `DataMemorialization` requests

**Expected Result:** DM fires once per DM-configured CRM with linked entities when the contact reaches Closed status.

---

**TC14** `[AGTINT][CXA][Multi-CRM][DataMemorialization][Digital] Digital contact closed + disposition enabled but not required → DM fires on close without agent saving disposition`

**Preconditions:**
- Multi-CRM feature toggle is ON
- CRMs configured with Data Memorialization
- Skill/queue has disposition enabled but not required
- Agent logged into CX Agent

**Steps:**
1. Accept a digital contact
2. Link at least one entity per DM-configured CRM
3. Close the contact without saving the disposition
4. Monitor the browser network tab for `DataMemorialization` requests

**Expected Result:** DM fires once per DM-configured CRM with linked entities when the contact reaches Closed status. DM fires without the agent having saved the disposition.

---

**TC15** `[AGTINT][CXA][Multi-CRM][DataMemorialization][Digital] Setting the disposition form status to "Closed" pre-close → DM does not fire prematurely; fires only on actual contact close`

**Preconditions:**
- Multi-CRM feature toggle is ON
- CRMs configured with Data Memorialization
- Skill/queue has disposition enabled but not required
- Agent logged into CX Agent

**Steps:**
1. Accept a digital contact
2. Link at least one entity per DM-configured CRM
3. In the disposition panel, set the status dropdown to "Closed" — do not click Save
4. Monitor the browser network tab — note whether any DM calls fire at this step
5. Fully close the digital contact (contact reaches system Closed status)
6. Monitor the browser network tab again

**Expected Result:** No DM call fires when the agent sets the form status field to "Closed" before the contact is actually closed (step 3). DM fires once per DM-configured CRM when the contact reaches system Closed status (step 5).

---

**TC16** `[AGTINT][CXA][Multi-CRM][DataMemorialization][Digital] Required disposition saved before contact close → DM fires when contact reaches Closed status with disposition data included`

**Preconditions:**
- Multi-CRM feature toggle is ON
- CRMs configured with Data Memorialization
- Skill/queue has disposition enabled and required
- Agent logged into CX Agent

**Steps:**
1. Accept a digital contact
2. Link at least one entity per DM-configured CRM
3. Complete and save the required disposition while the contact is still active
4. Close the contact
5. Monitor the browser network tab for `DataMemorialization` requests and inspect the payload

**Expected Result:** DM fires once per DM-configured CRM with linked entities when the contact reaches Closed status. The DM payload includes the saved disposition data.

---

**TC17** `[AGTINT][CXA][Multi-CRM][DataMemorialization][Digital] Contact closes before required disposition is saved → DM fires when agent saves disposition post-close`

**Preconditions:**
- Multi-CRM feature toggle is ON
- CRMs configured with Data Memorialization
- Skill/queue has disposition enabled and required
- Agent logged into CX Agent

**Steps:**
1. Accept a digital contact
2. Link at least one entity per DM-configured CRM
3. Close the contact without saving the required disposition
4. Monitor the browser network tab — no DM should fire at this point
5. With the contact now closed, complete and click Save in the disposition panel
6. Monitor the browser network tab

**Expected Result:** DM does not fire on contact close (step 3) because the required disposition has not yet been saved. DM fires once per DM-configured CRM with linked entities when the agent saves the disposition after the contact is closed (step 5).

---

**TC18** `[AGTINT][CXA][Multi-CRM][DataMemorialization][Digital] Disposition Save fires DM only when contact is already CLOSED → no duplicate DM call when the contact subsequently closes`

**Preconditions:**
- Multi-CRM feature toggle is ON
- CRMs configured with Data Memorialization
- Skill/queue has disposition enabled and required
- Agent logged into CX Agent

**Steps:**
1. Accept a digital contact
2. Link at least one entity per DM-configured CRM
3. Complete and click Save in the disposition panel while the contact is still active
4. Observe whether any DM calls fire at this point (they should not)
5. Close the contact
6. Monitor the browser network tab for total `DataMemorialization` call count throughout the session

**Expected Result:** No DM call fires when the agent clicks Save while the contact is still active (step 3). DM fires once per DM-configured CRM when the contact closes (step 5). No duplicate DM calls appear for any CRM throughout the session.

---

**TC19** `[AGTINT][CXA][Multi-CRM][DataMemorialization][Digital] Digital contact unassignment → DM fires per DM-configured CRM with linked entities`

**Preconditions:**
- Multi-CRM feature toggle is ON
- CRMs configured with Data Memorialization
- Agent logged into CX Agent

**Steps:**
1. Accept a digital contact
2. Link at least one entity per DM-configured CRM
3. Unassign the contact (supervisor reassigns it or agent routes to queue)
4. Monitor the browser network tab for `DataMemorialization` requests

**Expected Result:** DM fires once per DM-configured CRM with linked entities. Legacy single-CRM DM does not fire.

---

**TC20** `[AGTINT][CXA][Multi-CRM][DataMemorialization][Digital] Digital contact transfer → DM fires per DM-configured CRM with linked entities`

**Preconditions:**
- Multi-CRM feature toggle is ON
- CRMs configured with Data Memorialization
- Agent logged into CX Agent

**Steps:**
1. Accept a digital contact
2. Link at least one entity per DM-configured CRM
3. Transfer the digital contact to another agent or queue
4. Monitor the browser network tab for `DataMemorialization` requests

**Expected Result:** DM fires once per DM-configured CRM with linked entities. Legacy single-CRM DM does not fire.

---

## Group 6 — Dispatch Guard / No Duplicate DM (1 TC)

---

**TC21** `[AGTINT][CXA][Multi-CRM][DataMemorialization][Voice] Multiple potential trigger points for the same contact → exactly one DM call per CRM with no duplicates`

**Preconditions:**
- Multi-CRM feature toggle is ON
- CRMs configured with Data Memorialization
- Skill/queue has disposition enabled but not required
- Agent logged into CX Agent

**Steps:**
1. Accept a voice contact
2. Link entities in each DM-configured CRM
3. Submit a disposition (Save) while the call is still active
4. End the call
5. Monitor the browser network tab for all `DataMemorialization` calls throughout the full session

**Expected Result:** DM fires exactly once per DM-configured CRM with linked entities. No duplicate `DataMemorialization` API calls appear for the same CRM and contact.