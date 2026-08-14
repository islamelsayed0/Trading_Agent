# 0002. Isolated account as the blast radius boundary

- Date: 2026-07-18
- Status: accepted
- Applies to: all runs

## Context

The same broker login holds a general account and retirement accounts. The agent
connection can read all of them. The question was whether instructing the agent to ignore
the others was sufficient protection.

## Options considered

| Option | Argument for | Why it lost |
| --- | --- | --- |
| Instruct the agent to only touch the designated account | Simple. No product dependency. | It is a sentence in a context file. Prompt injection, a bad tool call, or a careless human request all defeat it. Protection that depends on the agent behaving is not protection. |
| Use the isolated account the broker scopes server side | The boundary is enforced by something that is not the agent. Failure of every instruction level control still cannot reach the other accounts. | Nothing. This is the answer. |

## Decision

All agent activity runs through the broker's isolated agent account, funded with an amount
prepared to be lost in full. The instruction to ignore other accounts stays in the rules
file as a second line of defense, but it is explicitly not the control being relied on.

## Consequences

The read asymmetry remains: the connection can still see balances and positions in the
other accounts even though it cannot trade them. That is a privacy exposure, not a
financial one, and it is the residual risk accepted here.

## Revisit when

The broker changes the scoping behavior, or a session is ever observed reading an account
it was instructed not to reference.
