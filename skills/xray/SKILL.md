---
name: xray
description: Use when working with the Xray Cloud API directly — authenticating for a bearer token, inspecting the test repository folder tree (paths, test counts, where a new test case belongs), or working with test executions/test runs (mass execution, bulk result import, execution status). Applies to any Xray Cloud REST/GraphQL work that the Atlassian MCP doesn't cover, whether triggered automatically by the plugin (e.g. deciding a folder for `/generate-tests` output) or invoked directly by the user for ad hoc Xray tasks.
---

# Xray

The Atlassian MCP handles Jira issues, but Xray-specific concepts — the **test repository folder tree**, **test executions**, and **test runs** — live in Xray's own Cloud API (REST + GraphQL) and aren't reachable through the MCP. Use this skill for any of that.

## Credentials

Never hardcode credentials. The scripts read:

| Variable | Meaning |
|---|---|
| `XRAY_CLIENT_ID` | Xray API client id |
| `XRAY_CLIENT_SECRET` | Xray API client secret |

They are loaded from `$env:XRAY_CLIENT_ID` / `$env:XRAY_CLIENT_SECRET`, or from a `.env` file in the current working repo (see `.env.example` at the plugin root). Keep `.env` gitignored.

## Project identifiers

| Project | Key | Numeric project ID |
|---|---|---|
| CX_Integration Framework | `CXIFW` | `13458` |

The GraphQL API requires the **numeric** project ID, not the key. REST endpoints use the key.

## Scripts

Run from PowerShell. Each writes/reads the token at `$env:TEMP\xray_token.txt` so `auth` only needs running once per session (tokens are short-lived — re-auth if you get a 401).

| Script | Purpose |
|---|---|
| `scripts/xray_auth.ps1` | POST to `/api/v2/authenticate`, cache the JWT, then attempt the REST folder listing with a GraphQL fallback. |
| `scripts/xray_folders.ps1` | Query the folder tree via GraphQL `getFolder`. Accepts `-ProjectId` (default `13458`) and `-Path` (default `/`). Writes raw JSON to stdout, and to a file with `-OutFile`. |
| `scripts/xray_print_tree.ps1` | Pretty-print a saved `getFolder` JSON response as an indented tree with test counts. Accepts a file path, or piped JSON on stdin. |

### Typical flow — folder structure

```powershell
./scripts/xray_auth.ps1
./scripts/xray_folders.ps1 -OutFile "$env:TEMP\xray_tree.json"
./scripts/xray_print_tree.ps1 "$env:TEMP\xray_tree.json"
```

## Test executions & mass execution

There are no scripts for this yet — the patterns below are API notes for driving it by hand (curl / `Invoke-RestMethod` with the cached bearer token) until a concrete script is written.

- **Create a Test Execution:** GraphQL mutation `createTestExecution(testIssueIds: [...], jira: {fields: {project: {key: "CXIFW"}, summary: "..."}})` — bulk-associates a list of test issue IDs with a new execution issue in one call.
- **Add tests to an existing execution:** `addTestsToTestExecution(issueId:, testIssueIds: [...])`.
- **Bulk-import run results:** `POST /api/v2/import/execution` (Xray JSON format) or the format-specific variants (`/import/execution/junit`, `/import/execution/cucumber`, `/import/execution/testng`, ...) — the standard way to mass-update statuses from a CI run rather than editing runs one at a time.
- **Query run status:** GraphQL `getTestExecutions` / `getTestRuns` — filter by test execution issue id or JQL to check status across many tests at once.

Confirm exact field/type names against the current Xray GraphQL schema before relying on them — Xray Cloud's schema does drift between releases.

## API notes

- Auth: `POST https://xray.cloud.getxray.app/api/v2/authenticate` with `{"client_id":..., "client_secret":...}` returns a bare JWT string wrapped in double quotes — strip them before use.
- The REST endpoint `GET /api/v2/testrepository/{projectKey}/folders` is often unavailable on Cloud; the GraphQL endpoint `POST /api/v2/graphql` is the reliable path for folder queries.
- GraphQL `getFolder(projectId:, path:)` returns `name`, `path`, `testsCount`, and `folders`. Nested `folders` come back as a flat structure per level, so recurse if you need the full tree.
- All GraphQL calls use the same `POST /api/v2/graphql` endpoint with `Authorization: Bearer <token>` — only the query/mutation body changes.
