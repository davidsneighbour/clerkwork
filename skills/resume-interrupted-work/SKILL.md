---
id: resume-interrupted-work
name: resume-interrupted-work
title: Resume interrupted work
type: skill
description: Manage a project-root RESUME.md handoff file that blocks new work until previously interrupted or paused work is resolved. Use whenever work starts in a repository, when the user says resume, continue, or carry on, or when previous work may have been interrupted.
---

Use this skill whenever work starts in a repository, when the user says `resume`, `continue`, `carry on`, or when previous work may have been interrupted.

This skill manages a project-root `RESUME.md` scratch file that allows any agent to continue unfinished work safely.

## Purpose

`RESUME.md` is a temporary handoff file for interrupted agent work.

It must explain the unfinished task clearly enough that another agent can resume without hidden context, previous chat history, or assumptions.

## Startup Rule

Before starting project work, check whether a project-root `RESUME.md` exists.

If `RESUME.md` exists:

1. Read it first.
2. Treat its contents as blocking unfinished work.
3. Do not start unrelated work until the resume work is resolved.
4. Continue or complete the unfinished work described in `RESUME.md`.
5. Remove `RESUME.md` once the unfinished work is solved, abandoned by explicit user instruction, or fully incorporated into the new task.

Only after `RESUME.md` has been resolved and removed may normal work continue.

## No Resume File

If no project-root `RESUME.md` exists, continue with the user's current request normally.

Do not create `RESUME.md` pre-emptively.

## User Says Resume or Continue

When the user says `resume`, `continue`, `carry on`, or similar:

1. Check for project-root `RESUME.md`.
2. If it exists, read it and continue that work.
3. If it does not exist, continue from the visible current task context if possible.
4. If neither `RESUME.md` nor visible context is enough to continue, ask the user for the missing context.

## When to Create or Update `RESUME.md`

Create or update project-root `RESUME.md` whenever the current task cannot be fully completed in the current step.

This includes:

- the user says `pause`, `stop`, `resume later`, or similar;
- work must stop because of context, time, usage, or tool limits;
- a required dependency, credential, tool, environment, or user answer is missing;
- a multi-step task is only partially complete;
- files were changed but not verified;
- verification failed and the cause is not fully fixed;
- there are known remaining steps required to complete the user's active request.

Do not create `RESUME.md` for unrelated nice-to-have improvements, speculative cleanup, or optional future ideas.

## Required `RESUME.md` Format

Use this structure:

```markdown
# Resume Work

## Status

Briefly explain why work was interrupted and what state the project is currently in.

## Original Task

Restate the user's request in concrete terms.

## Completed

- List completed work.
- Mention files changed.
- Mention commands run.
- Mention important decisions made.

## Remaining Work

- List exact next steps.
- Be specific enough that another agent can continue immediately.

## Files and Locations

- List relevant files, folders, branches, issues, PRs, scripts, commands, or documentation.

## Verification

- List checks already run.
- List checks still required.
- Include failures and current hypotheses if something failed.

## Notes for Next Agent

- Include assumptions.
- Include risks.
- Include anything that is easy to miss.
```

## Writing Rules

Write `RESUME.md` plainly and operationally.

The file must not depend on:

- hidden reasoning;
- previous private context;
- unreferenced chat history;
- vague phrases like "continue what I was doing";
- unexplained file paths;
- unexplained tool output.

Prefer exact paths, commands, filenames, issue numbers, branch names, and observed error messages.

## Removal Rule

Remove `RESUME.md` once its contents are no longer needed.

Before removing it, make sure one of these is true:

- the unfinished work was completed;
- the user explicitly cancelled or replaced the unfinished work;
- the remaining items were moved into a durable tracker such as an issue, TODO file, or project board.

Never leave a stale `RESUME.md` in the repository after the interruption has been resolved.

## Git Commit Rule

`RESUME.md` is a temporary scratch file for resuming interrupted work in the near future. It is not a durable project-planning file, not a backlog, and not a file that should normally become part of the code base.

Do not include `RESUME.md` in git commits unless the user explicitly asks for it to be committed. Do not offer to add `RESUME.md` to a commit. If a task needs durable tracking, move the relevant information into an issue, `TODO.md`, `PROJECT.md`, or another appropriate project-tracking location, then remove `RESUME.md`.

## Registration Rule

When this skill is being installed, updated, or audited as part of repository instruction setup, verify that `AGENTS.md` mentions the `RESUME.md` protocol.

If `AGENTS.md` exists and does not mention `RESUME.md`, add a short paragraph that makes the resume protocol visible to agents that do not automatically load skills.

Use an idempotent edit: do not add duplicate paragraphs if an equivalent rule already exists.

Recommended paragraph:

> Before starting repository work, agents must check for project-root `RESUME.md`. If it exists, they must read it, resolve or explicitly abandon the unfinished work, and remove `RESUME.md` before starting unrelated work. When available, follow `skills/20-repository-workflows/resume-interrupted-work/SKILL.md` for the full protocol.

Also verify that `.gitignore` ignores `RESUME.md`. If `.gitignore` exists and does not already ignore `RESUME.md`, add this rule:

```gitignore
# Temporary agent resume scratch file
RESUME.md
```

Use an idempotent edit: do not add the rule if `RESUME.md` is already ignored by an exact entry or an equivalent pattern.

Do not modify `AGENTS.md` or `.gitignore` during unrelated feature work, bug fixes, content edits, or maintenance tasks unless the user explicitly asked to update repository instructions.
