# Titans / Agent Integrations — Architecture & Data-Flow Deep Dive

> Companion to `titans-features.instructions.md`. That file explains **what** the features do.
> This file explains **how the systems wire together and how payloads travel** end-to-end.
> Written for someone new to the codebase who already understands the features.

---

## 0. TL;DR — the one-paragraph mental model

A CXone interaction (voice or digital) triggers a **CXone Studio** script or the **CXone Agent** UI. Both talk to the **C# Monolith** (`VCSvc` / `ProviderData`), which is the *only* public API layer. The Monolith authenticates the request and **directly invokes a Node.js Lambda** (`AWS.Lambda.invoke()` — **there is no API Gateway**). The Lambda reads tenant config from **DynamoDB**, builds a CRM-shaped payload, and calls a **Tray.io** workflow (REST for execution, GraphQL for config). Tray.io performs the actual CRM operation (Salesforce / ServiceNow / MS Dynamics / Zendesk / etc.) and the results are written into an **ElastiCache Redis** interaction cache keyed by `cacheKey`. The agent's **Customer Card** (a React app in `webapp-acd-agent-apps`) then reads that cache (and/or receives `AGENT_WORKFLOW_*` WebSocket events) to render Related/Current Interactions, screen pops, dynamic data, etc.

```
Studio / CXA ──► C# Monolith ──(Lambda.invoke, NO API GW)──► Node Lambda ──► Tray.io ──► CRM
                     ▲                                            │  ▲            │
                     │                                            ▼  │            ▼
                 Agent reads ◄──── Redis interaction cache ◄── setInteractionCacheData (callback)
                 GET .../interaction/{cacheKey}                 (lpush + 2-day TTL)
```

---

## 1. The five systems (and which repo is which)

This is the single most important orientation fact for a newcomer, because the repo names are **not** self-explanatory.

| # | System | Repo | Stack | Owned by | Role |
|---|--------|------|-------|----------|------|
| 1 | **CXone Studio** | (platform) | Studio scripting | Platform | IVR script captures interaction data; fires `Workflow Execute` + `Agent Workflow Configuration` actions |
| 2 | **Agent Desktop / Customer Card** | `webapp-acd-agent-apps` | React 17 · Nx · Redux | Dark Knights | The agent-facing Customer Card UI (screen pop, relates-to, pin, DM trigger) |
| 3 | **Config Admin MFE** | **`cxone-webapp-agent-integration`** | Angular 17 · NgRx | **Titans** | Admin UI to create/manage CRM integration configs, data mappings, dynamic data |
| 4 | **C# Monolith** | (inContact `VCSvc`/`ProviderData`) | C# .NET 4.8 | All teams | Central API gateway: auth, routing, **Lambda invocation** |
| 5 | **iPaaS Lambdas** | **`lambda-ipaas-workflow-integration`** | Node.js 22 | **Titans** | Orchestrator: config CRUD, workflow execution, Redis cache, transcript |

> ⚠️ **Common newcomer trap:** `cxone-webapp-agent-integration` (Angular) is the **admin/config MFE**, *not* the agent's Customer Card. The Customer Card the agent actually sees during a call lives in the React `webapp-acd-agent-apps` repo (Dark Knights). Titans owns the **config admin UI** and the **backend Lambda**; the agent runtime UI is consumed cross-team.

Plus the supporting cast:

| Infra | What | Notes |
|-------|------|-------|
| **DynamoDB** (`ipaas-workflow-integrations`) | Tenant config store | configurations, data mappings, dynamic-data mappings, audits |
| **ElastiCache Redis** | Interaction cache | Stores per-interaction CRM results; **stored as a Redis LIST**; TTL 2 days |
| **Tray.io** (a.k.a. Tray.ai) | iPaaS workflow engine | REST (execution) + GraphQL (config); regional AMER/EMEA/APAC; OAuth 2.0 to CRMs |
| **SQS** (`ipaas-digital-transcript-queue`) | Async digital DM | Triggers the `digitalTranscript` Lambda |
| **Secrets Manager** | Tray master tokens, CSRF | per-region master tokens |
| **WFO Account Lambda** | Feature-toggle tokens | reached via cross-account STS AssumeRole |

📖 Confluence: [Agent Integrations — Architecture](https://nice-ce-cxone-prod.atlassian.net/wiki/spaces/IN/pages/3678339994) · [System Map](https://nice-ce-cxone-prod.atlassian.net/wiki/spaces/IN/pages/3677586871) · [iPaaS / Workflow Integration Architecture](https://nice-ce-cxone-prod.atlassian.net/wiki/spaces/IN/pages/3673063772)

---

## 2. Key architectural decisions (memorize these)

| Decision | What | Why it matters for you |
|----------|------|------------------------|
| **No API Gateway** | Monolith calls Lambda via `AWS.Lambda.invoke()` | Lambda is never publicly exposed; auth is the Monolith's job. You won't find REST routes in the Lambda — it routes on an `event.key` field. |
| **`event.key` routing** | One Lambda handles many operations, dispatched by `event.key` | e.g. `executeWorkflow_v23.1`, `setInteractionCacheData`, `getInteractionCacheData`. |
| **Redis as a LIST** | Interaction state stored via `lpush` (not String/Hash) | Tray can write multiple times; `lrange 0 -1` returns all, `[0]` is newest. |
| **Multi-region Tray** | AMER / EMEA / APAC endpoints chosen per config | Region is **immutable** after config creation — wrong region = recreate config. |
| **Module Federation** | Agent shell loads Config Admin MFE at runtime; cross-team comms via ~18 typed `CustomEvent`s | Teams ship independently; version drift (v26–v34) is a real risk. |
| **v1 (IVR) vs v2 (API)** | Two execution code paths in the Lambda | v1 = Studio/IVR (`requestor: "ivr"`, keyed on `actionType`); v2 = CX Agent (`requestor: "api"`, keyed on `action`). |

---

## 3. Key identifiers (the glossary you'll keep returning to)

| Field | Meaning | Format / example |
|-------|---------|------------------|
| `interactionId` | One customer interaction | UUID `43fd078e-c74b-42d4-89b7-0de6625d5bc5` |
| `contactId` | CXone contact | 64-bit number `987654` |
| `tenantId` | Tenant / business unit | GUID; also the Redis key **prefix** |
| `cacheKey` | Redis key base | typically `tenantId_interactionId` |
| `configurationId` | A CRM integration config | UUID (DynamoDB SK suffix) — selected in the Action Editor |
| `workflowId` | A Tray.io workflow | UUID, region-specific |
| `dataMappingId` | A Data Memorialization field-mapping set | UUID — selected in the Action Editor |
| `dynamicDataMappingId` | A Dynamic Data field-mapping set | UUID — present only for Dynamic Data search |
| `instanceId` | Tray **solution instance** id | per-config, used to fetch workflow trigger URLs |
| `event.key` | Lambda dispatch key | `executeWorkflow_v23.1`, `setInteractionCacheData`, `getInteractionCacheData` |
| `action` (v2) | Workflow action | `Search` · `Create` · `Timeline` · `DataMemorialization` · `relatesTo` |
| `actionType` (v1) | Studio/IVR action | `Search` · `Create` · `DynamicData` |
| `requestor` | Caller origin | `api` (CX Agent) or `ivr` (Studio) |

The 3 Redis sub-keys (the heart of the cache):

| Key pattern | Holds | Surfaces as |
|-------------|-------|-------------|
| `{cacheKey}` | search results (records[]) | **Related Interactions** |
| `{cacheKey}_pin` | pinned/created records | **Current Interactions** (auto-linked for DM) |
| `{cacheKey}_workflow` | `AgentWorkflowConfiguration` JSON | tells the system which workflows to run at contact end |

📖 Confluence: [Transfer Contact End to End Data Flow](https://nice-ce-cxone-prod.atlassian.net/wiki/spaces/IN/pages/483622913) (the cache truth table + payloads live here).

---

## 4. The end-to-end payload journey (hop by hop, with real shapes)

This is the spine of the whole system. Follow a single "Search at call arrival" then a "Data Memorialization at call end".

### Hop 1 — Studio (or CXA) → C# Monolith

For voice/IVR, a Studio script runs the **Workflow Execute** action. The Monolith's `AdminActions.cs` receives an `[ActionHandler]` named **`AGTINT_WRKFLO_EXE_IMP`** (or `AGTINT_ENH_WRKFLO_EXE_IMP` for the enhanced/multi-config variant). The Monolith first checks `HasAgentIntegrationEnabled` (a BusinessUnit cache); if the tenant isn't enabled it returns `NotConfigured` and **never calls the Lambda**.

For the CX Agent UI, the request is REST:

```
POST /services/v27.0/agent-integration/configuration/{configurationId}/workflow/{workflowId}
```

The body the **Agent → API** sends:

```jsonc
{
  "action": "DataMemorialization",   // Search | Timeline | Create | DataMemorialization | relatesTo
  "contactID": "",                   // optional, server-side logging
  "interactionId": "",               // optional, server-side logging
  "cxoneContact": { /* CXoneContactModel */ }, // required for Timeline/DM
  "integration": [ { "entity": "", "entityId": "" } ], // required for Timeline/DM
  "dataMappingId": "",               // required for DM
  "workflowInput": {                 // passed straight through to Search/Create
    "phoneNumber": "", "email": "", "entities": [""]
  }
}
```

Monolith proxy classes (in `API/`): `AgentIntegrationProxy` (execute + config CRUD), `AgentIntegrationCacheProxy` (interaction cache), `DataMemorializationProxy`, `DynamicDataProxy`, `EnhancedCustomerCardProxy`, `EnhancedWorkflowExecuteProxy`. All funnel into `AgentIntegration.GetIpaasLambdaResponse` which builds the `AWSLambdaCriteria` and calls `Lambda.Invoke`.

📖 Confluence: [C# Monolith](https://nice-ce-cxone-prod.atlassian.net/wiki/spaces/IN/pages/3680174467) · [AGTINT - Data Memorialization](https://nice-ce-cxone-prod.atlassian.net/wiki/spaces/IN/pages/17291055)

### Hop 2 — Monolith → Lambda (`AWS.Lambda.invoke()`, no API Gateway)

The Monolith wraps the agent payload inside a Lambda event. **This is the canonical invoke shape:**

```jsonc
{
  "key": "executeWorkflow_v23.1",
  "tenantId": "<tenant_guid>",
  "userId": "<user_guid>",
  "configurationId": "<configuration_guid>",
  "workflowId": "<workflow_guid>",
  "payload": {
    "action": "DataMemorialization",
    "contactID": "",
    "interactionId": "",
    "cxoneContact": { /* CXoneContactModel */ },
    "integration": [ { "entity": "", "entityId": "" } ],
    "dataMappingId": "",
    "workflowInput": { /* search/create fields */ },
    "requestor": "api"        // "api" (CXA) or "ivr" (Studio) — auto-set
  }
}
```

The Lambda functions the Monolith can invoke (one Lambda per concern):

| Lambda alias | Function | Purpose |
|--------------|----------|---------|
| `IpaasWorkflowIntegration_*` | `workflowIntegration/app.js` | config CRUD, auth, integration types, data mappings, dynamic data, entities |
| `IpaasWorkflowExecution_*` | `workflowExecution/app.js` | single workflow execution + Redis cache read/write |
| `IpaasEnhancedWorkflowExecution_*` | `enhancedWorkflowExecution/app.js` | multi-config fan-out over `workflowInput.configs[]` |
| `IpaasEnhancedCustomerCardExecution_*` | `digitalTranscript/app.js` | SQS-triggered DFO transcript + DM |

### Hop 3 — Lambda entry → dispatch on `event.key`

`lambda/workflowExecution/app.js` is the handler. Before anything else it does a **feature-toggle check** (`Utility-crm-traythrottlingfix-CRM-24904`) to pick between the legacy and connection-reuse cache helpers (see §13), then calls `appService.processRequest`. Dispatch is dead simple (`workflowExecution/appService.js`):

```javascript
if (event?.key === 'executeWorkflow_v23.1') {
    return await events.workflowExecution_V2(event, dbHelper, cacheManager, /* ... */);
}
if (event.key === 'setInteractionCacheData') { return cacheEvents.setInteractionCacheData(event, elastiCacheHelper, redisHelper); }
if (event.key === 'getInteractionCacheData') { return cacheEvents.getInteractionCacheData(event, elastiCacheHelper, redisHelper); }
// fallback: legacy v1 path
return await workflowExecutionHelper.workflowExecution(event, /* ... */);
```

The handler always returns the Monolith-friendly envelope:

```javascript
const done = (statusCode, data, err) => callback(null, {
    StatusCode: statusCode,
    Payload: data ? JSON.stringify(data) : null,
    Error: err ? JSON.stringify(err) : null,
});
```

### Hop 4 — v2 action dispatch

`workflowExecution_V2` routes on `payload.action` to one of the handlers in `lambda/workflowExecutionEvents/V2/`:

```
searchWorkflow.js · createWorkflow.js · timelineWorkflow.js
dataMemorializationWorkflow.js · relatesToWorkflow.js · triggerWorkflow.js
```

Each handler lifts fields off `event.payload` and (for most) delegates to the shared `workflowExecutionHelpers/workflowExecutionHelper.js`, which resolves the Tray **workflow trigger URL** (via DynamoDB config + Tray solution instance), executes it, and caches results. Example (`searchWorkflow.js`):

```javascript
event.cacheKey = event.payload?.cacheKey;
event.contactId = event.payload?.contactID;
event.dynamicDataMappingId = event.payload?.dynamicDataMappingId;
event.workflowInput = event.payload?.workflowInput || {};
return workflowExecutionHelper.workflowExecution(event, /* ...helpers... */);
```

### Hop 5 — Lambda → Tray.io

Two distinct Tray channels live in `lambda/helpers/trayIoHelper.js` (and the newer `trayHelperNew.js`):

- **Workflow execution = REST POST** to a per-workflow `triggerUrl`, authenticated with an `X-Csrf-Token` header:

  ```javascript
  getWorkflowResponse = async (url, token, query) => {
      await axios.post(url, query, {
          headers: { 'Content-Type': 'application/json', 'X-Csrf-Token': token },
      });
  };
  ```

- **Config operations = GraphQL** to a regional endpoint, authenticated with a bearer token:

  ```javascript
  getGraphqlData = async (method, token, query, variables) => {
      await axios.post(this.endpointUrl, { query: print(query), variables },
          { headers: { authorization: token } });
  };
  ```

Region selection is per-config and immutable:

```javascript
case 'EMEA': this.endpointUrl = process.env.emeaTrayEndPoint; this.masterTokenName = process.env.emeaTrayMasterTokenName; break;
case 'APAC': this.endpointUrl = process.env.apacTrayEndPoint; this.masterTokenName = process.env.apacTrayMasterTokenName; break;
case 'AMER': default: this.endpointUrl = process.env.trayEndPoint; this.masterTokenName = process.env.trayMasterTokenName;
```

Auth chain: master token (per region) comes from **Secrets Manager**; a per-tenant **user access token** is obtained via the `authorize` GraphQL mutation and **cached** (≈23h). `getWorkflows()` reads each workflow's `triggerUrl` from the Tray **solution instance** (`instanceId`).

The Lambda→Tray **body** depends on the action (note these are *different* from the API-layer payload — the Lambda transforms first):

```jsonc
// Search
{ "requestor": "ivr", "phoneNumber": "", "email": "", "entity": ["..."] }

// Timeline (one call per integration record)
{ "requestor": "ivr", "cxoneContact": { /* model */ }, "integration": { "entity": "", "entityId": "" } }

// Data Memorialization (one call for all mapped entities)
{
  "requestor": "ivr",
  "entities": [
    { "entity": "", "entityId": "",
      "entityFields": [ { "name": "", "value": "", "type": "standard" } ] }
  ]
}
```

### Hop 6 — Tray.io → CRM → back to Redis

Tray executes the CRM operation over OAuth 2.0 (Salesforce/Zendesk/HubSpot/Dynamics-OAuth) or credentials (ServiceNow/Oracle/Dynamics). When results come back, they are written into Redis via a **callback** Lambda invoke `setInteractionCacheData` (so the agent can poll them). The standard record shape stored/returned:

```jsonc
{
  "result": [
    {
      "system": { "type": "msd", "label": "MSD", "icon": "", "baseUrl": "https://...dynamics.com" },
      "records": [
        { "display": "Tyler Test", "id": "2e92...d17d", "label": "Contact",
          "type": "contact", "linkable": true, "url": "/main.aspx?...", "related": [], "fields": [] }
      ]
    }
  ]
}
```

### Hop 7 — Redis interaction cache (the LIST model)

`lambda/helpers/elastiCacheHelper.js` is tiny and worth knowing by heart:

```javascript
setElasticache = async (key, payload, redisHelper) => {
    const redis = await redisHelper.getRedis();
    const result = await redis.lpush(key, JSON.stringify(payload));   // LIST push (newest first)
    await redis.expire(key, process.env.workFlowExecutionCacheTTL);    // 2 days
    redis.quit();
    return result;
};

getElasticache = async (key, redisHelper, types) => {
    // types = "default|pin|workflow"; formulateQueryKeys -> {cacheKey}, {cacheKey}_pin, {cacheKey}_workflow
    const values = await redis.lrange(key, 0, -1);  // read whole list
};

keepCacheAlive = async (key, redisHelper) => {
    await redis.expire(key, process.env.workFlowExecutionCacheTTL);   // KeepAlive => refresh TTL
};
```

The Monolith exposes this to clients as:

```
GET  /services/v30.0/agent-integration/workflow-execution/interaction/{cacheKey}?types=default,pin,workflow
POST /services/v30.0/agent-integration/workflow-execution/interaction/{cacheKey}   // set or { "keepAlive": true }
```

A GET response merges the three sub-keys into `result[]` (with `records` + `pinRecords`) and `agentWorkflowConfiguration[]`. See the **truth table** on the Transfer Contact page for which `types` combinations return what.

> **TTL history:** originally 15 min, raised to **2 days in 24.4**. Before that, a contact queued >15 min lost its related interactions until the agent hit "refresh".

> **Redis → Valkey migration (CRM-24300):** ElastiCache is migrating from Redis to **Valkey 8.0** (Valkey is the open-source fork of Redis — same commands, same behavior). This is an **infrastructure-only** change: application code is untouched (`cacheManager.js` unchanged, `ioredis` supports Valkey natively), so every `lpush`/`lrange`/`expire` in this section works identically. Rollout is phased per-region with a rollback path, so read "Redis" here as "Redis/Valkey — the fast in-memory cache." See `VALKEY_MIGRATION_FIXES.md` in the lambda repo.

### Hop 8 — Back to the agent: the event ingress pipeline

The agent UI gets data two ways: (a) it **polls** the cache via the GET above, and (b) it receives **`AGENT_WORKFLOW_*` events** pushed over the UI-Queue WebSocket. The carrier pipeline (in `webapp-acd-agent-apps`):

```
Backend ──► UI Queue WebSocket (ui-queue-ws-provider.ts)  [primary]
        └─► HTTP poller (get-next-event-provider.ts)      [fallback]
                      │
                      ▼
        cxone-get-next-adapter.ts   (switch on event.Type)
                      │  routes to RxJS Subjects on ACDSessionManager
                      ▼
        ccf-contact-assignment.tsx  ──► CXoneAgentIntegrationTransformer.normalize()
                      │
                      ▼
        Redux dispatch: setActivityInformation / storeCustomEventFlag
                      ▼
        CcfCustomerCardSlice reducer ──► CcfCustomerCard re-renders
```

The four event types the adapter disambiguates:

| `eventName` / type | Subject | Notes |
|--------------------|---------|-------|
| `AgentWorkflowResponse` (CustomEvent) | `agentWorkflowEvent` | search/exec results |
| `AgentWorkflowRequest` (CustomEvent) | `agentWorkflowRequestEvent` | request to run a workflow |
| `AgentWorkflowConfiguration` (top-level, **not** CustomEvent-wrapped) | `agentWorkflowRequestEvent` (shared) | disambiguated by `eventName` |
| `AgentWorkflowCreatePayload` (CustomEvent) | `agentWorkflowCreatePayloadEvent` | **raw string, not parsed** by the adapter |

When the contact ends (digital `CASE_INBOX_UNASSIGNED` or voice `DISCONNECTED`), `acdSessionEventMiddleware` performs **cleanup only** (it does not translate workflow events) — clearing per-contact LocalStorage keys like `AGENT_WORKFLOW_EVENT`, `CRM_PIN_RECORDS`, `CC_LINKED_ACTIVITIES`.

📖 Confluence: [Studio Execution Flow](https://nice-ce-cxone-prod.atlassian.net/wiki/spaces/IN/pages/3676931980) · [Event Ingress Flow](https://nice-ce-cxone-prod.atlassian.net/wiki/spaces/IN/pages/3676932001)

---

## 5. The CXone Contact Model (the canonical data object)

`cxoneContact` is the payload that carries *interaction* data into Timeline and Data Memorialization. There is a variant per media type. The voice shape (most common):

```jsonc
{
  "interactionId": "GUID",
  "contactId": "64-bit number",
  "direction": "Inbound | Outbound",
  "mediaType": "PhoneCall",
  "agentId": "CXone user UUID",
  "agentName": "Agent Name",
  "skillId": "GUID/number", "skillName": "Queue/Skill",
  "startTime": "ISO-8601", "endTime": "ISO-8601",
  "dispositionName": "optional", "dispositionNotes": "optional",
  "status": "CXone contact status", "finalState": true,
  "masterContactId": 123, "contactType": "Regular | Consult | ...",
  "ani": "inbound number", "dnis": "outbound number",
  "recordingUrl": "call/screen recording url",
  "tags": ["..."],
  "scriptVariables": { "key": "value" }   // ← published from Studio (powers Script Variables DM)
}
```

Digital swaps in `channelType`, `channelName`, `from`/`to`, `eventType`, `customerName`, and uses `recordingUrl` as the **transcript** link. There are also VoiceMail and WorkItem variants (with `fileName`/`fileDuration` and `workItemId`/`workItemType`/`workItemPayload` respectively).

The companion **Integration Record Model** (what the agent linked):

```jsonc
{ "entity": "Case | Incident | contact | phonecall ...", "entityId": "crm-record-id" }
```

📖 Source of truth in code: `lambda/constants/CXone.js` (Lambda) and `libs/shared/apps-lib/.../cxone-voice-contact-data.ts` (Agent).

---

## 6. Data Memorialization — the transform algorithm (the crown jewel)

DM is the most complex transform. It lives in `lambda/workflowExecutionEvents/V2/dataMemorializationWorkflow.js`. The algorithm:

1. **Validate** the payload — `integration` must be a non-empty array, `cxoneContact` non-empty, `dataMappingId` present (else **400**).
2. **Resolve** the Tray DM workflow trigger URL (and a separate `DiscoverFields` workflow URL for digital transcript).
3. **Load** the mapping entities for `dataMappingId` from DynamoDB (`dbHelper.dataMappings.getDataMappingEntitiesByDataMappingId`).
4. For each **mapping entity**, find the matching record(s) in `integration[]` (case-insensitive `entity` match). No match → record a soft error (becomes a 206, not a 400).
5. **Filter fields by media type**: voice keeps `voiceCallContact` fields, digital keeps `digitalContact` fields, and **`scriptVariable` fields are always kept**. `transcriptText` (digital) is split out and handled asynchronously via SQS.
6. **Source each field's value** — the core rule:

   ```javascript
   const isScriptVariable = cxoneChannel === CXONE.SCRIPT_VARIABLE.name;
   const contactField = isScriptVariable
       ? cxoneContact.scriptVariables[cxoneChannelField]   // custom Studio value
       : cxoneContact[cxoneChannelField];                  // standard contact field
   entityFields.push({ name: crmEntityField, value: contactField });
   ```

   If a mapped field can't be sourced from the payload, it's collected as an error and `countOfMappingsUnableToSourceInteractionData++`.
7. **Assemble** `entities[] = { entity, entityId, entityFields[] }`. `relatesTo` related-objects (validated by a Joi schema) are appended as extra fields.
8. **Digital transcript**: if any `transcriptText` mappings exist on a digital contact, push a job to **SQS** (`awsHelper.sendMessageToSQS({ message: { tenantId, caseId, DMworkflowTriggerUrl, discoverFieldsWorkflow, configurationId, entities, instanceId } })`).
9. **Execute** — region-aware Tray call with the assembled body:

   ```javascript
   const regionHelper = TrayIoHelper.getInstance(configuration.region || 'AMER');
   const trayResponse = await regionHelper.getWorkflowResponse(
       workflowTriggerUrl, csrfToken,
       { requestor, entities, contactId: event?.payload?.contactID }
   );
   ```
10. **Result mapping**: all fields sourced → **200** with `result`; some fields unsourced → **206 Partial Success** with `result` + `errors[]`; nothing mappable → **400**.

> Why you care for testing: the matrix of (media type) × (field type: standard/scriptVariable/transcriptText) × (entity matched/unmatched) is exactly where DM bugs hide. Script Variables **do not work with digital chat today** (voice ACD only).

📖 Confluence: [AGTINT - Data Memorialization](https://nice-ce-cxone-prod.atlassian.net/wiki/spaces/IN/pages/17291055)

---

## 7. Per-feature payload traces (feature → code → real payload)

Real payload examples below come from the automation suites in `cxone-crm-integration-automation` (the clearest source of *actual* request bodies).

### 7.1 Search

```
POST /services/v27.0/agent-integration/configuration/{configId}/workflow/{workflowId}
{ "action": "Search", "contactID": "3341888", "workflowInput": { "phoneNumber": "+919970393189" } }
```
Custom search uses `workflowInput.search` (single object or array of `{ entity, filter }`). Lambda → Tray search body becomes `{ requestor, phoneNumber|email, entity[] }`. Results cached under `{cacheKey}` → Related Interactions.

### 7.2 Create (Agent Create / manual create)

CRM-specific bodies (note how the `workflowInput` differs per CRM):

```jsonc
// ServiceNow
{ "action": "Create", "workflowInput": { "tablename": "sn_customerservice_case",
  "pinnedRecord": "true", "cacheResponse": "true",
  "data": [ { "name": "short_description", "value": "Test" } ] } }

// Salesforce
{ "action": "Create", "workflowInput": { "entity": "Case",
  "data": [ { "key": "lastName", "value": "Heiner" }, { "key": "status", "value": "open" } ],
  "pinnedRecord": "true", "cacheResponse": "true" } }

// Zendesk / HubSpot
{ "action": "Create", "workflowInput": { "table": "tickets",
  "data": { "ticket": { "subject": "...", "priority": "normal", "custom_fields": [ ... ] } },
  "pinnedRecord": "true", "cacheResponse": "true" } }
```

Key flags inside `workflowInput`:
- `pinnedRecord: "true"` → record goes to **Current Interactions** and is **auto-linked for DM**.
- `cacheResponse: "false"` → record is created in the CRM but **hidden** from the agent (background-only).
- `screenPop: "true"` → pop the created record in the CRM.

### 7.3 Screen Pop

Driven by `screenPop: "true"` in Create/Search workflow input, and by single-match search results. The CRM is told via the **Channel Provider** config. In the Config Admin MFE, `src/services/config-window/config-window.service.ts` manages `window.open` + `postMessage` for Tray config popups (`tray.configPopup.*`), which is a *different* popup mechanism (admin config, not agent screen pop) — don't conflate them.

### 7.4 Pinned records

Cache reflects the split: `records[]` (Related) vs `pinRecords[]` (Current). In the Config Admin store (`src/store/agentIntegrations/state/index.ts`), `cxoneEntities` = Related, `crmEntities` = Current.

### 7.5 Relates To

```jsonc
{ "action": "relatesTo", "entity": "sn_customerservice_case", "entityId": "12345",
  "relatedObject": { "name": "account", "value": "67890" } }
```
Fires **during the active call** (not at contact end) and is excluded from end-of-call DM. Supported for ServiceNow, Salesforce, MS Dynamics.

### 7.6 Timeline

```jsonc
{ "action": "Timeline",
  "integration": [ { "relatedObjectType": "Incident", "relatedObjectId": "7412", "makePrivate": false } ],
  "cxoneContact": { /* model */ } }
```
Lambda iterates `integration[]` and calls the Tray timeline workflow **once per record**.

### 7.7 Data Memorialization

```jsonc
{ "action": "DataMemorialization",
  "integration": [ { "entity": "customer_contact", "entityId": "entity-id-789" } ],
  "dataMappingId": "mapping-uuid-456",
  "cxoneContact": { /* model, incl. scriptVariables */ } }
```

### 7.8 Dynamic Data vs Standard Search

Dynamic Data adds `dynamicDataMappingId` to the search. The Lambda then returns **only the configured fields** for matched entities (Dynamic Data shows what the agent can *view*; DM controls what the agent can *edit*). The Agent Workflow Configuration's `searchWorkflow` carries `workflowParam.dynamicDataMappingId`; only one search workflow (standard *or* dynamic) can be selected at a time.

📖 Confluence: [Dynamic Data End to End Flow](https://nice-ce-cxone-prod.atlassian.net/wiki/spaces/IN/pages/180520839) · [Dynamic Data - Studio Configuration](https://nice-ce-cxone-prod.atlassian.net/wiki/spaces/IN/pages/317359512)

---

## 8. The Agent Workflow Configuration object

This is what Studio's **Agent Workflow Configuration** action publishes; it's cached under `{cacheKey}_workflow` and tells the system which workflows to run (especially at contact end for DM):

```jsonc
{
  "type": "AgentWorkflowConfiguration",
  "interactionId": "377e7072-...",
  "contactId": "477725514935",
  "searchWorkflow": [[ { "configurationId": "...", "workflowId": "...", "cacheKey": "..." } ]],
  "timelineWorkflow": [[ { "configurationId": "...", "workflowId": "..." } ]],
  "dataMemorializationWorkflow": [[
    { "configurationId": "...", "workflowId": "...",
      "workflowParam": { "dataMappingId": "54460702-..." } } ]]
}
```

At contact end the DM Lambda reads `{cacheKey}_workflow` to find the DM `workflowId` + `dataMappingId`, reads `{cacheKey}` + `{cacheKey}_pin` to find the linked/pinned entities, then runs DM.

---

## 9. Digital channels — the async SQS flow

Digital DM (and transcript writing) is asynchronous so it doesn't block contact handling:

1. DM handler detects `transcriptText` mappings on a `mediaType === 'digital'` contact → pushes a job to **`ipaas-digital-transcript-queue`** (`awsHelper.sendMessageToSQS`).
2. The **`digitalTranscript`** Lambda (`EventSourceMapping`, BatchSize 1) consumes it.
3. It fetches the DFO transcript: `GET /dfo/3.0/contacts/{caseId}/messages`, formats `Agent:`/`Customer:` lines into one conversation string.
4. It populates every `entityField.value` with the transcript text and runs the DM Tray workflow.

```javascript
// digitalTranscript/events/getTranscript.js (essence)
for (const record of event.Records) {
    const { message } = JSON.parse(record.body);
    const transcription = await fetchTranscription('get', dfoUrl + `/dfo/3.0/contacts/${caseId}/messages`, token, tenantId);
    transcription.body.forEach(m => conversation +=
        `${ts} ${m.isMadeByUser ? 'Agent' : 'Customer'}: ${m.messageContent.text}\n`);
}
```

📖 Confluence: [JS Lambdas](https://nice-ce-cxone-prod.atlassian.net/wiki/spaces/IN/pages/3678110836)

---

## 10. v1 (IVR) vs v2 (API) — the two execution paths

The Lambda supports two callers with subtly different inputs (this trips up many people):

| | **v1 — Studio / IVR** | **v2 — CX Agent / API** |
|--|----------------------|-------------------------|
| Caller | CXone Studio script | CX Agent web app (via Monolith REST) |
| `requestor` | `"ivr"` | `"api"` |
| Keyed on | `actionType` (Create, Search, DynamicData) | `action` (Create, Search, Timeline, DataMemorialization, relatesTo) |
| Action known... | only **after** the workflow is fetched from Tray | up-front in the payload |
| Tray body | identical to v2 **except** `requestor: "ivr"` | `requestor: "api"` |

v1 IVR search invoke (note: top-level `dynamicDataMappingId`, `workflowInput` may be a JSON string):

```jsonc
{ "tenantId": "...", "integrationId": "...", "workflowId": "...", "interactionId": "...",
  "actionType": "DynamicData", "dynamicDataMappingId": "...",
  "workflowInput": { "search": { "entity": "contact", "filter": "status:open is_public:true" } } }
```

---

## 11. Multi-config / Enhanced execution

`enhancedWorkflowExecution/app.js` handles the **Multi-CRM** fan-out. It iterates `workflowInput.configs[]`, runs each config's workflow, and **isolates per-config errors** so one CRM's failure can't block the others:

```javascript
for (let i = 0; i < workFlowInput.configs.length; i++) {
    try { responseFromWorkflow.push(await appService.processRequest(/* ... per-config payload ... */)); }
    catch (error) { responseFromWorkflow.push({ statusCode: error.statusCode || 500, error: error.message }); }
}
done(HTTP_STATUS_CODES.OK, responseFromWorkflow, null);   // always 200, mixed results inside
```

Monolith side: `AGTINT_ENH_WRKFLO_EXE_IMP` / `EnhancedWorkflowExecuteProxy` / `EnhancedCustomerCardProxy`.

---

## 12. DynamoDB config model (`ipaas-workflow-integrations`)

Single-table design. Configurations, data mappings, dynamic-data mappings, and audit versions all live here.

```
PK: {tenant}#{ENTITY_TYPE}#{id}          e.g. tenant-abc#CONFIGURATION#config-xyz
SK: {version}#{timestamp}                 e.g. v1#2026-... (audit "version prefix zero" pattern)
GSI1PK: i_{tenantId}_{VENDOR}            e.g. i_tenant-abc_TRAY
GSI1SK: {entityType}#{id}#{status}       e.g. config#config-xyz#active
```

Relationships: a **Configuration** holds `instanceId` (Tray solution instance), `region`, and a `workflows[]` list (`{ workflowId, action, triggerUrl, dataMappingIds[] }`); a **DataMapping** references its `configurationId` and holds `entities[] → fields[] → { cxoneChannel, cxoneChannelField, crmEntityField }`. Helpers: `lambda/helpers/dbHelper/`, `dbDAO.js`, `dbDAO.dataMappings.js`.

A Data Memorialization mapping example (from the automation fixtures):

```jsonc
{ "name": "test_dm_all_mapping",
  "entityMappings": [ { "action": "CREATE", "crmEntityName": "customer_contact", "crmEntityLabel": "Contact",
    "fieldMappings": [
      { "cxoneChannel": "voiceCallContact", "cxoneChannelField": "agentId", "crmEntityField": "account" },
      { "cxoneChannel": "scriptVariable",   "cxoneChannelField": "agentId", "crmEntityField": "account" }
    ] } ] }
```

---

## 13. Feature toggles & the Tray throttle fix (CRM-24904)

Toggles are fetched cross-account: the Lambda `AssumeRole`s into the WFO account (STS) and invokes the feature-toggle Lambda, caching the result (~2 min). Usage pattern (`lambda/featureToggles/featureToggles.js`):

```javascript
await featureToggles.checkFeatureToggleEnabled('release-...-AW-15977', tenantId, awsHelper);
```

The headline toggle **`Utility-crm-traythrottlingfix-CRM-24904`** selects the cache/Tray code path in `workflowExecution/app.js`:
- **OFF (26.2 legacy):** new `redisHelper`/auth per invocation, `redis.quit()` after each op — more Tray calls, higher latency.
- **ON (throttle fix):** module-scope **singletons** (`CacheClientHelper`, `CacheManagerNew`, `ElastiCacheHelperNew`) reuse the Redis connection across warm invocations and cache the auth token (~23h) → ~80–90% fewer Tray calls. Requires `context.callbackWaitsForEmptyEventLoop = false` because the persistent Redis connection keeps the event loop alive.

---

## 14. Error handling & status codes

The Lambda returns `{ StatusCode, Payload, Error }`. Common codes:

| Code | Meaning |
|------|---------|
| `200` | success (`Payload.result`) |
| `206` | **partial success** — some DM fields couldn't be sourced; `result` + `errors[]` |
| `400` | input validation failed (bad/empty `integration`, empty `cxoneContact`, missing `dataMappingId`, zero DDM matches) |
| `404` | `configurationId`/`workflowId` not found / trigger URL not resolvable |
| `500` | unhandled exception (check CloudWatch) |

DM soft errors (entity not in mapping, field not sourced) are collected and surface as 206 — they do **not** fail the whole call. Validation errors throw via `errorHandler(...)` and become 400.

---

## 15. Repo-by-repo developer guide

### 15.1 `lambda-ipaas-workflow-integration` (Node 22)

```
lambda/
  workflowIntegration/      app.js          # config CRUD, auth, types, mappings, entities (event.key dispatch)
  workflowExecution/        app.js          # entry: FT check -> appService.processRequest
                            appService.js   # routes on event.key
  enhancedWorkflowExecution/app.js          # multi-config fan-out
  digitalTranscript/        app.js          # SQS-triggered DFO transcript + DM
  workflowExecutionEvents/
    V2/  searchWorkflow.js createWorkflow.js timelineWorkflow.js
         dataMemorializationWorkflow.js relatesToWorkflow.js triggerWorkflow.js
    cache/  setInteractionCacheData/  getInteractionCacheData/   # Redis read/write events
  workflowExecutionHelpers/ workflowExecutionHelper.js interactionCacheHelper.js
                            workflowCreateMappingHelper.js workflowSearchMappingHelper.js
  helpers/  trayIoHelper.js trayHelperNew.js graphql.js          # Tray REST + GraphQL
            elastiCacheHelper.js elastiCacheHelperNew.js redisHelper.js
            cacheManager.js cacheManagerNew.js cacheClientHelper.js
            dbHelper/ dbDAO.js dbDAO.dataMappings.js configurationHelper.js
            awsHelper.js encryptionHelper.js errorHandler/
  featureToggles/ featureToggles.js
  constants/  CXone.js  (+ index constants)
template/  main-template.yaml   # CloudFormation
```

Build/run: `cd lambda` → `aws-role-creds-V2.0.ps1` (CodeArtifact auth) → `npm install` → `npm run lint` → `npm run test` → `npm run coverage`. Tests are Mocha/Chai/Sinon; every source file has a `.spec.js` next to it (read those for input/output examples).

### 15.2 `cxone-webapp-agent-integration` (Angular 17 — Config Admin MFE)

```
src/
  app/pages/crm-administration/   # config + mapping admin screens
      crm-integrations/           # configurations grid
  store/agentIntegrations/        # NgRx: actions / reducers / effects / selectors / state
      effects/base.effects.ts     # calls DataMappingService / DynamicDataMappingService (@cxone/acd-service-library)
  services/config-window/         # window.open + postMessage for Tray config popups
```
Runs as the `agent-integrations` MFE behind `container-platform-frontend` (Rancher). Dev: set `.env`, `npm run start`, browse `http://na1.dev.localhost:8088`. E2E: Playwright suites (`npm run playwright13` …). This repo is where you change the **admin/config experience and data-mapping editors**, not the agent runtime card.

### 15.3 `cxone-crm-integration-automation` (Playwright/TypeScript)

```
src/constants/API/    configuration-api.ts  # all endpoint builders (v26–v33)
src/constants/CRM/    crm-types.ts           # Salesforce, ServiceNow, Dynamics, Zendesk, Oracle, Kustomer, HubSpot
src/utils/builders/   dynamic-data-builders.ts
tests/api/            api-workflow-execution/ api-workflow-cache/ api-dynamic-data/
                      api-data-memorialization/ api-configurations/ ...
tests/ui/
```
This is the **best place to see real payloads**. Run `npm install` → `npx playwright install` → `npm run test:smoke`. Endpoint version map: v26 (workflows/configs read), v27 (data-mapping + execute), v29 (dynamic-data), v30 (interaction cache), v31 (config audits), v33 (current config CRUD).

---

## 16. Putting it all together — two full traces

### Trace A — Inbound voice call, screen pop

```
1. Call arrives → Studio runs Workflow Execute (Search) + Agent Workflow Configuration
2. Monolith AGTINT_WRKFLO_EXE_IMP → Lambda.invoke { key:"executeWorkflow_v23.1", payload:{action:"Search", workflowInput:{phoneNumber}} }
3. workflowExecution/app.js → appService → V2 searchWorkflow → workflowExecutionHelper
4. DynamoDB: resolve config + Tray instance → Tray REST POST (search) → CRM
5. Result lpush'd to Redis {cacheKey}; single match w/ screenPop → AgentWorkflowResponse event
6. Monolith caches workflow config under {cacheKey}_workflow
7. Agent: WebSocket event → cxone-get-next-adapter → Redux → Customer Card renders + screen pop
   (and/or) Agent GET /v30/.../interaction/{cacheKey}?types=default,pin,workflow
```

### Trace B — Call ends, Data Memorialization

```
1. Disconnect → CXA reads {cacheKey}_workflow to find DM workflowId + dataMappingId, and {cacheKey}/{cacheKey}_pin for linked entities
2. POST /v27/.../workflow/{dmWorkflowId} { action:"DataMemorialization", dataMappingId, cxoneContact, integration[] }
3. Monolith → Lambda.invoke (executeWorkflow_v23.1)
4. dataMemorializationWorkflow.js: load mapping entities → match integration[] → filter fields by mediaType →
   source values from cxoneContact / scriptVariables → build entities[].entityFields[]
5. (digital + transcriptText) → SQS → digitalTranscript Lambda → DFO transcript → DM
6. Region-aware Tray REST POST { requestor, entities, contactId } → CRM writes the record/fields
7. 200 (all sourced) | 206 (some fields unsourced + errors[]) | 400 (validation)
```

---

## 17. References (Confluence + code)

**Confluence (space IN — NICE CXone):**
- [Agent Integrations — Architecture](https://nice-ce-cxone-prod.atlassian.net/wiki/spaces/IN/pages/3678339994) (index)
- [System Map](https://nice-ce-cxone-prod.atlassian.net/wiki/spaces/IN/pages/3677586871)
- [Studio Execution Flow](https://nice-ce-cxone-prod.atlassian.net/wiki/spaces/IN/pages/3676931980)
- [Event Ingress Flow](https://nice-ce-cxone-prod.atlassian.net/wiki/spaces/IN/pages/3676932001)
- [C# Monolith](https://nice-ce-cxone-prod.atlassian.net/wiki/spaces/IN/pages/3680174467)
- [JS Lambdas](https://nice-ce-cxone-prod.atlassian.net/wiki/spaces/IN/pages/3678110836)
- [iPaaS / Workflow Integration Architecture](https://nice-ce-cxone-prod.atlassian.net/wiki/spaces/IN/pages/3673063772)
- [Transfer Contact End to End Data Flow](https://nice-ce-cxone-prod.atlassian.net/wiki/spaces/IN/pages/483622913) (cache truth table + payloads)
- [AGTINT - Data Memorialization](https://nice-ce-cxone-prod.atlassian.net/wiki/spaces/IN/pages/17291055) (all payload schemas)
- [Dynamic Data End to End Flow](https://nice-ce-cxone-prod.atlassian.net/wiki/spaces/IN/pages/180520839)
- [Dynamic Data - Studio Configuration](https://nice-ce-cxone-prod.atlassian.net/wiki/spaces/IN/pages/317359512)

**Code landmarks:**
- Lambda entry: `lambda/workflowExecution/app.js` · dispatch `lambda/workflowExecution/appService.js`
- DM transform: `lambda/workflowExecutionEvents/V2/dataMemorializationWorkflow.js`
- Tray client: `lambda/helpers/trayIoHelper.js` (`getWorkflowResponse` REST, `getGraphqlData` GraphQL)
- Redis: `lambda/helpers/elastiCacheHelper.js` (`lpush`/`lrange`/`expire`)
- Contact model: `lambda/constants/CXone.js`
- Config admin state: `cxone-webapp-agent-integration/src/store/agentIntegrations/`
- Real payloads: `cxone-crm-integration-automation/tests/api/`

> Tip: when a payload field confuses you, search the automation repo first (`tests/api/`), then the matching V2 handler in the Lambda, then the Confluence page for the schema.
