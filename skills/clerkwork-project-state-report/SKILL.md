---
id: clerkwork-project-state-report
name: clerkwork-project-state-report
title: Clerkwork Project State Report
type: skill
description: Analyse a repository's current state, safely fetch and fast-forward remote updates, report what changed since a supplied date phrase or since the user last worked on the project, include GitHub PR and issue activity, and recommend what to do next. Use when asked for a project state report, project catch-up, what changed since yesterday or last week, what happened since we last worked, update from remote and summarize, or a clerkwork-project-task-triage-style status with remote and GitHub activity.
---

Produce a readable project catch-up report without mixing it with implementation work.

## Boundaries

- Work only in the current repository.
- Preserve unrelated tracked and untracked work.
- Do not merge, rebase, or create merge commits.
- Do not implement fixes unless the user explicitly asks.
- Do not create, update, close, or label GitHub issues or PRs unless the user asks.
- Do not run expensive checks unless repository instructions or the user request make them necessary.
- When the report finds tracking work that should be reconciled, recommend using `clerkwork-project-task-triage` rather than silently doing that work.

## Track Run State

Keep these facts for the final report:

```text
repository: <owner/name or path>
branch: <current branch>
upstream: <upstream ref or none>
since_input: <user phrase or inferred>
since_resolved: <absolute timestamp/date and reason>
pre_sync_head: <sha>
post_sync_head: <sha>
sync_result: up to date / fast-forwarded / no upstream / diverged / dirty-blocked / failed
remote_commits: <count and range>
local_unpushed_commits: <count>
open_issues: <count or unavailable>
open_prs: <count or unavailable>
changed_files: <summary>
taskable_items: <count and source>
recommendation: <next action or do nothing>
```

## Workflow

### 1. Read Repository Instructions

Inspect repository guidance before touching remote state:

```bash
git rev-parse --show-toplevel
git status --short
find .. -maxdepth 2 -name AGENTS.md -o -name CLAUDE.md -o -name CONTRIBUTING.md
```

Read applicable instruction files, including project-root `AGENTS.md`.

If the project has a resume or interrupted-work protocol, follow it before doing unrelated catch-up work.

### 2. Resolve the Since Window

Resolve the report window before syncing.

When the user gives a concrete or relative phrase, convert it to an absolute date or timestamp and state the resolved value in the report. Examples:

- `yesterday`: start of yesterday in the user's or repository's local timezone
- `last week`: the previous calendar week unless the user clearly means the last seven days
- `since 2026-07-01`: that exact date at local start of day
- `since the last release`: the latest reachable release tag or GitHub release

When the user says `since we last worked on it`, infer the baseline in this order:

1. Capture `pre_sync_head` before fetching.
2. Identify the current branch upstream with `git rev-parse --abbrev-ref --symbolic-full-name '@{u}'`.
3. Use the timestamp of `pre_sync_head` as the default baseline.
4. If configured Git identity is available, inspect recent commits and prefer the newest commit authored or committed by that identity on the current branch.
5. If remote has moved beyond the local branch, treat commits in `pre_sync_head..upstream` as the primary "what happened while we were away" range.
6. If no reliable authored commit or upstream range exists, say that the baseline is inferred from the current HEAD before sync.

Useful commands:

```bash
git rev-parse HEAD
git log -1 --format='%H%x09%cI%x09%an%x09%s'
git config user.name
git config user.email
git log --date=iso --format='%H%x09%aI%x09%an%x09%ae%x09%s' --max-count=30
```

### 3. Capture Pre-Sync State

Record the local state before fetching:

```bash
git branch --show-current
git status --branch --short
git remote -v
git rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null || true
git log --oneline --decorate --max-count=10
```

If the working tree has unrelated changes, continue with read-only reporting but do not pull unless a fast-forward is clearly safe and the changes cannot be affected. Prefer reporting `dirty-blocked` over risking user work.

### 4. Fetch and Fast-Forward Safely

Fetch remote state:

```bash
git fetch --all --prune
git status --branch --short
```

Then classify sync state:

- `no upstream`: no tracking branch exists; continue with local and GitHub report.
- `up to date`: local and upstream are equal.
- `fast-forwarded`: local branch is only behind and the working tree is safe; run `git pull --ff-only`.
- `diverged`: local and upstream both have unique commits; stop syncing and report the divergence.
- `dirty-blocked`: working tree changes make a pull unsafe; do not stash automatically.
- `failed`: fetch or fast-forward failed; report the command and error.

Use commit counts to decide:

```bash
git rev-list --left-right --count HEAD...@{u} 2>/dev/null || true
```

After any fast-forward, record `post_sync_head`.

### 5. Collect Git Change Evidence

Summarize commits and files changed in the resolved window.

Prefer ranges that match the baseline:

- For remote catch-up after fast-forward: `pre_sync_head..HEAD`
- For a date phrase: `--since=<resolved timestamp>`
- For divergence: compare both sides with `HEAD..@{u}` and `@{u}..HEAD`

Useful commands:

```bash
git log --date=short --format='%h%x09%ad%x09%an%x09%s' <range>
git diff --stat <range>
git diff --name-status <range>
git shortlog -sne <range>
```

Group the result by area when possible: source, tests, docs, dependencies, configuration, build, release, or tracking.

### 6. Collect GitHub Activity

Use `gh` when available and authenticated. If GitHub data is unavailable, say so and continue from git evidence.

Identify the repository:

```bash
gh repo view --json nameWithOwner,url,defaultBranchRef
```

Collect open state:

```bash
gh issue list --state open --limit 100 --json number,title,labels,assignees,updatedAt,url
gh pr list --state open --limit 100 --json number,title,author,headRefName,baseRefName,updatedAt,isDraft,reviewDecision,url
```

Collect activity since the resolved window:

```bash
gh issue list --state all --search "updated:>=YYYY-MM-DD" --limit 100 --json number,title,state,author,labels,updatedAt,closedAt,url
gh pr list --state all --search "updated:>=YYYY-MM-DD" --limit 100 --json number,title,state,author,mergedAt,closedAt,updatedAt,url
```

For merged PRs or closed issues relevant to the report, inspect enough detail to explain what changed:

```bash
gh pr view <number> --json number,title,author,mergedAt,additions,deletions,changedFiles,files,reviews,url
gh issue view <number> --json number,title,state,author,labels,comments,closedAt,url
```

Report who did what from commit authors, PR authors, issue authors, reviewers, and closers when available. Do not over-attribute when evidence only shows who opened or updated an item.

### 7. Detect Taskable Items

Look for taskable follow-up signals:

- open GitHub issues
- open PRs needing review, changes, or merge attention
- failed or pending checks on relevant PRs or the current branch
- TODO or roadmap drift discovered from repository files
- new failing validation, dependency, audit, or security signals observed during lightweight checks
- remote changes that introduced obvious follow-up work, such as TODO comments, skipped tests, failing CI notes, deprecations, or incomplete migrations

Use existing repository tracking conventions. If GitHub Issues are the project's source of truth, prefer recommending issue creation or `clerkwork-project-task-triage` instead of keeping tasks only in prose.

### 8. Recommend Next Action

Choose one primary recommendation:

- `Do nothing`: use when remote is current, no open issues or PRs need attention, no drift is detected, and no taskable items were found.
- `Review PRs`: use when PRs are open or updated and need attention.
- `Triage tasks`: use when TODO, ROADMAP, or GitHub issue state appears stale or incomplete.
- `Work on issue #N`: use when one open issue is clearly the best next task.
- `Investigate`: use when sync failed, branches diverged, checks failed, or the repo state is ambiguous.
- `Validate`: use when remote changes landed and the next useful action is running the project's normal quality gate.

Explain why the recommendation follows from the evidence.

## Report Format

Keep the report compact and readable:

```text
Project State
- Repository:
- Branch:
- Sync:
- Since:

What Changed
- <commit/PR/file-area summary with people attached where known>

GitHub Activity
- Issues:
- PRs:

Taskable Items
- <issue, PR, validation, or tracking follow-up>
- None found.

Recommendation
- <one primary recommendation and short rationale>

Notes
- <blocked sync, unavailable GitHub data, inferred baseline, or validation not run>
```

Only include `Notes` when there is something useful to disclose.
