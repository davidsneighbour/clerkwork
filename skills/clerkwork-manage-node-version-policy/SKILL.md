---

id: clerkwork-manage-node-version-policy
name: clerkwork-manage-node-version-policy
title: Clerkwork Manage Node Version Policy
description: "Audits and updates Node.js and npm version declarations across a repository, synchronises package.json engines with actively supported Node.js releases, adds a weekly lifecycle check, and verifies the repository after changes. Use when asked to update Node versions, fix Node engine constraints, remove EOL Node versions, align GitHub Actions with package.json, or enforce an LTS/current Node policy. Triggers on: 'update Node versions', 'check Node engines', 'fix Node workflow versions', 'Node version policy', 'remove EOL Node', 'execute Node updates'."
---

Use this procedure to audit and maintain Node.js and npm version declarations throughout a repository.

## Purpose

Keep all repository Node.js declarations consistent with an explicit support policy and the official Node.js release lifecycle.

The skill must:

1. Determine whether the repository should use:

   - the latest active LTS Node.js release; or
   - the latest active Node.js release, including Current releases.
2. Calculate an appropriate `engines.node` range.
3. Find Node.js and npm version declarations throughout the repository.
4. Update or propose changes consistently.
5. Add a weekly GitHub Actions workflow that detects stale Node.js declarations.
6. Run the repository's checks after changes.
7. Present clear, friendly results.

## Invocation modes

The skill has two operating modes.

### Review mode

Review mode is the default.

Use review mode unless the request explicitly contains an execution instruction such as:

- `execute`
- `apply`
- `implement`
- `update all`
- `fix all`
- `make the changes`
- `run the migration`

In review mode:

1. Audit the repository.
2. Determine the required changes.
3. Show each proposed file change separately.
4. Ask for approval before changing each file.
5. Do not combine approvals for unrelated files.
6. Do not modify files that the user has not approved.

A response such as `yes`, `approve`, or `apply this` approves only the change currently being presented unless the user explicitly approves all remaining changes.

### Execute mode

Use execute mode when the user explicitly requests execution.

In execute mode:

1. Audit the entire repository first.
2. Present a concise summary of the intended changes.
3. Apply all necessary Node.js and npm version changes without requesting approval for every file.
4. Preserve unrelated formatting and content.
5. Run validation after all edits.
6. Report every changed file and validation result.

Execute mode does not permit unrelated refactoring.

## Required repository preparation

Before inspecting or changing files:

1. Read `AGENTS.md`.
2. Read all applicable instruction files under `.vscode/instructions/`.
3. When entering a directory, read its `README.md` and `INDEX.md` if present.
4. Update the local repository to the latest `main` branch unless the user explicitly prohibits it.
5. Check the working tree before making changes.
6. Never overwrite unrelated uncommitted work.
7. Follow repository-specific package-manager and formatting rules.

If the repository specifies a package manager, use it. Otherwise, detect the package manager from lockfiles and `packageManager`.

For DNB repositories, prefer npm and static package versions.

## Node.js support policies

The skill supports two policies.

### Policy: LTS

Use the newest Node.js major release that currently has an active LTS status.

Do not select:

- an EOL release;
- an odd-numbered Current release;
- a future release whose official start date has not arrived.

Examples of user intent:

- `use LTS`
- `prefer stability`
- `production LTS`
- `latest LTS`
- `stay on LTS`

### Policy: active-latest

Use the newest officially released Node.js major whose lifecycle has started and whose end-of-life date has not passed.

This may select:

- an even-numbered LTS release; or
- an odd-numbered Current release.

Examples of user intent:

- `use latest`
- `use current`
- `use newest active Node`
- `do not restrict this to LTS`

### Asking for the policy

Before making version decisions, determine whether the repository already defines its policy.

Look for an explicit policy in:

- `.github/dnb.toml`
- `AGENTS.md`
- `README.md`
- `package.json`
- version-management configuration
- existing workflows
- repository instructions
- prior user instructions in the current task

If no policy is explicitly defined, ask:

> Should this repository use the latest active LTS Node.js release, or the latest active Node.js release including Current versions?

Offer exactly these choices:

1. Latest active LTS
2. Latest active release

Do not infer that `>=25`, `node-version: 25`, or an odd-numbered release represents an intentional active-latest policy. It may simply be stale.

In execute mode, the policy question must still be asked if it cannot be determined safely from repository configuration or the user's request.

## Official lifecycle source

Use the Node.js Release Working Group schedule as the authoritative lifecycle source:

```text
https://raw.githubusercontent.com/nodejs/Release/main/schedule.json
```

Do not hard-code assumptions about which Node.js releases are active.

When evaluating a release on date `TODAY`:

```text
release.start <= TODAY
AND
release.end >= TODAY
```

For LTS selection, also require a valid LTS date whose date has passed:

```text
release.lts exists
AND
release.lts <= TODAY
```

Use UTC dates for lifecycle comparisons.

If the lifecycle source cannot be retrieved:

1. Do not guess current release status.
2. Report the retrieval failure clearly.
3. Leave existing versions unchanged.
4. Explain how to retry.

## Determine the target Node version

Fetch and parse the official release schedule.

For `latest active LTS`:

1. Select releases whose start date has passed.
2. Select releases whose LTS date has passed.
3. Exclude releases whose end date has passed.
4. Sort by major version.
5. Select the highest major.

For `latest active release`:

1. Select releases whose start date has passed.
2. Exclude releases whose end date has passed.
3. Sort by major version.
4. Select the highest major.

Record:

- selected policy;
- selected major version;
- lifecycle status;
- start date;
- LTS date when applicable;
- maintenance date when available;
- end-of-life date.

## Determine the supported engine range

The target runtime version and the package compatibility range are related but distinct.

### Applications

For an application intended to run on one selected Node.js release, prefer a bounded major range:

```json
{
  "engines": {
    "node": ">=MAJOR.0.0 <NEXT_MAJOR.0.0"
  }
}
```

Equivalent caret notation may be used when consistent with the repository:

```json
{
  "engines": {
    "node": "^MAJOR.0.0"
  }
}
```

### Reusable packages

For a library or reusable configuration package, inspect which active release lines the package should support.

Unless repository instructions say otherwise:

- include all actively maintained LTS majors;
- include Current only when the policy is `active-latest` and CI tests it;
- exclude EOL majors;
- do not claim support for untested future majors.

Example form:

```json
{
  "engines": {
    "node": "^22.22.2 || ^24.15.0 || ^26.0.0"
  }
}
```

Minimum patch versions must be based on actual package requirements, npm requirements, or test evidence. Do not invent patch minimums.

When no patch-specific constraint exists, use:

```json
{
  "engines": {
    "node": "^22.0.0 || ^24.0.0 || ^26.0.0"
  }
}
```

### Never use an unbounded future range by default

Avoid:

```json
{
  "engines": {
    "node": ">=26.0.0"
  }
}
```

This claims compatibility with every future Node.js major, including versions that have not been released or tested.

Prefer an explicitly bounded range.

## npm policy

Do not install `npm@latest` unconditionally in CI.

This pattern is unsafe:

```yaml
- name: Update npm
  run: npm install --global npm@latest
```

It introduces a moving dependency whose Node.js engine requirements may change independently of the repository.

Use the npm version bundled with the selected Node.js release unless the repository explicitly requires another npm version.

When an explicit npm version is required:

1. Declare it in `packageManager`.
2. Use a static exact version.
3. Optionally declare a compatible `engines.npm` range.
4. Install that declared exact version rather than `npm@latest`.

Example:

```json
{
  "packageManager": "npm@12.0.1",
  "engines": {
    "node": "^22.22.2 || ^24.15.0 || ^26.0.0",
    "npm": "^12.0.0"
  }
}
```

Corresponding workflow step:

```yaml
- name: Install declared npm version
  run: npm install --global npm@12.0.1
```

Do not add `engines.npm` merely because npm is used. Add it only when the repository has a real npm compatibility requirement.

## Repository audit

Search the complete repository for Node.js and npm version declarations.

Exclude:

- `.git/`
- `node_modules/`
- generated build output;
- coverage output;
- caches;
- vendored dependencies;
- lockfile package metadata that does not represent repository policy.

Inspect at least the following.

### Package metadata

- root `package.json`
- workspace `package.json` files
- `packageManager`
- `engines.node`
- `engines.npm`
- `devEngines`
- Volta configuration
- npm configuration
- package-lock metadata where directly relevant

### Version manager files

- `.nvmrc`
- `.node-version`
- `.tool-versions`
- `mise.toml`
- `.mise.toml`
- `volta`
- `.npmrc`
- `.env`
- example environment files

### GitHub Actions

Inspect all files under:

```text
.github/workflows/
.github/actions/
```

Look for:

- `actions/setup-node`
- `node-version`
- `node-version-file`
- matrix Node versions
- container images containing Node.js
- `npm@latest`
- explicit npm versions
- `npx`
- Corepack activation
- reusable workflow inputs
- workflow comments documenting versions

### Containers and deployment

Inspect:

- `Dockerfile`
- `Dockerfile.*`
- Compose files
- Dev Container files
- deployment configuration
- Netlify configuration
- Cloudflare configuration
- build images
- CI images

Look for values such as:

```dockerfile
FROM node:25
FROM node:25-alpine
```

### Documentation and examples

Inspect:

- `README.md`
- `docs/`
- `AGENTS.md`
- contribution documentation
- setup guides
- code examples
- badges
- comments describing supported Node.js versions

Update documentation only when it states or demonstrates a conflicting Node.js or npm version.

### Scripts and source files

Search for:

```text
node-version
NODE_VERSION
NVM_VERSION
npm@latest
npm@<version>
node:<version>
setup-node
engines.node
packageManager
```

Do not replace unrelated numbers that merely resemble version numbers.

## Consistency rules

After determining the selected policy and target versions, make all authoritative declarations consistent.

Typical mappings:

| Location | Expected value |
| ----------------------------- | ----------------------------------------------- |
| `package.json#engines.node` | Supported bounded semver range |
| `package.json#packageManager` | Exact package-manager version, when declared |
| `.nvmrc` | Selected development major or exact version |
| `.node-version` | Selected development major or exact version |
| `actions/setup-node` | Selected major or generated supported matrix |
| Docker base image | Selected runtime major |
| documentation | Same stated support policy |
| weekly validation workflow | Same policy encoded as repository configuration |

Do not blindly make every declaration textually identical. Each file has a different semantic role.

For example:

```json
{
  "engines": {
    "node": "^24.0.0"
  }
}
```

may correctly correspond to:

```text
24
```

in `.nvmrc` and:

```yaml
node-version: 24
```

in a workflow.

## Persistent policy configuration

Add or update this repository-local policy file:

```text
.github/node-version-policy.json
```

Use this schema:

```json
{
  "$schema": "./node-version-policy.schema.json",
  "policy": "lts",
  "packageType": "application",
  "includeAllActiveLts": false,
  "includeCurrentForLibraries": false
}
```

Allowed `policy` values:

```text
lts
active-latest
```

Allowed `packageType` values:

```text
application
library
```

Meaning:

- `policy`: selects the development and primary CI Node.js version.
- `packageType`: determines whether `engines.node` represents one runtime or multiple supported release lines.
- `includeAllActiveLts`: for libraries, include every active LTS line in `engines.node` and CI.
- `includeCurrentForLibraries`: for libraries, additionally include the active Current release.

If the repository has `.github/dnb.toml` and its established schema should be extended instead, prefer adding equivalent keys there rather than introducing duplicate configuration.

Suggested TOML keys:

```toml
[node]
policy = "lts"
package_type = "application"
include_all_active_lts = false
include_current_for_libraries = false
```

Use one authoritative policy location, never both.

## Weekly lifecycle check

Add:

```text
.github/workflows/check-node-version-policy.yml
```

The workflow must:

1. Run once weekly.
2. Support manual execution.
3. Use read-only permissions except where issue creation or updates are explicitly implemented.
4. Fetch the official Node.js release schedule.
5. Read the repository's Node policy configuration.
6. Calculate the expected active versions.
7. Compare expected values with:

   - `package.json#engines.node`;
   - the selected development Node version;
   - Node.js versions used in GitHub Actions;
   - npm declarations that conflict with the selected Node versions.
8. Print a readable GitHub Actions summary.
9. Fail when authoritative version declarations are stale.
10. Explain exactly which files or values need updating.

Recommended schedule:

```yaml
on:
  schedule:
    - cron: "17 3 * * 1"
  workflow_dispatch:
```

The unusual minute reduces load concentration at the start of the hour.

### Workflow implementation

Prefer a repository script over embedding substantial logic directly in YAML.

Add:

```text
scripts/check-node-version-policy.mjs
```

or use the repository's established scripts directory.

The script must support:

```bash
node scripts/check-node-version-policy.mjs --help
node scripts/check-node-version-policy.mjs --check
node scripts/check-node-version-policy.mjs --write
node scripts/check-node-version-policy.mjs --format=json
```

Required behaviour:

- `--check`

  - makes no changes;
  - exits `0` when declarations are current;
  - exits non-zero when changes are required.
- `--write`

  - updates supported version declarations;
  - preserves unrelated file content;
  - reports every changed file.
- `--format=json`

  - emits machine-readable results.
- default output

  - is concise and friendly.
- `--verbose`

  - shows inspected files and comparison details.

Use named options only.

The script must provide actionable errors and use explicit error handling.

## Optional issue reporting

When repository policy permits GitHub issue creation, the weekly workflow may create or update one tracking issue.

Use a stable issue title:

```text
chore: update Node.js version policy
```

The issue body should include:

- current repository policy;
- current declared versions;
- expected versions;
- affected files;
- relevant lifecycle dates;
- the workflow run URL;
- the command that can apply the changes.

Do not create a new issue every week.

Search for an existing open issue with the stable title and update it. If the repository becomes compliant, close the existing issue or add a resolved comment according to repository issue policy.

If issue permissions or repository issue conventions are unknown, use a failing workflow and GitHub Actions summary only.

## File update rules

When changing JSON:

1. Use the repository's existing indentation.
2. Preserve key ordering where practical.
3. Avoid rewriting the entire file through a serializer when a targeted edit is possible.
4. Keep package versions static.
5. Run the repository formatter afterward if one exists.

When changing YAML:

1. Preserve comments.
2. Preserve action pinning conventions.
3. Preserve `persist-credentials: false` when present.
4. Do not replace pinned action commit SHAs with floating tags.
5. Preserve unrelated workflow permissions and triggers.

When changing Dockerfiles:

1. Preserve the existing image variant.
2. Update only the Node major or exact version.
3. Do not change `alpine`, `slim`, distro, or digest unless required for compatibility.

Example:

```dockerfile
FROM node:25-alpine
```

becomes:

```dockerfile
FROM node:26-alpine
```

not:

```dockerfile
FROM node:26
```

## Review-mode presentation

For each proposed file change, show:

```text
File: path/to/file
Reason: why the declaration is stale
Current: current value
Proposed: proposed value
Effect: what this changes
```

Then ask:

> Apply this change?

Do not present raw full-file replacements unless the file is new or the surrounding context is necessary.

For a new workflow or script, provide:

- file path;
- purpose;
- significant behaviour;
- permissions;
- triggers;
- files it may inspect or update.

## Validation

After applying changes, determine the repository's validation commands from:

- `package.json#scripts`
- `AGENTS.md`
- repository instructions
- CI workflows
- contribution documentation
- Makefiles or task runners

Run the appropriate available checks.

At minimum, when present:

```bash
npm install
npm run build
npm test
npm run lint
npm run check
npm run typecheck
```

Prefer `npm ci` when the lockfile is current and no dependency metadata was intentionally changed.

Use repository-defined aggregate commands such as:

```bash
npm run check
```

instead of duplicating their child commands unless detailed diagnosis is needed.

Also validate the Node policy tool itself:

```bash
node scripts/check-node-version-policy.mjs --check
```

When multiple Node versions are part of the support policy, use the repository's available version manager or CI matrix to test all declared versions when practical.

Do not claim compatibility with a Node.js version that was not tested unless clearly marked as declared but unverified.

## Handling failures

If validation fails:

1. Do not hide the failure.
2. Determine whether it was caused by the Node.js version changes.
3. Report the exact failing command.
4. Include the relevant error summary.
5. Fix problems caused by the skill's changes when safe.
6. Re-run the failed check after correction.
7. Do not modify unrelated application behaviour merely to make checks pass.
8. Leave the repository in a clear, inspectable state.

If an active Node.js release is incompatible with dependencies:

1. Identify the incompatible package and its engine constraint.
2. Check whether a compatible dependency update exists.
3. In review mode, propose that dependency update separately.
4. In execute mode, apply it only when it is a direct and safe compatibility update.
5. Otherwise, retain the newest compatible active Node.js version and explain the temporary constraint.
6. Never fall back to an EOL release silently.

## Friendly result output

Finish with a compact report.

Example successful result:

```text
Node.js policy update complete

Policy: Latest active LTS
Selected development version: Node.js 24
Supported package engines: ^22.0.0 || ^24.0.0

Changed:
- package.json
- .nvmrc
- .github/workflows/test.yml
- .github/workflows/check-node-version-policy.yml
- scripts/check-node-version-policy.mjs

Removed:
- Unbounded npm@latest installation from CI

Validation:
- npm ci: passed
- npm run check: passed
- Node policy check: passed

Next scheduled check:
- Every Monday at 03:17 UTC
```

Example no-change result:

```text
Node.js policy is current

Policy: Latest active LTS
Development version: Node.js 24
Engine range: ^22.0.0 || ^24.0.0
Weekly lifecycle check: present
Conflicting Node/npm declarations: none
Validation: passed

No files were changed.
```

Example stale review result:

```text
Node.js policy needs attention

Policy: Latest active release
Current development version: Node.js 25
Expected development version: Node.js 26
Reason: Node.js 25 has reached end of life

Affected files:
- package.json
- .nvmrc
- .github/workflows/test.yml
- Dockerfile

No files were changed because the skill is running in review mode.
```

## Documentation

Document the Node.js policy in the repository's relevant `README.md`.

Include:

- selected policy;
- meaning of the policy;
- authoritative configuration file;
- weekly workflow path;
- local check command;
- local write command;
- how failures are reported.

Link new documentation from an applicable `INDEX.md` when one exists.

Do not document behaviour that the script or workflow does not enforce.

## Completion requirements

The task is complete only when:

- the Node.js policy has been explicitly selected;
- the official lifecycle schedule has been checked;
- `package.json#engines.node` is current;
- repository Node.js declarations have been audited;
- npm declarations have been audited;
- unsafe `npm@latest` CI upgrades have been removed or justified;
- the weekly policy workflow exists;
- the policy-check script exists;
- documentation is current;
- repository checks have run;
- all changes and failures have been reported clearly.

Do not commit changes unless the user explicitly asks for a commit.

When committing in a repository that permits direct `main` commits, follow repository-specific Git instructions and use a conventional commit scope defined by `.release-it.ts`.
