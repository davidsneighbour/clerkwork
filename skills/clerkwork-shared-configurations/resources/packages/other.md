# Other DNBHQ configuration maintenance

Maintain supported DNBHQ shared configuration packages that do not yet justify dedicated skills.

Read its package registry before presenting selectable maintenance targets. Only offer packages that are installed, configured, detected as legacy, or clearly applicable.

## Scope

This skill may cover configuration packages such as:

- Markdown and prose linting
- Stylelint
- Astro or framework conventions
- test configuration
- editor configuration
- commit and repository quality tooling
- other DNBHQ shared presets

Only maintain packages that are detected in the repository or explicitly selected by the user.

## Package registry

Read `resources/package-registry.md` before proceeding.

Each package entry must define:

- current package name
- package repository
- predecessor package names
- relevant config files
- authoritative documentation locations
- installation and update checks
- migration concerns
- validation commands
- known coexistence rules

Do not invent package-specific behaviour when the registry lacks an entry. Audit and report the package, then request that a package resource be added.

## Workflow

For each selected package:

1. identify current and legacy state
2. read current upstream and installed documentation
3. determine the compatible target version
4. inspect local overrides and integrations
5. onboard, update, migrate, repair, or audit as required
6. remove obsolete duplication only after validation
7. run safe package-specific validation
8. report results separately

## Rules

- Keep each package's changes independently reviewable.
- Do not combine unrelated cleanup.
- Do not replace specialised tools without confirming feature coverage.
- Preserve intentional local configuration.
- Avoid write-mode linting or formatting unless explicitly requested.
- Move sufficiently complex packages into dedicated skills rather than expanding this skill indefinitely.

## Final response

Use one row per package and report starting state, action, changed files, migration result, validation, and remaining work.
