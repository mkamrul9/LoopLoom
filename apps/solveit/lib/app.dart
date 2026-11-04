import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'data/blind75_curriculum.dart';
import 'data/lesson_catalog.dart';
import 'data/mastery300_curriculum.dart';
import 'data/pilot_lessons.dart';
import 'data/interview_lessons.dart';
import 'data/interview_diagnostic.dart';
import 'domain/learner_preferences.dart';
import 'domain/lesson.dart';
import 'features/coaching/interview_diagnostic_screen.dart';
import 'features/coaching/practice_screen.dart';
import 'features/coaching/session_controller.dart';
import 'ui/looploom_theme.dart';
import 'ui/save_status.dart';
import 'ui/workbook_bootstrap.dart';
import 'ui/backup_screen.dart';
import 'ui/settings_screen.dart';
import 'ui/readable_surface.dart';

class LoopLoomApp extends StatefulWidget {
  const LoopLoomApp({super.key, this.store});
  final PracticeStore? store;

  @override
  State<LoopLoomApp> createState() => _LoopLoomAppState();
}

class _LoopLoomAppState extends State<LoopLoomApp> {
  ThemeMode _themeMode = ThemeMode.system;
  PracticeStore? _observedStore;

  ThemeMode _modeFor(AppearancePreference preference) => switch (preference) {
    AppearancePreference.system => ThemeMode.system,
    AppearancePreference.light => ThemeMode.light,
    AppearancePreference.dark => ThemeMode.dark,
  };

  void _observeStore(PracticeStore store) {
    if (identical(_observedStore, store)) return;
    _observedStore?.removeListener(_syncTheme);
    _observedStore = store;
    _themeMode = _modeFor(store.preferences.appearance);
    store.addListener(_syncTheme);
    if (mounted) setState(() {});
  }

  void _syncTheme() {
    final store = _observedStore;
    if (store == null) return;
    final next = _modeFor(store.preferences.appearance);
    if (next != _themeMode && mounted) setState(() => _themeMode = next);
  }

  @override
  void initState() {
    super.initState();
    final store = widget.store;
    if (store != null) _observeStore(store);
  }

  @override
  void didUpdateWidget(covariant LoopLoomApp oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.store, widget.store)) {
      final nextStore = widget.store;
      if (nextStore != null) {
        _observeStore(nextStore);
      } else {
        _observedStore?.removeListener(_syncTheme);
        _observedStore = null;
        setState(() => _themeMode = ThemeMode.system);
      }
    }
  }

  @override
  void dispose() {
    _observedStore?.removeListener(_syncTheme);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'LoopLoom — Think it through',
    debugShowCheckedModeBanner: false,
    theme: studyTheme(Brightness.light),
    darkTheme: studyTheme(Brightness.dark),
    themeMode: _themeMode,
    home: widget.store == null
        ? WorkbookBootstrap(
            onStoreReady: _observeStore,
            builder: (store) => LearningHome(store: store),
          )
        : LearningHome(store: widget.store!),
  );
}

class LearningHome extends StatefulWidget {
  const LearningHome({super.key, required this.store});
  final PracticeStore store;
  @override
  State<LearningHome> createState() => _LearningHomeState();
}

class _LearningHomeState extends State<LearningHome> {
  PracticeStore get store => widget.store;
  int selected = 0;
  int track = 3;
  String blindQuery = '';
  String blindDifficulty = 'All';
  String curriculumProgressFilter = 'All progress';
  bool savedOnly = false;
  String masteryMilestone = 'All';
  List<Lesson> get trackLessons => switch (track) {
    0 => pilotLessons,
    1 => interviewLessons,
    2 => starter30Lessons,
    3 => blind75Lessons,
    _ => mastery300Lessons,
  };

  String get trackTitle => switch (track) {
    0 => 'Interview warm-ups',
    1 => 'Intermediate foundations',
    2 => 'Starter 30',
    3 => 'Blind 75 · guided path',
    _ => 'Interview Mastery · 300',
  };
  int reviewedInTrack() => store.sessions
      .where(
        (s) =>
            s.stage == CoachingStage.complete &&
            trackLessons.any((l) => l.id == s.lesson.id),
      )
      .map((s) => s.lesson.id)
      .toSet()
      .length;
  Lesson? _diagnosticNextLesson(Set<String> selfReviewedIds) {
    if (track < 3 || store.preferences.diagnosticCompletedAt == null) {
      return null;
    }
    for (final question in interviewDiagnostic) {
      if (store.preferences.diagnosticScores[question.pattern] != 0) continue;
      final lesson = trackLessons
          .where(
            (item) =>
                item.pattern.toLowerCase().contains(question.patternNeedle) &&
                !selfReviewedIds.contains(item.id),
          )
          .firstOrNull;
      if (lesson != null) return lesson;
    }
    return null;
  }

  String progressFor(Lesson lesson) {
    final attempts = store.sessions.where((s) => s.lesson.id == lesson.id);
    if (attempts.any((s) => s.stage != CoachingStage.complete)) {
      return 'Resume';
    }
    if (attempts.any((s) => s.stage == CoachingStage.complete)) {
      return 'Self-reviewed';
    }
    return attempts.isEmpty ? 'Start' : 'Resume';
  }

  Widget trackPicker() => Wrap(
    spacing: 10,
    runSpacing: 8,
    children: [
      ChoiceChip(
        label: const Text('Warm-ups · 3'),
        selected: track == 0,
        onSelected: (_) => setState(() => track = 0),
      ),
      ChoiceChip(
        label: Text('Intermediate · ${interviewLessons.length}'),
        selected: track == 1,
        onSelected: (_) => setState(() => track = 1),
      ),
      ChoiceChip(
        label: Text('Starter 30 · ${starter30Lessons.length}'),
        selected: track == 2,
        onSelected: (_) => setState(() => track = 2),
      ),
      ChoiceChip(
        label: Text('Blind 75 · ${blind75Entries.length}'),
        selected: track == 3,
        onSelected: (_) => setState(() => track = 3),
      ),
      ChoiceChip(
        label: Text('Mastery · ${mastery300Entries.length}'),
        selected: track == 4,
        onSelected: (_) => setState(() => track = 4),
      ),
    ],
  );
  @override
  void dispose() {
    store.dispose();
    super.dispose();
  }

  void openLesson(Lesson lesson) {
    final session = store.startOrResume(lesson);
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PracticeScreen(session: session, store: store),
      ),
    );
  }

  Future<void> openDiagnostic() async {
    final lesson = await Navigator.of(context).push<Lesson>(
      MaterialPageRoute<Lesson>(
        builder: (_) => InterviewDiagnosticScreen(store: store),
      ),
    );
    if (!mounted) return;
    if (lesson != null) openLesson(lesson);
  }

  Future<void> toggleSaved(Lesson lesson) async {
    try {
      await store.toggleSaved(lesson);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not save this change locally. Try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: store,
    builder: (context, _) => ReadableSurface(
      scale: store.preferences.textScale,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 840;
          return Scaffold(
            appBar: AppBar(
              title: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LoopLoomWordmark(),
                        Text(
                          'THINK · TRACE · CODE',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: .8,
                            color: context.palette.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  tooltip: 'Profile & settings',
                  icon: const Icon(Icons.account_circle_outlined),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => SettingsScreen(store: store),
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  tooltip: 'Workbook options',
                  icon: const Icon(Icons.more_horiz),
                  constraints: const BoxConstraints(minWidth: 224),
                  onSelected: (option) => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => option == 'settings'
                          ? SettingsScreen(store: store)
                          : BackupScreen(store: store),
                    ),
                  ),
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: 'settings',
                      child: Row(
                        children: [
                          Icon(Icons.tune_outlined, size: 19),
                          SizedBox(width: 12),
                          Text('Profile & settings'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'backup',
                      child: Row(
                        children: [
                          Icon(Icons.inventory_2_outlined, size: 19),
                          SizedBox(width: 12),
                          Text('Workbook backup'),
                        ],
                      ),
                    ),
                  ],
                ),
                if (wide)
                  Padding(
                    padding: const EdgeInsets.only(right: 24),
                    child: SaveStatus(store: store, compact: true),
                  ),
              ],
              bottom: const PreferredSize(
                preferredSize: Size.fromHeight(1),
                child: Divider(),
              ),
            ),
            body: Row(
              children: [
                if (wide)
                  NavigationRail(
                    selectedIndex: selected,
                    onDestinationSelected: (v) => setState(() => selected = v),
                    labelType: NavigationRailLabelType.all,
                    destinations: const [
                      NavigationRailDestination(
                        icon: Icon(Icons.auto_stories_outlined),
                        label: Text('Learn'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.route_outlined),
                        label: Text('Roadmaps'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.history),
                        label: Text('History'),
                      ),
                    ],
                  ),
                if (wide) const VerticalDivider(width: 1),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      wide ? 48 : 24,
                      wide ? 42 : 30,
                      wide ? 48 : 24,
                      32,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 960),
                        child: selected == 0
                            ? _learn(wide)
                            : selected == 1
                            ? _roadmaps()
                            : _history(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            bottomNavigationBar: wide
                ? null
                : DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border(top: BorderSide(color: context.palette.line)),
                    ),
                    child: NavigationBar(
                      selectedIndex: selected,
                      onDestinationSelected: (v) =>
                          setState(() => selected = v),
                      destinations: const [
                        NavigationDestination(
                          icon: Icon(Icons.auto_stories_outlined),
                          label: 'Learn',
                        ),
                        NavigationDestination(
                          icon: Icon(Icons.route_outlined),
                          label: 'Roadmaps',
                        ),
                        NavigationDestination(
                          icon: Icon(Icons.history),
                          label: 'History',
                        ),
                      ],
                    ),
                  ),
          );
        },
      ),
    ),
  );

  Widget _learn(bool wide) {
    final selfReviewedIds = {
      for (final session in store.sessions)
        if (session.stage == CoachingStage.complete) session.lesson.id,
    };
    final activeSession = store.latestIncomplete;
    final diagnosticLesson = activeSession == null
        ? _diagnosticNextLesson(selfReviewedIds)
        : null;
    final allTrackLessonsReviewed = trackLessons.every(
      (lesson) => selfReviewedIds.contains(lesson.id),
    );
    final nextLesson =
        activeSession?.lesson ??
        diagnosticLesson ??
        trackLessons
            .where((lesson) => !selfReviewedIds.contains(lesson.id))
            .firstOrNull ??
        trackLessons.first;
    final nextNumber = trackLessons.indexWhere(
      (lesson) => lesson.id == nextLesson.id,
    );

    return _learnBody(
      wide,
      activeSession: activeSession,
      diagnosticLesson: diagnosticLesson,
      allTrackLessonsReviewed: allTrackLessonsReviewed,
      nextLesson: nextLesson,
      nextNumber: nextNumber,
    );
  }

  Widget _learnBody(
    bool wide, {
    required SessionController? activeSession,
    required Lesson? diagnosticLesson,
    required bool allTrackLessonsReviewed,
    required Lesson nextLesson,
    required int nextNumber,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('THE INTERVIEW WORKBOOK', style: noteLabel),
      const SizedBox(height: 18),
      Text(
        store.preferences.displayName.trim().isEmpty
            ? 'Think it through.'
            : 'Welcome back, ${store.preferences.displayName.trim()}.',
        style: TextStyle(
          fontSize: wide ? 42 : 34,
          height: 1.15,
          fontWeight: FontWeight.w500,
          letterSpacing: -1.7,
        ),
      ),
      const SizedBox(height: 12),
      Text(
        'One problem. A clearer way forward.',
        style: TextStyle(color: context.palette.muted, fontSize: 16, height: 1.5),
      ),
      if (!wide) ...[const SizedBox(height: 10), SaveStatus(store: store)],
      const SizedBox(height: 22),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: context.palette.recess,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('YOUR STUDY PLAN', style: noteLabel),
            const SizedBox(height: 8),
            Text(
              '${store.preferences.dailyGoalMinutes} minutes a day · ${store.preferences.weeklyGoalDays} days a week',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            if (store.preferences.targetRole.trim().isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Preparing for ${store.preferences.targetRole.trim()}',
                style: TextStyle(fontSize: 14, color: context.palette.muted),
              ),
            ],
            if (store.preferences.targetInterviewDate case final date?) ...[
              const SizedBox(height: 4),
              Text(
                'Target date · ${MaterialLocalizations.of(context).formatMediumDate(date)}',
                style: TextStyle(fontSize: 14, color: context.palette.muted),
              ),
            ],
          ],
        ),
      ),
      const SizedBox(height: 16),
      _diagnosticCard(),
      const SizedBox(height: 16),
      _reviewPlan(),
      const SizedBox(height: 32),
      Container(
        width: double.infinity,
        padding: EdgeInsets.all(wide ? 30 : 22),
        decoration: BoxDecoration(
          color: context.palette.sheet,
          border: Border.all(color: context.palette.line),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    activeSession != null
                        ? 'RESUME YOUR SESSION'
                        : diagnosticLesson != null
                        ? 'FROM YOUR QUICK CHECK'
                        : allTrackLessonsReviewed
                        ? 'REVISIT A LESSON'
                        : 'NEXT IN YOUR TRACK',
                    style: noteLabel,
                  ),
                ),
                Text(
                  activeSession != null
                      ? 'RESUME'
                      : allTrackLessonsReviewed
                      ? 'REVIEW'
                      : (nextNumber + 1).toString().padLeft(2, '0'),
                  style: TextStyle(
                    fontFamily: 'monospace',
                    color: context.palette.muted,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            Text(
              nextLesson.title,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w500,
                letterSpacing: -.8,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              activeSession != null
                  ? 'Continue from your ${activeSession.stage.label.toLowerCase()} checkpoint.'
                  : diagnosticLesson != null
                  ? 'Your check suggests revisiting ${nextLesson.pattern}. Start here, then continue through the unreviewed problems in this path.'
                  : allTrackLessonsReviewed
                  ? 'You have self-reviewed every lesson in $trackTitle. Start another attempt to practice recall, or choose another path.'
                  : 'Next unreviewed lesson in $trackTitle. Work through the approach, trace, code, and reflection at your pace.',
              style: TextStyle(
                fontSize: 15,
                height: 1.55,
                color: context.palette.muted,
              ),
            ),
            const SizedBox(height: 22),
            Wrap(
              spacing: 14,
              runSpacing: 8,
              children: [
                Text(nextLesson.pattern.toUpperCase(), style: noteLabel),
                Text(
                  pilotLessons.any((l) => l.id == nextLesson.id)
                      ? 'INTERVIEW WARM-UP'
                      : nextLesson.id.startsWith('blind75-')
                      ? 'BLIND 75'
                      : nextLesson.id.startsWith('mastery300-')
                      ? 'MASTERY 300'
                      : 'INTERMEDIATE',
                  style: noteLabel,
                ),
              ],
            ),
            const SizedBox(height: 26),
            FilledButton.icon(
              onPressed: () => openLesson(nextLesson),
              icon: const Icon(Icons.arrow_forward, size: 17),
              label: Text(
                activeSession != null
                    ? 'Resume practice'
                    : allTrackLessonsReviewed
                    ? 'Practice again'
                    : 'Start guided practice',
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 22),
      const Wrap(
        spacing: 16,
        runSpacing: 10,
        children: [
          Text('01  Understand', style: noteLabel),
          Text('02  Approach', style: noteLabel),
          Text('03  Trace', style: noteLabel),
          Text('04  Code', style: noteLabel),
          Text('05  Reflect', style: noteLabel),
        ],
      ),
      const SizedBox(height: 38),
      Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Expanded(
            child: Text(
              'Practice by pattern',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                letterSpacing: -.4,
              ),
            ),
          ),
          Text(
            '${reviewedInTrack()}/${trackLessons.length} SELF-REVIEWED',
            style: noteLabel,
          ),
        ],
      ),
      const SizedBox(height: 16),
      trackPicker(),
      const SizedBox(height: 12),
      if (track == 3 || track == 4) ...[
        _curriculumPath(track == 3 ? blind75Entries : mastery300Entries),
      ] else ...[
        ...trackLessons.indexed.map(
          (item) => _lessonTile(item.$2, item.$1 + 1),
        ),
      ],
      const SizedBox(height: 24),
      Text(
        'C++ / Python / JavaScript / TypeScript',
        style: TextStyle(fontSize: 12, color: context.palette.muted),
      ),
      const SizedBox(height: 10),
      Text(
        'Your workbook saves on this device. Guided checkpoints are self-reviewed; reference-case matches do not establish verified solves.',
        style: TextStyle(fontSize: 12, color: context.palette.muted, height: 1.6),
      ),
    ],
  );

  Widget _diagnosticCard() {
    final completedAt = store.preferences.diagnosticCompletedAt;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.palette.sheet,
        border: Border.all(color: context.palette.line),
        borderRadius: BorderRadius.circular(12),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 560;
          final copy = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('A QUICK STARTING POINT', style: noteLabel),
              const SizedBox(height: 8),
              Text(
                completedAt == null
                    ? 'Choose what to practice next.'
                    : 'Your next patterns are ready.',
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                completedAt == null
                    ? 'Answer eight short interview scenarios. Get a focused path from your results.'
                    : 'Retake the short check anytime to refresh your suggested practice order.',
                style: TextStyle(color: context.palette.muted, height: 1.5),
              ),
              if (completedAt != null) ...[
                const SizedBox(height: 7),
                Text(
                  'Last completed ${MaterialLocalizations.of(context).formatMediumDate(completedAt.toLocal())}',
                  style: TextStyle(fontSize: 13, color: context.palette.muted),
                ),
              ],
            ],
          );
          final action = FilledButton.icon(
            onPressed: openDiagnostic,
            icon: const Icon(Icons.route_outlined),
            label: Text(
              completedAt == null ? 'Start diagnostic' : 'View or retake',
            ),
          );
          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [copy, const SizedBox(height: 16), action],
            );
          }
          return Row(
            children: [
              Expanded(child: copy),
              const SizedBox(width: 16),
              action,
            ],
          );
        },
      ),
    );
  }

  Widget _lessonTile(Lesson lesson, int number, {String? title, String? tag}) =>
      Column(
        children: [
          const Divider(),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => openLesson(lesson),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  children: [
                    SizedBox(
                      width: 42,
                      child: Text(
                        number.toString().padLeft(2, '0'),
                        style: TextStyle(
                          fontFamily: 'monospace',
                          color: context.palette.muted,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(lesson.pattern.toUpperCase(), style: noteLabel),
                          const SizedBox(height: 7),
                          Text(
                            title ?? lesson.title,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            lesson.summary,
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.55,
                              color: context.palette.muted,
                            ),
                          ),
                          if (tag != null) ...[
                            const SizedBox(height: 8),
                            Text(tag.toUpperCase(), style: noteLabel),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      children: [
                        IconButton(
                          tooltip: store.isSaved(lesson)
                              ? 'Remove saved problem'
                              : 'Save problem',
                          icon: Icon(store.isSaved(lesson)
                              ? Icons.bookmark
                              : Icons.bookmark_border),
                          onPressed: () => toggleSaved(lesson),
                        ),
                        Text(
                          progressFor(lesson),
                          style: TextStyle(
                            fontSize: 13,
                            color: context.palette.muted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );

  Widget _reviewPlan({bool showAll = false}) {
    final now = DateTime.now();
    final schedule = store.reviewSchedule;
    final due = schedule.where((assignment) => assignment.isDueAt(now)).toList();
    final candidates = showAll || due.isEmpty ? schedule : due;
    final visible = showAll ? candidates : candidates.take(4).toList();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.palette.sheet,
        border: Border.all(color: context.palette.line),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(child: Text('SPACED PRACTICE', style: noteLabel)),
              Text(
                due.isEmpty
                    ? '${schedule.length} scheduled'
                    : '${due.length} due',
                style: TextStyle(
                  fontSize: 13,
                  color: context.palette.muted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            due.isEmpty ? 'Keep earlier patterns fresh.' : 'Time to revisit.',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 5),
          Text(
            'After self-review, revisit a problem in 1, 3, 7, then 14 days. Reviews are practice, not verified solves.',
            style: TextStyle(
              fontSize: 13,
              height: 1.55,
              color: context.palette.muted,
            ),
          ),
          if (visible.isEmpty) ...[
            const SizedBox(height: 12),
            const Text(
              'Complete a guided session to add your first review.',
              style: TextStyle(fontSize: 14),
            ),
          ] else ...[
            const SizedBox(height: 10),
            for (final assignment in visible)
              ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                title: Text(assignment.lesson.title),
                subtitle: Text(
                  assignment.isDueAt(now)
                      ? 'Due now · ${assignment.intervalDays}-day interval'
                      : 'Due ${MaterialLocalizations.of(context).formatMediumDate(assignment.dueAt.toLocal())}',
                ),
                trailing: TextButton(
                  onPressed: () => openLesson(assignment.lesson),
                  child: Text(assignment.isDueAt(now) ? 'Review' : 'Preview'),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _curriculumPath(List<Blind75Entry> entries) {
    final normalizedQuery = blindQuery.trim().toLowerCase();
    final milestoneLimit = switch (masteryMilestone) {
      'Core 75' => 75,
      'Core 150' => 150,
      'Breadth 250' => 250,
      'Mastery 300' => 300,
      _ => entries.length,
    };
    final milestoneEntries = entries.where((entry) {
      return entries.length != 300 || entry.number <= milestoneLimit;
    }).toList();
    final completedIds = store.sessions
        .where((session) => session.stage == CoachingStage.complete)
        .map((session) => session.lesson.id)
        .toSet();
    final activeIds = store.sessions
        .where((session) => session.stage != CoachingStage.complete)
        .map((session) => session.lesson.id)
        .toSet();
    String statusFor(Blind75Entry entry) {
      if (activeIds.contains(entry.lesson.id)) return 'In progress';
      if (completedIds.contains(entry.lesson.id)) return 'Self-reviewed';
      return 'Not started';
    }
    final pathPatterns = <String, List<Blind75Entry>>{};
    for (final entry in milestoneEntries) {
      pathPatterns.putIfAbsent(entry.pattern, () => []).add(entry);
    }
    final patternsStarted = pathPatterns.values
        .where(
          (pattern) => pattern.any((entry) => statusFor(entry) != 'Not started'),
        )
        .length;
    final reviewedCount = milestoneEntries
        .where((entry) => statusFor(entry) == 'Self-reviewed')
        .map((entry) => entry.lesson.id)
        .toSet()
        .length;
    final inProgressCount = milestoneEntries
        .where((entry) => statusFor(entry) == 'In progress')
        .map((entry) => entry.lesson.id)
        .toSet()
        .length;
    final visibleEntries = milestoneEntries.where((entry) {
      final matchesQuery =
          normalizedQuery.isEmpty ||
          entry.title.toLowerCase().contains(normalizedQuery) ||
          entry.pattern.toLowerCase().contains(normalizedQuery) ||
          entry.lesson.summary.toLowerCase().contains(normalizedQuery);
      final matchesDifficulty =
          blindDifficulty == 'All' || entry.difficulty == blindDifficulty;
      final status = statusFor(entry);
      final matchesProgress = switch (curriculumProgressFilter) {
        'Not self-reviewed' => status != 'Self-reviewed',
        'Self-reviewed' => status == 'Self-reviewed',
        _ => true,
      };
      return matchesQuery && matchesDifficulty &&
          matchesProgress && (!savedOnly || store.isSaved(entry.lesson));
    }).toList();
    final phases = <String, List<Blind75Entry>>{};
    for (final entry in visibleEntries) {
      phases.putIfAbsent(entry.phase, () => []).add(entry);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: context.palette.sheet,
            border: Border.all(color: context.palette.line),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entries.length == 75
                    ? 'LoopLoom’s prompts and explanations are original. This community study path links to the official LeetCode questions; LoopLoom is not affiliated with LeetCode.'
                    : 'This 300-problem path combines the Blind 75 with 225 curated interview challenges. Prompts guide your reasoning; official challenge pages provide full statements. LoopLoom is not affiliated with LeetCode.',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.6,
                  color: context.palette.muted,
                ),
              ),
              const SizedBox(height: 6),
              if (entries.length == 75)
                TextButton.icon(
                  onPressed: () async {
                    final opened = await launchUrl(
                      Uri.https('blind-75.com', '/'),
                      mode: LaunchMode.externalApplication,
                    );
                    if (!opened && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Could not open the list reference.'),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.open_in_new, size: 18),
                  label: const Text('View Blind 75 list reference'),
                ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        TextField(
          onChanged: (value) => setState(() => blindQuery = value),
          textInputAction: TextInputAction.search,
          decoration: const InputDecoration(
            labelText: 'Find a problem or pattern',
            prefixIcon: Icon(Icons.search),
            hintText: 'Try “trees” or “Two Sum”',
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ['All', 'Easy', 'Medium', 'Hard']
              .map(
                (level) => ChoiceChip(
                  label: Text(level),
                  selected: blindDifficulty == level,
                  onSelected: (_) => setState(() => blindDifficulty = level),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 8),
        FilterChip(
          label: const Text('Saved problems'),
          selected: savedOnly,
          onSelected: (value) => setState(() => savedOnly = value),
        ),
        const SizedBox(height: 8),
        const Text('PRACTICE STATUS', style: noteLabel),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ['All progress', 'Not self-reviewed', 'Self-reviewed']
              .map(
                (status) => ChoiceChip(
                  label: Text(status),
                  selected: curriculumProgressFilter == status,
                  onSelected: (_) =>
                      setState(() => curriculumProgressFilter = status),
                ),
              )
              .toList(),
        ),
        if (entries.length == 300) ...[
          const SizedBox(height: 12),
          const Text('STUDY MILESTONE', style: noteLabel),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                [
                  'All',
                  'Core 75',
                  'Core 150',
                  'Breadth 250',
                  'Mastery 300',
                ].map((milestone) {
                  final limit = switch (milestone) {
                    'Core 75' => 75,
                    'Core 150' => 150,
                    'Breadth 250' => 250,
                    'Mastery 300' => 300,
                    _ => entries.length,
                  };
                  final count = entries
                      .where((entry) => entry.number <= limit)
                      .length;
                  return ChoiceChip(
                    label: Text('$milestone · $count'),
                    selected: masteryMilestone == milestone,
                    onSelected: (_) =>
                        setState(() => masteryMilestone = milestone),
                  );
                }).toList(),
          ),
        ],
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: context.palette.sheet,
            border: Border.all(color: context.palette.line),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${visibleEntries.length} of ${milestoneEntries.length} problems shown · '
            '$reviewedCount self-reviewed · $inProgressCount in progress · '
            '$patternsStarted of ${pathPatterns.length} patterns practiced',
            style: TextStyle(fontSize: 14, color: context.palette.muted),
          ),
        ),
        if (visibleEntries.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Text('No problems match those filters.'),
          ),
        if (normalizedQuery.isNotEmpty)
          ...visibleEntries.map(
            (entry) => _lessonTile(
              entry.lesson,
              entry.number,
              title: entry.title,
              tag: entry.difficulty,
            ),
          )
        else
          ...phases.entries.map((phase) {
            final patterns = <String, List<Blind75Entry>>{};
            for (final entry in phase.value) {
              patterns.putIfAbsent(entry.pattern, () => []).add(entry);
            }
            return ExpansionTile(
              key: PageStorageKey<String>('blind-phase-${phase.key}'),
              tilePadding: const EdgeInsets.symmetric(horizontal: 4),
              title: Text(
                phase.key,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                '${phase.value.length} problems',
                style: const TextStyle(fontSize: 14),
              ),
              initiallyExpanded:
                  normalizedQuery.isNotEmpty ||
                  phase.key == entries.first.phase,
              children: patterns.entries.map((pattern) {
                final patternEntries = milestoneEntries
                    .where(
                      (entry) =>
                          entry.phase == phase.key &&
                          entry.pattern == pattern.key,
                    )
                    .toList();
                final patternReviewed = patternEntries
                    .where((entry) => statusFor(entry) == 'Self-reviewed')
                    .map((entry) => entry.lesson.id)
                    .toSet()
                    .length;
                final patternInProgress = patternEntries
                    .where((entry) => statusFor(entry) == 'In progress')
                    .map((entry) => entry.lesson.id)
                    .toSet()
                    .length;
                return ExpansionTile(
                  key: PageStorageKey<String>(
                    'blind-pattern-${phase.key}-${pattern.key}',
                  ),
                  tilePadding: const EdgeInsets.symmetric(horizontal: 12),
                  title: Text(
                    pattern.key,
                    style: const TextStyle(fontSize: 16),
                  ),
                  subtitle: Text(
                    '$patternReviewed of ${patternEntries.length} self-reviewed · '
                    '$patternInProgress in progress',
                    style: const TextStyle(fontSize: 14),
                  ),
                  initiallyExpanded: normalizedQuery.isNotEmpty,
                  children: pattern.value
                      .map(
                        (entry) => _lessonTile(
                          entry.lesson,
                          entry.number,
                          title: entry.title,
                          tag: entry.difficulty,
                        ),
                      )
                      .toList(),
                );
              }).toList(),
            );
          }),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _roadmaps() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('CHOOSE YOUR DIRECTION', style: noteLabel),
      const SizedBox(height: 18),
      const Text(
        'A path, at your pace.',
        style: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w500,
          letterSpacing: -1,
        ),
      ),
      const SizedBox(height: 12),
      Text(
        'Choose a focused track. Every lesson is available from the start; return to a pattern whenever you need it.',
        style: TextStyle(height: 1.6, color: context.palette.muted),
      ),
      const SizedBox(height: 32),
      trackPicker(),
      const SizedBox(height: 24),
      const Text('AVAILABLE NOW', style: noteLabel),
      const SizedBox(height: 10),
      Text(
        trackTitle,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
      ),
      const SizedBox(height: 10),
      Text(
        '${reviewedInTrack()} of ${trackLessons.length} self-reviewed · no test-verified solves yet',
        style: TextStyle(fontSize: 13, color: context.palette.muted),
      ),
      const SizedBox(height: 18),
      LinearProgressIndicator(
        value: reviewedInTrack() / trackLessons.length,
        minHeight: 3,
      ),
      const SizedBox(height: 24),
      Text(switch (track) {
        0 => 'Build confidence with lookup, sorted search, and fixed windows.',
        1 =>
          'Practice windows, search boundaries, strings, heaps, trees, linked lists, graphs, backtracking, and dynamic programming.',
        2 =>
          'The starter path combines three warm-ups with twenty-seven intermediate pattern lessons.',
        3 =>
          'A 75-question interview-preparation path arranged by patterns and study phases, with one guided reasoning sequence per problem.',
        _ =>
          'A 300-problem interview path across core and advanced patterns. Each challenge has five guided reasoning checkpoints and links to its official statement.',
      }, style: TextStyle(fontSize: 13, height: 1.65, color: context.palette.muted)),
      const SizedBox(height: 16),
      if (track == 3 || track == 4) ...[
        _curriculumPath(track == 3 ? blind75Entries : mastery300Entries),
      ] else ...[
        ...trackLessons.indexed.map(
          (item) => _lessonTile(item.$2, item.$1 + 1),
        ),
      ],
      const SizedBox(height: 32),
      const Text('300-PROBLEM ROADMAP', style: noteLabel),
      const SizedBox(height: 14),
      _mastery300Plan(),
      const SizedBox(height: 16),
      Text(
        'The available 30 lessons are original drafts with five guided checkpoints each. They are useful for practice, but still need independent editorial review before a reviewed interview curriculum can be claimed.',
        style: TextStyle(fontSize: 12, height: 1.65, color: context.palette.muted),
      ),
    ],
  );

  Widget _mastery300Plan() {
    const patterns = <(String, int)>[
      ('Arrays, strings & hashing', 26),
      ('Two pointers', 15),
      ('Sliding window', 11),
      ('Binary search', 16),
      ('Linked lists', 16),
      ('Stacks & monotonic structures', 16),
      ('Trees & BSTs', 27),
      ('Tries', 5),
      ('Backtracking', 19),
      ('Heaps & top-k', 15),
      ('Graph traversal & modeling', 25),
      ('Advanced graphs', 15),
      ('One-dimensional DP', 21),
      ('Two-dimensional DP', 20),
      ('Greedy', 17),
      ('Intervals', 9),
      ('Bit manipulation', 12),
      ('Math & geometry', 15),
    ];
    const milestones = <(String, String)>[
      ('Core 75', 'Blind 75 · available'),
      ('Core 150', 'Available · deepen the core patterns'),
      ('Breadth 250', 'Available · practice across every family'),
      ('Mastery 300', 'Available · advanced and mixed-pattern practice'),
    ];
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        key: const PageStorageKey<String>('mastery-300-plan'),
        leading: const Icon(Icons.route_outlined),
        title: const Text('Interview Mastery · 300'),
        subtitle: Text(
          '${mastery300Entries.length} guided problems · 18 target pattern families',
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'A staged interview path: learn the core patterns, widen coverage, then practice advanced variants and mixed-pattern problems. All 300 challenge entries are available; official challenge pages provide full problem statements.',
            style: TextStyle(height: 1.6, color: context.palette.muted),
          ),
          const SizedBox(height: 16),
          for (final milestone in milestones)
            ListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              leading: Icon(
                milestone.$1 == 'Core 75'
                    ? Icons.check_circle_outline
                    : Icons.circle_outlined,
              ),
              title: Text(milestone.$1),
              subtitle: Text(milestone.$2),
              trailing: const Text('LIVE', style: noteLabel),
            ),
          const Divider(height: 28),
          Text(
            'PATTERN TARGETS · ${patterns.fold<int>(0, (sum, item) => sum + item.$2)} TOTAL',
            style: noteLabel,
          ),
          const SizedBox(height: 8),
          for (final pattern in patterns)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                children: [
                  Expanded(child: Text(pattern.$1)),
                  Text('${pattern.$2}'),
                ],
              ),
            ),
          const SizedBox(height: 12),
          Text(
            'Problem choices will favor reusable interview techniques and topic coverage. “Interview relevant” is a curation goal, not a promise about any specific company or interview.',
            style: TextStyle(
              fontSize: 13,
              height: 1.55,
              color: context.palette.muted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _history() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('YOUR WORK, REVISITED', style: noteLabel),
      const SizedBox(height: 18),
      const Text(
        'A record of your thinking.',
        style: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w500,
          letterSpacing: -1,
        ),
      ),
      const SizedBox(height: 12),
      Text(
        'Your attempts, drafts, and the questions that helped.',
        style: TextStyle(color: context.palette.muted, height: 1.6),
      ),
      const SizedBox(height: 10),
      Text(
        'Saved on this device. Clearing browser data or uninstalling the app removes local work.',
        style: TextStyle(fontSize: 12, color: context.palette.muted),
      ),
      const SizedBox(height: 18),
      _savedProblems(),
      const SizedBox(height: 18),
      _reviewPlan(showAll: true),
      const SizedBox(height: 32),
      if (store.unavailableAttempts > 0)
        Text(
          '${store.unavailableAttempts} older attempts could not be opened. Their saved records have been kept.',
          style: const TextStyle(fontSize: 12, height: 1.6),
        ),
      if (store.sessions.isEmpty)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(),
            const SizedBox(height: 24),
            const Text(
              'Your first attempt starts here.',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: () => openLesson(interviewLessons.first),
              child: const Text('Try a lesson'),
            ),
          ],
        ),
      ...store.sessions.map(
        (session) => Column(
          children: [
            const Divider(),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
              title: Text(
                session.lesson.title,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              subtitle: Text(
                'Attempt ${session.attemptNumber} · ${session.stage.label}\n${session.language.label} · ${session.hintsUsed} hints${session.solutionRevealed ? ' · solution viewed' : ''}',
              ),
              isThreeLine: true,
              trailing: const Icon(Icons.north_east, size: 17),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) =>
                      PracticeScreen(session: session, store: store),
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );

  Widget _savedProblems() {
    final lessons = allLessons.where(store.isSaved).toList();
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        leading: const Icon(Icons.bookmark_border),
        title: const Text('Saved problems'),
        subtitle: Text('${lessons.length} saved'),
        children: lessons.isEmpty
            ? const [
                Padding(
                  padding: EdgeInsets.all(18),
                  child: Text('Save a problem from a roadmap to return to it here.'),
                ),
              ]
            : lessons.map((lesson) => ListTile(
                title: Text(lesson.title),
                subtitle: Text(lesson.pattern),
                trailing: const Icon(Icons.north_east, size: 17),
                onTap: () => openLesson(lesson),
              )).toList(),
      ),
    );
  }
}
