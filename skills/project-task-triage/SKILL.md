---
id: project-task-triage
name: project-task-triage
title: Clerkwork Project Task Triage
description: "Maintains the repository task-tracking system by syncing the local TODO.md scratch pad with GitHub Issues and regenerating the local PROJECT.md dashboard. Use when asked to check project status, update task tracking, sync todos with GitHub, regenerate the project dashboard, or recommend next steps. Triggers on: 'check status', 'project status', 'sync todos', 'update project', 'update roadmap', 'triage tasks', 'what's next', 'next steps'."
---

Use this procedure when asked to check the status of a repository, update project tracking, sync TODO items with GitHub Issues, regenerate the project dashboard, or recommend next steps.

## Purpose

Maintain the repository task-tracking system while avoiding project-management-only commits.

This repository uses three tracking layers:

1. **GitHub Issues** are the source of truth.

   - Every actual task, bug, improvement, tracked decision, or follow-up that needs action belongs in the GitHub issue tracker.
   - Issues must include enough context, explanation, references, expected outcome, dependencies, and acceptance criteria to be actionable.
   - Issues may contain clarification questions when requirements are incomplete.
   - Once something is represented by a GitHub issue, it must not remain as a duplicate task in `/TODO.md`.

2. **`/PROJECT.md`** is the local generated project dashboard.

   - It is a quick local cache of the current GitHub issue state.
   - It must list every relevant open GitHub issue.
   - It must never list a closed issue as an entry, regardless of why it was closed or how recently.
   - It only points forward. It is not a progress log, changelog, or record of what was already done, so a closed issue never earns a place in it, not even as a "done" or struck-through entry.
   - If a closed issue is a subtask of an open parent issue, do not list the closed subtask on its own. Instead, summarise progress on the parent's entry, for example "3 of 5 subtasks closed", and let the parent issue's own subtask list (in GitHub) carry the detail.
   - It may group issues by topic, priority, type, phase, or recommended execution order.
   - It should include short notes explaining the purpose, risk, dependency, or expected impact of each issue.
   - It should include a short project-state summary at the top.
   - It should include useful project health indicators where available, such as test coverage, failing checks, build status, lint status, documentation gaps, dependency status, or other measurable project-specific signals.
   - It may include a recommended next-steps section.
   - It must not be treated as the source of truth.
   - It is local working state and must not be committed.
   - Do not copy full issue bodies into `/PROJECT.md`; detailed explanations belong in GitHub Issues.
   - Do not use `/PROJECT.md` as a substitute for permanent project documentation.

3. **`/TODO.md`** is the local scratchpad and inbox.

   - It is used for rough notes, ideas, quick reminders, and unprocessed task candidates.
   - It may be handwritten, incomplete, duplicated, badly formatted, or partially obsolete.
   - It is not a task-tracking system.
   - Anything already represented by a GitHub issue must not remain in `/TODO.md`.
   - Only unclear, non-actionable, or intentionally unprocessed notes should remain in `/TODO.md`.
   - It is local working state and must not be committed.

## Permanent information

Before removing, replacing, or regenerating local project-management content, check whether it contains information that must be preserved permanently.

Move durable information to the appropriate tracked location:

- architectural decisions into architecture or decision documentation
- implementation requirements into GitHub Issues or specifications
- repository procedures into `AGENTS.md` or repository instructions
- user-facing completed changes into release notes or changelogs
- operational knowledge into the relevant documentation
- unresolved actionable work into GitHub Issues

Do not leave durable project knowledge only in `/PROJECT.md` or `/TODO.md`.

## Local file setup

`/PROJECT.md` and `/TODO.md` must be excluded from version control.

Ensure the root `.gitignore` contains these exact patterns:

```gitignore
# Local project-management working files
/PROJECT.md
/TODO.md
```

Do not add duplicate entries when equivalent root-level patterns already exist.

Do not use either of these commands to hide tracked modifications:

```bash
git update-index --skip-worktree PROJECT.md
git update-index --assume-unchanged PROJECT.md
```

These flags create hidden local index state and are not an acceptable replacement for proper ignore rules.

### Existing repository migration

An older version of this skill used `/ROADMAP.md` instead of `/PROJECT.md` to present the current state of the project. If `/ROADMAP.md` exists:

1. Preserve its current local content.
2. Rename it to `/PROJECT.md`.
3. Replace all repository workflow references from `ROADMAP.md` to `PROJECT.md`.
4. Add `/PROJECT.md` and `/TODO.md` to `.gitignore`.
5. Remove the files from the Git index without deleting the local copies.
6. Do not remove durable information before moving it to the appropriate tracked location.

For tracked files, use the equivalent of:

```bash
git rm --cached --ignore-unmatch ROADMAP.md PROJECT.md TODO.md
```

After the index removal, ensure the local content remains available as `/PROJECT.md` and `/TODO.md`.

The migration may require one repository configuration commit containing only appropriate tracked changes, such as:

- `.gitignore`
- skill or instruction references
- tracked documentation explaining the local workflow

DO NOT commit `/PROJECT.md` or `/TODO.md` as part of the migration.

## Procedure

1. Prepare the local tracking files.

   - Check whether `/ROADMAP.md` exists.
   - If `/ROADMAP.md` exists and `/PROJECT.md` does not, migrate its local content to `/PROJECT.md`.
   - If both files exist, compare them before changing either file and preserve unique useful information.
   - Ensure `/PROJECT.md` and `/TODO.md` are ignored.
   - Ensure neither file remains tracked by Git.
   - Create empty local files only when they are needed and do not already exist.
   - NEVER commit `/PROJECT.md` or `/TODO.md` to the index.

2. Read the current tracking state.

   - Read `/TODO.md`.
   - Read `/PROJECT.md`.
   - Fetch current GitHub Issues for the repository.
   - Include open issues.
   - Include recently closed issues only when needed to reconcile stale project or TODO entries.
   - Treat GitHub Issues as authoritative whenever `/PROJECT.md` or `/TODO.md` disagrees with the issue tracker.

3. Reconcile GitHub Issues with `/PROJECT.md`.

   - Ensure every relevant open GitHub issue is listed in `/PROJECT.md`.
   - Remove closed, completed, duplicate, or obsolete issues from `/PROJECT.md`. This applies unconditionally, including issues closed during this same run.
   - If an issue appears in `/PROJECT.md` but no longer exists or is closed, remove it from `/PROJECT.md`.
   - If an issue is open in GitHub but missing from `/PROJECT.md`, add it.
   - If a closed issue is a subtask of an open parent, do not re-add it to `/PROJECT.md`; instead update the parent's entry to reflect subtask progress (for example "3 of 5 subtasks closed").
   - If work is clearly complete but the GitHub issue is still open, close the issue with a short explanation.
   - Do not close issues when completion is uncertain. Add a note or clarification question instead.
   - Other skills may edit `/PROJECT.md` between triage runs and check off a task's checkbox (for example `- [x] ...`) instead of removing the entry. Treat any checked-off entry found in `/PROJECT.md` as done: remove that entry entirely on this run, and if it corresponds to an open GitHub issue whose work is clearly complete, close that issue with a short explanation. Never leave a checked-off entry in the regenerated file, and never render one as a struck-through or "completed" line either — the same forward-only rule applies regardless of which tool checked the box.

4. Reconcile `/TODO.md` with GitHub Issues.

   - Review every item in `/TODO.md`.
   - Remove every TODO item that is already covered by an existing GitHub issue.
   - Do not keep duplicate task descriptions in `/TODO.md` once they exist in GitHub.
   - If a TODO item is related to an existing issue, add useful missing context to that issue instead of creating a duplicate issue.
   - If a TODO item is too unclear to convert into an issue, leave it in `/TODO.md` and mark what clarification is needed.
   - If a TODO item is only a note, idea, or reminder and is not ready for tracking, keep it in `/TODO.md`.

5. Process new TODO items.

   - Split rough notes into individual actionable items.

   - Create one GitHub issue per new actionable item.

   - Do not combine unrelated tasks into one issue.

   - Do not create issues for vague notes unless there is enough context to make the issue useful.

   - Each new issue must include:

      - context
      - problem or goal
      - expected outcome
      - relevant references
      - acceptance criteria
      - known dependencies
      - clarification questions where requirements are unclear

   - Do not guess missing requirements.

   - Add clarification questions to the issue when the issue is otherwise useful and actionable.

   - Leave the item in `/TODO.md` instead when too little information exists to create a useful issue.

6. Update existing GitHub Issues where useful.

   - Add missing context from `/TODO.md` or `/PROJECT.md`.
   - Add references to relevant files, commands, failing checks, previous decisions, or related issues.
   - Add clarification questions when the issue cannot be implemented safely from the available information.
   - Avoid noisy updates.
   - Only update an issue when the added information improves actionability.

7. Collect project health indicators.

   - Use existing project scripts where available.

   - Prefer lightweight checks over expensive full audits unless explicitly requested.

   - Useful indicators may include:

     - test status
     - coverage current versus threshold
     - lint status
     - typecheck status
     - build status
     - CI status
     - dependency status
     - documentation gaps

   - Do not invent measurements.

   - If a measurement cannot be collected, omit it or clearly mark it as unavailable.

8. Regenerate `/PROJECT.md`.

   - Rebuild `/PROJECT.md` from the current GitHub issue state, using only open issues. Closed issues never appear as entries, even the ones just closed in this run, and even as a "recently completed" or "done" section — `/PROJECT.md` points forward only, it does not track progress.

   - Start with a short project-state summary.

   - Group open issues into useful sections, such as bugs, fixes, refactoring, performance, documentation, new features, maintenance, or follow-up work.

   - For each issue, include:

     - issue number
     - issue title
     - issue link
     - short notes explaining why it matters, what is blocked, what needs attention, or what the likely implementation path is
     - if the issue has closed subtasks, a short progress note (for example "3 of 5 subtasks closed") instead of listing those closed subtasks separately

   - Add dependency notes where one issue should happen before another.

   - Add a suggested order of work.

   - Add a section for open clarification questions.

   - Add project health indicators where available and relevant.

   - Keep `/PROJECT.md` concise enough to scan quickly.

   - Keep detailed explanations in GitHub Issues, not in `/PROJECT.md`.

   - Do not stage or commit `/PROJECT.md`.

9. Clean `/TODO.md`.

   - Remove items converted into GitHub Issues.
   - Remove items already covered by existing GitHub Issues.
   - Remove duplicate or obsolete notes.
   - Keep only notes that are unclear, non-actionable, intentionally not ready for issue creation, or useful as scratch pad material.
   - Add short clarification markers for remaining unclear notes where helpful.
   - Do not stage or commit `/TODO.md`.

10. Verify Git state.

    - Confirm that `/PROJECT.md` and `/TODO.md` are ignored.
    - Confirm that neither file is tracked.
    - Confirm that neither file is staged.
    - Do not create a commit whose only purpose is updating local project-management state.
    - Do not include these files in implementation commits, release commits, pull requests, or automated staging operations.
    - If tracked configuration or documentation was changed during a one-time migration, report those changes separately and commit them only when explicitly requested or when the surrounding workflow already authorises commits.

11. Report the result.

    - List issues closed.
    - List issues created.
    - List existing issues updated.
    - List items removed from `/TODO.md` because they are now tracked in GitHub.
    - List duplicates skipped.
    - List TODO items left behind and why.
    - List project health indicators added or updated in `/PROJECT.md`.
    - Report whether `/PROJECT.md` and `/TODO.md` are correctly ignored and untracked.
    - Report any durable information moved into tracked documentation.
    - End with the same recommended next steps that were written into `/PROJECT.md`.

## Boundaries

The routine may update:

- GitHub Issues
- local `/PROJECT.md`
- local `/TODO.md`

During initial setup or migration, it may also update:

- `.gitignore`
- repository instructions that refer to `PROJECT.md`
- tracked documentation describing the project-management workflow

Do not implement source-code changes unless explicitly asked.

Do not delete human notes from `/TODO.md` unless they are obsolete, duplicated, represented by a GitHub issue, or preserved in a more appropriate tracked location.

Do not close GitHub Issues unless completion is clear from the repository state, issue discussion, or existing project files.

Do not list a closed issue as an entry in `/PROJECT.md`, including closed subtasks of an open parent issue; summarise closed subtasks as a progress note on the parent instead. This also applies to entries any other skill left checked off (`- [x]`) in `/PROJECT.md` — remove them on the next triage run rather than keeping or re-checking them. `/PROJECT.md` reflects what is next, not what was done.

Never stage or commit `/PROJECT.md` or `/TODO.md`.

Never create project-management-only commits for regenerated local tracking state.

Never use hidden Git index flags such as `skip-worktree` or `assume-unchanged` to manage these files.

Do not allow durable decisions, requirements, or operational knowledge to exist only in ignored local files.
