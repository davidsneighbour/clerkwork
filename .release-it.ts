import { createReleaseConfig } from '@dnbhq/release-config';
import type { Config } from 'release-it';

const updateClaudeMarketplaceVersion = [
  'node',
  '--input-type=module',
  '--eval',
  '\'import { readFileSync, writeFileSync } from "node:fs"; const file = ".claude-plugin/marketplace.json"; const marketplace = JSON.parse(readFileSync(file, "utf8")); marketplace.version = process.argv.at(-1); writeFileSync(file, JSON.stringify(marketplace, null, 2) + "\\n");\'',
  '${version}',
].join(' ');

const config: Config = createReleaseConfig({
  githubTokenRef: 'GITHUB_TOKEN_CONTENT_PRIVATE',
  overrides: {
    github: {
      release: true,
    },
    hooks: {
      'after:bump': updateClaudeMarketplaceVersion,
    },
    npm: {
      publish: false,
    },
  },
});

export default config;
