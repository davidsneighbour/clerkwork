---
id: agent-instructions-audit
name: agent-instructions-audit
title: Clerkwork agent instructions audit
type: skill
description: Audit repository agent instructions for bootstrap cost, scope quality, duplication, legacy CLAUDE.md content, and correct separation between AGENTS.md, scoped instructions, task references, skills, and documentation. Audit is non-mutating by default; optimise only when explicitly requested.
argument-hint: "<audit|optimise> [target]"
---

Use this skill when the user asks to audit, review, reduce, optimise, restructure, or analyse the cost or architecture of repository agent instructions.

The primary goal is not merely shorter prose. The goal is to minimise unconditional agent context while preserving reliable discovery of specialised instructions.

## Relationship with agent alignment

`AGENTS.md` is the canonical repository instruction entry point for the supported current Claude Code and Codex setup.

`agent-align` owns structural alignment of `AGENTS.md`, `.agents/instructions/`, and `.agents/references/`.

This skill owns context-efficiency analysis, duplication removal, and migration of obsolete agent-specific repository instruction files such as `CLAUDE.md`.

## Modes

### Audit

Audit is the default and MUST NOT modify repository files.

Inspect the instruction architecture, classify material, estimate context cost, and report concrete recommendations.

If `CLAUDE.md` exists, read it completely and report:

* whether it contains only obsolete adapter/import boilerplate;
* which content duplicates `AGENTS.md` or another instruction source;
* which unique content remains useful;
* where each useful unique instruction should move;
* whether the file can be removed after migration.

Treat a project `CLAUDE.md` as an `ERROR` in the target architecture because current Claude Code's default AGENTS.md support is used when no project CLAUDE.md is present.

### Optimise

Optimise mode may modify agent instruction files only when the user explicitly asks to optimise, restructure, fix, migrate, or apply the audit recommendations.

Optimisation may edit:

* `AGENTS.md`;
* `CLAUDE.md` when present;
* files below `.agents/instructions/`;
* files below `.agents/references/`;
* narrow pointers in ordinary documentation when required to keep moved material discoverable.

Optimisation may delete `CLAUDE.md` only after all useful unique content has been preserved elsewhere in the canonical hierarchy.

Do not keep a minimal `CLAUDE.md` adapter for the supported current-Claude setup.

## Target architecture

Use three instruction layers.

### Bootstrap: AGENTS.md

`AGENTS.md` is unconditional context and therefore the most expensive layer.

Keep it as small as practical. It should contain only:

* genuinely universal behavioural rules;
* essential repository-wide workflow or safety constraints;
* the minimal explanation needed to discover scoped instructions and task references;
* narrow semantic triggers that cannot live in a more specific scoped instruction.

### Scoped instructions: .agents/instructions/

Scoped instruction files contain behavioural rules that apply automatically because the files being worked on match their scope.

Every instruction file MUST have an `applyTo` pattern narrower than the entire repository.

The following and equivalent repository-wide scopes are prohibited:

```yaml
applyTo: "*"
applyTo: "**"
applyTo: "**/*"
```

Also flag effectively-global scopes that technically avoid those exact forms but cover most working files.

### Task references: .agents/references/

Reference files contain specialised knowledge or procedures whose applicability depends on the semantic task rather than simply the path of the file being edited.

Reference files MUST NOT have `applyTo`.

A reference MUST have a discoverable task trigger. Prefer placing that trigger in the narrowest relevant scoped instruction. Put it in `AGENTS.md` only when no narrower instruction can reliably expose it.

## CLAUDE.md migration

For the supported latest-Claude setup, `CLAUDE.md` is legacy repository state.

When it exists:

1. Read `CLAUDE.md` and `AGENTS.md` completely before making any migration decision.
2. Classify every meaningful `CLAUDE.md` instruction as:
   * duplicate;
   * obsolete compatibility boilerplate;
   * universal bootstrap;
   * file-scoped behavioural rule;
   * task-triggered reference material;
   * reusable skill/workflow;
   * ordinary documentation.
3. Remove duplicate and obsolete adapter/import boilerplate.
4. Move useful universal instructions into `AGENTS.md`.
5. Move file-scoped behavioural rules into `.agents/instructions/` with precise non-global `applyTo`.
6. Move semantic task knowledge into `.agents/references/` without `applyTo`.
7. Move reusable multi-step workflows to skills where appropriate.
8. Preserve genuinely useful Claude-originated guidance as ordinary canonical instructions rather than keeping a Claude-specific repository file.
9. Verify that all unique useful content now exists elsewhere.
10. Delete `CLAUDE.md`.

Never delete `CLAUDE.md` merely because it exists. Preserve intent first, then remove the obsolete file.

Also flag project-level variants such as `.claude/CLAUDE.md` or `CLAUDE.local.md` when they contain repository instructions that would mask or compete with the canonical `AGENTS.md` setup.

## Classification

Classify each substantial instruction block or file as one of:

* `bootstrap`: concise rule needed for essentially every task;
* `scope`: behavioural instruction whose applicability follows from file path or type;
* `task`: semantic trigger for specialised task knowledge;
* `reference`: specialised knowledge or procedure loaded only when required;
* `skill`: reusable multi-step workflow better implemented as a skill;
* `duplicate`: behaviour already defined elsewhere;
* `obsolete`: instruction or compatibility mechanism no longer needed.

Ordinary project documentation is not an agent-instruction classification.

## Audit procedure

1. Read `AGENTS.md` completely.
2. Check for `CLAUDE.md`, `.claude/CLAUDE.md`, and `CLAUDE.local.md`.
3. If any exist, read them completely and classify their contents using the migration rules above.
4. Inventory `.agents/instructions/` and `.agents/references/` when present.
5. Parse each instruction file's `applyTo` frontmatter.
6. Identify global, missing, malformed, redundant, overlapping, and suspiciously broad scopes.
7. Identify reference files with `applyTo`; this is invalid.
8. Identify scoped instructions that primarily contain documentation or specialised reference material.
9. Identify bootstrap sections that are conditional, procedural, duplicated, or primarily documentation.
10. Trace reference triggers and report orphaned references or triggers that unnecessarily live in `AGENTS.md`.
11. Check for duplicated or contradictory rules across the instruction hierarchy.
12. Estimate unconditional context cost and representative task-specific context cost.
13. Recommend moves, scope changes, deletions, or consolidation without changing files in audit mode.

## Context-cost estimates

Report byte counts when available and provide approximate token counts.

Token estimates are estimates, not billing measurements. Prefer bytes divided by four when no tokenizer is available.

At minimum report:

* `AGENTS.md` size and estimated tokens;
* any legacy project instruction file size, including `CLAUDE.md`;
* other effectively unconditional instruction material;
* total scoped instruction size;
* total reference size;
* estimated bootstrap cost before optimisation;
* estimated bootstrap cost after the proposed optimisation.

## Findings and severity

Use:

* `ERROR` for invalid architecture, including a legacy project `CLAUDE.md` in the supported current-Claude setup, repository-wide `applyTo`, `applyTo` on references, or contradictory mandatory rules;
* `WARN` for effectively-global scopes, major duplication, misplaced large material, missing task triggers, or substantial bootstrap bloat;
* `INFO` for smaller opportunities and maintainability improvements.

For every finding, include the affected file or section, classification, reason, and recommended destination or fix.

## Optimisation rules

When optimising:

1. Preserve behaviour before reducing wording.
2. Migrate useful `CLAUDE.md` content before deleting the file.
3. Move universal concise rules to `AGENTS.md`.
4. Move automatically file-scoped behaviour to `.agents/instructions/` with precise `applyTo`.
5. Move semantically triggered specialised knowledge to `.agents/references/` without `applyTo`.
6. Move reusable multi-step workflows to skills when appropriate.
7. Move explanatory background to ordinary documentation.
8. Remove duplicate wording only after confirming the authoritative copy remains discoverable.
9. Prefer a scoped instruction as the trigger for a related reference instead of adding every reference to `AGENTS.md`.
10. Do not create a global instruction file as a workaround for keeping `AGENTS.md` small.
11. Remove `CLAUDE.md` once migration is complete.
12. Re-run the audit after changes and compare before/after bootstrap estimates.

## Expected audit report

Use a compact report with:

1. architecture summary;
2. context-cost summary;
3. errors;
4. warnings;
5. CLAUDE.md migration status when applicable;
6. classification/move recommendations;
7. estimated post-optimisation bootstrap size;
8. any structural alignment work that should be delegated to `agent-align`.

## Validation

In audit mode, validate conclusions against the actual repository files and do not mutate them.

In optimise mode, verify that:

* `AGENTS.md` remains the canonical entry point;
* no project `CLAUDE.md` remains after successful migration;
* no useful unique `CLAUDE.md` content was lost;
* universal behaviour has not been lost;
* every instruction has a non-global `applyTo`;
* no instruction scope is `*`, `**`, `**/*`, or equivalent;
* every reference has no `applyTo`;
* every required reference has a discoverable semantic trigger;
* moved files are referenced correctly;
* no new duplicate or contradictory rule was introduced;
* bootstrap context is smaller or there is a documented reason why it cannot be reduced.
