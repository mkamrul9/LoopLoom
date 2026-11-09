import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../domain/learner_preferences.dart';
import '../domain/lesson.dart';
import '../features/coaching/session_controller.dart';
import '../features/coaching/firebase_ai_coach_provider.dart';
import '../features/coaching/reference_runner.dart';
import 'backup_screen.dart';
import 'readable_surface.dart';
import 'save_status.dart';
import 'looploom_theme.dart';
import 'feedback_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.store,
    this.onOpenBackup,
    this.onOpenFeedback,
    this.runnerClientFactory,
  });
  final PracticeStore store;
  final VoidCallback? onOpenBackup;
  final VoidCallback? onOpenFeedback;
  final ReferenceRunnerClient Function(String address, String token)?
  runnerClientFactory;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  PracticeStore get store => widget.store;
  late final TextEditingController _name;
  late final TextEditingController _role;
  late final TextEditingController _runnerAddress;
  late final TextEditingController _runnerToken;
  late int _weeklyGoalDays;
  late int _dailyGoalMinutes;
  ExperienceLevel? _level;
  DateTime? _targetDate;
  bool _savingProfile = false;
  bool _checkingRunner = false;
  bool _runnerReady = false;
  String? _runnerStatus;

  @override
  void initState() {
    super.initState();
    final preferences = store.preferences;
    _name = TextEditingController(text: preferences.displayName);
    _role = TextEditingController(text: preferences.targetRole);
    _runnerAddress = TextEditingController(text: preferences.runnerAddress);
    _runnerToken = TextEditingController(text: preferences.runnerToken);
    _weeklyGoalDays = preferences.weeklyGoalDays;
    _dailyGoalMinutes = preferences.dailyGoalMinutes;
    _level = preferences.experienceLevel;
    _targetDate = preferences.targetInterviewDate;
  }

  @override
  void dispose() {
    _name.dispose();
    _role.dispose();
    _runnerAddress.dispose();
    _runnerToken.dispose();
    super.dispose();
  }

  Future<void> _savePreference(LearnerPreferences value) async {
    try {
      await store.updatePreferences(value);
    } catch (_) {
      if (mounted) {
        _showMessage('Could not save that setting. Try again.');
      }
    }
  }

  Future<void> _saveRunner() async {
    final address = _runnerAddress.text.trim();
    final token = _runnerToken.text.trim();
    if (address.isNotEmpty) {
      try {
        ReferenceRunnerClient(address, token: token).close();
      } catch (_) {
        _showMessage(
          'Use http://PRIVATE-LAN-IP:8766 and a token of at least 32 characters.',
        );
        return;
      }
    }
    try {
      await store.updatePreferences(
        store.preferences.copyWith(runnerAddress: address, runnerToken: token),
      );
    } catch (_) {
      if (mounted) {
        _showMessage('Could not save the runner connection. Try again.');
      }
      return;
    }
    if (mounted) {
      setState(() => _runnerStatus = null);
      _showMessage(
        address.isEmpty
            ? 'Runner disconnected.'
            : 'Runner settings saved on this device.',
      );
    }
  }

  Future<void> _testRunner() async {
    final address = _runnerAddress.text.trim();
    final token = _runnerToken.text.trim();
    if (address.isEmpty) {
      setState(() {
        _runnerReady = false;
        _runnerStatus = 'Enter a runner address first.';
      });
      return;
    }
    if (kIsWeb && !{'localhost', '127.0.0.1'}.contains(Uri.base.host)) {
      setState(() {
        _runnerReady = false;
        _runnerStatus =
            'The hosted HTTPS web app cannot reach this HTTP private runner. Use the Android app or the local web preview.';
      });
      return;
    }
    ReferenceRunnerClient? client;
    setState(() {
      _checkingRunner = true;
      _runnerStatus = null;
    });
    try {
      client =
          widget.runnerClientFactory?.call(address, token) ??
          ReferenceRunnerClient(address, token: token);
      final health = await client.checkHealth();
      if (!mounted) return;
      setState(() {
        _runnerReady = health.ready;
        _runnerStatus = health.ready
            ? 'Connected. Ready: ${health.languages.map((language) => switch (language) {
                'cpp' => 'C++',
                'python' => 'Python',
                'javascript' => 'JavaScript',
                _ => 'TypeScript',
              }).join(', ')}.${address == store.preferences.runnerAddress && token == store.preferences.runnerToken ? '' : ' Save this connection to use Run.'}'
            : 'Runner reached, but no language runtime is ready. Start Docker and the pinned runner images on your PC.';
      });
    } on ArgumentError {
      if (mounted) {
        setState(() {
          _runnerReady = false;
          _runnerStatus =
              'Use a private HTTP address and a token of at least 32 characters for LAN access.';
        });
      }
    } on RunnerHealthException catch (error) {
      if (mounted) {
        setState(() {
          _runnerReady = false;
          _runnerStatus = error.message;
        });
      }
    } finally {
      client?.close();
      if (mounted) setState(() => _checkingRunner = false);
    }
  }

  Future<void> _setAiCoachConsent(bool enabled) async {
    if (!enabled) {
      await _savePreference(store.preferences.copyWith(aiCoachConsent: false));
      return;
    }
    final accepted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Allow Gemini AI coaching?'),
        content: const Text(
          'When you tap Ask AI, LoopLoom sends your current answer and a short problem context to Google Gemini. It does not send answers in the background. Gemini’s free tier may use submitted content to improve Google products. Do not include personal or confidential information. AI feedback is a suggestion, not a test result.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Not now'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Allow AI coach'),
          ),
        ],
      ),
    );
    if (accepted == true && mounted) {
      await _savePreference(store.preferences.copyWith(aiCoachConsent: true));
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _savingProfile = true);
    try {
      await store.updatePreferences(
        store.preferences.copyWith(
          displayName: _name.text.trim(),
          targetRole: _role.text.trim(),
          weeklyGoalDays: _weeklyGoalDays,
          dailyGoalMinutes: _dailyGoalMinutes,
          experienceLevel: _level,
          clearExperienceLevel: _level == null,
          targetInterviewDate: _targetDate,
          clearTargetInterviewDate: _targetDate == null,
        ),
      );
      if (mounted) {
        _showMessage('Profile and study goals saved on this device.');
      }
    } catch (_) {
      if (mounted) {
        _showMessage('Could not save your profile. Try again.');
      }
    } finally {
      if (mounted) {
        setState(() => _savingProfile = false);
      }
    }
  }

  void _showMessage(String message) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));

  Future<void> _chooseTargetDate() async {
    final today = DateUtils.dateOnly(DateTime.now());
    final initial = _targetDate ?? today.add(const Duration(days: 30));
    final selected = await showDatePicker(
      context: context,
      initialDate: initial.isBefore(today) ? today : initial,
      firstDate: today,
      lastDate: DateTime(today.year + 10),
      helpText: 'Target interview date',
    );
    if (selected != null && mounted) {
      setState(() => _targetDate = DateUtils.dateOnly(selected));
    }
  }

  Widget _sectionHeading(String label, String title, String subtitle) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label.toUpperCase(), style: noteLabel),
      const SizedBox(height: 8),
      Text(
        title,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 6),
      Text(
        subtitle,
        style: TextStyle(color: context.palette.muted, height: 1.55),
      ),
    ],
  );

  Widget _profileCard() {
    final name = _name.text.trim();
    final initial = name.isEmpty ? 'L' : name.substring(0, 1).toUpperCase();
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.palette.sheet,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.palette.line),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: context.palette.recess,
            foregroundColor: context.palette.ink,
            child: Text(
              initial,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.isEmpty ? 'Your learning profile' : name,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _role.text.trim().isEmpty
                      ? 'Interview preparation · private to this device'
                      : '${_role.text.trim()} · private to this device',
                  style: TextStyle(fontSize: 14, color: context.palette.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: store,
    builder: (context, _) => ReadableSurface(
      scale: store.preferences.textScale,
      child: Scaffold(
        appBar: AppBar(title: const Text('Profile & settings')),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
          children: [
            const Text('YOUR STUDY SPACE', style: noteLabel),
            const SizedBox(height: 10),
            const Text(
              'Set up for your next step.',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w600,
                letterSpacing: -.7,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Shape a quiet, practical place to prepare. Your profile and preferences are saved locally.',
              style: TextStyle(
                fontSize: 16,
                height: 1.6,
                color: context.palette.muted,
              ),
            ),
            const SizedBox(height: 22),
            _profileCard(),
            const SizedBox(height: 34),
            _sectionHeading(
              'Profile',
              'Your interview goal',
              'These details personalize your workbook and are optional.',
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(labelText: 'Name or nickname'),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _role,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: 'Target role (optional)',
                hintText: 'e.g. Backend engineer',
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 20),
            const Text('YOUR CURRENT EXPERIENCE', style: noteLabel),
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
              'Optional. This only changes the suggested path on Home.',
              style: TextStyle(fontSize: 14, color: context.palette.muted),
            ),
            const SizedBox(height: 20),
            const Text('TARGET INTERVIEW DATE', style: noteLabel),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _chooseTargetDate,
              icon: const Icon(Icons.event_outlined),
              label: Text(
                _targetDate == null
                    ? 'Add a target date'
                    : MaterialLocalizations.of(
                        context,
                      ).formatMediumDate(_targetDate!),
              ),
            ),
            if (_targetDate != null)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => setState(() => _targetDate = null),
                  icon: const Icon(Icons.close, size: 18),
                  label: const Text('Remove date'),
                ),
              ),
            const SizedBox(height: 20),
            const Text('PRACTICE DAYS EACH WEEK', style: noteLabel),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(7, (index) => index + 1)
                  .map(
                    (days) => ChoiceChip(
                      label: Text('$days ${days == 1 ? 'day' : 'days'}'),
                      selected: _weeklyGoalDays == days,
                      onSelected: (_) => setState(() => _weeklyGoalDays = days),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 20),
            const Text('DAILY PRACTICE TARGET', style: noteLabel),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [15, 30, 45, 60, 90, 120]
                  .map(
                    (minutes) => ChoiceChip(
                      label: Text('$minutes min'),
                      selected: _dailyGoalMinutes == minutes,
                      onSelected: (_) =>
                          setState(() => _dailyGoalMinutes = minutes),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _savingProfile ? null : _saveProfile,
              icon: const Icon(Icons.save_outlined),
              label: Text(
                _savingProfile ? 'Saving profile…' : 'Save profile and goals',
              ),
            ),
            const SizedBox(height: 36),
            const Divider(),
            const SizedBox(height: 24),
            _sectionHeading(
              'Accessibility',
              'Comfortable to read',
              'Choose a size for lesson prompts, examples, and settings throughout the app.',
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  const [
                        (1.0, 'Standard'),
                        (1.15, 'Comfortable'),
                        (1.3, 'Large'),
                        (1.5, 'Extra large'),
                      ]
                      .map(
                        (option) => ChoiceChip(
                          label: Text(option.$2),
                          selected:
                              (store.preferences.textScale - option.$1).abs() <
                              .01,
                          onSelected: (_) => _savePreference(
                            store.preferences.copyWith(textScale: option.$1),
                          ),
                        ),
                      )
                      .toList(),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: context.palette.recess,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'A clear line, a useful hint, and enough room to think.',
                style: TextStyle(
                  fontSize: 18,
                  height: 1.55,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'LoopLoom respects your device text setting as well.',
              style: TextStyle(fontSize: 14, color: context.palette.muted),
            ),
            const SizedBox(height: 34),
            const Divider(),
            const SizedBox(height: 24),
            _sectionHeading(
              'Optional cloud feature',
              'Gemini AI coach',
              'AI feedback only runs when you ask. The offline coach keeps working without internet.',
            ),
            const SizedBox(height: 12),
            if (store.coach is FirebaseAiCoachProvider)
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                value: store.preferences.aiCoachConsent,
                onChanged: _setAiCoachConsent,
                title: const Text('Allow AI feedback'),
                subtitle: Text(
                  store.preferences.aiCoachConsent
                      ? 'Your answers are sent only after you tap Ask AI. You can turn this off any time.'
                      : 'Review the data notice before enabling.',
                ),
              )
            else if (store.coach.enabled)
              const ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.science_outlined),
                title: Text('Experimental local AI is configured'),
                subtitle: Text(
                  'It is for development only. Its feedback has not passed the quality checks for learner use.',
                ),
              )
            else
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.cloud_off_outlined),
                title: const Text('Cloud AI is not configured'),
                subtitle: const Text(
                  'The offline coach is ready. Gemini requires the Firebase setup described in docs/AI_SETUP.md.',
                ),
              ),
            const SizedBox(height: 34),
            const Divider(),
            const SizedBox(height: 24),
            _sectionHeading(
              'Code practice',
              'Run your draft',
              'Use a Docker-backed runner on your own PC or server. Your phone and runner must share a trusted private network.',
            ),
            const SizedBox(height: 12),
            Text(
              'Study points: ${store.preferences.pointsBalance} · Reference code costs 10 points per problem and unlocks all four languages.',
              style: const TextStyle(fontSize: 15, height: 1.5),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _runnerAddress,
              onChanged: (_) => setState(() => _runnerStatus = null),
              keyboardType: TextInputType.url,
              autocorrect: false,
              decoration: const InputDecoration(
                labelText: 'Runner address',
                hintText: 'http://192.168.1.20:8766',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _runnerToken,
              onChanged: (_) => setState(() => _runnerStatus = null),
              obscureText: true,
              autocorrect: false,
              decoration: const InputDecoration(
                labelText: 'Runner access token',
                helperText:
                    'Use the same random token configured on the runner PC.',
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: _saveRunner,
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Save connection'),
                ),
                FilledButton.icon(
                  onPressed: _checkingRunner ? null : _testRunner,
                  icon: _checkingRunner
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.wifi_tethering, size: 18),
                  label: Text(
                    _checkingRunner ? 'Checking…' : 'Test connection',
                  ),
                ),
              ],
            ),
            if (_runnerStatus case final status?) ...[
              const SizedBox(height: 10),
              Semantics(
                liveRegion: true,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      _runnerReady
                          ? Icons.check_circle_outline
                          : Icons.info_outline,
                      size: 20,
                      color: _runnerReady
                          ? context.palette.accent
                          : context.palette.muted,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        status,
                        style: const TextStyle(fontSize: 15, height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              'The runner PC must be on when you tap Run. The hosted web app cannot call this HTTP LAN service; use the Android app or local preview. Reference code and edge cases stay available offline. Do not expose the runner to the internet.',
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: context.palette.muted,
              ),
            ),
            const SizedBox(height: 34),
            const Divider(),
            const SizedBox(height: 24),
            _sectionHeading(
              'Appearance',
              'Choose a theme',
              'System follows your device setting. Light and Dark stay selected on this device.',
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AppearancePreference.values.map((appearance) {
                final icon = switch (appearance) {
                  AppearancePreference.system =>
                    Icons.settings_suggest_outlined,
                  AppearancePreference.light => Icons.light_mode_outlined,
                  AppearancePreference.dark => Icons.dark_mode_outlined,
                };
                return ChoiceChip(
                  avatar: Icon(icon, size: 18),
                  label: Text(appearance.label),
                  selected: store.preferences.appearance == appearance,
                  onSelected: (_) => _savePreference(
                    store.preferences.copyWith(appearance: appearance),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 34),
            const Divider(),
            const SizedBox(height: 24),
            _sectionHeading(
              'Coaching',
              'Choose your working style',
              'This changes the prompts for new attempts. It does not change problem difficulty or correctness rules.',
            ),
            const SizedBox(height: 12),
            RadioGroup<CoachingPace>(
              groupValue: store.preferences.pace,
              onChanged: (value) {
                if (value != null) {
                  _savePreference(store.preferences.copyWith(pace: value));
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
                        activeColor: context.palette.ink,
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 18),
            const Text('DEFAULT CODE LANGUAGE', style: noteLabel),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: CodeLanguage.values
                  .map(
                    (language) => ChoiceChip(
                      label: Text(language.label),
                      selected: store.preferences.preferredLanguage == language,
                      onSelected: (_) => _savePreference(
                        store.preferences.copyWith(preferredLanguage: language),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 28),
            const Divider(),
            const SizedBox(height: 22),
            _sectionHeading(
              'Your data',
              'Private by default',
              'LoopLoom currently works without an online account. Practice history, profile details, and settings remain in this workbook on this device.',
            ),
            const SizedBox(height: 14),
            if (kIsWeb) ...[
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: context.palette.recess,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('INSTALL ON YOUR PHONE', style: noteLabel),
                    SizedBox(height: 8),
                    Text(
                      'Open your browser menu and choose Install app or Add to Home Screen. LoopLoom then opens like an app. Download the lessons once while online before practicing offline.',
                      style: TextStyle(fontSize: 15, height: 1.55),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            Text(
              'Use a workbook backup to move your attempts to another device. Backups are plain text and are not encrypted; store them somewhere you trust.',
              style: TextStyle(
                fontSize: 15,
                height: 1.6,
                color: context.palette.muted,
              ),
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed:
                  widget.onOpenBackup ??
                  () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => BackupScreen(store: store),
                    ),
                  ),
              icon: const Icon(Icons.inventory_2_outlined),
              label: const Text('Open workbook backup'),
            ),
            const SizedBox(height: 18),
            SaveStatus(store: store),
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 22),
            _sectionHeading(
              'Support',
              'Feedback & contact',
              'Report a bug, share an idea, or contact the LoopLoom team.',
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed:
                  widget.onOpenFeedback ??
                  () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const FeedbackScreen(),
                    ),
                  ),
              icon: const Icon(Icons.feedback_outlined),
              label: const Text('Feedback & contact'),
            ),
          ],
        ),
      ),
    ),
  );
}
