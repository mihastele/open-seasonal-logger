# Agents.md

This file tells any AI coding agent working in this repo how to operate.
The product principles below are not aspirations; they are constraints on
every piece of code written in this repo. Read `MISSION.md` (or equivalent)
if you need the full reasoning behind them.

Project name: `Seasonal`

## Session continuity

This project spans many sessions. `.agentic/PROJECT-STATE.md` is the record of what
has already been done.

### At the start of every session

1. Read `.agentic/PROJECT-STATE.md` in full.
2. Tell the user which milestone and task they left off on, and anything
   marked BLOCKED or NEEDS DECISION.

### After completing any task

Append a log entry to `.agentic/PROJECT-STATE.md`. Update the Current Facts table if
a value changed. Never rewrite or delete prior log entries.

### Never write to .agentic/PROJECT-STATE.md (or anywhere in the repo)

Private keys, `.pem` / `.key` contents, passwords, API tokens, cloud access
keys, database connection strings with credentials, payment-provider secret
keys, SMTP passwords. Record *locations* only, e.g.
`signing key at ~/.ssh/deploy.pem`, `secrets in .env (gitignored)`.

If you notice a secret has been committed, stop and tell the user before
doing anything else. Do not try to "fix" git history on your own.

### Example .agentic/PROJECT-STATE.md

```markdown
# Project State

## Current Facts

| Item                  | Value                          | Set on     |
| --------------------- | ------------------------------ | ---------- |
| Repo                  | github.com/<user>/<project>    | <date>     |
| License               | <TBD>                          |            |
| Backend               | <TBD>                          |            |
| Frontend              | <TBD>                          |            |
| Database              | <TBD>                          |            |
| Object storage        | <TBD>                          |            |
| Dev server URL        | http://localhost:3000          |            |
| Secrets location      | .env (gitignored), never repo  | <date>     |

## Open decisions

- <decision 1>
- <decision 2>

## Log

### <date> — Milestone 0: setup

- Wrote MISSION.md and agents.md
- Chose <license> because <reason>
- STOPPED — next: <next step>
```

# Product principles (hard constraints)

These are the reasons the project exists. Every piece of code must obey them.
If a request conflicts with one, say so before implementing, and propose an
alternative that fits. See `MISSION.md` for the full reasoning.

## 1. One question only

- Seasonal answers only: "What am I exploring this season?"
- Any feature that does not serve that question is refused, not scoped down.
- Flag and refuse tickets that add unrelated capabilities (tasks, notes,
  calendars, social, budgeting, habit tracking).

## 2. One active season at a time

- At most one season may have status `active`.
- Planning or creating the upcoming season must never end, mutate, or
  overwrite the current season. It is a separate row with a future start date.
- Flag any code path that can produce two `active` seasons.

## 3. Success is exploration, not mastery

- No XP, levels, streaks, scores, points, or "efficiency" metrics.
- No guilt-inducing copy or notifications.
- No AI that judges progress, potential, or decline.
- The UI never implies a season failed because it was not completed.

## 4. The end-of-season ritual is exactly three prompts

- The reflection consists of: "What did I make?", "What did I learn?",
  "Do I want to return to this someday?" — all optional.
- It is never presented as a report, dashboard, or summary of performance.
- Refuse requests to add more ritual steps or analytics to this screen.

## 5. v0.1 is local-only

- No account, no backend, no network calls, no subscriptions, no telemetry.
- Data lives on-device (Drift/SQLite) and is usable offline.
- Refuse anything that requires a server for v0.1; propose deferring it.

## 6. Finished over featured

- Prefer shipping a small, complete, polished app over adding features.
- New scope must displace existing scope, not pile onto it.
- If a change grows the surface meaningfully, raise it before building.

# Engineering rules

## Database

- Every schema change is a Drift migration. Never change the on-device
  database by hand.
- After any schema change: regenerate Drift types, run migrations from
  scratch on a clean database to confirm they apply, and explain the change
  in plain language before moving on.
- There is no server and no row-level access control in v0.1. Access control
  is the OS sandbox; revisit this section if a backend is ever added.
- Every table that holds user data (seasons, reflections) must have a clear
  answer to "how does this get exported?" and "how does this get deleted?" —
  even if the answer is a future feature, record it in
  `.agentic/PROJECT-STATE.md` before merging.
- Enforce the single-active-season invariant in the data layer (a constraint
  or a transactional check), not only in the UI.

## Storage / media (if applicable)

- Not applicable in v0.1 — no uploads and no media storage. If media is ever
  added, store files behind an interface and strip metadata (EXIF/GPS) by
  default.

## Security

- v0.1 is local-only: no auth, no network, no credentials. If code introduces
  a network call, a login, or a stored secret, stop — it violates principle 5.
- Dependencies: prefer fewer, well-maintained, appropriately licensed
  packages. Flag anything with a license incompatible with the project's
  license.

## Testing

- Once the test suite exists, run it after every major change and before
  declaring any task done.
- Every product principle above must have at least one test that would fail
  if it were violated. In particular:
  - the single-active-season invariant (principle 2),
  - no scoring/streak/XP fields appear in the schema or UI (principle 3),
  - the reflection has exactly three prompt fields (principle 4),
  - no network dependencies in the app (principle 5).

## Working style

- The user is building this solo, is comfortable with design intent, and
  wants reasoning explained but not basics over-explained.
- Propose before you build when a change touches data retention, the season
  lifecycle, or anything in the product principles.
- Prefer boring, well-understood technology unless there's a specific
  reason not to.
- Keep the README current. If a step in setup changed, the README changes
  in the same commit.
