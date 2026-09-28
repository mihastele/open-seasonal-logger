# Project State

## Current Facts

| Item                  | Value                                | Set on     |
| --------------------- | ------------------------------------ | ---------- |
| Repo                  | Not yet created                      | 2026-09-28 |
| License               | TBD                                  |            |
| Frontend              | Flutter 3.47.5 / Dart 3.13.4         | 2026-09-28 |
| Database              | Drift / SQLite (on-device), schema v1 | 2026-09-28 |
| Backend               | None — v0.1 is local-only            | 2026-09-28 |
| Object storage        | None — v0.1 has no uploads/media     | 2026-09-28 |
| Notifications         | Local only, 5 days before season end | 2026-09-28 |
| Secrets location      | None yet (no secrets in v0.1)        | 2026-09-28 |
| Test command          | `flutter test`                       | 2026-09-28 |
| Analyze command       | `flutter analyze`                    | 2026-09-28 |

## Open decisions

- License (TBD).
- Whether "Up next" allows a single upcoming season only, or a queue of
  upcoming seasons. Diagram implies one upcoming; confirm at build time.
- Export / delete design: recorded as required by AGENTS.md, not yet designed.
  Proposed: export season + reflections to Markdown/JSON; delete per-season.
- Exact `durationWeeks` handling for "Week N of M" and the progress bar.

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


