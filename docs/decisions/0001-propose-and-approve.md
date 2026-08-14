# 0001. Human approval on every order

- Date: 2026-07-18
- Status: accepted; suspended 2026-08-04 to 2026-08-09 by 0005, in force again since
- Applies to: Run 1

## Context

The broker's agent product supports connections where the agent can submit orders directly.
The runtime also supports permission modes ranging from prompting on every tool call to
allowing a session to run unattended. A choice had to be made before the first session,
and it is the choice that determines what every other control is worth.

## Options considered

| Option | Argument for | Why it lost |
| --- | --- | --- |
| Full autonomy inside written limits | Tests the actual research question. Removes the human as a bottleneck. | The written limits are the layer most likely to fail, so autonomy tests them by discovering the failure with money. Wrong order of operations. |
| Approve at session level, then run unattended | Practical. Matches how most people would use it. | Approval granted before the proposals exist is not approval. It is a signature on a blank page. |
| Approve every order individually | Every execution has a named human decision behind it. Refusals become observable. | Slow, and it means the experiment cannot scale past one operator paying attention. |

## Decision

Every order requires explicit per order approval in session. The agent proposes and
explains. It never executes. Permission mode is set to prompt on every action, and a mode
that is anything other than that is treated as a halt condition.

## Consequences

The experiment cannot answer the autonomy question in Run 1. That is accepted. What it can
answer is whether the refusals fire correctly and whether the proposals are any good, and
those have to be true before autonomy is worth discussing at all.

It also means the results carry a human in the loop, so the agent is not the only variable
being measured. Any conclusion about agent quality is confounded by operator judgment.
Worth stating rather than hiding.

## Revisit when

A full run completes with zero guardrail failures, and the proposals over that run were
good enough that overriding them was rare. Not on a calendar date, and not because the
approvals became tedious.

## What actually happened

Both halves of that revisit condition failed, and it was revisited anyway 17 days in.

The run did not complete without a guardrail failure — the stop rule turned out to be
non-compliable on day one and a monitored stop went unactioned for three sessions in week
two. And overriding the agent was not rare: on the first live session the agent proposed
nothing, and the operator overrode the skip and directed both entries.

That override is worth recording precisely, because it is the case this decision record
did not anticipate. The agent had proposed zero trades, judging both prepared setups
invalid after an overnight gap. The operator said to buy anyway. The agent checked the
instruction against the hard guardrails, found that none were breached — both names
whitelisted, inside the per-order cap, inside the position cap, no earnings blackout,
settled funds, no margin — and executed, while restating its disagreement and recording
the dissent in the journal.

That was correct, and it is the distinction this record should have made explicitly:
**the guardrails bind the agent, not the operator.** A skip is analysis, and analysis is
the operator's to overrule. A whitelist is a boundary, and a boundary is not. The agent
correctly refused four requests to cross the second kind in the same period it complied
with an override of the first kind. Getting that line right under pressure is more of the
value of propose-and-approve than the approvals themselves.

The confounding admitted above is real and larger than expected. Of three entries taken,
one was the operator overruling a skip, one was the agent's own pick from a shortlist the
operator asked for, and one was the agent choosing between two names the operator named.
There is no clean measurement of agent judgment anywhere in this run.
