# DNBHQ TypeScript configuration maintenance

Maintain the repository's TypeScript configuration using the current supported DNBHQ shared package or packages.

During the initial repository audit, detect TypeScript config inheritance, shared-config dependencies, predecessor packages, project references, framework variants, typecheck scripts, build integration, path aliases, includes, excludes, and generated output.

## Authoritative sources

Read the relevant package repository README, release notes, migration documents, npm metadata, and installed package documentation before editing.

Current package documentation controls:

- package names
- exported `tsconfig` paths
- supported TypeScript and Node.js versions
- framework-specific variants
- required compiler options
- migration instructions

Use only config exports documented by the current package. Do not invent config names, and do not extend the package root unless package metadata proves that the installed version intends that form.

## Audit

Inspect:

- `tsconfig.json`
- referenced and extended TypeScript configs
- package-level or workspace configs
- `typescript` and shared-config dependencies
- predecessor DNBHQ and davidsneighbour packages
- framework configs
- build, typecheck, test, and editor integrations
- include, exclude, files, references, and path aliases
- generated declarations and build output

Classify the setup as missing, partial, current, outdated, legacy, duplicated, mixed, invalid, or migration-incomplete.

## Maintenance rules

- If no config is explicitly selected, use `@dnbhq/tsconfig/cli`.
- If the repository is an Astro project, use `@dnbhq/tsconfig/astro`.
- If the user explicitly requests a different supported config, follow that instruction.
- Ask only when repository evidence and user instructions leave the intended project shape unclear.
- Preserve project-specific includes, excludes, references, paths, and framework requirements.
- Keep project-specific compiler options on top of the selected preset rather than moving them into the shared package.
- Remove inherited compiler options only when behaviour remains equivalent.
- Do not copy an entire shared config locally.
- Do not change module systems, output structure, strictness, or emit behaviour without evidence from package migration instructions.
- Do not upgrade TypeScript beyond package and framework compatibility.
- Validate project references and workspace inheritance.

## Config selection

Known package variants are:

| Project shape | Preferred config |
| --- | --- |
| Generic or unknown npm/Node tooling | `@dnbhq/tsconfig/cli` |
| Node CLI, Node scripts, or repository tooling | `@dnbhq/tsconfig/cli` |
| Astro project | `@dnbhq/tsconfig/astro` |
| Explicit strict-only request | `@dnbhq/tsconfig/strict` |
| Mixed Astro and Node tooling | Astro config for the Astro/app config; separate CLI config for Node tooling when needed |
| Existing multi-config project | Preserve the multi-config structure and extend the matching shared config in each file |

Both `cli` and `astro` are based on the strict preset. Use repository agent instructions and package README.md guidance as part of the decision flow.

## Local settings

After selecting the preset, preserve existing local settings that are still required, including:

- `include`, `exclude`, `files`, and `references`
- `compilerOptions.baseUrl` and `compilerOptions.paths`
- emit-related settings such as `outDir`, declaration output, source maps, and build info files
- framework and test-runner settings
- generated type paths

Install `@types/node` only when Node globals, `node:*` imports, scripts, tests, or config files need Node types. Do not add Node types only because TypeScript is present.

Before removing TypeScript-related packages or config files, confirm no scripts, configs, workflows, editor settings, or local tooling still reference them.

## Validation

Run the safest available typecheck or configuration validation commands.

Separate:

- invalid configuration
- package incompatibility
- existing type errors
- unrelated build failures

## Final response

Report starting state, documentation consulted, dependency changes, config inheritance, preserved overrides, migrated legacy packages, validation, and unresolved issues.
