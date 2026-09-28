# Mission

**Seasonal** is a small local-first app that answers exactly one question:

> **"What am I exploring this season?"**

That's it. It is deliberately **not** another productivity system.

## The problem

Curiosity is broad, but most tools treat it as a project to be optimized.
They turn hobbies into backlogs, learning into streaks, and exploration into
a dashboard that tells you your hobby efficiency dropped 17%. The result is
a permanent collection of abandoned Week-1 tutorials, plus guilt.

Seasonal gives curiosity a **temporary commitment and a natural stopping
point**. You pick one thing to explore, you explore it for a season, and the
season ends. You do not have to master it. You do not have to continue it.

## The philosophical rule

> **A season is successful if you genuinely explored something — not only if
> you mastered it.**

This is the rule every design and engineering decision is measured against.

## The core model

```text
Season
├── title: "Build a Tiny PLC"
├── description: "Learn embedded control by actually building one."
├── startDate: 2026-09-28
├── durationWeeks: 8
├── status: active | completed | upcoming
└── reflection?: "What did I make/learn?"
```

Reflections are captured as three optional guided fields, not an analytics
report:

- **What did I make?**
- **What did I learn?**
- **Do I want to return to this someday?**

## What the home screen does

```text
SEASONAL


🍂 CURRENT SEASON


Build a Tiny PLC


Week 3 of 8
████████░░░░░░░░░░  38%


Ends November 22


        [ Open Season ]


────────────────────


Up next
No season planned yet.


Past seasons ›
```

Approximately **5 days before a season ends**, Seasonal gently says:

> 🍂 Your season is ending soon.
> What would you like to explore next?

Choosing what's next **does not end or overwrite the current season**. It is
created as the upcoming season, which begins when the current one ends:

```text
Current
Sep 28 ─────────────── Nov 22
        Build a Tiny PLC


Upcoming
                       Nov 23 ───────────── Jan 17
                               Learn Swedish
```

At most one season is active at a time. Seasons are sequential.

## Scope of v0.1

Keep it **entirely local** so it can be genuinely *finished*:

- Flutter, one codebase
- Local database (Drift / SQLite)
- Local notifications
- No account, no backend, no network calls, no subscriptions

The goal is a small, complete app — not a 47-feature SaaS empire.
