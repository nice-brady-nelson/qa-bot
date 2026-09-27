# QA-Bot-Claude

A Claude Code plugin that turns a Jira epic into a reviewed, posted set of Xray test cases for the **CXone Connected Agent - Titans** team.

---

## What it does

The plugin drives a three-stage QA workflow. Each stage stops for your approval before anything is written to Jira.

1. **Plan.** Reads the epic from Jira and writes a high-level test plan — objective, scope, out-of-scope, 5-8 test areas of assertion statements, entry/exit criteria, risks. Stakeholder language, not code language.
2. **Generate.** Reads the *approved plan* (the source of truth, not the epic) and writes detailed test cases into a local `TC-Files/` markdown file using the team's `[AGTINT][CXA][Feature][Sub-Feature][Channel]` title convention.
3. **Post.** Creates the test cases in Jira/Xray with the team's required fields, labels, priorities, and assignee.

---

## Install

This repo is its own single-plugin marketplace. In Claude Code:

```
/plugin marketplace add nice-brady-nelson/qa-bot
/plugin install qa-bot@qa-bot
```

To pick up a new release afterwards:

```
/plugin update qa-bot@qa-bot
```

The bundled `mcp.json` registers the Atlassian MCP server (`https://mcp.atlassian.com/v1/mcp`) — you will be prompted to authenticate on first use.

### Xray credentials (optional)

Only needed if you want to inspect the Xray test repository folder tree.

**Set them as user environment variables** — this is the recommended route for an installed plugin, since `/plugin update` replaces the plugin directory and would wipe a `.env` living inside it.

```powershell
[Environment]::SetEnvironmentVariable("XRAY_CLIENT_ID", "...", "User")
[Environment]::SetEnvironmentVariable("XRAY_CLIENT_SECRET", "...", "User")
```

For local development against a clone, a `.env` works too:

```bash
cp skills/xray/.env.example skills/xray/.env
```

```
XRAY_CLIENT_ID=...
XRAY_CLIENT_SECRET=...
```

`.env` is gitignored — **never commit real credentials.**

---

## Commands

| Command | Argument | What it does |
|---|---|---|
| `/create-test-plan` | Jira key of the epic (e.g. `CXIFW-1234`) | Generates a high-level test plan, presents it for approval, then posts it to Jira. |
| `/generate-tests` | Jira key of the approved test plan | Generates detailed test cases into `TC-Files/` in the current repo, following the established title format. |
| `/post-tests-to-jira` | Path to the TC file | Creates the test cases in the CXIFW project with required fields and labels. Asks you for Feature and Sub-Feature. |

### Typical session

```
/create-test-plan CXIFW-857
   → review the plan, ask for edits, approve
   → Claude posts it and gives you the new plan key, e.g. CXIFW-901

/generate-tests CXIFW-901
   → Claude writes TC-Files/multicrm-dm-TCs.md
   → review and edit the file directly

/post-tests-to-jira TC-Files/multicrm-dm-TCs.md
   → Claude asks for Feature / Sub-Feature labels, confirms, then creates the issues
```

---

## Skills

Skills load automatically when the work calls for them — you do not need to invoke them by name.

### `titans-context`

Domain knowledge for the Titans / Agent Integrations system. Claude reads this before writing plans or test cases so assertions are grounded in real feature behavior rather than guesses.

The SKILL.md is a short router; the substance sits in `references/` and is loaded selectively:

| Reference | Contents |
|---|---|
| `titans-features.md` | Default starting point. Per-feature behavior, trigger points, and known limitations — Data Memorialization, Multi-CRM, ScreenPop, Related/Current Interactions, Agent Create, Dynamic Data. The richest source of edge cases. |
| `titans-plain-english.md` | Analogy-first orientation to the whole system. Read this first if you're new to the domain. |
| `titans-architecture-deep-dive.md` | Exact payloads, cache keys, repo names, file paths, hop-by-hop data flow. Used for per-layer failure modes and negative tests. |
| `agent-create-multi-snippet.md` | Agent Create / manual create: snippet payload lists, `configurationId` + `workflowId` routing, `cacheResponse`, multi-CRM create trays. |
| `tc-examples/` | Two representative TC files (`relatesTo-multiCRM-TCs.md`, `screenpop-TCs.md`) used as format exemplars. |

### `remove-jira-test-cases`

The three-transition chain (Designed → Reviewed → Remove) required to retire a Jira Test issue. There is no direct Design → Removed path, so this exists to stop Claude from guessing.

### `xray`

General-purpose skill for working with the Xray Cloud API directly — the Atlassian MCP covers Jira issues, but Xray-specific concepts (test repository folders, test executions, test runs) are Xray-only. Loads automatically for context (e.g. deciding which folder new tests belong in) and can also be invoked directly for ad hoc Xray work like inspecting the folder tree or mass test execution.

```powershell
./skills/xray/scripts/xray_auth.ps1
./skills/xray/scripts/xray_folders.ps1 -OutFile "$env:TEMP\xray_tree.json"
./skills/xray/scripts/xray_print_tree.ps1 "$env:TEMP\xray_tree.json"
```

`xray_auth.ps1` caches a short-lived JWT in `$env:TEMP`; re-run it if you start getting 401s. PowerShell only.

---

## Configuration reference

This plugin was designed for the Titans team, but could be modified to work with other teams' workflows. Reference what the plugin uses in table below if you'd like to change any configurations so it works for your team.

| Item | Value |
|---|---|
| Team | Connected Agent - Titans |
| Jira & Confluence | `https://nice-ce-cxone-prod.atlassian.net` |
| cloudId | `0e508bed-9911-4fa0-9106-53d761fb5715` |
| Test repository project | `CXIFW` (CX_Integration Framework) — numeric id `13458` for Xray GraphQL |
| Standard labels | `AGENTIC_AI_CODE`, `Agent_Integrations`, `CXAgent`, `mcp-auto-generated`, plus Feature and Sub-Feature |

---

## Behavior guarantees

Defined in `CLAUDE.md` and applied to every session:

- The high-level test plan is the 100% source of truth for test cases — read before writing.
- Always confirm before creating or modifying Jira issues, unless told to proceed automatically.
- Never fabricate Jira field values. If a field is unknown, ask.
- Test case steps are concise but specific — no "test the feature."

---

## Layout

```
QA-Bot-Claude/
├── .claude-plugin/
│   ├── plugin.json              # plugin manifest
│   └── marketplace.json         # single-plugin marketplace, source "./"
├── CLAUDE.md                    # persona, flow, behavior rules
├── mcp.json                     # Atlassian MCP server
├── commands/
│   ├── create-test-plan.md
│   ├── generate-tests.md
│   └── post-tests-to-jira.md
└── skills/
    ├── titans-context/
    │   ├── SKILL.md
    │   └── references/
    ├── remove-jira-test-cases/SKILL.md
    └── xray/
        ├── SKILL.md
        ├── .env.example         # Xray credential template
        └── scripts/
```

---

## Ported from

I originally developed this plugin for Copilot in VS Code. The below table details the previous agent/skills setup and how it was ported to a Claude Code plugin.

| VS Code (QA-Bot) | Here |
|---|---|
| `.github/copilot-instructions.md` | `CLAUDE.md` |
| `.github/prompts/plan.prompt.md` | `commands/create-test-plan.md` |
| `.github/prompts/create.prompt.md` | `commands/generate-tests.md` |
| `.github/prompts/post.prompt.md` | `commands/post-tests-to-jira.md` |
| `.github/instructions/titans-*.md`, `agent-create-multi-snippet` | `skills/titans-context/references/` |
| `.github/instructions/remove-TC.instructions.md` | `skills/remove-jira-test-cases/` |
| `xray_*.ps1` (root) | `skills/xray/scripts/` |

The Xray scripts were changed in the port: credentials now come from the environment instead of being hardcoded, and the tree printer takes a file path or stdin instead of a hardcoded VS Code temp file.
