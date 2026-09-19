---
id: select-next-issue
name: select-next-issue
title: Select Next GitHub Issue
type: skill
description: Select one suitable open GitHub issue by priority and roadmap relevance, without implementing it. Use as a subskill before work-on-issue.
---

## Description

Use this skill when an instruction needs one suitable open GitHub issue to be selected, but not implemented yet.

This skill is selection-only.

It must:

- inspect open GitHub issues through the GitHub CLI
- read `PROJECT.md` when present
- rank issues by priority, roadmap relevance, clarity, and suitability
- return exactly one issue number
- make no code changes
- create no branch
- create no commit

This skill is usually called by `~/.ai/skills/20-repository-workflows/work-on-next-issue/SKILL.md`.

## Trigger examples

Use this skill as a subskill for requests such as:

- "work on open issues"
- "pick the next issue"
- "select the next issue"
- "find a suitable open issue"
- "choose one issue from the backlog"

Do not use this skill directly when the user already provided a specific issue number. In that case, use `~/.ai/skills/20-repository-workflows/work-on-issue/SKILL.md`.

## Preconditions

Before selecting an issue:

1. Confirm the current directory is a Git repository.

   ```bash
   git rev-parse --show-toplevel
   ```

2. Confirm the GitHub CLI is available and authenticated.

   ```bash
   gh auth status
   ```

3. Confirm the repository has a GitHub remote.

   ```bash
   gh repo view --json nameWithOwner,url
   ```

4. Inspect local project instructions when they exist, especially:

   - `AGENTS.md`
   - `CLAUDE.md`
   - `.github/copilot-instructions.md`
   - `.vscode/instructions/**/*.md`
   - `README.md`
   - `CONTRIBUTING.md`

5. Do not modify files.

## Issue listing

List open issues with enough metadata to rank them.

```bash
gh issue list \
  --state open \
  --limit 100 \
  --json number,title,labels,assignees,updatedAt,createdAt,body,url
```

If `PROJECT.md` exists, read it before ranking issues.

```bash
test -f PROJECT.md && sed -n '1,240p' PROJECT.md
```

Use `PROJECT.md` to identify:

- explicit recommendations
- priority sections
- current milestones
- issue numbers
- topics marked as next, active, urgent, important, planned, or deferred
- repeated topics that match open issues

Do not edit `PROJECT.md`.

## Ranking rules

Rank open issues by:

1. explicit priority labels, for example `priority:critical`, `priority:high`, `prio:critical`, `prio:high`, `P0`, or `P1`
2. direct mention in `PROJECT.md`
3. topic alignment with `PROJECT.md`
4. clear acceptance criteria
5. clear bug report, feature request, documentation task, or maintenance task
6. suitability for implementation in the current repository
7. unassigned issues or issues assigned to the current maintainer
8. older issues before newer issues when otherwise equal

Prefer one issue that can be completed safely and fully.

## Issues to skip

Do not select issues that are:

- closed
- labelled `blocked`, `waiting`, `wontfix`, `duplicate`, `invalid`, or similar
- vague epics without a clear implementation path
- dependent on unavailable secrets, production systems, private credentials, or external accounts
- mostly product, strategy, or design decisions
- unrelated to the current repository
- likely to require broad unrelated refactoring
- impossible to validate locally

If no suitable issue exists, report that no safe actionable issue was found.

## Candidate inspection

For promising issues, inspect full details and comments.

```bash
gh issue view ISSUE_NUMBER \
  --comments \
  --json number,title,body,labels,assignees,state,comments,url
```

Inspect enough candidates to make a defensible selection. Usually 3-5 candidates are enough unless the repository has unusually unclear issues.

## Selection output contract

Return exactly one selected issue when possible.

Use this format:

```text
Selected issue: #ISSUE_NUMBER
Title: ISSUE_TITLE
Reason: SHORT_SELECTION_REASON
```

Example:

```text
Selected issue: #123
Title: Fix token refresh after session expiry
Reason: High-priority bug, mentioned in PROJECT.md, clear reproduction steps, and safe local validation path.
```

If no issue can be selected, use this format:

```text
Selected issue: none
Reason: No open issue was safe and actionable.
Inspected: #12, #18, #27
Blocked by: Issues were blocked, vague, external-system dependent, or unrelated to this repository.
```

## Handoff rules

This skill must not implement the issue.

After selection, hand off the selected issue number to:

```text
~/.ai/skills/20-repository-workflows/work-on-issue/SKILL.md
```

Do not change the selected issue during handoff unless the selected issue is found to be closed, inaccessible, or blocked during the given-issue inspection step.
