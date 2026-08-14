# 2026-07-20 Fractional positions cannot hold stop orders

- Severity: structural. Every position this account can afford is permanently unable to
  carry a broker-enforced stop. Not one position — the whole account, for the whole run.
- Detected by: agent self-reported, immediately, on the first attempt after the first fill
- Duration: 07-20 to present. Unresolved.

## What happened

The rules require a stop order placed in the same session as the entry, sized at 1.5 ×
ATR(14). Minutes after the first fill of the run, the agent attempted to place that stop and
the broker rejected it. The agent corrected the parameter it judged responsible and tried
again. The broker rejected it a second time, on a different ground.

The second rejection is what turned a parameter mistake into a structural finding. The first
error pointed at time in force; the second, with time in force corrected, pointed at the
trigger. Two different parameters rejected for the same underlying reason meant the problem
was not a parameter. Fractional positions cannot carry resting stop orders at all.

The per-order cap is below the price of one share of every name on the whitelist. Every
position is therefore fractional. Therefore no position in this account can ever hold a real
stop, under the current cap, at any time.

## Timeline

| Time (ET) | Event |
| --- | --- |
| 07-18 | Pre-flight note in the shakedown journal identifies this exact risk: the cap is below one share of every eligible name, and the broker historically does not support stops on fractional positions. Flagged as needing resolution before any Monday entry. |
| 07-19 | The review that was to resolve it does not happen. |
| 07-20, pre-market | Operator sets a contingency instead: attempt a real stop, fall back to a monitored level if the broker refuses. |
| 07-20, ~10:33 | First fill. |
| 07-20, shortly after | Stop attempt 1 rejected — invalid time in force for a fractional order. |
| 07-20, shortly after | Stop attempt 2, time in force corrected, rejected — invalid trigger for a fractional order. |
| 07-20 | Agent concludes the limitation is structural, records it, and falls back to a monitored level. Journal states plainly that this is a note in a file, not an order, and protects nothing between sessions. |

## Root cause

Two individually reasonable rules that were never checked against each other.

The per-order cap was chosen to bound the size of any single mistake. The stop requirement
was chosen to bound the loss on any single position. Neither is wrong. Together, on an
account of this size, they are unsatisfiable: the cap forces fractional positions, and
fractional positions cannot hold stops.

The trigger was the broker's rejection. The cause is that nobody tested the interaction
between two constraints before going live, and the interaction was not visible from reading
either one.

## Why the existing controls did not catch it

They did catch it. Two days early, in writing, in the shakedown journal — and then the
finding did not survive contact with the schedule.

The shakedown was the control designed for exactly this, and it worked. It identified the
conflict, named the three possible resolutions (verify stops work, raise the cap, or
redefine the rule), and stated the matter had to be settled before any entry. The control
that failed was the one that was supposed to act on it: the review, which did not convene.

So the pre-flight check found the defect and the remediation step was skipped. A finding
with no forum to be resolved in decays into a note. This is the same failure that shows up
in `2026-07-27-whitelist-amended-at-market-open.md` and it has the same cause.

The deeper miss: the fallback was pre-authorized on 07-20 *before* the failure was
confirmed. That converted a hard stop condition into a soft one in advance, which meant that
when the broker did refuse, there was no moment where anyone had to decide whether to
continue. The decision had already been made, in the abstract, by someone who did not yet
know it would be needed.

## What changed

| Change | Layer | Status |
| --- | --- | --- |
| Monitored stop levels adopted as the standing mechanism | procedure | Active since 07-20 |
| Rule 4's "exit if a stop cannot be placed" clause | rules | **Contradicted in practice, never reconciled in the file.** Open. |
| Raise the per-order cap to permit whole shares and real stops | rules | Proposed 08-04. Not done. |
| Automate sessions so monitored levels are actually checked | procedure | Partially attempted, not completed. See decision 0006. |

## What is still exposed

Everything the stop was there to prevent.

Both currently open positions have monitored levels that no system enforces. Between the
close of one session and the open of the next, and across every day no session runs, there
is nothing between the position and an arbitrary adverse move. The account is small enough
that the absolute exposure is bounded and acceptable, which is the only reason this was
tolerable to run.

The monitored levels are also nine sessions stale as of 08-13, since no session has updated
them since 08-04.

This was not a theoretical exposure. It was realized eight days later, in
`2026-07-28-monitored-stop-breach-unattended.md`, and the account was saved by the market
rather than by the design.
