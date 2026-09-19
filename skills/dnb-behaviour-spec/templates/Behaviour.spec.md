---
strict: true
---

# Behaviour specification

## Scope

Describe the feature, component, page, module, CLI, API, workflow, or integration covered by this specification.

### Files in scope

- `path/to/file.ext`

### Files out of scope

- `path/to/other-file.ext`

## Vocabulary

Define all terms that are used in behaviours and tests.

- `term`: Definition.

## Invariants

List behaviour that must always hold.

| ID | Statement | Test type |
| --- | --- | --- |
| `I001` | The system always ... | Unit/integration/browser/e2e/manual |

## Behaviours

Each behaviour must be observable, atomic, and testable.

| ID | Context | Trigger | Expected result | Test type |
| --- | --- | --- | --- | --- |
| `B001` | Initial state | The subject is rendered or started | The subject ... | Unit/integration/browser/e2e/manual |

## Edge cases

List relevant boundary, empty, invalid, unsupported, degraded, or error states.

| ID | Context | Trigger | Expected result | Test type |
| --- | --- | --- | --- | --- |
| `E001` | Empty input | The subject receives no items | The subject ... | Unit/integration/browser/e2e/manual |

## Accessibility requirements

Use this section when the subject has a user interface.

| ID | Requirement | Test type |
| --- | --- | --- |
| `A001` | The control has an accessible name. | Unit/browser/e2e/manual |

## Test mapping

Map every invariant, behaviour, edge case, and accessibility requirement to a test location.

| Spec ID | Test location | Required assertion |
| --- | --- | --- |
| `B001` | `path/to/file.test.ext` | Assert that ... |

## Non-goals

List behaviour this specification intentionally does not define.

- This specification does not define ...

## Open questions

Open questions block test generation in strict mode.

- None.
