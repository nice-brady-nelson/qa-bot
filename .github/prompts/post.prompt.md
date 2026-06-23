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
  - P1: Should be run regularly
  - P2: Should be run regularly, but not as often as P1
  - P3: Should be run every regression cycle, but not as often as P2
  - P4: Should be run every regression cycle, but not as often as P3
- Labels:
  - AGENTIC_AI_CODE
  - Agent_Integrations
  - CXAgent
  - mcp-auto-generated
  - implemented by AI agent field (if present) set to yes
  - [Feature] (**ASK USER FOR THIS**, eg. Multi_CRM)
  - [Sub-Feature] (**ASK USER FOR THIS**, eg. ScreenPop)