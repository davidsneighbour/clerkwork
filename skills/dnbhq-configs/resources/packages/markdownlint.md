# DNBHQ Markdownlint configuration maintenance

Maintain Markdown linting with `@dnbhq/markdownlint-config`.

During the initial repository audit, detect markdownlint configuration files, Markdown lint scripts, markdownlint dependencies and custom rules, Markdown and MDX file locations, generated/vendor folders, lint-staged integration, hooks, CI, and local prose rules.

## Authoritative sources

Read the package repository README.md, release notes, migration documents, npm metadata, and installed package documentation before editing.

Current package documentation controls:

- package names
- exported config paths
- bundled markdownlint runtime packages and custom rules
- supported CLI usage
- migration instructions
- package-specific caveats

## Audit

Inspect:

- `.markdownlint-cli2.jsonc`, `.markdownlint-cli2.json`, `.markdownlint-cli2.yaml`, and `.markdownlint-cli2.yml`
- `.markdownlint.jsonc`, `.markdownlint.json`, `.markdownlintrc`, `.markdownlintrc.json`, and `.markdownlintignore`
- `lint:markdown`, `lint:markdown:fix`, generic lint scripts, and old markdownlint CLI scripts
- `@dnbhq/markdownlint-config`, `markdownlint-cli2`, `markdownlint`, `@github/markdownlint-github`, and custom rule dependencies
- Markdown and MDX file locations
- generated, vendor, build, coverage, framework, and public output folders that may need excludes

Classify the setup as missing, partial, current, outdated, legacy, duplicated, mixed, invalid, or migration-incomplete.

## Maintenance rules

- Use the package README.md as the current source for exact config path, scripts, bundled rules, and supported cleanup.
- Use `markdownlint-cli2`; do not migrate to the older `markdownlint` CLI.
- Do not put a `markdownlint-cli2` options object into `.markdownlint.jsonc`. That file name is treated as markdownlint rule configuration only.
- If a project needs CLI2-only fields such as `customRules`, `globs`, or `ignores`, use `.markdownlint-cli2.jsonc`.
- Use `.markdownlint.jsonc` only for project-specific rule overrides.
- Preserve project-specific ignores, local prose rules, and custom rules that remain necessary.
- Do not copy the shared `.markdownlintignore` blindly; add local ignores only when the repository needs them.
- Keep MDX in the default lint target unless the project is intentionally Markdown-only.
- Avoid automatic Markdown fixes unless explicitly requested.

## Cleanup

Remove old markdownlint config fragments, old CLI scripts, and duplicate dependencies only after checking:

- package scripts
- config files
- GitHub workflows
- local scripts
- lint-staged or hook configuration
- documentation that defines live commands

If the package README.md says runtime or custom rule packages are bundled, they are removable only when no local config or script still references them.

## Validation

Run the safest available Markdown lint validation commands documented by the current package.

Separate:

- invalid shared config paths or CLI2 configuration
- package incompatibility
- existing Markdown content violations
- unrelated lint failures
- network or registry failures

## Final response

Report starting state, documentation consulted, dependency changes, script changes, config path, local ignores and overrides, cleanup, validation, and unresolved issues.
