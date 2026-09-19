---
id: work-through-issues
name: work-through-issues
title: Work through GitHub Issues
type: skill
description: Continuously work through open GitHub issues until no suitable actionable issues remain, committing each fix individually. Orchestrates select-next-issue and work-on-issue in a loop.
---

## Description

Use this skill when the user asks to continuously work through open GitHub issues until no suitable actionable issues remain.

This skill is an orchestrator.

It repeatedly uses:

```text
~/.ai/skills/20-repository-workflows/select-next-issue/SKILL.md
```

and:

```text
~/.ai/skills/20-repository-workflows/work-on-issue/SKILL.md
```

The goal is to select one issue, complete it, commit it, then select the next issue and repeat until the selector reports that no safe actionable issue remains.

Do not duplicate selection or implementation logic in this skill.

## Trigger examples

Use this skill for requests such as:

- "work through open issues"
- "keep working on issues until none are left"
- "fix all actionable open issues"
- "go through the backlog and commit each fix"
- "work continuously on GitHub issues"
- "clear the issue queue"

Do not use this skill when the user asks to fix only one issue. In that case, use one of:

```text
~/.ai/skills/20-repository-workflows/work-on-next-issue/SKILL.md
~/.ai/skills/20-repository-workflows/work-on-issue/SKILL.md
```

## High-level workflow

Repeat this loop:

1. Run `~/.ai/skills/20-repository-workflows/select-next-issue/SKILL.md`.
2. If no issue is selected, stop.
3. Extract the selected issue number.
4. Run `~/.ai/skills/20-repository-workflows/work-on-issue/SKILL.md` with that issue number.
5. If the issue was completed and committed, continue to the next loop.
6. If the issue could not be completed, stop and report the blocker.

## Preconditions

Before starting the loop:

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

4. Inspect the working tree.

   ```bash
   git status --short
   ```

5. Read local project instructions before working, especially:

   - `AGENTS.md`
   - `CLAUDE.md`
   - `.github/copilot-instructions.md`
   - `.vscode/instructions/**/*.md`
   - `README.md`
   - `CONTRIBUTING.md`

6. Do not overwrite, stage, or commit unrelated user changes.

7. If the repository has its own issue, branch, commit, test, or release rules, follow those rules over this generic skill.

## Loop rules

Each loop iteration must work on exactly one issue.

For each iteration:

1. Run the issue selector.

   ```text
   ~/.ai/skills/20-repository-workflows/select-next-issue/SKILL.md
   ```

2. Expect selector output in this format:

   ```text
   Selected issue: #ISSUE_NUMBER
   Title: ISSUE_TITLE
   Reason: SHORT_SELECTION_REASON
   ```

3. If the selector returns `Selected issue: none`, stop the loop.

4. Extract the issue number.

5. Run the given-issue implementation skill.

   ```text
   ~/.ai/skills/20-repository-workflows/work-on-issue/SKILL.md
   ```

6. Pass the selected issue number as the required input.

   Example handoff:

   ```text
   Work on issue #123 using ~/.ai/skills/20-repository-workflows/work-on-issue/SKILL.md.
   ```

7. After the given-issue skill completes, confirm that a commit was created.

   ```bash
   git log -1 --oneline
   ```

8. Confirm the working tree state before starting the next loop.

   ```bash
   git status --short
   ```

9. Continue only when the working tree is clean or contains only unrelated pre-existing user changes that must remain untouched.

## Stop conditions

Stop immediately when any of the following happens:

- the selector reports no safe actionable issue
- the selected issue is closed, inaccessible, blocked, or unsuitable
- the given-issue skill cannot complete the issue safely
- validation fails for a reason that cannot be resolved within the selected issue scope
- the working tree contains unexpected changes after an iteration
- the next issue depends on secrets, production systems, private credentials, or external accounts
- project instructions require manual review before continuing
- the user explicitly requested a maximum number of issues and that number has been reached

Do not automatically skip a failed selected issue and continue to another issue. Stop and report the blocker.

## Optional issue limit

If the user provides a maximum number of issues, respect it.

Examples:

```text
work through 3 issues
fix up to 5 open issues
work on issues until none are left, maximum 10
```

When no limit is provided, continue until the selector returns no suitable issue or a stop condition is reached.

## Branch handling

Branch handling is owned by:

```text
~/.ai/skills/20-repository-workflows/work-on-issue/SKILL.md
```

This orchestrator must not create branches directly.

If the given-issue skill creates one branch per issue, continue following that project convention.

If project instructions require a single branch for a batch of issue fixes, follow the project instructions.

## Commit rules

Commit creation is owned by:

```text
~/.ai/skills/20-repository-workflows/work-on-issue/SKILL.md
```

Each completed issue must have its own commit.

Each commit must:

- use a Conventional Commits message
- mention the fixed issue number
- include a closing keyword so the issue closes when pushed

Preferred commit body format:

```text
Closes #ISSUE_NUMBER
```

Do not squash multiple unrelated issues into one commit unless project instructions explicitly require it.

Do not push unless the user explicitly asked for pushing or the active project instructions require it.

## Validation rules

Validation is owned by:

```text
~/.ai/skills/20-repository-workflows/work-on-issue/SKILL.md
```

Validation must be run for each issue according to the given-issue skill and local project instructions.

If full validation is expensive, still run the most relevant validation for each issue. Run broader validation before the final summary when practical.

Do not continue to the next issue after a failed validation unless the failure is clearly unrelated, documented, and allowed by project instructions.

## Do not duplicate subskill logic

This skill must not define its own detailed issue-ranking logic.

That belongs to:

```text
~/.ai/skills/20-repository-workflows/select-next-issue/SKILL.md
```

This skill must not define its own detailed implementation, staging, validation, or commit logic.

That belongs to:

```text
~/.ai/skills/20-repository-workflows/work-on-issue/SKILL.md
```

If those rules need to change, update the subskills.

## Progress reporting

After each completed issue, record:

- issue number
- issue title
- selection reason
- commit hash
- validation result
- any notes or limitations

Keep this record for the final response.

## Final response format

When the loop stops, report:

1. total number of issues completed
2. list of completed issues with commit hashes
3. validation commands run and their results
4. reason the loop stopped
5. any remaining blocker or manual follow-up

Use this format:

```text
Completed issues: NUMBER

Completed:
- #123 ISSUE_TITLE — COMMIT_HASH — COMMIT_MESSAGE
- #124 ISSUE_TITLE — COMMIT_HASH — COMMIT_MESSAGE

Validation:
- COMMAND: PASS
- COMMAND: PASS

Stopped because:
REASON

Remaining follow-up:
FOLLOW_UP_OR_NONE
```

If no issues were completed, use this format:

```text
Completed issues: 0

Stopped because:
REASON

Inspected:
ISSUES_OR_SELECTOR_SUMMARY

Remaining follow-up:
FOLLOW_UP_OR_NONE
```
