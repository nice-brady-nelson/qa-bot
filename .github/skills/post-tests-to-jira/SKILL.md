---
name: post-tests-to-jira
description: 'Post a set of test cases to Jira.'
argument-hint: 'File containing test cases.'
---

Create the pre-made test cases in Jira, using the Atlassian MCP (BN-ROVO-MCP).

When the test cases are created in Jira, they need to have the following:
- Be in the CRM project
- Team name: Connected Agent - Titans
- Assignee: Brady Nelson
- Regression set to Yes
- Candidate for Automation set to Yes
- Priority set
- Labels:
  - AGENTIC_AI_CODE
  - Agent_Integrations
  - CXAgent
  - mcp-auto-generated
  - implemented by AI agent set to yes
  - [Feature] (**ASK USER FOR THIS**, eg. Multi_CRM)
  - [Sub-Feature] (**ASK USER FOR THIS**, eg. ScreenPop)

Ask the user exactly **where** in the test repository the test cases should be posted. Of course, they should automatically be within the "Connected Agent - Titans" folder, but the user should specify the actual subfolder path.