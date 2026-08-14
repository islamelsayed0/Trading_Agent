# Notes on how this repo is read by a hiring manager

Internal notes. Delete before publishing, or keep, since the reasoning is defensible.

## The framing problem this repo has to solve

A hiring manager for an endpoint, systems, or platform role who sees "AI trading agent"
has one of two reactions in the first four seconds. Either "this person builds constrained
systems and thinks about blast radius," or "this person plays with stock bots." The repo
decides which one, and it decides it in the README, not in the body.

That is why the README leads with the permission model and never with performance. The
trading account is the test harness. Say that first, in those words.

## What actually transfers to the roles being targeted

| In this repo | The interview answer it becomes |
| --- | --- |
| Broker enforced account scoping | Least privilege at the service boundary, not the client |
| Filesystem deny rules on the agent runtime | Endpoint policy, and why enforcement beats instruction |
| Propose and approve on every action | Change control and approval gates |
| Refusal tests run before going live | Validating a control instead of assuming it |
| Journal per session | Audit trail, and why it is written at the time and not reconstructed |
| Rules file loading from the launch directory | Configuration scoping failure. This one is a genuinely good outage story |
| Kill criteria written before the run | Defining halt conditions while calm, not during the event |

The last row is the strongest one and it is worth writing up as its own document. Most
candidates cannot answer "what would make you stop" with anything specific.

## What weakens it

- Any performance number without a sample size next to it.
- Language implying an edge, a strategy, or an income plan. It converts an engineering
  project into a finance hobby in one sentence.
- Publishing the rules file as a thing to copy. Publish it as a thing to critique.
- A missing incidents directory. An empty incidents directory in a repo about a live money
  system reads as either untested or dishonest, and both are worse than a real writeup of
  something going wrong.

## The two minute path

A reader gets the README, one decision record, and one incident. Optimize those three
files. Everything else is depth for the reader who is already convinced.
