---
name: xray-test-repository
description: Authenticate to the Xray Cloud API and inspect the Xray test repository folder structure for a Jira project (default CXIFW). Use when you need an Xray bearer token, need to know which test repository folder a test case should live in, need test counts per folder, or are working with the Xray REST/GraphQL API directly rather than through the Atlassian MCP.
---

# Xray Test Repository

The Atlassian MCP handles Jira issues, but the **test repository folder tree** lives in Xray and is only reachable through the Xray Cloud API. Use this skill when you need folder paths or test counts — e.g. deciding where `/generate-tests` output should be filed.

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

The GraphQL API requires the **numeric** project ID, not the key. The REST endpoint uses the key.

## Scripts

Run from PowerShell. Each writes/reads the token at `$env:TEMP\xray_token.txt` so `auth` only needs running once per session (tokens are short-lived — re-auth if you get a 401).

| Script | Purpose |
|---|---|
| `scripts/xray_auth.ps1` | POST to `/api/v2/authenticate`, cache the JWT, then attempt the REST folder listing with a GraphQL fallback. |
| `scripts/xray_folders.ps1` | Query the folder tree via GraphQL `getFolder`. Accepts `-ProjectId` (default `13458`) and `-Path` (default `/`). Writes raw JSON to stdout, and to a file with `-OutFile`. |
| `scripts/xray_print_tree.ps1` | Pretty-print a saved `getFolder` JSON response as an indented tree with test counts. Accepts a file path, or piped JSON on stdin. |

## Typical flow

```powershell
./scripts/xray_auth.ps1
./scripts/xray_folders.ps1 -OutFile "$env:TEMP\xray_tree.json"
./scripts/xray_print_tree.ps1 "$env:TEMP\xray_tree.json"
```

## API notes

- Auth: `POST https://xray.cloud.getxray.app/api/v2/authenticate` with `{"client_id":..., "client_secret":...}` returns a bare JWT string wrapped in double quotes — strip them before use.
- The REST endpoint `GET /api/v2/testrepository/{projectKey}/folders` is often unavailable on Cloud; the GraphQL endpoint `POST /api/v2/graphql` is the reliable path.
- GraphQL `getFolder(projectId:, path:)` returns `name`, `path`, `testsCount`, and `folders`. Nested `folders` come back as a flat structure per level, so recurse if you need the full tree.
