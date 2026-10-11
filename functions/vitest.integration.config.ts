import { defineConfig } from 'vitest/config';

// Integration tests (callables against emulators) are added under test/integration
// as modules land. Run through: firebase emulators:exec "npm run test:integration"
export default defineConfig({
  test: {
    include: ['test/integration/**/*.test.ts'],
    environment: 'node',
    fileParallelism: false,
    passWithNoTests: true,
  },
});
