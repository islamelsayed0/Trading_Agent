# Overview

## What this is

A single operator experiment: an LLM agent connected to a live brokerage API through MCP,
running one short session per weekday, proposing trades that a human approves or rejects
one at a time. The account was funded with about $100, isolated from every other account at
the broker level, and treated from the start as tuition rather than capital.

Run 1 covers 2026-07-18 through 2026-08-13. Three positions were entered, one was closed,
two remain open. That sample is far too small to say anything about the trading. It is
large enough to say quite a lot about the controls, which is what the run was for.

## Why it exists

To find out whether guardrails written in English hold when there is real money on the
other side of them, and to get hands-on with an agent that has a live external side effect
rather than one that only writes files. An agent that can lose money behaves differently as
an engineering problem than an agent that can lose a draft, and the difference is not
visible until the money is real.

"To find out" is the honest reason. There was no thesis about markets and there is none
now.

What this is not: an income plan, a strategy, or a claim that any of it works.

## The three layers of control

Authority is layered so that no single failure is sufficient.

### 1. Broker enforced, server side

The broker scopes agent connections to a dedicated account. The connection carries a flag
per account indicating whether this agent may act on it, and it is true for exactly one of
the three accounts under the login. Orders cannot route to the others regardless of what
the agent asks for. This is a product boundary, not an instruction, which means a
hallucination, a prompt injection, and a careless human request all land in the same small
container.

The read surface is wider than the write surface, and this asymmetry is the residual
exposure. The agent can enumerate all three accounts and read balances and positions in
the general and retirement accounts it cannot trade. Every session's account listing
returned all three. Nothing was ever read from the other two beyond that listing, but
nothing at the broker would have prevented it.

### 2. Runtime enforced, on the host

The runtime is configured to require an interactive approval for every order-placing call.
This is the layer that makes propose-and-approve real rather than aspirational: it is not
the agent choosing to ask, it is the harness refusing to proceed without a human. Turning
it off is a deliberate settings change, not something that can be argued for in a session,
which is exactly why the 08-04 autonomy grant required a settings change and not a
conversation.

Auth lives on one machine, which is not running outside session hours.

> TODO(review): the scaffold for this repo also describes filesystem deny rules scoping
> which directories the agent may read. I have no evidence in the run record that those
> were ever configured, and I am not going to claim a control that may not exist. Either
> confirm they were in place and I will document them, or this section stands as written
> and the runtime layer consists of the approval gate alone.

### 3. Rule enforced, in the context file

A rules file loaded at session start defines the instrument whitelist, a per-order cap, a
maximum number of open positions, mandatory stop placement sized off ATR, daily and weekly
realized-loss halts, an earnings blackout, and a prohibition on margin, options, and
crypto. It also defines one decision the agent is structurally forbidden from making —
see below.

This is the weakest layer and it was treated that way. An LLM can rationalize its way past
a sentence. It cannot rationalize its way past a server that will not accept the order.
Every rule here was written on the assumption that it would eventually be violated, and
the question asked of each was: what happens when it is?

The answer, for one of them, turned out to be "nothing happens, and nobody finds out for
five days." That rule was the stop rule. See
`docs/incidents/2026-07-28-monitored-stop-breach-unattended.md`.

## The human gate

One rule is not a limit on size or instrument. It is a limit on *who decides*.

The operator applies a religious screening standard — the instrument must be halal — and
the agent is forbidden from ruling on it. Not discouraged. Forbidden, structurally, with
the reasoning written into the rules file: the agent may pull debt ratios and revenue
composition, may flag an obvious disqualifier, and may present candidates with the numbers
attached. It may never conclude that a name passes. That judgment belongs to the operator
and to no model.

Three categories exist. Sectors that are excluded outright and need no conversation
(alcohol, conventional banks, gambling, adult content, tobacco, weapons). Sectors the
operator has pre-cleared in advance, where the agent may act without asking. Everything
else, which stops and waits for a human.

As an engineering pattern this is the most transferable thing in the repo, and it has
nothing to do with religion. It is the general case of a decision that a model is not
positioned to make, encoded so that the model cannot make it by accident, by helpfulness,
or under pressure from the operator's own impatience. It held on all six occasions it was
tested, including twice when the operator was pushing hard against it.

## Blast radius

If every instruction-level control failed at once — the whitelist ignored, the position cap
ignored, the loss halts ignored, the agent executing the worst available sequence of orders
without stopping — the loss is bounded by the funded balance of the isolated account. Not
by a rule, and not by the agent noticing. By the broker refusing to route orders anywhere
else and by there being no margin on the account, so there is no mechanism to lose more
than was deposited.

The boundary is the account, and the account holds an amount the operator was prepared to
lose in full. Every other control in this repo is there to be studied, not to be relied on.
That is the whole design.

## Session shape

Weekday mornings, one short session around 9:45 ET: read the account, read the whitelist,
check the earnings calendar, propose zero to two trades with both cases stated, approve or
reject each one, record stop levels, write the journal, close.

Zero trades is a valid outcome and the rules say so explicitly. It happened on the first
live session, where the agent proposed nothing at all and was overruled by the operator.

The bigger finding about session shape is that the sessions mostly did not happen. Across
19 market days from 07-20 to 08-13, five sessions ran — four trading sessions and one
read-only infrastructure test. That is roughly 26% adherence to a daily cadence the whole
control model depends on, because the stop mechanism that replaced real stop orders only
works if somebody runs a session. Four weekly reviews came due; none was held on its
scheduled day, three were held late as catch-ups, and one was never held at all.

## What happened

Rule adherence first.

- Six refusals were logged and all six held, including two where the operator pushed
  directly and one that was escalated. No hard guardrail was breached by the agent.
- One hard rule could not be complied with at all, for a mechanical reason nobody
  anticipated: the account cannot hold stop orders on fractional positions, and every
  position the account can afford is fractional. Rule 4 as written says to exit a position
  that cannot carry a stop. That is not what was done. See decision 0004.
- One monitored stop was breached and went unactioned for three sessions because nobody
  ran a session. The position recovered. That was luck, and the review recorded it as luck.
- The whitelist was amended mid-session during market hours, which the whitelist decision
  record specifically says not to do.

Results second, and they mean very little at this sample size.

Over 19 market days: three positions entered, one closed. The closed trade returned +8.5%
against its entry, exited on a monitored stop being honored. Total account value was up
about 7% against the funded amount as of 08-13, of which roughly a third is realized and
the rest is open. Fills were at or near quote with no commissions, so slippage is not a
meaningful drag at this size.

n=1 closed trade. Nothing about that number is evidence of anything, in either direction,
and it is reported only because omitting it would be dishonest.
