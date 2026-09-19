# DNBHQ release configuration maintenance

Maintain release procedures with `@dnbhq/release-config` and `release-it`.

During the initial repository audit, detect existing release configuration files, release-related packages, release scripts, repository metadata, package version metadata, ESM and TypeScript compatibility, `CHANGELOG.md`, `CITATION.cff`, GitHub release expectations, and npm publishing expectations.

## Authoritative sources

Read the package repository README.md, release notes, migration documents, npm metadata, installed package README.md, and TypeScript declarations before editing.

Current package documentation controls:

- exported APIs
- option names
- defaults
- merge behavior
- migration instructions
- script recommendations
- release-it compatibility caveats

## Audit

Inspect:

- `.release-it.ts`, `.release-it.js`, `.release-it.cjs`, `.release-it.mjs`, `.release-it.json`, and `package.json` `release-it`
- `.releaserc`, `release.config.*`, semantic-release, standard-version, auto-changelog, and custom release scripts
- `release-it`, `@dnbhq/release-config`, `@release-it/conventional-changelog`, semantic-release, standard-version, conventional changelog, and auto-changelog packages
- `package.json` `repository`, `version`, `type`, and release scripts
- `CHANGELOG.md` and `CITATION.cff`
- GitHub remotes and CI release jobs when relevant

Classify the setup as missing, partial, current, outdated, legacy, duplicated, mixed, invalid, or migration-incomplete.

## Defaults

Assume the package README.md defaults unless repository evidence or the user says otherwise.

The default release behavior is:

- determine the version bump from Conventional Changelog rules
- create the release commit
- create the Git tag
- push the release commit and tag
- create the GitHub release
- do not publish an npm package from the local release setup

If npm package publishing is wanted, the user must explicitly say so. Prefer configuring npm publishing in a GitHub workflow after the tag is pushed.

Assume the GitHub token setup rather than asking for it. If the token is missing or wrong, GitHub or release-it will report that during validation or release. If the user explicitly names a token environment variable, configure that value.

Do not create or commit real secrets.

## Maintenance rules

- Use `.release-it.ts` when the current package README.md documents it as the supported setup.
- Prefer the smallest `createReleaseConfig(...)` call that matches the package README.md defaults.
- Add only options needed by the repository or explicitly requested by the user.
- Preserve repository-specific release hooks, changelog paths, repository metadata, allowed scopes, and package metadata only when they remain necessary.
- Note unsupported or unclear legacy settings instead of silently dropping them.
- Treat package README.md guidance as authoritative for script names and flags.
- Do not publish, tag, push, or create a real release during maintenance unless explicitly requested.
- Do not delete `CHANGELOG.md`.
- Do not delete `CITATION.cff`.

## Migration

When migrating existing release configuration, map old settings to the current `@dnbhq/release-config` API when documented:

- changelog file path
- GitHub token environment variable
- conventional commit type and scope behavior
- repository package path or fallback URL
- Git, GitHub, npm, plugin, and hook overrides

If current documentation says main option objects merge shallowly, preserve required nested defaults explicitly when overriding them.

Before removing release packages, scripts, or config fragments, search:

- package scripts
- config files
- GitHub workflows
- local scripts
- imports and requires
- documentation that defines live release commands

## Validation

Run the safest available release dry-run or config validation commands documented by the current package.

At minimum, validate that:

- the release config imports correctly
- the dry-run reads the config
- changelog generation points to the correct repository
- GitHub token reference uses the selected or default setup
- npm publishing is disabled unless explicitly requested
- old release config fragments are gone or intentionally retained

Separate:

- invalid release configuration
- package incompatibility
- GitHub credential or network failures
- unrelated lint, typecheck, or test failures

## Final response

Report starting state, documentation consulted, config file changes, token handling, npm publishing behavior, release scripts, migrated legacy settings, retained or removed packages/configs, validation, and unresolved issues.
