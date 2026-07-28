---
name: remove-jira-test-cases
description: Use when removing, retiring, or marking Jira test cases as obsolete. Covers the three-step workflow transition chain required to move a Test issue to Removed status in the NICE CXone Prod instance.
---

# Removing Jira Test Cases

To move a Test issue to **Removed** status, the workflow requires three sequential transitions. There is no direct path from Design to Removed.

## Transition Chain

| Step | Transition Name | Transition ID | From → To |
|------|----------------|--------------|-----------|
| 1 | Designed | `11` | Design → Reviewing |
| 2 | Reviewed | `41` | Reviewing → Active |
| 3 | Remove | `101` | Active → Removed |

## Process

For each issue to remove:

1. Call `transitionJiraIssue` with transition ID `11` (Design → Reviewing)
2. Call `transitionJiraIssue` with transition ID `41` (Reviewing → Active)
3. Call `transitionJiraIssue` with transition ID `101` (Active → Removed)

Repeat for every issue. Transitions must be applied sequentially per issue — each step must succeed before the next.

## Notes

- Always confirm with the user before removing issues unless explicitly told to proceed.
- If an issue is already past Design (e.g., already in Reviewing or Active), skip the earlier step(s) and start from its current status.
- `cloudId` for the NICE CXone Prod instance: `0e508bed-9911-4fa0-9106-53d761fb5715`
