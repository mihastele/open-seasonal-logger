import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:seasonal/data/app_database.dart';
import 'package:seasonal/data/season_repository.dart';
import 'package:seasonal/domain/season_math.dart';
import 'package:seasonal/domain/season_timeline.dart';
import 'package:seasonal/main.dart';

/// Bottom sheet for creating or editing a season.
///
/// Planning never ends or overwrites the current season (principle 2). When
/// one is already active, a new season is created as a separate `upcoming`
/// row that begins on or after the current season ends.
Future<void> showNewSeasonSheet(
  BuildContext context, {
  required AppDependencies dependencies,
  Season? editing,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _NewSeasonSheet(
      dependencies: dependencies,
      editing: editing,
    ),
  );
}

class _NewSeasonSheet extends StatefulWidget {
  const _NewSeasonSheet({
    required this.dependencies,
    this.editing,
  });

  final AppDependencies dependencies;
  final Season? editing;

  @override
  State<_NewSeasonSheet> createState() => _NewSeasonSheetState();
}

class _NewSeasonSheetState extends State<_NewSeasonSheet> {
  final _title = TextEditingController();
  final _description = TextEditingController();
  DateTime _startDate = DateTime.now();
  int _durationWeeks = 8;
  bool _saving = false;
  String? _error;
  bool _ready = false;
  bool _hasActiveSeason = false;

  bool get _isEditing => widget.editing != null;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final editing = widget.editing;
    if (editing != null) {
      _title.text = editing.title;
      _description.text = editing.description ?? '';
      setState(() {
        _startDate = editing.startDate;
        _durationWeeks = editing.durationWeeks;
        _ready = true;
      });
      return;
    }

    final timeline =
        SeasonTimeline(await widget.dependencies.seasons.all());
    final slot = timeline.nextSlot(DateTime.now());
    if (!mounted) return;
    setState(() {
      _hasActiveSeason = timeline.active != null;
      if (slot != null) {
        _startDate = slot.startDate;
        _durationWeeks = slot.durationWeeks;
      }
      _ready = true;
    });
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final ends = SeasonMath.endDate(_startDate, _durationWeeks);
    final formatter = DateFormat.yMMMMd();

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFFBF7F2),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCCFC2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  _isEditing
                      ? 'Edit season'
                      : (_hasActiveSeason
                          ? 'What next?'
                          : 'What would you like to explore?'),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (!_isEditing && _hasActiveSeason) ...[
                  const SizedBox(height: 6),
                  const Text(
                    "This won't end your current season. It simply waits "
                    'its turn.',
                    style: TextStyle(fontSize: 13, color: Color(0xFF8A7A6B)),
                  ),
                ],
                const SizedBox(height: 22),
                TextField(
                  controller: _title,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: _decoration('Title', hint: 'Build a Tiny PLC'),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _description,
                  minLines: 2,
                  maxLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: _decoration(
                    'Description (optional)',
                    hint: 'Learn embedded control by actually building one.',
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _PickerTile(
                        label: 'Starts',
                        value: formatter.format(_startDate),
                        onTap: _pickStartDate,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _PickerTile(
                        label: 'Length',
                        value: '$_durationWeeks weeks',
                        onTap: _pickDuration,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  'Ends ${formatter.format(ends)}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF8A7A6B),
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 14),
                  Text(
                    _error!,
                    style: const TextStyle(color: Color(0xFF9C3A2A)),
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: (!_ready || _saving) ? null : _save,
                    child: Text(
                      _isEditing
                          ? 'Save changes'
                          : (_saving ? 'Saving…' : 'Save season'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _decoration(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    );
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
    );
    if (picked != null) setState(() => _startDate = picked);
  }

  Future<void> _pickDuration() async {
    final picked = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFFFBF7F2),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(vertical: 12),
            children: [
              for (final weeks in const [4, 6, 8, 12, 16, 24])
                ListTile(
                  title: Text('$weeks weeks'),
                  onTap: () => Navigator.of(context).pop(weeks),
                ),
            ],
          ),
        ),
      ),
    );
    if (picked != null) setState(() => _durationWeeks = picked);
  }

  Future<void> _save() async {
    final title = _title.text.trim();
    if (title.isEmpty) {
      setState(() => _error = 'Give your season a title.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });

    final description =
        _description.text.trim().isEmpty ? null : _description.text.trim();

    try {
      if (_isEditing) {
        await widget.dependencies.seasons.updateSeason(
          seasonId: widget.editing!.id,
          title: title,
          description: description,
          startDate: _startDate,
          durationWeeks: _durationWeeks,
        );
      } else {
        final now = DateTime.now();
        final status = _startDate.isAfter(now)
            ? SeasonStatus.upcoming
            : SeasonStatus.active;
        await widget.dependencies.seasons.createSeason(
          title: title,
          description: description,
          startDate: _startDate,
          durationWeeks: _durationWeeks,
          status: status,
        );
      }
      await widget.dependencies.rescheduleReminder();
      if (mounted) Navigator.of(context).pop();
    } on ActiveSeasonConflict {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = 'A season is already active.';
        });
      }
    } on UpcomingSeasonLimit {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = 'You can plan at most $maxUpcomingSeasons seasons ahead.';
        });
      }
    }
  }
}

class _PickerTile extends StatelessWidget {
  const _PickerTile({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  letterSpacing: 1.5,
                  color: Color(0xFF8A7A6B),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
