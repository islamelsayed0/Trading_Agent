#!/usr/bin/env bash
# Secret and identity scanner for the trading agent notebook.
# Usage:
#   ./scripts/scan.sh            scan tracked and staged content
#   ./scripts/scan.sh --tree     scan the whole working tree
#   ./scripts/scan.sh --history  scan all history and commit messages
set -uo pipefail

RED=$'\033[31m'; YEL=$'\033[33m'; GRN=$'\033[32m'; OFF=$'\033[0m'
FAIL=0

# Lines carrying the marker below are skipped. It exists so that this file and
# PUBLISHING.md can name a pattern in order to document it. It will also hide a real
# secret, so it belongs nowhere else.
MARKER='scan-allow'

PATTERNS=(
  # Broker and account identity
  '\baccount[ _-]?(number|no|#)\s*[:=]\s*[A-Za-z0-9]{5,}'
  '\b[A-Z]{3}[0-9]{8}\b'
  '\b[0-9]{9,}\b'
  '[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}'
  # Credentials
  'eyJ[A-Za-z0-9_-]{10,}'
  '(?i)\b(bearer|authorization)\b\s*[:=]?\s*[A-Za-z0-9._-]{20,}'
  '(?i)\b(api[_-]?key|secret|passwd|password|refresh[_-]?token|access[_-]?token|client[_-]?secret)\b\s*[:=]\s*\S{8,}'
  '[0-9]{8,10}:[A-Za-z0-9_-]{35}'
  '-----BEGIN [A-Z ]*PRIVATE KEY-----'
  # Host and personal identity
  '/Users/[a-z]'
  '/home/[a-z]'
  '\b10\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\b'
  '\b192\.168\.[0-9]{1,3}\.[0-9]{1,3}\b'
  '\b172\.(1[6-9]|2[0-9]|3[01])\.[0-9]{1,3}\.[0-9]{1,3}\b'
  '\b100\.(6[4-9]|[7-9][0-9]|1[01][0-9]|12[0-7])\.[0-9]{1,3}\.[0-9]{1,3}\b'
  '\b[a-zA-Z0-9-]+\.local\b'
  '\b[a-zA-Z0-9-]+\.ts\.net\b'
  # The business that never appears here (marker keeps this line from matching itself)
  '(?i)simsim' # scan-allow
)

BLOCKED_FILES='\.(png|jpe?g|gif|webp|heic|pdf|csv|ofx|qfx|pem|key|crt|p12|env|conf|cfg)$|(^|/)(settings\.json|\.mcp\.json)$'

scan_text () {
  local label="$1" text="$2"
  local clean
  clean=$(printf '%s' "$text" | grep -v "$MARKER")
  for p in "${PATTERNS[@]}"; do
    if printf '%s' "$clean" | grep -nPqi -- "$p" 2>/dev/null; then
      echo "${RED}BLOCKED${OFF} $label matches: $p"
      printf '%s' "$clean" | grep -nPi -- "$p" | head -3 | sed 's/^/    /'
      FAIL=1
    fi
  done
}

scan_files () {
  local files="$1"
  for f in $files; do
    [ -f "$f" ] || continue
    if printf '%s' "$f" | grep -Eq "$BLOCKED_FILES"; then
      if [ "${ALLOW_BLOCKED_FILES:-0}" = "1" ]; then
        echo "${YEL}OVERRIDE${OFF} file type normally refused: $f"
      else
        echo "${RED}BLOCKED${OFF} file type refused by default: $f"
        echo "    Screenshots and live config leak more than they explain."
        echo "    Draw a diagram, or override deliberately with ALLOW_BLOCKED_FILES=1."
        FAIL=1
      fi
      continue
    fi
    scan_text "$f" "$(cat "$f")"
  done
}

MODE="${1:---staged}"
case "$MODE" in
  --tree)
    scan_files "$(git ls-files 2>/dev/null; find . -type f -not -path './.git/*' | sed 's|^\./||')"
    ;;
  --history)
    scan_files "$(git ls-files)"
    for c in $(git rev-list --all 2>/dev/null); do
      scan_text "commit message $c" "$(git log -1 --format=%B "$c")"
    done
    for blob in $(git rev-list --objects --all 2>/dev/null | awk '{print $1}'); do
      t=$(git cat-file -t "$blob" 2>/dev/null)
      [ "$t" = "blob" ] || continue
      scan_text "history blob $blob" "$(git cat-file -p "$blob" 2>/dev/null | head -2000)"
    done
    ;;
  *)
    scan_files "$(git diff --cached --name-only --diff-filter=ACM 2>/dev/null)"
    ;;
esac

if [ "$FAIL" -eq 1 ]; then
  echo "${RED}Scan failed.${OFF} Nothing was committed. Fix the hits above."
  exit 1
fi
echo "${GRN}Scan clean.${OFF}"
