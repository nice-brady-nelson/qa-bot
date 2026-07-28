# Multi-CRM: RelatesTo — CRM-Specific Test Cases (Review Draft)

**Supported CRMs for RelatesTo:** Salesforce, ServiceNow, Dynamics 365

> Note: Kustomer, Oracle, and Zendesk do not support RelatesTo and are excluded from these scenarios.

**Total TCs: 20**

---

## Changes Summary

| Jira Key | Status | Action |
|---|---|---|
| CRM-25762 | Reviewing | Merge with CRM-25774 → TC1 (button presence + action in one test) |
| CRM-25764 | Reviewing | Merge with CRM-25767 → TC4–TC6 (popover isolation becomes a step, not separate TCs) |
| CRM-25765 | Reviewing | No change — already names Salesforce, ServiceNow, Dynamics specifically |
| CRM-25767 | Reviewing | Retire → popover isolation rolled into Section B as an observation step |
| CRM-25768 | Reviewing | Update → replace CRM-A/CRM-B with Salesforce + ServiceNow |
| CRM-25774 | Reviewing | Merge with CRM-25762 → TC1–TC3 (config isolation + action success in one test per CRM) |
| CRM-25775 | Reviewing | Update → name Salesforce + ServiceNow specifically |
| CRM-25776 | Reviewing | Update → TC8–TC10: one test per CRM in the false position (SF/SN/Dyn only) |
| CRM-25777 | Reviewing | Retire → behavior covered by TC2 (ServiceNow=true + Salesforce=false) |
| CRM-25772 | Active | Split → TC13–TC15: one test per CRM for digital (SF/SN/Dyn only) |
| CRM-25773 | Active | Split → TC16–TC18: one test per CRM pair for digital (SF/SN/Dyn only) |
| CRM-25888 | Active | Update → list Salesforce, ServiceNow, Dynamics explicitly; positions 4–10 are other test configs |
| CRM-25887 | Active | Update → list Salesforce, ServiceNow, Dynamics explicitly; positions 4–11 are other test configs |

---

## Section A: Voice — Config Isolation + Action per CRM (TC1–TC3)

*Merges old Sections A and C. Config: the target CRM has relatesTo=true; its companion has relatesTo=false. Each test verifies button presence/absence, then performs the action and confirms it succeeds — all in one pass.*

*Replaces: CRM-25762, CRM-25774, CRM-25777.*

---

**TC1** `[AGTINT][CXA][Multi-CRM][RelatesTo][Voice] Salesforce relatesTo=true + ServiceNow relatesTo=false → RelatesTo button present on Salesforce only; action succeeds; ServiceNow unaffected`

*(Merges CRM-25762 + CRM-25774)*

**Preconditions:**
- Multi-CRM feature toggle is ON
- **Salesforce** and **ServiceNow** configured, each with a Search and Create workflow
- Create workflow: **Salesforce** Pinned Record = true, relatesTo = **true**; **ServiceNow** Pinned Record = true, relatesTo = **false**
- Salesforce has a RelatesTo DM workflow configured; ServiceNow does not
- Agent logged into CX Agent

**Steps:**
1. Launch Agent and mark as Available
2. Receive an inbound voice contact
3. Both Salesforce and ServiceNow return search results and a pinned record in Current Interactions
4. Confirm the **Salesforce** pinned record card has a RelatesTo button
5. Confirm the **ServiceNow** pinned record card has **no** RelatesTo button
6. Click the RelatesTo button on the Salesforce pinned record
7. Select the entity to relate from the popover
8. Verify the Salesforce RelatesTo button changes state (e.g. turns green)
9. Go to Salesforce and verify the entities are now related
10. Go to ServiceNow and verify no unintended relationship was created

**Expected Result:** The RelatesTo button is present and functional on Salesforce; none appears on ServiceNow. The action completes successfully in Salesforce. ServiceNow records are entirely unaffected.

---

**TC2** `[AGTINT][CXA][Multi-CRM][RelatesTo][Voice] ServiceNow relatesTo=true + Salesforce relatesTo=false → RelatesTo button present on ServiceNow only; action succeeds; Salesforce unaffected`

*(Replaces CRM-25777)*

**Preconditions:**
- Multi-CRM feature toggle is ON
- **ServiceNow** and **Salesforce** configured, each with a Search and Create workflow
- Create workflow: **ServiceNow** Pinned Record = true, relatesTo = **true**; **Salesforce** Pinned Record = true, relatesTo = **false**
- ServiceNow has a RelatesTo DM workflow configured; Salesforce does not
- Agent logged into CX Agent

**Steps:**
1. Launch Agent and mark as Available
2. Receive an inbound voice contact
3. Both ServiceNow and Salesforce return search results and a pinned record in Current Interactions
4. Confirm the **ServiceNow** pinned record card has a RelatesTo button
5. Confirm the **Salesforce** pinned record card has **no** RelatesTo button
6. Click the RelatesTo button on the ServiceNow pinned record
7. Select the entity to relate from the popover
8. Verify the ServiceNow RelatesTo button changes state (e.g. turns green)
9. Go to ServiceNow and verify the entities are now related
10. Go to Salesforce and verify no unintended relationship was created

**Expected Result:** The RelatesTo button is present and functional on ServiceNow; none appears on Salesforce. The action completes successfully in ServiceNow. Salesforce records are entirely unaffected.

---

**TC3** `[AGTINT][CXA][Multi-CRM][RelatesTo][Voice] Dynamics relatesTo=true + Salesforce relatesTo=false → RelatesTo button present on Dynamics only; action succeeds; Salesforce unaffected`

*(New)*

**Preconditions:**
- Multi-CRM feature toggle is ON
- **Dynamics 365** and **Salesforce** configured, each with a Search and Create workflow
- Create workflow: **Dynamics** Pinned Record = true, relatesTo = **true** (Phone Call entity); **Salesforce** Pinned Record = true, relatesTo = **false**
- Dynamics has a RelatesTo DM workflow configured; Salesforce does not
- Agent logged into CX Agent

**Steps:**
1. Launch Agent and mark as Available
2. Receive an inbound voice contact
3. Both Dynamics and Salesforce return search results and a pinned record in Current Interactions
4. Confirm the **Dynamics** pinned record card has a RelatesTo button
5. Confirm the **Salesforce** pinned record card has **no** RelatesTo button
6. Click the RelatesTo button on the Dynamics pinned record
7. Select the entity to relate from the popover
8. Verify the Dynamics RelatesTo button changes state (e.g. turns green)
9. Go to Dynamics and verify the entities are now related
10. Go to Salesforce and verify no unintended relationship was created

**Expected Result:** The RelatesTo button is present and functional on Dynamics; none appears on Salesforce. The action completes successfully in Dynamics. Salesforce records are entirely unaffected.

---

## Section B: Voice — Both CRMs Independently + Popover Isolation (TC4–TC6)

*Merges old Sections B and F. Both CRMs have relatesTo=true. The popover observation (steps 4 and 6) validates entity isolation. Covers all three supported CRM pairs.*

*Replaces: CRM-25764, CRM-25767.*

---

**TC4** `[AGTINT][CXA][Multi-CRM][RelatesTo][Voice] Salesforce + ServiceNow → each CRM's popover shows only its own entities; RelatesTo succeeds in both independently`

*(Merges CRM-25764 + CRM-25767)*

**Preconditions:**
- Multi-CRM feature toggle is ON
- **Salesforce** and **ServiceNow** configured, each with a Search and Create workflow returning multiple Related Interactions
- Create workflow for both CRMs: Pinned Record = true, relatesTo = true
- Both CRMs have a RelatesTo DM workflow configured
- Agent logged into CX Agent

**Steps:**
1. Launch Agent and mark as Available
2. Receive an inbound voice contact
3. Both Salesforce and ServiceNow return search results and a pinned record in Current Interactions
4. Click the RelatesTo button on the **Salesforce** pinned record — confirm the popover lists only Salesforce entities (no ServiceNow records visible)
5. Select a Salesforce entity and confirm the button turns green
6. Click the RelatesTo button on the **ServiceNow** pinned record — confirm the popover lists only ServiceNow entities (no Salesforce records visible)
7. Select a ServiceNow entity and confirm the button turns green
8. Go to Salesforce and verify the relationship was created
9. Go to ServiceNow and verify the relationship was created

**Expected Result:** Each CRM's popover shows only its own entities. Both RelatesTo actions succeed independently without interference. Relationships are created in both CRMs.

---

**TC5** `[AGTINT][CXA][Multi-CRM][RelatesTo][Voice] ServiceNow + Dynamics → each CRM's popover shows only its own entities; RelatesTo succeeds in both independently`

*(New)*

**Preconditions:**
- Multi-CRM feature toggle is ON
- **ServiceNow** and **Dynamics 365** configured, each with a Search and Create workflow returning multiple Related Interactions
- Create workflow for both CRMs: Pinned Record = true, relatesTo = true
- Both CRMs have a RelatesTo DM workflow configured
- Agent logged into CX Agent

**Steps:**
1. Launch Agent and mark as Available
2. Receive an inbound voice contact
3. Both ServiceNow and Dynamics return search results and a pinned record in Current Interactions
4. Click the RelatesTo button on the **ServiceNow** pinned record — confirm the popover lists only ServiceNow entities (no Dynamics records visible)
5. Select a ServiceNow entity and confirm the button turns green
6. Click the RelatesTo button on the **Dynamics** pinned record — confirm the popover lists only Dynamics entities (no ServiceNow records visible)
7. Select a Dynamics entity and confirm the button turns green
8. Go to ServiceNow and verify the relationship was created
9. Go to Dynamics and verify the relationship was created

**Expected Result:** Each CRM's popover shows only its own entities. Both RelatesTo actions succeed independently without interference. Relationships are created in both CRMs.

---

**TC6** `[AGTINT][CXA][Multi-CRM][RelatesTo][Voice] Dynamics + Salesforce → each CRM's popover shows only its own entities; RelatesTo succeeds in both independently`

*(New)*

**Preconditions:**
- Multi-CRM feature toggle is ON
- **Dynamics 365** and **Salesforce** configured, each with a Search and Create workflow returning multiple Related Interactions
- Create workflow for both CRMs: Pinned Record = true, relatesTo = true
- Both CRMs have a RelatesTo DM workflow configured
- Agent logged into CX Agent

**Steps:**
1. Launch Agent and mark as Available
2. Receive an inbound voice contact
3. Both Dynamics and Salesforce return search results and a pinned record in Current Interactions
4. Click the RelatesTo button on the **Dynamics** pinned record — confirm the popover lists only Dynamics entities (no Salesforce records visible)
5. Select a Dynamics entity and confirm the button turns green
6. Click the RelatesTo button on the **Salesforce** pinned record — confirm the popover lists only Salesforce entities (no Dynamics records visible)
7. Select a Salesforce entity and confirm the button turns green
8. Go to Dynamics and verify the relationship was created
9. Go to Salesforce and verify the relationship was created

**Expected Result:** Each CRM's popover shows only its own entities. Both RelatesTo actions succeed independently without interference. Relationships are created in both CRMs.

---

## Section C: Voice — Both relatesTo=false (TC7)

*Updates CRM-25775 — names Salesforce + ServiceNow specifically.*

---

**TC7** `[AGTINT][CXA][Multi-CRM][RelatesTo][Voice] Salesforce relatesTo=false + ServiceNow relatesTo=false → no RelatesTo buttons appear on either CRM's pinned record`

*(Updates CRM-25775)*

**Preconditions:**
- Multi-CRM feature toggle is ON
- **Salesforce** and **ServiceNow** configured, each with a Search and Create workflow
- Create workflow for **both** CRMs: Pinned Record = true, relatesTo = **false**
- Agent logged into CX Agent

**Steps:**
1. Launch Agent and mark as Available
2. Receive an inbound voice contact
3. Both Salesforce and ServiceNow return search results and a pinned record in Current Interactions
4. Observe both the Salesforce and ServiceNow pinned record cards for the presence of any RelatesTo button

**Expected Result:** No RelatesTo button appears on either the Salesforce or ServiceNow pinned record card. Both cards render normally. No errors or unexpected console entries.

---

## Section D: Voice — Three CRMs Mixed Config (TC8–TC10)

*Updates CRM-25776. Each of the 3 supported CRMs appears once in the relatesTo=false position.*

---

**TC8** `[AGTINT][CXA][Multi-CRM][RelatesTo][Voice] Salesforce=true + ServiceNow=false + Dynamics=true → RelatesTo available in Salesforce and Dynamics; absent in ServiceNow`

*(Updates CRM-25776)*

**Preconditions:**
- Multi-CRM feature toggle is ON
- **Salesforce**, **ServiceNow**, and **Dynamics 365** configured, each with a Search and Create workflow
- Create workflow: **Salesforce** relatesTo = true; **ServiceNow** relatesTo = **false**; **Dynamics** relatesTo = true — all Pinned Record = true
- Salesforce and Dynamics have a RelatesTo DM workflow configured; ServiceNow does not
- Agent logged into CX Agent

**Steps:**
1. Launch Agent and mark as Available
2. Receive an inbound voice contact
3. All three CRMs return search results and a pinned record in Current Interactions
4. Confirm **Salesforce** and **Dynamics** pinned record cards each have a RelatesTo button; confirm **ServiceNow** has none
5. Click RelatesTo on the Salesforce pinned record, select an entity, and confirm the button turns green
6. Click RelatesTo on the Dynamics pinned record, select an entity, and confirm the button turns green
7. Verify relationships were created in Salesforce and Dynamics
8. Verify ServiceNow records are unaffected

**Expected Result:** RelatesTo buttons are present and functional on Salesforce and Dynamics. No RelatesTo button appears on ServiceNow. Both actions complete successfully and independently. ServiceNow records are unaffected.

---

**TC9** `[AGTINT][CXA][Multi-CRM][RelatesTo][Voice] ServiceNow=true + Salesforce=false + Dynamics=true → RelatesTo available in ServiceNow and Dynamics; absent in Salesforce`

*(New)*

**Preconditions:**
- Multi-CRM feature toggle is ON
- **ServiceNow**, **Salesforce**, and **Dynamics 365** configured, each with a Search and Create workflow
- Create workflow: **ServiceNow** relatesTo = true; **Salesforce** relatesTo = **false**; **Dynamics** relatesTo = true — all Pinned Record = true
- ServiceNow and Dynamics have a RelatesTo DM workflow configured; Salesforce does not
- Agent logged into CX Agent

**Steps:**
1. Launch Agent and mark as Available
2. Receive an inbound voice contact
3. All three CRMs return search results and a pinned record in Current Interactions
4. Confirm **ServiceNow** and **Dynamics** pinned record cards each have a RelatesTo button; confirm **Salesforce** has none
5. Click RelatesTo on the ServiceNow pinned record, select an entity, and confirm the button turns green
6. Click RelatesTo on the Dynamics pinned record, select an entity, and confirm the button turns green
7. Verify relationships were created in ServiceNow and Dynamics
8. Verify Salesforce records are unaffected

**Expected Result:** RelatesTo buttons are present and functional on ServiceNow and Dynamics. No RelatesTo button appears on Salesforce. Both actions complete successfully and independently. Salesforce records are unaffected.

---

**TC10** `[AGTINT][CXA][Multi-CRM][RelatesTo][Voice] Salesforce=true + ServiceNow=true + Dynamics=false → RelatesTo available in Salesforce and ServiceNow; absent in Dynamics`

*(New)*

**Preconditions:**
- Multi-CRM feature toggle is ON
- **Salesforce**, **ServiceNow**, and **Dynamics 365** configured, each with a Search and Create workflow
- Create workflow: **Salesforce** relatesTo = true; **ServiceNow** relatesTo = true; **Dynamics** relatesTo = **false** — all Pinned Record = true
- Salesforce and ServiceNow have a RelatesTo DM workflow configured; Dynamics does not
- Agent logged into CX Agent

**Steps:**
1. Launch Agent and mark as Available
2. Receive an inbound voice contact
3. All three CRMs return search results and a pinned record in Current Interactions
4. Confirm **Salesforce** and **ServiceNow** pinned record cards each have a RelatesTo button; confirm **Dynamics** has none
5. Click RelatesTo on the Salesforce pinned record, select an entity, and confirm the button turns green
6. Click RelatesTo on the ServiceNow pinned record, select an entity, and confirm the button turns green
7. Verify relationships were created in Salesforce and ServiceNow
8. Verify Dynamics records are unaffected

**Expected Result:** RelatesTo buttons are present and functional on Salesforce and ServiceNow. No RelatesTo button appears on Dynamics. Both actions complete successfully and independently. Dynamics records are unaffected.

---

## Section E: Voice — Three CRMs All relatesTo=true (TC11)

*No change to CRM-25765.*

---

**TC11** `[AGTINT][CXA][Multi-CRM][RelatesTo][Voice] Salesforce + ServiceNow + Dynamics → RelatesTo can be performed in all three CRMs on the same contact`

*(No change — CRM-25765)*

**Preconditions:**
- Multi-CRM feature toggle is ON
- **Salesforce**, **ServiceNow**, and **Dynamics 365** configured concurrently, each with Search and Create workflows
- Create workflow for all CRMs: Pinned Record = true, relatesTo = true (Dynamics: Phone Call entity)
- All three CRMs have a RelatesTo DM workflow configured
- Agent logged into CX Agent

**Steps:**
1. Launch Agent and mark as Available
2. Receive an inbound voice contact
3. All three CRMs return search results and a pinned record in Current Interactions
4. Click RelatesTo on the **Salesforce** pinned record, select an entity, and confirm the button turns green
5. Click RelatesTo on the **ServiceNow** pinned record, select an entity, and confirm the button turns green
6. Click RelatesTo on the **Dynamics** pinned record, select an entity, and confirm the button turns green
7. Verify in each CRM that the respective relationship was created

**Expected Result:** All three CRMs independently show the new relationship. No CRM is skipped or errored.

---

## Section F: Voice — Loading State Scoped (TC12)

*Updates CRM-25768 — replaces CRM-A/CRM-B with Salesforce + ServiceNow.*

---

**TC12** `[AGTINT][CXA][Multi-CRM][RelatesTo][Voice] Salesforce + ServiceNow → loading state is scoped to the Salesforce button only when Salesforce RelatesTo is clicked`

*(Updates CRM-25768)*

**Preconditions:**
- Multi-CRM feature toggle is ON
- **Salesforce** and **ServiceNow** configured concurrently, each with a pinned RelatesTo-enabled record
- Agent logged into CX Agent

**Steps:**
1. Launch Agent and mark as Available
2. Receive an inbound voice contact; both Salesforce and ServiceNow produce a pinned record
3. Click the RelatesTo button on the **Salesforce** pinned record
4. Immediately observe both the Salesforce RelatesTo button and the ServiceNow RelatesTo button

**Expected Result:** A loading indicator appears on the Salesforce RelatesTo button only. The ServiceNow RelatesTo button remains in its normal idle state.

---

## Section G: Digital — RelatesTo per CRM (TC13–TC15)

*Updates CRM-25772 (Salesforce-only) and adds TC14–TC15 to cover ServiceNow and Dynamics.*

---

**TC13** `[AGTINT][CXA][Multi-CRM][RelatesTo][Digital] Salesforce + ServiceNow → RelatesTo on Salesforce pinned record succeeds on a digital contact; ServiceNow unaffected`

*(Updates CRM-25772)*

**Preconditions:**
- Multi-CRM feature toggle is ON
- **Salesforce** and **ServiceNow** configured for Digital, each with a Search and Create workflow
- Create workflow for both CRMs: Pinned Record = true, relatesTo = true
- Both CRMs have a RelatesTo DM workflow configured
- Digital chat is set up

**Steps:**
1. Launch Agent and mark as Available
2. Set up a digital chat and connect to a contact
3. Both Salesforce and ServiceNow return search results and a pinned record in Current Interactions
4. Click the RelatesTo button on the **Salesforce** pinned record
5. Select the entity to relate from the popover
6. Verify the Salesforce RelatesTo button changes state (e.g. turns green)
7. Go to Salesforce and verify the entities are now related
8. Go to ServiceNow and verify no unintended relationship was created

**Expected Result:** The selected entities are related in Salesforce. ServiceNow records are entirely unaffected.

---

**TC14** `[AGTINT][CXA][Multi-CRM][RelatesTo][Digital] ServiceNow + Salesforce → RelatesTo on ServiceNow pinned record succeeds on a digital contact; Salesforce unaffected`

*(New)*

**Preconditions:**
- Multi-CRM feature toggle is ON
- **ServiceNow** and **Salesforce** configured for Digital, each with a Search and Create workflow
- Create workflow for both CRMs: Pinned Record = true, relatesTo = true
- Both CRMs have a RelatesTo DM workflow configured
- Digital chat is set up

**Steps:**
1. Launch Agent and mark as Available
2. Set up a digital chat and connect to a contact
3. Both ServiceNow and Salesforce return search results and a pinned record in Current Interactions
4. Click the RelatesTo button on the **ServiceNow** pinned record
5. Select the entity to relate from the popover
6. Verify the ServiceNow RelatesTo button changes state (e.g. turns green)
7. Go to ServiceNow and verify the entities are now related
8. Go to Salesforce and verify no unintended relationship was created

**Expected Result:** The selected entities are related in ServiceNow. Salesforce records are entirely unaffected.

---

**TC15** `[AGTINT][CXA][Multi-CRM][RelatesTo][Digital] Dynamics + Salesforce → RelatesTo on Dynamics pinned record succeeds on a digital contact; Salesforce unaffected`

*(New)*

**Preconditions:**
- Multi-CRM feature toggle is ON
- **Dynamics 365** and **Salesforce** configured for Digital, each with a Search and Create workflow
- Create workflow for both CRMs: Pinned Record = true, relatesTo = true (Dynamics: Phone Call entity)
- Both CRMs have a RelatesTo DM workflow configured
- Digital chat is set up

**Steps:**
1. Launch Agent and mark as Available
2. Set up a digital chat and connect to a contact
3. Both Dynamics and Salesforce return search results and a pinned record in Current Interactions
4. Click the RelatesTo button on the **Dynamics** pinned record
5. Select the entity to relate from the popover
6. Verify the Dynamics RelatesTo button changes state (e.g. turns green)
7. Go to Dynamics and verify the entities are now related
8. Go to Salesforce and verify no unintended relationship was created

**Expected Result:** The selected entities are related in Dynamics. Salesforce records are entirely unaffected.

---

## Section H: Digital — Both CRMs Independently (TC16–TC18)

*Updates CRM-25773 and expands to cover all three supported CRM pairs.*

---

**TC16** `[AGTINT][CXA][Multi-CRM][RelatesTo][Digital] Salesforce + ServiceNow → RelatesTo can be performed in both CRMs independently on the same digital contact`

*(Updates CRM-25773)*

**Preconditions:**
- Multi-CRM feature toggle is ON
- **Salesforce** and **ServiceNow** configured concurrently for Digital, each with Search and Create workflows
- Create workflow for both CRMs: Pinned Record = true, relatesTo = true
- Both CRMs have a RelatesTo DM workflow configured
- Digital chat is set up

**Steps:**
1. Launch Agent and mark as Available
2. Set up a digital chat and connect to a contact
3. Both Salesforce and ServiceNow return search results and a pinned record in Current Interactions
4. Click RelatesTo on the **Salesforce** pinned record, select an entity, and confirm the button turns green
5. Click RelatesTo on the **ServiceNow** pinned record, select an entity, and confirm the button turns green
6. Go to Salesforce and verify the relationship was created
7. Go to ServiceNow and verify the relationship was created

**Expected Result:** Both Salesforce and ServiceNow independently show the new relationship. Each action succeeds without interfering with the other.

---

**TC17** `[AGTINT][CXA][Multi-CRM][RelatesTo][Digital] ServiceNow + Dynamics → RelatesTo can be performed in both CRMs independently on the same digital contact`

*(New)*

**Preconditions:**
- Multi-CRM feature toggle is ON
- **ServiceNow** and **Dynamics 365** configured concurrently for Digital, each with Search and Create workflows
- Create workflow for both CRMs: Pinned Record = true, relatesTo = true
- Both CRMs have a RelatesTo DM workflow configured
- Digital chat is set up

**Steps:**
1. Launch Agent and mark as Available
2. Set up a digital chat and connect to a contact
3. Both ServiceNow and Dynamics return search results and a pinned record in Current Interactions
4. Click RelatesTo on the **ServiceNow** pinned record, select an entity, and confirm the button turns green
5. Click RelatesTo on the **Dynamics** pinned record, select an entity, and confirm the button turns green
6. Go to ServiceNow and verify the relationship was created
7. Go to Dynamics and verify the relationship was created

**Expected Result:** Both ServiceNow and Dynamics independently show the new relationship. Each action succeeds without interfering with the other.

---

**TC18** `[AGTINT][CXA][Multi-CRM][RelatesTo][Digital] Dynamics + Salesforce → RelatesTo can be performed in both CRMs independently on the same digital contact`

*(New)*

**Preconditions:**
- Multi-CRM feature toggle is ON
- **Dynamics 365** and **Salesforce** configured concurrently for Digital, each with Search and Create workflows
- Create workflow for both CRMs: Pinned Record = true, relatesTo = true
- Both CRMs have a RelatesTo DM workflow configured
- Digital chat is set up

**Steps:**
1. Launch Agent and mark as Available
2. Set up a digital chat and connect to a contact
3. Both Dynamics and Salesforce return search results and a pinned record in Current Interactions
4. Click RelatesTo on the **Dynamics** pinned record, select an entity, and confirm the button turns green
5. Click RelatesTo on the **Salesforce** pinned record, select an entity, and confirm the button turns green
6. Go to Dynamics and verify the relationship was created
7. Go to Salesforce and verify the relationship was created

**Expected Result:** Both Dynamics and Salesforce independently show the new relationship. Each action succeeds without interfering with the other.

---

## Section I: Boundary — Max CRM Tests (TC19–TC20)

*Updates CRM-25888 and CRM-25887 — Salesforce, ServiceNow, and Dynamics fill the first three positions; remaining positions use generic test CRM configurations.*

---

**TC19** `[AGTINT][CXA][Multi-CRM][RelatesTo][Voice] Ten CRMs configured → RelatesTo can be performed across all ten CRMs on the same contact`

*(Updates CRM-25888)*

**Preconditions:**
- Multi-CRM feature toggle is ON
- **Ten CRMs configured**: Salesforce (pos 1), ServiceNow (pos 2), Dynamics 365 (pos 3), plus seven additional test CRM configurations (pos 4–10)
- Each CRM has a Search and Create workflow; Create workflow for all: Pinned Record = true, relatesTo = true
- All ten CRMs have a RelatesTo DM workflow configured
- Agent logged into CX Agent

**Steps:**
1. Log in to CX Agent with all 10 CRMs configured
2. Receive an inbound voice contact
3. All 10 CRMs return search results and a pinned record in Current Interactions
4. Click RelatesTo on each CRM's pinned record (Salesforce → ServiceNow → Dynamics → pos 4 → … → pos 10), select an entity, and confirm the button turns green for each
5. Verify in each CRM that the respective relationship was created

**Expected Result:** All 10 CRMs independently show the new relationship. No CRM is skipped or errors. Agent remains stable throughout.

---

**TC20** `[AGTINT][CXA][Multi-CRM][RelatesTo][Voice] Eleven CRMs injected → RelatesTo available for first 10 CRMs; 11th is silently ignored`

*(Updates CRM-25887)*

**Preconditions:**
- Multi-CRM feature toggle is ON
- **Eleven CRM configurations injected**: Salesforce (pos 1), ServiceNow (pos 2), Dynamics 365 (pos 3), plus eight additional test CRM configurations (pos 4–11) — exceeds the 10-CRM limit
- All eleven have Pinned Record = true, relatesTo = true
- Agent logged into CX Agent

**Steps:**
1. Inject all 11 CRM configurations into the agent session
2. Receive an inbound voice contact
3. Observe how many CRM panels display a RelatesTo-enabled pinned record
4. Attempt RelatesTo on each visible CRM's pinned record

**Expected Result:** Only the first 10 CRMs (positions 1–10) display a RelatesTo-enabled pinned record. The 11th CRM configuration is silently ignored — no pinned record card, no RelatesTo button, no crash. Agent remains stable and functional.

---

## Coverage Matrix

| CRM | Section A (config isolation + action) | Section B (both independently + popover) | Section D (three-CRM mixed) | Digital G | Digital H |
|---|:---:|:---:|:---:|:---:|:---:|
| Salesforce | TC1 | TC4, TC6 | TC8, TC9, TC10 | TC13 | TC16, TC18 |
| ServiceNow | TC2 | TC4, TC5 | TC8, TC9, TC10 | TC14 | TC16, TC17 |
| Dynamics | TC3 | TC5, TC6 | TC8, TC9, TC10 | TC15 | TC17, TC18 |
