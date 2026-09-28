import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:seasonal/data/app_database.dart';
import 'package:seasonal/data/season_repository.dart';
import 'package:seasonal/domain/season_math.dart';
import 'package:seasonal/main.dart';

/// The Season screen. It is a place to look at what you're exploring and, when
/// the season ends, to answer exactly three optional questions. It is never a
/// report, dashboard, or summary of performance (principle 4).
class SeasonDetailScreen extends StatelessWidget {
  const SeasonDetailScreen({
    super.key,
    required this.dependencies,
    required this.seasonId,
  });

  final AppDependencies dependencies;
  final int seasonId;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Season?>(
      stream: (dependencies.database.select(dependencies.database.seasons)
            ..where((t) => t.id.equals(seasonId)))
          .watchSingleOrNull(),
      builder: (context, snapshot) {
        final season = snapshot.data;
        if (season == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            foregroundColor: const Color(0xFF4A3F35),
          ),
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
                  children: [
                    _Header(season: season),
                    const SizedBox(height: 28),
                    _LifecycleActions(
                      dependencies: dependencies,
                      season: season,
                    ),
                    const SizedBox(height: 32),
                    _ReflectionSection(
                      dependencies: dependencies,
                      season: season,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.season});

  final Season season;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final ends = SeasonMath.endDate(season.startDate, season.durationWeeks);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          season.title,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        if (season.description != null && season.description!.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(
            season.description!,
            style: const TextStyle(color: Color(0xFF6B5D50), height: 1.55),
          ),
        ],
        const SizedBox(height: 18),
        Text(
          '${DateFormat.yMMMd().format(season.startDate)} – '
          '${DateFormat.yMMMd().format(ends)}',
          style: const TextStyle(fontSize: 13, color: Color(0xFF8A7A6B)),
        ),
        if (season.status == SeasonStatus.active) ...[
          const SizedBox(height: 6),
          Text(
            'Week ${SeasonMath.currentWeek(season.startDate, season.durationWeeks, now)} '
            'of ${season.durationWeeks}',
            style: const TextStyle(fontSize: 13, color: Color(0xFF8A7A6B)),
          ),
        ],
      ],
    );
  }
}

class _LifecycleActions extends StatelessWidget {
  const _LifecycleActions({
    required this.dependencies,
    required this.season,
  });

  final AppDependencies dependencies;
  final Season season;

  @override
  Widget build(BuildContext context) {
    switch (season.status) {
      case SeasonStatus.active:
        return Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton(
            onPressed: () => _endSeason(context),
            child: const Text('End season'),
          ),
        );
      case SeasonStatus.upcoming:
        return StreamBuilder<Season?>(
          stream: dependencies.seasons.watchActiveSeason(),
          builder: (context, snapshot) {
            final hasActive = snapshot.data != null;
            return Align(
              alignment: Alignment.centerLeft,
              child: FilledButton(
                onPressed: hasActive ? null : () => _startSeason(context),
                child: Text(
                  hasActive
                      ? 'Starts after your current season'
                      : 'Start this season',
                ),
              ),
            );
          },
        );
      case SeasonStatus.completed:
        return const SizedBox.shrink();
    }
  }

  Future<void> _endSeason(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End this season?'),
        content: const Text(
          'Whatever you explored is enough. You can still reflect on it '
          'afterward.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Not yet'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('End season'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await dependencies.seasons.completeSeason(season.id);
    await dependencies.notifications.cancelReminder();
    if (context.mounted) Navigator.of(context).pop();
  }

  Future<void> _startSeason(BuildContext context) async {
    try {
      await dependencies.seasons.startUpcoming(season.id);
      await dependencies.notifications.scheduleEndOfSeasonReminder(
        startDate: season.startDate,
        durationWeeks: season.durationWeeks,
      );
    } on ActiveSeasonConflict {
      // The button is disabled in this case; ignore races.
    }
  }
}

class _ReflectionSection extends StatefulWidget {
  const _ReflectionSection({
    required this.dependencies,
    required this.season,
  });

  final AppDependencies dependencies;
  final Season season;

  @override
  State<_ReflectionSection> createState() => _ReflectionSectionState();
}

class _ReflectionSectionState extends State<_ReflectionSection> {
  late final TextEditingController _made;
  late final TextEditingController _learned;
  late final TextEditingController _returnSomeday;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _made = TextEditingController(text: widget.season.reflectionMade ?? '');
    _learned =
        TextEditingController(text: widget.season.reflectionLearned ?? '');
    _returnSomeday = TextEditingController(
      text: widget.season.reflectionReturnSomeday ?? '',
    );
  }

  @override
  void dispose() {
    _made.dispose();
    _learned.dispose();
    _returnSomeday.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'REFLECTION',
          style: TextStyle(
            fontSize: 12,
            letterSpacing: 3,
            fontWeight: FontWeight.w600,
            color: Color(0xFF8A7A6B),
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'All optional. There are no wrong answers, and no score.',
          style: TextStyle(fontSize: 13, color: Color(0xFF8A7A6B)),
        ),
        const SizedBox(height: 18),
        _ReflectionField(label: 'What did I make?', controller: _made),
        const SizedBox(height: 18),
        _ReflectionField(label: 'What did I learn?', controller: _learned),
        const SizedBox(height: 18),
        _ReflectionField(
          label: 'Do I want to return to this someday?',
          controller: _returnSomeday,
        ),
        const SizedBox(height: 22),
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton(
            onPressed: _save,
            child: const Text('Save reflection'),
          ),
        ),
        if (_saved) ...[
          const SizedBox(height: 12),
          const Text(
            'Saved.',
            style: TextStyle(fontSize: 13, color: Color(0xFF8A7A6B)),
          ),
        ],
      ],
    );
  }

  Future<void> _save() async {
    await widget.dependencies.seasons.saveReflection(
      seasonId: widget.season.id,
      made: _made.text,
      learned: _learned.text,
      returnSomeday: _returnSomeday.text,
    );
    if (mounted) setState(() => _saved = true);
  }
}

class _ReflectionField extends StatelessWidget {
  const _ReflectionField({required this.label, required this.controller});

  final String label;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      minLines: 2,
      maxLines: 5,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        labelText: label,
        alignLabelWithHint: true,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
