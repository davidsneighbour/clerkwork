---
id: clerkwork-agent-align
name: clerkwork-agent-align
title: Clerkwork agent alignment
type: skill
description: Create or update repository agent instruction files only when the user asks to onboard Clerkwork, asks for agent alignment, or explicitly names agent-align. Always ask for confirmation before changing files.
---

Use this skill only when the user asks to onboard Clerkwork in any form, asks
for agent alignment, or explicitly asks for `agent-align`.

Do not use this skill for general repository setup, documentation cleanup,
agent work, issue work, dependency maintenance, audits, or any other adjacent
task.

## Required confirmation

Before inspecting or changing repository instruction files for this task, ask
the user to confirm that they want to run agent alignment.

Use a direct question such as:

```text
Do you want me to run agent alignment for this repository now?
```

Stop until the user confirms.

If the user confirms, continue with the scope and workflow below. If the user
does not confirm, do not run alignment.

## Scope boundaries

This skill may create or update only:

* `AGENTS.md`
* `CLAUDE.md`
* files below `.agents/instructions/`

It must not perform any other task.

Do not edit unrelated documentation, source code, project tracking, package
files, lockfiles, CI configuration, editor configuration, or generated files.

Ask the user for explicit permission before:

* overwriting an existing file;
* deleting or replacing meaningful instructions;
* changing files outside the allowed scope;
* committing changes;
* pushing changes;
* doing work that differs from the rules in this skill or the repository's
  established instructions.

## Onboard repository agent instructions

Onboard this repository to my standard agent-instruction structure.

The goal is to establish one canonical, agent-independent source of truth while keeping agent-specific files minimal and avoiding duplicated instructions.

## Target structure

Use this hierarchy:

```text
AGENTS.md
CLAUDE.md
.agents/
└── instructions/
    ├── TOPIC.md
    └── ...
```

Subdirectories below `.agents/instructions/` are encouraged where they make the instruction structure clearer, for example:

```text
.agents/instructions/
├── development/
│   ├── testing.md
│   └── dependencies.md
├── repository/
│   ├── commits.md
│   └── issues.md
└── documentation/
    └── style.md
```

Do not create files or directories merely to satisfy this example. Structure them according to the actual repository instructions.

## `AGENTS.md`: canonical source of truth

Create or maintain `AGENTS.md` as the canonical entry point for all agent-related instructions in the repository.

Put all instructions that apply generally to AI agents in `AGENTS.md` or in instruction files referenced by it.

Rules:

* `AGENTS.md` is the single source of truth for shared agent behaviour.
* Instructions that apply to Claude, Codex, or other agents equally MUST NOT be duplicated into agent-specific files.
* Keep `AGENTS.md` concise enough to serve as an effective entry point.
* Move complex, specialised, or lengthy instruction sets into dedicated files below `.agents/instructions/`.
* `AGENTS.md` MUST explicitly tell agents which additional instruction files they need to read and under what circumstances.
* Preserve existing useful repository-specific instructions while reorganising them according to this model.
* Resolve duplicate or conflicting instructions rather than preserving multiple competing versions.
* Do not silently discard meaningful existing instructions.

When extracting instructions, prefer topic-oriented files over arbitrary splits.

For example:

```markdown
## Repository workflow

Follow `.agents/instructions/repository/workflow.md` for repository, branch, commit, and push behaviour.
```

Instruction files referenced by `AGENTS.md` are part of the canonical instruction set and MUST be treated with the same authority as instructions written directly in `AGENTS.md`.

## `CLAUDE.md`: claude-specific delta only

Create or maintain `CLAUDE.md`, but put only instructions in it that are specifically required for Claude and differ from, supplement, or adapt the canonical instructions because of Claude-specific behaviour or capabilities.

At the beginning of `CLAUDE.md`, include a prominent instruction equivalent to:

```markdown
# Claude instructions

Before doing any work in this repository, you MUST read `AGENTS.md` and follow all instructions defined there and in the instruction files it references. `AGENTS.md` is the canonical single source of truth for agent behaviour in this repository.

This file contains only Claude-specific additions or deviations. Nothing in this file replaces a shared instruction from `AGENTS.md` unless the difference is explicitly required for Claude.
```

Rules for `CLAUDE.md`:

* Do NOT duplicate instructions already contained in `AGENTS.md` or its referenced instruction files.
* Do NOT use `CLAUDE.md` as a second general-purpose instruction file.
* Only add instructions that are genuinely Claude-specific.
* If there are no Claude-specific instructions beyond the requirement to load `AGENTS.md`, keep `CLAUDE.md` correspondingly minimal.
* If existing `CLAUDE.md` content is actually agent-independent, migrate it to `AGENTS.md` or an appropriate `.agents/instructions/` file.

## Existing repository handling

Inspect the repository before changing anything.

### Neither file exists

If neither `AGENTS.md` nor `CLAUDE.md` exists:

1. If the current agent provides an `/init` command or equivalent repository-initialisation mechanism, use it where appropriate to gather or initialise repository instructions.
2. Review the generated result rather than accepting it blindly.
3. Reorganise the resulting instructions according to the structure in this prompt.
4. Create `AGENTS.md` as the canonical shared instruction entry point.
5. Create the minimal `CLAUDE.md` described above.
6. Extract complex instructions into `.agents/instructions/` where useful.

Do not invent extensive repository policies that cannot be derived from the repository, its documentation, configuration, or existing conventions.

### Only `AGENTS.md` exists

If `AGENTS.md` exists but `CLAUDE.md` does not:

1. Review and preserve the existing `AGENTS.md` instructions.
2. Refactor complex sections into `.agents/instructions/` where appropriate.
3. Create a minimal `CLAUDE.md`.
4. Do not copy the contents of `AGENTS.md` into `CLAUDE.md`.

### Only `CLAUDE.md` exists

If `CLAUDE.md` exists but `AGENTS.md` does not:

1. Review all existing `CLAUDE.md` instructions.
2. Separate shared instructions from genuinely Claude-specific instructions.
3. Move shared instructions into the new `AGENTS.md` or `.agents/instructions/`.
4. Leave only Claude-specific differences in `CLAUDE.md`.
5. Add the mandatory `AGENTS.md` loading instruction at the beginning of `CLAUDE.md`.
6. Preserve the intent of existing instructions during the migration.

### Both files exist

If both `AGENTS.md` and `CLAUDE.md` exist:

1. Read both completely before editing either.
2. Identify duplicate, overlapping, conflicting, shared, and Claude-specific instructions.
3. Consolidate all shared instructions into `AGENTS.md` or `.agents/instructions/`.
4. Reduce `CLAUDE.md` to Claude-specific additions or deviations only.
5. Ensure `CLAUDE.md` begins by requiring Claude to read and follow `AGENTS.md`.
6. Resolve contradictions deliberately, using repository evidence and the existing instruction intent.
7. Do not leave duplicated policies in both files.

## Modular instruction files

Use `.agents/instructions/$TOPIC.md` for instructions that are too substantial or specialised to belong directly in `AGENTS.md`.

A deeper directory structure is preferred when several related topics exist.

Good candidates include:

* repository workflow;
* branching, commits, and pushing;
* issue handling;
* dependency management;
* testing and quality gates;
* coding conventions;
* documentation conventions;
* release procedures;
* security requirements;
* framework-specific development rules;
* deployment;
* content or editorial rules.

Each extracted file should:

* have one clear responsibility;
* contain actionable instructions rather than background material;
* avoid duplicating instructions from other files;
* be referenced from `AGENTS.md`;
* explain when it applies if it is conditional.

Do not hide critical baseline instructions several levels deep without making their applicability clear from `AGENTS.md`.

## Repository evidence

Before restructuring the instructions, inspect relevant repository files to understand existing conventions. Depending on the repository, this may include:

```text
README.md
CONTRIBUTING.md
PROJECT.md
ROADMAP.md
package.json
pyproject.toml
Cargo.toml
Makefile
justfile
.github/
.vscode/
.ai/
docs/
```

Also inspect existing agent, editor, AI-assistant, contribution, testing, and repository-workflow instructions.

Prefer explicit repository conventions over assumptions.

## Migration requirements

During onboarding:

* preserve useful existing instructions;
* remove unnecessary duplication;
* consolidate shared behaviour;
* separate Claude-specific behaviour cleanly;
* extract complex topics where this improves maintainability;
* update references when files are moved;
* avoid creating dead or unreferenced instruction files;
* avoid changing unrelated repository content;
* retain existing terminology where it is deliberate and useful.

If an existing instruction conflicts with this organisational model, preserve the behavioural requirement while moving it to the correct location.

## Commit handling

Do not commit automatically.

After the instruction structure has been created or migrated, ask the user for
permission before committing the resulting changes.

The commit should include only the files changed as part of this onboarding task.

Rules:

* If the repository already defines commit-message conventions in `AGENTS.md`, `.agents/instructions/`, `CONTRIBUTING.md`, or another repository policy, follow those conventions.
* If the repository uses Conventional Commits, prefer a `docs(ai): ...` commit type/scope for this work.
* The agent may choose an appropriate commit message based on the actual changes.
* If no more specific message is warranted, use:

```text
docs(ai): onboard agent files
```

* If the task primarily migrates or restructures existing instructions rather than introducing them for the first time, a more precise message is preferable, for example:

```text
docs(ai): restructure agent instructions
```

* If both new files and migrated instructions are involved, choose the message that best describes the substantive change rather than mechanically listing every file operation.
* Do not include unrelated working-tree changes in the commit.
* Before committing, review the staged diff to confirm that only the intended onboarding changes are included.
* If the repository workflow requires commits to reference an issue, task, or ticket, include that reference according to the repository's existing rules.
* If commits are not permitted automatically by the current agent, prepare the changes and report the exact commit message that should be used instead.

## Validation

Before finishing, verify that:

* `AGENTS.md` exists;
* `CLAUDE.md` exists;
* `AGENTS.md` is the canonical source for shared agent instructions;
* `CLAUDE.md` explicitly requires Claude to read and follow `AGENTS.md` before doing work;
* `CLAUDE.md` contains no unnecessary copies of shared instructions;
* complex extracted instructions live below `.agents/instructions/`;
* every extracted instruction file that agents need is discoverable from `AGENTS.md`;
* references point to files that actually exist;
* no meaningful instructions were accidentally lost;
* no contradictory duplicate policies remain.

Finally, report:

1. which files were created;
2. which files were modified;
3. which instructions were moved and where;
4. which Claude-specific instructions remain in `CLAUDE.md`;
5. any conflicts or ambiguities you had to resolve.

## Agent instruction alignment

Use `agent-align` to ensure repository-level agent instruction files exist, are correctly configured, and follow the current Clerkwork rules.

### Canonical instruction source

`AGENTS.md` is the canonical, tool-agnostic source of repository instructions.

Do not maintain separate copies of the same instruction corpus for individual agents. Agent-specific files should only exist when an agent cannot consume `AGENTS.md` directly or requires additional configuration to do so.

The governing principle is:

> One instruction corpus, multiple compatibility adapters. `AGENTS.md` is authoritative; agent-specific files exist only to expose that corpus to tools that cannot consume it directly.

### Agent-specific files

Treat agent-specific instruction files as compatibility adapters, not independent instruction sources.

For each supported agent, classify its integration as one of the following:

* **Native**: the agent reads `AGENTS.md` directly. No additional repository-level instruction file is required.
* **Configured**: the agent can consume `AGENTS.md`, but requires repository or tool configuration to enable or locate it.
* **Adapter**: the agent requires its own instruction file. Create the smallest possible adapter that delegates to `AGENTS.md`.
* **Unsupported or unknown**: do not guess. Leave the repository unchanged and report that support must be verified before an adapter is added.

Never duplicate the contents of `AGENTS.md` into another instruction file unless a tool has no viable mechanism for referencing or importing it.

### Claude

Claude Code requires `CLAUDE.md`, so maintain it as a thin compatibility adapter.

Prefer:

```markdown
@AGENTS.md
```

Add content directly to `CLAUDE.md` only when it is genuinely Claude-specific and cannot reasonably belong in `AGENTS.md`.

Do not copy the general repository instructions from `AGENTS.md` into `CLAUDE.md`.

### Codex

Codex consumes `AGENTS.md` directly.

No Codex-specific repository instruction file is required unless future Codex behaviour or project requirements introduce a separate configuration mechanism.

### Other agents

Do not assume that every coding agent supports `AGENTS.md`, even when that convention is commonly supported.

Maintain an explicit compatibility registry for agents that Clerkwork knows how to align. This registry should record, at minimum:

* agent identifier;
* integration mode: `native`, `configured`, or `adapter`;
* canonical source;
* adapter filename, when applicable;
* import or reference mechanism, when applicable;
* any agent-specific validation requirements.

Conceptually:

```yaml
agents:
  codex:
    mode: native
    source: AGENTS.md

  claude:
    mode: adapter
    source: AGENTS.md
    file: CLAUDE.md
    import: "@AGENTS.md"
```

Add Pi, OpenClaw-derived agents, other `*claw` tools, or future assistants only after their instruction-discovery behaviour has been verified.

Agent support is therefore a Clerkwork compatibility concern, not a reason to change the repository's canonical instruction architecture.

### Alignment behaviour

`agent-align` should handle both initialisation and maintenance.

When run, it should:

1. determine which supported agents are relevant to the repository or current environment;
2. verify that `AGENTS.md` exists;
3. verify that `AGENTS.md` follows the current Clerkwork structure and instruction-file rules;
4. inspect required agent-specific adapters or configuration;
5. create missing adapters where their requirements are known;
6. repair adapters that duplicate, contradict, or fail to reference the canonical instructions correctly;
7. preserve genuinely agent-specific instructions;
8. report unsupported or unverified agents rather than inventing integration rules.

### Missing files

If `AGENTS.md` is missing, initialise it according to the current Clerkwork rules.

If a required adapter such as `CLAUDE.md` is missing, create it.

If an agent does not require an adapter, do not create an agent-specific file merely for symmetry or future-proofing.

### Existing files

Existing instruction files must not automatically be overwritten.

Inspect their contents and distinguish between:

* shared repository instructions that belong in `AGENTS.md`;
* valid agent-specific instructions;
* duplicated instructions;
* obsolete compatibility boilerplate;
* contradictory instructions;
* unrelated user-maintained content.

Where safe, move shared instructions into `AGENTS.md` and reduce the agent-specific file to its compatibility role.

Do not silently discard unique instructions.

### Audit and mutation

The primary operation is **alignment**.

An optional non-mutating audit/check mode may inspect the same state without changing files.

Conceptually:

```text
agent-align
```

Align the repository with the current rules.

```text
agent-align --check
```

Inspect and report differences without modifying the repository.

The terminology should remain:

* **alignment**: the overall process;
* **initialisation**: creating missing canonical or adapter files;
* **audit/check**: non-mutating inspection;
* **realignment**: correcting an existing setup that has drifted from the expected state.

### Extensibility

Do not hard-code the architecture around Claude and Codex.

Claude and Codex are simply the currently used integrations.

Adding another agent should normally require updating Clerkwork's compatibility registry and validation rules, not introducing another independent repository instruction system.

The repository should continue to have one authoritative instruction hierarchy regardless of how many agents consume it.
