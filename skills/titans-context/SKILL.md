---
name: titans-context
description: Load domain context for the CXone Connected Agent - Titans team (Agent Integrations / CX_CRM) before writing test plans, test cases, or reasoning about feature behavior. Covers Data Memorialization, Multi-CRM, ScreenPop, Agent Create workflows, Related/Current Interactions, and the Studio → Monolith → Lambda → Tray.io → CRM data flow. Use whenever a task involves Titans features, AGTINT test cases, or understanding how CXone Agent talks to a CRM.
user-invocable: false
---

# Titans Context

Titans domain knowledge lives in the **Titans knowledge library** (the `knowledge-library/` folder of the Titans agentic platform repo), not in this skill. This skill tells you how to find it and keeps only the qa-bot-specific test-case templates locally.

## 1. Locate the library

Use the first of these that exists:

1. The path in the `TITANS_KB_PATH` environment variable (the `knowledge-library` folder itself).
2. `~/.claude/plugins/marketplaces/*/knowledge-library/TABLE-OF-CONTENTS.md`, i.e. the marketplace clone when qa-bot was installed from the Titans agentic platform.
3. Otherwise, ask the user where their clone of the Titans agentic platform repo is, and suggest they set `TITANS_KB_PATH` so they aren't asked again.

## 2. Load only what you need

1. If `TABLE-OF-CONTENTS.md` is already in your context, don't read it again. Otherwise read it **once**.
2. Open only the entries whose **description** matches the task. Never load the whole library.
3. Titans system knowledge is mostly in the `titans-crm-integrations` domain:
   - **`orientation`**: plain-English overview, identifiers glossary, and **test-planning approach**. Read the test-planning approach first for any test plan or test-case work.
   - **`architecture`**: system map/ownership, end-to-end request flow, the interaction cache, the Lambda, Tray.io, the DynamoDB config, repos. Use it for per-hop failure modes and negative/error-isolation cases.
   - **`features`**: Data Memorialization, ScreenPop, Related/Current Interactions, Relates To, Agent Create, Search & Dynamic Data, Multi-CRM. Each feature's trigger points and limitations are the richest source of edge cases.
4. Related entries in `cxone-agent-testing` and `webapp-acd-agent-apps` are cross-linked from those entries. Follow the links when relevant.

If knowledge you expected isn't findable from the descriptions, mention it to the user as a retrieval miss for `/librarian audit`.

## 3. Local references (qa-bot only)

| Read this | When |
|---|---|
| `references/tc-examples/` | You're about to write a TC file and need the established format. Two representative examples: `relatesTo-multiCRM-TCs.md` and `screenpop-TCs.md`. |
| `references/agent-create-multi-snippet.md` | The work involves Agent Create (manual create), create snippets, `configurationId`/`workflowId` payload lists, or multi-CRM create trays on the customer card. |

## Ground rules for test work

- Ground every assertion in documented behavior. Where the docs don't guarantee a behavior (notably multi-CRM in a single create snippet), treat the test as **product validation of a new feature**, not verification of documented behavior, and say so in the plan.
- If the library can't be found and the user can't supply it, say so plainly rather than writing tests from memory.
