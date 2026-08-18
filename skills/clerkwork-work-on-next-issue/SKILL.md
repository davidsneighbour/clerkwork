---
id: clerkwork-work-on-next-issue
name: clerkwork-work-on-next-issue
title: Work on Next GitHub Issue
type: skill
description: Orchestrate selecting and implementing the next suitable open GitHub issue without a specific issue number provided. Delegates selection to clerkwork-select-next-issue and implementation to clerkwork-work-on-issue.
---

## Description

Use this skill when the user asks to work on open GitHub issues without providing a specific issue number.

This skill is an orchestrator.

It must:

1. select one suitable open issue
2. hand that issue number to the given-issue implementation skill
3. implement, validate, and commit through that implementation skill

Do not duplicate issue-fixing logic in this skill.

## Trigger examples

Use this skill for requests such as:

- "work on open issues"
- "work on the next issue"
- "pick an issue and fix it"
- "solve one open GitHub issue"
- "take an issue from the backlog"
- "work through the issue list"
- "find something useful to fix"

Do not use this skill when the user provides a specific issue number. In that case, use:

```text
~/.ai/skills/20-repository-workflows/clerkwork-work-on-issue/SKILL.md
```

## Workflow

### Step 1: Select one issue

Run:

```text
~/.ai/skills/20-repository-workflows/clerkwork-select-next-issue/SKILL.md
```

The selector must return an output in this format:

```text
Selected issue: #ISSUE_NUMBER
Title: ISSUE_TITLE
Reason: SHORT_SELECTION_REASON
```

If the selector returns no suitable issue, stop and report the selector result. Do not make code changes.

### Step 2: Extract the issue number

Extract the selected issue number from the selector result.

Example:

```text
Selected issue: #123
```

The extracted issue number is:

```text
123
```

Do not change the issue number after extraction unless the given-issue skill finds that the issue is closed, inaccessible, or blocked.

### Step 3: Work on the selected issue

Run:

```text
~/.ai/skills/20-repository-workflows/clerkwork-work-on-issue/SKILL.md
```

Pass the extracted issue number as the required input.

Example handoff:

```text
Work on issue #123 using ~/.ai/skills/20-repository-workflows/clerkwork-work-on-issue/SKILL.md.
```

The given-issue skill is responsible for:

- inspecting the selected issue
- checking whether it is actionable
- creating a branch when appropriate
- implementing the change
- running relevant validation
- fixing validation failures caused by the current work
- staging only related files
- committing with a Conventional Commits message
- including `Closes #ISSUE_NUMBER` in the commit body

## Do not duplicate implementation rules

This skill must not define its own implementation, validation, staging, or commit workflow.

Those rules live in:

```text
~/.ai/skills/20-repository-workflows/clerkwork-work-on-issue/SKILL.md
```

If the implementation rules need to change, update the given-issue skill, not this orchestrator.

## Safety rules

Do not:

- select more than one issue unless the user explicitly asks
- work on a different issue after selection
- modify files before the given-issue skill starts
- stage unrelated changes
- commit unrelated changes
- push unless the user explicitly asked for pushing or the active project instructions require it

If the selected issue becomes unsuitable during given-issue inspection, stop and report why. Do not automatically select another issue unless the user asked for a full retry.

## Final response format

Use the final response format from:

```text
~/.ai/skills/20-repository-workflows/clerkwork-work-on-issue/SKILL.md
```

Also include the selection reason from:

```text
~/.ai/skills/20-repository-workflows/clerkwork-select-next-issue/SKILL.md
```

Final response should include:

1. selected issue number and title
2. selection reason
3. what changed
4. validation commands run and their results
5. commit hash and commit message
6. whether anything remains open or blocked

If no issue was selected, report:

- that no safe actionable issue was found
- which issues were inspected, when available
- why they were skipped
- the best next action
