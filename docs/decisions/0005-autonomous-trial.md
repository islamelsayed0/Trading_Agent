# 0005. A one-week autonomous trial, granted over the agent's objection

- Date: 2026-08-04
- Status: expired 2026-08-09 by its own sunset clause, unrenewed; superseded by a return
  to 0001
- Applies to: Run 1, week of 2026-08-04

## Context

On 08-04 the operator asked the agent to start buying and selling on its own, without
per-trade approval.

The request arrived in the same session as the review that documented the monitored stop
being breached and unactioned for three sessions — the clearest evidence in the run that
the stop mechanism fails silently. The agent said so directly, declined to action the
request mid-week on the grounds that rules change only at review, and proposed a narrower
alternative.

This record exists because the operator then granted broad autonomy anyway, deliberately,
with the sunset and the halts written in. Recording only the agent's recommendation would
make the repo look better and would be a lie about what happened.

## Options considered

| Option | Argument for | Why it lost |
| --- | --- | --- |
| Decline entirely until stops are real | The prerequisite is unambiguous: the mechanism autonomy would rely on had failed six days earlier. Fix the control before removing the supervisor. | Nothing lost it on the merits. It was not chosen. |
| Supervised autonomy: auto-execute protective sells and stop-exits, keep new buys human-gated | Targets the actual gap. The failure mode was a stop not being honored while nobody watched, and this authorizes exactly the action that failure needed, and nothing more. Buys — the thing that creates new risk — stay gated. | Agent's recommendation. Not chosen; the operator wanted the broader test. |
| Full autonomy on buys and sells inside all hard guardrails, one week, with a sunset | Tests the actual research question rather than a proxy for it. Bounded by a $10 daily and $20 weekly realized-loss halt, a $25 per-order cap, three positions, and an account holding about $100. The worst realistic week is small and the information is real. | Chosen. It puts autonomous execution on top of a control already known to fail silently, which is the compounding this record is named for. |

## Decision

Full execution autonomy for buys and sells, for one week, sunsetting at the 08-09 review
and reverting to propose-and-approve by default if not explicitly renewed.

Autonomy removed the approval step and nothing else. Every hard guardrail stayed: the
whitelist, the per-order cap, the position cap, the earnings blackout, the loss halts, no
margin or options or crypto, settlement rules. The halal gate remained non-automatable
under any mode — that was written into the grant explicitly, as the one human decision that
autonomy does not touch.

The grant also stated its own operational preconditions, which is the part of it that aged
best: autonomy is only real if a scheduled agent is actually running the daily session, if
that agent can reach the broker, and if order placement can proceed without an interactive
prompt. The rules file instructed the agent to say plainly when those were not satisfied
rather than pretend autonomy was active.

## Consequences

**The compounding risk was accepted knowingly.** Autonomous execution was layered on a
monitored-stop mechanism that had already failed once, in the same document that recorded
the failure. The mitigations are the loss halts and the small account, not a fix to the
underlying control.

**Autonomy was never fully operational, and the rules file predicted the reason.** A
read-only cloud access test on 08-05 confirmed the scheduled agent could read the repo and
reach the broker. Order placement from a scheduled context was never verified, and the
recurring routine was never created. For most of the trial week, autonomy existed on paper.

**One autonomous action occurred, and it was the right one.** On 08-07 a position traded
through its monitored stop and the agent sold it without asking, citing the rule and
explicitly citing the 07-28 failure as the thing it was not going to repeat. It closed
+8.5%, the first realized profit of the run. That is a sample size of one, and it is the
narrow supervised-autonomy case the agent had recommended in the first place.

**The sunset worked, and nothing noticed it.** The trial expired on 08-09 because the
renewal review was not held. The default was the safe one, so the outcome was correct. But
the correctness came from the default, not from detection — the lapse went unobserved until
08-13. A control that only works when it fails safe has not been tested.

## Revisit when

Real resting stops exist, or scheduled execution is verified end to end including order
placement. Until one of those is true, a renewal is a repeat of the same bet with the same
known-broken dependency, and the outcome of the first one was decided by the market rather
than by the design.
