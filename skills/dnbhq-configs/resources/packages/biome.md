# DNBHQ biome configuration maintenance

Onboard, update, migrate, repair, audit, and validate a repository's DNBHQ Biome configuration.

During the initial repository audit, detect Biome config files, Biome and shared-config dependencies, predecessor packages, ESLint/Prettier overlap, package scripts, CI, hooks, lint-staged, editor integration, generated files, and ignore requirements.

Maintain the repository's Biome setup using the current supported DNBHQ shared configuration.

## Lifecycle

This skill supports:

- initial onboarding
- dependency updates
- package migrations
- ESLint and Prettier responsibility migration
- configuration repair
- duplication cleanup
- periodic audit
- validation

## Authoritative sources

Before editing, inspect:

1. the target package repository README
2. target release notes, changelog, and migration documents
3. the npm package metadata
4. the installed package README and `package.json`

The current package documentation is authoritative for:

- package names
- exported config paths
- supported Biome versions
- required direct dependencies
- migration instructions
- compatibility caveats

Do not hard-code volatile package facts when current documentation is available.

## Audit

Inspect:

- Biome config files
- `@dnbhq/biome-config`
- `@biomejs/biome`
- predecessor DNBHQ and davidsneighbour packages
- ESLint and Prettier dependencies and configs
- scripts, CI, hooks, lint-staged, and editor settings
- source file types and generated output
- ignore requirements

Classify the setup as missing, partial, current, outdated, legacy, duplicated, mixed, invalid, or migration-incomplete.

## Maintenance rules

- Install Biome directly in the consuming repository.
- Preserve required project-specific overrides.
- Prefer a config that extends the shared package exactly as documented by the package README.
- Use a commented extension of the shared config when local settings are required; every local setting should have a clear reason.
- Remove duplicated inherited settings.
- Do not remove ESLint or Prettier until their remaining responsibilities are identified.
- Do not mass-format or mass-fix source files unless explicitly requested.
- Update scripts and integrations conservatively.
- Separate configuration failures from existing code violations.

## Config shape

Use the package README.md as the current source for the exported shared config path and package caveats.

If no project-specific overrides are required, the repository config should contain only the schema and the shared config extension documented by the package.

If project-specific overrides are required:

- keep them in the repository's Biome config after the shared config extension
- explain each local setting with a JSONC comment when the file format allows comments
- keep generated-output exclusions, framework-specific parser needs, required rule changes, and VCS defaults local when they differ from the shared config
- do not copy the full shared config into the consuming repository
- do not duplicate settings that are inherited from the shared config

Use `biome.json` unless the project already uses `biome.jsonc` or comments are needed to explain local overrides. Do not create both.

## Scripts and cleanup

Add or update scripts conservatively. If the repository already has `lint`, `format`, or `check` scripts, preserve their existing role unless Biome fully replaces that role and validation passes.

Before removing ESLint, Prettier, or related config fragments:

1. confirm Biome covers the replaced responsibility
2. search package scripts, config files, workflows, local scripts, imports, and documentation that defines live commands
3. keep any tool that still owns behavior outside Biome's coverage
4. report retained overlap explicitly

## Validation

Use the commands documented by the current package.

At minimum, validate that:

- the active config loads
- the shared config path resolves
- package versions are compatible
- project-local scripts invoke installed binaries
- CI and hooks do not reference removed tools
- safe read-only checks complete

## Final response

Report starting state, documentation consulted, dependency changes, config changes, migrations, cleanup, integrations, audit result, validation result, and unresolved issues.
