---
id: issues
name: issues
title: Clerkwork Issues
type: skill
description: Work with project issues using Patrick's GitHub-first issue workflow. Use when inspecting open issues, selecting what to work on next, working on a specific issue, continuing with the next issue, or working through multiple issues. Recognise natural requests such as "check open issues", "work on issue #123", "work on the next issue", and "continue working on issues".
---

This skill describes Patrick's issue-based project workflow. GitHub Issues is the canonical implementation because Patrick's projects normally use GitHub for repository hosting and issue tracking.

## Platform model

This workflow is GitHub-first.

Use GitHub terminology, behaviour, CLI commands, issue references, labels, milestones, comments, and closing semantics as the canonical implementation.

When another repository host or issue tracker is in use, preserve the workflow principles wherever practical and map GitHub-specific operations to the nearest available equivalents. For example, map issue numbers to ticket identifiers, GitHub labels to the service's classification mechanism, and closing references to the service's supported issue-linking or transition mechanism.

Do not reduce or generalise the GitHub workflow merely to make the skill theoretically portable. Adapt only the operations that the active system cannot support directly.

## Supporting skills

Use these Clerkwork skills when their responsibilities are needed:

- `labels` owns Patrick's issue label taxonomy and lifecycle classification.
- `commit` owns Conventional Commits message construction and commit-message review.

Do not duplicate their detailed rules here. Issue work orchestrates them.

## Intent routing

Infer the operation from the user's wording. The user does not need to name a mode.

### Inspect

Use inspection-only behaviour for requests such as:

- "check open issues"
- "show me the open issues"
- "review the issue queue"
- "what issues are open?"
- "what is happening with issue #123?"

Inspect and report. Do not implement work unless the request also asks for implementation.

### Select

Use selection-only behaviour for requests such as:

- "what should we work on next?"
- "pick the next issue"
- "select an issue"
- "find a suitable issue"

Return one suitable issue without modifying the repository.

### Work on a specific issue

Use specific-issue behaviour when the request identifies an issue, for example:

- "work on issue #123"
- "fix #123"
- "take care of #123"
- "continue issue #123"

Inspect that issue and work only on it unless the user explicitly broadens the scope.

### Work on the next issue

Use next-issue behaviour for requests such as:

- "work on the next issue"
- "pick an issue and fix it"
- "work on one open issue"
- "find something useful to fix"

Select one suitable issue, then run the common implementation workflow for that issue.

### Work through issues

Use continuous behaviour for requests such as:

- "continue working on issues"
- "work through the issues"
- "keep working on open issues"
- "fix all actionable open issues"
- "clear the issue queue"
- "work through 3 issues"

Repeatedly select and complete one issue at a time until a stop condition is reached or the user's issue limit is met.

## Repository preconditions

Before implementation work:

1. Confirm the current directory is a Git repository.
2. Identify the repository host and issue system.
3. Read repository instructions, especially `AGENTS.md` and any narrower applicable instruction files.
4. Check for repository workflow documents such as `PROJECT.md`, `README.md`, and `CONTRIBUTING.md` when they affect issue selection or implementation.
5. Inspect the working tree before changing files.
6. Preserve unrelated user changes.
7. Follow repository-specific branch, validation, commit, push, and release rules over this generic workflow.

For GitHub repositories, prefer the GitHub CLI when local command execution is available:

```bash
git rev-parse --show-toplevel
gh auth status
gh repo view --json nameWithOwner,url
git status --short
```

Do not create a branch merely because issue work has started. Follow the repository's own branch policy.

## Inspecting issues

For GitHub, list enough metadata to understand the queue:

```bash
gh issue list \
  --state open \
  --limit 100 \
  --json number,title,labels,assignees,updatedAt,createdAt,body,url
```

Inspect a specific issue and its discussion when needed:

```bash
gh issue view ISSUE_NUMBER \
  --comments \
  --json number,title,body,labels,assignees,state,comments,milestone,url
```

When issue lifecycle or classification matters, use `labels` to validate or update the issue's labels.

## Selecting the next issue

When selection is required, consider:

1. explicit priority labels
2. direct mention or priority in `PROJECT.md`
3. roadmap or current-milestone relevance
4. dependencies between issues
5. clear acceptance criteria
6. suitability for implementation in the current repository
7. ability to validate the result locally
8. unassigned work or work assigned to the current maintainer
9. older issues before newer issues when otherwise equal

Inspect enough promising candidates to make a defensible choice. Usually 3-5 candidates are sufficient.

Skip issues that are clearly:

- blocked
- waiting on unavailable information
- duplicates, invalid, cancelled, or intentionally not being fixed
- vague epics without an actionable next change
- dependent on unavailable secrets, production systems, private credentials, or external accounts
- primarily unresolved product, strategy, or design decisions
- unrelated to the repository
- impossible to validate safely in the current environment

For selection-only requests, return:

```text
Selected issue: #ISSUE_NUMBER
Title: ISSUE_TITLE
Reason: SHORT_SELECTION_REASON
```

If nothing suitable exists, report that no safe actionable issue was found and summarise why the leading candidates were skipped.

## Common implementation workflow

For each issue being implemented:

1. Fetch and read the full issue before changing code.
2. Confirm that it is open, actionable, and belongs to the current repository.
3. Read relevant project documentation and inspect the affected code before editing.
4. Use `labels` when issue classification or lifecycle state needs to be corrected or advanced.
5. Implement the smallest complete change that satisfies the issue.
6. Prefer existing project patterns over new abstractions.
7. Add or update tests when behaviour changes.
8. Add or update documentation when usage, configuration, workflow, or public APIs change.
9. Run the most relevant available validation.
10. Fix failures caused by the current work and rerun the relevant validation.
11. Inspect the final diff and stage only files belonging to the issue.
12. Use `commit` for the commit message and include the issue reference required by the repository workflow.
13. Verify the working tree before moving to another issue.

Do not include unrelated cleanups, unrelated formatting, or unrelated user changes.

## Validation

Detect the repository's actual tooling and prefer project-defined scripts.

For Node-based repositories, inspect `package.json` and use its scripts. Typical checks may include:

```bash
npm run lint
npm test
npm run test
npm run build
npx astro check
```

Only run checks that make sense for the repository.

Do not silently ignore failures. If a pre-existing unrelated failure prevents full validation, document it clearly and do not expand the issue scope merely to repair unrelated work.

## Commits and issue references

Each completed issue should normally produce its own atomic commit unless repository instructions explicitly require another structure.

Before committing:

```bash
git status --short
git diff
git diff --cached --stat
git diff --cached
```

Use the `commit` skill to construct or review the message.

For GitHub, use the repository's required issue-closing semantics. When no narrower project rule exists, prefer a Conventional Commits message with a closing footer:

```text
fix(scope): concise summary

Closes #123
```

Do not push unless the user requested it or repository instructions require it.

## Continuous issue work

When the user asks to continue working on issues or work through multiple issues:

1. Select exactly one suitable issue.
2. Complete the common implementation workflow for that issue.
3. Commit that issue separately.
4. Record the issue number, title, commit, and validation result.
5. Re-check repository and working-tree state.
6. Select the next issue from the current issue state, not from a stale initial list.
7. Repeat until a stop condition is reached.

If the user gives a maximum number of issues, stop at that limit.

Do not require every earlier issue, milestone, or category to be completely resolved before moving to independent later work. A blocker stops the sequence only when it prevents safe progress on the next suitable issue or repository instructions define it as a gate.

## Stop conditions

Stop continuous work when:

- no safe actionable issue remains
- the selected issue is blocked or cannot be completed safely
- validation fails for a reason that cannot be resolved within issue scope
- unexpected working-tree changes make further work unsafe
- the next work requires unavailable credentials, external systems, or a human decision
- repository instructions require manual review before continuing
- the user-specified issue limit has been reached

When one issue is blocked, do not automatically treat all later independent issues as blocked. If the user's request is explicitly to continue autonomously through issues, record the blocked issue and continue with another independent actionable issue unless repository instructions or dependency relationships make that unsafe.

## Issue lifecycle

Use `labels` whenever the repository uses Patrick's taxonomy.

Typical lifecycle handling is:

- before implementation: ensure classification is valid
- when active work starts: move the issue to the appropriate in-progress state
- when clarification blocks progress: represent the blocked/question state
- when implementation is complete but the issue remains open: use the appropriate completed-open state
- when closure occurs through the repository workflow: ensure closed-issue labels and resolution are valid

Do not manually close an issue when project instructions require closure through a commit, pull request, merge, or another automated mechanism.

## Reporting

For a single completed issue, report:

1. issue number and title
2. what changed
3. validation commands and results
4. commit hash and message, when committed
5. anything still open or blocked

For continuous work, report:

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

Keep reporting factual and concise.
