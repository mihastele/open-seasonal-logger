import 'package:flutter/material.dart';
import 'package:seasonal/brand/palette.dart';
import 'package:seasonal/data/app_database.dart';
import 'package:seasonal/main.dart';

/// Settings for the single end-of-season reminder.
///
/// This is not a recurring habit schedule. A season has a natural stopping
/// point, and so does its reminder (see the product principles).
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.dependencies});

  final AppDependencies dependencies;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: SeasonalColors.ink,
        title: const Text('Settings'),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: StreamBuilder<ReminderSetting>(
              stream: dependencies.reminders.watch(),
              builder: (context, snapshot) {
                final setting = snapshot.data;
                if (setting == null) {
                  return const Center(child: CircularProgressIndicator());
                }
                return _ReminderForm(
                  dependencies: dependencies,
                  setting: setting,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _ReminderForm extends StatefulWidget {
  const _ReminderForm({required this.dependencies, required this.setting});

  final AppDependencies dependencies;
  final ReminderSetting setting;

  @override
  State<_ReminderForm> createState() => _ReminderFormState();
}

class _ReminderFormState extends State<_ReminderForm> {
  late bool _enabled;
  late int _daysBeforeEnd;
  late int _timeOfDayMinutes;

  @override
  void initState() {
    super.initState();
    _enabled = widget.setting.enabled;
    _daysBeforeEnd = widget.setting.daysBeforeEnd;
    _timeOfDayMinutes = widget.setting.timeOfDayMinutes;
  }

  @override
  Widget build(BuildContext context) {
    final time = TimeOfDay(
      hour: _timeOfDayMinutes ~/ 60,
      minute: _timeOfDayMinutes % 60,
    );
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
      children: [
        const Text(
          'END-OF-SEASON REMINDER',
          style: TextStyle(
            fontSize: 12,
            letterSpacing: 3,
            fontWeight: FontWeight.w600,
            color: SeasonalColors.stone,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'One gentle nudge as your season draws to a close. Not a streak, '
          'not a daily task — just a moment to think about what is next.',
          style: TextStyle(color: SeasonalColors.clay, height: 1.5),
        ),
        const SizedBox(height: 20),
        Card(
          child: SwitchListTile(
            title: const Text('Remind me'),
            subtitle: const Text('Off means no reminder at all.'),
            value: _enabled,
            activeThumbColor: SeasonalColors.ember,
            onChanged: (value) {
              setState(() => _enabled = value);
              _save();
            },
          ),
        ),
        const SizedBox(height: 12),
        Opacity(
          opacity: _enabled ? 1 : 0.4,
          child: IgnorePointer(
            ignoring: !_enabled,
            child: Column(
              children: [
                Card(
                  child: _ChoiceTile<int>(
                    title: 'When',
                    value: _daysBeforeEnd,
                    options: const {1: '1 day before', 3: '3 days before', 5: '5 days before', 7: '7 days before'},
                    onChanged: (value) {
                      setState(() => _daysBeforeEnd = value);
                      _save();
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: ListTile(
                    title: const Text('Time'),
                    subtitle: Text(time.format(context)),
                    trailing: const Icon(Icons.schedule),
                    onTap: _pickTime,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'The reminder is rescheduled automatically whenever your seasons '
          'change.',
          style: TextStyle(fontSize: 13, color: SeasonalColors.stone),
        ),
      ],
    );
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: _timeOfDayMinutes ~/ 60,
        minute: _timeOfDayMinutes % 60,
      ),
    );
    if (picked == null) return;
    setState(() => _timeOfDayMinutes = picked.hour * 60 + picked.minute);
    _save();
  }

  Future<void> _save() async {
    await widget.dependencies.reminders.save(
      enabled: _enabled,
      daysBeforeEnd: _daysBeforeEnd,
      timeOfDayMinutes: _timeOfDayMinutes,
    );
    await widget.dependencies.rescheduleReminder();
  }
}

class _ChoiceTile<T> extends StatelessWidget {
  const _ChoiceTile({
    required this.title,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String title;
  final T value;
  final Map<T, String> options;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final entry in options.entries)
                ChoiceChip(
                  label: Text(entry.value),
                  selected: entry.key == value,
                  selectedColor: SeasonalColors.linen,
                  onSelected: (_) => onChanged(entry.key),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
