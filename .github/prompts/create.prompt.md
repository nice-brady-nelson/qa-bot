---
name: generate-tests
description: 'Generate QA test cases based on a previously created high-level test plan for a given Jira epic.'
argument-hint: 'Jira key of high-level test plan (e.g. CRM-1234)'
---

Generate tests based on the provided high-level test plan, found using the Atlassian MCP (BN-ROVO-MCP).

Ensure that the generated tests are comprehensive, covering all relevant scenarios and edge cases. The test cases should first be generated in their own file following the format of other files found in the "TC Files" folder, and then after user approval, they should be posted to Jira using the "post-tests-to-jira" skill.

---

## Test Case Standards

Title format for test cases is:

```
[WORKSTREAM][APP][FEATURE][SUB-FEATURE][CHANNEL] Title describing condition → expected result
```

| Segment | Values | Purpose |
|---|---|---|
| `[AGTINT]` | Always present | Workstream — Agent Integration |
| `[CXA]` or `[CXAgent]` | Agent app variant | `CXA` = CX Agent, `CXAgent` = older form |
| `[Feature]` | e.g. `[Multi-CRM]` | Feature area |
| `[Sub-Feature]` | e.g. `[Create Workflows]`, `[Agent Workflow Configuration]`, `[ScreenPop]` | Optional sub-area |
| `[Channel]` | `[Voice]` or `[Digital]` | Omit if not channel-specific |

**Title body** then uses one of two styles observed:
- **Condition → outcome:** `Search Workflow = Single Match + Pinned Record = True + Screen Pop = True -> Record added to Current Interactions and Popped in CRM`
- **State description:** `Invalid or missing Config ID shows "Invalid Configuration" toast and error indicator on tile`