---
name: create-test-plan
description: 'Generate a high-level test plan for a given feature or epic'
argument-hint: 'Jira key of the epic (e.g. CRM-1234)'
---

Generate a high-level test plan for a given feature or epic, found using the Atlassian MCP (BN-ROVO-MCP).

---

## Test Plan Standards

High-level plan includes: **Objective**, **Scope**, **Out of Scope**, **Test Areas**, **Entry/Exit Criteria**, and a small sections for **Risks**.

The key pattern is that each Area groups scenarios by **concern** (not by component), and each numbered item within an area is a concise, **assertion-style statement** describing the expected behavior — making them easy to convert into actual test cases or acceptance criteria.

In general, make it less code-focused and more functionality focused, like its designed for someone less familiar with code.