import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:seasonal/brand/palette.dart';
import 'package:seasonal/brand/seasonal_mark.dart';
import 'package:seasonal/data/app_database.dart';
import 'package:seasonal/domain/season_math.dart';
import 'package:seasonal/domain/season_timeline.dart';
import 'package:seasonal/main.dart';
import 'package:seasonal/services/season_notifications.dart';
import 'package:seasonal/ui/new_season_sheet.dart';
import 'package:seasonal/ui/season_detail_screen.dart';
import 'package:seasonal/ui/settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.dependencies});

  final AppDependencies dependencies;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: StreamBuilder<List<Season>>(
              stream: dependencies.seasons.watchAll(),
              builder: (context, snapshot) {
                final seasons = snapshot.data ?? const <Season>[];
                final timeline = SeasonTimeline(seasons);
                return ListView(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
                  children: [
                    _Header(
                      onSettings: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              SettingsScreen(dependencies: dependencies),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    _ActiveSeasonSection(
                      dependencies: dependencies,
                      timeline: timeline,
                    ),
                    const SizedBox(height: 28),
                    _UpcomingSection(
                      dependencies: dependencies,
                      timeline: timeline,
                    ),
                    const SizedBox(height: 28),
                    _PastSeasonsSection(dependencies: dependencies),
                  ],
                );
              },
            ),
          ),
        ),
      ),
      floatingActionButton: StreamBuilder<List<Season>>(
        stream: dependencies.seasons.watchAll(),
        builder: (context, snapshot) {
          final timeline = SeasonTimeline(snapshot.data ?? const <Season>[]);
          if (timeline.isFull) return const SizedBox.shrink();
          return FloatingActionButton.extended(
            onPressed: () => _planNextSeason(context),
            icon: const Icon(Icons.add),
            label: const Text('New season'),
          );
        },
      ),
    );
  }

  Future<void> _planNextSeason(BuildContext context) async {
    await showNewSeasonSheet(context, dependencies: dependencies);
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onSettings});

  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SeasonalMark(size: 40),
        const SizedBox(width: 14),
        const Text(
          'SEASONAL',
          style: TextStyle(
            fontSize: 13,
            letterSpacing: 6,
            fontWeight: FontWeight.w700,
            color: SeasonalColors.stone,
          ),
        ),
        const Spacer(),
        IconButton(
          onPressed: onSettings,
          icon: const Icon(Icons.tune),
          color: SeasonalColors.stone,
          tooltip: 'Settings',
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          letterSpacing: 3,
          fontWeight: FontWeight.w600,
          color: SeasonalColors.stone,
        ),
      ),
    );
  }
}

class _ActiveSeasonSection extends StatelessWidget {
  const _ActiveSeasonSection({
    required this.dependencies,
    required this.timeline,
  });

  final AppDependencies dependencies;
  final SeasonTimeline timeline;

  @override
  Widget build(BuildContext context) {
    final season = timeline.active;
    final now = DateTime.now();
    if (season == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionLabel('CURRENT SEASON'),
          const _EmptyCard(
            child: Text(
              'Nothing active right now.\n'
              'What would you like to explore next?',
              style: TextStyle(color: SeasonalColors.clay, height: 1.5),
            ),
          ),
        ],
      );
    }

    final endingSoon = SeasonMath.daysRemaining(
          season.startDate,
          season.durationWeeks,
          now,
        ) <=
        SeasonNotificationService.remindDaysBeforeEnd;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(
          endingSoon ? 'CURRENT SEASON · ENDING SOON' : 'CURRENT SEASON',
        ),
        _SwipeableSeasonCard(
          dependencies: dependencies,
          season: season,
          now: now,
        ),
        if (endingSoon) ...[
          const SizedBox(height: 12),
          const _GentlePrompt(),
        ],
      ],
    );
  }
}

class _GentlePrompt extends StatelessWidget {
  const _GentlePrompt();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SeasonalColors.linen,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Text(
        '🍂 Your season is ending soon.\nWhat would you like to explore next?',
        style: TextStyle(color: SeasonalColors.clay, height: 1.5),
      ),
    );
  }
}

class _UpcomingSection extends StatelessWidget {
  const _UpcomingSection({
    required this.dependencies,
    required this.timeline,
  });

  final AppDependencies dependencies;
  final SeasonTimeline timeline;

  @override
  Widget build(BuildContext context) {
    final upcoming = timeline.upcoming;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(
          'UP NEXT${upcoming.isEmpty ? '' : ' (${upcoming.length}/$maxUpcomingSeasons)'}',
        ),
        if (upcoming.isEmpty)
          const _EmptyCard(
            child: Text(
              'No season planned yet.',
              style: TextStyle(color: SeasonalColors.stone),
            ),
          )
        else
          ...upcoming.map(
            (season) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _SwipeableSeasonCard(
                dependencies: dependencies,
                season: season,
                compact: true,
              ),
            ),
          ),
      ],
    );
  }
}

/// A season card that reveals an edit (amber pencil) and delete (bark trash)
/// action when swiped. There is deliberately no red: red means failure, and an
/// ending season is not a failure (see brand/BRAND.md).
class _SwipeableSeasonCard extends StatelessWidget {
  const _SwipeableSeasonCard({
    required this.dependencies,
    required this.season,
    this.now,
    this.compact = false,
  });

  final AppDependencies dependencies;
  final Season season;
  final DateTime? now;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: ValueKey(season.id),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.5,
        children: [
          SlidableAction(
            onPressed: (_) => _edit(context),
            backgroundColor: SeasonalColors.amber,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'Edit',
          ),
          SlidableAction(
            onPressed: (_) => _delete(context),
            backgroundColor: SeasonalColors.bark,
            foregroundColor: Colors.white,
            icon: Icons.delete_outline,
            label: 'Delete',
          ),
        ],
      ),
      child: _SeasonCard(
        season: season,
        now: now,
        compact: compact,
        onTap: () => _open(context),
      ),
    );
  }

  void _open(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SeasonDetailScreen(
          dependencies: dependencies,
          seasonId: season.id,
        ),
      ),
    );
  }

  Future<void> _edit(BuildContext context) async {
    await showNewSeasonSheet(
      context,
      dependencies: dependencies,
      editing: season,
    );
  }

  Future<void> _delete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete “${season.title}”?'),
        content: const Text(
          'This permanently removes the season and any reflection. '
          'This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep it'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: SeasonalColors.bark,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await dependencies.seasons.deleteSeason(season.id);
    await dependencies.rescheduleReminder();
  }
}

class _PastSeasonsSection extends StatelessWidget {
  const _PastSeasonsSection({required this.dependencies});

  final AppDependencies dependencies;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Season>>(
      stream: dependencies.seasons.watchPastSeasons(),
      builder: (context, snapshot) {
        final seasons = snapshot.data ?? const <Season>[];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionLabel('PAST SEASONS'),
            if (seasons.isEmpty)
              const _EmptyCard(
                child: Text(
                  'Nothing here yet.',
                  style: TextStyle(color: SeasonalColors.stone),
                ),
              )
            else
              ...seasons.map(
                (s) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _PastRow(
                    season: s,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => SeasonDetailScreen(
                          dependencies: dependencies,
                          seasonId: s.id,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _PastRow extends StatelessWidget {
  const _PastRow({required this.season, required this.onTap});

  final Season season;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat.yMMMd();
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      season.title,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${formatter.format(season.startDate)} – '
                      '${formatter.format(SeasonMath.endDate(season.startDate, season.durationWeeks))}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: SeasonalColors.stone,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Color(0xFFB9AA9B)),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: child,
    );
  }
}

class _SeasonCard extends StatelessWidget {
  const _SeasonCard({
    required this.season,
    required this.onTap,
    this.now,
    this.compact = false,
  });

  final Season season;
  final VoidCallback onTap;
  final DateTime? now;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final reference = now ?? DateTime.now();
    final week = SeasonMath.currentWeek(
      season.startDate,
      season.durationWeeks,
      reference,
    );
    final progress = SeasonMath.progress(
      season.startDate,
      season.durationWeeks,
      reference,
    );
    final ends = SeasonMath.endDate(season.startDate, season.durationWeeks);
    final percent = (progress * 100).round();

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                season.title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                  color: SeasonalColors.ink,
                ),
              ),
              if (season.description != null &&
                  season.description!.isNotEmpty &&
                  !compact) ...[
                const SizedBox(height: 8),
                Text(
                  season.description!,
                  style: const TextStyle(
                    color: SeasonalColors.clay,
                    height: 1.5,
                  ),
                ),
              ],
              if (!compact && season.status == SeasonStatus.active) ...[
                const SizedBox(height: 20),
                Text(
                  'Week $week of ${season.durationWeeks}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: SeasonalColors.stone,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 8,
                          backgroundColor: const Color(0xFFEDE4DA),
                          valueColor: const AlwaysStoppedAnimation(
                            SeasonalColors.ember,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '$percent%',
                      style: const TextStyle(
                        fontSize: 13,
                        color: SeasonalColors.stone,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Ends ${DateFormat.yMMMMd().format(ends)}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: SeasonalColors.stone,
                  ),
                ),
                const SizedBox(height: 18),
                Align(
                  alignment: Alignment.centerLeft,
                  child: FilledButton(
                    onPressed: onTap,
                    child: const Text('Open Season'),
                  ),
                ),
              ],
              if (compact) ...[
                const SizedBox(height: 6),
                Text(
                  'Starts ${DateFormat.yMMMMd().format(season.startDate)}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: SeasonalColors.stone,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
