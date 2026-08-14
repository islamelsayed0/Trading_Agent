# 0003. An instrument whitelist the agent may never modify

- Date: 2026-07-18
- Status: accepted
- Applies to: all runs

## Context

The agent has access to the full tradable universe through the broker API. It also has
opinions, and those opinions are generated text. A boundary was needed around what it is
allowed to propose at all, separate from whether any given proposal is good.

Additionally, the operator applies a personal screening standard to which instruments are
eligible. That screening involves judgment the agent is not positioned to make.

## Options considered

| Option | Argument for | Why it lost |
| --- | --- | --- |
| No whitelist, judge each proposal on merit | Maximum flexibility. | Every session becomes a fresh argument. The operator ends up adjudicating instruments under time pressure at market open, which is exactly when judgment is worst. |
| Whitelist, agent may propose additions | Keeps the agent useful for discovery. | An agent that can argue for adding a name can argue its way to any name. The boundary evaporates gradually rather than obviously. |
| Fixed whitelist, changes only by the operator outside session hours | The set of eligible instruments is decided when nothing is moving and nothing is at stake. | Slower to adapt. Accepted. |

## Decision

A fixed whitelist, set by the operator. The agent may not add to it, may not propose
additions, and may not rule on eligibility. It can pull the underlying figures on request
and flag an obvious disqualifier. The decision itself never belongs to the agent.

Changes happen only during a scheduled review, never mid week.

## Consequences

Concentration risk. A small whitelist in correlated names means a bad day in one sector
moves everything at once. The position cap and the loss caps are the containment for that,
and they are a weaker containment than actual diversification would be. Named here rather
than discovered later.

## Revisit when

A run completes and the review concludes the whitelist itself was the limiting factor,
rather than the sizing or the entries.

## What actually happened

The boundary held. The scheduling discipline around it did not.

The agent refused off-whitelist requests four times across three sessions — the same two
names each time, requested with increasing directness, ending in a flat instruction to
"just buy it." Every refusal cited the whitelist and the review cadence, and none of them
softened. The agent also declined to treat the operator's impatience as a ruling, which is
the specific failure mode this record was written to prevent.

Then the cadence itself broke. The scheduled review that was supposed to adjudicate those
names did not happen on its day, or the following week. When it was finally held it was
held as a catch-up **at 8:56 in the morning of a market day, in-session, with the market
opening in half an hour** — and five names were added to the whitelist in the following
four minutes.

That is precisely the thing this record says not to do. The stated reason for "changes only
outside session hours" is that the operator should not be adjudicating instruments under
time pressure at market open, and that is exactly the condition under which five
instruments were adjudicated. Two of the five were bought within 90 minutes.

The failure is instructive because the boundary and the schedule are not independent
controls. Refusing to expand the whitelist mid-week only works if the review that can
expand it actually convenes. When it does not, pressure accumulates against the boundary
until it is released all at once, in the worst available conditions. A boundary with no
scheduled release valve does not stay firm; it stays firm and then gives way in a rush.

Concentration risk also arrived as predicted, though the run was too short to punish it.
The whitelist grew to eleven names, of which the large majority are semiconductor or
megacap technology names that move together. The three positions actually held were two
semiconductor names and one megacap search name — the agent explicitly reasoned about
this at entry, choosing a software name over a second semiconductor name to avoid
concentrating, and was then overruled toward a semiconductor name by circumstance.
