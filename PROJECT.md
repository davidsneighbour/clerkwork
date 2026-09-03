# Project dashboard

*Generated local dashboard. GitHub Issues are the source of truth.*

## State summary

Triage refreshed on 2026-09-03 from the live GitHub issue list. The repository
is on `main` at `016fa969b20b`, with four open issues and no recently closed
issues. `PROJECT.md` and `TODO.md` are normally local working files; this
snapshot is being committed by explicit maintainer request in #4.

There is active work in the tree:

* `.gitignore` now ignores `/PROJECT.md` and `/TODO.md`.
* The `clerkwork-agent-align` skill was committed locally in `016fa969b20b`,
  but #3 remains open until that commit is pushed.
* `skills/foreman/SKILL.md` has an unstaged `argument-hint` change that is
  outside this triage snapshot.
* `skills/clerkwork-shared-configurations/`, `skills/dnb-behaviour-spec/`, and
  `skills/dnb-quality-gate-organisation/` remain untracked draft skill
  directories.

## Project health

* Issue tracker: 4 open issues, 0 closed issues in the latest closed-issue
  query.
* Local tracking files: `/PROJECT.md` and `/TODO.md` are ignored by
  `.gitignore`, and will be force-added only for this explicit snapshot commit.
* Full validation: `npm run check` fails at Biome formatting for
  `.vscode/settings.json`; this is tracked by #1. Because the command stops
  there, typecheck, skill validation, tests, Markdown lint, and spelling did
  not run in that full check.
* Direct skill validation from the previous focused check still reports
  missing `agents/openai.yaml` metadata for existing committed skills, plus
  manifest gaps for the untracked DNB draft skills. The committed-skill
  metadata gap is tracked by #2.

## Open issues

### Bugs

* [ ] [#1 Fix repository check formatting failure](https://github.com/davidsneighbour/clerkwork/issues/1)
  * `npm run check` still fails on `.vscode/settings.json` formatting, so the
    issue remains open and unchecked.
* [ ] [#2 Add missing agents/openai.yaml to existing skills](https://github.com/davidsneighbour/clerkwork/issues/2)
  * Existing committed skills still lack required OpenAI metadata. This blocks
    `npm run validate:skills` once #1 no longer stops the full check first.
* [ ] [#3 Add Clerkwork agent alignment skill](https://github.com/davidsneighbour/clerkwork/issues/3)
  * Fix committed locally in `016fa969b20b`; remains open until pushed.
* [-] [#4 Commit project triage snapshot](https://github.com/davidsneighbour/clerkwork/issues/4)
  * This dashboard snapshot and `TODO.md` are being prepared for the requested
    issue-linked commit.

## Suggested order of work

1. Resolve and commit #1 so `npm run check` can proceed past Biome.
2. Work #2 by adding `agents/openai.yaml` to the existing committed skills.
3. Push the local `clerkwork-agent-align` commit when ready, so #3 can close.
4. Complete this explicit triage snapshot commit for #4.
5. Before committing the untracked draft skill directories, add required
   metadata, update manifests, and run focused Markdown and skill validation.
6. Add new actionable work directly as GitHub Issues before implementation.

## Open clarification questions

None.
