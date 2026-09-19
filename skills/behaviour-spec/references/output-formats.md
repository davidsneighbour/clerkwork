# Output formats

Use these output formats for behaviour specification work.

## Review output

Return review results in this structure:

```markdown
## Specification summary

Briefly describe what the specification covers.

## Structural issues

List missing or malformed sections.

Use `None.` when there are no issues.

## Coverage issues

List missing scope, missing behaviours, missing edge cases, or omitted files.

Use traceable locations.

## Clarity and testability issues

List vague, compound, subjective, or non-testable behaviour.

For each issue include:

- location
- spec ID, if available
- problem
- required correction
- suggested rewrite, if useful

## Vocabulary issues

List missing, inconsistent, or non-operational vocabulary.

## Behaviour ID issues

List missing, duplicated, unstable, or incorrectly formatted IDs.

## Test mapping issues

List missing mappings, impossible mappings, duplicate mappings, or wrong test types.

## File consistency issues

List mismatches between the spec and local files.

Do not infer missing behaviour from implementation.

## Open questions

List questions that block test generation.

If none, write `None.`.

## Recommended additions or rewrites

Provide concrete replacement text where useful.

## Decision

ACCEPT
```

The final decision must be exactly one of:

- `ACCEPT`
- `ACCEPT WITH ISSUES`
- `REJECT`

## Test-generation output

Return test-generation results in this structure:

```markdown
## Coverage report

### Covered

- `B001` - Summary. Covered by `path/to/test.ext:42`.

### Partially covered

- `B002` - Summary. Partial coverage in `path/to/test.ext:55`.

### Missing

- `B003` - Summary. No existing test found.

### Blocked by ambiguity

- `B004` - Summary. Blocked by `path/to/Behaviour.spec.md:31`.

### Blocked by open questions

- `B005` - Summary. Blocked by `path/to/Behaviour.spec.md:74`.

### Blocked by missing test infrastructure

- `B006` - Summary. No existing suitable test runner found.

### Contradicted by implementation

- `B007` - Summary. Spec says X, implementation currently does Y at `path/to/file.ext:88`.

## Files changed

- `path/to/test.ext:42` - Added coverage for `B001`.
- `path/to/test.ext:77` - Added expected failing coverage for `B007`.

## Important snippets

Include only relevant snippets.

Do not include full file contents unless explicitly requested.

## Validation results

### Command

```bash
npm test
```

Result: passed.

### Command

```bash
npm run test:e2e
```

Result: passed with expected failure for `B007`.

## Open questions

Use `None.` when no open questions remain.

## Traceable file references

Use traceable file references throughout review and test-generation output.

Preferred form:

```text
path/to/file.ext:123
```

Fallback form when line numbers are unavailable:

```text
path/to/file.ext#Heading
```

Do not use vague references like:

- in the component
- in the test file
- somewhere in the spec
- above

## Full file contents

Do not include full file contents by default.

Include full file contents only when:

- the user explicitly asks for them
- the file is short and full content is necessary for correctness
- the assistant first asks and the user confirms

Prefer summaries, traceable paths, validation output, and important snippets.
