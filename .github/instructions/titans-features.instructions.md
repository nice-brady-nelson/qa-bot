---
description: Loaded when creating test cases or test plans to better understand feature functionality and edge cases.
applyTo: 'Will be applied to any prompt that involves the creation of test cases or test plans, as these are the core features owned the Connect Agent - Titans team.'
---

Here is a comprehensive analysis of the **Connect Agent – Titans Team** features within CX_CRM, synthesized from internal Confluence documentation, Jira issues, architecture docs, and release testing records.

---

## 1. Data Memorialization (DM)

**Core Functionality:** When a call ends, a transfer completes, or a digital contact is closed/dispositioned, the system automatically writes CXone interaction data (contact fields, disposition, agent info, etc.) to the customer's CRM. This eliminates manual data entry and ensures important information is captured for future reference.

**How DM Interacts with the Architecture:**

The DM flow traverses multiple layers:

1. **CXone Agent (CXA) → ACD API:** At contact end, CXA identifies which CRMs have a DM workflow configured and at least one linked entity. It dispatches a separate DM call per qualifying CRM. [High Level Test Plan (CXIFW-857)](https://nice-ce-cxone-prod.atlassian.net/browse/CXIFW-857)

2. **ACD API (C# Monolith) → AWS Lambda:** The monolith invokes the `prod-ipaas-workflow-execution` Lambda via `AgentIntegrationCacheProxy.PostIntegrationWorkflowCache`. The action handler `AGTINT_WRKFLO_CONFIG` is declared `Blocking = true`. [CRM-25086 - MI Root Cause](https://nice-ce-cxone-prod.atlassian.net/browse/CRM-25086)

3. **Lambda → Redis (ElastiCache):** The Lambda reads interaction cache data (the cache key and linked entities) from Redis to determine which records are linked and need DM. It also reads the `{cacheKey}_workflow` entry to get the `dataMappingId` and `workflowId`. [Transfer Contact End to End Data Flow](https://nice-ce-cxone-prod.atlassian.net/wiki/spaces/IN/pages/483622913/Transfer+Contact+End+to+End+Data+Flow)

4. **Lambda → Tray.io:** The Lambda constructs the DM payload — iterating entities configured for the `dataMappingId`, transforming CXone contact data and field mappings into CRM entity objects — and invokes the Tray.io workflow webhook via `axios.post()`. The Tray workflow then writes the data to the CRM (Salesforce, ServiceNow, MS Dynamics, etc.). [AGTINT - Data Memorialization](https://nice-ce-cxone-prod.atlassian.net/wiki/spaces/IN/pages/17291055/AGTINT+-+Data+Memorialization)

5. **For Digital Contacts:** DM is triggered asynchronously — CXone places a DM job on an **AWS SQS queue** (`ipaas-digital-transcript-queue`), and the `digitalTranscript/app.js` Lambda picks it up, fetches the DFO transcript, and executes the DM workflow. [JS Lambdas Architecture](https://nice-ce-cxone-prod.atlassian.net/wiki/spaces/IN/pages/3678110836/JS+Lambdas)

**Key DM Trigger Points:**
- Voice (no disposition): fires at disconnect
- Voice (disposition enabled, not required): fires at disconnect
- Voice (disposition required): fires at disconnect (disposition data may be empty if ACW incomplete)
- Digital: fires when contact reaches CLOSED status, or on Save button click if disposition is required
- Transfer: fires at the transfer event for all qualifying CRMs

**Multi-CRM DM (Upcoming 26.x Feature):** Each CRM's DM call fires in parallel. Per-CRM error isolation ensures one CRM's failure doesn't block others. The dispatch guard prevents duplicate DM fires. [CXIFW-857](https://nice-ce-cxone-prod.atlassian.net/browse/CXIFW-857)

**Known Limitation:** DM requires a CRM record to be **linked** (either manually by the agent or automatically via a pinned record). An unlinked record will not trigger DM. If the Customer Card is not in focus when the call is dispositioned, the DM request is not triggered. [Common Problems](https://nice-ce-cxone-prod.atlassian.net/wiki/spaces/IN/pages/808583256/Integrations+Team+CXone+Agent+-+Agent+Integrations+-+Common+Problems)

---

## 2. Cache Key & Its Functionality

The **cache key** (`cacheKey`) is the central identifier that holds all Agent Integration information for a given contact interaction. It is stored in **ElastiCache Redis** (migrating to Valkey).

**Structure:** The cache key is an output parameter of the **Workflow Execute** Studio action (`cacheKey(out)`). It is typically the `interactionId` (a GUID) and branches into three sub-keys:

| Cache Key Pattern | Content | Purpose |
|---|---|---|
| `{cacheKey}` (default) | Search results — array of CRM records (contacts, cases, leads) | Stores **Related Interactions** data displayed in the Customer Card |
| `{cacheKey}_pin` | Pinned/created records | Stores **Current Interactions** data — records pinned to the top of the Customer Card, auto-linked for DM |
| `{cacheKey}_workflow` | Agent Workflow Configuration JSON (search, timeline, DM workflow IDs, configuration IDs) | Stores which workflows are configured so the system knows what to execute at contact end |

**TTL:** Originally 15 minutes. **As of 24.4, increased to 2 days.** If a contact sat in queue for 15+ minutes with the old TTL, the agent wouldn't see related interactions until pressing "refresh." [Triage & Troubleshooting](https://nice-ce-cxone-prod.atlassian.net/wiki/spaces/IN/pages/808452097/Integrations+Team+CXone+Agent+-+Agent+Integrations+-+Triage+Troubleshooting)

**KeepAlive Mechanism:** A `keepAlive: true` request can be sent to `POST /services/v30.0/agent-integration/workflow-execution/interaction/{cacheKey}` to refresh the TTL for all cached items based on that key. [Transfer Contact E2E Data Flow](https://nice-ce-cxone-prod.atlassian.net/wiki/spaces/IN/pages/483622913/Transfer+Contact+End+to+End+Data+Flow)

**Cache Response Setting:** The `cacheResponse` setting determines whether data is rendered on the Customer Card. If set to `false`, the record is still created in the CRM background but is hidden from the agent's view.

**How the Cache Key Flows:**
1. Studio script executes **Workflow Execute** → Lambda processes search/create → results cached in Redis under `{cacheKey}`
2. **Agent Workflow Configuration** action sends workflow metadata → Lambda caches it under `{cacheKey}_workflow`
3. CXA reads from Redis via `GET /agent-integration/workflow-execution/interaction/{cacheKey}?types=default,pin,workflow` to populate the Customer Card
4. At contact end, DM Lambda reads `{cacheKey}_workflow` to find the DM workflow and `dataMappingId`, reads `{cacheKey}` and `{cacheKey}_pin` to find linked entities, then executes DM

**On Transfer:** All cached data (all three sub-keys) is carried over to the receiving agent. The cache key is preserved across the transfer. [Transfer Contact E2E Data Flow](https://nice-ce-cxone-prod.atlassian.net/wiki/spaces/IN/pages/483622913/Transfer+Contact+End+to+End+Data+Flow)

---

## 3. Cache Response

Determines whether data is rendered on the Customer Card in the agent's view. If the code snippet for `cacheResponse` is removed, the system still runs normally and displays the record. If set to **false**, the record is hidden from the agent's view but still created in the CRM in the background. This is useful for backend-only CRM operations where the agent doesn't need to see the record.

---

## 4. Screen Pop

**Functionality:** Automatically opens a CRM record in the agent's browser/embedded CRM when an interaction arrives.

**Rules:**
- Screen pops trigger **exclusively for single-match searches** and newly created records (where `screenPop=true` in the Studio snippet)
- The same record always pops a new window for the same CRM
- For embedded CRMs, a single search screen pop opens within the CRM. For standalone browser or a second CRM, it opens in a new browser tab
- Screen pop is sent to the CRM via the **Channel Provider** configuration — if incorrect, the screen pop fails
- Pinned records created with `screenPop=true` will pop automatically even if other records exist in Related Interactions
- For Multi-CRM (upcoming): each single-match result opens separately if multiple CRM searches are configured

**Limitations:** Cannot screen pop multiple records in Agent Embedded for Kustomer or any agent app integrated with ServiceNow. Only active Salesforce flows can be screen popped. [Frequent Configuration Issues](https://nice-ce-cxone-prod.atlassian.net/wiki/spaces/IN/pages/17593737/Frequent+Configuration+Issues+-+CXone+Agent+Integrated), [WEMDOC-9152](https://nice-ce-cxone-prod.atlassian.net/browse/WEMDOC-9152)

---

## 5. Pinned Records

**Functionality:** The active phone call/interaction is the **Current Interaction** and related interactions populate below based on search results.

- Records created via scripting with `createPayload.pinnedRecord="true"` are moved from "Related Interactions" to "Current Interactions"
- Pinned records are **automatically linked for Data Memorialization** — no manual linking needed
- If `pinnedRecord=false`, created records populate in Related Interactions instead
- For ServiceNow: you can only pin one record per interaction to Current Interactions, and therefore can only relate one record per interaction

---

## 6. Relates To

**Functionality:** Allows agents to link records within the CRM. Currently supported for **ServiceNow, Salesforce, and Microsoft Dynamics**.

**How it works:**
- The Relates To button only appears for pinned records that have `relatesTo="true"` and are valid entity types
- CXA holds a JSON object containing the **relationship map** and field mappings
- On click, a popover shows entities from Related Interactions filtered by the relationship map (only valid relatable entities shown)
- On selecting a record, a **data-memorialization workflow API call** is executed with `action: "relatesTo"`, the entity type, entity ID, and the related object's field name and value
- For **Relates To DM isolation**: the RelatesTo workflow fires during the active call (not at contact end), and is excluded from end-of-call DM payloads

**Limitation:** As of 02/11/2025, for Microsoft Dynamics only Phone Call entities are supported for RelatesTo. [ServiceNow Relate To Docs](https://nice-ce-cxone-prod.atlassian.net/wiki/spaces/IN/pages/910034717/ServiceNow+-+Relate+Created+Record+to+Search+Result+Record+CRM-10702)

---

## 7. Agent Create (Manual Create)

**Functionality:** Allows the agent to manually generate a new CRM record directly from their CXone Agent interface during an active interaction.

- The manual create icon appears next to the Related Interaction label when configured
- Agent selects the record type to create (e.g., Case, Contact, Lead)
- The create workflow fires through the same Lambda → Tray → CRM pipeline
- Created records can be pinned (`pinnedRecord=true`) to Current Interactions or left in Related Interactions
- For Multi-CRM: labels for create options need to be descriptive for which CRM instance the record will be created in
- **Tested by Titans QA (Sarah Castaneda) across CSA releases** — confirmed passing in 25.3 and 25.4 testing cycles [CSA25.4 Agent Experience](https://nice-ce-cxone-prod.atlassian.net/wiki/spaces/csa/pages/3424410089/CSA25.4+Agent+Experience)

**Deep Dive:** In Agent Workspace (Embedded), Agent Create lets an agent click Create New in the Related Interactions section of the customer card and choose the type of CRM record they want to create while handling an interaction. The record is created by the configured system user for that CRM integration, not by the agent identity directly.
For the manual-create setup, the NiCE docs say you modify the Studio script by adding a SNIPPET and a CUSTOMEVENT named Agent Workflow Create Payload. The snippet builds the create configuration, and the custom event passes that configuration into Agent Workspace so the UI can render the create options.
Inside that snippet, you define one or more create payload objects. Each payload includes at least:
- a display label shown to the agent
- a workflowInput object containing the create data
- a configurationId that identifies the CRM configuration in Agent Integrations
- and a workflowId that identifies the CRM workflow to run
The docs then have you put those payloads into a list and send the list as JSON through the custom event. NiCE explicitly documents that if you want agents to be able to create more than one type of record, you include more than one workflow/payload in that same snippet list.

---

## 8. Script Variables

**Functionality:** A more customizable form of data memorialization. Instead of using standard CXone data fields (ANI, contact ID, skill name, etc.), script variables pull **custom values** defined in Studio scripting.

**How it works in DM:**
- In the DM field mapping, if a field uses `scriptVariable`, the Lambda reads the value from `cxoneContact.scriptVariables` in the payload
- Otherwise, it fetches the value of the `cxoneChannelField` from the standard `cxoneContact` model
- This allows customers to write custom IVR-collected data (account numbers, case IDs, customer-provided info) back to the CRM

**Current Limitation:** Script variables **do not currently work with digital chat** — only ACD voice interactions. [AGTINT - Data Memorialization](https://nice-ce-cxone-prod.atlassian.net/wiki/spaces/IN/pages/17291055/AGTINT+-+Data+Memorialization)

---

## 9. Search Types (Standard vs. Dynamic)

**Standard Search:** Uses the default search workflow configured in Agent Integrations. The search payload passes `phoneNumber`, `email`, or `entity` arrays. Results are cached and displayed in Related Interactions.

**Dynamic Search:** Uses **Dynamic Data Mappings** configured in User Hub under Agent Integrations. This allows customers to:
- Customize which data fields are pulled from the CRM and displayed on the Customer Card
- Use a `dynamicDataMappingId` in the Workflow Execute action
- Build complex search filters with entity types and custom field criteria (e.g., `entity: "contact"`, `filter: "status:open is_public:true"`)

**Key difference:** Standard search workflows do not use dynamic data mapping — the search fields are fixed. Dynamic search allows full customization of both the search criteria and the display fields (up to 5 fields configured in Dynamic Data Mappings, max 10 string fields and 3 other types). [Dynamic Data End to End Flow](https://nice-ce-cxone-prod.atlassian.net/wiki/spaces/IN/pages/180520839/Dynamic+Data+End+to+End+Flow), [Dynamic Data - Studio Configuration](https://nice-ce-cxone-prod.atlassian.net/wiki/spaces/IN/pages/317359512/Dynamic+Data+-+Studio+Configuration)

**Selection Rules:** In the Agent Workflow Configuration editor, only one search workflow can be selected at a time. Selecting a Dynamic Data workflow removes the default Search selection and vice versa.

---

## 10. Dynamic Data

**Functionality:** Displays CRM record data to agents in the Customer Card workspace during an active interaction. Configured via Dynamic Data Mappings in User Hub.

- **Tip:** Dynamic Data shows what fields the Customer can **view**; Data Memorialization shows what fields the Customer can **edit**
- Limit of up to **5 fields** per mapping (10 string fields, 3 other types max)
- Only fields populated with data are displayed
- **Tested by Titans QA** — confirmed passing across releases [CSA25.3](https://nice-ce-cxone-prod.atlassian.net/wiki/spaces/csa/pages/3424405627/CSA25.3+Agent+Experience)

---

## 11. Lambda Architecture (Component Map)

The Titans features are powered by the `lambda-ipaas-workflow-integration` Node.js 22 codebase, deployed via AWS CloudFormation. Four Lambda functions exist:

| Lambda | Role |
|---|---|
| `workflowIntegration/app.js` | Config CRUD, auth, integration types, data mappings, dynamic data, entities |
| `workflowExecution/app.js` | Single workflow execution (`executeWorkflow_v23.1`), Redis cache read/write |
| `enhancedWorkflowExecution/app.js` | Multi-config fan-out — iterates `workflowInput.configs[]` |
| `digitalTranscript/app.js` | SQS trigger, DFO transcript fetch + data memorialization |

**Shared Modules:** `helpers/` (awsHelper, dbHelper, cacheManager, trayIoHelper, redisHelper, errorHandler), `featureToggles/` (30-min cache, cross-account STS), workflow execution events/helpers/constants.

**External Dependencies:**
- **DynamoDB** (`ipaas-workflow-integrations`) — persistent config storage
- **ElastiCache Redis** (interaction cache, TTL 2 days)
- **Tray.io** (GraphQL endpoints — US/EMEA/APAC regional)
- **Secrets Manager** (master tokens, CSRF)
- **WFO Account Lambda** (feature toggle tokens)

[JS Lambdas Architecture](https://nice-ce-cxone-prod.atlassian.net/wiki/spaces/IN/pages/3678110836/JS+Lambdas)



## Summary of Titans-Owned Features (Validated via CSA Testing)

| Feature | Description | Titans QA Owner |
|---|---|---|
| Data Memorialization | Write CXone data to CRM at contact end | Sarah Castaneda |
| Dynamic Data | Display CRM fields on Customer Card | Sarah Castaneda |
| Screen Pop on Create Workflows | Pop created records in CRM | Sarah Castaneda |
| Relates To (SNOW) | Link records within ServiceNow | Sarah Castaneda |
| Agent Create | Manual record creation during interaction | Sarah Castaneda |
| Workflow Execute (Studio) | Studio action editor changes | Sarah Castaneda |
| Agent Workflow Configuration (Studio) | Studio action editor changes | Sarah Castaneda |


Sources:

1. https://nice-ce-cxone-prod.atlassian.net/wiki/spaces/IN/pages/808583256/Integrations+Team+CXone+Agent+-+Agent+Integrations+-+Common+Problems

2. https://nice-ce-cxone-prod.atlassian.net/wiki/spaces/IN/pages/910034717/ServiceNow+-+Relate+Created+Record+to+Search+Result+Record+CRM-10702

3. https://nice-ce-cxone-prod.atlassian.net/wiki/spaces/IN/pages/808452097/Integrations+Team+CXone+Agent+-+Agent+Integrations+-+Triage+Troubleshooting

4. https://nice-ce-cxone-prod.atlassian.net/wiki/spaces/csa/pages/3424410089/CSA25.4+Agent+Experience

5. https://nice-ce-cxone-prod.atlassian.net/browse/CXIFW-857

6. https://nice-ce-cxone-prod.atlassian.net/wiki/spaces/IN/pages/17593737/Frequent+Configuration+Issues+-+CXone+Agent+Integrated

7. https://nice-ce-cxone-prod.atlassian.net/wiki/spaces/IN/pages/3678110836/JS+Lambdas

8. https://nice-ce-cxone-prod.atlassian.net/wiki/spaces/IN/pages/483622913/Transfer+Contact+End+to+End+Data+Flow

9. https://nice-ce-cxone-prod.atlassian.net/wiki/spaces/IN/pages/17291055/AGTINT+-+Data+Memorialization

10. https://nice-ce-cxone-prod.atlassian.net/browse/CRM-25185

11. https://nice-ce-cxone-prod.atlassian.net/browse/CRM-25086

12. https://nice-ce-cxone-prod.atlassian.net/wiki/spaces/IN/pages/180520839/Dynamic+Data+End+to+End+Flow

13. https://nice-ce-cxone-prod.atlassian.net/wiki/spaces/csa/pages/3424405627/CSA25.3+Agent+Experience

14. https://nice-ce-cxone-prod.atlassian.net/wiki/spaces/IN/pages/317359512/Dynamic+Data+-+Studio+Configuration

15. https://nice-ce-cxone-prod.atlassian.net/browse/WEMDOC-9152