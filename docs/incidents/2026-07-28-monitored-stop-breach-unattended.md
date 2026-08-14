# 2026-07-28 A monitored stop was breached for three sessions and nobody was there

- Severity: the highest of the run. The only risk control on an open position failed, in
  the exact manner it was documented as being able to fail, and the position was unmanaged
  through it. Contained by position size, not by any control.
- Detected by: discovered in review, five market days late
- Duration: first breach 07-28, discovered 08-04. Approximately five market days in a bad
  state.

## What happened

A position carried a monitored stop level of $194.47 — not a resting order, a number in a
file, per `2026-07-20-fractional-positions-cannot-hold-stops.md`. The rule attached to that
number is that the position is exited when price trades through it.

Price traded through it on 07-28, low of $192.74. It traded through it again on 07-29, low
of $190.01, and **closed** at $190.01 — not an intraday wick, a close below the level. It
traded through it a third time on 07-30, low of $191.52.

No session ran on any of those days. Nobody checked the level, nobody proposed the exit,
and no exit occurred. The position remained open, unmanaged, for the entire period.

By 08-04, when a catch-up review was finally held, price had recovered to $209.65 and the
position showed a small gain. The correct action, taken on time, would have realized a loss
of about $1.36. Not taking it produced a better outcome.

That is luck. The review recorded it as luck, in those terms, and this writeup does the
same. A control that fails and is rescued by a market reversal has still failed, and the
next reversal is not owed to anyone.

## Timeline

| Date | Event |
| --- | --- |
| 07-27 | Session runs. Three positions open, all with monitored levels only. Journal states explicitly that all three are unenforced and must be re-checked every session. |
| 07-28 | Low $192.74 — below the $194.47 level. No session. |
| 07-29 | Low and close $190.01 — closes below the level. No session. |
| 07-30 | Low $191.52 — below the level. No session. |
| 07-31 → 08-03 | No sessions. |
| 08-02 | Weekly review due. Not held. |
| 08-04 | Catch-up review held. Breach discovered in the price history, after the fact. Price recovered to $209.65; position green. Logged as the critical adherence wobble of the week. |

## Root cause

The monitored-stop mechanism has a dependency that a resting stop order does not: a human
starting a session. That dependency was never satisfied on the days it mattered.

The cause is not that someone forgot on a particular morning. It is that the design placed
a load-bearing control behind a manual trigger, on a machine that is deliberately powered
down, with no alerting, no scheduled execution, and no halt condition for "nobody has run a
session in three days." Every one of those was a known property of the design on 07-20. The
mechanism worked exactly as specified. The specification was the defect.

The trigger was an adverse price move. The cause is that the only thing standing between the
position and that move was somebody's memory.

## Why the existing controls did not catch it

Every layer that could have caught it was either absent or not applicable, and this is worth
walking through because it is the clearest illustration of the layering argument in the
whole run.

**Broker layer.** Would have caught it, if a resting stop had existed. It could not exist.
This is the layer that enforces regardless of attention, and it was unavailable for
mechanical reasons.

**Runtime layer.** Not applicable. The approval gate governs actions the agent takes. It has
nothing to say about actions nobody attempted.

**Rules layer.** The rule was correct and specific — exit on breach. It was never evaluated,
because evaluating it requires a session and there was no session. A rule that is only read
when someone starts a process is not enforced during the time nobody does.

**Procedural layer.** The daily session was the control. It did not run. There was no
detection for its absence — no alert, no dead-man switch, no halt condition triggered by
consecutive missed sessions. The system had no way to notice its own silence.

The general lesson, which is the one that transfers: **the layers are only independent if
they fail independently.** Here, the rules layer and the procedural layer shared a single
point of failure — a human starting a session — so what looked like two layers was one. The
broker layer, the genuinely independent one, had been knocked out eight days earlier by an
unrelated sizing constraint. That left a single control with a single dependency, described
in the documentation as three layers.

## What changed

| Change | Layer | Status |
| --- | --- | --- |
| Monitored levels trailed upward at the 08-04 review | procedure | Done, then stale again within days |
| Automate the daily session on a schedule so levels are actually checked | procedure | Proposed 08-04 as the single most important fix. Read-only verification passed 08-05. Recurring schedule never created. **Open.** |
| Raise the per-order cap to permit whole shares and real resting stops | rules | Proposed. Not done. **Open.** |
| Halt condition for consecutive missed sessions | rules | Not proposed at the time. Identified in this writeup. **Open.** |
| Execution autonomy granted | procedure | Done 08-04 — see below |

The last row is the uncomfortable one. The same review that identified this failure, and
that named fixing the stop mechanism as a prerequisite, also granted execution autonomy for
the following week without the prerequisite being met. The agent objected and recommended a
narrower grant limited to protective sells. See `docs/decisions/0005-autonomous-trial.md`.

## What is still exposed

All of it, as of 08-13.

Two positions remain open with monitored levels that no system enforces, last updated
08-04, nine sessions stale. No schedule runs. No alert fires when a session is missed. The
per-order cap is unchanged, so real stops remain impossible.

The one thing that changed is demonstrated rather than structural: on 08-07 a level was
breached and the exit was executed within minutes, with the journal explicitly citing this
incident as the mistake it was not going to repeat. That is encouraging and it is n=1. It
happened in a manually started session, which means it confirms the mechanism works when
somebody is present — the thing that was never in doubt.
