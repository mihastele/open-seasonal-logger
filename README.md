# Seasonal

> What am I exploring this season?

Seasonal is a small, local-first Flutter app for exploring one thing at a
time. It is deliberately **not** another productivity system: no XP, no
streaks, no scores, no dashboards. A season is successful if you genuinely
explored something, not only if you mastered it.

See [`MISSION.md`](MISSION.md) for the reasoning and [`AGENTS.md`](AGENTS.md)
for the constraints every change must obey.

## What v0.1 does

- One active season at a time, with a start date and a length in weeks.
- A home screen showing the current season, what's up next, and past seasons.
- Planning the next season creates a separate **upcoming** season; it never
  ends or overwrites the current one.
- A gentle local reminder five days before a season ends.
- An end-of-season reflection of exactly three optional questions:
  *What did I make? What did I learn? Do I want to return to this someday?*

Everything lives on-device. There is no account, no backend, no network call,
and no telemetry.

## Setup

Requires Flutter (developed against Flutter 3.47 / Dart 3.13). If Flutter is
not on your `PATH`, use its absolute path, e.g. `~/development/flutter/bin/flutter`.

```sh
flutter pub get
dart run build_runner build   # regenerate Drift code after schema changes
```

## Run

```sh
flutter run -d linux      # or -d android, -d ios
```

## Test

```sh
flutter test
flutter analyze
```

The tests encode the product principles, so they fail if a principle is
violated: the single-active-season invariant, the absence of scoring/streak/XP
fields in the schema, and the exactly-three reflection prompts.

## Project layout

```
lib/
  data/     Drift schema (AppDatabase) and SeasonRepository
  domain/   Pure season date math, free of Flutter and Drift
  services/ Local notifications
  ui/       Home screen, season screen, new-season sheet, theme
test/       Principle tests and widget tests
```
