# Test generation from behaviour specifications

Use this reference when generating or updating tests from a `Behaviour.spec.md` file.

## Role

Generate or update tests so that the repository test suite aligns with `Behaviour.spec.md`.

`Behaviour.spec.md` is the source of truth.

## Core rules

Do not:

- infer behaviour from implementation
- invent behaviour
- improve behaviour beyond the spec
- add new test frameworks without approval
- silently skip failing behaviour
- generate tests for ambiguous behaviour

Do:

- use existing repository test tools
- follow existing test style
- keep tests colocated when that is the repository convention
- keep tests minimal and maintainable
- use spec IDs in test names or nearby comments
- report traceable changed files

## Stop before editing

Stop before changing tests when:

- `Behaviour.spec.md` is missing
- required sections are missing
- `strict: true` is missing
- any testable item lacks an ID
- open questions affect test generation
- behaviour is ambiguous
- expected result is missing
- trigger is missing
- required thresholds are missing
- no existing test strategy can be identified

## Coverage report first

Before editing tests, produce a coverage report with these groups:

- Covered
- Partially covered
- Missing
- Blocked by ambiguity
- Blocked by open questions
- Blocked by missing test infrastructure
- Contradicted by implementation

Each entry must include:

- spec ID
- short behaviour summary
- traceable spec location
- traceable test location when known

## Test type selection

Use the repository's existing test types.

Map behaviours to the narrowest suitable test type.

General guidance:

- pure logic belongs in unit tests
- rendering structure belongs in component or integration tests
- API contracts belong in integration or contract tests
- database behaviour belongs in integration tests
- CLI behaviour belongs in command or integration tests
- browser interaction belongs in browser or e2e tests
- visual-only checks belong in visual regression or manual checks when no automated tool exists
- accessibility should be automated where practical and manual only when needed

Do not simulate browser-only behaviour in unit tests unless the repository already has a reliable convention for it.

## Observable behaviour only

Test externally observable behaviour.

Good assertions:

- output contains expected text
- response has expected status code
- control has accessible name
- command exits with expected code
- menu becomes visible after activation
- validation message appears for invalid input

Avoid implementation-detail assertions:

- private variable changed
- internal function was called
- CSS class exists
- framework-specific state value changed

Implementation details are allowed only when the spec explicitly defines them as part of the public contract.

## Expected failing tests

When the specification is clear but the implementation does not satisfy it, create or update the test and mark it as expected failing using the repository's existing framework convention.

Expected failing tests must:

- still execute
- be traceable to a spec ID
- include a short reason
- avoid blocking validation or automated commits
- fail the suite if the expected-failure marker is no longer valid, when the framework supports that behaviour

Do not use silent skips for clear required behaviour.

Do not mark ambiguous behaviour as expected failing.

Ambiguous behaviour must block generation instead.

## Test naming

Include the spec ID in test names when practical.

Example:

```text
B003 opens the mobile menu after activating the menu button
```

If the framework style discourages IDs in names, place the ID in a nearby comment.

## Editing rules

When editing tests:

- extend existing tests where possible
- avoid duplicate assertions
- create new files only when required
- preserve repository style
- preserve existing helpers and fixtures
- avoid broad rewrites
- do not change implementation unless the user explicitly asks for implementation fixes

## Validation

After editing tests, run the relevant validation commands from `references/validation.md`.

Do not claim success unless validation passed or expected failures are explicitly marked and reported.

## Required output

Use the test-generation output format in `references/output-formats.md`.

Do not include full file contents unless the user explicitly requests them.

Include important snippets only when they clarify the change.
