#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

echo "== Flutter =="
melos bootstrap
melos run format-check
melos run analyze
melos run test

echo "== Functions =="
(cd functions && npm ci && npm run typecheck && npm test && npm run test:rules)

echo "All suites passed."
