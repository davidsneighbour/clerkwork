# Repository Guidelines

AGENTS.md is the single source of truth for repository instructions. Tool- or
assistant-specific files may add narrow overrides, but shared workflow,
structure, security, and editing rules belong here.

## Project Structure & Module Organization

Clerkwork is a collection of standalone AI skills reflecting Patrick's
engineering knowledge: dependency maintenance, GitHub issue triage, project
tracking, and repository upkeep. There is no app, build output, or central
test suite; the repository product is the Markdown and scripts under
`skills/`. Each `skills/<skill-name>/` directory is independently loadable and
uses `SKILL.md` as its entrypoint. Supporting files belong inside the owning
skill directory, commonly in `references/`, `scripts/`, or `agents/`.

## Skill Map

* `foreman`: single router skill. Interprets short command-style requests
  (`foreman audit packages`, `foreman issues next`) or plain-language
  requests, asks a clarifying question when the area or action is missing,
  and hands off to the matching skill below without doing the work itself.
* `clerkwork-dependency-maintenance`: safely maintain npm dependencies in a
  single-package repository or npm monorepo.
* `clerkwork-github-label-classifier`: analyse GitHub issue text and select or
  apply labels from Patrick's category:value label taxonomy.
* `clerkwork-manage-node-version-policy`: audit and update Node.js and npm version
  declarations across a repository against actively supported releases.
* `clerkwork-osv-scan`: scan dependencies for known vulnerabilities with
  osv-scanner, auto-apply safe fixes, and file issues for the rest.
* `clerkwork-project-state-report`: report what changed in a repository since a
  given time, including GitHub PR and issue activity.
* `clerkwork-project-task-triage`: sync the local TODO.md scratch pad with GitHub
  Issues and regenerate the local PROJECT.md dashboard.
* `clerkwork-resume-interrupted-work`: manage a project-root RESUME.md handoff file
  that blocks new work until previously interrupted work is resolved.
* `clerkwork-select-next-issue`: select one suitable open GitHub issue by priority
  and roadmap relevance, without implementing it.
* `clerkwork-work-on-issue`: inspect a specific GitHub issue, implement the
  required change, validate, and commit with a closing reference.
* `clerkwork-work-on-next-issue`: orchestrate selecting and implementing the next
  suitable open GitHub issue.
* `clerkwork-work-through-issues`: continuously work through open GitHub issues
  until no suitable actionable issues remain, committing each fix
  individually.

## Build, Test, and Development Commands

There is no root build step. Run helper scripts directly from the repository
root once a skill defines one, for example:

```bash
node skills/<skill-name>/scripts/some-script.ts --help
```

TypeScript resource scripts are run with `node <path>.ts`; do not assume
compiled JavaScript, `tsx`, or a build step exists.

Repository-wide checks run from `package.json`:

```bash
npm run check         # biome, typecheck, validate:skills, test, markdown, spelling
npm run validate:skills
npm run lint:markdown
npm run lint:spelling
```

## Coding Style & Naming Conventions

Use plain Markdown for skill documentation. Keep `SKILL.md` frontmatter
specific and actionable, especially `id`, `name`, `title`, and `description`.
Skill directories use lowercase hyphenated names such as
`clerkwork-dependency-maintenance`; resource scripts use action-oriented names.
Prefer ASCII punctuation unless quoting existing text.

## Testing Guidelines

No coverage threshold is defined. Validate changed scripts with targeted
`--help`, dry-run, or non-writing modes before handoff. When a skill's
behaviour changes, update its `SKILL.md` in the same change.

## Commit & Pull Request Guidelines

Always work on `main`. Do not create branches unless the user explicitly asks
for a feature branch.

Every commit must refer to a GitHub issue. If no fitting issue exists, or the
work did not start from an issue, create one before committing. Apply fitting
GitHub labels for type, priority, status, and affected area, using existing
repository labels. Close issues only through `closes #123` in commit messages;
do not close issues manually.

When reporting, reviewing, or documenting repository work, link references to
commits, pull requests, and issues whenever they are mentioned. If the
referenced object is not available locally yet but will have a stable GitHub
URL after the repository state is pushed, use that URL form anyway.

Use conventional changelog subjects for all commits:
`type(optional-scope): imperative summary`. For skill changes, use
`feat(<skill-name>): ...` for new or changed capabilities and
`fix(<skill-name>): ...` for corrections. Write verbose commit bodies that
explain what changed, why it changed, validation performed, and the issue
reference. Commit when the change is complete. If open questions remain or the
change is not done, do not commit; explain what remains and offer to commit
once resolved. Push when stopping work if one or more commits were added.

Pull requests should explain the affected skill, list validation performed,
and link the related issue or task. Include screenshots only for asset or
README visual changes.

## Agent Workflow

Before starting repository work, agents must check for project-root
`RESUME.md`. If it exists, read it first, resolve or explicitly abandon the
unfinished work, and remove `RESUME.md` before starting unrelated work.

Keep edits scoped to the requested skill or document. Preserve existing user
changes in this dirty worktree unless the user explicitly asks to include,
replace, or remove them.
