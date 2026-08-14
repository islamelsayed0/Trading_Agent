# System architecture

## Components

| Component | Role | Holds credentials |
| --- | --- | --- |
| Session host laptop | Runs the agent, the only machine with broker auth | Yes |
| Broker agent account | Isolated account, the only order destination | n/a |
| MCP connection | Transport between agent and broker API | Token, on host only |
| Rules file | Loaded at session start from the project directory | No |
| Journal directory | Append-only record of every session | No |
| Cloud agent runner | Scheduled execution, verified for reads only | Delegated, not stored by the operator |

Deliberately excluded: every always-on machine in the environment. The convenient move is
to put broker auth on something that is always awake so the schedule can fire without
anyone being present, and that convenience is exactly what makes it a bad idea. An
always-on host with broker credentials is reachable during every hour nobody is watching.
The session host is not running outside session hours, which means the window in which
credentials are live is the window in which a human is present.

This decision has a cost and the run paid it in full. Because the only credentialed
machine is one somebody has to turn on, the daily session depends on a human remembering,
and the human did not remember on 14 of 19 market days. The mitigation and the failure are
the same design choice viewed from two sides. See
`docs/decisions/0006-scheduled-execution.md`.

## Data flow

```
  ┌─ SESSION START ────────────────────────────────────────────────────┐
  │                                                                     │
  │   agent launched from project directory                             │
  │            │                                                        │
  │            ▼                                                        │
  │   rules file loaded from launch directory  ◄── silent failure point │
  │            │                                    (see below)         │
  │            ▼                                                        │
  │   [H] confirm rules loaded, confirm approval mode is on             │
  └────────────┼────────────────────────────────────────────────────────┘
               │
               ▼
     ┌─ READ (no approval needed, no side effects) ──────────────┐
     │   account state ─ positions ─ quotes ─ ATR ─ earnings     │
     │   broker enforces: agent-enabled flag true on 1 of 3 accts│
     └────────────┼──────────────────────────────────────────────┘
                  │
                  ▼
        agent forms 0–2 proposals
        (bull case, bear case, entry, size, stop arithmetic, exit)
                  │
                  ├─────────── is the instrument on the whitelist? ──── no ──▶ REFUSE
                  │                                                            (logged)
                  ├─────────── is it halal-cleared already? ───── unknown ──▶ ┌──────┐
                  │                                                           │ [H]  │
                  │                                             THE ONE GATE  │ ASK  │
                  │                                             never automated└──┬───┘
                  │                                                              │
                  ├─────────── inside earnings blackout? ──────── yes ──▶ REFUSE  │
                  ├─────────── would exceed 3 open positions? ─── yes ──▶ REFUSE  │
                  ├─────────── order over the per-order cap? ──── yes ──▶ REFUSE  │
                  ├─────────── uses unsettled funds? ──────────── yes ──▶ REFUSE  │
                  ▼                                                              │
        ┌─────────────────────┐                                                  │
        │  [H] APPROVE / REJECT│ ◄────────────────────────────────────────────────┘
        │  per order, in session│
        └──────────┬───────────┘
                   │ approved
                   ▼
        runtime approval prompt  ◄── [H] the enforced gate, not the polite one
                   │
                   ▼
        order submitted ──▶ broker ──▶ ACCEPTED or REJECTED (400s are real, see incidents)
                   │
                   ▼
        stop placement attempted
                   │
                   ├── fractional position? ──▶ BROKER REFUSES ──▶ monitored level only
                   │                             (structural, every position)      │
                   └── whole share? ──▶ resting stop rests at broker                │
                                                                                    │
                   ┌────────────────────────────────────────────────────────────────┘
                   ▼
        journal written ──▶ session closed ──▶ host down

  [H] = a human decision is required. Five of them per session.
        The gate marked THE ONE GATE is never automated under any mode,
        including the autonomous trial.
```

During the autonomous trial week the two `[H]` boxes in the approve path were removed and
the runtime prompt was disabled. The whitelist checks, the caps, the blackout, and the
halal gate all remained. Autonomy removed the approval step; it never relaxed a guardrail.

## The startup dependency worth knowing about

The rules file loads based on the directory the agent was launched from, not on any
directory changed into afterward. Launching from the wrong place silently drops every rule
while keeping the broker connection fully alive. There is no error. The agent comes up
helpful, capable, connected to a live brokerage account, and unconstrained.

Mitigation is procedural and weak: the session always starts with the same launch from the
same directory, and step 2 of the runbook is to ask a question with a known refusal answer
before anything else happens. If it complies, the rules did not load and the session is
void.

That check has never caught a real failure, which is not the same as the failure being
impossible. It is the same class of problem as any system that loads policy from a path
and then trusts that the path was right — the failure is silent, the blast radius is
total, and the only signal is the absence of a behavior you have to deliberately go
looking for.

This is the highest-severity failure mode in the design and it has nothing to do with
trading.

## Permission model

Reads require no approval: account listings, positions, quotes, historical bars, technical
indicators, earnings calendars. These have no side effects and the agent uses them freely.

Writes require an interactive approval per call, enforced by the runtime rather than by the
agent's willingness to ask. Order placement, order cancellation, and watchlist mutation all
sit behind it. The distinction that matters is that the agent cannot approve on its own
behalf; a human is in the loop because the harness will not proceed otherwise.

The agent is denied the other two accounts by the broker, not by instruction. The rules
file also instructs it to ignore them, deliberately as a second line rather than as the
control being relied on.

Disconnection lives at the broker, in the account's agent-connection setting. It is
outside the agent's reach entirely — nothing the agent does can restore its own access
once the operator revokes it. This was located and confirmed before the first live
session, on the principle that you do not want to be discovering the kill switch during
the event that requires it.

## What I would change

Written after the fact, in order of how much they would have mattered.

1. **Raise the per-order cap enough to buy whole shares, or accept that there are no
   stops.** The cap was set at a level below one share of every name on the whitelist,
   which forced fractional positions, which made resting stop orders impossible. A risk
   control was silently converted into a note in a file by an unrelated sizing decision.
   Nobody designed that; it emerged.

2. **Do not grant autonomy on top of a known-broken control.** Autonomy was enabled six
   days after the stop mechanism was demonstrated to fail silently, with the fix listed as
   a prerequisite that was then not completed first.

3. **Automate the schedule before relying on a schedule.** The entire monitored-stop
   fallback assumes a daily session. The daily session ran 26% of the time.

4. **Write the halt condition for "the operator disappears for a week."** There is a halt
   for realized losses, one for guardrail failures, and one for the permission mode being
   wrong. There is none for nobody showing up, which is the failure that actually happened,
   twice.
