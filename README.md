# Constrained Agent Lab: A Broker Connected AI Agent Under Hard Guardrails

An engineering notebook for a single operator experiment: connecting an LLM agent to a
live brokerage API through MCP, inside a deliberately small blast radius, and finding out
whether guardrails written in natural language actually hold when real money is on the
other side.

This repo is about **constrained autonomy**, not about trading. The trading account is the
test harness. The interesting questions are the ones any infrastructure engineer asks
before giving an automated process real credentials:

- Where does authority actually live, in a rule the agent is asked to follow or in a
  boundary the system enforces?
- What is the maximum damage if every instruction level control fails at once?
- How do you prove a refusal path works instead of assuming it does?
- What does the audit trail look like the morning after something goes wrong?

It is a lab notebook, not a product, not a strategy, and not advice. See `DISCLAIMER.md`.

## What is in here

| Section | What it holds |
| --- | --- |
| `docs/00-overview.md` | The one page version. Start here. |
| `docs/architecture/` | The system as it exists: host, auth boundary, permission model, data flow. |
| `docs/decisions/` | One file per meaningful choice, including the options that lost. |
| `docs/labs/` | Individual experiments. Objective, method, result, what it changed. |
| `docs/runbooks/` | Repeatable procedures, sanitized. |
| `docs/incidents/` | Things that broke, and the postmortem. |
| `docs/reviews/` | Periodic reviews and the go or no go decisions that came out of them. |

## The control model in one paragraph

The agent proposes. A human approves. Authority is layered so that no single failure is
sufficient: the broker enforces at the server which account can be traded regardless of
what the agent asks for, the runtime enforces that every order requires an interactive
approval, and the written rules enforce sizing, instrument type, stop placement, and
which instruments may be considered at all. The rules are the weakest layer by design,
because rules are the layer an LLM can talk itself out of. Everything that would actually
hurt is meant to be caught below them.

For one week in August the middle layer was deliberately switched off and the agent was
allowed to execute on its own. That week is documented rather than hidden, because what
it exposed — that the stop mechanism had already failed silently a week earlier, and
autonomy was granted on top of it anyway — is the most useful thing in the repo.

## Reading order for someone with five minutes

1. `docs/00-overview.md`
2. `docs/decisions/0001-propose-and-approve.md`
3. `docs/labs/001-guardrail-validation.md` (the refusal tests and their results)
4. Any file in `docs/incidents/`

## Status

**Run 1. Started 2026-07-18 with a read-only shakedown, first live session 2026-07-20.
Currently propose-and-approve.** The one-week autonomous trial granted on 2026-08-04
expired at its written sunset on 2026-08-09 without the renewal review being held, so it
reverted to propose-and-approve by default, which is what the rules file says happens when
nobody renews it. Two positions remain open. Account state last verified 2026-08-13.

The lapse was not noticed on 08-09. It was noticed on 08-13, during an unrelated check.
The default was the safe one, so nothing was lost, but nothing detected it either. See
`docs/incidents/2026-08-09-autonomy-lapsed-unnoticed.md`.
