#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
npm --prefix functions run build
mkdir -p .emulator-data
IMPORT=()
if [ -f .emulator-data/firebase-export-metadata.json ]; then IMPORT=(--import ./.emulator-data); fi
firebase emulators:start "${IMPORT[@]}" --export-on-exit ./.emulator-data
