#!/usr/bin/env bash
# Negative tests for scripts/scan.sh. Every check must refuse what it exists to refuse.
# A scanner whose only test is "the repo passes" cannot be told apart from a dead one
# (see docs/incidents/2026-11-08-scanner-grep-p-silent-pass.md).
#
# Run from anywhere: tests/test_scan.sh    The pre-push hook runs it before scanning.
# Each case runs in a throwaway git repo. Planted values are assembled from pieces at
# run time, so this file itself scans clean.
set -uo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SCAN="$ROOT/scripts/scan.sh"
ALLOWED=$(sed -n "s/^ALLOWED_EMAIL='\([^']*\)'.*/\1/p" "$SCAN")
NAME=$(sed -nE "s/.*\(\?i\)([a-z]{4,})'.*scan-allow.*/\1/p" "$SCAN" | head -1)
has () { grep -qF -- "$1" "$SCAN"; }

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
PASS=0; FAILS=0

fail () { FAILS=$((FAILS + 1)); echo "FAIL $1"; [ -f "$TMP/out" ] && sed 's/^/    /' "$TMP/out" | head -6; }

[ -n "$ALLOWED" ] || { echo "FAIL cannot read ALLOWED_EMAIL from scan.sh"; exit 1; }

fresh () { # [private]  new repo with the scanner committed
  rm -rf "$TMP/r"; mkdir -p "$TMP/r/scripts"; cd "$TMP/r" || exit 1
  git init -q -b main
  git config user.name test; git config user.email "$ALLOWED"; git config core.hooksPath "$TMP/nohooks"
  cp "$SCAN" scripts/scan.sh
  [ "${1:-}" = private ] && echo private > .scan-profile
  git add -A && git commit -q -m init
}

expect () { # want(0|1) name command...
  local want=$1 name=$2 got; shift 2
  "$@" >"$TMP/out" 2>&1 </dev/null; got=$?
  [ "$got" -ne 0 ] && got=1
  if [ "$got" != "$want" ]; then fail "$name (want exit $want, got $got)"; return; fi
  # A refusal only counts if the scanner itself refused. A crash, a missing file or a
  # permission error also exits non zero, and must not pass as "blocked".
  if [ "$want" = 1 ] && ! grep -q 'Scan failed\.' "$TMP/out"; then
    fail "$name (exited non zero without the scanner refusing)"; return
  fi
  PASS=$((PASS + 1))
}

stage () { printf '%s\n' "$2" > "$1"; git add "$1"; }
staged () { ./scripts/scan.sh --staged; }
history () { ./scripts/scan.sh --history; }
push_range () { printf 'refs/heads/main %s refs/heads/main %s\n' "$2" "$1" | ./scripts/scan.sh --emails; }

ZEROS=$(printf '0%.0s' $(seq 1 40))
TOKEN="access""_token = abcdefghijklmnop"
JWT="ey""J$(printf 'a%.0s' $(seq 1 24))"
PKEY="-----BEGIN RSA PRIV""ATE KEY-----"
HOMEPATH="/Us""ers/someone/project"
PRIVIP="192.""168.1.20"
LONGNUM="12345""67890"
LOCALHOST="buildbox.lo""cal"

# 1. Each secret class is refused at commit time.
for c in TOKEN JWT PKEY HOMEPATH PRIVIP LONGNUM LOCALHOST; do
  fresh; stage notes.md "line with ${!c} in it"
  expect 1 "staged refuses $c" staged
done
if has 'xoxb|xoxp|ghp_'; then
  fresh; stage notes.md "gh""p_abcdefghijklmnop"
  expect 1 "staged refuses GITHUB_TOKEN" staged
fi

# 2. Refused file types and the clean path.
fresh; printf 'x' > shot.png; git add shot.png
expect 1 "staged refuses a .png" staged
fresh; stage notes.md "an ordinary sentence about stops and limits"
expect 0 "staged passes clean text" staged

# 3. Profiles: public refuses the business name and dollar amounts; private allows them.
if has 'PROFILE=public'; then
  fresh; stage notes.md "made for $NAME"
  expect 1 "public profile refuses the business name" staged
  fresh; stage notes.md "balance "'$'"1,250.00"
  expect 1 "public profile refuses a dollar amount" staged
  fresh private; stage notes.md "made for $NAME, balance "'$'"1,250.00"
  expect 0 "private profile allows name and dollars" staged
elif [ -n "$NAME" ]; then
  fresh; stage notes.md "made for $NAME"
  expect 1 "staged refuses the business name" staged
fi

# 4. --files mode, where present.
if has '--files)'; then
  fresh; printf '%s\n' "$TOKEN" > notes.md
  expect 1 "--files refuses a token" ./scripts/scan.sh --files notes.md
fi

# 5. History: a secret deleted later, and a secret in a commit message.
fresh; stage notes.md "$TOKEN"; git commit -q -m add; git rm -q notes.md; git commit -q -m remove
expect 1 "history refuses a deleted secret" history
fresh; git commit -q --allow-empty -m "$TOKEN"
expect 1 "history refuses a secret in a commit message" history
fresh
expect 0 "history passes a clean repo" history

# 6. Commit identity.
fresh; git config user.email "someone@example.test"; stage notes.md "clean"
expect 1 "staged refuses a non noreply identity" staged
fresh; git -c user.email=someone@example.test commit -q --allow-empty -m wip
expect 1 "history refuses a non noreply commit email" history
fresh; base=$(git rev-parse HEAD); git -c user.email=someone@example.test commit -q --allow-empty -m wip
expect 1 "pre-push refuses a bad email in the pushed range" push_range "$base" "$(git rev-parse HEAD)"
fresh; base=$(git rev-parse HEAD); git commit -q --allow-empty -m ok
expect 0 "pre-push passes a good pushed range" push_range "$base" "$(git rev-parse HEAD)"
fresh; git -c user.email=someone@example.test commit -q --allow-empty -m wip
expect 1 "pre-push refuses a bad email on a new branch" push_range "$ZEROS" "$(git rev-parse HEAD)"

# 7. No PCRE grep: must fail closed and say why, never report clean.
fresh; sed -i.bak 's/^for g in .*; do$/for g in no_such_grep_here; do/' scripts/scan.sh
if grep -q 'no_such_grep_here' scripts/scan.sh; then
  expect 1 "no PCRE grep fails closed" staged
  grep -q 'No grep with -P' "$TMP/out" || fail "no PCRE grep message missing"
else
  fail "could not disable grep discovery in the scanner copy"
fi

echo "scanner self test: $PASS passed, $FAILS failed"
[ "$FAILS" -eq 0 ]
