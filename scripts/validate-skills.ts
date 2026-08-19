#!/usr/bin/env node
// Checks each skill against the Agent Skills spec <https://agentskills.io/specification>
// and against install manifests:
//
//   - SKILL.md exists and its front matter parses
//   - `name` is 1-64 chars, kebab-case, and matches its directory
//   - `description` is present and at most 1024 chars
//   - agents/openai.yaml exists and has valid OpenAI UI metadata
//   - skills/ and skills.sh.json entries are 1:1
//   - skills/ and the Claude marketplace skill paths are 1:1

import { existsSync, readdirSync, readFileSync } from "node:fs";
import { join } from "node:path";

const CLAUDE_MARKETPLACE = ".claude-plugin/marketplace.json";
const SKILLS_SH_MANIFEST = "skills.sh.json";
const VALIDATOR_CONFIG = join("scripts", "validate-skills.config.json");

const NAME_MAX = 64;
const DESCRIPTION_MAX = 1024;
const OPENAI_SHORT_DESCRIPTION_MIN = 25;
const OPENAI_SHORT_DESCRIPTION_MAX = 64;
// Lowercase alphanumerics in hyphen-separated groups: no leading, trailing or
// doubled hyphen, which is every rule the spec puts on `name` bar its length.
const NAME_PATTERN = /^[a-z0-9]+(-[a-z0-9]+)*$/;

type Frontmatter = {
  description?: string;
  name?: string;
};

type PackageJson = {
  name?: unknown;
};

type ValidatorConfig = {
  explicitOnlySkills?: unknown;
};

type OpenAiMetadata = {
  interface?: {
    default_prompt?: string;
    display_name?: string;
    short_description?: string;
  };
  policy?: {
    allow_implicit_invocation?: boolean;
  };
};

type SkillsManifest = {
  groupings?: Array<{
    skills?: unknown;
    title?: unknown;
  }>;
};

type ClaudeMarketplace = {
  plugins?: Array<{
    name?: unknown;
    skills?: unknown;
    source?: unknown;
    strict?: unknown;
  }>;
};

const errors: string[] = [];
const fail = (where: string, message: string): void => {
  errors.push(`${where}: ${message}`);
};

// Enough YAML for two quoted-or-plain scalars, which saves a dependency.
const frontmatterOf = (source: string): Frontmatter | null => {
  const match = /^---\n(.*?)\n---(?:\n|$)/s.exec(source);
  if (!match) return null;

  const body = match[1];
  if (body === undefined) return null;

  const fields: Record<string, string> = {};
  for (const line of body.split("\n")) {
    const field = /^([A-Za-z][\w-]*):[ \t]*(.*)$/.exec(line);
    if (!field) continue;
    const key = field[1];
    const rawValue = field[2];
    if (key === undefined || rawValue === undefined) continue;
    const value = rawValue.trim();
    const quoted = /^'(.*)'$|^"(.*)"$/s.exec(value);
    fields[key] = quoted ? (quoted[1] ?? quoted[2] ?? "") : value;
  }
  return fields;
};

const openAiMetadataOf = (
  source: string,
  path: string,
): OpenAiMetadata | null => {
  const metadata: OpenAiMetadata = {};
  let section: "interface" | "policy" | null = null;

  for (const [lineIndex, line] of source.split("\n").entries()) {
    if (!line.trim()) continue;

    const sectionMatch = /^([a-z_]+):$/.exec(line);
    if (sectionMatch) {
      const sectionName = sectionMatch[1];
      if (sectionName === "interface" || sectionName === "policy") {
        section = sectionName;
        metadata[section] ??= {};
        continue;
      }

      fail(
        path,
        `unsupported top-level section \`${sectionName}\` on line ${lineIndex + 1}`,
      );
      section = null;
      continue;
    }

    const fieldMatch = /^ {2}([a-z_]+):[ \t]*(.*)$/.exec(line);
    if (!fieldMatch || !section) {
      fail(path, `unsupported YAML shape on line ${lineIndex + 1}`);
      continue;
    }

    const key = fieldMatch[1];
    const rawValue = fieldMatch[2];
    if (!key || rawValue === undefined) continue;

    if (section === "interface") {
      const quoted = /^"(.*)"$/.exec(rawValue.trim());
      if (!quoted) {
        fail(
          path,
          `interface.${key} must be a quoted string on line ${lineIndex + 1}`,
        );
        continue;
      }

      if (
        key !== "display_name" &&
        key !== "short_description" &&
        key !== "default_prompt"
      ) {
        fail(path, `unsupported interface field \`${key}\``);
        continue;
      }

      metadata.interface ??= {};
      metadata.interface[key] = quoted[1] ?? "";
      continue;
    }

    if (key !== "allow_implicit_invocation") {
      fail(path, `unsupported policy field \`${key}\``);
      continue;
    }

    const value = rawValue.trim();
    if (value !== "true" && value !== "false") {
      fail(
        path,
        `policy.${key} must be true or false on line ${lineIndex + 1}`,
      );
      continue;
    }

    metadata.policy ??= {};
    metadata.policy.allow_implicit_invocation = value === "true";
  }

  return metadata;
};

const unique = <Value>(values: Value[]): Value[] => [...new Set(values)];

const duplicates = <Value>(values: Value[]): Value[] =>
  unique(values).filter(
    (value) => values.filter((entry) => entry === value).length > 1,
  );

const readJson = <Value>(path: string): Value | null => {
  try {
    return JSON.parse(readFileSync(path, "utf8")) as Value;
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    fail(path, `unreadable or invalid JSON: ${message}`);
    return null;
  }
};

const readOptionalJson = <Value>(path: string): Value | null => {
  if (!existsSync(path)) return null;
  return readJson<Value>(path);
};

const packageNameSlug = (name: unknown): string | null => {
  if (typeof name !== "string" || !name) return null;

  const slug = name.includes("/") ? name.split("/").at(-1) : name;
  return slug && NAME_PATTERN.test(slug) ? slug : null;
};

const validateListedSlugs = (
  manifestPath: string,
  listed: string[],
  entryKind: string,
): void => {
  for (const slug of slugs)
    if (!listed.includes(slug))
      fail(manifestPath, `skills/${slug} has no ${entryKind} entry`);
  for (const name of listed)
    if (!slugs.includes(name))
      fail(
        manifestPath,
        `${entryKind} entry \`${name}\` has no skills/${name}`,
      );
  for (const name of duplicates(listed))
    fail(
      manifestPath,
      `${entryKind} entry \`${name}\` is listed more than once`,
    );
};

const slugs = readdirSync("skills", { withFileTypes: true })
  .filter((entry) => entry.isDirectory() && !entry.name.startsWith("."))
  .map((entry) => entry.name)
  .sort();

const packageJson = readOptionalJson<PackageJson>("package.json");
const repositoryPackageName = packageNameSlug(packageJson?.name);
if (!repositoryPackageName) {
  fail(
    "package.json",
    "`name` must identify the repository package name, such as @scope/example-skill",
  );
}

const validatorConfig = readOptionalJson<ValidatorConfig>(VALIDATOR_CONFIG);
const explicitOnlySkills = validatorConfig?.explicitOnlySkills ?? [];
if (!Array.isArray(explicitOnlySkills)) {
  fail(VALIDATOR_CONFIG, "`explicitOnlySkills` must be an array");
}
const explicitOnlySkillSlugs = Array.isArray(explicitOnlySkills)
  ? explicitOnlySkills.flatMap((skill) => {
      if (typeof skill === "string") return skill;
      fail(VALIDATOR_CONFIG, "`explicitOnlySkills` entries must be strings");
      return [];
    })
  : [];
for (const skill of duplicates(explicitOnlySkillSlugs)) {
  fail(
    VALIDATOR_CONFIG,
    `explicitOnlySkills entry \`${skill}\` is listed more than once`,
  );
}
for (const skill of explicitOnlySkillSlugs) {
  if (!slugs.includes(skill)) {
    fail(
      VALIDATOR_CONFIG,
      `explicitOnlySkills entry \`${skill}\` has no skills/${skill}`,
    );
  }
}

for (const slug of slugs) {
  const path = join("skills", slug, "SKILL.md");
  if (!existsSync(path)) {
    fail(path, "missing SKILL.md");
    continue;
  }

  const frontmatter = frontmatterOf(readFileSync(path, "utf8"));
  if (!frontmatter) {
    fail(path, "missing YAML front matter (--- name / description ---)");
    continue;
  }

  const { name = "", description = "" } = frontmatter;

  if (name !== slug) {
    fail(path, `\`name: ${name}\` must match its directory (${slug})`);
  } else if (!NAME_PATTERN.test(name)) {
    fail(
      path,
      `\`name: ${name}\` must be lowercase a–z, 0–9 and single hyphens, ` +
        "not leading, trailing or doubled",
    );
  } else if (name.length > NAME_MAX) {
    fail(path, `\`name\` is ${name.length} characters (max ${NAME_MAX})`);
  }

  // An agent reads the description to decide whether the skill is relevant, so
  // without one the skill never fires.
  if (!description) {
    fail(path, "front matter is missing `description`");
  } else if (description.length > DESCRIPTION_MAX) {
    fail(
      path,
      `\`description\` is ${description.length} characters (max ${DESCRIPTION_MAX})`,
    );
  }

  const openAiPath = join("skills", slug, "agents", "openai.yaml");
  if (!existsSync(openAiPath)) {
    fail(openAiPath, "missing agents/openai.yaml");
    continue;
  }

  const openAiMetadata = openAiMetadataOf(
    readFileSync(openAiPath, "utf8"),
    openAiPath,
  );
  const openAiInterface = openAiMetadata?.interface ?? {};
  const openAiPolicy = openAiMetadata?.policy;

  if (!openAiInterface.display_name) {
    fail(openAiPath, "interface.display_name is required");
  }

  const shortDescription = openAiInterface.short_description ?? "";
  if (!shortDescription) {
    fail(openAiPath, "interface.short_description is required");
  } else if (
    shortDescription.length < OPENAI_SHORT_DESCRIPTION_MIN ||
    shortDescription.length > OPENAI_SHORT_DESCRIPTION_MAX
  ) {
    fail(
      openAiPath,
      `interface.short_description is ${shortDescription.length} characters ` +
        `(must be ${OPENAI_SHORT_DESCRIPTION_MIN}-${OPENAI_SHORT_DESCRIPTION_MAX})`,
    );
  }

  const defaultPrompt = openAiInterface.default_prompt ?? "";
  if (!defaultPrompt) {
    fail(openAiPath, "interface.default_prompt is required");
  } else if (!defaultPrompt.includes(`$${slug}`)) {
    fail(openAiPath, `interface.default_prompt must mention $${slug}`);
  }

  if (explicitOnlySkillSlugs.includes(slug)) {
    if (openAiPolicy?.allow_implicit_invocation !== false) {
      fail(
        openAiPath,
        "credential helper skills must set policy.allow_implicit_invocation to false",
      );
    }
  } else if (openAiPolicy?.allow_implicit_invocation === false) {
    fail(
      openAiPath,
      "only credential helper skills may disable implicit invocation",
    );
  }
}

const skillsManifest = readJson<SkillsManifest>(SKILLS_SH_MANIFEST);

if (skillsManifest) {
  const groupings = Array.isArray(skillsManifest.groupings)
    ? skillsManifest.groupings
    : [];
  const listed = groupings.flatMap((grouping, index) => {
    if (!Array.isArray(grouping.skills)) {
      fail(
        `${SKILLS_SH_MANIFEST} groupings[${index}]`,
        "`skills` must be an array",
      );
      return [];
    }

    return grouping.skills.flatMap((skill) => {
      if (typeof skill === "string") return skill;
      fail(
        `${SKILLS_SH_MANIFEST} groupings[${index}]`,
        "`skills` entries must be strings",
      );
      return [];
    });
  });

  // A skill with no manifest entry cannot be installed through the repo manifest,
  // and a stale manifest entry points users at a skill that is not present.
  validateListedSlugs(SKILLS_SH_MANIFEST, listed, "manifest");
}

const claudeMarketplace = readJson<ClaudeMarketplace>(CLAUDE_MARKETPLACE);

if (claudeMarketplace) {
  const plugins = Array.isArray(claudeMarketplace.plugins)
    ? claudeMarketplace.plugins
    : [];

  if (plugins.length !== 1) {
    fail(CLAUDE_MARKETPLACE, "expected exactly one plugin entry");
  }

  const [plugin] = plugins;
  if (plugin) {
    if (repositoryPackageName && plugin.name !== repositoryPackageName) {
      fail(
        CLAUDE_MARKETPLACE,
        `plugin \`name\` must match repository package name "${repositoryPackageName}"`,
      );
    }
    if (plugin.source !== "./") {
      fail(CLAUDE_MARKETPLACE, 'plugin `source` must be "./"');
    }
    if (plugin.strict !== false) {
      fail(CLAUDE_MARKETPLACE, "plugin must set `strict` to false");
    }
    if (!Array.isArray(plugin.skills)) {
      fail(CLAUDE_MARKETPLACE, "plugin `skills` must be an array");
    } else {
      const listed = plugin.skills.flatMap((skill) => {
        if (typeof skill === "string" && skill.startsWith("./skills/")) {
          return skill.slice("./skills/".length);
        }
        fail(
          CLAUDE_MARKETPLACE,
          "`skills` entries must be ./skills/<skill-name> paths",
        );
        return [];
      });

      validateListedSlugs(CLAUDE_MARKETPLACE, listed, "Claude marketplace");
    }
  }
}

if (errors.length > 0) {
  console.error(`✗ ${errors.length} problem(s):\n`);
  for (const error of errors) console.error(`  ${error}`);
  process.exit(1);
}

console.log(`✓ ${slugs.length} skill(s) valid: ${slugs.join(", ")}`);
