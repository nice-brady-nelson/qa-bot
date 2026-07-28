---
description: Generate QA test cases based on a previously created high-level test plan for a given Jira epic
argument-hint: <Jira key of the high-level test plan, e.g. CXIFW-1234>
---

Generate test cases from the high-level test plan `$1`, read via the Atlassian MCP. The test plan is the 100% source of truth — read its requirements, description, and acceptance criteria before writing anything.

Before writing, use the **titans-context** skill to load feature behavior and edge-case knowledge for the area under test.

Ensure the generated tests are comprehensive, covering all relevant scenarios and edge cases. Write them first into their own file in the `TC-Files` folder of the current working repo, following the format of the existing files there (create the folder if it does not exist). Example TC files are available in the titans-context skill's `references/tc-examples/` if the working repo has none.

After user approval, post them to Jira with `/post-tests-to-jira`.

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
