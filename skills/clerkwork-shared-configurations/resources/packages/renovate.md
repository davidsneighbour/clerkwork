# DNBHQ Renovate configuration maintenance

Maintain repository Renovate configuration with the shared `dnbhq/renovate-config` GitHub preset.

During the initial repository audit, detect Renovate config files, GitHub workflows, package managers and lockfiles, dependency ecosystems, workspace layout, local package rules, schedules, ignore paths, enabled managers, automerge policy, host rules, custom registries, labels, reviewers, assignees, commit message settings, and branch naming.

## Authoritative sources

Read the `dnbhq/renovate-config` repository README.md and migration notes before editing.

Current package documentation controls:

- preset names
- supported config file shape
- included preset behavior
- migration instructions
- validation caveats

This is a Renovate GitHub preset. Do not install `@dnbhq/renovate-config` from npm as a normal runtime or dev dependency.

## Audit

Inspect:

- `renovate.json`, `renovate.json5`, `.github/renovate.json`, and `.github/renovate.json5`
- `.renovaterc`, `.renovaterc.json`, `.renovaterc.json5`, and `package.json` `renovate` config
- `.github/workflows/*.yml` and `.github/workflows/*.yaml`
- npm, GitHub Actions, Docker, Hugo, Go, Composer, Python, Rust, and other package ecosystem files
- npm workspaces, `packages/*`, `apps/*`, and nested lockfiles
- current project-specific Renovate settings

Classify the setup as missing, partial, current, outdated, legacy, duplicated, mixed, invalid, or migration-incomplete.

## Maintenance rules

- Use the GitHub preset documented by the package README.md, normally `github>dnbhq/renovate-config`.
- Prefer `.github/renovate.json5` because JSON5 supports comments and is the DNBHQ convention.
- Create `.github` when needed.
- Do not create both JSON and JSON5 Renovate config files.
- Preserve project-specific package rules, schedules, manager settings, host rules, custom registries, encrypted secrets, reviewers, labels, assignees, and branch naming unless they are clearly obsolete.
- Do not remove unrelated dependency-update tooling unless the user explicitly asks or responsibilities are intentionally separated.
- Do not create secrets.

## Cleanup

Remove obsolete Renovate config fragments and duplicated shared-preset settings only after comparing with the current README.md and preset behavior.

If an npm validation script is useful, add it conservatively. Prefer an `npx` validator invocation during validation instead of adding Renovate as a permanent dependency unless the repository already has a reason to run Renovate locally.

## Validation

Run the safest available Renovate config validation command for the current tool version and report the exact command used.

Validate that:

- the config parses
- the shared preset reference is present
- local overrides are valid Renovate configuration
- old config fragments are gone or intentionally retained
- duplicate config files do not conflict

Separate local syntax/config errors from failures to resolve the shared GitHub preset because of credentials, network, registry, or GitHub access.

## Final response

Report starting state, documentation consulted, config file changes, shared preset, preserved local overrides, cleanup, validation, and unresolved issues.
