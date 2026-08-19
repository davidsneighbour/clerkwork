---
name: synchwork
description: Synchronize shared maintenance state across the local Posthaste, Clerkwork, and Idiolect projects.
---

# Synchwork

Use this skill when asked to synchronize, compare, or maintain shared project
state across these three local repositories:

```text
~/github.com/davidsneighbour/posthaste
~/github.com/davidsneighbour/clerkwork
~/github.com/davidsneighbour/idiolect
```

Keep these paths as the project set for now. Do not infer additional
repositories unless the user explicitly adds them.

## Operating Rules

- Treat the three repositories as separate working trees.
- Start every run by checking each repository's `AGENTS.md` and project-root
  `RESUME.md` if present.
- Preserve unrelated dirty worktree changes in every repository.
- Touch only the files needed for the requested synchronization task.
- Do not commit, push, publish, or run mutating external commands unless the
  user explicitly asks for that action.
- Report skipped steps, blockers, and pre-existing unrelated dirty files.

## Step-Based Workflow

1. Confirm the project set.
   - Verify that all three paths exist after expanding `~`.
   - Read each repository's local instructions before changing files.
   - Stop and ask if a repository is missing or a `RESUME.md` describes work
     that conflicts with the requested synchronization.

2. Inspect current state.
   - Run `git status --short` in each repository.
   - Identify existing user changes before editing.
   - Note which files the requested task is allowed to modify.

3. Run the synchronization checklist.
   - Complete each relevant task in [Checklist](#checklist).
   - Keep every task narrow: inspect, compute the intended common state, apply
     only that state, then verify it.
   - If a task would require editing outside its stated files, stop and report
     the reason before making that broader change.

4. Verify the result.
   - Re-run the task-specific checks.
   - Re-run `git status --short` in each repository and distinguish new edits
     from pre-existing dirty state.
   - Confirm that synchronized files are byte-for-byte identical when the task
     requires identical output.

5. Report the outcome.
   - List the task results by repository.
   - Include counts, hashes, duplicate names, or other concrete evidence from
     the checks.
   - Mention validation commands run and any commands that could not be run.

## Checklist

### CSpell Dictionaries

Synchronize `.vscode/dictionary.txt` across all three repositories.

1. Read each repository's `.vscode/dictionary.txt`.
2. Merge all entries into one wordlist.
3. Remove blank lines and exact duplicates.
4. Preserve distinct case variants when they exist.
5. Sort case-insensitively, with a stable case-sensitive tie-breaker for case
   variants.
6. Write the exact same newline-terminated wordlist back to each
   `.vscode/dictionary.txt`.
7. Verify that all three dictionary files have identical hashes.
8. Run `git diff --check -- .vscode/dictionary.txt` in each repository.
9. Report the final word count and dictionary hash for each repository.

### Skill Names

Ensure no skill folder under `skills/` has the same name across the three
repositories.

1. List direct child directories under each repository's `skills/` directory.
2. Compare directory basenames across the full project set.
3. Report any duplicate names with the repositories where they appear.
4. If duplicates exist, do not rename anything unless the user explicitly asks
   for a rename plan or implementation.
5. If no duplicates exist, report that the skill namespace is clear.

### Social Poster Image

Synchronize each repository's social poster image, `.github/assets/images/SKILLNAME.png`
(`SKILLNAME` is that repository's own project name: `posthaste`, `clerkwork`,
or `idiolect`), plus its `-thumb` variant and any generated size variants, to
the other two repositories.

1. Locate the current poster image, thumb image, and size-variant assets for
   each repository under `.github/assets/images/`.
2. Copy each repository's own poster set into the corresponding location in
   the other two repositories, without altering the source repository's own
   image files.
3. Verify that each repository now holds all three projects' poster images
   with matching byte content (compare hashes).
4. Report which images were copied, skipped as already identical, or
   flagged because a source image was missing.

### VS Code Settings

Synchronize shared options in `.vscode/settings.json` across all three
repositories, without touching per-repository theming.

1. Read each repository's `.vscode/settings.json`.
2. Treat `workbench.colorCustomizations` and `peacock.color` as
   repository-specific theming settings; never modify, remove, or
   synchronize these two keys.
3. Compare all remaining keys across the three files.
4. Where values differ, stop and ask which value is authoritative before
   applying it, unless the user has already specified the intended value.
5. Apply the agreed common values to all three files, preserving each
   repository's `workbench.colorCustomizations` and `peacock.color` untouched.
6. Verify that all keys other than the two excluded theming keys are
   identical across the three files.
7. Report which keys were synchronized, which were left as
   repository-specific theming, and any conflicts that required a decision.

### `synchwork` Package Script

Ensure `package.json` in each repository defines a `synchwork` script that
opens a three-way diff of the local project set:

```json
"synchwork": "meld ~/github.com/davidsneighbour/clerkwork ~/github.com/davidsneighbour/idiolect ~/github.com/davidsneighbour/posthaste"
```

1. Read the `scripts` block in each repository's `package.json`.
2. Add or correct the `synchwork` entry to match the command above exactly,
   in all three repositories.
3. Preserve the existing key order and formatting conventions of each
   `package.json`.
4. Report whether the script was added, corrected, or already present and
   correct in each repository.

### `skills.sh.json`

Keep `skills.sh.json` accurate in each repository.

1. Read each repository's `skills.sh.json` and its `skills/` directory
   listing.
2. Confirm every skill folder present in the repository is represented in a
   grouping, and that no grouping references a skill folder that no longer
   exists.
3. Report additions, removals, or grouping fixes needed per repository. Do
   not invent new groupings or reorder existing ones unless the user
   explicitly asks for that.
4. Apply only the corrections needed to keep the file accurate; leave
   unrelated structure untouched.

### README Structure and Shared Section

Keep each repository's `README.md` following the same overall structure, and
keep the `## The cabinet of @davidsneighbour's skills` section, including its
heading, byte-for-byte identical in content across all three repositories.

1. Read each repository's `README.md`.
2. Compare top-level heading structure across the three files and report
   structural drift (missing, reordered, or renamed sections), without
   rewriting unrelated prose unless the user asks for that.
3. Extract the `## The cabinet of @davidsneighbour's skills` section from
   each `README.md`, from its heading up to the next top-level heading or end
   of file.
4. Merge into one canonical version of that section and write the identical
   result back into all three `README.md` files.
5. Verify the extracted section is byte-for-byte identical across all three
   repositories.
6. Report structural differences found outside the shared section, and
   confirm the shared section now matches.

### `synchwork` Skill Definition

Keep this skill's own definition, `.agents/skills/synchwork/`, identical
across all three repositories.

1. Read `.agents/skills/synchwork/SKILL.md` (and any supporting files in that
   directory) from each repository.
2. Compare content across the three repositories.
3. If they differ, ask which version is authoritative unless the user has
   already indicated the source of truth, then write the identical content
   back to the other two repositories.
4. Verify all three copies are byte-for-byte identical.
5. Report which repositories were updated.

## Completion Standard

A synchwork run is complete when every requested checklist item has either
passed with concrete evidence or has a clearly reported blocker. The final
report should make it obvious which repository changed, which checks passed,
and which dirty worktree entries were already present before the run.
