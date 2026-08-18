---
id: clerkwork-osv-scan
name: clerkwork-osv-scan
title: Clerkwork OSV Vulnerability Scan
type: skill
description: Scan dependencies for known vulnerabilities with osv-scanner, auto-apply safe non-breaking fixes, file GitHub issues for the rest, and track accepted/fixed/workaround decisions in a committed ledger so repeat runs never re-file the same vulnerability. Use when asked to run an OSV scan, check dependencies for vulnerabilities, triage osv-scanner findings, or decide whether to accept, fix, or work around a reported vulnerability.
---

Scan this repository's dependencies with `osv-scanner`, resolve what can be resolved automatically, and hand everything else to GitHub Issues — without ever losing track of a prior decision.

## Boundaries

- Run only in the current repository.
- Stop if `osv-scanner` is not installed (`osv-scanner --version`); tell the user how to install it rather than falling back to another tool.
- This skill sends `package-lock.json` dependency metadata to the public `https://api.osv.dev/v1/querybatch` endpoint. Only run it when explicitly invoked — do not wire it into git hooks, `package.json` scripts, or CI. That trust-boundary decision is recorded in `memories/osv-scan.md` (see [#16](https://github.com/davidsneighbour/ai/issues/16)).
- Auto-apply only safe, non-breaking fixes (a patch/minor version bump that resolves the reported vulnerability). Never auto-apply a major upgrade; hand it to a GitHub issue instead.
- Never invent an "accepted" or "workaround" decision yourself. Those require the user's explicit call, made either in conversation or by how a linked GitHub issue was closed.
- File at most one GitHub issue per vulnerability ID. Always search existing issues (open and closed) before creating a new one.
- Treat `memories/osv-scan-ledger.json` as the single source of truth for what has already been triaged. Update the specific entry only — never rewrite unrelated entries, never delete history.
- Do not commit changes without the user's confirmation.

## Ledger format

`memories/osv-scan-ledger.json`:

```json
{
  "version": 1,
  "entries": [
    {
      "id": "GHSA-xxxx-xxxx-xxxx",
      "aliases": ["CVE-2024-00000"],
      "package": "example-package",
      "ecosystem": "npm",
      "severity": "high",
      "status": "accepted",
      "decided_date": "2026-07-05",
      "github_issue": 42,
      "reason": "Free text: why accepted, or how the workaround/fix resolves it",
      "fixed_version": "2.3.1",
      "review_after": "2026-10-01"
    }
  ]
}
```

`status` is one of:

- `open` — a GitHub issue exists and is unresolved. `github_issue` is set; nothing else to do until the issue closes.
- `accepted` — risk accepted by the user. Skip in future scans unless `review_after` has passed.
- `fixed` — resolved by upgrading the dependency to `fixed_version`. Kept for history; skip in future scans.
- `workaround` — mitigated indirectly (e.g. an `overrides`/`resolutions` pin) because the direct dependency has not shipped a native fix yet. Re-checked every run; promote to `fixed` once the override is no longer needed.

`memories/osv-scan.md` holds the human-readable rationale for `accepted` and `workaround` entries — add a dated log entry there whenever one is created or changed.

## Track run state

```text
osv_scanner_version: <version or "missing">
findings_total: <count>
auto_fixed: <list of id/package/fixed_version>
issues_created: <list of id -> issue URL>
skipped_accepted: <count>
skipped_fixed: <count>
skipped_open: <count>
workarounds_reviewed: <count>
workarounds_promoted_to_fixed: <list>
needs_human_decision: <list of id -> reason>
ledger_changed: yes / no
notes_changed: yes / no
commit_created: yes / no
```

## Workflow

### 1. Preflight

```bash
osv-scanner --version
gh auth status
```

Stop and report if `osv-scanner` is missing. Stop and report if `gh` is not authenticated — issue filing needs it.

Ensure the ledger files exist; if missing, create them exactly as shown in "Ledger format" and with the header structure from `memories/osv-scan.md`. Never overwrite either file if it already has content.

### 2. Run the scan

```bash
osv-scanner scan --format json -r . > /tmp/osv-scan-result.json
```

Write the JSON output outside the repository. Parse `results[].packages[].vulnerabilities[]`, collecting for each: primary `id`, `aliases`, package `name`, `ecosystem`, installed version, `severity` (prefer `database_specific.severity`, else derive a rough band from CVSS if present, else `unknown`), and any `severity`/`affected[].ranges` data that indicates a fixed version.

### 3. Cross-reference the ledger

Load `memories/osv-scan-ledger.json`. For each finding, match by `id` or any `aliases` against existing entries:

- **`accepted`** and (`review_after` unset or in the future): skip, count as `skipped_accepted`.
- **`accepted`** and `review_after` has passed: add to `needs_human_decision` — ask the user whether to keep accepting, and update `decided_date`/`review_after` or change status based on their answer.
- **`fixed`**: skip, count as `skipped_fixed`. (osv-scanner should not normally re-report these; if it does, treat as a regression and escalate via `needs_human_decision` rather than silently re-fixing.)
- **`workaround`**: check whether the direct dependency now ships a version that removes the need for the override — inspect `npm view <direct-package> versions --json` and whatever changelog/advisory data is available. If resolved, update the entry to `status: fixed`, set `fixed_version`, remove the override from `package.json` if one was added for this purpose, and log the change in `memories/osv-scan.md`. Otherwise leave as-is and count as `workarounds_reviewed`.
- **`open`**: check the linked issue:

  ```bash
  gh issue view <github_issue> --json state,labels,stateReason
  ```

  - Still open: skip, count as `skipped_open`.
  - Closed with a `resolution:wont-fix` or `resolution:invalid` label: ask the user to confirm this means the risk is accepted; on confirmation, update the entry to `status: accepted` with `reason` and `decided_date` from the closure, and log it in `memories/osv-scan.md`.
  - Closed with `resolution:completed` (or otherwise closed as done): ask the user whether it was resolved by a direct dependency upgrade (`status: fixed`, record `fixed_version`) or by a workaround/override (`status: workaround`, record what was overridden). Log the decision in `memories/osv-scan.md`.
- **No matching entry**: continue to step 4.

### 4. Attempt a safe auto-fix for new findings

For each finding with no ledger entry, check whether a non-major fixed version exists:

```bash
osv-scanner fix -M package.json -L package-lock.json --non-interactive --strategy=in-place
```

Or, for a single direct dependency, `npm view <package> versions --json` to find the lowest non-major version that clears the advisory.

- If a safe fix applies cleanly: install it, run `npm install`, then re-run the scan for that package to confirm the finding is gone, and run the repository's validation gate (`npm run ai:check`). If it passes, add a `fixed` ledger entry (`fixed_version`, `decided_date` today, `reason: "auto-fixed by clerkwork-osv-scan"`), do not file an issue, and record it in `auto_fixed`.
- If validation fails after the fix, or only a major upgrade resolves it, or no fix exists at all: revert any partial fix attempt and continue to step 5.

### 5. File a GitHub issue for everything else

Before creating anything, search for an existing issue so the same vulnerability is never filed twice:

```bash
gh issue list --repo <owner>/<repo> --state all --search "<id> in:title"
```

If found, link it into the ledger as `status: open` (or reconcile per step 3 if it's already closed) instead of creating a new one.

Otherwise create:

```bash
gh issue create --repo <owner>/<repo> \
  --title "chore(deps): <id> in <package> (<ecosystem>)" \
  --label "type:dependencies" --label "<prio-label>" \
  --body "<vulnerability summary>"
```

Map severity to the priority label:

```text
critical -> prio:critical
high     -> prio:high
moderate/medium -> prio:medium
low      -> prio:low
unknown  -> prio:medium
```

Issue body must include: package name, ecosystem, installed version, severity, aliases/CVE IDs, a short summary, references/advisory links, and — if step 4 found only a major-version fix — that version and why it wasn't auto-applied. Add a closing note explaining that closing with `resolution:wont-fix`/`resolution:invalid` records this as accepted, and closing with `resolution:completed` records it as fixed or worked around, on the next scan.

Record the new entry as `status: open` with the created `github_issue` number.

### 6. Update the ledger and notes

Write back `memories/osv-scan-ledger.json` with only the entries that changed this run (new, promoted, or reconciled). Append dated log entries to `memories/osv-scan.md` for every `accepted` or `workaround` decision made or changed this run, in the format already shown in that file.

### 7. Review and optionally commit

```bash
git status --short
git diff -- memories/osv-scan-ledger.json memories/osv-scan.md package.json package-lock.json
```

If a commit is authorized, stage only the changed files above (plus any dependency files touched by an auto-fix) and commit with a Conventional Commit subject, e.g.:

```text
fix(deps): resolve <id> in <package>
```

or

```text
chore(deps): triage OSV scan findings
```

Never stage through broad globs.

### 8. Report

Report:

- `osv-scanner` version and total findings
- auto-fixed packages (with old/new version)
- newly filed issues, with URLs
- counts skipped as already accepted / fixed / open
- workarounds reviewed and any promoted to fixed
- anything left in `needs_human_decision`, with the specific question to resolve
- whether the ledger/notes changed and whether a commit was created
