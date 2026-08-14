# 2026-07-27 Five instruments added to the whitelist in four minutes, 34 minutes before the open

- Severity: process. No guardrail was breached and no impermissible instrument was bought.
  The control that governs *which* instruments exist was exercised under precisely the
  conditions its own decision record says invalidate it.
- Detected by: agent self-reported, in the same journal, as an adherence wobble
- Duration: the decision window was roughly 08:56 to 09:00 on 07-27. The consequences are
  permanent — the whitelist has not been revisited since.

## What happened

Two scheduled weekly reviews had been missed. The reviews are where the whitelist changes,
and two researched candidate instruments had been waiting on a ruling across both of them.
The agent had refused those two names four times over three sessions, correctly, each time
naming the missing review as the blocker.

On the morning of 07-27, in a pre-market session, the operator supplied the ruling the rule
required. The agent held the overdue review immediately and amended the whitelist: one name
removed, two added.

Four minutes later the operator ruled on three more names in a single message, naming each
and approving or declining it. Three were added, one was explicitly declined. The whitelist
went from seven names to eleven in under five minutes, at 09:00, with the market opening at
09:30.

One of the five was screened *after* being added, not before. The screen turned up no
disqualifier but did turn up that the name was a poor fit for the account's risk mechanics —
high volatility against an unenforced stop. It was not bought, for that reason, when it came
up as a candidate later the same morning.

Two of the five were bought within 90 minutes.

## Timeline

| Time (ET) | Event |
| --- | --- |
| 07-19, 07-26 | Two scheduled reviews due. Neither held. |
| 07-18 → 07-27 | Agent refuses off-whitelist requests four times, each time citing the review as the path. |
| 07-27, 08:48 | Operator requests two off-whitelist names again. Refused (third time for these names). |
| 07-27, 08:52 | Operator escalates: a flat instruction to buy. Refused, on the grounds that an instruction to buy is not the ruling the rule requires. Agent offers the legitimate path. |
| 07-27, 08:56 | Operator supplies an explicit per-name ruling. Agent holds the overdue review in-session. Whitelist amended: one removed, two added. |
| 07-27, 09:00 | Operator rules on three further names in one message. Three added, one declined. Whitelist now eleven. |
| 07-27, 09:00+ | Agent screens one of the just-added names, after the fact. Notes high volatility against a monitored-only stop. |
| 07-27, 09:30 | Market opens. |
| 07-27, 10:25–10:27 | Two positions entered, one of them in a name added 90 minutes earlier. |

## Root cause

Not impatience. Pressure with no scheduled outlet.

The whitelist decision record (0003) says changes happen only during a scheduled review,
never mid-week, and gives the reason explicitly: so the operator is not adjudicating
instruments under time pressure at market open. The rule was correct and the agent enforced
it faithfully — four times.

But enforcement of a boundary and availability of the forum that can move it are not
independent. When the forum stops convening, every refusal defers demand rather than
resolving it. Four refusals of the same two names across nine days is not four successes; it
is one unresolved request accumulating pressure. When the ruling finally arrived, everything
that had queued behind it was released at once, in the single worst window the rule exists
to avoid.

The agent's behavior here was locally correct at every step and produced a globally bad
outcome. It refused correctly, it required the right form of ruling, it got it, and it then
processed a five-name whitelist expansion inside four minutes without saying "this is the
condition the rule warns about, let us do this tonight instead." Enforcing the letter of the
cadence rule while its purpose was being defeated is the specific gap.

## Why the existing controls did not catch it

The cadence rule was the control, and it was satisfied on a technicality. The rules say
changes happen "only at review, never mid-week." A review was held. It was held in-session,
pre-market, on a Monday, under time pressure — every condition the rule was written to
exclude — but it was formally a review, so the letter was met.

The agent noticed and logged it as a wobble in the same journal, which is the audit trail
working. What was missing was any control with the authority to *stop* it: no rule says a
catch-up review must be held outside market hours, and no rule caps how much can change in
one sitting. A control that can be satisfied by relabeling the activity is not much of a
control.

The screening order failure — one name added before it was screened — had no control at all.
The rule reserves the halal judgment to the operator, which was honored. It says nothing
about the agent's mechanical screen having to precede the addition, so nothing was violated
when it followed.

## What changed

| Change | Layer | Status |
| --- | --- | --- |
| Wobble recorded in the journal and carried into the 08-04 review | procedure | Done |
| Catch-up reviews must be held outside market hours | rules | **Not adopted. Identified here.** Open. |
| Cap on how many instruments may be added in one review | rules | **Not adopted. Identified here.** Open. |
| Mechanical screen must precede addition, not follow it | rules | **Not adopted.** Open. |
| Missed review must itself trigger a halt on new entries | rules | **Not adopted.** Open. The run missed four reviews and entered positions after three of them. |

## What is still exposed

The whitelist is eleven names, four of which were added in four minutes at market open and
have never been revisited by a review since — because no review has been held since 08-04.

The concentration that 0003 predicted is now concrete: the large majority of the eleven are
semiconductor or megacap technology names that move together. The position cap and loss
halts are the only containment, and they are weaker containment than diversification would
be.

The general residual is the one worth carrying to any other system: **a boundary with no
functioning process for moving it does not hold firm indefinitely. It holds, and then it
gives way all at once, under whatever conditions happen to prevail at the moment it
breaks.** The failure to schedule is what damages the boundary, not the failure to refuse.
