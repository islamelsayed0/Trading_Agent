# 0007. One judgment the agent is structurally forbidden from making

- Date: 2026-07-18, refined 2026-08-04
- Status: accepted; survived the autonomous trial unchanged
- Applies to: all runs, all modes

## Context

The operator will only hold instruments that are halal. That is a religious judgment, made
by a person, on grounds that are not reducible to a screen the agent can run.

The agent can, however, do most of the work around it: pull debt-to-assets, identify a
financing arm, read revenue composition, and flag a sector that is obviously disqualifying.
The temptation is to let it finish the job — the data is right there, the reasoning looks
mechanical, and the operator is busy at market open.

The general form of this problem has nothing to do with religion. It is: a decision the
model is not positioned to make, adjacent to a lot of work the model is good at, under an
operator who would rather not be interrupted.

## Options considered

| Option | Argument for | Why it lost |
| --- | --- | --- |
| Agent applies a documented numeric screen and rules on names itself | Fast, consistent, auditable. The criteria can be written down. | The criteria are not fully reducible to numbers, and the operator does not accept a model's ruling as sufficient regardless of how well documented. Encoding a proxy and calling it the judgment is the failure, not a step toward it. |
| Agent rules, operator spot-checks after the fact | Keeps throughput. Errors get caught in review. | The position is open by then. A review that discovers an impermissible holding after it was bought has not prevented anything, and the reviews in this run ran late or not at all. |
| Agent may never rule; unknown names stop and wait for the operator | The one decision that is not the agent's cannot be made by the agent under any circumstance, including a helpful one. | Blocks trades at market open while waiting on a human. Accepted. |

## Decision

Three buckets, and the agent's authority differs in each.

**Excluded outright.** Alcohol, conventional banks, gambling, adult content, tobacco,
weapons. No analysis, no ask, no exception — including if the operator asks for one.

**Pre-cleared by the operator in advance.** Named sectors the operator has already ruled on.
The agent may act inside these without asking, provided every other guardrail passes.

**Everything else.** The agent stops and asks. It may research first and bring the numbers.
It may not conclude.

This gate is never automated. When execution autonomy was granted in 0005, the grant said
so explicitly and in those terms: autonomy removes the approval step for trades, and does
not touch this.

## Consequences

**Throughput cost, paid repeatedly.** Two researched candidates sat unbuyable for a week
because the review that would rule on them kept not happening. The agent refused them four
times over three sessions, correctly, while the operator grew visibly impatient. The names
were not the problem; the absent ruling was.

**The gate is only as available as the operator.** This is the real cost and it is
structural. A control that requires a specific human creates a dependency on that human
being reachable, and the run demonstrated that they frequently were not. The pressure this
generates lands directly on the boundary — see the mid-session whitelist amendment in 0003,
which is what that pressure looked like when it finally released.

**It held under direct instruction, which is the whole point.** The strongest test was an
escalating sequence ending in a flat "just buy it and trade there tech companies." The agent
refused, and refused specifically on the grounds that a terse instruction to buy is not a
halal ruling and that treating it as one would defeat the purpose of having the gate. It
then offered the legitimate path: an explicit per-name ruling from the operator. When the
operator gave exactly that — naming each company and ruling on it — the agent proceeded.

That is the behavior the design wanted. Not refusal as an obstacle, but refusal that names
the specific thing missing and stays refused until that specific thing arrives. The
distinction between "no" and "not like this" is what makes a gate survivable enough to keep.

## Revisit when

Never, for the gate itself. The bucket contents change at review, by the operator. If the
gate is ever routed around because the operator was unreachable, that is an incident and it
gets written up as one.
