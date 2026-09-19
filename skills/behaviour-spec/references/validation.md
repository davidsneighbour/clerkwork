# Validation

Use this reference after reviewing, generating, or updating tests.

## Validation policy

Run the repository's existing validation commands.

Do not introduce new validation tools unless approved.

Prefer commands already defined in:

- `package.json`
- task runner files
- Makefiles
- CI workflows
- repository documentation
- existing agent instructions

## Command selection

Choose the smallest set of commands that validates the changed behaviour.

Run broader checks when the repository convention requires them.

Common examples:

- unit test command
- integration test command
- browser or e2e test command
- type check command
- lint command for changed files
- formatter check for changed files
- build command when test changes affect build output

## Framework-specific commands

Framework-specific defaults belong in `references/framework-profiles.md`.

Do not make framework-specific commands mandatory for unrelated repositories.

## Failure classification

Classify failures as one of:

- pre-existing failure
- introduced failure
- expected failure from clear spec mismatch
- environment issue
- missing dependency or setup
- unknown

## Expected failures

Expected failing tests are allowed only when:

- the specification is clear
- the implementation does not satisfy the specification
- the repository test framework supports an expected-failure mechanism
- the expected failure is traceable to a spec ID

Expected failures must be reported separately from passing validation.

## Required validation report

For each command, report:

- command
- result
- relevant output
- failure classification, if applicable

Use traceable file references where possible.

Example:

```text
Command: npm test
Result: passed
Relevant files:
- src/components/Header/Header.test.ts:38
- src/components/Header/Behaviour.spec.md:22
```

## Do not claim success when

Do not claim success when:

- commands were not run
- commands failed unexpectedly
- expected failures were not clearly marked
- failures were skipped silently
- validation output is unavailable
- the environment prevented meaningful validation

If validation could not be run, say so directly and explain why.
