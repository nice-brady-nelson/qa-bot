---
name: titans-context
description: Load domain context for the CXone Connected Agent - Titans team (Agent Integrations / CX_CRM) before writing test plans, test cases, or reasoning about feature behavior. Covers Data Memorialization, Multi-CRM, ScreenPop, Agent Create workflows, Related/Current Interactions, and the Studio → Monolith → Lambda → Tray.io → CRM data flow. Use whenever a task involves Titans features, AGTINT test cases, or understanding how CXone Agent talks to a CRM.
---

# Titans Context

Domain knowledge for the CXone Connected Agent - Titans team. Read only the references you need — do not load all of them.

## Which reference to read

| Read this | When |
|---|---|
| `references/titans-features.md` | **Default starting point** for any test plan or test cases. What each feature does, trigger points, known limitations, and edge cases per feature (Data Memorialization, Multi-CRM, ScreenPop, Related/Current Interactions, Agent Create, Dynamic Data). |
| `references/titans-plain-english.md` | You need intuition first, or you're orienting on the system from scratch. Analogy-driven walkthrough of the same system. Read before the deep dive. |
| `references/titans-architecture-deep-dive.md` | You need exact payloads, cache keys, repo names, file paths, or the end-to-end hop-by-hop data flow — e.g. reasoning about where a failure could occur, or writing negative/error-isolation test cases. |
| `references/agent-create-multi-snippet.md` | The work involves Agent Create (manual create), create snippets, `configurationId`/`workflowId` payload lists, or multi-CRM create trays on the customer card. |
| `references/tc-examples/` | You are about to write a TC file and need the established format. Two representative examples: `relatesTo-multiCRM-TCs.md` and `screenpop-TCs.md`. |

## Key facts

- **Jira & Confluence:** `https://nice-ce-cxone-prod.atlassian.net`
- **cloudId:** `0e508bed-9911-4fa0-9106-53d761fb5715`
- **Mental model:** Studio / CXA → C# Monolith → Node Lambda (direct `Lambda.invoke`, no API Gateway) → Tray.io → CRM, with results written to an ElastiCache Redis interaction cache keyed by `cacheKey` that the agent Customer Card reads back.

## How to use this in test work

1. Read `titans-features.md` for the feature under test — its trigger points and known limitations are the richest source of edge cases.
2. If the feature spans layers (transfers, DM, error isolation), read the architecture deep dive to identify per-hop failure modes worth covering.
3. Ground every assertion in documented behavior. Where the docs do not guarantee a behavior (notably multi-CRM in a single create snippet), treat the test as **product validation of a new feature**, not verification of documented behavior — and say so in the plan.
