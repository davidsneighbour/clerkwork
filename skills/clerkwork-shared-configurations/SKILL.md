---
id: dnbhq-configs
name: dnbhq-configs
title: DNBHQ repository configuration maintenance
type: skill
description: Audit DNBHQ repository configuration and coordinate selected package-specific maintenance workflows.
---

Audit or initialise the current repository's shared DNBHQ configuration and coordinate targeted maintenance through the package-specific skills.

## Purpose

This is the managing skill. It must:

1. read the package registry
2. inspect the repository without making changes during audits
3. identify installed, missing, outdated, legacy, duplicated, mixed, or invalid configuration
4. identify which supported configuration packages apply
5. present the audit findings
6. initialise selected configuration packages when requested
7. sort selected packages by registry weight when a weight is provided
8. delegate only the selected workflows
9. summarise the combined result

## Commands

### `/dnbhq-configs audit`

Audit is read-only. It must:

1. read `resources/package-registry.md`
2. list every configuration package available in the registry
3. inspect the current project for each package's dependencies, config files, predecessors, integrations, and validation hooks
4. classify each package using the standard state table
5. show the state of each registry package in the current project
6. recommend audit-only, onboard, update, migrate, repair, skip, or unknown for each package

Use the registry entries as the package inventory. Do not hide packages merely because they are not installed; mark them `not-applicable`, `missing`, or `unknown` with a concise reason.

The audit response must include:

| Package | State | Evidence | Recommended action |
| --- | ---: | --- | --- |
| Package name | State | Files, dependencies, scripts, or absence found | Action |

Do not edit files, install packages, run write-mode formatters, or stage changes during audit.

### `/dnbhq-configs init`

Init sets up selected shared configuration packages. It may receive prose instructions that name packages to include, packages to leave out, migration preferences, validation limits, or repository-specific constraints.

Before editing, init must:

1. read `resources/package-registry.md`
2. parse the user's prose instructions into explicit include, exclude, preserve, and unknown items
3. run the audit flow for the selected or potentially applicable packages
4. read authoritative package documentation for every package that will be added or changed
5. sort selected packages by ascending registry weight, keeping unweighted packages in registry order
6. present a concise setup plan when package selection, migration scope, or destructive cleanup is unclear

When the prose instructions leave packages out, mark them as skipped and do not configure them. When no package selection is provided, use audit evidence to choose only packages that are clearly applicable; ask before introducing optional packages that are not already present.

Use `resources/package-registry.md` as the single source of truth for supported configurable packages. Do not discover package workflows from prompt filenames or hard-coded package lists.

During setup:

- keep changes scoped to the selected packages
- preserve repository-specific overrides
- avoid replacing legacy or overlapping tools until feature coverage is confirmed
- remove dependencies or config fragments only when the registry or current package documentation identifies them as removable, or when repository evidence shows they are no longer referenced
- avoid write-mode linting, mass formatting, image optimisation, release tagging, or publishing unless explicitly requested
- update package scripts, hooks, CI, and editor integration only where required by the selected package setup
- keep every package's changes independently reviewable

The init response must include:

| Package | Requested action | Changes | Validation | Result |
| --- | --- | --- | --- | ---: |
| Package name | Onboard, update, migrate, repair, or skip | Files changed | Commands run or not run | Done/Partial/Failed/Skipped |

## Supported workflows

Read the relevant resource before auditing each area:

- `resources/package-registry.md`
- `resources/packages/biome.md`
- `resources/packages/markdownlint.md`
- `resources/packages/release.md`
- `resources/packages/renovate.md`
- `resources/packages/typescript.md`
- `resources/packages/other.md`

## Operating rules

- Audit before editing.
- Do not modify configuration during the initial audit.
- Do not run package-specific maintenance until the user selects it.
- Do not assume every repository needs every shared package.
- Read package documentation before recommending an update.
- Treat installed package documentation as authoritative for the installed version.
- Treat upstream package documentation and migration notes as authoritative for the target version.
- Do not remove legacy tools until replacement coverage is confirmed.
- Check package README.md files for defaults and supported changes before copying package-specific setup details into a repository.
- Avoid unrelated formatting or source-code changes.
- Preserve repository-specific overrides that remain necessary.
- Keep findings separated by registry package.

## Initial repository audit

Inspect:

- `package.json`
- package-manager lock files
- existing DNBHQ and davidsneighbour dependencies
- Biome, ESLint, and Prettier configuration
- TypeScript configuration
- framework-specific configuration
- package scripts
- lint-staged and Git hooks
- CI workflows
- editor settings
- generated-file and ignore configuration

Classify each supported registry package as:

| State | Meaning |
| --- | --- |
| `not-applicable` | The configuration does not apply to this repository |
| `missing` | The configuration is expected but absent |
| `partial` | Some required components are missing |
| `current` | The setup appears current and valid |
| `outdated` | Installed packages or configuration are behind |
| `legacy` | A predecessor package or tool is still used |
| `duplicated` | Local settings unnecessarily repeat shared configuration |
| `mixed` | Old and new tools overlap |
| `invalid` | Configuration cannot be loaded or validated |
| `unknown` | Documentation or repository evidence is insufficient |

## Required selection response

After the audit, present:

| Package | State | Findings | Recommended action |
| --- | ---: | --- | --- |
| `@dnbhq/biome-config` | State | Concise findings | Audit only, onboard, update, migrate, repair, or skip |
| `@dnbhq/tsconfig` | State | Concise findings | Audit only, onboard, update, migrate, repair, or skip |
| Registry package name | State | Concise findings | Audit only, onboard, update, migrate, repair, skip, or unknown |

Include one row for every package listed in `resources/package-registry.md`. Use package names as the response units, even when multiple packages share the same underlying instruction resource.

Then ask the user to select one or more applicable packages.

Do not offer packages classified as `not-applicable` unless there is a concrete reason to introduce them.

`Other` is only a package-instruction category for choosing `resources/packages/other.md`; it is not a response grouping and must not appear as a row label.

## Delegation

For each selected package:

1. invoke or follow the corresponding package-specific skill
2. pass the repository audit findings to avoid repeating work
3. allow the package-specific skill to perform deeper inspection
4. keep changes scoped to that package
5. collect the package-level final report when the workflow defines one
6. collect validation results

Where skill delegation is unavailable, read the matching resource and follow the package-specific workflow directly.

## Final response

Report the package-level final reports collected during setup. If a package resource does not define a package-specific report, use this format:

| Package | Starting state | Action | Result | Validation |
| --- | ---: | --- | ---: | --- |
| `@dnbhq/biome-config` | State | Summary | Done/Partial/Failed/Skipped | Result |
| `@dnbhq/tsconfig` | State | Summary | Done/Partial/Failed/Skipped | Result |
| Registry package name | State | Summary | Done/Partial/Failed/Skipped | Result |

End with one bullet for each configuration package that was configured, skipped, blocked, or left unchanged.

Include concrete unresolved issues and their next action. Omit empty sections.
