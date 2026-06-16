---
description: Load for context when dealing with agentCreate-related test cases and test plans.
---

Here’s a **practical test plan / implementation guide** for validating **multi-CRM manual create with one snippet** in Agent Workspace (Embedded), with the expectation that **newly created records appear under separate CRM-labeled trays on the customer card** for your new feature. I’m going to frame this as a **testable hypothesis** based on how NiCE documents manual create today. [\[help.nicecxone.com\]](https://help.nicecxone.com/content/agent/cxoneagent/usecustomercardcxa.htm)

***

# Goal

Validate that **one manual-create snippet** can publish **create options for multiple CRM configurations** in a single payload list, and that when the agent creates records from those options, the created records are rendered into the **correct CRM-labeled tray/section** on the customer card under your new multi-CRM UI behavior. [\[help.nicecxone.com\]](https://help.nicecxone.com/content/agent/cxoneagent/usecustomercardcxa.htm)

***

# Why this test is valid

NiCE’s manual-create documentation says the manual-create snippet builds **one or more payload objects**, and each payload contains its own **`configurationId`** and **`workflowId`**, plus `workflowInput` and a display label. The docs also say you can include **more than one workflow** in the same snippet by building a list of payloads and sending that list through the **`Agent Workflow Create Payload`** custom event. That means the **routing metadata already exists at the payload-item level**, which is exactly what makes a **single-snippet / multi-CRM test** worth validating. [\[help.nice-...ontact.com\]](https://help.nice-incontact.com/content/agent/agentapplicationadministration/cxoneagent/crmintegration/workflowsnippetinformation/configuresnowworkflowsforcxa.htm)

To be precise, NiCE’s public docs describe this pattern clearly for **multiple create options**, but they do **not explicitly say** “mix several CRM configurations in one list.” So this test is best treated as **a product validation of your new feature**, not as something the docs formally guarantee out of the box. [\[help.nice-...ontact.com\]](https://help.nice-incontact.com/content/agent/agentapplicationadministration/cxoneagent/crmintegration/workflowsnippetinformation/configuresnowworkflowsforcxa.htm)

***

# Important architecture note before testing

For **manual Agent Create**, the documented path is the **`SNIPPET` + `CUSTOMEVENT`** path. The docs for manual create do **not** show `WORKFLOW EXECUTE` as the mechanism for publishing the **Create New** options in the customer card. Instead, the snippet builds the payload list, and the custom event passes that list into the agent UI.

`WORKFLOW EXECUTE` is still important in NiCE overall—it is the general Studio action that triggers CRM workflows, and each `WORKFLOW EXECUTE` action is tied to a workflow/configuration path—but for **manual create menu setup**, the main thing under test is the **payload list delivered by the custom event**. [\[help.nice-...ontact.com\]](https://help.nice-incontact.com/content/agent/agentapplicationadministration/cxoneagent/crmintegration/workflowsnippetinformation/configuresnowworkflowsforcxa.htm)

Also, if you want the newly created records to **show up in the customer card**, the docs say you must set **`cacheResponse = "true"`** in the create payload. If `cacheResponse = "false"`, the created record will **not** appear in the customer card and will not be pinned or screen popped even if other flags are true.

***

# Preconditions

Before you run the test, make sure these are true:

1. You have at least **two CRM configurations** set up in **Agent Integrations > Configurations**, each with valid create workflows and accessible **Configuration ID** and **Workflow ID** values. The manual-create docs require a CRM configuration first, and the payload object explicitly references `configurationId` and `workflowId`. [\[help.nice-...ontact.com\]](https://help.nice-incontact.com/content/agent/agentapplicationadministration/cxoneagent/crmintegration/workflowsnippetinformation/configuresnowworkflowsforcxa.htm)

2. The system/integration user for each CRM has permission to create the record types you plan to test. NiCE’s CRM workflow docs say workflows run using the system user’s roles and permissions, and records are created using that system user context.

3. Your script contains the **manual-create `SNIPPET`** and the **`CUSTOMEVENT`** configured for **`Agent Workflow Create Payload`**. For voice, the docs say the target agent should be `{__agentId}` and the event data should be the JSON produced by the snippet.

4. Your new feature for **separate CRM-labeled trays** is enabled in the build you are testing. This tray-splitting behavior is your implementation expectation on top of the standard Related Interactions customer card area, which is where NiCE normally shows CRM-related records. [\[help.nicecxone.com\]](https://help.nicecxone.com/content/agent/cxoneagent/usecustomercardcxa.htm)

***

# Test setup: build one snippet with multiple CRM create payloads

## Step 1: Choose distinct create targets

Pick at least **two CRMs** and two obviously different record types so validation is easy. For example:

* **ServiceNow** → Create Incident or Contact.
* **Microsoft Dynamics** → Create Case or Contact. The workflow docs for Dynamics show standard/custom create workflow support. [\[help.nicecxone.com\]](https://help.nicecxone.com/content/studio/actionscx/agtint_wrkflo_config/agtint_wrkflo_config.htm?TocPath=Studio%7CStudio%7CActions%20%28Studio%29%7C_____7)

If you want a stronger test, use **three CRMs** so you can prove the one-snippet list scales beyond two create targets.

***

## Step 2: Build one shared workflow input object (or one per CRM if needed)

Your snippet can build a reusable create input payload (for example contact phone, ANI, or interaction context) and then attach that input to each CRM-specific payload through the `workflowInput` property. NiCE’s docs explicitly show that each payload has a `workflowInput` property and let you point that property at a dynamic object you build in the snippet.

If the CRMs need different field shapes, build **separate workflow input objects** inside the same snippet and assign the correct one to each payload. That still keeps the test focused on **one snippet → one payload list → many CRM targets**. The docs support per-payload workflow input assignment.

***

## Step 3: Define one payload per CRM option

For each create option, define a payload object with:

* `workflowInput`
* `display`
* `configurationId`
* `workflowId`
* `cacheResponse = "true"` so the created record can appear in the customer card.

### Pseudocode structure

Below is the **kind of structure** you want in the snippet. This is intentionally pseudocode-style and derived from the documented payload pattern:

```text
DYNAMIC createSharedPayload
createSharedPayload.cacheResponse = "true"
createSharedPayload.phone = "{ANI}"
createSharedPayload.contactId = "{contactId}"

DYNAMIC createSnowIncidentPayload
createSnowIncidentPayload.workflowInput = createSharedPayload
createSnowIncidentPayload.display = "SN Incident"
createSnowIncidentPayload.configurationId = "<ServiceNow Config ID>"
createSnowIncidentPayload.workflowId = "<ServiceNow Create Workflow ID>"

DYNAMIC createDynamicsCasePayload
createDynamicsCasePayload.workflowInput = createSharedPayload
createDynamicsCasePayload.display = "Dyn Case"
createDynamicsCasePayload.configurationId = "<Dynamics Config ID>"
createDynamicsCasePayload.workflowId = "<Dynamics Create Workflow ID>"

DYNAMIC list
list[1] = createSnowIncidentPayload
list[2] = createDynamicsCasePayload

DYNAMIC data
data.list = list
data.id = "{contactId}"

ASSIGN agentWorkflowCreatePayloadData = "{data.asjson()}"
```

This structure follows the documented manual-create model: multiple payloads, each with `configurationId` and `workflowId`, then packed into a list and passed to the custom event.

***

## Step 4: Configure the CustomEvent correctly

The manual-create docs say the **CustomEvent** should be configured with:

* **Target Agent** = `{__agentId}` for voice
* **EventName** = `Agent Workflow Create Payload`
* **PersistInMemory** = True / On
* **Data** = the JSON from the snippet.

If any of these are wrong—especially the **event name** or **data variable**—the Create New options may not show up in Agent Workspace.

***

# How to execute the test

## Test Case 1 — Baseline two-CRM create from one snippet

### Setup

* Put two payloads into the same snippet list: one for CRM A and one for CRM B.
* Set `cacheResponse = "true"` for both.

### Execution

1. Start a voice interaction that reaches the script containing the manual-create snippet and custom event.
2. Open the **Customer Card** in Agent Workspace. NiCE says the customer card is where CRM-linked records and related interactions appear. [\[help.nicecxone.com\]](https://help.nicecxone.com/content/agent/cxoneagent/usecustomercardcxa.htm)
3. Go to the **Related Interactions** area and click **Create New**. The manual-create docs say this is where agents select the record type to create.
4. Confirm that both options from your snippet are visible—for example **SN Incident** and **Dyn Case**. Those names come from the payload `display` values.
5. Select the ServiceNow option and complete or confirm the create operation.
6. Select the Dynamics option and complete or confirm the create operation on a fresh interaction or in sequence, depending on your UX.

### Expected result

* The **ServiceNow-created record** appears in the **ServiceNow-labeled tray** on the customer card for your new feature.
* The **Dynamics-created record** appears in the **Dynamics-labeled tray** on the customer card for your new feature.
* No record appears in the wrong tray.
* No record is duplicated across trays.
* The tray labels remain stable and CRM-specific even if the record types are similarly named.

Because create visibility in the customer card depends on `cacheResponse = "true"`, failure to display may indicate payload or caching issues rather than routing. [\[help.nicecxone.com\]](https://help.nicecxone.com/content/agent/cxoneagent/usecustomercardcxa.htm)

***

# Validation checklist

Use this checklist after each run:

* **Create New menu shows all expected options from one snippet**. The docs support multiple payloads in one list.
* **Each menu option uses the correct `display` label** from the payload. The docs say `display` is the name shown to agents.
* **Selecting a menu option creates a record in the correct backend CRM**, proving the selected payload’s `configurationId` and `workflowId` were honored. The payload contract is what makes this test valid. [\[help.nice-...ontact.com\]](https://help.nice-incontact.com/content/agent/agentapplicationadministration/cxoneagent/crmintegration/workflowsnippetinformation/configuresnowworkflowsforcxa.htm)
* **The record shows on the customer card** because `cacheResponse = "true"` was set.
* **The record appears in the expected CRM-labeled tray** for your new feature, not in a shared or ambiguous tray.
* **The customer card records remain separated by CRM**, consistent with the new multi-CRM tray behavior.

***

# Strong negative / edge tests you should run

## 1) One valid CRM payload, one invalid CRM payload

Keep one payload correct and intentionally break the other `workflowId` or `configurationId`. Since each payload carries its own routing info, the ideal behavior is that the **bad option fails in isolation** while the valid option still works. That proves you are dispatching per payload item rather than treating the snippet as one monolithic CRM context. [\[help.nice-...ontact.com\]](https://help.nice-incontact.com/content/agent/agentapplicationadministration/cxoneagent/crmintegration/workflowsnippetinformation/configuresnowworkflowsforcxa.htm)

## 2) Same record type name across CRMs

Create **Contact** in two different CRMs from the same snippet list. The docs say `display` is just what the agent sees; the actual routing is still defined by `configurationId` and `workflowId`. This is the best way to confirm your tray-splitting logic uses CRM identity, not only label text. [\[help.nice-...ontact.com\]](https://help.nice-incontact.com/content/agent/agentapplicationadministration/cxoneagent/crmintegration/workflowsnippetinformation/configuresnowworkflowsforcxa.htm)

## 3) `cacheResponse = "false"` control test

Set one payload to `false` and leave one at `true`. NiCE explicitly says that if `cacheResponse = "false"`, the record won’t appear in the customer card. This is a great control to prove that **tray visibility** and **backend creation success** are separate concerns.

## 4) More than two CRMs in one snippet

Add a third payload and verify the system still:

* shows all menu items,
* creates records correctly, and
* routes display into distinct CRM trays.

The docs support more than two payloads in a list by extending the array pattern.

***

# Evidence to capture

For each run, capture:

1. **Snippet payload JSON** used by the custom event, showing all payloads and their `configurationId` / `workflowId`. This is your best proof that the setup was truly “one snippet, many CRMs.”
2. **Customer Card screenshots** before and after create. NiCE’s customer card is where related CRM records are surfaced. [\[help.nicecxone.com\]](https://help.nicecxone.com/content/agent/cxoneagent/usecustomercardcxa.htm)
3. **Create New menu screenshot** showing multiple CRM create options coming from the same interaction.
4. **Backend proof** from each CRM showing the record was actually created under the correct system user context. NiCE says records are created using the CRM system user.
5. **Tray placement proof** showing the record appears in the expected CRM-labeled tray under the new UI behavior.

***

# Suggested pass/fail criteria

## Pass

* One snippet publishes multiple create options tied to different CRM configurations.
* Selecting each option creates a record in the correct CRM. [\[help.nice-...ontact.com\]](https://help.nice-incontact.com/content/agent/agentapplicationadministration/cxoneagent/crmintegration/workflowsnippetinformation/configuresnowworkflowsforcxa.htm)
* Created records with `cacheResponse = "true"` appear in the customer card.
* Under your new feature, each created record appears in the correct **CRM-labeled tray** and not in another CRM’s tray.

## Fail

* Create New only shows one CRM’s options even though the payload list contains several.
* Both creates land in the same backend CRM.
* Both records show in the wrong tray or in a single combined tray.
* Records create in backend but don’t appear in the customer card despite `cacheResponse = "true"`.
* One bad payload breaks the whole menu or the whole snippet rather than failing only that option. [\[help.nice-...ontact.com\]](https://help.nice-incontact.com/content/agent/agentapplicationadministration/cxoneagent/crmintegration/workflowsnippetinformation/configuresnowworkflowsforcxa.htm)

***

# Recommended tester note / hypothesis statement

You can use this language in a Jira comment or test case:

> **Hypothesis:** NiCE manual create should support a single snippet publishing multiple create options across different CRM configurations because each payload item includes its own `configurationId`, `workflowId`, and `workflowInput`, and the payload list is passed to Agent Workspace through `Agent Workflow Create Payload`. Under the new multi-CRM customer-card feature, records created from those options should surface in distinct CRM-labeled trays, provided `cacheResponse = "true"` is set for the selected payload. [\[help.nice-...ontact.com\]](https://help.nice-incontact.com/content/agent/agentapplicationadministration/cxoneagent/crmintegration/workflowsnippetinformation/configuresnowworkflowsforcxa.htm), [\[help.nicecxone.com\]](https://help.nicecxone.com/content/agent/cxoneagent/usecustomercardcxa.htm)

***

If you want, I can turn this into a **Jira-ready test case template** for **CXIFW-380** with **Preconditions / Steps / Expected Results / Evidence / Pass-Fail** fields filled out.
