import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:seasonal/brand/palette.dart';
import 'package:seasonal/brand/seasonal_mark.dart';
import 'package:seasonal/data/app_database.dart';
import 'package:seasonal/domain/season_math.dart';
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
            child: ListView(
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
                _ActiveSeasonSection(dependencies: dependencies),
                const SizedBox(height: 28),
                _UpcomingSection(dependencies: dependencies),
                const SizedBox(height: 28),
                _PastSeasonsSection(dependencies: dependencies),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _planNextSeason(context),
        icon: const Icon(Icons.add),
        label: const Text('Plan a season'),
      ),
    );
  }

  Future<void> _planNextSeason(BuildContext context) async {
    final active = await dependencies.seasons.activeSeason();
    if (!context.mounted) return;
    await showNewSeasonSheet(
      context,
      dependencies: dependencies,
      hasActiveSeason: active != null,
    );
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
          color: Color(0xFF8A7A6B),
        ),
      ),
    );
  }
}

class _ActiveSeasonSection extends StatelessWidget {
  const _ActiveSeasonSection({required this.dependencies});

  final AppDependencies dependencies;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Season?>(
      stream: dependencies.seasons.watchActiveSeason(),
      builder: (context, snapshot) {
        final season = snapshot.data;
        final now = DateTime.now();
        if (season == null) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionLabel('CURRENT SEASON'),
              _EmptyCard(
                child: Text(
                  'Nothing active right now.\n'
                  'What would you like to explore next?',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF6B5D50),
                        height: 1.5,
                      ),
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
            _SectionLabel(endingSoon ? 'CURRENT SEASON · ENDING SOON' : 'CURRENT SEASON'),
            _SeasonCard(
              season: season,
              now: now,
              onTap: () => _open(context, season),
            ),
            if (endingSoon) ...[
              const SizedBox(height: 12),
              const _GentlePrompt(),
            ],
          ],
        );
      },
    );
  }

  void _open(BuildContext context, Season season) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SeasonDetailScreen(
          dependencies: dependencies,
          seasonId: season.id,
        ),
      ),
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
        color: const Color(0xFFF3E9DE),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        '🍂 Your season is ending soon.\nWhat would you like to explore next?',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF6B5D50),
              height: 1.5,
            ),
      ),
    );
  }
}

class _UpcomingSection extends StatelessWidget {
  const _UpcomingSection({required this.dependencies});

  final AppDependencies dependencies;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Season?>(
      stream: dependencies.seasons.watchUpcomingSeason(),
      builder: (context, snapshot) {
        final season = snapshot.data;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionLabel('UP NEXT'),
            if (season == null)
              _EmptyCard(
                child: Text(
                  'No season planned yet.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF8A7A6B),
                      ),
                ),
              )
            else
              _SeasonCard(
                season: season,
                compact: true,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => SeasonDetailScreen(
                      dependencies: dependencies,
                      seasonId: season.id,
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
              _EmptyCard(
                child: Text(
                  'Nothing here yet.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF8A7A6B),
                      ),
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
                        color: Color(0xFF8A7A6B),
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
                ),
              ),
              if (season.description != null &&
                  season.description!.isNotEmpty &&
                  !compact) ...[
                const SizedBox(height: 8),
                Text(
                  season.description!,
                  style: const TextStyle(
                    color: Color(0xFF6B5D50),
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
                    color: Color(0xFF8A7A6B),
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
                            Color(0xFFB4633A),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '$percent%',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF8A7A6B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Ends ${DateFormat.yMMMMd().format(ends)}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF8A7A6B),
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
                    color: Color(0xFF8A7A6B),
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
