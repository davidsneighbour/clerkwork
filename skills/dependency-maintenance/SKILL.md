---
id: dependency-maintenance
name: dependency-maintenance
title: Clerkwork Dependency Maintenance
type: skill
description: Safely maintain npm dependencies in a single-package repository or npm monorepo. Use when asked to inspect outdated packages, update dependency ranges and lockfiles, assess or fix npm audit findings, validate the result, and optionally create a conventional dependency-update commit while preserving unrelated work.
---

Maintain npm dependencies without mixing unrelated work into the update.

## Boundaries

- Work only in the current repository.
- Support npm projects only. Stop on pnpm, Yarn, Bun, or ambiguous package-manager state unless the user explicitly asks to adapt the workflow.
- Preserve unrelated tracked and untracked work.
- Do not make unrelated source, formatting, or refactoring changes.
- Do not install maintenance tooling as a project dependency.
- Do not use `npm audit fix --force` without explicit approval.
- Do not treat a generic "update dependencies" request as approval for major upgrades.
- Do not merge, rebase, or use plain `git pull`.
- Do not commit when validation fails unless the user explicitly accepts the failure.
- Commit only when the request includes committing or clearly asks for a completed maintenance run.

## Track run state

Keep these facts for the final report:

```text
package_manager: npm / ambiguous / unsupported
repository_type: single package / npm workspaces / configured monorepo / ambiguous
upstream_branch: <branch or none>
sync_result: up to date / fast-forwarded / no upstream / diverged / failed / skipped
stash_created: yes / no
stash_ref: <ref or none>
package_files_changed: <list>
lockfiles_changed: <list>
major_upgrades: <list>
audit_fixes_applied: yes / no
validation_commands: <command and result list>
commit_created: yes / no
commit_hash: <hash or none>
```

## Workflow

### 1. Inspect repository instructions and state

Read repository guidance such as `AGENTS.md`, `CONTRIBUTING.md`, and relevant documentation before changing files.

Run:

```bash
git rev-parse --show-toplevel
git branch --show-current
git status --short
node --version
npm --version
```

Inspect package-manager markers:

```bash
find . -maxdepth 3 \
  \( -name package.json -o -name package-lock.json -o -name npm-shrinkwrap.json \
  -o -name pnpm-lock.yaml -o -name yarn.lock -o -name bun.lock -o -name bun.lockb \) \
  -not -path "*/node_modules/*" -not -path "*/.git/*"
npm pkg get packageManager workspaces 2>/dev/null || true
```

Classify the project:

- Continue as npm when `package-lock.json` or `npm-shrinkwrap.json` exists, `packageManager` identifies npm, or the user explicitly identifies npm.
- Stop as unsupported when only another package manager's lockfile exists.
- Stop as ambiguous when multiple package-manager lockfile types exist.
- Stop when no `package.json` exists.

### 2. Determine repository shape

Inspect npm-check-updates configuration:

```bash
find . -maxdepth 3 \
  \( -name ".ncurc" -o -name ".ncurc.json" -o -name ".ncurc.yml" \
  -o -name ".ncurc.yaml" -o -name ".ncurc.js" -o -name "ncu.config.js" \
  -o -name "ncu.config.cjs" -o -name "ncu.config.mjs" \) \
  -not -path "*/node_modules/*" -not -path "*/.git/*"
```

Use this decision model:

- **Single package:** one root package manifest; update the root manifest and lockfile.
- **npm workspaces:** root `package.json` declares workspaces; update included workspace manifests and refresh the root lockfile.
- **Configured monorepo:** an existing npm-check-updates configuration defines package-file scope; run from the repository root and respect it.
- **Ambiguous monorepo:** multiple manifests exist without workspaces or clear configuration; stop and ask which package paths are in scope.

Do not update arbitrary nested manifests.

### 3. Protect existing work

Inspect both staged and unstaged dependency changes:

```bash
git status --short
git diff --stat
git diff --cached --stat
git diff -- '**/package.json' '**/package-lock.json' '**/npm-shrinkwrap.json'
git diff --cached -- '**/package.json' '**/package-lock.json' '**/npm-shrinkwrap.json'
```

Handle the result as follows:

- Continue when the tree is clean.
- Continue with unrelated untracked files, but leave them untouched.
- Stop when package manifests or lockfiles already have changes. Ask whether to include them, commit them separately, or use them as the update baseline.
- For unrelated tracked changes, prefer asking the user to commit or stash them.
- Auto-stash only when the user requested an automated end-to-end run, the changes are clearly unrelated, and hiding them cannot affect the maintenance result.

When auto-stashing:

```bash
git stash push --message "pre-dependency-maintenance" --
git stash list --max-count=1
```

Do not include untracked files unless explicitly requested. Record the actual stash ref and never pop it automatically.

### 4. Synchronize safely

Synchronize only after dependency files are clean and unrelated tracked changes are absent or safely stashed.

```bash
git rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null || true
git fetch --prune
git status --branch --short
```

- If there is no upstream, record `no upstream` and continue.
- If local and upstream are equal, record `up to date`.
- If the branch is only behind, run `git pull --ff-only`.
- If the branch has diverged, stop. Do not merge or rebase.
- If fetch or pull fails, stop and report the failure.

### 5. Inspect available updates

Run from the repository root:

```bash
npm outdated || true
npx --yes npm-check-updates
```

Allow an existing npm-check-updates configuration to control package scope. Do not add npm-check-updates to `package.json`.

Classify proposed updates:

- patch and minor updates
- major updates
- production dependencies
- development dependencies
- high-risk tooling such as frameworks, build tools, TypeScript, test runners, linters, and deployment packages

### 6. Choose update scope

Follow an explicit user scope when provided.

Otherwise:

- Apply patch and minor updates by default.
- Present major updates before applying them.
- Apply majors without another prompt only when the user explicitly asked for all/latest dependencies or clearly authorized major upgrades.

For patch and minor updates:

```bash
npx --yes npm-check-updates --target minor --upgrade
npm install
```

For explicitly approved major updates:

```bash
npx --yes npm-check-updates --upgrade
npm install
```

For workspaces, use workspace-aware behavior supported by the installed npm-check-updates version or the repository configuration. If neither defines safe scope, stop instead of guessing.

After installation:

```bash
git status --short
git diff --stat
git diff -- '**/package.json' '**/package-lock.json' '**/npm-shrinkwrap.json'
```

Verify that changes are limited to intended dependency manifests and lockfiles. Record exact changed files and version transitions.

### 7. Audit dependencies

Run:

```bash
npm audit || true
```

Use `npm audit --json` when structured details are needed, writing temporary output outside the repository when practical.

Before applying audit fixes, inspect the proposed remediation:

```bash
npm audit fix --dry-run || true
```

Run `npm audit fix` only when its proposed changes are non-breaking and remain inside the approved dependency scope:

```bash
npm audit fix
git diff --stat
git diff -- '**/package.json' '**/package-lock.json' '**/npm-shrinkwrap.json'
npm audit || true
```

After `npm audit fix`, inspect the diff again. If it changed files outside the approved dependency scope or introduced unapproved major changes, stop and report the situation before committing.

Do not automatically fix findings when:

- `--force` is required
- a major upgrade is required but not approved
- framework or build-tool changes may be breaking
- no safe fix is available
- the remediation risk exceeds the vulnerability risk

For remaining findings, report package, severity, direct or transitive status, safe-fix availability, and recommended action.

### 8. Validate the repository

Inspect repository scripts and documented checks:

```bash
npm pkg get scripts
```

Run the repository's documented validation gate. When no project-specific order exists, use applicable scripts in this order:

```text
test
lint
typecheck
check
build
```

Run only scripts that exist. Prefer root orchestration scripts in workspaces and monorepos.

Record every command and whether it passed, failed, or was skipped. If validation fails:

- stop before committing
- preserve the dependency changes for inspection
- report whether the failure appears update-related
- provide exact rollback commands using only changed dependency files

### 9. Review and optionally commit

Review staged and unstaged state:

```bash
git status --short
git diff --check
git diff --stat
git diff -- '**/package.json' '**/package-lock.json' '**/npm-shrinkwrap.json'
```

Ensure no temporary audit artifacts or unrelated files are included.

If a commit is authorized and validation passed:

1. Build the exact list of intended changed dependency files.
2. Stage those paths explicitly with `git add -- <paths>`.
3. Inspect `git diff --cached --stat` and `git diff --cached --check`.
4. Commit with a Conventional Commit subject:

```text
build(deps): update dependencies
```

Include a concise body covering:

- updated package and lockfiles
- major upgrades, if any
- audit result and remaining findings
- validation commands

Capture the commit hash:

```bash
git rev-parse --short HEAD
```

Never stage through broad globs, `git add .`, or `git add -A`.

### 10. Report

Report:

- status: completed, stopped, or failed
- branch and upstream sync result
- repository type and package manager
- package and lockfiles changed
- production and development updates
- major upgrades
- audit fixes and remaining findings
- validation results
- commit hash, or why no commit was created
- unrelated files left untouched
- manual follow-up recommendations

When a stash was created, add a dedicated note with the actual ref and these recovery commands:

```bash
git stash list
git stash show --stat <stash-ref>
git stash pop <stash-ref>
```

Never omit a created stash from the report.
