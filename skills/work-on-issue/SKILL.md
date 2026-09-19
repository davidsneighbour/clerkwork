---
id: work-on-issue
name: work-on-issue
title: Work on Given GitHub Issue
type: skill
description: Inspect a specific GitHub issue by number, implement the required change, validate, and commit with a Conventional Commits message that closes the issue.
---

## Description

Use this skill when the user asks to work on a specific GitHub issue by number.

The goal is to inspect the specified issue, implement the required change, validate the repository, and commit the result with a Conventional Commits message that closes the issue when pushed.

## Trigger examples

Use this skill for requests such as:

- "work on issue #123"
- "fix issue 123"
- "solve GitHub issue #123"
- "implement issue 123"
- "take care of #123"
- "work on this issue: 123"

This skill may also be called by `~/.ai/skills/20-repository-workflows/work-on-next-issue/SKILL.md` after issue selection.

## Required input

The user or calling skill must provide a GitHub issue number.

Accepted formats include:

```text
#123
123
issue 123
GH-123
```

Extract the issue number before starting work.

If no issue number is present, do not select an issue automatically. Ask for the issue number or use `~/.ai/skills/20-repository-workflows/select-next-issue/SKILL.md` only when the user explicitly asked to work on an unspecified open issue.

## Preconditions

Before changing files:

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

5. Do not overwrite, stage, or commit unrelated user changes.

6. Read local project instructions before working, especially:

   - `AGENTS.md`
   - `CLAUDE.md`
   - `.github/copilot-instructions.md`
   - `.vscode/instructions/**/*.md`
   - `README.md`
   - `CONTRIBUTING.md`

7. If the repository has its own issue, branch, commit, test, or release rules, follow those rules over this generic skill.

## Issue inspection

Inspect the specified issue in full.

```bash
gh issue view ISSUE_NUMBER \
  --comments \
  --json number,title,body,labels,assignees,state,comments,url
```

Verify that the issue exists and is open.

If the issue is closed, do not reopen or work on it unless the user explicitly asked to continue anyway. Report that the issue is already closed.

If the issue does not exist or cannot be accessed, report the error and stop.

If `PROJECT.md` exists, read it for context only.

```bash
test -f PROJECT.md && sed -n '1,240p' PROJECT.md
```

Use `PROJECT.md` to understand:

- related milestones
- project priorities
- linked topics
- implementation direction
- constraints or sequencing notes

Do not switch to another issue based on `PROJECT.md`.

## Issue suitability rules

Work only on the specified issue.

Do not select a different issue, even when another issue appears higher priority.

Before implementation, check whether the specified issue is actionable.

Proceed when the issue has at least one of:

- a clear bug report
- a clear feature request
- acceptance criteria
- linked failing behaviour
- documentation task
- maintenance task
- enough context in comments, labels, or linked files to infer the required change safely

Stop and report the blocker when the issue is:

- labelled `blocked`, `waiting`, `wontfix`, `duplicate`, `invalid`, or similar
- too vague to implement safely
- dependent on secrets, production systems, private credentials, or external accounts
- mostly a product, strategy, or design decision
- unrelated to the current repository

Do not invent requirements to force a commit.

## Branch handling

Inspect the current branch.

```bash
git branch --show-current
```

If already on a suitable work branch, continue there.

If on `main`, `master`, `develop`, or another protected/default branch, create a dedicated branch.

```bash
git switch -c issue-ISSUE_NUMBER-short-slug
```

Use a short, lowercase, hyphenated slug based on the issue title.

Example:

```bash
git switch -c issue-123-fix-token-refresh
```

## Implementation workflow

For the specified issue:

1. Restate the issue number, title, and expected outcome.
2. Inspect relevant files before editing.
3. Search the codebase for related code, tests, docs, and configuration.
4. Implement the smallest complete change that solves the issue.
5. Prefer existing project patterns over introducing new abstractions.
6. Add or update tests when the issue affects behaviour.
7. Add or update documentation when the issue changes usage, configuration, workflows, or public APIs.
8. Do not include unrelated cleanups.
9. Do not reformat unrelated files.
10. Do not modify generated files unless the project requires generated files to be committed.

Useful inspection commands:

```bash
git grep -n "SEARCH_TERM"
find . -maxdepth 3 -type f | sort
git diff --stat
git diff
```

## Validation workflow

Detect the project tooling from files such as:

- `package.json`
- `pnpm-lock.yaml`
- `package-lock.json`
- `yarn.lock`
- `bun.lockb`
- `go.mod`
- `composer.json`
- `pyproject.toml`
- `Cargo.toml`
- `Makefile`

Run the most relevant available validation commands.

For Node-based repositories, prefer project scripts from `package.json`.

Common commands:

```bash
npm run lint
npm test
npm run test
npm run build
npx astro check
```

Only run commands that make sense for the repository.

If validation fails:

1. inspect the error
2. fix issues caused by the current changes
3. rerun the relevant command
4. repeat until the current work passes or the remaining failure is clearly unrelated

Do not silently ignore failures.

If an unrelated pre-existing failure blocks validation, document it clearly in the final summary and do not include unrelated fixes unless they are necessary for the specified issue.

## Git staging rules

Before committing:

```bash
git status --short
git diff
```

Stage only files required for the specified issue.

```bash
git add path/to/file another/path
```

Do not stage unrelated user changes.

Review staged changes.

```bash
git diff --cached --stat
git diff --cached
```

## Commit message rules

Use a Conventional Commits message.

Choose the type based on the actual change:

- `fix` for bug fixes
- `feat` for user-facing features
- `docs` for documentation-only changes
- `test` for tests-only changes
- `refactor` for behaviour-preserving code changes
- `chore` for maintenance
- `ci` for workflow changes
- `build` for build-system changes

Use a concise scope when obvious.

The commit must close the specified issue when pushed.

Preferred format:

```text
fix(scope): concise summary

Closes #ISSUE_NUMBER
```

Examples:

```text
fix(auth): handle expired tokens during refresh

Closes #123
```

```text
feat(search): add filtering by label

Closes #456
```

```text
docs(workflows): document release issue handling

Closes #789
```

Create the commit.

```bash
git commit -m "fix(scope): concise summary" -m "Closes #ISSUE_NUMBER"
```

Do not push unless the user explicitly asked for pushing or the active project instructions require it.

## Final response format

After committing, report:

1. specified issue number and title
2. what changed
3. validation commands run and their results
4. commit hash and commit message
5. whether anything remains open or blocked

Keep the summary factual and concise.

If the specified issue cannot be completed, report:

- issue number and title, when available
- why work could not proceed
- what was inspected
- what would be needed next

Do not choose another issue unless the user explicitly asks.
