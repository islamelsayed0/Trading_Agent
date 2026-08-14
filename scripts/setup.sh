#!/usr/bin/env bash
set -euo pipefail
git rev-parse --git-dir >/dev/null 2>&1 || { echo "Run git init first."; exit 1; }
chmod +x scripts/scan.sh .githooks/pre-commit .githooks/pre-push
git config core.hooksPath .githooks
echo "Hooks installed. pre-commit scans staged content, pre-push scans tree and history."
