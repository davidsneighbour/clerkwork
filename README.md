![clerkwork and foreman](.github/assets/images/skillwerk/clerkwork.png)

## AI skills for software engineering workflows

Clerkwork is a collection of reusable AI skills reflecting Patrick's engineering knowledge: dependency maintenance, GitHub issue triage, project tracking, and repository upkeep. The goal is to keep the routine parts of maintaining a repository consistent and portable across projects and AI assistants.

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

* `foreman` routes short command-style requests (`foreman audit packages`, `foreman issues next`) to the right skill below, asking a clarifying question when the area or action is missing.
* `clerkwork-dependency-maintenance` safely maintains npm dependencies in a single-package repository or npm monorepo.
* `clerkwork-github-label-classifier` analyses GitHub issue text and selects or applies labels from Patrick's category:value label taxonomy.
* `clerkwork-manage-node-version-policy` audits and updates Node.js and npm version declarations against actively supported releases.
* `clerkwork-osv-scan` scans dependencies for known vulnerabilities, auto-applies safe fixes, and files issues for the rest.
* `clerkwork-project-state-report` reports what changed in a repository since a given time, including GitHub PR and issue activity.
* `clerkwork-project-task-triage` syncs the local TODO.md scratch pad with GitHub Issues and regenerates the local PROJECT.md dashboard.
* `clerkwork-resume-interrupted-work` manages a project-root RESUME.md handoff file that blocks new work until interrupted work is resolved.
* `clerkwork-select-next-issue` selects one suitable open GitHub issue by priority and roadmap relevance, without implementing it.
* `clerkwork-work-on-issue` inspects a specific GitHub issue, implements the required change, validates, and commits with a closing reference.
* `clerkwork-work-on-next-issue` orchestrates selecting and implementing the next suitable open GitHub issue.
* `clerkwork-work-through-issues` continuously works through open GitHub issues until no suitable actionable issues remain.

## The cabinet of @davidsneighbour's skills

| Exhibit | Skill |
| :---: | :--- |
| [![Clerkwork](.github/assets/images/skillwerk/clerkwork-thumb.png)](https://github.com/davidsneighbour/clerkwork) | **[Clerkwork](https://github.com/davidsneighbour/clerkwork):** It's an engineers world. Start your engines, maintain, contrive, and put in the works. |
| [![Gallimaufry](.github/assets/images/skillwerk/gallimaufry-thumb.png)](https://github.com/davidsneighbour/gallimaufry) | **[Gallimaufry](https://github.com/davidsneighbour/gallimaufry):** A miscellaneous collection of small AI skills and odd useful workflows. |
| [![Gazetteer](.github/assets/images/skillwerk/gazetteer-thumb.png)](https://github.com/davidsneighbour/gazetteer) | **[Gazetteer](https://github.com/davidsneighbour/gazetteer):** Place-aware patterns for geographic content, local context, and location-rich publishing. |
| [![Idiolect](.github/assets/images/skillwerk/idiolect-thumb.png)](https://github.com/davidsneighbour/idiolect) | **[Idiolect](https://github.com/davidsneighbour/idiolect):** Finding your own language in skill outputs. |
| [![Patternbook](.github/assets/images/skillwerk/patternbook-thumb.png)](https://github.com/davidsneighbour/patternbook) | **[Patternbook](https://github.com/davidsneighbour/patternbook):** Patterns for better digital work. |
| [![Posthaste](.github/assets/images/skillwerk/posthaste-thumb.png)](https://github.com/davidsneighbour/posthaste) | **[Posthaste](https://github.com/davidsneighbour/posthaste):** A collection of skills to post to social media of all kinds. |
