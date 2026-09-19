# Behaviour specification contract

A `Behaviour.spec.md` file is a strict specification artifact.

It defines what must be true, what must be tested, and what remains unresolved.

It is not an implementation note, planning document, or test wishlist.

## Required front matter

```yaml
---
strict: true
---
```

Strict mode is required by default.

## Required sections

A complete specification must contain these sections:

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

## Behaviour ID rules

Every testable item must have a stable ID.

Use these prefixes:

- `I001`, `I002`, `I003` for invariants
- `B001`, `B002`, `B003` for behaviours
- `E001`, `E002`, `E003` for edge cases
- `A001`, `A002`, `A003` for accessibility requirements

IDs must not be reused for different behaviour.

IDs should remain stable across edits unless the behaviour is removed.

## Scope rules

The scope must say what is included and what is excluded.

The scope must list relevant files when known.

The scope must not rely on phrases like:

- this component
- this feature
- related files
- everything here

unless those phrases are made concrete by file paths or explicit names.

## Vocabulary rules

Vocabulary must be stable and operational.

Define terms when they affect tests.

Examples:

- `visible`
- `hidden`
- `active`
- `selected`
- `mobile`
- `desktop`
- `valid`
- `invalid`
- `empty`
- `authenticated`
- `unauthorised`

Bad vocabulary:

- `fast`: not measurable
- `nice`: subjective
- `properly`: vague
- `responsive`: incomplete without breakpoints or contexts

## Invariant rules

An invariant is something that must always hold.

Good invariant:

- `I001`: The site title links to `/`.

Bad invariant:

- `I001`: The component stores menu state internally.

Invariants must be observable from outside the implementation.

## Behaviour rules

Each behaviour must be:

- observable
- atomic
- testable
- scoped
- free of hidden implementation assumptions

Each behaviour must define:

- ID
- context
- trigger
- expected result
- test type

Good behaviour:

- `B001`: In the initial mobile state, when the navigation is rendered, the menu is closed.

Bad behaviour:

- `B001`: The menu works correctly on mobile.

## Edge case rules

Edge cases should cover relevant exceptional or boundary states.

Examples:

- empty input
- missing optional data
- invalid input
- unavailable network
- unauthorised request
- disabled feature
- unsupported environment
- duplicate values
- very long content

Do not add speculative edge cases unless they are relevant to the stated scope.

## Accessibility rules

For user interfaces, define accessibility requirements where applicable.

Consider:

- landmarks
- roles
- accessible names
- keyboard reachability
- focus order
- focus trapping
- escape behaviour
- aria state
- reduced motion
- contrast only when the repository has a testable standard

Accessibility requirements must still be testable or explicitly marked as manual.

## Test mapping rules

Every ID from these sections must appear in `Test mapping`:

- `Invariants`
- `Behaviours`
- `Edge cases`
- `Accessibility requirements`

A test mapping must include:

- spec ID
- test location
- required assertion

If the test file does not exist yet, list the intended path.

## Open question rules

Open questions block test generation in strict mode.

Use `None.` only when there are no open questions.

Do not hide ambiguity in prose.

Do not generate tests for behaviour affected by open questions.

## Non-goal rules

Non-goals prevent accidental scope expansion.

Use non-goals to state what the specification intentionally does not cover.

Good non-goal:

- This specification does not define animation easing.

Bad non-goal:

- More tests later.

## Forbidden wording

Avoid behaviour statements containing:

- properly
- correctly
- smoothly
- nicely
- intuitively
- should work
- should behave
- user-friendly
- responsive
- some
- a bit
- as needed
- etc.

These words may appear only when followed by concrete, testable definitions.

## Threshold rules

Behaviours involving these concepts must define concrete thresholds or conditions:

- scroll position
- timing
- delay
- viewport size
- breakpoints
- animation state
- number of items
- input length
- timeout
- retry count
- permissions
- authentication state

Do not infer thresholds from implementation.

## Manual verification

Manual verification is allowed only when automated testing is not practical.

Manual checks must still include:

- ID
- exact condition
- exact expected result
- reason automation is not used
