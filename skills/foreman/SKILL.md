---
id: foreman
name: foreman
title: Foreman
description: Route Clerkwork engineering skills from short command-style requests such as `foreman audit packages` or `foreman issues next`. Use when the user addresses foreman directly, or asks to audit the repository, work through GitHub issues, check project status, or otherwise wants Clerkwork to decide which skill handles a task. Asks a clarifying question whenever the area or action is missing or ambiguous, and never performs the underlying work itself.
argument-hint: "<audit|agent-align|issues|status|resume> [target]"
---

Use this router skill whenever the user addresses `foreman` or otherwise asks
Clerkwork to pick the right skill for an engineering task. It understands
short command-style phrasing in the form `foreman <area> [action]`, such as
`foreman audit packages` or `foreman issues next`, but the area and action can
also arrive spread across a conversation or a plain-language request.

## How to route

1. Parse the request into an *area* (what kind of work) and an *action* (what
   to do within that area).
2. If the area is missing, or does not match a known area below, ask the user
   which area they mean before doing anything else.
3. If the area is known but the action is missing or ambiguous, ask which
   action within that area, listing the available actions for that area.
4. Once both are resolved, hand off to exactly the matching skill below. Do
   not perform the underlying work yourself, and do not skip a target skill's
   own confirmation or safety steps.
5. If the user's request already unambiguously names a Clerkwork skill, or
   clearly wants something the areas below do not cover, hand off directly
   instead of replaying the `foreman <area> [action]` grammar back at them.

## Areas and actions

### `audit` — dependency and vulnerability upkeep

Ask "What should I audit: packages, security, or the Node version policy?"
when the action is missing.

* `packages` → `clerkwork-dependency-maintenance`
* `security` → `clerkwork-osv-scan`
* `node` (or "node version(s)") → `clerkwork-manage-node-version-policy`

### `agent-align` — align repository agent instruction files

Route to `clerkwork-agent-align` only when the request explicitly asks to
`onboard clerkwork`, asks for `agent alignment`, or names `agent-align`.
The target skill must ask the user to confirm before it inspects or changes
repository instruction files.

Do not route general onboarding, setup, documentation, agent, instruction, or
configuration requests to this skill unless they include one of those exact
intents.

### `issues` — issue tracker workflow

Ask "What do you want to do with issues: select the next one, work the next
one, work through all of them, work a specific issue number, sync tracking,
or set up the label taxonomy?" when the action is missing.

* `select` → `clerkwork-select-next-issue`
* `next` → `clerkwork-work-on-next-issue`
* `all` → `clerkwork-work-through-issues`
* `setup` → `clerkwork-github-label-classifier`
* `sync` → `clerkwork-project-task-triage`
* a specific issue number (for example `issues 123` or `issues work 123`) →
  `clerkwork-work-on-issue`

### `status` — project state

A bare `foreman status` (or `foreman report`) needs no further action; route
straight to `clerkwork-project-state-report`.

### `resume` — interrupted work

A bare `foreman resume` needs no further action; route straight to
`clerkwork-resume-interrupted-work`.

## Rules

* Never guess an area or action that was not stated or confirmed; ask
  instead.
* Do not duplicate a target skill's own logic here — this skill only
  identifies which one to run and hands off.
* If none of the areas fit, say so rather than forcing the request into one.
