---
id: commit
name: commit
title: Clerkwork Commit Messages
type: skill
description: Write Git commit messages that follow the Conventional Commits specification (v1.0.0) — types, scopes, description, body, and footers — with examples and best practices. Use when creating a commit, drafting or reviewing a commit message, or checking commit history for consistency.
---

# Conventional commits

Write commit messages that follow the [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) specification: an explicit, machine-readable commit history that makes project changes and automation (changelogs, releases) easier.

## When to use this skill

Use this skill when:

- creating a Git commit
- drafting or reviewing a commit message
- reviewing commit messages in a pull request
- checking commit history for consistency with the specification

## Commit message structure

```text
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

```bash
git commit -m "type(scope): description"
```

## Commit types

**feat** — a new feature for the user

```text
feat: add export to PDF functionality
feat(api): add webhook signature verification
```

**fix** — a bug fix for the user

```text
fix: resolve login redirect loop
fix(api): handle null response from GitHub webhook
```

**docs** — documentation only changes

```text
docs: update API endpoint documentation
```

**style** — changes that don't affect code meaning (formatting, whitespace)

```text
style: format code with Biome
```

**refactor** — a code change that neither fixes a bug nor adds a feature

```text
refactor: extract user validation to service object
```

**perf** — performance improvements

```text
perf: add database index for user lookups
```

**test** — adding or updating tests

```text
test: add specs for user authentication
```

**chore** — build process, dependency, or maintenance changes

```text
chore: update dependencies
```

**build** — changes to the build system or dependencies

```text
build: configure Docker for production
```

**ci** — changes to CI configuration

```text
ci: add security scanning to GitHub Actions
```

**revert** — reverts a previous commit

```text
revert: revert "feat: add export feature"

This reverts commit abc123.
```

Use `type:chore` only when no more specific type applies.

## Scope (optional)

Scope names the part of the codebase that changed. Choose scopes that match the project's own architecture and domain areas, for example `auth`, `api`, `ui`, `database`, `deps`, `config`, `docs`.

```text
feat(auth): add two-factor authentication
fix(api): handle rate limit errors
```

## Description

**Rules:**

- use imperative, present tense: "add", not "added" or "adds";
- don't capitalise the first letter;
- no period at the end;
- keep under 72 characters, ideally under 50.

**Good:**

```text
add user profile page
fix memory leak in file upload
```

**Bad:**

```text
Added user profile page          # past tense
Fix Memory Leak In File Upload   # capitalised
Updated email templates.         # period at end
Lots of changes to the codebase  # vague
```

## Body (optional)

Include a body for complex changes, non-obvious design decisions, breaking changes, or migration instructions. Separate it from the description with a blank line, use the imperative mood, and explain *why*, not *what* — the diff already shows what changed.

```text
feat(api): add webhook signature verification

Add HMAC-SHA256 signature verification for all incoming webhooks
to prevent unauthorized access and replay attacks.
```

## Footer (optional)

**Breaking changes** use a `BREAKING CHANGE:` footer, or a `!` after the type/scope:

```text
feat(api)!: remove deprecated /login endpoint

BREAKING CHANGE: The /auth endpoint now requires a client_id parameter.
```

**Issue references:**

```text
fix(auth): resolve session timeout bug

Fixes #123
Closes #456
Related to #789
```

**Co-authors:**

```text
feat: add data export feature

Co-authored-by: Jane Doe <jane@example.com>
```

## Workflow

1. Run `git status` to review changed files.
2. Run `git diff` or `git diff --cached` to inspect the actual changes — never guess the message from the file list alone.
3. Stage the relevant files with `git add <file>`.
4. Construct the commit message using the structure above.
5. Run `git commit -m "type(scope): description"`, adding `-m` body/footer paragraphs as needed.

## Best practices

Do:

- use present-tense imperative mood ("add", not "added");
- keep the first line under 50 characters when possible;
- reference issues or PRs in the footer;
- explain "why" in the body, not "what";
- make commits atomic — one logical change per commit.

Don't:

- use vague descriptions ("fix stuff", "updates");
- combine multiple unrelated changes in one commit;
- capitalise the first letter or end the description with a period;
- use past tense;
- commit broken code.

For a fuller set of examples covering every type, scope pattern, and footer combination, see `resources/commit-examples.md`.
