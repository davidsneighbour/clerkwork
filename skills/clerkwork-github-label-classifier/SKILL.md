---
id: clerkwork-github-label-classifier
name: clerkwork-github-label-classifier
title: Clerkwork GitHub Label Classifier
type: skill
description: Analyse GitHub issue text or issue metadata and select or apply labels from Patrick's category:value label taxonomy. Use when creating, triaging, reviewing, updating, or closing GitHub issues, or when validating whether an issue's existing labels correctly represent its type, workflow status, resolution, priority, and metadata.
---

Classify GitHub issues using the canonical label taxonomy in `references/label-taxonomy.yml`.

## Core model

Every managed label follows this syntax:

```text
category:value
```

Treat each category as a separate classification dimension. Do not choose labels by keyword alone. Infer the issue's meaning, current lifecycle state, and intended handling from all available evidence.

## Accepted input

Analyse any combination of:

- issue title
- issue body
- issue comments
- issue state
- existing labels
- linked pull requests or commits
- assignees and milestone
- explicit user instructions

When only plain issue text is provided, return recommendations without claiming that labels were applied.

When connected GitHub tooling is available and the user asks to update or apply labels, inspect the current issue first, compute the required changes, and then apply them.

## Classification procedure

1. Read `references/label-taxonomy.yml` completely.
2. Determine whether the issue is open or closed.
3. Identify the issue's primary acceptance criterion and classify its `type`.
4. For an open issue, classify its current `status`, required `prio`, and any applicable `meta` labels.
5. For a closed issue, classify its `resolution` and remove all open-only labels.
6. Use the narrowest matching label supported by evidence.
7. Preserve valid existing labels unless the issue meaning or lifecycle state has changed.
8. Remove labels that conflict with the selected label in a single-value category.
9. Do not invent labels outside the taxonomy.
10. Explain uncertain classifications and identify the missing evidence.

## Category semantics

### `type`

Describes the primary nature of the work requested or required.

- Select exactly one type for every issue, whether open or closed.
- Prefer the label that describes the intended change, not merely the file type involved.
- Use `type:chore` only when no more specific type applies.
- A bug fix that also adds regression tests remains `type:bug`, not `type:tests`.
- A dependency upgrade remains `type:dependencies`, even when it requires code changes.
- Use `type:security` for security hardening, vulnerabilities, unsafe behaviour, access control, secret exposure, or security-sensitive configuration.
- Use priority to represent urgency and scheduling, not as a formal security severity score.
- Use `type:design` for visual design, layout, branding, styling, themes, interaction presentation, or design-system work.
- Use `type:content` for user-facing editorial or marketing copy and content structure. Use `type:documentation` for technical, project, process, or usage documentation.

### `status`

Describes the issue's current workflow state while it is open.

- Select exactly one status for every open issue.
- Update it when the lifecycle state changes.
- Remove it when the issue closes.
- `status:blocked` takes precedence while meaningful progress cannot continue.
- `status:review` means implementation or analysis is ready for review or validation.
- `status:done` means an agent or contributor has finished the work, but the issue remains open because the change has not yet been merged, pushed, deployed, or otherwise closed.
- When an agent finishes work without closing the issue, set `status:done`.
- When an agent finishes and closes the issue in the same operation, skip `status:done` and apply `resolution:completed` directly.

Do not add `status:planned`, `status:waiting`, or `status:needs-info`:

- planned work is `status:confirmed` until implementation starts
- unanswered questions use `meta:question`
- a question that prevents progress uses `status:blocked` plus `meta:question`
- a question that does not prevent progress uses the otherwise correct status plus `meta:question`

### `resolution`

Describes why a closed issue was closed.

- Do not apply a resolution to an open issue.
- Apply exactly one resolution when closing an issue.
- `resolution:completed` means the requested work was completed and the issue is now closed.
- `resolution:cancelled` means previously intended or accepted work was deliberately withdrawn before completion.
- `resolution:superseded` means another decision, implementation, issue, or approach replaced this issue, without the issue merely being a duplicate report.
- `resolution:wont-fix` means the issue remains understood but there is a deliberate decision not to implement or fix it.
- `resolution:duplicate` means the same issue or request is already tracked elsewhere.
- `resolution:invalid` means the report or request is not valid enough to remain actionable.

### `prio`

Describes deliberate prioritisation based on impact, urgency, and scheduling intent.

- Apply exactly one priority label to every open issue.
- Remove all priority labels when the issue is closed.
- Use explicit user or project priority when available.
- Otherwise infer priority from impact, urgency, dependencies, and scheduling consequences.
- Use `prio:low` as the deterministic default when no evidence supports a higher priority.
- Do not add `prio:unsorted`; the taxonomy requires an actionable priority, and the owner's established fallback is `prio:low`.
- Do not equate security severity with priority automatically. A security issue may receive any priority based on actual risk and urgency.

### `meta`

Adds workflow or collaboration context that does not replace the other categories.

- Apply zero or more compatible meta labels to open issues.
- Remove a meta label once its condition no longer applies.
- Remove all meta labels when the issue is closed.
- Use `meta:question` whenever clarification, information, or discussion is needed.
- Combine `meta:question` with `status:blocked` only when the missing answer prevents meaningful progress.

## Type precedence

Choose the type representing the primary acceptance criterion. Use this ordering to resolve overlap, but prefer explicit issue intent over mechanical ordering:

1. `type:security` — security vulnerability, hardening, authentication, authorisation, secrets, unsafe behaviour, or security-sensitive configuration.
2. `type:bug` — existing behaviour is incorrect, broken, or regressed.
3. `type:accessibility` — accessibility compliance, assistive-technology support, keyboard operation, semantics, contrast, or inclusive interaction is the primary deliverable.
4. `type:performance` — speed, latency, resource use, bundle size, rendering cost, throughput, or performance measurement is the primary deliverable.
5. `type:dependencies` — upstream package, runtime, action, or dependency update.
6. `type:design` — visual design, theme, styling, layout, branding, or design-system work.
7. `type:content` — user-facing copy, editorial material, marketing content, or content organisation.
8. `type:documentation` — technical, project, process, reference, or usage documentation.
9. `type:tests` — test coverage, test infrastructure, or test correction where another product-code issue is not primary.
10. `type:data` — datasets, structured content data, migrations, transformations, imports, exports, or data preparation.
11. `type:refactor` — internal restructuring with no intended user-visible behaviour change.
12. `type:enhancement` — new or improved behaviour or capability not covered by a more specific type.
13. `type:chore` — routine maintenance or housekeeping not covered above.

`type:theme` is not part of the taxonomy. Theme work is a subset of `type:design`; a broader design label remains useful for non-theme visual work.

## Status transitions

Use these normal transitions unless issue evidence requires otherwise:

```text
unconfirmed -> confirmed -> in-progress -> review -> done
                        \-> blocked -> in-progress
```

Interpretation:

- `status:unconfirmed`: validity, reproducibility, scope, or acceptance is unresolved.
- `status:confirmed`: accepted as valid work, but active implementation has not started.
- `status:in-progress`: active work is underway.
- `status:blocked`: progress cannot continue because of an external dependency, missing decision, missing information, or another issue.
- `status:review`: implementation or investigation is ready for review, testing, or validation.
- `status:done`: work is finished, but the open issue is awaiting merge, push, deployment, automated closure, or other final handling.

## Lifecycle invariants

An open issue must have:

- exactly one `type`
- exactly one `status`
- exactly one `prio`
- zero or more `meta` labels
- no `resolution`

A closed issue must have:

- exactly one `type`
- exactly one `resolution`
- no `status`
- no `prio`
- no `meta`

The `status` and `resolution` categories are mutually exclusive.

### Finishing work

- Work finished, issue remains open: set `status:done`.
- Work finished and issue closes immediately: apply `resolution:completed` directly.
- Issue already has `status:done` and is now closing: replace it with `resolution:completed` and remove all open-only labels.

### Closing an issue

1. Retain or reassess exactly one `type`.
2. Select exactly one `resolution`.
3. Remove every `status` label.
4. Remove every `prio` label.
5. Remove every `meta` label.
6. Close the issue only when the user or authorised workflow requests closure.

### Reopening an issue

1. Retain or reassess its `type`.
2. Remove every `resolution` label.
3. Assign exactly one current `status`.
4. Assign exactly one `prio`, using `prio:low` when no higher priority is supported.
5. Restore only currently applicable `meta` labels.

## Applying changes

When asked to apply labels through GitHub tooling:

1. Fetch the issue and its current labels.
2. Determine the target open or closed lifecycle state.
3. Compare proposed labels with existing labels.
4. Add missing labels.
5. Remove conflicting, stale, or lifecycle-incompatible managed labels.
6. Preserve labels outside this taxonomy unless the user explicitly asks to remove them.
7. Report labels added, removed, retained, and any unresolved ambiguity.

Never close an issue merely because `status:done` or `resolution:completed` appears appropriate unless the user asked to close it or the surrounding workflow explicitly authorises closure.

Applying existing repository labels to issues does not authorise creating new
repository labels. Create repository labels only after the user explicitly
confirms that labels should be created.

## Required output

For analysis-only requests, return:

```markdown
## Recommended labels

- `type:...` — reason
- `status:...` — required while open
- `prio:...` — required while open; defaults to `prio:low`
- `meta:...` — zero or more, only while open
- `resolution:...` — required while closed and mutually exclusive with status

## Changes from existing labels

- Add: ...
- Remove: ...
- Keep: ...

## Uncertainty

State any missing evidence or ambiguous classification. Omit this section when there is no meaningful uncertainty.
```

For applied changes, state exactly what changed and whether any recommended change could not be applied.

## Validation

Before finishing, verify:

- every selected label exists in the taxonomy
- no single-value category has multiple labels
- every issue has exactly one type
- every open issue has exactly one status and exactly one priority
- open issues have no resolution label
- every closed issue has exactly one resolution label
- closed issues have no status, priority, or meta labels
- `type` reflects the primary acceptance criterion
- `prio:low` is used when no higher priority is justified
- stale lifecycle and meta labels were removed

## Taxonomy provisioning

Use `scripts/label-manager.sh` to create or update the canonical labels in one or more repositories.

Do not run taxonomy provisioning with `--apply` unless the user explicitly
confirms that repository labels should be created or updated. Run audit-only or
dry-run mode first when current label state is uncertain.

After every run, the manager audits the repository and reports:

- installed canonical labels
- missing canonical labels
- legacy labels using a managed namespace with an unknown value
- repository-specific labels outside the managed namespaces

Managed namespaces are `type:`, `status:`, `resolution:`, `prio:`, and `meta:`. Treat an unknown label inside one of these namespaces as a likely legacy label requiring review. Preserve labels outside these namespaces as potentially intentional repository-specific labels. The audit never deletes or renames labels.

Run only the audit with:

```bash
scripts/label-manager.sh --repo OWNER/REPOSITORY --audit-only
```

The script is intentionally Bash-based because GitHub CLI remains the operative cross-platform dependency. Replacing the wrapper with TypeScript would still require `gh` while also adding a Node.js runtime and package execution layer. The Bash script works on Linux, macOS, WSL, and Windows environments that provide Bash, Git, and GitHub CLI.

Run it without `--apply` first:

```bash
./scripts/label-manager.sh --repo OWNER/REPOSITORY
```

Apply the changes after reviewing the dry-run output:

```bash
./scripts/label-manager.sh --repo OWNER/REPOSITORY --apply
```

Use `--clear` only when the repository should contain no labels outside this taxonomy. It deletes every existing label before recreating the canonical set:

```bash
./scripts/label-manager.sh --repo OWNER/REPOSITORY --apply --clear
```
