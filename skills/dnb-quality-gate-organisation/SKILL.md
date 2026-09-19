---
id: dnb-quality-gate-organisation
name: dnb-quality-gate-organisation
title: DNB Quality Gate Organisation
description: Name repository quality-check commands consistently. Use when deciding npm script names or documenting check, lint, validate, format, test, and audit command conventions.
---

## Purpose

Use this skill to name repository quality-check commands consistently.

The default top-level command is:

```bash
npm run check
```

`check` means:

> Run all non-mutating quality gates for the repository.

A quality gate is any command that inspects the repository and exits with success or failure without intentionally changing files.

## Core Rule

Do not use `lint`, `validate`, `format`, `test`, and `audit` as interchangeable terms.

They describe different kinds of checks:

| Term | Meaning |
| --- | --- |
| `check` | Umbrella command for non-mutating quality gates |
| `lint` | Static analysis for style, conventions, maintainability, likely mistakes |
| `validate` | Contract/schema/policy conformance |
| `format` | Canonical file formatting |
| `test` | Behavioural correctness |
| `audit` | Security, dependency, performance, or risk inspection |

`validate` is not simply “stricter lint”.
`lint` is not simply “technical validation”.

## Required Naming Model

### `check`

Use `check` as the top-level non-mutating quality gate.

Good:

```json
{
  "scripts": {
    "check": "npm run lint && npm run validate && npm run test && npm run audit"
  }
}
```

Use `check:*` for mixed or tool-native commands that do not map cleanly to one category.

Examples:

```json
{
  "scripts": {
    "check:astro": "astro check",
    "check:biome": "biome check .",
    "check:links": "lychee ."
  }
}
```

Prefer a more specific name when the purpose is clear.

### `lint`

Use `lint` for static analysis, style rules, prose rules, spelling, typo checks, Markdown conventions, and code-quality rules.

Good:

```json
{
  "scripts": {
    "lint": "npm run lint:code && npm run lint:markdown && npm run lint:prose && npm run lint:spelling",
    "lint:code": "biome lint .",
    "lint:markdown": "markdownlint .",
    "lint:prose": "vale .",
    "lint:spelling": "cspell .",
    "lint:typos": "typos ."
  }
}
```

Examples:

| Tool | Recommended script |
| --- | --- |
| ESLint | `lint:code` |
| Biome lint | `lint:code` |
| markdownlint | `lint:markdown` |
| Vale | `lint:prose` |
| cspell | `lint:spelling` |
| typos | `lint:typos` |

Use `lint` when the command answers:

> Is this probably wrong, inconsistent, suspicious, badly styled, or against project conventions?

### `validate`

Use `validate` for exact contracts, schemas, metadata rules, policy checks, and repository invariants.

Good:

```json
{
  "scripts": {
    "validate": "npm run validate:types && npm run validate:content && npm run validate:package",
    "validate:types": "tsc --noEmit",
    "validate:content": "astro check",
    "validate:package": "node scripts/validate-package-json.mjs",
    "validate:frontmatter": "node scripts/validate-frontmatter.mjs",
    "validate:engines": "node scripts/validate-node-engines.mjs"
  }
}
```

Examples:

| Check | Recommended script |
| --- | --- |
| TypeScript type checking | `validate:types` |
| Astro content collections | `validate:content` or `check:astro` |
| JSON schema | `validate:json` |
| package.json policy | `validate:package` |
| frontmatter description length | `validate:frontmatter` |
| Node engine policy | `validate:engines` |
| required metadata | `validate:metadata` |

Use `validate` when the command answers:

> Does this match the exact contract required by the project?

### `format`

Use `format` only for canonical formatting.

Mutating formatter:

```json
{
  "scripts": {
    "format": "prettier --write ."
  }
}
```

Non-mutating formatter check:

```json
{
  "scripts": {
    "format:check": "prettier --check ."
  }
}
```

Do not hide mutating formatters under `check`.

Bad:

```json
{
  "scripts": {
    "check": "prettier --write ."
  }
}
```

Good:

```json
{
  "scripts": {
    "check": "npm run format:check && npm run lint && npm run validate && npm run test",
    "format": "prettier --write .",
    "format:check": "prettier --check ."
  }
}
```

### `test`

Use `test` for behavioural correctness.

Examples:

```json
{
  "scripts": {
    "test": "vitest run",
    "test:watch": "vitest",
    "test:e2e": "playwright test"
  }
}
```

Use `test` when the command answers:

> Does the code behave as expected?

### `audit`

Use `audit` for security, dependency, performance, accessibility, or risk-oriented inspections.

Examples:

```json
{
  "scripts": {
    "audit": "npm run audit:deps && npm run audit:security",
    "audit:deps": "npm audit --audit-level=moderate",
    "audit:security": "zizmor .github/workflows",
    "audit:performance": "lighthouse https://example.com"
  }
}
```

Use `audit` when the command answers:

> Is there a security, dependency, workflow, performance, accessibility, or operational risk?

Use `security:*` only when the command is specifically security-related and not part of a broader audit namespace.

Good:

```json
{
  "scripts": {
    "audit:security": "zizmor .github/workflows",
    "security:workflows": "zizmor .github/workflows"
  }
}
```

Pick one style per repository.

## Mutating Commands

A command named `check`, `lint`, `validate`, `test`, or `audit` must not intentionally modify files.

Use explicit mutating suffixes:

| Suffix | Meaning |
| --- | --- |
| `:fix` | Applies safe automatic fixes |
| `:write` | Writes generated or formatted output |
| `:update` | Updates dependencies, generated data, caches, or policy files |

Examples:

```json
{
  "scripts": {
    "lint": "biome lint .",
    "lint:fix": "biome lint --write .",
    "format": "prettier --write .",
    "format:check": "prettier --check .",
    "validate:engines": "node scripts/validate-node-engines.mjs",
    "update:engines": "node scripts/update-node-engines.mjs"
  }
}
```

## `lint-staged`

`lint-staged` is a runner, not a quality category.

Good names:

```json
{
  "scripts": {
    "precommit": "lint-staged",
    "lint:staged": "lint-staged"
  }
}
```

Inside `lint-staged`, commands may format, lint, validate, or test the staged files.

Example:

```json
{
  "lint-staged": {
    "*.{js,ts,astro}": [
      "biome check --write"
    ],
    "*.{md,mdx}": [
      "prettier --write",
      "markdownlint --fix",
      "cspell"
    ],
    "package.json": [
      "node scripts/validate-package-json.mjs"
    ]
  }
}
```

If a repository also supports checking all files, expose that separately.

Good:

```json
{
  "scripts": {
    "check": "npm run lint && npm run validate && npm run test",
    "lint:staged": "lint-staged",
    "lint:all": "npm run lint"
  }
}
```

## Recommended Repository Baseline

Use this as the default shape for JavaScript, TypeScript, Astro, Markdown, or documentation-heavy repositories.

```json
{
  "scripts": {
    "check": "npm run format:check && npm run lint && npm run validate && npm run test",
    "format": "prettier --write .",
    "format:check": "prettier --check .",
    "lint": "npm run lint:code && npm run lint:markdown && npm run lint:prose && npm run lint:spelling",
    "lint:code": "biome lint .",
    "lint:markdown": "markdownlint .",
    "lint:prose": "vale .",
    "lint:spelling": "cspell .",
    "validate": "npm run validate:types && npm run validate:content && npm run validate:package",
    "validate:types": "tsc --noEmit",
    "validate:content": "astro check",
    "validate:package": "node scripts/validate-package-json.mjs",
    "test": "vitest run",
    "audit": "npm audit --audit-level=moderate",
    "precommit": "lint-staged"
  }
}
```

Adapt the commands to the tools actually used in the repository.

## Decision Rules

When naming a command, ask these questions in order:

1. Does it intentionally change files?

   - Use `format`, `*:fix`, `*:write`, or `*:update`.
2. Is it the top-level non-mutating gate?

   - Use `check`.
3. Does it inspect style, conventions, spelling, prose, maintainability, or likely mistakes?

   - Use `lint`.
4. Does it verify a strict contract, schema, required metadata, type contract, or project policy?

   - Use `validate`.
5. Does it verify runtime or behavioural correctness?

   - Use `test`.
6. Does it inspect risk, security, dependencies, performance, accessibility, or workflows?

   - Use `audit`.
7. Is it genuinely mixed?

   - Use `check:*`.

## Anti-patterns

Avoid these names:

```json
{
  "scripts": {
    "validate": "eslint .",
    "lint": "tsc --noEmit",
    "check": "prettier --write .",
    "test": "markdownlint .",
    "security": "npm run lint && npm run test"
  }
}
```

Prefer:

```json
{
  "scripts": {
    "lint:code": "eslint .",
    "validate:types": "tsc --noEmit",
    "format": "prettier --write .",
    "lint:markdown": "markdownlint .",
    "check": "npm run lint && npm run validate && npm run test && npm run audit"
  }
}
```

## Relationship to Tool-specific Skills

This skill only defines command naming and quality-gate taxonomy.

Tool-specific behaviour belongs in separate skills or instructions, for example:

- Biome configuration
- ESLint rules
- markdownlint rules
- Vale editorial rules
- cspell dictionaries
- typos configuration
- Prettier formatting policy
- Astro checks
- TypeScript strictness
- GitHub Actions security audits
- dependency audit policy

Those sub-skills may define exact commands, config files, ignores, severity levels, and CI behaviour, but they should preserve the naming model defined here.
