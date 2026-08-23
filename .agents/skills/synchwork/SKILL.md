---
name: synchwork
description: Synchronize shared maintenance state across the local project set defined in .agents/skills/synchwork/config.json.
---

# Synchwork

Use this skill when asked to synchronize, compare, or maintain shared project
state across the local repositories defined in
`.agents/skills/synchwork/config.json`. This covers full checklist runs (see
[Checklist](#checklist)) and ad hoc syncs of a single file or folder from the
current repository to the rest of the project set (see
[Ad Hoc Path Sync](#ad-hoc-path-sync)).

## Project Set

The project set lives in `.agents/skills/synchwork/config.json`, under the
`repositories` key, as a list of local paths (`~` denotes the home
directory). Read this file at the start of every run to determine which
repositories are in scope — do not hardcode or assume the project set.

Keep the project set exactly as configured. Do not infer additional
repositories beyond what `config.json` lists, and do not drop a repository
from it just because it is currently empty or mid-bootstrap; report it as
not-yet-ready instead of removing it. If the user wants a repository added or
removed, update `config.json` and confirm the change with the user rather
than editing this file.

Each repository's slug is the basename of its path in `repositories` (for
example, `~/github.com/davidsneighbour/clerkwork` has the slug `clerkwork`).
Checklist items that reference a repository by slug — such as Social Poster
Image and Package Scripts below — mean this basename.

## Operating Rules

- Treat every repository in the project set as a separate working tree.
- Start every run by reading `config.json`, then checking each repository's
  `AGENTS.md` and project-root `RESUME.md` if present.
- Preserve unrelated dirty worktree changes in every repository.
- Touch only the files needed for the requested synchronization task.
- Do not commit, push, publish, or run mutating external commands unless the
  user explicitly asks for that action.
- Report skipped steps, blockers, and pre-existing unrelated dirty files.

## Step-Based Workflow

1. Confirm the project set.
   - Read `.agents/skills/synchwork/config.json` and expand `~` in each path.
   - Verify that every configured path exists.
   - Verify `scripts` and `repositories` agree: every slug used in `scripts`
     has a matching `repositories` entry, and every `repositories` entry has
     a corresponding `synchwork:<slug>` tuple in `scripts`. Report any
     mismatch and ask before proceeding with a task that depends on the
     mismatched side.
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

Synchronize `.vscode/dictionary.txt` across every repository in the project
set.

1. Read each repository's `.vscode/dictionary.txt`.
2. Merge all entries into one wordlist.
3. Remove blank lines and exact duplicates.
4. Preserve distinct case variants when they exist.
5. Sort case-insensitively, with a stable case-sensitive tie-breaker for case
   variants.
6. Write the exact same newline-terminated wordlist back to each repository's
   `.vscode/dictionary.txt`.
7. Verify that every dictionary file in the project set has an identical
   hash.
8. Run `git diff --check -- .vscode/dictionary.txt` in each repository.
9. Report the final word count and dictionary hash for each repository.

### Skill Names

Ensure no skill folder under `skills/` has the same name across the project
set.

1. List direct child directories under each repository's `skills/` directory.
2. Compare directory basenames across the full project set.
3. Report any duplicate names with the repositories where they appear.
4. If duplicates exist, do not rename anything unless the user explicitly asks
   for a rename plan or implementation.
5. If no duplicates exist, report that the skill namespace is clear.

### Social Poster Image

Synchronize each repository's social poster image,
`.github/assets/images/SKILLNAME.png` (`SKILLNAME` is that repository's own
project name, matching its folder name as configured in `config.json`), plus
its `-thumb` variant and any generated size variants, to every other
repository in the project set.

1. Locate the current poster image, thumb image, and size-variant assets for
   each repository under `.github/assets/images/`.
2. Copy each repository's own poster set into the corresponding location in
   every other repository in the project set, without altering the source
   repository's own image files.
3. Verify that each repository now holds every project's poster images with
   matching byte content (compare hashes), for every project that has
   published a poster set so far.
4. Report which images were copied, skipped as already identical, or
   flagged because a source image was missing.

### VS Code Settings

Synchronize shared options in `.vscode/settings.json` across the project set,
without touching per-repository theming.

1. Read each repository's `.vscode/settings.json`.
2. Treat `workbench.colorCustomizations` and `peacock.color` as
   repository-specific theming settings; never modify, remove, or
   synchronize these two keys.
3. Compare all remaining keys across the project set.
4. Where values differ, stop and ask which value is authoritative before
   applying it, unless the user has already specified the intended value.
5. Apply the agreed common values to every repository, preserving each
   repository's `workbench.colorCustomizations` and `peacock.color`
   untouched.
6. Verify that all keys other than the two excluded theming keys are
   identical across the project set.
7. Report which keys were synchronized, which were left as
   repository-specific theming, and any conflicts that required a decision.

### `synchwork` Package Scripts

Derive each `synchwork:<slug>` script from the `scripts` array in
`.agents/skills/synchwork/config.json` rather than from any fixed list in
this file. Each entry in that array is a `[slug, [member1, member2, member3]]`
tuple: `slug` names the script (`synchwork:<slug>`), and the three members
are the ordered `meld` arguments, each resolved to its full path via the
`repositories` list in the same file.

This task only adds or overwrites the `synchwork:<slug>` keys it derives. It
must never remove, reorder, or otherwise touch any other script already
defined in a repository's `package.json`.

1. Read the `scripts` array and the `repositories` list from `config.json`.
2. For each `[slug, [a, b, c]]` tuple, resolve `a`, `b`, and `c` against
   `repositories` and build the entry:
   `"synchwork:<slug>": "meld <path-of-a> <path-of-b> <path-of-c>"`.
3. Read the existing `scripts` block in each repository's `package.json`.
4. Merge the derived entries into that block: add any `synchwork:<slug>` key
   that is missing, and overwrite a `synchwork:<slug>` key only when its
   value differs from the derived one. Leave every other key in `scripts`
   untouched, including any script whose name does not match
   `synchwork:<slug>` for a slug in `config.json`.
5. Preserve the existing key order and formatting conventions of each
   `package.json`; append genuinely new `synchwork:<slug>` entries in the
   order their tuples appear in `config.json`.
6. After editing, confirm each modified `package.json` still parses (for
   example, `jq . package.json` or `node -e "require('./package.json')"`)
   before moving to the next repository.
7. Report, per repository, which `synchwork:<slug>` scripts were added,
   corrected, or already present and correct, and confirm no unrelated
   script was modified.

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
heading, byte-for-byte identical in content across the project set.

1. Read each repository's `README.md`.
2. Compare top-level heading structure across the project set and report
   structural drift (missing, reordered, or renamed sections), without
   rewriting unrelated prose unless the user asks for that.
3. Extract the `## The cabinet of @davidsneighbour's skills` section from
   each `README.md`, from its heading up to the next top-level heading or end
   of file.
4. Merge into one canonical version of that section, including an entry for
   every repository that has a poster image ready, and write the identical
   result back into every repository's `README.md`.
5. Verify the extracted section is byte-for-byte identical across the
   project set.
6. Report structural differences found outside the shared section, and
   confirm the shared section now matches.

### `synchwork` Skill Definition

Keep this skill's own definition, `.agents/skills/synchwork/`, identical
across the project set.

1. Read `.agents/skills/synchwork/SKILL.md` (and any supporting files in that
   directory, including `config.json`) from each repository.
2. Compare content across the project set.
3. If they differ, ask which version is authoritative unless the user has
   already indicated the source of truth, then write the identical content
   back to the other repositories.
4. Verify every copy is byte-for-byte identical, including confirming each
   `config.json` still parses (for example, `jq . config.json`) after being
   written.
5. Report which repositories were updated.

## Ad Hoc Path Sync

Use this mode when the user asks to sync one specific file or folder from the
current repository to the rest of the project set, rather than running the
full checklist. Recognize it from an invocation of the form `sync <path>`
(for example, `/synchwork sync .agents/skills/synchwork` or
`/synchwork sync .vscode/dictionary.txt`) or an equivalent natural-language
request such as "sync `<path>` from here to the other projects" or "push
`<path>` to everyone else." `<path>` is a single file or folder, relative to
a repository root.

This mode touches only the given path in the source and target repositories.
It does not run the full [Checklist](#checklist) and is not a substitute for
it.

### Resolving Source and Targets

1. Determine the source repository: the entry in `repositories` whose path
   contains the current working directory. If none matches, or the match is
   ambiguous, stop and ask which repository is the source.
2. Determine the target repositories: every other entry in `repositories`.
3. Resolve `<path>` against the source repository's root. If it does not
   exist there, stop and report that there is nothing to sync.

### Procedure

1. Read the source's copy of `<path>` — file contents, or the full file tree
   if it is a folder.
2. For each target repository, resolve the same relative path.
   - If `<path>` does not yet exist in the target, it will be created; no
     permission is needed.
   - If it exists and its content differs from the source, run
     `git status --short -- <path>` in the target first. If the target
     already has uncommitted changes touching `<path>`, stop and ask for
     permission before overwriting it — never overwrite dirty target content
     silently.
3. Once clear to proceed (clean target, or the user has given permission),
   copy the source's content over:
   - For a file: overwrite the target file with the source file.
   - For a folder: copy every file from the source tree into the
     corresponding location in the target tree, creating missing
     directories and overwriting files that exist at the same relative
     path. Do not delete a file that exists only in the target and not in
     the source — this is a merge, not a mirror — unless the user
     explicitly asks for mirroring instead.
4. Verify each updated target path matches the source byte-for-byte (per
   file, when `<path>` is a folder).
5. Report, per target repository, what was created, overwritten, skipped as
   already identical, or held back pending permission.

## Completion Standard

A synchwork run is complete when every requested checklist item has either
passed with concrete evidence or has a clearly reported blocker. The final
report should make it obvious which repository changed, which checks passed,
and which dirty worktree entries were already present before the run.
