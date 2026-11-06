import 'package:flutter/material.dart';
import '../domain/learner_preferences.dart';
import '../domain/lesson.dart';
import '../features/coaching/session_controller.dart';
import 'looploom_theme.dart';
import 'readable_surface.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.store});
  final PracticeStore store;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final TextEditingController _name;
  late final TextEditingController _role;
  ExperienceLevel? _level;
  late CodeLanguage _language;
  late int _minutes;
  DateTime? _date;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final preferences = widget.store.preferences;
    _name = TextEditingController(text: preferences.displayName);
    _role = TextEditingController(text: preferences.targetRole);
    _level = preferences.experienceLevel;
    _language = preferences.preferredLanguage;
    _minutes = preferences.dailyGoalMinutes;
    _date = preferences.targetInterviewDate;
  }

  @override
  void dispose() {
    _name.dispose();
    _role.dispose();
    super.dispose();
  }

  Future<void> _finish({required bool save, bool check = false}) async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final old = widget.store.preferences;
      await widget.store.updatePreferences(
        old.copyWith(
          onboardingSeen: true,
          displayName: save ? _name.text.trim() : old.displayName,
          targetRole: save ? _role.text.trim() : old.targetRole,
          experienceLevel: save ? _level : old.experienceLevel,
          clearExperienceLevel: save && _level == null,
          preferredLanguage: save ? _language : old.preferredLanguage,
          dailyGoalMinutes: save ? _minutes : old.dailyGoalMinutes,
          targetInterviewDate: save ? _date : old.targetInterviewDate,
          clearTargetInterviewDate: save && _date == null,
        ),
      );
      if (mounted) Navigator.of(context).pop(check);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not save your choices. Please try again.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _pickDate() async {
    final today = DateUtils.dateOnly(DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: _date != null && !_date!.isBefore(today)
          ? _date!
          : today.add(const Duration(days: 30)),
      firstDate: today,
      lastDate: DateTime(today.year + 10),
    );
    if (picked != null && mounted) setState(() => _date = picked);
  }

  @override
  Widget build(BuildContext context) => ReadableSurface(
    scale: widget.store.preferences.textScale,
    child: Scaffold(
      appBar: AppBar(title: const Text('Your starting point')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const Text('MAKE IT YOURS', style: noteLabel),
                const SizedBox(height: 10),
                const Text(
                  'Find your next step.',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                Text(
                  'A few optional details help suggest a path on Home. Every roadmap remains open, and you can change these later.',
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.55,
                    color: context.palette.muted,
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _name,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Name or nickname (optional)',
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _role,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Target role (optional)',
                    hintText: 'e.g. Backend engineer',
                  ),
                ),
                const SizedBox(height: 25),
                const Text('WHERE ARE YOU TODAY?', style: noteLabel),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ...ExperienceLevel.values.map(
                      (level) => ChoiceChip(
                        label: Text(level.label),
                        selected: _level == level,
                        onSelected: (_) => setState(() => _level = level),
                      ),
                    ),
                    ChoiceChip(
                      label: const Text('Not sure yet'),
                      selected: _level == null,
                      onSelected: (_) => setState(() => _level = null),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'You can leave this unanswered and use the short pattern check instead.',
                  style: TextStyle(fontSize: 14, color: context.palette.muted),
                ),
                const SizedBox(height: 24),
                const Text('PRACTICE LANGUAGE', style: noteLabel),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: CodeLanguage.values
                      .map(
                        (language) => ChoiceChip(
                          label: Text(language.label),
                          selected: _language == language,
                          onSelected: (_) =>
                              setState(() => _language = language),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 24),
                const Text('MINUTES A DAY', style: noteLabel),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [15, 30, 45, 60, 90]
                      .map(
                        (minutes) => ChoiceChip(
                          label: Text('$minutes min'),
                          selected: _minutes == minutes,
                          onSelected: (_) => setState(() => _minutes = minutes),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 24),
                const Text('INTERVIEW DATE (OPTIONAL)', style: noteLabel),
                const SizedBox(height: 9),
                Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.event_outlined),
                    label: Text(
                      _date == null
                          ? 'Add a date'
                          : MaterialLocalizations.of(
                              context,
                            ).formatMediumDate(_date!),
                    ),
                  ),
                ),
                if (_date != null)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () => setState(() => _date = null),
                      child: const Text('Remove date'),
                    ),
                  ),
                const SizedBox(height: 26),
                FilledButton(
                  onPressed: _saving
                      ? null
                      : () => _finish(save: true, check: true),
                  child: const Text('Save and take short check'),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: _saving ? null : () => _finish(save: true),
                  child: const Text('Save and explore'),
                ),
                TextButton(
                  onPressed: _saving ? null : () => _finish(save: false),
                  child: const Text('Skip for now'),
                ),
                const SizedBox(height: 16),
                Text(
                  'Saved on this device. The optional check is eight pattern-recognition questions, not a coding assessment.',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: context.palette.muted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
