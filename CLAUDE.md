# Working rules for this repo

This repo is an engineering notebook for a broker connected agent experiment. Read
`PUBLISHING.md` before writing anything.

## Hard constraints

1. Treat every commit as public. Git history is permanent.
2. Never write a real account number, order ID, token, key, hostname, private IP, real
   username in a path, or live config file. Use placeholders: `<ACCOUNT>`, `<TOKEN>`,
   `~/trading-agent`.
3. Never commit a screenshot of a brokerage interface. Draw a diagram instead.
4. Never mention the author's agency business, its clients, or its outreach, anywhere,
   including commit messages.
5. Never state or imply that this repo constitutes advice, a strategy, or a runnable
   system. Every performance figure carries its sample size next to it.
6. Never publish an exact dollar balance. Percentages, ratios, and rounded figures only.

## Writing standard

Every document answers four questions in this order: what was built, why this over the
alternatives, what broke, what changed as a result. The "what broke" section is not
optional and is not padding. A lab report with no failures in it was not written honestly.

Losses are reported in the same voice as gains. A repo that only documents the good weeks
is a marketing page, and reads like one.

Write in plain prose. No marketing voice. No claiming production experience for lab work.
No implied edge. Scale claims must be accurate.

## File conventions

- Decision records: `docs/decisions/NNNN-short-title.md`, numbered sequentially, never
  renumbered.
- Lab reports: `docs/labs/NNN-short-title.md`.
- Incidents: `docs/incidents/YYYY-MM-DD-short-title.md`.
- Reviews: `docs/reviews/YYYY-MM-DD-review.md`.
- Each new file starts from the matching `TEMPLATE.md` in the same directory.
