import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'data/blind75_curriculum.dart';
import 'data/lesson_catalog.dart';
import 'data/mastery300_curriculum.dart';
import 'data/pilot_lessons.dart';
import 'data/interview_lessons.dart';
import 'data/interview_sprints.dart';
import 'data/path_recommendation.dart';
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
import 'ui/onboarding_screen.dart';
import 'ui/feedback_screen.dart';
import 'ui/readable_surface.dart';

CustomTransitionPage<T> _studyPage<T>(
  GoRouterState state,
  Widget child,
) => CustomTransitionPage<T>(
  key: state.pageKey,
  child: child,
  transitionDuration: const Duration(milliseconds: 190),
  reverseTransitionDuration: const Duration(milliseconds: 150),
  transitionsBuilder: (context, animation, secondaryAnimation, child) {
    if (MediaQuery.disableAnimationsOf(context)) return child;
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, .025), end: Offset.zero)
            .animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            ),
        child: child,
      ),
    );
  },
);

class LoopLoomApp extends StatefulWidget {
  const LoopLoomApp({super.key, this.store, this.initialLocation});
  final PracticeStore? store;
  final String? initialLocation;

  @override
  State<LoopLoomApp> createState() => _LoopLoomAppState();
}

class _LoopLoomAppState extends State<LoopLoomApp> {
  ThemeMode _themeMode = ThemeMode.system;
  PracticeStore? _observedStore;
  PracticeStore? _routerStore;
  GoRouter? _router;

  ThemeMode _modeFor(AppearancePreference preference) => switch (preference) {
    AppearancePreference.system => ThemeMode.system,
    AppearancePreference.light => ThemeMode.light,
    AppearancePreference.dark => ThemeMode.dark,
  };

  void _observeStore(PracticeStore store) {
    if (identical(_observedStore, store)) return;
    final previousStore = _observedStore;
    previousStore?.removeListener(_syncTheme);
    _observedStore = store;
    _themeMode = _modeFor(store.preferences.appearance);
    store.addListener(_syncTheme);
    if (previousStore != null) {
      previousStore.dispose();
    }
    if (mounted) setState(() {});
  }

  GoRouter _routerFor(PracticeStore store) {
    if (identical(_routerStore, store) && _router != null) return _router!;
    _router?.dispose();
    _routerStore = store;
    const tabLocations = ['/learn', '/roadmaps', '/history'];
    const practiceNames = [
      'practice-learn',
      'practice-roadmaps',
      'practice-history',
    ];
    GoRoute practiceRoute(String name) => GoRoute(
      path: 'problem/:lessonId',
      name: name,
      pageBuilder: (context, state) {
        final lessonId = state.pathParameters['lessonId'];
        final lesson = allLessons
            .where((item) => item.id == lessonId)
            .firstOrNull;
        if (lesson == null) {
          return _studyPage<void>(state, const _RouteNotFound());
        }
        final attemptId = state.uri.queryParameters['attempt'];
        final session =
            store.sessions.where((item) => item.id == attemptId).firstOrNull ??
            store.startOrResume(lesson);
        return _studyPage<void>(
          state,
          PracticeScreen(session: session, store: store),
        );
      },
    );

    _router = GoRouter(
      initialLocation: widget.initialLocation,
      overridePlatformDefaultLocation: widget.initialLocation != null,
      routes: [
        GoRoute(path: '/', redirect: (_, _) => '/learn'),
        GoRoute(
          path: '/problem/:lessonId',
          redirect: (_, state) {
            final lessonId = state.pathParameters['lessonId'] ?? '';
            final query = state.uri.hasQuery ? '?${state.uri.query}' : '';
            return '/learn/problem/${Uri.encodeComponent(lessonId)}$query';
          },
        ),
        ShellRoute(
          builder: (context, state, child) {
            final path = state.uri.path;
            final selected = path.startsWith('/roadmaps')
                ? 1
                : path.startsWith('/history')
                ? 2
                : 0;
            final isTabRoot =
                path == '/learn' || path == '/roadmaps' || path == '/history';
            return LearningHome(
              store: store,
              closeStoreOnDispose: false,
              initialSelected: selected,
              routeChild: isTabRoot ? null : child,
              onTabSelected: (index) => context.go(tabLocations[index]),
              onOpenLesson: (lesson) => context.pushNamed(
                practiceNames[selected],
                pathParameters: {'lessonId': lesson.id},
              ),
              onOpenAttempt: (session) => context.pushNamed(
                practiceNames[selected],
                pathParameters: {'lessonId': session.lesson.id},
                queryParameters: {'attempt': session.id},
              ),
              onOpenDiagnostic: () => context.pushNamed<Lesson>('diagnostic'),
              onOpenOnboarding: () => context.pushNamed<bool>('onboarding'),
              onOpenFeedback: () => context.pushNamed('feedback'),
              onOpenSettings: () => context.pushNamed('settings'),
              onOpenBackup: () => context.pushNamed('backup'),
            );
          },
          routes: [
            GoRoute(
              path: '/learn',
              builder: (_, _) => const SizedBox.shrink(),
              routes: [practiceRoute(practiceNames[0])],
            ),
            GoRoute(
              path: '/roadmaps',
              builder: (_, _) => const SizedBox.shrink(),
              routes: [practiceRoute(practiceNames[1])],
            ),
            GoRoute(
              path: '/history',
              builder: (_, _) => const SizedBox.shrink(),
              routes: [practiceRoute(practiceNames[2])],
            ),
            GoRoute(
              path: '/diagnostic',
              name: 'diagnostic',
              pageBuilder: (_, state) => _studyPage<Lesson>(
                state,
                InterviewDiagnosticScreen(store: store),
              ),
            ),
            GoRoute(
              path: '/settings',
              name: 'settings',
              pageBuilder: (context, state) => _studyPage<void>(
                state,
                SettingsScreen(
                  store: store,
                  onOpenBackup: () => context.pushNamed('backup'),
                  onOpenFeedback: () => context.pushNamed('feedback'),
                ),
              ),
            ),
            GoRoute(
              path: '/onboarding',
              name: 'onboarding',
              pageBuilder: (_, state) =>
                  _studyPage<bool>(state, OnboardingScreen(store: store)),
            ),
            GoRoute(
              path: '/feedback',
              name: 'feedback',
              pageBuilder: (_, state) =>
                  _studyPage<void>(state, const FeedbackScreen()),
            ),
            GoRoute(
              path: '/backup',
              name: 'backup',
              pageBuilder: (_, state) =>
                  _studyPage<void>(state, BackupScreen(store: store)),
            ),
          ],
        ),
      ],
      errorBuilder: (_, _) => const _RouteNotFound(),
    );
    return _router!;
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
        final previousStore = _observedStore;
        _observedStore?.removeListener(_syncTheme);
        _observedStore = null;
        _router?.dispose();
        _router = null;
        _routerStore = null;
        previousStore?.dispose();
        setState(() => _themeMode = ThemeMode.system);
      }
    }
  }

  @override
  void dispose() {
    _observedStore?.removeListener(_syncTheme);
    _router?.dispose();
    _observedStore?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = widget.store ?? _observedStore;
    if (store == null) {
      return MaterialApp(
        title: 'LoopLoom — Think it through',
        debugShowCheckedModeBanner: false,
        theme: studyTheme(Brightness.light),
        darkTheme: studyTheme(Brightness.dark),
        themeMode: _themeMode,
        home: WorkbookBootstrap(
          onStoreReady: _observeStore,
          builder: (_) => const SizedBox.shrink(),
        ),
      );
    }
    return MaterialApp.router(
      title: 'LoopLoom — Think it through',
      debugShowCheckedModeBanner: false,
      theme: studyTheme(Brightness.light),
      darkTheme: studyTheme(Brightness.dark),
      themeMode: _themeMode,
      routerConfig: _routerFor(store),
    );
  }
}

class _RouteNotFound extends StatelessWidget {
  const _RouteNotFound();

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off_outlined, size: 44),
            const SizedBox(height: 16),
            const Text('We could not find that LoopLoom page.'),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => context.go('/learn'),
              child: const Text('Go to Learn'),
            ),
          ],
        ),
      ),
    ),
  );
}

class LearningHome extends StatefulWidget {
  const LearningHome({
    super.key,
    required this.store,
    this.closeStoreOnDispose = true,
    this.initialSelected = 0,
    this.onTabSelected,
    this.onOpenLesson,
    this.onOpenAttempt,
    this.onOpenDiagnostic,
    this.onOpenOnboarding,
    this.onOpenFeedback,
    this.onOpenSettings,
    this.onOpenBackup,
    this.routeChild,
  });
  final PracticeStore store;
  final bool closeStoreOnDispose;
  final int initialSelected;
  final ValueChanged<int>? onTabSelected;
  final ValueChanged<Lesson>? onOpenLesson;
  final ValueChanged<SessionController>? onOpenAttempt;
  final Future<Lesson?> Function()? onOpenDiagnostic;
  final Future<bool?> Function()? onOpenOnboarding;
  final VoidCallback? onOpenFeedback;
  final VoidCallback? onOpenSettings, onOpenBackup;
  final Widget? routeChild;
  @override
  State<LearningHome> createState() => _LearningHomeState();
}

class _LearningHomeState extends State<LearningHome> {
  PracticeStore get store => widget.store;
  late final TextEditingController _historySearchController;
  int selected = 0;
  int track = 3;
  String blindQuery = '';
  String blindDifficulty = 'All';
  String curriculumProgressFilter = 'All progress';
  String historyQuery = '';
  String historyFilter = 'All attempts';
  bool savedOnly = false;
  String masteryMilestone = 'All';

  @override
  void initState() {
    super.initState();
    _historySearchController = TextEditingController();
    selected = widget.initialSelected;
    track = store.preferences.selectedTrack;
  }

  @override
  void didUpdateWidget(covariant LearningHome oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialSelected != widget.initialSelected) {
      selected = widget.initialSelected;
    }
  }

  List<Lesson> get trackLessons => switch (track) {
    0 => pilotLessons,
    1 => interviewLessons,
    2 => starter30Lessons,
    3 => blind75Lessons,
    4 => mastery300Lessons,
    5 => oneWeekInterviewSprint.lessons,
    _ => lastDayInterviewSprint.lessons,
  };

  String get trackTitle => switch (track) {
    0 => 'Interview warm-ups',
    1 => 'Intermediate foundations',
    2 => 'Starter 30',
    3 => 'Blind 75 · guided path',
    4 => 'Interview Mastery · 300',
    5 => oneWeekInterviewSprint.title,
    _ => lastDayInterviewSprint.title,
  };

  void _clearHistorySearch() {
    _historySearchController.clear();
    setState(() => historyQuery = '');
  }

  void _resetHistoryFilters() {
    _historySearchController.clear();
    setState(() {
      historyQuery = '';
      historyFilter = 'All attempts';
    });
  }

  void _selectTrack(int value) {
    if (track == value) return;
    setState(() => track = value);
    unawaited(_persistSelectedTrack(value));
  }

  Future<void> _persistSelectedTrack(int value) async {
    try {
      await store.updatePreferences(
        store.preferences.copyWith(selectedTrack: value),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'The selected roadmap could not be saved on this device.',
          ),
        ),
      );
    }
  }

  Future<void> _confirmDeleteAttempt(SessionController session) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete this attempt?'),
        content: Text(
          'This removes attempt ${session.attemptNumber} for '
          '${session.lesson.title}, including its saved reasoning, code drafts, '
          'and coach history. This cannot be undone. Other attempts and saved '
          'problems will stay in your workbook.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Keep attempt'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete attempt'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await store.deleteAttempt(session.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Attempt deleted from this device.')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not delete the attempt. Your history is unchanged.',
          ),
        ),
      );
    }
  }

  int reviewedInTrack() => store.sessions
      .where(
        (s) =>
            s.stage == CoachingStage.complete &&
            trackLessons.any((l) => l.id == s.lesson.id),
      )
      .map((s) => s.lesson.id)
      .toSet()
      .length;
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

  Widget trackPicker() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Wrap(
        spacing: 10,
        runSpacing: 8,
        children: [
          ChoiceChip(
            label: const Text('Warm-ups · 3'),
            selected: track == 0,
            onSelected: (_) => _selectTrack(0),
          ),
          ChoiceChip(
            label: Text('Intermediate · ${interviewLessons.length}'),
            selected: track == 1,
            onSelected: (_) => _selectTrack(1),
          ),
          ChoiceChip(
            label: Text('Starter 30 · ${starter30Lessons.length}'),
            selected: track == 2,
            onSelected: (_) => _selectTrack(2),
          ),
          ChoiceChip(
            label: Text('Blind 75 · ${blind75Entries.length}'),
            selected: track == 3,
            onSelected: (_) => _selectTrack(3),
          ),
          ChoiceChip(
            label: Text('Mastery · ${mastery300Entries.length}'),
            selected: track == 4,
            onSelected: (_) => _selectTrack(4),
          ),
        ],
      ),
      const SizedBox(height: 14),
      const Text('SHORT INTERVIEW PREP', style: noteLabel),
      const SizedBox(height: 6),
      Wrap(
        spacing: 10,
        runSpacing: 8,
        children: [
          ChoiceChip(
            label: const Text('One week · 25'),
            selected: track == 5,
            onSelected: (_) => _selectTrack(5),
          ),
          ChoiceChip(
            label: const Text('Last day · 7'),
            selected: track == 6,
            onSelected: (_) => _selectTrack(6),
          ),
        ],
      ),
    ],
  );
  @override
  void dispose() {
    _historySearchController.dispose();
    if (widget.closeStoreOnDispose) store.dispose();
    super.dispose();
  }

  void openLesson(Lesson lesson) {
    final onOpenLesson = widget.onOpenLesson;
    if (onOpenLesson != null) {
      onOpenLesson(lesson);
      return;
    }
    final session = store.startOrResume(lesson);
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PracticeScreen(session: session, store: store),
      ),
    );
  }

  void openAttempt(SessionController session) {
    final onOpenAttempt = widget.onOpenAttempt;
    if (onOpenAttempt != null) {
      onOpenAttempt(session);
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PracticeScreen(session: session, store: store),
      ),
    );
  }

  void _selectTab(int value) {
    final onTabSelected = widget.onTabSelected;
    if (onTabSelected == null) {
      setState(() => selected = value);
    } else {
      onTabSelected(value);
    }
  }

  Future<void> openDiagnostic() async {
    final onOpenDiagnostic = widget.onOpenDiagnostic;
    final lesson = onOpenDiagnostic == null
        ? await Navigator.of(context).push<Lesson>(
            MaterialPageRoute<Lesson>(
              builder: (_) => InterviewDiagnosticScreen(store: store),
            ),
          )
        : await onOpenDiagnostic();
    if (!mounted) return;
    if (lesson != null) openLesson(lesson);
  }

  Future<void> openOnboarding() async {
    final takeCheck = widget.onOpenOnboarding == null
        ? await Navigator.of(context).push<bool>(
            MaterialPageRoute<bool>(
              builder: (_) => OnboardingScreen(store: store),
            ),
          )
        : await widget.onOpenOnboarding!();
    if (mounted && takeCheck == true) await openDiagnostic();
  }

  void openFeedback() {
    final callback = widget.onOpenFeedback;
    if (callback != null) {
      callback();
    } else {
      Navigator.of(
        context,
      ).push(MaterialPageRoute<void>(builder: (_) => const FeedbackScreen()));
    }
  }

  Future<void> toggleSaved(Lesson lesson) async {
    try {
      await store.toggleSaved(lesson);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not save this change locally. Try again.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final routeChild = widget.routeChild;
    if (routeChild != null) return routeChild;
    return ListenableBuilder(
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
                    onPressed:
                        widget.onOpenSettings ??
                        () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => SettingsScreen(store: store),
                          ),
                        ),
                  ),
                  PopupMenuButton<String>(
                    tooltip: 'Workbook options',
                    icon: const Icon(Icons.more_horiz),
                    constraints: const BoxConstraints(minWidth: 224),
                    onSelected: (option) {
                      if (option == 'settings') {
                        final openSettings = widget.onOpenSettings;
                        if (openSettings != null) {
                          openSettings();
                        } else {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => SettingsScreen(store: store),
                            ),
                          );
                        }
                      } else if (option == 'feedback') {
                        openFeedback();
                      } else {
                        final openBackup = widget.onOpenBackup;
                        if (openBackup != null) {
                          openBackup();
                        } else {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => BackupScreen(store: store),
                            ),
                          );
                        }
                      }
                    },
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
                        value: 'feedback',
                        child: Row(
                          children: [
                            Icon(Icons.feedback_outlined, size: 19),
                            SizedBox(width: 12),
                            Text('Feedback & contact'),
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
                      onDestinationSelected: _selectTab,
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
                          child: AnimatedSwitcher(
                            duration: MediaQuery.disableAnimationsOf(context)
                                ? Duration.zero
                                : const Duration(milliseconds: 180),
                            transitionBuilder: (child, animation) =>
                                FadeTransition(
                                  opacity: animation,
                                  child: child,
                                ),
                            child: KeyedSubtree(
                              key: ValueKey(selected),
                              child: selected == 0
                                  ? _learn(wide)
                                  : selected == 1
                                  ? _roadmaps()
                                  : _history(),
                            ),
                          ),
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
                        border: Border(
                          top: BorderSide(color: context.palette.line),
                        ),
                      ),
                      child: NavigationBar(
                        selectedIndex: selected,
                        onDestinationSelected: _selectTab,
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
  }

  Widget _learn(bool wide) {
    final selfReviewedIds = {
      for (final session in store.sessions)
        if (session.stage == CoachingStage.complete) session.lesson.id,
    };
    final activeSession = store.latestIncomplete;
    final dueReview = activeSession == null
        ? store.dueReviewsAt(DateTime.now()).firstOrNull
        : null;
    final allTrackLessonsReviewed = trackLessons.every(
      (lesson) => selfReviewedIds.contains(lesson.id),
    );
    final nextLesson =
        activeSession?.lesson ??
        dueReview?.lesson ??
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
      dueReview: dueReview,
      allTrackLessonsReviewed: allTrackLessonsReviewed,
      nextLesson: nextLesson,
      nextNumber: nextNumber,
    );
  }

  Widget _learnBody(
    bool wide, {
    required SessionController? activeSession,
    required ReviewAssignment? dueReview,
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
        style: TextStyle(
          color: context.palette.muted,
          fontSize: 16,
          height: 1.5,
        ),
      ),
      if (!wide) ...[const SizedBox(height: 10), SaveStatus(store: store)],
      const SizedBox(height: 22),
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
                        : dueReview != null
                        ? "TODAY'S REVIEW"
                        : allTrackLessonsReviewed
                        ? 'REVISIT A LESSON'
                        : 'NEXT IN YOUR TRACK',
                    style: noteLabel,
                  ),
                ),
                Text(
                  activeSession != null
                      ? 'RESUME'
                      : dueReview != null
                      ? 'DUE'
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
            if (!wide) ...[
              const SizedBox(height: 18),
              _nextLessonAction(
                nextLesson,
                activeSession,
                dueReview,
                allTrackLessonsReviewed,
              ),
            ],
            const SizedBox(height: 10),
            Text(
              activeSession != null
                  ? 'Continue from your ${activeSession.stage.label.toLowerCase()} checkpoint.'
                  : dueReview != null
                  ? 'A ${dueReview.intervalDays}-day recall check is due. Try the problem from memory before reviewing your notes.'
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
            if (wide) ...[
              const SizedBox(height: 26),
              _nextLessonAction(
                nextLesson,
                activeSession,
                dueReview,
                allTrackLessonsReviewed,
              ),
            ],
          ],
        ),
      ),
      if (!store.preferences.onboardingSeen) ...[
        const SizedBox(height: 16),
        _startingPointCard(),
      ],
      if (recommendPath(store.preferences) case final suggestion?) ...[
        const SizedBox(height: 16),
        _recommendationCard(suggestion),
      ],
      const SizedBox(height: 20),
      ExpansionTile(
        tilePadding: EdgeInsets.zero,
        title: const Text(
          'Study plan & review',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
        subtitle: const Text(
          'Goals, weekly progress, quick check, and due reviews',
        ),
        children: [
          _studyPlanCard(),
          const SizedBox(height: 16),
          _weeklyPracticeCard(),
          const SizedBox(height: 16),
          _diagnosticCard(),
          const SizedBox(height: 16),
          _reviewPlan(),
          const SizedBox(height: 16),
        ],
      ),
      const SizedBox(height: 30),
      LayoutBuilder(
        builder: (context, constraints) {
          final heading = const Text(
            'Practice by pattern',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              letterSpacing: -.4,
            ),
          );
          final progress = Text(
            '${reviewedInTrack()}/${trackLessons.length} SELF-REVIEWED',
            style: noteLabel,
          );
          if (constraints.maxWidth < 420) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [heading, const SizedBox(height: 4), progress],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(child: heading),
              progress,
            ],
          );
        },
      ),
      const SizedBox(height: 16),
      trackPicker(),
      const SizedBox(height: 12),
      if (track == 3 || track == 4) ...[
        _curriculumPath(track == 3 ? blind75Entries : mastery300Entries),
      ] else if (track == 5 || track == 6) ...[
        _interviewSprintPath(
          track == 5 ? oneWeekInterviewSprint : lastDayInterviewSprint,
        ),
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
        style: TextStyle(
          fontSize: 12,
          color: context.palette.muted,
          height: 1.6,
        ),
      ),
    ],
  );

  Widget _nextLessonAction(
    Lesson lesson,
    SessionController? activeSession,
    ReviewAssignment? dueReview,
    bool allTrackLessonsReviewed,
  ) => FilledButton.icon(
    onPressed: () => openLesson(lesson),
    icon: const Icon(Icons.arrow_forward, size: 17),
    label: Text(
      activeSession != null
          ? 'Resume practice'
          : dueReview != null
          ? 'Review now'
          : allTrackLessonsReviewed
          ? 'Practice again'
          : 'Start guided practice',
    ),
  );

  Widget _studyPlanCard() => Container(
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
  );

  Widget _startingPointCard() {
    if (store.preferences.onboardingSeen) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.palette.accentWash,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('OPTIONAL SETUP', style: noteLabel),
          const SizedBox(height: 8),
          const Text(
            'Make this workbook yours.',
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          const Text(
            'Tell us your experience and study goal to get a suggested path. You can explore every roadmap at any time.',
            style: TextStyle(fontSize: 15, height: 1.5),
          ),
          const SizedBox(height: 12),
          FilledButton.tonal(
            onPressed: openOnboarding,
            child: const Text('Set up my starting point'),
          ),
        ],
      ),
    );
  }

  Widget _recommendationCard(PathRecommendation suggestion) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: context.palette.sheet,
      border: Border.all(color: context.palette.line),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('SUGGESTED NEXT PATH', style: noteLabel),
        const SizedBox(height: 8),
        Text(
          suggestion.title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        Text(
          suggestion.reason,
          style: TextStyle(
            fontSize: 15,
            height: 1.5,
            color: context.palette.muted,
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => _selectTrack(suggestion.trackIndex),
          icon: const Icon(Icons.route_outlined),
          label: Text(
            track == suggestion.trackIndex ? 'Current path' : 'Explore path',
          ),
        ),
      ],
    ),
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
                    : 'Retake the short check anytime to refresh your suggested path on Home.',
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

  Widget _weeklyPracticeCard() {
    final now = DateTime.now();
    final weekStart = DateTime.utc(
      now.year,
      now.month,
      now.day - now.weekday + 1,
    );
    final weekEnd = weekStart.add(const Duration(days: 7));
    final practiceDays = <int>{};
    for (final session in store.sessions) {
      final dates = [session.startedAt, ?session.completedAt];
      for (final date in dates) {
        final local = date.toLocal();
        final day = DateTime.utc(local.year, local.month, local.day);
        if (!day.isBefore(weekStart) && day.isBefore(weekEnd)) {
          practiceDays.add(day.weekday);
        }
      }
    }
    const dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const fullDayLabels = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    final goal = store.preferences.weeklyGoalDays;
    final goalMet = practiceDays.length >= goal;
    final progress = (practiceDays.length / goal).clamp(0.0, 1.0).toDouble();

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
              const Expanded(child: Text('WEEKLY PRACTICE', style: noteLabel)),
              Text(
                '${practiceDays.length} of $goal days',
                style: TextStyle(
                  color: context.palette.muted,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            goalMet
                ? 'You reached your weekly target.'
                : '${goal - practiceDays.length} more practice '
                      '${goal - practiceDays.length == 1 ? 'day' : 'days'} to meet your weekly target.',
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(value: progress, minHeight: 5),
          ),
          const SizedBox(height: 14),
          Row(
            children: List.generate(7, (index) {
              final weekday = index + 1;
              final practiced = practiceDays.contains(weekday);
              final isToday = now.weekday == weekday;
              return Expanded(
                child: Semantics(
                  label:
                      '${fullDayLabels[index]}, ${practiced ? 'practice recorded' : 'no saved attempt'}${isToday ? ', today' : ''}',
                  child: ExcludeSemantics(
                    child: Column(
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: practiced
                                ? context.palette.accent
                                : context.palette.recess,
                            border: isToday && !practiced
                                ? Border.all(
                                    color: context.palette.accent,
                                    width: 2,
                                  )
                                : null,
                          ),
                          child: practiced
                              ? Icon(
                                  Icons.check,
                                  size: 17,
                                  color: context.palette.onAccent,
                                )
                              : null,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          dayLabels[index],
                          style: TextStyle(
                            fontSize: 12,
                            color: isToday
                                ? context.palette.ink
                                : context.palette.muted,
                            fontWeight: isToday
                                ? FontWeight.w700
                                : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          Text(
            'Monday–Sunday. A day counts when a practice attempt starts or is completed; study time is not tracked.',
            style: TextStyle(
              fontSize: 12,
              height: 1.5,
              color: context.palette.muted,
            ),
          ),
        ],
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
                          icon: Icon(
                            store.isSaved(lesson)
                                ? Icons.bookmark
                                : Icons.bookmark_border,
                          ),
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
    final due = schedule
        .where((assignment) => assignment.isDueAt(now))
        .toList();
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
                style: TextStyle(fontSize: 13, color: context.palette.muted),
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
            'After self-review, revisit a problem in 1, 3, 7, then 14 days. Your recall rating can bring a shaky problem back sooner or stretch a confident one. Reviews are practice, not verified solves.',
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
          (pattern) =>
              pattern.any((entry) => statusFor(entry) != 'Not started'),
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
      return matchesQuery &&
          matchesDifficulty &&
          matchesProgress &&
          (!savedOnly || store.isSaved(entry.lesson));
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
                final nextPatternEntry =
                    pattern.value
                        .where((entry) => statusFor(entry) == 'In progress')
                        .firstOrNull ??
                    pattern.value
                        .where((entry) => statusFor(entry) != 'Self-reviewed')
                        .firstOrNull;
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
                  children: [
                    if (nextPatternEntry != null)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(12, 2, 12, 8),
                          child: TextButton.icon(
                            onPressed: () =>
                                openLesson(nextPatternEntry.lesson),
                            icon: const Icon(Icons.arrow_forward, size: 17),
                            label: Text(
                              statusFor(nextPatternEntry) == 'In progress'
                                  ? 'Resume this pattern'
                                  : 'Start this pattern',
                            ),
                          ),
                        ),
                      ),
                    ...pattern.value.map(
                      (entry) => _lessonTile(
                        entry.lesson,
                        entry.number,
                        title: entry.title,
                        tag: entry.difficulty,
                      ),
                    ),
                  ],
                );
              }).toList(),
            );
          }),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _interviewSprintPath(
    InterviewSprint sprint, {
    bool showDescription = true,
  }) {
    final completedIds = store.sessions
        .where((session) => session.stage == CoachingStage.complete)
        .map((session) => session.lesson.id)
        .toSet();
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
              if (showDescription) ...[
                Text(
                  sprint.description,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.55,
                    color: context.palette.muted,
                  ),
                ),
                const SizedBox(height: 10),
              ],
              Text(
                'Selected from LoopLoom’s guided catalog using Grind 75’s priority order and topic coverage. These are practice candidates, not predictions of a specific interview. Progress is shared across roadmaps.',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.55,
                  color: context.palette.muted,
                ),
              ),
              TextButton.icon(
                onPressed: () => launchUrl(
                  Uri.https('www.techinterviewhandbook.org', '/grind75/'),
                  mode: LaunchMode.externalApplication,
                ),
                icon: const Icon(Icons.open_in_new, size: 18),
                label: const Text('View Grind 75 source'),
              ),
              if (sprint == oneWeekInterviewSprint) ...[
                const SizedBox(height: 12),
                const Text('READY FOR A FULL ROUND?', style: noteLabel),
                const SizedBox(height: 6),
                Text(
                  'This 80/20 track refreshes the fundamentals. Medium problems are common in coding interviews, so practice more once these patterns feel comfortable.',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.55,
                    color: context.palette.muted,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      blindQuery = '';
                      blindDifficulty = 'Medium';
                      curriculumProgressFilter = 'All progress';
                      savedOnly = false;
                    });
                    _selectTrack(3);
                  },
                  icon: const Icon(Icons.arrow_forward, size: 18),
                  label: const Text('Continue with Blind 75 Medium'),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        for (final (dayIndex, day) in sprint.days.indexed)
          Builder(
            builder: (context) {
              final entries = [
                for (final slug in day.slugs)
                  mastery300Entries.firstWhere((entry) => entry.slug == slug),
              ];
              final startNumber = sprint.days
                  .take(dayIndex)
                  .fold<int>(
                    0,
                    (count, previous) => count + previous.slugs.length,
                  );
              final reviewed = entries
                  .where((entry) => completedIds.contains(entry.lesson.id))
                  .length;
              return Card(
                clipBehavior: Clip.antiAlias,
                child: ExpansionTile(
                  key: PageStorageKey<String>(
                    'sprint-${sprint.title}-${day.title}',
                  ),
                  initiallyExpanded:
                      sprint == lastDayInterviewSprint || startNumber == 0,
                  title: Text(
                    day.title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    '$reviewed of ${entries.length} self-reviewed · ${day.focus}',
                    style: const TextStyle(fontSize: 14, height: 1.4),
                  ),
                  children: [
                    for (final (index, entry) in entries.indexed)
                      _lessonTile(
                        entry.lesson,
                        startNumber + index + 1,
                        title: entry.title,
                        tag: entry.difficulty,
                      ),
                  ],
                ),
              );
            },
          ),
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
        5 => oneWeekInterviewSprint.description,
        6 => lastDayInterviewSprint.description,
        _ =>
          'A 300-problem interview path across core and advanced patterns. Each challenge has five guided reasoning checkpoints and links to its official statement.',
      }, style: TextStyle(fontSize: 13, height: 1.65, color: context.palette.muted)),
      const SizedBox(height: 16),
      if (track == 3 || track == 4) ...[
        _curriculumPath(track == 3 ? blind75Entries : mastery300Entries),
      ] else if (track == 5 || track == 6) ...[
        _interviewSprintPath(
          track == 5 ? oneWeekInterviewSprint : lastDayInterviewSprint,
          showDescription: false,
        ),
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
        'The 300 guided entries use original LoopLoom coaching prompts and five checkpoints each. Content remains under editorial review. Reference-case execution covers the one-week track and other supported lessons.',
        style: TextStyle(
          fontSize: 12,
          height: 1.65,
          color: context.palette.muted,
        ),
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

  Widget _history() {
    final allSessions = store.sessions;
    final query = historyQuery.trim().toLowerCase();
    final visibleSessions = allSessions.where((session) {
      final matchesStatus = switch (historyFilter) {
        'In progress' => session.stage != CoachingStage.complete,
        'Self-reviewed' => session.stage == CoachingStage.complete,
        _ => true,
      };
      final searchText =
          '${session.lesson.title} ${session.lesson.pattern} '
                  '${session.lesson.id} ${session.language.label} '
                  '${session.stage.label} ${session.attemptNumber}'
              .toLowerCase();
      return matchesStatus && (query.isEmpty || searchText.contains(query));
    }).toList();

    return Column(
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
        TextField(
          controller: _historySearchController,
          onChanged: (value) => setState(() => historyQuery = value),
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            labelText: 'Find an attempt',
            hintText: 'Problem, pattern, language, or stage',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: historyQuery.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Clear search',
                    onPressed: _clearHistorySearch,
                    icon: const Icon(Icons.close),
                  ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ['All attempts', 'In progress', 'Self-reviewed']
              .map(
                (filter) => ChoiceChip(
                  label: Text(filter),
                  selected: historyFilter == filter,
                  onSelected: (_) => setState(() => historyFilter = filter),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 10),
        Text(
          '${visibleSessions.length} of ${allSessions.length} attempts',
          style: TextStyle(fontSize: 14, color: context.palette.muted),
        ),
        const SizedBox(height: 12),
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
        if (allSessions.isNotEmpty && visibleSessions.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No attempts match this search and filter.',
                  style: TextStyle(color: context.palette.muted),
                ),
                TextButton(
                  onPressed: _resetHistoryFilters,
                  child: const Text('Clear search and filters'),
                ),
              ],
            ),
          ),
        ...visibleSessions.map(
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
                trailing: IconButton(
                  tooltip: 'Delete attempt',
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _confirmDeleteAttempt(session),
                ),
                onTap: () => openAttempt(session),
              ),
            ],
          ),
        ),
      ],
    );
  }

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
                  child: Text(
                    'Save a problem from a roadmap to return to it here.',
                  ),
                ),
              ]
            : lessons
                  .map(
                    (lesson) => ListTile(
                      title: Text(lesson.title),
                      subtitle: Text(lesson.pattern),
                      trailing: const Icon(Icons.north_east, size: 17),
                      onTap: () => openLesson(lesson),
                    ),
                  )
                  .toList(),
      ),
    );
  }
}
