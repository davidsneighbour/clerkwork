import { createReleaseConfig } from '@dnbhq/release-config';
import type { Config } from 'release-it';

const config: Config = createReleaseConfig({
  githubTokenRef: 'GITHUB_TOKEN_CONTENT_PRIVATE',
  overrides: {
    github: {
      release: true,
    },
    npm: {
      publish: false,
    },
  },
});

export default config;
