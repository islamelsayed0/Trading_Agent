# 2026-11-08 The secret scanner reported clean without ever running a pattern

- Severity: control failure with no confirmed leak. The scanner is the last automated check
  before anything in this public repo reaches GitHub. From July until today it passed every
  input on stock macOS. A full rescan with the fix found nothing.
- Detected by: agent, reading the scanner before reusing it in a follow on project
- Duration: July 2026 (scanner written) to 2026-11-08 (fix pushed)

## What happened

`scripts/scan.sh` runs each pattern with `grep -nPqi`. The grep that ships with macOS is
BSD grep, which has no `-P` (Perl regex) option. Every call failed with "invalid option",
the error went to `/dev/null`, and a failed grep reads the same as "no match". With nothing
matched, the script printed "Scan clean." and exited 0. That holds for any input, a real
token included.

So for the whole of Run 1 the scanner described in `PUBLISHING.md` was a green light wired
to nothing. The notebook went out on 2026-08-13 protected only by the manual read through
that `PUBLISHING.md` asks for before going public.

The defect surfaced when the scanner was copied into a private follow on repo and read
line by line before being installed as a hook. A one line test of the system grep with
`-P` failed.

Fixing it exposed a second gap. In the follow on repo the machine had no git email set,
so git built one from the login name and the hostname, and the first commits carried it as
author and committer. That repo is private and the commits were rewritten the same day.
The scanner could not have caught this even when working: it reads file contents and
commit messages, never commit metadata.

## Timeline

| Date | Event |
| --- | --- |
| July 2026 | Scanner written for this notebook. Fails open on stock macOS from the start. |
| 2026-08-13 | Notebook committed and published. The only check that actually ran was the manual review. |
| 2026-11-08 | Scanner read before reuse. `grep -P` on macOS: "invalid option". Defect confirmed. |
| 2026-11-08 | This repo cloned. A fixed copy of its own scanner run over every file, every commit message, every historical blob and every author and committer email: clean. A planted test secret was blocked, so "clean" means something this time. |
| 2026-11-08 | Fix pushed. Email check added. This record written. |

## Root cause

The scanner checked for a match and never checked that its matcher worked. A grep that
cannot start and a grep that finds nothing return the same "false" to an `if`, and stderr
was discarded on purpose to keep the output tidy. There was no self test, so the first
time it met a real secret on macOS would also have been the first time anyone learned it
did nothing.

The email gap has its own cause: file contents were treated as the whole surface, and
commit metadata was left out of scope.

## Why the existing controls did not catch it

- The scanner was the control, and it failed open. Its only test was the clean path, "the
  repo passes", which a dead scanner passes too. It was never run against a planted secret
  on the machine that uses it.
- The hooks live in local git config (`core.hooksPath`). A fresh clone does not inherit
  them. The clone made for this fix had no hooks until they were turned on by hand.
- No layer looked at author or committer emails.

## What changed

| Change | Layer | Status |
| --- | --- | --- |
| Scanner picks a grep that supports `-P` (GNU grep), confirms it with a self test, and exits 1 if none is found | procedure | done |
| Full rescan of files, commit messages, blobs and commit emails | procedure | done, clean |
| `scan.sh --history` checks every author and committer email against the account's GitHub noreply address | procedure | done |
| New `scan.sh --emails`, run first in `pre-push`, checks the commits being pushed | procedure | done |
| The default (pre commit) mode refuses a commit whose author or committer identity is not the noreply address | procedure | done |
| Negative tests: planted token blocked; a wrong email blocked at commit, history scan and push | procedure | done, by hand |

## What is still exposed

- The negative tests were run by hand once. Nothing reruns them, so a later edit could make
  the scanner fail open again unnoticed. A test that plants a secret and expects exit 1
  belongs in any repo that relies on this script.
- Hooks still have to be enabled in every clone. Forgetting is silent.
- The history scan reads only the first 2000 lines of each blob.
- Pattern scanning only finds what it has patterns for. The manual read through in
  `PUBLISHING.md` stays a required step, not a backup.
- A commit made in the GitHub web interface uses GitHub's own committer address and will be
  refused at the next push. That is deliberate.
