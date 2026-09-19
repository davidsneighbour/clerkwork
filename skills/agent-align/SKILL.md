---
id: agent-align
name: agent-align
title: Clerkwork agent alignment
type: skill
description: Create or update repository agent instruction files only when the user asks to onboard Clerkwork, asks for agent alignment, or explicitly names agent-align. Always ask for confirmation before changing files.
---

Use this skill only when the user asks to onboard Clerkwork in any form, asks for agent alignment, or explicitly asks for `agent-align`.

Do not use this skill for general repository setup, documentation cleanup, agent work, issue work, dependency maintenance, audits, or any other adjacent task.

## Required confirmation

Before inspecting or changing repository instruction files for this task, ask the user to confirm that they want to run agent alignment.

Use a direct question such as:

```text
Do you want me to run agent alignment for this repository now?
```

Stop until the user confirms.

## Supported agent baseline

Assume the user runs current releases of the supported coding agents.

For the current supported setup:

* Claude Code v2.1.277 or later reads `AGENTS.md` natively when no project `CLAUDE.md` is present.
* Codex reads `AGENTS.md` natively.
* `AGENTS.md` is therefore the sole repository-level instruction entry point required for the supported Claude and Codex setup.
* Do not create `CLAUDE.md` as a compatibility adapter.

If a repository already contains `CLAUDE.md`, do not preserve it merely for Claude compatibility. Use `agent-instructions-audit` to classify any unique content, migrate useful instructions to the canonical hierarchy, and remove the obsolete file.

Do not assume support details for additional agents. Verify their current instruction-discovery behaviour before adding any agent-specific adapter or configuration.

## Scope boundaries

This skill may create or update only:

* `AGENTS.md`;
* files below `.agents/instructions/`;
* files below `.agents/references/`.

It must not perform any other task.

Do not edit unrelated documentation, source code, project tracking, package files, lockfiles, CI configuration, editor configuration, or generated files.

Ask the user for explicit permission before:

* overwriting an existing file;
* deleting or replacing meaningful instructions;
* changing files outside the allowed scope;
* committing changes;
* pushing changes;
* doing work that differs from the rules in this skill or the repository's established instructions.

## Target structure

Use this hierarchy:

```text
AGENTS.md
.agents/
├── instructions/
│   ├── TOPIC.instructions.md
│   └── ...
└── references/
    ├── TOPIC.md
    └── ...
```

Use `.agents/instructions/` only for automatically applicable behavioural rules whose applicability can be determined from file paths. Every instruction file MUST define a non-global `applyTo` scope.

Use `.agents/references/` for specialised knowledge, procedures, framework notes, API guidance, or other task-triggered material that should be loaded only when the semantic nature of the task requires it. Reference files MUST NOT define `applyTo`.

Subdirectories below either directory are encouraged where they make ownership and discovery clearer. Do not create files or directories merely to satisfy this example.

## AGENTS.md: canonical source of truth

Create or maintain `AGENTS.md` as the canonical entry point for all repository agent instructions.

Rules:

* `AGENTS.md` is the single source of truth for shared agent behaviour.
* Keep `AGENTS.md` as small as practical because it is unconditional bootstrap context.
* Keep only genuinely universal behavioural rules in `AGENTS.md`.
* Move file-scoped behavioural rules into `.agents/instructions/` with a precise, non-global `applyTo`.
* Move task-specific specialised knowledge or procedures into `.agents/references/` and load them only when the task requires them.
* Preserve useful repository-specific instructions while reorganising them according to this model.
* Resolve duplicate or conflicting instructions rather than preserving competing versions.
* Do not silently discard meaningful existing instructions.

Scoped instruction files are part of the canonical instruction set and have the same authority as `AGENTS.md` whenever their `applyTo` scope matches. Reference files provide specialised context only when explicitly triggered.

## Existing repository handling

Inspect the repository before changing anything.

### AGENTS.md does not exist

1. Inspect repository documentation, configuration, and existing conventions.
2. If the current agent provides an appropriate repository-initialisation mechanism, use it only as input, not as authoritative output.
3. Create `AGENTS.md` as the canonical shared instruction entry point.
4. Extract path-scoped behavioural rules into `.agents/instructions/` where useful.
5. Extract task-triggered specialised knowledge into `.agents/references/` where useful.
6. Do not create `CLAUDE.md`.

Do not invent extensive repository policies that cannot be derived from repository evidence.

### AGENTS.md exists

1. Review and preserve its useful instructions.
2. Refactor complex conditional sections into scoped instructions or references where appropriate.
3. Resolve duplication and contradictions deliberately.
4. Do not create `CLAUDE.md`.

### CLAUDE.md exists

An existing project `CLAUDE.md` is legacy state for the supported current-Claude setup and can prevent Claude Code's default `AGENTS.md` fallback from being used.

Do not migrate or delete it inside `agent-align`. Report it and hand the cleanup to `agent-instructions-audit`, which must preserve any unique useful content before removal.

## Scoped instructions

Each file below `.agents/instructions/` MUST:

* have one clear responsibility;
* contain actionable behavioural instructions rather than background material;
* define an `applyTo` pattern narrower than the whole repository;
* avoid duplicating `AGENTS.md` or another instruction file;
* use the narrowest practical scope.

Instruction files MUST NOT use repository-wide patterns such as `*`, `**`, `**/*`, or equivalent effectively-global patterns.

## Task references

Each file below `.agents/references/` MUST:

* have one clear topic;
* contain no `applyTo` frontmatter;
* be loaded only when a task requires that specialised context;
* have a discoverable semantic trigger in `AGENTS.md` or, preferably, the narrowest relevant scoped instruction;
* avoid duplicating behavioural rules that belong in `AGENTS.md` or `.agents/instructions/`.

## Classification rule

Use this decision order:

1. If a concise rule matters for essentially every task, keep it in `AGENTS.md`.
2. If applicability can be determined from the files being worked on, put it in a scoped instruction with non-global `applyTo`.
3. If applicability depends on the semantic kind of work, put it in a task-triggered reference.
4. If the material is a reusable multi-step workflow, consider a skill instead.
5. If the material is background documentation with no agent-specific behavioural purpose, keep it in ordinary repository documentation.

## Repository evidence

Before restructuring instructions, inspect relevant repository files such as:

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

Prefer explicit repository conventions over assumptions.

## Partnership with agent instruction audit

`agent-align` owns structural alignment of the canonical `AGENTS.md` hierarchy and its scoped instructions/references.

`agent-instructions-audit` owns context-efficiency analysis and legacy-instruction cleanup, including migration and removal of obsolete `CLAUDE.md` files.

When alignment is structurally wrong, repair it here. When the structure is bloated, duplicated, poorly scoped, or contains legacy agent-specific instruction files, use `agent-instructions-audit`.

## Commit handling

Do not commit automatically.

After the instruction structure has been created or migrated, ask the user for permission before committing the resulting changes.

## Validation

Before finishing, verify that:

* `AGENTS.md` exists;
* `AGENTS.md` is the canonical repository instruction entry point;
* no new `CLAUDE.md` was created;
* every file below `.agents/instructions/` has a precise non-global `applyTo`;
* no instruction uses `*`, `**`, `**/*`, or an equivalent repository-wide scope;
* task-triggered specialised material lives below `.agents/references/` without `applyTo`;
* instruction and reference triggers are discoverable;
* references point to files that actually exist;
* no meaningful instructions were accidentally lost;
* no contradictory duplicate policies remain.

Finally, report which files were created or modified, which instructions were moved, and any conflicts or ambiguities that remain.
