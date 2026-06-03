## Position-Based Pop Order (6 TCs)

---

**TC1** `[AGTINT][CXA][Multi-CRM][ScreenPop][Voice] Two CRMs configured → all records pop in correct positional order, preserved across consecutive contacts`

**Preconditions:**
- Multi-CRM feature toggle is ON
- Two CRMs configured, each with a distinct position (1 and 2)
- Both CRMs have Search Workflow with Screen Pop = True
- Contact is set up to produce a single match in each configured CRM
- Agent logged into CX Agent

**Steps:**
1. Log in to CX Agent with two CRMs configured at positions 1 and 2
2. Receive a first inbound voice contact
3. Both search workflows return a single match each
4. Observe the order of screen pop events fired (capture sequence)
5. End the contact
6. Receive a second inbound voice contact
7. Observe the screen pop order again

**Expected Result:** For both contacts, the position 1 CRM screen pop fires before the position 2 CRM screen pop. Order is identical across both contacts — no reversal or state bleed between calls. Both pops are delivered; neither is dropped.

---

**TC2** `[AGTINT][CXA][Multi-CRM][ScreenPop][Voice] Three CRMs configured → all records pop in correct positional order with no CRM skipped`

**Preconditions:**
- Multi-CRM feature toggle is ON
- Three CRMs configured at positions 1, 2, and 3
- All three have Search Workflow with Screen Pop = True
- Contact is set up to produce a single match in each of the three configured CRMs
- Agent logged into CX Agent

**Steps:**
1. Log in to CX Agent with three CRMs at positions 1, 2, and 3
2. Receive an inbound voice contact
3. All three search workflows return a single match each
4. Capture the order and count of ScreenPopEvents fired

**Expected Result:** Exactly 3 ScreenPopEvents fire in positional order: position 1 → position 2 → position 3. No CRM is skipped or silently dropped. No crash or unhandled errors.

---

## Embedded vs. Standalone Routing (15 TCs)

---

**TC3** `[AGTINT][CXA][Multi-CRM][ScreenPop][Voice] Agent in Salesforce → Salesforce records open in embedded panel; other CRM records open in new tabs`

**Preconditions:**
- Multi-CRM feature toggle is ON
- Agent running CX Agent embedded inside Salesforce
- Salesforce CRM and at least one additional non-Salesforce CRM configured, each with Search and Create Workflow and Screen Pop = True
- Contact is set up to produce a single match in each configured CRM

**Steps:**
1. Log in to CX Agent embedded in Salesforce with multiple CRMs configured
2. Receive an inbound voice contact
3. All CRM search and create workflows execute and return results
4. Screen pops fire for all CRMs
5. Observe where each CRM's records open — both Salesforce and non-Salesforce

**Expected Result:** Salesforce records (search match and created record) open inside the Salesforce embedded panel. All non-Salesforce CRM records open in new browser tabs. No errors.

---

**TC4** `[AGTINT][CXA][Multi-CRM][ScreenPop][Voice] Agent in ServiceNow → ServiceNow records open in embedded panel; other CRM records open in new tabs`

**Preconditions:**
- Multi-CRM feature toggle is ON
- Agent running CX Agent embedded inside ServiceNow
- ServiceNow CRM and at least one additional non-ServiceNow CRM configured, each with Search and Create Workflow and Screen Pop = True
- Contact is set up to produce a single match in each configured CRM

**Steps:**
1. Log in to CX Agent embedded in ServiceNow with multiple CRMs configured
2. Receive an inbound voice contact
3. All CRM search and create workflows execute and return results
4. Screen pops fire for all CRMs
5. Observe where each CRM's records open — both ServiceNow and non-ServiceNow

**Expected Result:** ServiceNow records (search match and created record) open inside the ServiceNow embedded panel. All non-ServiceNow CRM records open in new browser tabs. No errors.

---

**TC5** `[AGTINT][CXA][Multi-CRM][ScreenPop][Voice] Agent in Dynamics → Dynamics records open in embedded panel; other CRM records open in new tabs`

**Preconditions:**
- Multi-CRM feature toggle is ON
- Agent running CX Agent embedded inside Dynamics 365
- Dynamics CRM and at least one additional non-Dynamics CRM configured, each with Search and Create Workflow and Screen Pop = True
- Contact is set up to produce a single match in each configured CRM

**Steps:**
1. Log in to CX Agent embedded in Dynamics with multiple CRMs configured
2. Receive an inbound voice contact
3. All CRM search and create workflows execute and return results
4. Screen pops fire for all CRMs
5. Observe where each CRM's records open — both Dynamics and non-Dynamics

**Expected Result:** Dynamics records (search match and created record) open inside the Dynamics embedded panel. All non-Dynamics CRM records open in new browser tabs. No errors.

---

**TC6** `[AGTINT][CXA][Multi-CRM][ScreenPop][Voice] Agent in Kustomer → Kustomer records open in embedded panel; other CRM records open in new tabs`

**Preconditions:**
- Multi-CRM feature toggle is ON
- Agent running CX Agent embedded inside Kustomer
- Kustomer CRM and at least one additional non-Kustomer CRM configured, each with Search and Create Workflow and Screen Pop = True
- Contact is set up to produce a single match in each configured CRM

**Steps:**
1. Log in to CX Agent embedded in Kustomer with multiple CRMs configured
2. Receive an inbound voice contact
3. All CRM search and create workflows execute and return results
4. Screen pops fire for all CRMs
5. Observe where each CRM's records open — both Kustomer and non-Kustomer

**Expected Result:** Kustomer records (search match and created record) open inside the Kustomer embedded panel. All non-Kustomer CRM records open in new browser tabs. No errors.

---

**TC7** `[AGTINT][CXA][Multi-CRM][ScreenPop][Voice] Agent in Oracle → Oracle records open in embedded panel; other CRM records open in new tabs`

**Preconditions:**
- Multi-CRM feature toggle is ON
- Agent running CX Agent embedded inside Oracle
- Oracle CRM and at least one additional non-Oracle CRM configured, each with Search and Create Workflow and Screen Pop = True
- Contact is set up to produce a single match in each configured CRM

**Steps:**
1. Log in to CX Agent embedded in Oracle with multiple CRMs configured
2. Receive an inbound voice contact
3. All CRM search and create workflows execute and return results
4. Screen pops fire for all CRMs
5. Observe where each CRM's records open — both Oracle and non-Oracle

**Expected Result:** Oracle records (search match and created record) open inside the Oracle embedded panel. All non-Oracle CRM records open in new browser tabs. No errors.

---

**TC8** `[AGTINT][CXA][Multi-CRM][ScreenPop][Voice] Agent in Zendesk → Zendesk records open in embedded panel; other CRM records open in new tabs`

**Preconditions:**
- Multi-CRM feature toggle is ON
- Agent running CX Agent embedded inside Zendesk
- Zendesk CRM and at least one additional non-Zendesk CRM configured, each with Search and Create Workflow and Screen Pop = True
- Contact is set up to produce a single match in each configured CRM

**Steps:**
1. Log in to CX Agent embedded in Zendesk with multiple CRMs configured
2. Receive an inbound voice contact
3. All CRM search and create workflows execute and return results
4. Screen pops fire for all CRMs
5. Observe where each CRM's records open — both Zendesk and non-Zendesk

**Expected Result:** Zendesk records (search match and created record) open inside the Zendesk embedded panel. All non-Zendesk CRM records open in new browser tabs. No errors.

---

**TC9** `[AGTINT][CXA][Multi-CRM][ScreenPop][Digital] Agent in Salesforce → Salesforce records open in embedded panel; other CRM records open in new tabs`

**Preconditions:**
- Multi-CRM feature toggle is ON
- Agent running CX Agent embedded inside Salesforce
- Salesforce CRM and at least one additional non-Salesforce CRM configured, each with Search and Create Workflow and Screen Pop = True
- Contact is set up to produce a single match in each configured CRM

**Steps:**
1. Log in to CX Agent embedded in Salesforce with multiple CRMs configured
2. Receive an inbound digital contact
3. All CRM search and create workflows execute and return results
4. Screen pops fire for all CRMs
5. Observe where each CRM's records open — both Salesforce and non-Salesforce

**Expected Result:** Salesforce records (search match and created record) open inside the Salesforce embedded panel. All non-Salesforce CRM records open in new browser tabs. No errors.

---

**TC10** `[AGTINT][CXA][Multi-CRM][ScreenPop][Digital] Agent in ServiceNow → ServiceNow records open in embedded panel; other CRM records open in new tabs`

**Preconditions:**
- Multi-CRM feature toggle is ON
- Agent running CX Agent embedded inside ServiceNow
- ServiceNow CRM and at least one additional non-ServiceNow CRM configured, each with Search and Create Workflow and Screen Pop = True
- Contact is set up to produce a single match in each configured CRM

**Steps:**
1. Log in to CX Agent embedded in ServiceNow with multiple CRMs configured
2. Receive an inbound digital contact
3. All CRM search and create workflows execute and return results
4. Screen pops fire for all CRMs
5. Observe where each CRM's records open — both ServiceNow and non-ServiceNow

**Expected Result:** ServiceNow records (search match and created record) open inside the ServiceNow embedded panel. All non-ServiceNow CRM records open in new browser tabs. No errors.

---

**TC11** `[AGTINT][CXA][Multi-CRM][ScreenPop][Digital] Agent in Dynamics → Dynamics records open in embedded panel; other CRM records open in new tabs`

**Preconditions:**
- Multi-CRM feature toggle is ON
- Agent running CX Agent embedded inside Dynamics 365
- Dynamics CRM and at least one additional non-Dynamics CRM configured, each with Search and Create Workflow and Screen Pop = True
- Contact is set up to produce a single match in each configured CRM

**Steps:**
1. Log in to CX Agent embedded in Dynamics with multiple CRMs configured
2. Receive an inbound digital contact
3. All CRM search and create workflows execute and return results
4. Screen pops fire for all CRMs
5. Observe where each CRM's records open — both Dynamics and non-Dynamics

**Expected Result:** Dynamics records (search match and created record) open inside the Dynamics embedded panel. All non-Dynamics CRM records open in new browser tabs. No errors.

---

**TC12** `[AGTINT][CXA][Multi-CRM][ScreenPop][Digital] Agent in Kustomer → Kustomer records open in embedded panel; other CRM records open in new tabs`

**Preconditions:**
- Multi-CRM feature toggle is ON
- Agent running CX Agent embedded inside Kustomer
- Kustomer CRM and at least one additional non-Kustomer CRM configured, each with Search and Create Workflow and Screen Pop = True
- Contact is set up to produce a single match in each configured CRM

**Steps:**
1. Log in to CX Agent embedded in Kustomer with multiple CRMs configured
2. Receive an inbound digital contact
3. All CRM search and create workflows execute and return results
4. Screen pops fire for all CRMs
5. Observe where each CRM's records open — both Kustomer and non-Kustomer

**Expected Result:** Kustomer records (search match and created record) open inside the Kustomer embedded panel. All non-Kustomer CRM records open in new browser tabs. No errors.

---

**TC13** `[AGTINT][CXA][Multi-CRM][ScreenPop][Digital] Agent in Oracle → Oracle records open in embedded panel; other CRM records open in new tabs`

**Preconditions:**
- Multi-CRM feature toggle is ON
- Agent running CX Agent embedded inside Oracle
- Oracle CRM and at least one additional non-Oracle CRM configured, each with Search and Create Workflow and Screen Pop = True
- Contact is set up to produce a single match in each configured CRM

**Steps:**
1. Log in to CX Agent embedded in Oracle with multiple CRMs configured
2. Receive an inbound digital contact
3. All CRM search and create workflows execute and return results
4. Screen pops fire for all CRMs
5. Observe where each CRM's records open — both Oracle and non-Oracle

**Expected Result:** Oracle records (search match and created record) open inside the Oracle embedded panel. All non-Oracle CRM records open in new browser tabs. No errors.

---

**TC14** `[AGTINT][CXA][Multi-CRM][ScreenPop][Digital] Agent in Zendesk → Zendesk records open in embedded panel; other CRM records open in new tabs`

**Preconditions:**
- Multi-CRM feature toggle is ON
- Agent running CX Agent embedded inside Zendesk
- Zendesk CRM and at least one additional non-Zendesk CRM configured, each with Search and Create Workflow and Screen Pop = True
- Contact is set up to produce a single match in each configured CRM

**Steps:**
1. Log in to CX Agent embedded in Zendesk with multiple CRMs configured
2. Receive an inbound digital contact
3. All CRM search and create workflows execute and return results
4. Screen pops fire for all CRMs
5. Observe where each CRM's records open — both Zendesk and non-Zendesk

**Expected Result:** Zendesk records (search match and created record) open inside the Zendesk embedded panel. All non-Zendesk CRM records open in new browser tabs. No errors.

---

**TC15** `[AGTINT][CXA][Multi-CRM][ScreenPop][Voice] Agent in standalone browser → two CRMs configured; both records pop in correct order`

> **Automation Note:** This test must be automated in both **CMA** and **CIA**. Do not create a duplicate test case — a single test case should cover both contexts.

**Preconditions:**
- Multi-CRM feature toggle is ON
- Agent running CX Agent in standalone browser
- Two CRMs configured at positions 1 and 2, both with Search Workflow + Screen Pop = True
- Contact is set up to produce a single match in each configured CRM

**Steps:**
1. Log in to CX Agent in standalone browser mode
2. Receive a voice contact
3. Both CRM workflows return a single match each and fire screen pops
4. Observe the order and behavior of both pops

**Expected Result:** Both CRM records open as screen pops in positional order (position 1 first, position 2 second). No embedded panel attempted. No records dropped.

---

**TC16** `[AGTINT][CXA][Multi-CRM][ScreenPop][Voice] Agent in standalone browser → three CRMs configured; all records pop in correct order`

> **Automation Note:** This test must be automated in both **CMA** and **CIA**. Do not create a duplicate test case — a single test case should cover both contexts.

**Preconditions:**
- Multi-CRM feature toggle is ON
- Agent in standalone browser
- Three CRMs configured at positions 1, 2, and 3, all with Search Workflow + Screen Pop = True
- Contact is set up to produce a single match in each of the three configured CRMs

**Steps:**
1. Log in to CX Agent in standalone browser mode
2. Receive a voice contact
3. All three CRM workflows return a single match each
4. Observe the order and count of screen pops

**Expected Result:** All three CRM records open as screen pops in positional order (1 → 2 → 3). No embedded panel attempted. No records dropped or out of order.


---

**TC17** `[AGTINT][CXA][Multi-CRM][ScreenPop][Voice] Create workflow fires for one CRM while a single-match search fires for another → both records pop correctly`

**Preconditions:**
- Multi-CRM feature toggle is ON
- Two CRMs configured — CRM A has a Create Workflow with Screen Pop = True, CRM B has a Search Workflow with Screen Pop = True
- Screen pops fire for single-match search results and newly created records (pinned or unpinned)
- Contact is set up so that CRM A produces a newly created record and CRM B returns a single search match
- Agent logged into CX Agent

**Steps:**
1. Log in to CX Agent with both CRMs configured
2. Receive an inbound voice contact
3. CRM A create workflow executes and creates a new record
4. CRM B search workflow executes and returns a single match
5. Observe both screen pop events — which records open, routing, and order

**Expected Result:** Both screen pops fire — the newly created CRM A record and the single-match CRM B record. Each routes correctly to its CRM (embedded panel if the agent is in that CRM's environment, new tab otherwise). Positional order is respected. No errors or dropped events.

---

## Screen Pop Disabled (2 TCs)

---

**TC18** `[AGTINT][CXA][Multi-CRM][ScreenPop][Voice] Two CRMs — one with Screen Pop = True, one with Screen Pop = False → only the enabled CRM pops`

**Preconditions:**
- Multi-CRM feature toggle is ON
- Two CRMs configured at positions 1 and 2
- CRM at position 1: Search Workflow with Screen Pop = **True**
- CRM at position 2: Search Workflow with Screen Pop = **False**
- Contact is set up to produce a single match in each configured CRM
- Agent logged into CX Agent

**Steps:**
1. Log in to CX Agent with two CRMs configured as described
2. Receive an inbound voice contact
3. Both search workflows execute and each returns a single match
4. Observe which screen pop events fire

**Expected Result:** Exactly one screen pop fires — the position 1 CRM (Screen Pop = True). The position 2 CRM (Screen Pop = False) does NOT produce a screen pop. No errors, no unexpected events for the disabled CRM.

---

**TC19** `[AGTINT][CXA][Multi-CRM][ScreenPop][Voice] All configured CRMs have Screen Pop = False → no screen pops fire`

**Preconditions:**
- Multi-CRM feature toggle is ON
- Two or more CRMs configured, **all** with Search Workflow and Screen Pop = **False**
- Contact is set up to produce a single match in each configured CRM
- Agent logged into CX Agent

**Steps:**
1. Log in to CX Agent with all CRMs having Screen Pop = False
2. Receive an inbound voice contact
3. All search workflows execute and each returns a single match
4. Observe whether any screen pop events fire

**Expected Result:** Zero screen pop events fire. No CRM records are opened. Agent handles the contact normally without any pop behavior. No errors in the browser console.

---

**TC20** `[AGTINT][CXA][Multi-CRM][ScreenPop][Voice] Ten CRMs — one with Screen Pop = True, rest with Screen Pop = False → only the enabled CRM pops`

**Preconditions:**
- Multi-CRM feature toggle is ON
- Ten CRMs configured at positions 1-10 (all must be different CRM types)
- CRM at position 1: Search Workflow with Screen Pop = **False**
- CRM at position 2: Search Workflow with Screen Pop = **True**
- CRMs at positions 3-10: Search Workflow with Screen Pop = **False**
- Contact is set up to produce a single match in each configured CRM
- Agent logged into CX Agent

**Steps:**
1. Log in to CX Agent with ten CRMs configured as described
2. Receive an inbound voice contact
3. All search workflows execute and return a single match
4. Observe which screen pop events fire

**Expected Result:** Exactly one screen pop fires — the position 2 CRM (Screen Pop = True). The position 1 CRM and positions 3-10 CRMs (Screen Pop = False) do NOT produce a screen pop. No errors, no unexpected events for the disabled CRM.

---

**TC21** `[AGTINT][CXA][Multi-CRM][ScreenPop][Digital] Ten CRMs — one with Screen Pop = True, rest with Screen Pop = False → only the enabled CRM pops`

**Preconditions:**
- Multi-CRM feature toggle is ON
- Ten CRMs configured at positions 1-10 (all be different CRM types, not all Dynamics or Salesforce)
- CRM at position 1: Search Workflow with Screen Pop = **False**
- CRM at position 2: Search Workflow with Screen Pop = **True**
- CRMs at positions 3-10: Search Workflow with Screen Pop = **False**
- Contact is set up to produce a single match in each configured CRM
- Agent logged into CX Agent

**Steps:**
1. Log in to CX Agent with ten CRMs configured as described
2. Receive a digital contact
3. All search workflows execute and return a single match
4. Observe which screen pop events fire

**Expected Result:** Exactly one screen pop fires — the position 2 CRM (Screen Pop = True). The position 1 CRM and positions 3-10 CRMs (Screen Pop = False) do NOT produce a screen pop. No errors, no unexpected events for the disabled CRM.

---

**TC22** `[AGTINT][CXA][Multi-CRM][ScreenPop][Voice] Eleven CRM workflow configs injected via payload manipulation → only the first 10 screen pop; 11th is silently ignored`

**Preconditions:**
- Multi-CRM feature toggle is ON
- The Agent Workflow Configuration editor enforces a maximum of 10 configured workflows — it is not possible to add an 11th through the UI
- An 11th workflow entry is injected by directly manipulating the configuration payload (bypassing the UI limit)
- All 11 workflow configs have Screen Pop = **True** and a Search Workflow that will return a single match
- Agent logged into CX Agent

**Steps:**
1. Using the Agent Workflow Configuration editor, set up 10 CRM workflow configurations (variety of CRM types), each with Screen Pop = True
2. Manually manipulate the configuration payload to inject an 11th CRM workflow entry, also with Screen Pop = True
3. Log in to CX Agent with the modified configuration loaded
4. Receive an inbound voice contact
5. All 11 search workflows execute and each returns a single match
6. Observe how many screen pop events fire and which CRM configs they correspond to

**Expected Result:** Exactly 10 screen pop events fire — corresponding to the first 10 configured workflows. The 11th workflow entry injected via payload manipulation does NOT produce a screen pop and is silently ignored by the system. No crash, no unhandled error. Agent remains fully functional.

---

## Manual Screen Pop (Click to Open Record) (4 TCs)

---

**TC23** `[AGTINT][CXA][Multi-CRM][ScreenPop][Voice] Agent in embedded CRM → clicking screen pop button on a record opens the record inside the embedded panel`

**Preconditions:**
- Multi-CRM feature toggle is ON
- Agent running CX Agent embedded inside a supported CRM (e.g. Salesforce, ServiceNow, or Dynamics)
- The Current Interactions panel contains records from both the embedded CRM and at least one other CRM, each with a manual screen pop button
- Agent is handling an active voice contact

**Steps:**
1. Log in to CX Agent embedded in a supported CRM
2. Receive an inbound voice contact
3. CRM records are surfaced in the Current Interactions panel (search or create results) for both the embedded CRM and other configured CRMs
4. Locate the screen pop button on the embedded CRM's record and click it
5. Observe where the embedded CRM record opens
6. Locate the screen pop button on a record belonging to a different CRM and click it
7. Observe where that record opens

**Expected Result:** The embedded CRM's record opens inside the embedded panel. Any record belonging to a different CRM opens in a new browser tab. No errors.

---

**TC24** `[AGTINT][CXA][Multi-CRM][ScreenPop][Digital] Agent in embedded CRM → clicking screen pop button on a record opens the record inside the embedded panel`

**Preconditions:**
- Multi-CRM feature toggle is ON
- Agent running CX Agent embedded inside a supported CRM (e.g. Salesforce, ServiceNow, or Dynamics)
- The Current Interactions panel contains records from both the embedded CRM and at least one other CRM, each with a manual screen pop button
- Agent is handling an active digital contact

**Steps:**
1. Log in to CX Agent embedded in a supported CRM
2. Receive an inbound digital contact
3. CRM records are surfaced in the Current Interactions panel (search or create results) for both the embedded CRM and other configured CRMs
4. Locate the screen pop button on the embedded CRM's record and click it
5. Observe where the embedded CRM record opens
6. Locate the screen pop button on a record belonging to a different CRM and click it
7. Observe where that record opens

**Expected Result:** The embedded CRM's record opens inside the embedded panel. Any record belonging to a different CRM opens in a new browser tab. No errors.

---

**TC25** `[AGTINT][CXA][Multi-CRM][ScreenPop][Voice] Agent in standalone browser → clicking screen pop button on a record opens the record in a new tab`

> **Automation Note:** This test must be automated in both **CMA** and **CIA**. Do not create a duplicate test case — a single test case should cover both contexts.

**Preconditions:**
- Multi-CRM feature toggle is ON
- Agent running CX Agent in a standalone browser (not embedded in any CRM)
- A CRM record is displayed in the Current Interactions panel with a manual screen pop button
- Agent is handling an active voice contact

**Steps:**
1. Log in to CX Agent in standalone browser mode
2. Receive an inbound voice contact
3. A CRM record is surfaced in the Current Interactions panel (search or create result)
4. Locate the button on the record
5. Click the button
6. Observe where the record opens

**Expected Result:** The record opens in a new browser tab. No embedded panel routing is attempted. The action completes without errors.

---

**TC26** `[AGTINT][CXA][Multi-CRM][ScreenPop][Digital] Agent in standalone browser → clicking screen pop button on a record opens the record in a new tab`

> **Automation Note:** This test must be automated in both **CMA** and **CIA**. Do not create a duplicate test case — a single test case should cover both contexts.

**Preconditions:**
- Multi-CRM feature toggle is ON
- Agent running CX Agent in a standalone browser (not embedded in any CRM)
- A CRM record is displayed in the Current Interactions panel with a manual screen pop button
- Agent is handling an active digital contact

**Steps:**
1. Log in to CX Agent in standalone browser mode
2. Receive an inbound digital contact
3. A CRM record is surfaced in the Current Interactions panel (search or create result)
4. Locate the button on the record
5. Click the button
6. Observe where the record opens

**Expected Result:** The record opens in a new browser tab. No embedded panel routing is attempted. The action completes without errors.

---

## Search vs. Create Workflow Screen Pop Combinations (5 TCs)

---

**TC27** `[AGTINT][CXA][Multi-CRM][ScreenPop][Voice] Two CRMs both with Search Pop = True and Create Pop = True → all four records pop`

**Preconditions:**
- Multi-CRM feature toggle is ON
- CRM A: Search Workflow (Screen Pop = **True**), Create Workflow (Screen Pop = **True**)
- CRM B: Search Workflow (Screen Pop = **True**), Create Workflow (Screen Pop = **True**)
- Contact produces a single search match AND a newly created record for both CRMs
- Agent logged into CX Agent

**Steps:**
1. Log in to CX Agent with both CRMs configured as described
2. Receive an inbound voice contact
3. Both search workflows execute and return a single match each
4. Both create workflows execute and create a new record each
5. Observe which screen pop events fire and how many

**Expected Result:** Four screen pop events fire — one search match and one created record for each CRM, in positional order. No pops are dropped or duplicated. No errors.

---

**TC28** `[AGTINT][CXA][Multi-CRM][ScreenPop][Voice] Two CRMs — CRM A: Search Pop = True / Create Pop = False; CRM B: Search Pop = False / Create Pop = True → one pop each, correct type only`

**Preconditions:**
- Multi-CRM feature toggle is ON
- CRM A: Search Workflow (Screen Pop = **True**), Create Workflow (Screen Pop = **False**)
- CRM B: Search Workflow (Screen Pop = **False**), Create Workflow (Screen Pop = **True**)
- Contact produces a single search match AND a newly created record for both CRMs
- Agent logged into CX Agent

**Steps:**
1. Log in to CX Agent with both CRMs configured as described
2. Receive an inbound voice contact
3. Both search and create workflows execute for both CRMs
4. Observe which screen pop events fire

**Expected Result:** Exactly two screen pops fire — CRM A's search match and CRM B's newly created record. CRM A's created record and CRM B's search match do NOT produce screen pops. Positional order is respected. No errors.

---

**TC29** `[AGTINT][CXA][Multi-CRM][ScreenPop][Voice] Two CRMs — CRM A: Search Pop = True / Create Pop = True; CRM B: Search Pop = False / Create Pop = False → only CRM A pops`

**Preconditions:**
- Multi-CRM feature toggle is ON
- CRM A: Search Workflow (Screen Pop = **True**), Create Workflow (Screen Pop = **True**)
- CRM B: Search Workflow (Screen Pop = **False**), Create Workflow (Screen Pop = **False**)
- Contact produces a single search match AND a newly created record for both CRMs
- Agent logged into CX Agent

**Steps:**
1. Log in to CX Agent with both CRMs configured as described
2. Receive an inbound voice contact
3. All four workflows (2 search, 2 create) execute
4. Observe which screen pop events fire

**Expected Result:** Exactly two screen pops fire — CRM A's search match and CRM A's created record. CRM B produces zero screen pops. No errors.

---

**TC30** `[AGTINT][CXA][Multi-CRM][ScreenPop][Digital] Two CRMs — CRM A: Search Pop = True / Create Pop = False; CRM B: Search Pop = False / Create Pop = True → one pop each, correct type only`

**Preconditions:**
- Multi-CRM feature toggle is ON
- CRM A: Search Workflow (Screen Pop = **True**), Create Workflow (Screen Pop = **False**)
- CRM B: Search Workflow (Screen Pop = **False**), Create Workflow (Screen Pop = **True**)
- Contact produces a single search match AND a newly created record for both CRMs
- Agent logged into CX Agent handling a digital contact

**Steps:**
1. Log in to CX Agent with both CRMs configured as described
2. Receive an inbound digital contact
3. Both search and create workflows execute for both CRMs
4. Observe which screen pop events fire

**Expected Result:** Exactly two screen pops fire — CRM A's search match and CRM B's newly created record. CRM A's created record and CRM B's search match do NOT produce screen pops. Positional order is respected. No errors.

---

## Edge Cases & Negative (3 TCs)

---

**TC31** `[AGTINT][CXA][Multi-CRM][ScreenPop][Voice] One CRM workflow has an invalid configurationId injected → that workflow fails gracefully; other CRM still pops correctly`

**Preconditions:**
- Multi-CRM feature toggle is ON
- Two CRMs configured, each with a Search Workflow and Screen Pop = True
- CRM A has its `configurationId` in the workflow payload manually replaced with a non-existent / invalid value
- CRM B retains a valid `configurationId`
- Contact is set up to produce a single match for both CRMs
- Agent logged into CX Agent receiving an inbound voice contact

**Steps:**
1. Configure two CRM workflows normally in the Agent Workflow Configuration editor
2. Manually edit the configuration payload to replace CRM A's `configurationId` with an invalid value (e.g. a random UUID that does not correspond to any saved configuration)
3. Load CX Agent with the modified payload
4. Receive an inbound voice contact
5. Both search workflows execute and each returns a single match
6. Observe which screen pop events fire
7. Check browser console for errors

**Expected Result:** CRM A's screen pop fails gracefully — the workflow with the invalid `configurationId` either produces no pop or surfaces an error indicator, but does NOT crash the agent. CRM B's screen pop fires correctly. No unhandled JavaScript errors in the console. Agent remains operational for the remainder of the contact.

---

**TC32** `[AGTINT][CXA][Multi-CRM][ScreenPop][Voice] One CRM workflow has an invalid workflowId injected → that workflow fails gracefully; other CRM still pops correctly`

**Preconditions:**
- Multi-CRM feature toggle is ON
- Two CRMs configured, each with a Search Workflow and Screen Pop = True
- CRM A has its `workflowId` in the workflow payload manually replaced with a non-existent / invalid value
- CRM B retains a valid `workflowId`
- Contact is set up to produce a single match for both CRMs
- Agent logged into CX Agent receiving an inbound voice contact

**Steps:**
1. Configure two CRM workflows normally in the Agent Workflow Configuration editor
2. Manually edit the configuration payload to replace CRM A's `workflowId` with an invalid value (e.g. a random UUID that does not correspond to any saved workflow)
3. Load CX Agent with the modified payload
4. Receive an inbound voice contact
5. Both search workflows execute (or CRM A's workflow fails to resolve)
6. Observe which screen pop events fire
7. Check browser console for errors

**Expected Result:** CRM A's screen pop fails gracefully — the workflow with the invalid `workflowId` either produces no pop or surfaces an error indicator, but does NOT crash the agent. CRM B's screen pop fires correctly. No unhandled JavaScript errors in the console. Agent remains operational for the remainder of the contact.

---

**TC33** `[AGTINT][CXA][Multi-CRM][ScreenPop][Voice] One CRM workflow has invalid configurationId, another has invalid workflowId → both fail gracefully, valid CRM still pops`

**Preconditions:**
- Multi-CRM feature toggle is ON
- Three CRMs configured, each with a Search Workflow and Screen Pop = True
- CRM A has its `configurationId` in the workflow payload manually replaced with an invalid value
- CRM B has its `workflowId` in the workflow payload manually replaced with an invalid value
- CRM C retains valid `configurationId` and `workflowId`
- Contact is set up to produce a single match for all three CRMs
- Agent logged into CX Agent receiving an inbound voice contact

**Steps:**
1. Configure three CRM workflows normally in the Agent Workflow Configuration editor
2. Manually edit the configuration payload to replace CRM A's `configurationId` with an invalid value
3. Also replace CRM B's `workflowId` with an invalid value
4. Load CX Agent with the modified payload
5. Receive an inbound voice contact
6. All three search workflows attempt to execute
7. Observe which screen pop events fire
8. Check browser console for errors

**Expected Result:** CRM A and CRM B both fail gracefully — their workflows with the invalid IDs either produce no pop or surface an error indicator, but do NOT crash the agent. CRM C's screen pop fires correctly. No unhandled JavaScript errors in the console. Agent remains operational and the contact can be completed normally.

---
