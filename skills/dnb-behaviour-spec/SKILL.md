---
id: dnb-behaviour-spec
name: dnb-behaviour-spec
title: DNB Behaviour Specification
type: skill
description: "Create, review, and generate tests from strict Behaviour.spec.md files. Use when a repository contains or needs behaviour specifications for features, components, pages, modules, CLIs, APIs, workflows, or integrations; when asked to review a Behaviour.spec.md file; when generating or updating tests from a behaviour specification; or when validating implementation against specified behaviour."
---

## Behaviour specification

Use this skill when a repository contains or needs a `Behaviour.spec.md` file that defines expected behaviour for a feature, component, page, module, CLI, API, workflow, or integration.

## Purpose

This skill enforces a specification-first workflow:

1. Write or update `Behaviour.spec.md`.
2. Review the specification for clarity, completeness, and testability.
3. Generate or update tests from the specification.
4. Validate the implementation against those tests.

`Behaviour.spec.md` is the source of truth.

Existing implementation may be inspected for file consistency, test placement, and current coverage. It must not be used to invent missing behaviour.

## Core workflow

```text
Behaviour.spec.md
-> review specification
-> resolve all blocking questions
-> generate or update tests
-> validate
-> report traceable results
```

## When to use this skill

Use this skill when the user asks to:

- create a behaviour specification
- review a `Behaviour.spec.md` file
- generate tests from a behaviour specification
- validate implementation against a behaviour specification
- debug mismatches between tests, implementation, and documented behaviour
- prepare a feature or component for strict test coverage

## Required files

A complete behaviour specification must follow `references/behaviour-spec-contract.md`.

Use `templates/Behaviour.spec.md` when creating a new specification.

## Framework policy

This skill is framework-neutral.

Use the repository's existing test tools and conventions.

Do not introduce new test frameworks, packages, runners, or tooling unless:

- the user explicitly requests it
- the repository has no viable existing test path
- the missing tooling is reported as a blocker first

Framework-specific guidance belongs in `references/framework-profiles.md`.

## Strict mode

Strict mode is the default.

New behaviour specifications must use:

```yaml
strict: true
```

In strict mode, open questions block test generation.

Do not generate tests from an ambiguous specification.

## Behaviour IDs

Every invariant, behaviour, edge case, and accessibility requirement must have a stable ID.

Use these prefixes:

- `I001` for invariants
- `B001` for behaviours
- `E001` for edge cases
- `A001` for accessibility requirements

IDs must be used in test names, comments, coverage reports, and validation summaries where relevant.

## Workflow selection

### Create or update a specification

Use `templates/Behaviour.spec.md`.

Do not infer hidden requirements from implementation.

If behaviour is unclear, add it to `Open questions`.

### Review a specification

Use `references/review-gate.md`.

Review the specification itself.

Implementation files may be read only to detect:

- missing referenced files
- naming mismatches
- components or modules present in scope but omitted from the spec
- existing tests that already cover specified behaviour
- contradictions between stated scope and local files

Do not edit implementation or tests during review.

### Generate or update tests

Use `references/test-generation.md`.

Only generate tests for behaviour that is clear enough to assert.

If the spec has blocking open questions, stop before editing tests.

If the spec is clear but the implementation does not satisfy it, create or update the test and mark it as expected failing using the repository's existing test framework conventions.

Expected failing tests must be traceable and must not silently skip validation.

### Validate

Use `references/validation.md`.

Run the relevant repository validation commands.

Report results with traceable file references.

Do not claim success unless validation passed or expected failures were explicitly marked and reported.

## Stop conditions

Stop before editing tests or implementation when:

- `Behaviour.spec.md` is missing
- required sections are missing
- `strict: true` is missing in a new spec
- any required behaviour lacks an ID
- any behaviour is ambiguous
- any behaviour lacks a trigger
- any behaviour lacks an expected result
- required thresholds are missing
- open questions affect test generation
- the test type cannot be determined from the spec
- repository test conventions are unclear
- adding required tooling would be necessary but has not been approved

## Core rules

- Specification over implementation.
- Observable behaviour over implementation detail.
- Stable IDs over prose-only tracking.
- Atomic statements over compound statements.
- Explicit thresholds over vague wording.
- Open questions over guessing.
- Expected failures over skipped failures.
- Existing tools over new packages.
- Traceable reports over generic summaries.
