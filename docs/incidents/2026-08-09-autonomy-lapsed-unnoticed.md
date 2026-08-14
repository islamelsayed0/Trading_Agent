# 2026-08-09 An autonomy grant expired and nothing observed it

- Severity: near miss, and the interesting kind. The outcome was correct and no control
  detected that it was correct. The system had no idea what state it was in for four days.
- Detected by: human, on 08-13, during a check that was about something else
- Duration: 08-09 to 08-13, four days of undetermined operating mode

## What happened

Execution autonomy was granted for one week on 08-04 with an explicit sunset: it expires at
the 08-09 review, and reverts to propose-and-approve unless the operator renews it.

The 08-09 review was not held. It was the fourth scheduled review of the run to be missed
and the first to be missed with no catch-up at all.

The grant therefore lapsed on its own terms and the account reverted to propose-and-approve.
That is the correct outcome and it is what the design intended: fail safe, revert by
default, require an affirmative act to continue. The default worked.

Nothing noticed. No session ran on 08-10, 08-11, 08-12, or 08-13. No document was written
recording the expiry. Nobody stated whether the trial had been renewed, extended, or ended,
and the question was not asked until 08-13, when an unrelated read-only account check
surfaced it.

For four days the operating mode of a system connected to a live brokerage account was
undetermined — not unsafe, undetermined. The safe answer was true by default rather than by
observation, and nobody could have said which it was without going back to read the
rules file.

## Timeline

| Date | Event |
| --- | --- |
| 08-04 | Autonomy granted for one week. Sunset written into the rules file: expires at the 08-09 review, reverts to propose-only if not explicitly renewed. |
| 08-05 | Read-only cloud access verification passes. Order placement from a scheduled context untested. Recurring schedule not created. |
| 08-07 | One autonomous action: a monitored stop is honored and the position is sold, +8.5%. Manually started session. |
| 08-08 → 08-09 | No session. Review due 08-09. Not held. |
| 08-09 | Grant expires by its own terms. No document records this. |
| 08-10 → 08-12 | No sessions. Two positions open with monitored levels last updated 08-04. |
| 08-13 | Read-only account check for unrelated reasons. The lapse is noticed, along with the fact that no review file exists for 08-09. |

## Root cause

The sunset was written as a *state transition* but implemented as an *absence*. Nothing
happens on 08-09 — no job runs, no flag flips, no file is written. The trial ends because
time passes and nobody renews it.

That is a correct design for the safety property and a poor one for the observability
property. The system cannot report its own mode, because its mode is defined by the absence
of an act rather than by any recorded fact. A reader on 08-11 wanting to know whether the
agent could execute autonomously would have had to reconstruct it: find the grant, find its
sunset condition, confirm no renewal document exists, and infer.

The contributing cause is the same one behind three other incidents in this directory. The
review is the mechanism that makes state changes explicit, and the review did not convene —
for the fourth time in four attempts.

## Why the existing controls did not catch it

**The fail-safe default worked and is the reason this is a near miss rather than an
incident.** Autonomy required an affirmative renewal. None came, so it ended. If the default
had been the other way — autonomy persists until revoked — this same sequence of nobody
paying attention for four days would have left an agent with execution authority over a live
account, unsupervised and unreviewed, and nobody would have noticed that either.

That is the whole finding, and it generalizes past trading: **when the humans stop paying
attention, the system does whatever the default says. Choose the default for the day nobody
is watching, because that is the day it will be used.** This default was chosen correctly on
08-04 and it silently saved the run four days later.

What was missing is detection, at every layer. No alert on a missed review. No dead-man
condition on consecutive missed sessions — the same gap named in the 07-28 incident and
still open. No status file the system writes and a human can read. No halt triggered by the
mode being indeterminate.

The one control that would have caught it — the daily session, which begins by confirming
the rules loaded and the permission mode is correct — did not run on any of the four days.

## What changed

| Change | Layer | Status |
| --- | --- | --- |
| Repo status line now states the current mode, the date it was last verified, and that the trial lapsed | procedure | Done in this writeup |
| Expiry of any time-boxed grant must produce a written record on the day it expires | procedure | **Not adopted. Identified here.** Open. |
| Halt on N consecutive missed sessions | rules | **Not adopted.** Open since 07-28. |
| Missed review blocks new entries until held | rules | **Not adopted.** Open since 07-27. |
| Keep fail-safe defaults on every time-boxed authority grant | rules | Already correct. Reaffirmed. |

## What is still exposed

Mode is still inferred rather than recorded. As of this writing the account is in
propose-and-approve because a grant expired and was not renewed, which is documented here
and in the README status line, and nowhere else that a running process could read.

Two positions remain open with monitored levels last updated 08-04. No schedule runs, so no
detection exists for the next lapse of any kind.

The residual worth naming: this run has now produced two multi-day gaps where the system's
state was known only by reconstruction. Both times the reconstruction turned out fine. In
neither case was that because anything checked.
