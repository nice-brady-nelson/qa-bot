---
description: Post a set of test cases to Jira
argument-hint: <file containing test cases>
---

Create the pre-made test cases in `$1` as Jira issues, using the Atlassian MCP. Confirm with the user before creating anything.

When the test cases are created in Jira, they need to have the following:

- Be in the CXIFW project (Test Repository for project CX_Integration Framework)
- Team name: Connected Agent - Titans
- Assignee: Brady Nelson
- Regression set to Yes
- Candidate for Automation set to Yes
- Priority set
  - P1's — Smoke tests that will be run during deploys
  - P1's, P2's — Tests that will be run during nightly pipelines
  - P1's, P2's, P3's, P4's — Tests that will be run every regression

  (consider what it would take to run tests at these different times)
- Labels:
  - `AGENTIC_AI_CODE`
  - `Agent_Integrations`
  - `CXAgent`
  - `mcp-auto-generated`
  - implemented by AI agent field (if present) set to yes
  - `[Feature]` (**ASK USER FOR THIS**, e.g. `Multi_CRM`)
  - `[Sub-Feature]` (**ASK USER FOR THIS**, e.g. `ScreenPop`)

Never fabricate a field value — if a required field is unknown, ask the user.
