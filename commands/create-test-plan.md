---
description: Generate a high-level test plan for a given feature or epic
argument-hint: <Jira key of the epic, e.g. CXIFW-1234>
---

Generate a high-level test plan for the feature or epic `$1`, read via the Atlassian MCP.

Before writing, use the **titans-context** skill to load the relevant feature, architecture, and edge-case knowledge for the area under test.

---

## Test Plan Standards

**Structure required:**

- Objective (1-2 sentences: what is being tested and why)
- Scope (bullet list: what IS in scope)
- Out of Scope (bullet list: what is NOT tested)
- Test Areas (5-8 areas, each with 3-5 assertion statements)
- Entry/Exit Criteria (test readiness and completion rules)
- Risks (table: risk description, impact level, mitigation)

**Test Area Guidelines:**

- Group by **concern** (user perspective, workflow, business logic), NOT by component/layer
- Each area is a concern (e.g., "Authentication", "Data Validation", "Error Handling")
- Within each area: 3-5 numbered assertion-style statements
- Assertion format: "User/System [action] and [expected result]" or "[Condition] results in [behavior]"
- Example assertions:
  - ✓ "User submits valid form and receives success confirmation email within 5 minutes"
  - ✓ "System rejects duplicate account emails and shows specific error message"
  - ✗ "Email validation" (too vague, not assertion)

**Tone:** Functionality-focused, not code-focused. Written for stakeholder/QA, not developers. Say "user can view order history" not "GET /api/orders endpoint returns 200 with orders array".

**Depth:** Assume reader has domain knowledge but no technical knowledge. Use business/user language.

---

Present the plan to the user for approval. Once approved, post it to Jira as a high-level test plan issue. Test cases are generated from the approved plan afterward via `/generate-tests`.
