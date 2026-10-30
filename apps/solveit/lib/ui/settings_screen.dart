import 'package:flutter/material.dart';
import '../domain/learner_preferences.dart';
import '../domain/lesson.dart';
import '../features/coaching/session_controller.dart';
import 'save_status.dart';
import 'solveit_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.store});
  final PracticeStore store;

  Future<void> _save(BuildContext context, LearnerPreferences value) async {
    try {
      await store.updatePreferences(value);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not save settings. Try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Learning preferences')),
    body: ListenableBuilder(
      listenable: store,
      builder: (context, _) => ListView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
        children: [
          const Text('MAKE IT YOURS', style: noteLabel),
          const SizedBox(height: 14),
          const Text(
            'Choose your pace.',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w500,
              letterSpacing: -.8,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'This changes the coaching prompts, not the difficulty or correctness rules. Your choice applies to new attempts.',
            style: TextStyle(height: 1.6, color: StudyColors.muted),
          ),
          const SizedBox(height: 28),
          const Text('COACHING PACE', style: noteLabel),
          const SizedBox(height: 10),
          RadioGroup<CoachingPace>(
            groupValue: store.preferences.pace,
            onChanged: (value) {
              if (value != null) {
                _save(context, store.preferences.copyWith(pace: value));
              }
            },
            child: Column(
              children: CoachingPace.values
                  .map(
                    (pace) => RadioListTile<CoachingPace>(
                      value: pace,
                      title: Text(pace.label),
                      subtitle: Text(pace.description),
                      contentPadding: EdgeInsets.zero,
                      activeColor: StudyColors.ink,
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 18),
          const Text('DEFAULT CODE LANGUAGE', style: noteLabel),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: CodeLanguage.values
                .map(
                  (language) => ChoiceChip(
                    label: Text(language.label),
                    selected: store.preferences.preferredLanguage == language,
                    onSelected: (_) => _save(
                      context,
                      store.preferences.copyWith(preferredLanguage: language),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 24),
          SaveStatus(store: store),
          const SizedBox(height: 22),
          const Text(
            'Settings and practice history stay on this device. Use Workbook backup to move attempts to another device.',
            style: TextStyle(color: StudyColors.muted, height: 1.6),
          ),
        ],
      ),
    ),
  );
}
