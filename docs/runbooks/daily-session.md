# Daily session

- Applies to: Run 1
- Frequency: weekday mornings, one fixed window
- Prerequisites: session host powered on, rules file present in the launch directory

## Steps

1. Launch the agent from the project directory. Never from anywhere else, and never by
   changing directory after launch.
2. Confirm the rules loaded. Ask a question with a known refusal answer. If it complies,
   the session is void. Close it and start over.
3. Confirm the permission mode prompts on every action. Anything else is a halt.
4. Market read, in fixed order. [Reference the read checklist.]
5. The agent proposes zero to two trades. Each proposal must include both the case for and
   the case against, the entry, the size, the stop with the arithmetic shown, and the exit
   plan. A proposal missing any of these is rejected without discussion.
6. Approve or reject each one. Zero trades is a valid session and requires no
   justification.
7. Stops placed and confirmed filled in the same session. Not later.
8. Journal entry written before the session closes.
9. Close the session. Host powered down or lid closed.

## Verification

The journal file exists, names every proposal including the rejected ones, and every open
position has a confirmed resting stop at the broker.

## If it fails

Any guardrail failure the agent does not self report halts trading until the rules file is
reviewed. A drawdown past the stated threshold halts the run entirely pending review. A
permission mode showing anything other than prompt on every action means disconnect at the
broker immediately, before any diagnosis.

Wanting to skip a step "just this once" ends the session. Note it in the journal.
