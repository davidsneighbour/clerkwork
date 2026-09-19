# Behaviour specification review gate

Use this reference to review a `Behaviour.spec.md` file before generating tests.

## Role

Review the specification itself.

Do not:

- implement tests
- modify application code
- fill gaps from implementation
- invent intended behaviour
- resolve ambiguity silently

## Inputs

The user should provide a path to a `Behaviour.spec.md` file or a folder containing one.

Read:

- the provided `Behaviour.spec.md`
- referenced files, if they exist
- existing tests, if they exist
- nearby files only when needed for consistency checks

## Implementation inspection limits

Implementation files may be read only to detect:

- referenced files that do not exist
- referenced tests that do not exist
- files present in the folder but omitted from scope
- naming mismatches
- current test coverage for specified behaviour
- obvious contradictions between file names and spec scope

Do not reinterpret the spec based on implementation.

## Required review checks

Check the specification for:

- required front matter
- required sections
- stable behaviour IDs
- complete scope
- clear vocabulary
- valid invariants
- atomic behaviours
- relevant edge cases
- accessibility requirements where applicable
- complete test mapping
- unresolved open questions
- vague wording
- missing thresholds
- impossible assertions
- framework assumptions
- test type mismatches

## Strict decision rules

If `strict: true` is present, reject the specification when any of these are true:

- any required section is missing
- any testable item lacks an ID
- any ID is duplicated
- any behaviour lacks context
- any behaviour lacks trigger
- any behaviour lacks expected result
- any required threshold is missing
- any behaviour depends on interpretation
- any behaviour depends on implementation knowledge
- any open question affects test generation
- test mapping is missing for any ID
- a test type is impossible or unsupported by the repository
- vague wording makes an assertion unreliable

Strict mode is a hard gate.

Do not return `ACCEPT WITH ISSUES` in strict mode when there is a blocking issue.

## Decision states

End with exactly one decision:

- `ACCEPT`
- `ACCEPT WITH ISSUES`
- `REJECT`

Use `ACCEPT WITH ISSUES` only when issues are non-blocking.

Use `REJECT` when tests should not be generated.

## Required output

Use the review output format in `references/output-formats.md`.

## Review style

Be strict and specific.

For each issue, include:

- traceable location where possible
- problematic text or summary
- why it is weak
- required correction
- suggested rewrite when useful

Use traceable file references like:

```text
src/components/Header/Behaviour.spec.md:42
```

If exact line numbers are unavailable, use the closest heading path:

```text
src/components/Header/Behaviour.spec.md#Behaviours
```
