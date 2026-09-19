---
id: foreman
name: foreman
title: Foreman
description: Interface to the Clerkwork skill collection. Use `foreman overview` to list all available skills by category, use category or topic requests such as `foreman git` or `foreman project` to narrow the catalogue, or route a concrete request such as `foreman audit packages` to the matching Clerkwork skill. Foreman identifies the job and hands it off; it does not duplicate the target skill's work.
argument-hint: "<overview|agent|repository|project|git|audit|issues|status|resume> [action|target]"
---

Use this skill whenever the user addresses `foreman`, wants to see what Clerkwork can do, cannot remember a skill name, or wants Clerkwork to choose the right skill for a task.

## Overview

A bare `foreman`, `foreman overview`, `foreman help`, or equivalent request must print the complete catalogue below, grouped by category. Include each skill name and a short description. Do not require the user to remember a category or exact skill name before showing the overview.

If the user supplies a broad category or topic without a concrete action, show only the matching category and its available skills. Examples include `foreman git`, `foreman github`, `foreman project`, `foreman agent`, and `foreman repository`.

## Catalogue

### Agent management

* `agent-align` — create or repair repository agent entry-point files and alignment.
* `agent-instructions-audit` — audit or optimise agent instruction architecture, scope, duplication, and context cost.

### Repository maintenance

* `dependency-maintenance` — inspect and safely update npm dependencies.
* `manage-node-version-policy` — audit and align Node.js and npm version declarations.
* `osv-scan` — scan dependencies for known vulnerabilities, apply safe fixes, and track follow-up work.

### Project management

* `project-state-report` — refresh and report repository state and recent GitHub activity.
* `project-task-triage` — sync TODO.md, GitHub Issues, and PROJECT.md.
* `resume-interrupted-work` — resume or resolve work recorded in RESUME.md before unrelated work starts.

### Git and GitHub

* `commit` — write a Git commit message that follows the Conventional Commits specification.
* `labels` — classify issues with the repository label taxonomy.
* `select-next-issue` — select one suitable open issue without implementing it.
* `work-on-issue` — implement one explicitly selected GitHub issue.
* `work-on-next-issue` — select and implement the next suitable issue.
* `work-through-issues` — repeatedly select and implement actionable issues until none remain.

## Routing

1. If the user requests an overview, help, a list of skills, or asks what Clerkwork can do, show the catalogue instead of asking a clarifying question.
2. If the user gives only a category or topic, show that category and its available jobs.
3. If the request clearly matches one skill, hand off directly to that skill.
4. If the category is known but multiple actions remain plausible, list the relevant skills and ask the user to choose only when their intended job cannot be inferred.
5. Do not perform the target skill's underlying work inside Foreman, and do not bypass its confirmation or safety rules.

## Common command routes

* `foreman audit packages` → `dependency-maintenance`
* `foreman audit security` → `osv-scan`
* `foreman audit node` → `manage-node-version-policy`
* `foreman agent align` → `agent-align`
* `foreman agent instructions` → `agent-instructions-audit`
* `foreman status` or `foreman report` → `project-state-report`
* `foreman resume` → `resume-interrupted-work`
* `foreman issues select` → `select-next-issue`
* `foreman issues next` → `work-on-next-issue`
* `foreman issues all` → `work-through-issues`
* `foreman issues labels` → `labels`
* `foreman issues sync` → `project-task-triage`
* `foreman commit` → `commit`
* a specific issue number, such as `foreman issues 123` → `work-on-issue`

## Rules

* Treat `overview` as a discovery operation, not a work operation.
* Prefer showing a small relevant catalogue over asking the user to remember exact names.
* Keep skill names flat; categories never become part of the public invocation name.
* Never invent a skill that is not in the catalogue.
* If no skill fits, say so rather than forcing the request into the nearest category.
