# DNB behaviour spec

`dnb-behaviour-spec` is a reusable AI coding-agent skill for working with `Behaviour.spec.md` files.

It defines a strict, specification-first workflow for describing expected behaviour, reviewing that behaviour for clarity and testability, generating or updating tests from the specification, and validating the result with the repository's existing tooling.

## What this skill does

This skill helps an AI agent answer these questions before changing tests or implementation:

- What behaviour is actually specified?
- Is the specification complete enough to test?
- Which behaviours are already covered?
- Which behaviours are missing tests?
- Which behaviours are blocked by ambiguity?
- Which existing repository test tools should be used?
- Which files changed, and where?
- Which validation commands passed or failed?

The central rule is:

```text
Behaviour.spec.md is the source of truth.
```

Implementation files may be inspected for consistency, current coverage, and test placement. They must not be used to invent missing behaviour.

## Core workflow

```text
Behaviour.spec.md
-> review specification
-> resolve all blocking questions
-> generate or update tests
-> validate
-> report traceable results
```

The workflow is intentionally high-friction. A weak specification should fail before tests are generated.

## Directory layout

```text
dnb-behaviour-spec/
├── SKILL.md
├── README.md
├── examples/
│   └── Behaviour.spec.md
├── references/
│   ├── behaviour-spec-contract.md
│   ├── framework-profiles.md
│   ├── output-formats.md
│   ├── review-gate.md
│   ├── test-generation.md
│   └── validation.md
└── templates/
    └── Behaviour.spec.md
```

## File purpose

### `SKILL.md`

Main entry point for the AI agent.

It explains when to use the skill, what the workflow is, when to stop, and which reference files to read for each task.

### `templates/Behaviour.spec.md`

Template for creating a new behaviour specification.

Use this whenever a repository does not yet have a `Behaviour.spec.md` file for the feature, component, page, module, CLI, API, workflow, or integration being tested.

### `references/behaviour-spec-contract.md`

Canonical contract for valid `Behaviour.spec.md` files.

This defines required sections, behaviour ID rules, strict mode, vocabulary rules, invariant rules, behaviour rules, edge case rules, accessibility rules, test mapping rules, open question rules, and forbidden vague wording.

### `references/review-gate.md`

Rules for reviewing a behaviour specification before generating tests.

Use this when the task is to decide whether a spec is precise, complete, and testable enough.

### `references/test-generation.md`

Rules for generating or updating tests from a valid behaviour specification.

Use this after the review gate passes and only when there are no blocking open questions.

### `references/validation.md`

Rules for selecting and reporting validation commands.

This keeps validation tied to the repository's existing scripts and tooling.

### `references/framework-profiles.md`

Optional framework-specific guidance.

The core skill is framework-neutral. Framework-specific advice belongs here and should only be used when the repository already uses that framework or tool.

### `references/output-formats.md`

Required output structures for review and test-generation work.

This keeps reports consistent and traceable.

### `examples/Behaviour.spec.md`

Example specification showing the expected structure and level of detail.

## Behaviour specification contract

A `Behaviour.spec.md` file is a strict specification artifact.

New specs must use:

```yaml
---
strict: true
---
```

A complete spec contains these sections:

- `Scope`
- `Vocabulary`
- `Invariants`
- `Behaviours`
- `Edge cases`
- `Accessibility requirements`
- `Test mapping`
- `Non-goals`
- `Open questions`

If a section is not relevant, keep the heading and write `None.`.

## Behaviour IDs

Every testable item must have a stable ID.

Use these prefixes:

- `I001` for invariants
- `B001` for behaviours
- `E001` for edge cases
- `A001` for accessibility requirements

IDs must be used in test names, comments, coverage reports, and validation summaries where relevant.

Example:

```markdown
| ID | Context | Trigger | Expected result | Test type |
| --- | --- | --- | --- | --- |
| `B001` | Mobile viewport below `768px` | The menu button is activated | The mobile menu becomes visible. | Browser/e2e |
```

A matching test name could be:

```text
B001 opens the mobile menu after activating the menu button
```

## Open questions

Open questions block test generation in strict mode.

Use:

```markdown
## Open questions

- None.
```

only when there are no unresolved questions.

If an open question affects a behaviour, the agent must stop before editing tests.

Example blocking question:

```markdown
## Open questions

- What viewport width defines `mobile` for `B001`?
```

That question blocks any test for `B001` because the test cannot choose a viewport without guessing.

## Expected failing tests

When the specification is clear but the implementation does not satisfy it, the agent may create or update a test and mark it as expected failing using the repository's existing test framework convention.

Expected failing tests are allowed only when:

- the behaviour is clear
- the expected result is defined
- the implementation currently does not satisfy the spec
- the repository test framework supports expected failures
- the expected failure is traceable to a spec ID

Expected failing tests must not be used for ambiguous behaviour.

Ambiguous behaviour blocks generation instead.

## Framework policy

This skill supports any framework.

The agent must use the repository's existing tools and conventions.

The agent must not introduce new test runners, packages, or frameworks unless one of these is true:

- the user explicitly requests it
- the repository has no viable existing test path
- the missing tooling is reported as a blocker first

Examples:

- If a repository already uses Vitest, use Vitest for suitable unit, rendering, or component tests.
- If a repository already uses Playwright, use Playwright for browser interaction, keyboard, focus, scroll, viewport, and responsive behaviour.
- If a repository already uses another test runner, use that runner instead.
- If a repository has no suitable test setup, report that as a test infrastructure blocker.

## Traceable output

Reports must use traceable file references.

Preferred format:

```text
path/to/file.ext:123
```

If line numbers are unavailable, use a heading reference:

```text
path/to/Behaviour.spec.md#Behaviours
```

The output should include:

- summary
- coverage report
- files changed
- important snippets
- validation output
- open questions

Do not include full file contents unless the user explicitly requests them.

## How to use this skill

### 1. Install the skill

Copy the directory into your skills folder:

```text
skills/30-quality-and-verification/dnb-behaviour-spec/
```

The directory must include `SKILL.md`.

### 2. Create a behaviour spec

Copy the template:

```text
templates/Behaviour.spec.md
```

into the relevant feature or component folder as:

```text
Behaviour.spec.md
```

Then fill out all required sections.

### 3. Ask the agent to review the spec

Example prompt:

```text
Use the dnb-behaviour-spec skill to review src/components/Header/Behaviour.spec.md. Do not generate tests yet.
```

The agent should use:

```text
references/review-gate.md
references/behaviour-spec-contract.md
references/output-formats.md
```

### 4. Fix blocking issues

If the review returns `REJECT`, fix the specification first.

Do not ask the agent to generate tests until blocking issues are resolved.

Common blocking issues are:

- missing behaviour IDs
- missing trigger
- missing expected result
- missing viewport or timing threshold
- vague wording
- unresolved open questions
- incomplete test mapping

### 5. Generate or update tests

Example prompt:

```text
Use the dnb-behaviour-spec skill to generate or update tests from src/components/Header/Behaviour.spec.md. Use the repository's existing test tools only.
```

The agent should use:

```text
references/test-generation.md
references/framework-profiles.md
references/validation.md
references/output-formats.md
```

### 6. Validate

The agent should run the relevant existing repository commands.

Examples may include:

```bash
npm test
```

```bash
npm run test:e2e
```

```bash
npm run lint
```

```bash
npx astro check
```

These are examples only. The actual commands must come from the repository's existing scripts, documentation, CI, or conventions.

## Good specification example

```markdown
| ID | Context | Trigger | Expected result | Test type |
| --- | --- | --- | --- | --- |
| `B001` | Mobile viewport below `768px` | The header is rendered | The mobile menu is closed. | Browser/e2e |
| `B002` | Mobile viewport below `768px` | The menu button is activated | The mobile menu becomes visible. | Browser/e2e |
```

This is good because each behaviour has:

- stable ID
- defined context
- defined trigger
- observable expected result
- appropriate test type

## Bad specification example

```markdown
- The menu should work properly on mobile.
```

This is bad because it lacks:

- behaviour ID
- viewport threshold
- trigger
- expected result
- test type
- assertion target

A better version:

```markdown
| ID | Context | Trigger | Expected result | Test type |
| --- | --- | --- | --- | --- |
| `B001` | Mobile viewport below `768px` | The menu button is activated | The mobile menu becomes visible. | Browser/e2e |
```

## Decision states

Review work ends with exactly one of these decisions:

```text
ACCEPT
```

```text
ACCEPT WITH ISSUES
```

```text
REJECT
```

In strict mode, blocking issues require `REJECT`.

Use `ACCEPT WITH ISSUES` only for non-blocking issues.

## Agent stop conditions

The agent must stop before editing tests or implementation when:

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

## Design principles

- Specification over implementation.
- Observable behaviour over implementation detail.
- Stable IDs over prose-only tracking.
- Atomic statements over compound statements.
- Explicit thresholds over vague wording.
- Open questions over guessing.
- Expected failures over skipped failures.
- Existing tools over new packages.
- Traceable reports over generic summaries.
