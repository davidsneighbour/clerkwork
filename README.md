![clerkwork and foreman](.github/assets/images/skillwerk/clerkwork.png)

## AI skills for software engineering workflows

Clerkwork is a collection of reusable AI skills reflecting Patrick's engineering knowledge: dependency maintenance, GitHub issue triage, project tracking, and repository upkeep. The goal is to keep the routine parts of maintaining a repository consistent and portable across projects and AI assistants.

> Clerkwork is the collection. Foreman is its interface. Skills describe jobs. Categories organise the collection.

* [AI skills for software engineering workflows](#ai-skills-for-software-engineering-workflows)
* [Install](#install)
* [Update](#update)
* [Skills](#skills)
* [The cabinet of @davidsneighbour's skills](#the-cabinet-of-davidsneighbours-skills)

## Install

Install the current Clerkwork skill set with:

```bash
npx skills add davidsneighbour/clerkwork --yes
```

## Update

Re-run the install command to refresh an existing install:

```bash
npx skills add davidsneighbour/clerkwork --yes
```

Use `--global` when the skills should be available outside the current project.

## Skills

Use `/foreman overview` when you do not remember a skill name. Foreman lists the complete collection by category and can narrow it with requests such as `/foreman git`, `/foreman project`, or route concrete jobs such as `/foreman audit packages`.

Skill names are intentionally flat. Categories organise the collection without becoming part of the invocation name, so individual skills remain independently installable and portable.

### Agent management

* `agent-align` creates or repairs the repository agent entry-point setup.
* `agent-instructions-audit` audits and optimises agent instruction architecture and context cost.

### Repository maintenance

* `dependency-maintenance` safely maintains npm dependencies in a single-package repository or npm monorepo.
* `manage-node-version-policy` audits and updates Node.js and npm version declarations against actively supported releases.
* `osv-scan` scans dependencies for known vulnerabilities, auto-applies safe fixes, and files issues for the rest.

### Project management

* `project-state-report` reports what changed in a repository since a given time, including GitHub PR and issue activity.
* `project-task-triage` syncs the local TODO.md scratch pad with GitHub Issues and regenerates the local PROJECT.md dashboard.
* `resume-interrupted-work` manages a project-root RESUME.md handoff file that blocks new work until interrupted work is resolved.

### Git and GitHub

* `github-label-classifier` analyses GitHub issue text and selects or applies labels from Patrick's category:value label taxonomy.
* `select-next-issue` selects one suitable open GitHub issue by priority and roadmap relevance, without implementing it.
* `work-on-issue` inspects a specific GitHub issue, implements the required change, validates, and commits with a closing reference.
* `work-on-next-issue` orchestrates selecting and implementing the next suitable open GitHub issue.
* `work-through-issues` continuously works through open GitHub issues until no suitable actionable issues remain.

## The cabinet of @davidsneighbour's skills

| Exhibit | Skill |
| :---: | :--- |
| [![Apparatus](.github/assets/images/skillwerk/apparatus-thumb.png)](https://github.com/davidsneighbour/apparatus) | **[Apparatus](https://github.com/davidsneighbour/apparatus):** A collection of practical, tool-driven skills for operating browsers, diagnostics, media utilities, and other reusable technical machinery. |
| [![Clerkwork](.github/assets/images/skillwerk/thumb.png)](https://github.com/davidsneighbour/clerkwork) | **[Clerkwork](https://github.com/davidsneighbour/clerkwork):** It's an engineers world. Start your engines, maintain, contrive, and put in the works. |
| [![Gallimaufry](.github/assets/images/skillwerk/gallimaufry-thumb.png)](https://github.com/davidsneighbour/gallimaufry) | **[Gallimaufry](https://github.com/davidsneighbour/gallimaufry):** A miscellaneous collection of small AI skills and odd useful workflows. |
| [![Gazetteer](.github/assets/images/skillwerk/gazetteer-thumb.png)](https://github.com/davidsneighbour/gazetteer) | **[Gazetteer](https://github.com/davidsneighbour/gazetteer):** Place-aware patterns for geographic content, local context, and location-rich publishing. |
| [![Idiolect](.github/assets/images/skillwerk/idiolect-thumb.png)](https://github.com/davidsneighbour/idiolect) | **[Idiolect](https://github.com/davidsneighbour/idiolect):** Finding your own language in skill outputs. |
| [![Patternbook](.github/assets/images/skillwerk/patternbook-thumb.png)](https://github.com/davidsneighbour/patternbook) | **[Patternbook](https://github.com/davidsneighbour/patternbook):** Patterns for better digital work. |
| [![Posthaste](.github/assets/images/skillwerk/posthaste-thumb.png)](https://github.com/davidsneighbour/posthaste) | **[Posthaste](https://github.com/davidsneighbour/posthaste):** A collection of skills to post to social media of all kinds. |
