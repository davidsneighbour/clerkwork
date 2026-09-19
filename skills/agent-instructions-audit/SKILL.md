---
id: agent-instructions-audit
name: agent-instructions-audit
title: Clerkwork agent instructions audit
type: skill
description: Audit repository agent instructions for bootstrap cost, scope quality, duplication, and correct separation between AGENTS.md, scoped instructions, task references, skills, and documentation. Audit is non-mutating by default; optimise only when explicitly requested.
argument-hint: "<audit|optimise> [target]"
---

Use this skill when the user asks to audit, review, reduce, optimise, restructure, or analyse the cost or architecture of repository agent instructions.

The primary goal is not merely shorter prose. The goal is to minimise unconditional agent context while preserving reliable discovery of specialised instructions.

## Relationship with agent alignment

`AGENTS.md` is the canonical agent-independent entry point.

`agent-align` owns structural alignment of `AGENTS.md`, agent-specific compatibility adapters such as `CLAUDE.md`, and the expected instruction/reference directory structure.

This skill owns context-efficiency analysis and optimisation after or alongside that alignment.

If the repository is missing `AGENTS.md`, uses duplicated agent-specific instruction corpora, or otherwise needs canonical entry-point repair, report that condition and use `agent-align` for the structural repair. Do not duplicate its compatibility-adapter logic here.

## Modes

### Audit

Audit is the default and MUST NOT modify repository files.

Inspect the instruction architecture, classify material, estimate context cost, and report concrete recommendations.

### Optimise

Optimise mode may modify agent instruction files only when the user explicitly asks to optimise, restructure, fix, or apply the audit recommendations.

Before editing, preserve the behavioural intent of existing instructions. Do not silently discard meaningful rules.

Optimisation may edit:

* `AGENTS.md`;
* files below `.agents/instructions/`;
* files below `.agents/references/`;
* narrow pointers in ordinary documentation when required to keep moved material discoverable.

Do not edit agent-specific compatibility adapters such as `CLAUDE.md` unless the task is explicitly handed to `agent-align`.

## Target architecture

Use three instruction layers.

### Bootstrap: `AGENTS.md`

`AGENTS.md` is unconditional context and therefore the most expensive layer.

Keep it as small as practical. It should contain only:

* genuinely universal behavioural rules;
* essential repository-wide workflow or safety constraints;
* the minimal explanation needed to discover scoped instructions and task references;
* narrow semantic triggers that cannot live in a more specific scoped instruction.

Do not keep architecture manuals, command catalogues, framework documentation, API notes, deployment internals, or specialised procedures in bootstrap context merely because they may occasionally be useful.

### Scoped instructions: `.agents/instructions/`

Scoped instruction files contain behavioural rules that apply automatically because the files being worked on match their scope.

Every instruction file MUST have an `applyTo` pattern that is narrower than the entire repository.

The following and equivalent repository-wide scopes are prohibited:

```yaml
applyTo: "*"
applyTo: "**"
applyTo: "**/*"
```

Also flag effectively-global scopes that technically avoid those exact forms but cover most working files.

Use the narrowest practical `applyTo` pattern. A rule for Astro components should not match all TypeScript, Markdown, and CSS merely because those files can be related to components.

### Task references: `.agents/references/`

Reference files contain specialised knowledge or procedures whose applicability depends on the semantic task rather than simply the path of the file being edited.

Reference files MUST NOT have `applyTo`.

Examples include:

* Tinykeys or another library's usage conventions;
* keyboard-shortcut implementation guidance;
* deployment internals;
* image-pipeline architecture;
* external API usage notes;
* specialised maintenance procedures.

A reference MUST have a discoverable task trigger. Prefer placing that trigger in the narrowest relevant scoped instruction. Put it in `AGENTS.md` only when no narrower instruction can reliably expose it.

Example:

```markdown
When modifying keyboard shortcuts or key bindings, read `.agents/references/development/tinykeys.md`.
```

## Classification

Classify each substantial instruction block or file as one of:

* `bootstrap`: a concise rule needed for essentially every task;
* `scope`: behavioural instruction whose applicability follows from file path or type;
* `task`: semantic trigger for specialised task knowledge;
* `reference`: specialised knowledge or procedure loaded only when required;
* `skill`: reusable multi-step workflow better implemented as a skill;
* `duplicate`: behaviour already defined elsewhere;
* `obsolete`: instruction no longer supported by the repository.

Ordinary project documentation is not an agent-instruction classification. If material is explanatory background rather than agent behaviour or task-specific operational knowledge, recommend moving it to normal repository documentation.

## Audit procedure

1. Read `AGENTS.md` completely.
2. Inspect known agent-specific adapters only enough to determine whether they are thin adapters or duplicated instruction corpora. Delegate structural repair to `agent-align`.
3. Inventory `.agents/instructions/` and `.agents/references/` when present.
4. Parse each instruction file's `applyTo` frontmatter.
5. Identify global, missing, malformed, redundant, overlapping, and suspiciously broad scopes.
6. Identify reference files with `applyTo`; this is invalid.
7. Identify scoped instructions that primarily contain documentation or specialised reference material.
8. Identify bootstrap sections that are conditional, procedural, duplicated, or primarily documentation.
9. Trace reference triggers and report orphaned references or triggers that unnecessarily live in `AGENTS.md`.
10. Check for duplicated or contradictory rules across the instruction hierarchy.
11. Estimate unconditional context cost and representative task-specific context cost.
12. Recommend moves, scope changes, deletions, or consolidation without changing files in audit mode.

## Context-cost estimates

Report byte counts when available and provide approximate token counts.

Token estimates are estimates, not billing measurements. Prefer a clearly stated approximation such as bytes divided by four when no tokenizer is available.

At minimum report:

* `AGENTS.md` size and estimated tokens;
* other effectively unconditional instruction material;
* total scoped instruction size;
* total reference size;
* estimated bootstrap cost before optimisation;
* estimated bootstrap cost after the proposed optimisation;
* one or more representative task scenarios when useful.

Do not claim that a reference is free after it is loaded. The optimisation target is to keep irrelevant material out of context until needed.

## Findings and severity

Use:

* `ERROR` for invalid architecture, including repository-wide `applyTo`, `applyTo` on references, or contradictory mandatory rules;
* `WARN` for effectively-global scopes, major duplication, misplaced large material, missing task triggers, or substantial bootstrap bloat;
* `INFO` for smaller opportunities and maintainability improvements.

For every finding, include the affected file or section, classification, reason, and recommended destination or fix.

## Optimisation rules

When optimising:

1. Preserve behaviour before reducing wording.
2. Move universal concise rules to `AGENTS.md`.
3. Move automatically file-scoped behaviour to `.agents/instructions/` with precise `applyTo`.
4. Move semantically triggered specialised knowledge to `.agents/references/` without `applyTo`.
5. Move reusable multi-step workflows to skills when appropriate.
6. Move explanatory background to ordinary documentation.
7. Remove duplicate wording only after confirming the authoritative copy remains discoverable.
8. Prefer a scoped instruction as the trigger for a related reference instead of adding every reference to `AGENTS.md`.
9. Do not create a global instruction file as a workaround for keeping `AGENTS.md` small.
10. Re-run the audit after changes and compare before/after bootstrap estimates.

## Expected audit report

Use a compact report with:

1. architecture summary;
2. context-cost summary;
3. errors;
4. warnings;
5. classification/move recommendations;
6. estimated post-optimisation bootstrap size;
7. any structural alignment work that should be delegated to `agent-align`.

Prefer actionable findings over generic prose.

A useful context summary resembles:

```text
Bootstrap
  AGENTS.md                     ~1,900 tokens
  effectively unconditional      ~600 tokens

Conditional
  scoped instructions total    ~4,200 tokens
  references total             ~8,600 tokens

Representative task
  Astro component              ~3,100 tokens

Target bootstrap              ~1,400 tokens
```

## Validation

In audit mode, validate conclusions against the actual repository files and do not mutate them.

In optimise mode, verify that:

* `AGENTS.md` remains the canonical entry point;
* universal behaviour has not been lost;
* every instruction has a non-global `applyTo`;
* no instruction scope is `*`, `**`, `**/*`, or equivalent;
* every reference has no `applyTo`;
* every required reference has a discoverable semantic trigger;
* moved files are referenced correctly;
* no new duplicate or contradictory rule was introduced;
* bootstrap context is smaller or there is a documented reason why it cannot be reduced.
