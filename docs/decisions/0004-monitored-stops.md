# 0004. Monitored stop levels after resting stops proved impossible

- Date: 2026-07-20, decided pre-market, exercised the same morning
- Status: accepted under protest; the rules file still contradicts it
- Applies to: Run 1, every position

## Context

The rules file requires a stop order placed in the same session as the entry, sized at 1.5
× ATR(14), never widened afterward. It also says, in the same rule: **if a stop cannot be
placed, exit the position.**

The per-order cap was set below the price of one share of every name on the whitelist. Every
position the account can afford is therefore fractional. On the first live session, after
the first fill, two attempts to place the stop were rejected by the broker — one citing an
invalid time in force for a fractional order, the second, with the time in force corrected,
citing an invalid trigger for a fractional order.

The second rejection is the one that mattered. It established that this was not a parameter
mistake. Fractional positions cannot carry resting stop orders at all. Combined with the
per-order cap, that means no position this account can hold can ever have a real stop.

A risk control had been silently voided by an unrelated sizing decision. Nobody designed
that. It emerged from two rules that were individually reasonable.

## Options considered

| Option | Argument for | Why it lost |
| --- | --- | --- |
| Follow Rule 4 literally: exit the position, and take no further positions | The rule is unambiguous and it is the conservative reading. It also correctly implies the account cannot trade under its own constraints. | Ends the experiment on day one over a mechanical detail, before any of the questions the run was built to answer had been touched. |
| Raise the per-order cap so whole shares are affordable, restoring real stops | Fixes the actual cause. Stops become enforced by the broker rather than by attention. | Requires a rule change mid-week, which another rule forbids. Also raises per-position size by roughly an order of magnitude on the cheapest eligible name, and much more on the rest — a large increase in real exposure to fix a control problem. |
| Monitored stop levels: record the price, check it every session, exit on breach | Keeps the run alive. Preserves the arithmetic and the discipline of sizing risk off ATR. | It is not a stop. It is a note in a file. It protects nothing between sessions and depends entirely on somebody running a session. |

## Decision

Monitored stop levels. The ATR arithmetic is still computed, still written down, still
trailed upward and never widened. It is simply not enforced by anything except the next
session happening.

The operator chose this pre-market on 07-20, before the failure occurred, as a
contingency — "attempt a real stop, fall back to monitored if the broker refuses." The
broker refused within the hour.

## Consequences

**The rules file is now internally contradictory and was left that way for the entire run.**
Rule 4 says to exit a position that cannot carry a stop. Standing practice was to hold
three such positions. Both cannot be true. This was flagged for reconciliation at the next
review, which did not happen, and then the next, which also did not happen. It is still
unreconciled.

Overnight and weekend gap risk is unhedged and permanent. Every position in this account
has been exposed to it continuously since 07-20.

The cost was paid on 07-28. A monitored stop was breached, and breached again the next
session, closing below the level — and nothing happened, because nobody ran a session for
five market days. The position recovered and the outcome was a small gain. That is luck.
The control failed exactly as this record predicted it could, and the only reason it did
not cost anything is that the market came back.

The deeper consequence is one the run demonstrated rather than argued: **a control whose
enforcement depends on a human showing up is not a control, it is a plan.** The distinction
was legible on paper on 07-20 and was not taken seriously enough until it failed.

## Revisit when

Immediately. This is the open item that should gate everything else. The two real fixes are
a per-order cap that permits whole shares, or scheduled execution reliable enough that the
monitoring actually occurs. The run attempted the second and never completed it. See 0006.
