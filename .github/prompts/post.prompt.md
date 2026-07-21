---
name: post-tests-to-jira
description: 'Post a set of test cases to Jira.'
argument-hint: 'File containing test cases.'
---

Create the pre-made test cases in Jira, using the Atlassian MCP (BN-ROVO-MCP).

When the test cases are created in Jira, they need to have the following:
- Be in the CXIFW project (Test Repository for project CX_Integration Framework)
- Team name: Connected Agent - Titans
- Assignee: Brady Nelson
- Regression set to Yes
- Candidate for Automation set to Yes
- Priority set
  - P1's - Smoke tests that will be run during deploys
  - P1's, P2's - Tests that will be run during nightly pipelines
  - P1's, P2's, P3's, P4's - Tests that will be run every regression
  (consider what it would take to run tests at these different times)
- Labels:
  - AGENTIC_AI_CODE
  - Agent_Integrations
  - CXAgent
  - mcp-auto-generated
  - implemented by AI agent field (if present) set to yes
  - [Feature] (**ASK USER FOR THIS**, eg. Multi_CRM)
  - [Sub-Feature] (**ASK USER FOR THIS**, eg. ScreenPop)