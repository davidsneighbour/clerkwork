---
strict: true
---

# Behaviour specification

## Scope

This specification covers a header navigation component with a site title, primary navigation links, and a mobile menu toggle.

### Files in scope

- `src/components/Header/Header.astro`
- `src/components/Header/Header.test.ts`
- `tests/e2e/header.spec.ts`

### Files out of scope

- `src/components/Footer/Footer.astro`

## Vocabulary

- `mobile`: Viewports below `768px`.
- `desktop`: Viewports at or above `768px`.
- `visible`: Rendered in the DOM and perceivable by users, not hidden with `display: none`, `visibility: hidden`, `aria-hidden="true"`, or equivalent hiding behaviour.
- `closed`: The menu content is not visible and cannot be reached by keyboard navigation.

## Invariants

| ID | Statement | Test type |
| --- | --- | --- |
| `I001` | The site title links to `/`. | Unit/component |
| `I002` | The primary navigation is exposed as a navigation landmark. | Unit/component |

## Behaviours

| ID | Context | Trigger | Expected result | Test type |
| --- | --- | --- | --- | --- |
| `B001` | Mobile viewport below `768px` | The header is rendered | The mobile menu is closed. | Browser/e2e |
| `B002` | Mobile viewport below `768px` | The menu button is activated | The mobile menu becomes visible. | Browser/e2e |
| `B003` | Mobile viewport below `768px` with the menu open | The menu button is activated again | The mobile menu becomes closed. | Browser/e2e |
| `B004` | Desktop viewport at or above `768px` | The header is rendered | The primary navigation links are visible without activating a menu button. | Browser/e2e |

## Edge cases

| ID | Context | Trigger | Expected result | Test type |
| --- | --- | --- | --- | --- |
| `E001` | No navigation links are configured | The header is rendered | The site title remains visible and no empty navigation list is rendered. | Unit/component |

## Accessibility requirements

| ID | Requirement | Test type |
| --- | --- | --- |
| `A001` | The menu button has an accessible name. | Unit/component |
| `A002` | The menu button can be operated with keyboard input. | Browser/e2e |

## Test mapping

| Spec ID | Test location | Required assertion |
| --- | --- | --- |
| `I001` | `src/components/Header/Header.test.ts` | Assert that the site title link has `href="/"`. |
| `I002` | `src/components/Header/Header.test.ts` | Assert that a navigation landmark exists. |
| `B001` | `tests/e2e/header.spec.ts` | Assert that the menu is closed after initial render below `768px`. |
| `B002` | `tests/e2e/header.spec.ts` | Assert that activating the menu button makes the menu visible below `768px`. |
| `B003` | `tests/e2e/header.spec.ts` | Assert that activating the menu button again closes the menu below `768px`. |
| `B004` | `tests/e2e/header.spec.ts` | Assert that navigation links are visible at or above `768px`. |
| `E001` | `src/components/Header/Header.test.ts` | Assert that no empty navigation list is rendered when there are no links. |
| `A001` | `src/components/Header/Header.test.ts` | Assert that the menu button has an accessible name. |
| `A002` | `tests/e2e/header.spec.ts` | Assert that keyboard activation toggles the menu. |

## Non-goals

- This specification does not define animation duration or easing.
- This specification does not define visual styling beyond visibility and accessibility requirements.

## Open questions

- None.
