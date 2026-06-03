# Multi-CRM: RelatesTo — QA Test Cases

**Epic:** CXIFW-379
**Test Plan:** CXIFW-771
**Feature:** Multi-CRM RelatesTo (Strategy Pattern Refactor + Per-CRM State + MUI Popper)
**Date:** June 2026
**Total TCs:** 27

---

## Group 1 — Strategy Pattern Routing (5 TCs)

---

**TC1** `[AGTINT][CXA][Multi-CRM][RelatesTo][Voice] Pinned Salesforce record → Salesforce strategy executes and SF-specific RelatesTo workflow fires`

**Preconditions:**
- Multi-CRM feature toggle is ON
- Salesforce CRM configured with a Create Workflow that pins a record with `relatesTo=true`
- RelatesTo data-memorialization workflow is configured for Salesforce
- Agent logged into CX Agent on a live voice contact

**Steps:**
1. Accept an inbound voice contact that produces a pinned Salesforce record in Current Interactions
2. Confirm the RelatesTo button is visible on the pinned SF record
3. Click the RelatesTo button on the pinned SF record
4. Select a valid relatable entity from the popover
5. Capture the outbound DM workflow API call payload

**Expected Result:** The SalesforceRelatesToStrategy is invoked (verifiable via network call shape / logs). The RelatesTo DM call fires with `action: "relatesTo"`, the correct SF entity type and ID, the related entity field name/value, and includes the SF configurationId and workflowId. No ServiceNow or MSD strategy is invoked.

---

**TC2** `[AGTINT][CXA][Multi-CRM][RelatesTo][Voice] Pinned ServiceNow record → ServiceNow strategy executes and SNOW-specific RelatesTo workflow fires`

**Preconditions:**
- Multi-CRM feature toggle is ON
- ServiceNow CRM configured with a Create Workflow that pins a record with `relatesTo=true`
- RelatesTo workflow is configured for ServiceNow
- Agent logged into CX Agent on a live voice contact

**Steps:**
1. Accept an inbound voice contact that produces a pinned SNOW record in Current Interactions
2. Click the RelatesTo button on the pinned SNOW record
3. Select a valid relatable entity from the popover
4. Capture the outbound DM workflow API call payload

**Expected Result:** The ServiceNowRelatesToStrategy is invoked. The RelatesTo DM call fires with the correct SNOW entity type, entity ID, related field, and the SNOW configurationId + workflowId. Salesforce and MSD strategies are not invoked.

---

**TC3** `[AGTINT][CXA][Multi-CRM][RelatesTo][Voice] Pinned Microsoft Dynamics Phone Call record → MSD strategy executes and MSD-specific RelatesTo workflow fires`

**Preconditions:**
- Multi-CRM feature toggle is ON
- Microsoft Dynamics CRM configured with a Create Workflow that pins a Phone Call entity with `relatesTo=true`
- RelatesTo workflow is configured for MSD
- Agent logged into CX Agent on a live voice contact

**Steps:**
1. Accept an inbound voice contact that produces a pinned MSD Phone Call record
2. Click the RelatesTo button on the pinned MSD record
3. Select a valid relatable entity from the popover
4. Capture the outbound DM workflow API call payload

**Expected Result:** The MsdRelatesToStrategy is invoked. The RelatesTo DM call fires with the correct MSD entity type (Phone Call), entity ID, related field, and the MSD configurationId + workflowId. SF and SNOW strategies are not invoked.

---

**TC4** `[AGTINT][CXA][Multi-CRM][RelatesTo][Voice] Strategy router dispatches by system.type → no if/else CRM branching observed in code path`

**Preconditions:**
- Multi-CRM feature toggle is ON
- Three CRMs configured: Salesforce, ServiceNow, and MSD, each with a pinned record supporting RelatesTo
- DevTools / logging enabled to trace strategy resolution
- Agent logged into CX Agent on a live voice contact

**Steps:**
1. Accept an inbound voice contact that produces pinned records for all three CRMs
2. Click RelatesTo on the SF pinned record → capture which strategy resolves
3. Click RelatesTo on the SNOW pinned record → capture which strategy resolves
4. Click RelatesTo on the MSD pinned record → capture which strategy resolves

**Expected Result:** For each click, `getRelatesToStrategy(systemType)` returns the correct strategy implementation matching the record's CRM type. No legacy if/else CRM branching is executed; routing is fully strategy-based. Each click only invokes its own strategy.

---

**TC5** `[AGTINT][CXA][Multi-CRM][RelatesTo][Voice] Unknown / unsupported system.type → router handles gracefully without crashing`

**Preconditions:**
- Multi-CRM feature toggle is ON
- Test environment configured with a CRM whose `system.type` is not SF, SNOW, or MSD (e.g. mocked unsupported type)
- Agent logged into CX Agent

**Steps:**
1. Accept an inbound voice contact with the unsupported CRM configured
2. Attempt to interact with the RelatesTo control if rendered
3. Observe the UI and console/logs

**Expected Result:** No JavaScript crash, no broken UI, and no incorrect strategy execution. Either the RelatesTo button is not rendered for the unsupported type, or the router returns a no-op / logs a clear "no strategy" message. Other CRMs on the same contact continue to function.

---

## Group 2 — Per-CRM RelatesTo State Isolation (5 TCs)

---

**TC6** `[AGTINT][CXA][Multi-CRM][RelatesTo][Voice] Two CRMs active → RelatesTo state is keyed by contactId_configurationId in ccf-multi-crm.slice.ts`

**Preconditions:**
- Multi-CRM feature toggle is ON
- Two CRMs configured (e.g. SF + SNOW), each with pinned records supporting RelatesTo
- Redux DevTools available
- Agent logged into CX Agent on a live voice contact

**Steps:**
1. Accept an inbound voice contact with two CRMs configured
2. Open Redux DevTools and inspect `ccf-multi-crm.slice` state
3. Click RelatesTo on the CRM-A pinned record and select a relatable entity
4. Click RelatesTo on the CRM-B pinned record and select a relatable entity
5. Inspect the slice state keys after each action

**Expected Result:** RelatesTo state entries are keyed by `{contactId}_{configurationId}` — one key per (contact, config) pair. CRM-A and CRM-B each have their own isolated state entry. No shared/global RelatesTo state key exists.

---

**TC7** `[AGTINT][CXA][Multi-CRM][RelatesTo][Voice] Two CRMs active → RelatesTo action in CRM-A does not modify CRM-B's RelatesTo state`

**Preconditions:**
- Multi-CRM feature toggle is ON
- Two CRMs configured (CRM-A and CRM-B), each with pinned records and RelatesTo enabled
- Agent logged into CX Agent on a live voice contact

**Steps:**
1. Accept an inbound voice contact with both CRMs configured
2. Capture initial state of CRM-B's RelatesTo slice entry
3. Click RelatesTo in CRM-A and select a relatable entity
4. Re-inspect CRM-B's RelatesTo slice entry

**Expected Result:** CRM-B's RelatesTo state is unchanged. No entity, loading flag, error, or selection from CRM-A bleeds into CRM-B's keyed entry.

---

**TC8** `[AGTINT][CXA][Multi-CRM][RelatesTo][Voice] generateListOfRelatableEntities filters by CRM → CRM-A popover lists only CRM-A entities`

**Preconditions:**
- Multi-CRM feature toggle is ON
- Two CRMs configured, both with multiple Related Interactions returned
- Agent on a live voice contact with pinned RelatesTo-enabled records in both CRMs

**Steps:**
1. Accept an inbound voice contact with two CRMs returning multiple Related Interactions each
2. Click RelatesTo on the CRM-A pinned record
3. Inspect the entities listed in the popover
4. Close the popover and click RelatesTo on the CRM-B pinned record
5. Inspect entities in the CRM-B popover

**Expected Result:** The CRM-A popover lists only entities from CRM-A's Related Interactions (filtered by relationship map). The CRM-B popover lists only CRM-B entities. No cross-CRM contamination of relatable entities.

---

**TC9** `[AGTINT][CXA][Multi-CRM][RelatesTo][Voice] Contact ends → RelatesTo state for that contactId is cleared from slice`

**Preconditions:**
- Multi-CRM feature toggle is ON
- Two CRMs configured with pinned RelatesTo-enabled records
- Agent on a live voice contact; at least one RelatesTo action has been performed
- Redux DevTools available

**Steps:**
1. Accept an inbound voice contact and perform a RelatesTo action in both CRMs
2. Verify slice entries exist for both `{contactId}_{configurationId}` keys
3. End the contact (and complete ACW if required)
4. Re-inspect the `ccf-multi-crm.slice` state

**Expected Result:** All RelatesTo state entries keyed by the ended contactId are cleared from the slice. State for any other concurrent / subsequent contacts is untouched.

---

**TC10** `[AGTINT][CXA][Multi-CRM][RelatesTo][Voice] Two concurrent voice contacts with overlapping CRMs → RelatesTo state for each contact is isolated by contactId`

**Preconditions:**
- Multi-CRM feature toggle is ON
- Two CRMs configured
- Agent capable of handling two concurrent voice contacts
- Both contacts produce pinned RelatesTo-enabled records in both CRMs

**Steps:**
1. Accept Contact 1; pinned records appear for both CRMs
2. Accept Contact 2 in parallel; pinned records appear for both CRMs
3. Perform a RelatesTo action on Contact 1 / CRM-A
4. Switch focus to Contact 2 and perform a RelatesTo action on Contact 2 / CRM-A
5. Inspect slice state and the popover content per contact

**Expected Result:** Four distinct slice keys exist (`contact1_configA`, `contact1_configB`, `contact2_configA`, `contact2_configB`). RelatesTo actions on Contact 1 do not affect Contact 2's state and vice versa. Each contact's popover shows only its own relatable entities.

---

## Group 3 — Thunk / Workflow Integration (3 TCs)

---

**TC11** `[AGTINT][CXA][Multi-CRM][RelatesTo][Voice] RelatesTo thunk payload → includes both configurationId and workflowId for the active CRM`

**Preconditions:**
- Multi-CRM feature toggle is ON
- At least one CRM configured with pinned RelatesTo-enabled record
- Network DevTools / proxy available to inspect outbound calls
- Agent on a live voice contact

**Steps:**
1. Accept an inbound voice contact producing a pinned RelatesTo-enabled record
2. Open Network DevTools and clear logs
3. Click the RelatesTo button and select a relatable entity
4. Inspect the outgoing workflow-execution POST payload

**Expected Result:** The payload contains both `configurationId` and `workflowId` corresponding to the CRM whose record initiated the action. Values match the CRM's Agent Workflow Configuration. No null/undefined/missing IDs.

---

**TC12** `[AGTINT][CXA][Multi-CRM][RelatesTo][Voice] Two CRMs active → RelatesTo in CRM-A sends CRM-A's configurationId+workflowId; RelatesTo in CRM-B sends CRM-B's`

**Preconditions:**
- Multi-CRM feature toggle is ON
- Two CRMs configured with distinct configurationIds and distinct RelatesTo workflowIds
- Agent on a live voice contact with pinned RelatesTo-enabled records in both CRMs

**Steps:**
1. Accept an inbound voice contact with both CRMs configured
2. Click RelatesTo on the CRM-A pinned record and select an entity; capture payload
3. Click RelatesTo on the CRM-B pinned record and select an entity; capture payload

**Expected Result:** The CRM-A payload contains CRM-A's configurationId + RelatesTo workflowId. The CRM-B payload contains CRM-B's configurationId + RelatesTo workflowId. There is no mix-up or cross-routing of IDs.

---

**TC13** `[AGTINT][CXA][Multi-CRM][RelatesTo][Voice] Lambda receives RelatesTo payload → executes correct CRM workflow per system.type`

**Preconditions:**
- Multi-CRM feature toggle is ON
- SF, SNOW, and MSD CRMs configured with RelatesTo workflows
- Backend Lambda / Tray.io workflow logs accessible
- Agent on a live voice contact with pinned RelatesTo records in all three CRMs

**Steps:**
1. Accept an inbound voice contact with all three CRMs configured
2. Perform RelatesTo in SF, then SNOW, then MSD
3. Inspect Lambda logs / Tray.io workflow invocations for each RelatesTo call

**Expected Result:** Three Lambda invocations are observed, each carrying the correct CRM's `configurationId`, `workflowId`, entity type, entity ID, and related field. The correct Tray.io RelatesTo workflow is invoked per CRM. No misrouted invocations.

---

## Group 4 — MUI Popper / UI Behavior (5 TCs)

---

**TC14** `[AGTINT][CXA][Multi-CRM][RelatesTo][Voice] Click RelatesTo button → popover renders via MUI Popper, anchored to the button`

**Preconditions:**
- Multi-CRM feature toggle is ON
- One CRM configured with a pinned RelatesTo-enabled record
- Agent on a live voice contact

**Steps:**
1. Accept an inbound voice contact producing a pinned RelatesTo-enabled record
2. Click the RelatesTo button on the pinned record
3. Inspect the rendered DOM (DevTools) and visual position of the popover

**Expected Result:** A MUI Popper-based popover renders, anchored to the RelatesTo button. The DOM does not show legacy `querySelector`/manual scroll DOM manipulation. The popover is positioned correctly relative to the button.

---

**TC15** `[AGTINT][CXA][Multi-CRM][RelatesTo][Voice] Click RelatesTo button again or outside → popover closes correctly`

**Preconditions:**
- Multi-CRM feature toggle is ON
- One CRM configured with a pinned RelatesTo-enabled record
- Agent on a live voice contact with the RelatesTo popover already open

**Steps:**
1. Open the RelatesTo popover on a pinned record
2. Click the RelatesTo button again → observe close
3. Re-open the popover, then click outside the popover area → observe close
4. Re-open the popover, press Escape → observe close

**Expected Result:** Popover toggles correctly on second button click, closes on outside click, and closes on Escape. No stuck-open or duplicate popover instances. No console errors.

---

**TC16** `[AGTINT][CXA][Multi-CRM][RelatesTo][Voice] Popover content reads from ccf-multi-crm.slice → displays the correct CRM's relatable entities`

**Preconditions:**
- Multi-CRM feature toggle is ON
- Two CRMs configured, both with multiple relatable entities in Related Interactions
- Redux DevTools available
- Agent on a live voice contact

**Steps:**
1. Accept an inbound voice contact producing pinned RelatesTo-enabled records in both CRMs
2. Open the RelatesTo popover for CRM-A
3. Compare the popover content against the `ccf-multi-crm.slice` state for that CRM's keyed entry
4. Close, open the CRM-B popover, repeat comparison

**Expected Result:** Each popover's listed entities match the entities stored in `ccf-multi-crm.slice` under that CRM's `{contactId}_{configurationId}` key. No data is sourced from the legacy slice.

---

**TC17** `[AGTINT][CXA][Multi-CRM][RelatesTo][Voice] Salesforce RelatesTo selection → getSFCRMNavigationData bridge returns correct navigation data`

**Preconditions:**
- Multi-CRM feature toggle is ON
- Salesforce CRM configured with a pinned RelatesTo-enabled record
- Agent embedded in Salesforce; SF navigation API accessible
- Agent on a live voice contact

**Steps:**
1. Accept an inbound voice contact producing a pinned SF record
2. Open RelatesTo popover and select a valid relatable SF entity
3. Confirm the SF navigation/Lightning navigation receives expected data
4. Inspect the data returned by the `getSFCRMNavigationData` bridge

**Expected Result:** The bridge selector returns the correct SF navigation data (record type, record ID, navigation URL params). SF receives the expected navigation/relate action and the operation completes without error.

---

**TC18** `[AGTINT][CXA][Multi-CRM][RelatesTo][Voice] Long list of relatable entities → popover renders, scrolls, and is selectable without DOM manipulation hacks`

**Preconditions:**
- Multi-CRM feature toggle is ON
- One CRM configured returning a long list of relatable entities (e.g. 20+)
- Agent on a live voice contact with a pinned RelatesTo-enabled record

**Steps:**
1. Accept an inbound voice contact with a long list of relatable entities
2. Open the RelatesTo popover
3. Scroll within the popover content
4. Select an entity from the middle or bottom of the list

**Expected Result:** Popover renders the full list, supports normal scrolling (MUI Popper, no direct querySelector/scroll hacks), and entity selection works regardless of list position. No layout jumps or selection mismatches.

---

## Group 5 — Loading State (Button-Level Only) (3 TCs)

---

**TC19** `[AGTINT][CXA][Multi-CRM][RelatesTo][Voice] Click RelatesTo → loading indicator is scoped to the clicked button only`

**Preconditions:**
- Multi-CRM feature toggle is ON
- Two CRMs configured with pinned RelatesTo-enabled records
- Agent on a live voice contact

**Steps:**
1. Accept an inbound voice contact producing pinned RelatesTo records in both CRMs
2. Click the RelatesTo button on the CRM-A pinned record
3. Immediately observe the CRM-A button, the CRM-B button, the CRM-A panel/section, and the CRM-B panel/section

**Expected Result:** The loading indicator appears on the CRM-A RelatesTo button only. CRM-B's button remains in its idle state. Neither CRM-A's nor CRM-B's broader panel/page-level UI shows any loading spinner. No `loadingByConfigId` page-level overlays.

---

**TC20** `[AGTINT][CXA][Multi-CRM][RelatesTo][Voice] RelatesTo success → button loading state clears and selection is reflected`

**Preconditions:**
- Multi-CRM feature toggle is ON
- One CRM configured with a pinned RelatesTo-enabled record
- Agent on a live voice contact
- Backend RelatesTo workflow succeeds

**Steps:**
1. Open the RelatesTo popover and select a valid relatable entity
2. Observe the button during the API call
3. Wait for the call to complete successfully
4. Observe the button after success

**Expected Result:** The button shows a loading state during the call and returns to its idle state after success. The selected entity reflects as related in the UI. No residual spinner.

---

**TC21** `[AGTINT][CXA][Multi-CRM][RelatesTo][Voice] RelatesTo failure → button loading state clears and error is surfaced (no global error state)`

**Preconditions:**
- Multi-CRM feature toggle is ON
- One CRM configured with a pinned RelatesTo-enabled record
- Test environment can force the RelatesTo workflow to fail (e.g. Tray.io error, invalid mapping)
- Agent on a live voice contact

**Steps:**
1. Open the RelatesTo popover and select a relatable entity
2. Observe the button during the failing API call
3. Once the call fails, observe the button and any error indication
4. Observe the rest of the CRM panel and the second CRM (if configured)

**Expected Result:** Button returns from loading to idle on failure. An error is surfaced inline (toast or button-level message). No global/page-level error overlay. Other CRMs and other parts of the agent UI remain functional.

---

## Group 6 — Bridge Selectors & External Consumer Compatibility (2 TCs)

---

**TC22** `[AGTINT][CXA][Multi-CRM][RelatesTo][Voice] External components reading RelatesTo fields → receive correct values via bridge selectors from new slice`

**Preconditions:**
- Multi-CRM feature toggle is ON
- At least one CRM configured with a pinned RelatesTo-enabled record
- External component(s) known to consume RelatesTo-specific fields (e.g. Customer Card sub-components, downstream UI) are rendered
- Redux DevTools available

**Steps:**
1. Accept an inbound voice contact producing a pinned RelatesTo-enabled record
2. Perform a RelatesTo action
3. Inspect the data displayed in external consumer components
4. Confirm the consumed values trace to `ccf-multi-crm.slice` via bridge selectors (not the legacy slice)

**Expected Result:** External components display correct RelatesTo data. Values resolve through the bridge selectors and reflect the new slice as the source of truth. No empty fields or stale data from the old slice.

---

**TC23** `[AGTINT][CXA][Multi-CRM][RelatesTo][Voice] Single-CRM regression (toggle OFF) → existing RelatesTo behavior is unchanged for SF, SNOW, and MSD`

**Preconditions:**
- Multi-CRM feature toggle is OFF
- One CRM configured at a time (run for SF, then SNOW, then MSD)
- Each CRM has its existing RelatesTo workflow configured
- Agent on a live voice contact

**Steps:**
1. With feature toggle OFF, log in with SF configured; receive an inbound voice contact with a pinned SF record
2. Perform a RelatesTo action and verify the SF DM call payload and UI
3. End the contact; repeat steps with SNOW configured
4. Repeat with MSD configured (Phone Call entity)

**Expected Result:** For each single-CRM run, RelatesTo behaves identically to pre-refactor: correct popover, correct relatable entities, correct DM workflow payload, correct linkage in the CRM. No regressions in any of the three legacy CRM flows.

---

## Group 7 — Multi-CRM End-to-End (2 TCs)

---

**TC24** `[AGTINT][CXA][Multi-CRM][RelatesTo][Voice] Two CRMs active → RelatesTo works independently and concurrently in both CRMs on the same contact`

**Preconditions:**
- Multi-CRM feature toggle is ON
- Two CRMs configured (e.g. SF + SNOW), each with pinned RelatesTo-enabled records and relatable entities
- Agent on a live voice contact

**Steps:**
1. Accept an inbound voice contact with both CRMs configured
2. Open the CRM-A RelatesTo popover; while it is open, open the CRM-B RelatesTo popover
3. Select a relatable entity in CRM-A
4. Select a relatable entity in CRM-B
5. Verify both relationships are reflected in their respective CRMs (backend check)

**Expected Result:** Both popovers can be opened and used independently. Both selections fire their own RelatesTo DM call with their own configurationId + workflowId. Both CRMs reflect the relationship. Neither selection affects the other CRM's UI or state.

---

**TC25** `[AGTINT][CXA][Multi-CRM][RelatesTo][Voice] Three CRMs active → RelatesTo per CRM executes correct strategy and updates only its own state`

**Preconditions:**
- Multi-CRM feature toggle is ON
- Three CRMs configured: SF, SNOW, MSD, each with pinned RelatesTo-enabled records
- Agent on a live voice contact

**Steps:**
1. Accept an inbound voice contact with all three CRMs configured
2. Perform a RelatesTo action in SF
3. Perform a RelatesTo action in SNOW
4. Perform a RelatesTo action in MSD
5. Inspect slice state and CRM-side records

**Expected Result:** Each action invokes only its own strategy and updates only its own `{contactId}_{configurationId}` slice entry. All three CRMs reflect their respective relationships. No cross-CRM bleed in state, payloads, or UI.

---

## Group 8 — Backwards Compatibility & RelatesTo-vs-DM Isolation (2 TCs)

---

**TC26** `[AGTINT][CXA][Multi-CRM][RelatesTo][Voice] RelatesTo fires during call → not included in end-of-call DM payload`

**Preconditions:**
- Multi-CRM feature toggle is ON
- One or more CRMs configured with DM workflow at contact end
- Agent on a live voice contact with a pinned RelatesTo-enabled record
- Network DevTools / backend logs available

**Steps:**
1. Accept an inbound voice contact producing a pinned RelatesTo-enabled record
2. Perform a RelatesTo action mid-call; capture that RelatesTo DM call
3. End the contact (and complete ACW if required)
4. Capture the end-of-call DM call payload(s)

**Expected Result:** The RelatesTo workflow fires immediately mid-call. The end-of-call DM payload does not include the RelatesTo action. RelatesTo and end-of-call DM remain isolated as designed.

---

**TC27** `[AGTINT][CXA][Multi-CRM][RelatesTo][Digital] RelatesTo on a digital contact with two CRMs → strategy routing, per-CRM state, and DM call are correct`

**Preconditions:**
- Multi-CRM feature toggle is ON
- Two CRMs configured (e.g. SF + SNOW), both supporting RelatesTo on a digital channel
- Pinned records with `relatesTo=true` produced for both CRMs
- Agent on a live digital contact

**Steps:**
1. Accept an inbound digital contact with both CRMs configured
2. Click RelatesTo on the CRM-A pinned record, select an entity; capture payload + state
3. Click RelatesTo on the CRM-B pinned record, select an entity; capture payload + state
4. Verify slice keying, popover content, button-level loading, and DM payloads

**Expected Result:** For digital contacts, behavior matches voice: correct strategy per CRM, state keyed by `{contactId}_{configurationId}`, button-level loading only, correct configurationId + workflowId per CRM, and no cross-CRM bleed.

---
