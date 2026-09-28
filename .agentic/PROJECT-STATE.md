# Project State

## Current Facts

| Item                  | Value                                | Set on     |
| --------------------- | ------------------------------------ | ---------- |
| Repo                  | Not yet created                      | 2026-09-28 |
| License               | TBD                                  |            |
| Frontend              | Flutter 3.47.5 / Dart 3.13.4         | 2026-09-28 |
| Database              | Drift / SQLite (on-device), schema v4 | 2026-09-28 |
| Backend               | None — v0.1 is local-only            | 2026-09-28 |
| Object storage        | None — v0.1 has no uploads/media     | 2026-09-28 |
| Notifications         | Local only, one reminder, user-timed | 2026-09-28 |
| Brand                 | brand/BRAND.md, logo/mark.svg        | 2026-09-28 |
| Static site           | site/ (no build step)                | 2026-09-28 |
| Icon tooling          | brand/render-icons.sh (rsvg-convert) | 2026-09-28 |
| Secrets location      | None yet (no secrets in v0.1)        | 2026-09-28 |
| Test command          | `flutter test`                       | 2026-09-28 |
| Analyze command       | `flutter analyze`                    | 2026-09-28 |

## Open decisions

- License (TBD).
- Whether "Up next" allows a single upcoming season only, or a queue of
  upcoming seasons. Diagram implies one upcoming; confirm at build time.
- Export / delete design: recorded as required by AGENTS.md, not yet designed.
  Proposed: export season + reflections to Markdown/JSON; delete per-season.
- Reminder scope (resolved 2026-09-28): user requested recurring
  daily/weekly/custom. Built as ONE user-timed season-end reminder instead,
  because recurring daily/weekly notifications conflict with principle 3.
  Recorded here so the decision is explicit; revisit only with the user.
- Git repo initialized (`git init`, commit `4d94c97 init`). No remote yet.

## Log

### 2026-09-28 — Milestone 0: setup

- Wrote `MISSION.md`: one question, the "exploration not mastery" rule,
  the core Season model, and local-only v0.1 scope.
- Replaced the `AGENTS.md` template with six concrete product principles:
  one question only; one active season at a time; success is exploration;
  exactly three reflection prompts; v0.1 local-only; finished over featured.
- Rewrote engineering rules for the local-only Flutter/Drift reality
  (no server access control, Drift migrations, principle-test requirements).
- Decisions confirmed by user:
  - Storage: Drift (SQLite).
  - Seasons are sequential; at most one active.
  - Reflection stored as three optional guided fields.
  - End-of-season notification fires 5 days before the end.
- STOPPED — next: scaffold the Flutter project and define the Drift schema
  (`Seasons` table, `SeasonStatus` enum, single-active invariant), then build
  the read-only home screen from the mission sketch. Awaiting license choice.

### 2026-09-28 — Milestone 1: first working build

- Scaffolded the Flutter app at the repo root (project `seasonal`, org
  `com.seasonal`, platforms linux/android/ios). Flutter 3.47.5 / Dart 3.13.4
  at `~/development/flutter` (not on PATH).
- Dependencies: `drift`, `drift_flutter`, `flutter_local_notifications`,
  `intl`, `timezone`, `flutter_timezone`; dev: `drift_dev`, `build_runner`.
- Data layer (`lib/data/`):
  - `Seasons` table with title, description, startDate, durationWeeks,
    `status`, and exactly three nullable reflection fields.
  - `SeasonStatus` enum: upcoming / active / completed.
  - Single-active-season invariant enforced in the data layer by a partial
    unique index (`CREATE UNIQUE INDEX ... ON seasons((1)) WHERE status =
    'active'`) plus transactional checks in `SeasonRepository`.
  - `SeasonRepository` supports create (upcoming never touches the current
    season), save reflection, complete, and start upcoming.
- Domain (`lib/domain/season_math.dart`): pure week/progress/end-date math.
  Uses calendar arithmetic so DST cannot shift an end date.
- Services: one local notification, `inexactAllowWhileIdle`, fired 5 days
  before the season ends. Init is wrapped so unsupported/test platforms are
  safe. No network anywhere.
- UI (`lib/ui/`): home screen, season screen with the three-prompt reflection,
  and a new-season sheet. Wording avoids guilt and any failure framing.
- Tests: 15 passing (`flutter test`), `flutter analyze` clean.
  - principle 2 (data layer + raw insert + planning doesn't touch current),
  - principle 3 (no score/streak/XP/etc. columns),
  - principle 4 (exactly three reflection fields, and three fields in UI).
- `flutter build bundle` succeeds. A native Linux build cannot link here yet:
  `pkg-config` and GTK3 are not installed on this machine. Not a code issue.
- README rewritten with setup, run, test, and layout.
- Notes for future sessions: test databases use
  `closeStreamsSynchronously: true` (`test/test_database.dart`) and Drift
  streams must not be `.first`-awaited inside widget tests — use one-shot
  repository reads instead.
- STOPPED — next: run `flutter run -d linux` once GTK3/pkg-config are present
  to eyeball the UI; then decide remaining M0 open decisions (license;
  whether more than one upcoming season is allowed). No schema change pending.

### 2026-09-28 — Android build fix

- First Android debug run failed: `:app:checkDebugAarMetadata` reported that
  `:flutter_local_notifications` requires core library desugaring.
- Fix in `android/app/build.gradle.kts`:
  - `compileOptions { isCoreLibraryDesugaringEnabled = true }`
  - `dependencies { coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4") }`
- Added `POST_NOTIFICATIONS` to `AndroidManifest.xml` and a runtime permission
  request (`_requestPermission` in `lib/services/season_notifications.dart`,
  Android + iOS) so the reminder can actually display on Android 13+.
- `flutter build apk --debug` now succeeds. A KGP warning about
  `flutter_timezone` remains (deprecation notice from Flutter, not an error).
- STOPPED — next: install/run on the device and eyeball the UI; then the same
  remaining open decisions (license; number of upcoming seasons).

### 2026-09-28 — Branding, website, and reminder settings

- Brand: created `brand/BRAND.md` (palette, mark, type, voice, do/don't copy)
  and `brand/logo/mark.svg` — a brush tip that has painted a leaf — plus
  `brand/logo/lockup.svg` (mark + SEASONAL wordmark).
- Icons: `brand/icons/icon.svg` and `brand/render-icons.sh` render the Android
  and iOS app icons with `rsvg-convert`. App display name set to "Seasonal"
  (Android label, iOS `CFBundleDisplayName`, Linux window title).
- In-app branding: `lib/brand/palette.dart` (SeasonalColors),
  `lib/brand/seasonal_mark.dart` (vector mark widget, no asset bundle), theme
  rewritten to the palette, home header now shows the mark + a settings button.
- Website: `site/` is a static, dependency-free site (index.html, styles.css,
  assets) that tells the product story and shows the palette. `site/README.md`
  documents serving/deploying. No JavaScript, no external requests, dark mode
  via `prefers-color-scheme`.
- Reminders (SCHEMA CHANGE, v1 -> v2):
  - New `ReminderSettings` single-row table: `enabled`, `daysBeforeEnd`,
    `timeOfDayMinutes`.
  - Migration in `AppDatabase` (`schemaVersion => 2`): `onUpgrade` creates and
    seeds the table and recreates the invariant indexes with `IF NOT EXISTS`.
  - `ReminderRepository` (watch/get/save). `AppDependencies.rescheduleReminder`
    is the single place that (re)schedules from settings + active season.
  - `SettingsScreen` (gear on home) lets the user toggle the reminder, choose
    1/3/5/7 days before the end, and pick a time.
  - DECISION: the user asked for recurring daily/weekly/custom notifications.
    Built as ONE user-timed season-end reminder instead, because a recurring
    habit schedule conflicts with principle 3. Recorded in Open decisions.
- Tests: 19 passing. Added `reminder_test.dart` (defaults, save/read,
  no streak/cadence columns) and `migration_test.dart` (real v1 DB upgrades to
  v2, keeps seasons, seeds settings, keeps the single-active invariant).
  `flutter analyze` clean.
- `sqlite3` added as a dev dependency for the migration test.
- STOPPED — next: run on device to eyeball branding + settings; remaining open
  decisions (license, upcoming-season count, export/delete).

### 2026-09-28 — Logo redesign: brush reads as a brush

- The first mark (a leaf-shaped brush) did not read as a paintbrush. Redesigned
  the mark: a tilted paintbrush (handle, ribbed metal ferrule, bristles
  tapering to a point) leaving a fresh tapering stroke of paint.
- Updated `brand/logo/mark.svg`, `brand/logo/lockup.svg`,
  `brand/icons/icon.svg`, and regenerated all Android/iOS icons and the
  standalone `brand/icons/icon-*.png`.
- Rewrote `lib/brand/seasonal_mark.dart` to draw the new mark as a vector;
  verified the Flutter render matches the SVG by rasterizing it in a throwaway
  test (since removed).
- Synced `site/assets/` and updated the mark description in `brand/BRAND.md`
  and `site/index.html`.
- Git: repo was already initialized with `origin` =
  `git@github.com:mihastele/open-seasonal-logger.git`. Prior work was already
  committed and pushed (`43de6e8 Update`). This logo change is committed and
  pushed on top.
- `flutter analyze` clean; 19 tests pass.
- STOPPED — next: run on device to eyeball branding; remaining open decisions
  (license, upcoming-season count, export/delete).

### 2026-09-28 — Swipe edit/delete and the 2-upcoming limit

- Swipe-to-reveal on current + upcoming cards: Edit (Amber pencil) and Delete
  (Bark trash). Uses `flutter_slidable` (MIT).
- DECISION (user): the red destructive button was refused in favour of the
  brand's no-red rule. Delete is Bark with a confirm dialog; edit is Amber.
  BRAND.md updated with the explicit "no red for destructive either" rule.
- DECISION (user): delete is a hard delete (row + reflection removed), after
  confirmation. This is the "how does this get deleted?" answer from AGENTS.md.
- New lifecycle limit, no schema change needed: at most 2 upcoming seasons
  (one active + 2 upcoming = full). Enforced in `SeasonRepository`
  (`UpcomingSeasonLimit`) in addition to the UI hiding the button.
- New pure domain logic `lib/domain/season_timeline.dart` (`SeasonTimeline`,
  `PlannedSlot`, `maxUpcomingSeasons`): decides which slot is missing, the
  suggested start date, and whether the timeline is full.
  - Placement rule (user): no active -> new season is active, starts today;
    otherwise fill the first gap in the active+upcoming chain (start = previous
    season's end date); if no gap, append after the last planned season.
- Repository additions: `watchUpcomingSeasons`, `upcomingSeasons`, `all`,
  `updateSeason`, `deleteSeason`. `createSeason` now refuses a 3rd upcoming.
- Sheet (`new_season_sheet.dart`) now supports create and edit modes, and
  prefills the suggested slot from the timeline.
- Home screen now renders one `watchAll` stream, lists up to 2 upcoming, and
  hides "New season" when full (label changed from "Plan a season").
- Notifications made fully best-effort: a scheduling failure can no longer
  break saving a season (this caused a headless-test crash).
- Tests: 34 pass. Added `season_timeline_test.dart` (7 cases) and repository
  tests for the 3rd-upcoming limit, hard delete, and update. Widget tests for
  swipe reveal, delete flow, edit flow, and FAB disappearing when full.
  `flutter analyze` clean.
- STOPPED — next: commit + push; run on device to eyeball the swipe UX.
  Remaining open decisions: license, export/delete-export design.

### 2026-09-28 — Optional Buy Me a Coffee link

- Added an optional, off-by-default support link at the foot of the home
  screen: `https://buymeacoffee.com/mihastele`.
- SCHEMA CHANGE, v2 -> v3: new single-row `SupportSettings` table
  (`showFooter`, default false). `onUpgrade` creates + seeds it; the old
  `_seedReminderSettings` became `_seedSingletonRows`. schemaVersion => 3.
- New `lib/data/support_repository.dart` (`SupportRepository`) holds the URL
  and the preference. `AppDependencies.support` added.
- New `lib/ui/support_footer.dart`: quiet text link + inline dismiss (X),
  using Stone/Clay — never the Buy-Me-a-Coffee yellow (per brand rule that
  third-party brand colours stay out of the app).
- Settings screen now has a "Show the coffee link" toggle (off by default).
- Link opens via `url_launcher` (`LaunchMode.externalApplication`); the app
  still makes no network request itself (principle 5). Added an https
  `<queries>` intent to AndroidManifest for Android 11+; no iOS
  `LSApplicationQueriesSchemes` needed since we don't call `canLaunchUrl`.
- DECISION: kept off by default so it "disturbs nobody"; the user opted to
  make it hideable inline and from Settings.
- Tests: 39 pass. Added `support_test.dart` (default off, toggle, https URL)
  and two widget tests (hidden by default; shown then dismissed inline).
  Migration test now also asserts the SupportSettings seed. Analyze clean.
- STOPPED — next: commit + push; run on device to eyeball the footer + settings.
  Remaining open decisions: license, export design.

### 2026-09-28 — Coffee link on by default

- REVERSAL of the prior decision: the "Buy me a coffee" link is now shown by
  default. The user's choice is saved (via the existing `SupportSettings` row),
  and the inline X plus the Settings toggle still hide it for good.
- SCHEMA CHANGE, v3 -> v4: `SupportSettings.showFooter` default flipped
  `false` -> `true`. `schemaVersion => 4`; `onUpgrade` (from == 3) updates the
  existing still-default row to `1` so installs seeded before the flip actually
  show the link, then `_seedSingletonRows` handles fresh/earlier upgrades.
  Regenerated Drift types with build_runner.
- Copy updated: Settings subtitle now reads "On by default", doc comments in
  `support_repository.dart`, `support_footer.dart`, `home_screen.dart`, and the
  README updated.
- Tests: 41 pass. `support_test.dart` now asserts the default is ON;
  home widget test asserts the link shows by default and that hiding persists
  across a fresh app over the same database; new migration test builds a real
  v3 DB and asserts v3 -> v4 flips the seed to shown while preserving seasons
  and the reminder preference. `flutter analyze` clean.
- DECISION: no secret/network change — opening the link still only hands a URL
  to the system browser (principle 5).
- STOPPED — next: commit + push; run on device to eyeball the default-on footer.
  Remaining open decisions: license, export design.

### 2026-09-28 — Rotating new-season examples (40 pairs)

- New `lib/domain/season_examples.dart`: 40 `SeasonExample(title, description)`
  pairs across many domains (electronics, painting, language, music, cooking,
  movement, gardening, crafts, nature, community, …). The original
  "Build a Tiny PLC" pair is kept as entry #1.
- `randomSeasonExample()` picks one per sheet opening and never repeats
  back-to-back. The sheet stores it in a `late final` so it is stable while
  open; invisible in edit mode (fields prefilled).
- Copy follows brand voice (warm, unhurried) and principle 3: no scoring,
  quota, cadence, or guilt language. Deliberately avoided "daily/weekly/one a
  week" framings to stay consistent with the one-reminder decision.
- Tests: 46 pass. New `test/season_examples_test.dart` (count is 40, unique
  non-empty titles/descriptions, principle-3 word scan, membership,
  no-back-to-back-repeat). `flutter analyze` clean. README domain line updated.
- STOPPED — next: commit + push; run on device to eyeball. Remaining open
  decisions: license, export design.

### 2026-09-28 — Full icon + favicon pass (Android, Linux, site, web)

- New master `brand/icons/foreground.svg`: brush mark at 50% on transparency
  for masked-icon contexts (Android adaptive, web maskable).
- Android: adaptive icon (`mipmap-anydpi-v26/ic_launcher.xml`) with Linen
  background (`values/colors.xml`) + foreground PNGs at all 5 densities;
  legacy `ic_launcher.png` re-rendered; pre-v21 splash tinted from white to
  Linen (v21+ keeps following the system day/night background).
- Linux: window/taskbar icon — `linux/runner/assets/app_icon.png` is installed
  to `bundle/data/` by CMake and loaded best-effort in `my_application.cc`;
  plus validated `linux/com.seasonal.seasonal.desktop` and a full hicolor icon
  tree (`linux/icons/hicolor/`). README documents the optional install step.
- Site: full favicon set (`favicon.svg`, multi-size `favicon.ico`, 16/32 PNG,
  `apple-touch-icon.png`), `theme-color`, and `site.webmanifest`.
- Web shell rebranded (was Flutter-blue defaults): Seasonal icons incl.
  maskables, manifest name/colors/description, page title, theme-color.
- `brand/render-icons.sh` now renders ALL of the above from the two SVG
  masters (needs `rsvg-convert`; Pillow-gated step for .ico/maskables).
  This session's PNGs were bootstrapped with system librsvg via
  `/tmp/render_icons.py` (throwaway) since rsvg-convert isn't installed.
- Tests: 54 pass. New `test/app_icons_test.dart` (8 tests): every icon ref in
  manifests/pages/native shells resolves to a real PNG; SVG favicon stays in
  sync with the master; web shell has no default blue left. Analyze clean.
- Verified: `flutter build linux` (icon lands in bundle), `flutter build apk
  --debug` (APK contains anydpi XML + foregrounds), `flutter build web`,
  `desktop-file-validate`, and a visual contact sheet of tiny/masked renders.
- Incidental: `test/widget_test.dart` (default counter-app template referencing
  nonexistent `MyApp`, dropped by an untracked `flutter create --platforms=web`
  run between sessions) broke compilation of the whole suite. Moved aside to
  `/tmp/widget_test.dart.orig`, not deleted — restore or drop at will.
- STOPPED — next: commit + push; eyeball launcher/window icons on device.
  Remaining open decisions: license, export design.


