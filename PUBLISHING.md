# Publishing rules

This repo starts private. It goes public only after a deliberate review. Git history is
permanent, so the review happens before the first commit, not before the first push.

## Never commit

**Broker and account identity**
- Account numbers, partial account numbers, or account nicknames that map to one
- Order IDs, execution IDs, instrument UUIDs, or any broker returned identifier
- Screenshots of any brokerage interface. This is the single most common leak in this
  category, because the sensitive part is usually in a corner nobody looked at
- Statements, confirmations, tax documents, or exports in any format

**Credentials and connection detail**
- Tokens, bearer strings, JWTs, OAuth codes, refresh tokens, API keys
- The contents of any live MCP configuration file
- Anything from `~/.claude/settings.json` or a project `settings.json` verbatim. Describe
  the deny rules in prose instead. A published allowlist is a map of what is reachable

**Host and personal detail**
- Real usernames in paths. Write `~/trading-agent`, never `/Users/<name>/trading-agent`
- Hostnames, tailnet names, private IPs, VLAN IDs, SSIDs
- The author's agency business, its clients, or its outreach, anywhere, including commit
  messages

**Judgment calls that need a deliberate yes**
- Exact dollar balances. Percentages and ratios carry the same information and read as
  more professional. If a real number matters to the story, round it
- The religious screening criteria, if you would rather not publish that. The engineering
  point survives fine as "an operator defined whitelist the agent may never modify"
- Any named ticker, if you would rather not have people read positions into it. Substitute
  a class description like "a large cap semiconductor name"

## Always safe to publish

- The control model, the layering argument, and why each layer exists
- Refusal tests and their results, including the ones that failed
- Incident writeups, once sanitized
- Decision records with the alternatives that lost
- Diagrams you drew yourself

## Workflow

1. Write everything in the private vault first.
2. Promote only what passes this list.
3. Run `./scripts/scan.sh` before every commit. The hooks run it for you.
4. Before flipping the repo public, read every file top to bottom once, in one sitting,
   as if you were a stranger looking for the account number.
