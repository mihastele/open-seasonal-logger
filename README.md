# Seasonal

> What am I exploring this season?

Seasonal is a small, local-first Flutter app for exploring one thing at a
time. It is deliberately **not** another productivity system: no XP, no
streaks, no scores, no dashboards. A season is successful if you genuinely
explored something, not only if you mastered it.

See [`MISSION.md`](MISSION.md) for the reasoning and [`AGENTS.md`](AGENTS.md)
for the constraints every change must obey. [`brand/BRAND.md`](brand/BRAND.md)
holds the palette, logo, and voice guidelines. The marketing/story site lives
in [`site/`](site/README.md).

## What v0.1 does

- One active season at a time, with a start date and a length in weeks.
- A home screen showing the current season, what's up next, and past seasons.
- Up to two upcoming seasons can be planned ahead. When one active plus two
  future seasons exist, the "New season" button disappears until a slot
  frees up. Creating fills the first gap in the timeline, so a deleted middle
  season can be replaced in place.
- Swipe any current or upcoming season to reveal edit (amber pencil) and
  delete (bark trash, with a confirm dialog) actions. Edit updates the
  existing season; delete permanently removes it and its reflection.
- A single, user-timed reminder five (or 1/3/7) days before a season ends, at
  a time you choose, switchable off entirely. Not a recurring habit schedule.
- An end-of-season reflection of exactly three optional questions:
  *What did I make? What did I learn? Do I want to return to this someday?*
- A "Buy me a coffee" link at the foot of the home screen
  (`buymeacoffee.com/mihastele`), shown by default. It uses the Seasonal
  palette, not the Buy-Me-a-Coffee yellow, and can be hidden inline or from
  Settings; your choice is remembered.

Everything lives on-device. There is no account, no backend, no network call,
and no telemetry. The coffee link only hands a URL to the system browser; the
app itself never makes a network request.

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
brand/
  BRAND.md        palette, logo, and voice guidelines
  logo/           mark.svg, lockup.svg
  icons/          rendered app icons
  render-icons.sh regenerate icons from icon.svg (needs rsvg-convert)
site/             static story/brand website (no build step)
lib/
  brand/    palette and the vector SeasonalMark widget
  data/     Drift schema, SeasonRepository, ReminderRepository, SupportRepository
  domain/   Pure season date math and timeline rules (no Flutter/Drift)
  services/ Local notifications
  ui/       Home screen, season screen, new/edit sheet, settings, support footer
test/       Principle tests, timeline/repository tests, migration, widgets
```
