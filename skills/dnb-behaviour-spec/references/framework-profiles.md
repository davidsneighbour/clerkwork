# Framework profiles

This file contains optional framework-specific guidance.

The core skill is framework-neutral.

Use these profiles only when the repository already uses the relevant tools.

Do not introduce these tools just because they are mentioned here.

## JavaScript and TypeScript

When the repository uses JavaScript or TypeScript:

- follow the existing module system
- preserve strict TypeScript settings
- avoid `any`
- use `unknown` with guards when needed
- avoid empty catch blocks
- include explicit error handling
- follow existing import aliases and test helpers

## Vitest-style repositories

Use when the repository already uses Vitest or a Vitest-compatible test setup.

Suitable for:

- pure functions
- rendering tests
- component tests
- static accessibility checks where supported
- props and input/output behaviour

Do not use Vitest to fake browser-only behaviour unless the repository already has a reliable convention for it.

For expected failures, use the repository's existing Vitest-compatible expected-failure convention. If none exists, report that as a test infrastructure question before editing.

## Playwright-style repositories

Use when the repository already uses Playwright or a Playwright-compatible browser test setup.

Suitable for:

- real browser interaction
- keyboard behaviour
- focus behaviour
- responsive behaviour
- scroll behaviour
- sticky behaviour
- navigation
- visibility changes
- browser-level accessibility checks where supported

For expected failures, use the repository's existing Playwright-compatible expected-failure convention. If none exists, report that as a test infrastructure question before editing.

## Astro repositories

Use when the repository already uses Astro.

Likely validation commands include:

```bash
npm test
npx astro check
```

Use existing component, integration, or browser tests already present in the repository.

Do not introduce Astro-specific tests into non-Astro repositories.

## Biome repositories

Use when the repository already uses Biome.

Prefer checking changed files when supported by repository scripts.

Example command shape:

```bash
npx biome check path/to/changed-file.ext
```

Use the repository's actual scripts when available.

## ESLint repositories

Use when the repository already uses ESLint.

Prefer existing scripts from `package.json`.

Do not add ESLint just to satisfy this skill.

## Markdown repositories

When specifications or generated documentation are edited, follow repository markdown rules.

Prefer:

- ATX headings
- dash bullets
- fenced code blocks
- ASCII punctuation
- descriptive link text
- traceable paths in backticks
