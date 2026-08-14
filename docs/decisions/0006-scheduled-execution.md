# 0006. Scheduled execution, attempted and not completed

- Date: 2026-08-04 proposed, 2026-08-05 partially verified
- Status: incomplete; read path verified, write path unverified, schedule never created
- Applies to: Run 1

## Context

The monitored-stop fallback (0004) makes the daily session load-bearing. If nobody runs a
session, no stop is checked and no exit is proposed. The session ran on 5 of 19 market
days. Twice, multi-day gaps opened during which the account held unprotected positions,
and during one of them a stop level was breached and closed through.

The manual cadence is not a discipline problem to be solved by trying harder. It failed
twice in three weeks and it will fail again, because it depends on a person remembering to
start a process on a machine that is deliberately powered down.

## Options considered

| Option | Argument for | Why it lost |
| --- | --- | --- |
| Keep it manual, try harder | No new infrastructure, no new credential surface. | Already tested twice by accident. Failed both times. |
| Move broker auth to an always-on machine and schedule locally | Simple. Full control. Nothing leaves the environment. | Puts live broker credentials on a host that is awake during every hour nobody is watching. This is the exact thing 0002 and the architecture note refuse to do. |
| Scheduled cloud agent that reads the repo and reaches the broker on a cron | The schedule does not depend on anyone being awake. The credentialed local host stays off. Sessions and stop checks happen whether or not the operator is present. | Chosen. Adds a scheduled context that can act on the account without a human present, which is a genuine expansion of the trusted surface. |

## Decision

Move the daily session and the weekly review to a scheduled agent. Verify in stages: repo
access first, broker read access second, order placement last, and do not claim autonomy is
active until the last one passes.

## Consequences

**The staged verification was the right shape and stopped at stage two.** On 08-05 a
read-only run confirmed the scheduled agent could read the rules file and the journals, and
could reach the broker for account, portfolio, position, and quote calls. It placed no
orders, by design, and said so.

Order placement from a scheduled context was never tested. The recurring schedule was never
created. The daily session therefore remained manual for the entire autonomous trial week —
which means the trial's own stated precondition ("a scheduled agent is running the daily
session") was not met for most of it, and the one autonomous sell that did occur happened
in a manually started session.

**The honest characterization is that this decision was made and not implemented.** The
gap between "we decided to automate the sessions" and "the sessions are automated" is where
this run actually lived, and the monitored stops were unenforced across all of it.

**The new exposure is real and was not analyzed before being partly adopted.** A scheduled
agent that can place orders without a human present removes the last practical constraint on
frequency and timing, and the run never got far enough to think properly about what
bounds it. The loss halts are the only thing that would.

## Revisit when

Before any renewal of 0005. Autonomy without a working schedule is not autonomy, and a
schedule without a working order path is not a session. Both need to pass before either is
worth relying on.
