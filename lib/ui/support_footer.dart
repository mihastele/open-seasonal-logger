import 'package:flutter/material.dart';
import 'package:seasonal/brand/palette.dart';
import 'package:seasonal/data/app_database.dart';

/// A quiet, optional support link for the foot of the home screen.
///
/// Deliberately understated: it uses the Seasonal palette (never the
/// Buy-Me-a-Coffee brand yellow), sits below everything else, and can be
/// hidden for good from Settings. Off by default.
class SupportFooter extends StatelessWidget {
  const SupportFooter({
    super.key,
    required this.setting,
    required this.onOpen,
    required this.onHide,
  });

  final SupportSetting setting;
  final Future<void> Function() onOpen;
  final Future<void> Function() onHide;

  @override
  Widget build(BuildContext context) {
    if (!setting.showFooter) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: TextButton.icon(
              onPressed: onOpen,
              style: TextButton.styleFrom(
                foregroundColor: SeasonalColors.stone,
                textStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              icon: const Icon(Icons.local_cafe_outlined, size: 16),
              label: const Text('Buy me a coffee'),
            ),
          ),
          IconButton(
            onPressed: onHide,
            icon: const Icon(Icons.close, size: 14),
            color: SeasonalColors.stone,
            visualDensity: VisualDensity.compact,
            tooltip: 'Hide this',
          ),
        ],
      ),
    );
  }
}
