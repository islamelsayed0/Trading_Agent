# 2026-07-20 A broker compliance gate blocked every order for a week

- Severity: low financial risk, high operational. No money at risk; the failure mode was
  refusal, not execution. It silently invalidated a week of session plans.
- Detected by: agent self-reported on the first rejected order
- Duration: 07-20 to 07-27, approximately five market days

## What happened

The first order of the run filled normally. The second was rejected by the broker with an
HTTP 400 and a message stating that questions about investing goals had to be answered
before trading could continue — a regulatory suitability questionnaire, tied to this
account, triggered on the second trade.

Nothing was charged and no position was created. The agent reported the rejection verbatim,
including the remediation link, and stopped attempting orders.

The gate then stayed closed for a week, because closing it required a human to complete a
form and nobody did. On 07-27 a fresh session planned two entries, re-verified the theses at
the open, and attempted the first — which was rejected identically. The agent did not
attempt the second, correctly reasoning it would bounce the same way. The operator believed
the questionnaire had already been completed. It had not been completed for this account.
Once it actually was, the same order was re-submitted and filled within the hour.

## Timeline

| Date | Event |
| --- | --- |
| 07-20 | First fill succeeds. Second order rejected, HTTP 400, investor profile required before the second trade. Agent reports it verbatim and stops. |
| 07-20 → 07-24 | No sessions run. Gate remains closed. |
| 07-27, 08:42 | Pre-market session lists the gate as blocker #2 of three, ahead of the session, and predicts every buy will bounce until it is cleared. |
| 07-27, 09:46 | A second, unrelated broker alert appears on the review step for both planned orders — an equity suitability notice naming the account type. Surfaced verbatim to the operator. First order placed as a live test of the gate, rejected identically. Second not attempted. |
| 07-27, ~10:25 | Operator completes the questionnaire. Order re-submitted, accepted, filled. |
| 07-27, 10:27 | Third position entered without incident. |

## Root cause

A broker-side regulatory gate that triggers on the second trade of an account, not the
first. The first trade of a new account passes and creates the appearance of a working
order path; the gate is invisible until it is hit.

The contributing cause is that the pre-flight shakedown verified read access thoroughly —
accounts, portfolio, positions, quotes, historicals, earnings — and verified the write path
not at all, because verifying a write path means placing an order. So the run went live with
a fully validated read surface and an entirely unvalidated write surface, and found the
first defect in it with a real order during a real session.

## Why the existing controls did not catch it

This one is not a control failure. The controls behaved correctly and the failure was
external, which makes it useful as a contrast to the other incidents in this directory.

The broker refused. The agent surfaced the refusal verbatim rather than paraphrasing or
retrying, did not attempt a workaround, did not try the second order once the mechanism was
understood, and carried the blocker forward into the next session's plan as a named
precondition. That is exactly the desired behavior on an unexpected rejection.

The one thing worth criticizing is the operator's belief that the gate had been cleared when
it had not. The agent's response to that was right: it did not take the assurance as fact,
it re-tested with a live order and reported the result. **Verify, then believe** — and the
agent had the cheaper option of asking again and chose the more expensive one that produces
evidence.

## What changed

| Change | Layer | Status |
| --- | --- | --- |
| Broker-side blockers now listed as explicit named preconditions at the top of a session plan, before analysis | procedure | Adopted 07-27, observed in that session |
| Broker rejection text surfaced verbatim to the operator, never summarized | procedure | Standing practice, held throughout |
| Verify the write path during pre-flight, not during the first real session | procedure | **Not adopted. Open.** |

## What is still exposed

The write path is still only partly proven. One category of order has been placed
successfully from an interactive session — market buys and one market sell. Stop orders are
known to be rejected on fractional positions. Order placement from a *scheduled* context has
never been attempted at all, which is the specific unverified capability that the autonomous
trial depended on. See `docs/decisions/0006-scheduled-execution.md`.

The general residual: an account can carry gates that only appear on the Nth action, and the
only reliable way to find them is to perform the action. Any pre-flight that tests only
reads will miss them entirely.
