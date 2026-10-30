import 'package:flutter/material.dart';
import 'data/pilot_lessons.dart';
import 'data/interview_lessons.dart';
import 'domain/lesson.dart';
import 'features/coaching/practice_screen.dart';
import 'features/coaching/session_controller.dart';
import 'ui/solveit_theme.dart';
import 'ui/save_status.dart';
import 'ui/workbook_bootstrap.dart';
import 'ui/backup_screen.dart';

class SolveItApp extends StatelessWidget {
  const SolveItApp({super.key, this.store});
  final PracticeStore? store;
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'SolveIt — Think it through',
    debugShowCheckedModeBanner: false,
    theme: studyTheme(),
    home: store == null
        ? WorkbookBootstrap(builder: (store) => LearningHome(store: store))
        : LearningHome(store: store!),
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
  int track = 1;
  List<Lesson> get trackLessons => track == 0 ? pilotLessons : interviewLessons;
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
        label: const Text('Intermediate · 3'),
        selected: track == 1,
        onSelected: (_) => setState(() => track = 1),
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

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: store,
    builder: (context, _) => LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 840;
        return Scaffold(
          appBar: AppBar(
            title: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                StudyMark(),
                SizedBox(width: 18),
                Flexible(
                  child: Text(
                    'solveit',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -.7,
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                tooltip: 'Workbook backup',
                icon: const Icon(Icons.inventory_2_outlined),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => BackupScreen(store: store),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: 24),
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
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: StudyColors.line)),
                  ),
                  child: NavigationBar(
                    selectedIndex: selected,
                    onDestinationSelected: (v) => setState(() => selected = v),
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
  );

  Widget _learn(bool wide) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('THE INTERVIEW WORKBOOK', style: noteLabel),
      const SizedBox(height: 18),
      Text(
        'Think it through.',
        style: TextStyle(
          fontSize: wide ? 42 : 34,
          height: 1.15,
          fontWeight: FontWeight.w500,
          letterSpacing: -1.7,
        ),
      ),
      const SizedBox(height: 12),
      const Text(
        'One problem. A clearer way forward.',
        style: TextStyle(color: StudyColors.muted, fontSize: 16, height: 1.5),
      ),
      const SizedBox(height: 32),
      Container(
        width: double.infinity,
        padding: EdgeInsets.all(wide ? 30 : 22),
        decoration: BoxDecoration(
          color: StudyColors.sheet,
          border: Border.all(color: StudyColors.line),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Expanded(child: Text('NEXT ON YOUR DESK', style: noteLabel)),
                Text(
                  '01',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    color: StudyColors.muted,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            Text(
              store.latestIncomplete?.lesson.title ?? trackLessons.first.title,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w500,
                letterSpacing: -.8,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              store.latestIncomplete == null
                  ? 'Explain your method, trace it, then write your code.'
                  : 'Continue from your ${store.latestIncomplete!.stage.label.toLowerCase()} checkpoint.',
              style: TextStyle(
                fontSize: 15,
                height: 1.55,
                color: StudyColors.muted,
              ),
            ),
            const SizedBox(height: 22),
            Wrap(
              spacing: 14,
              runSpacing: 8,
              children: [
                Text(
                  (store.latestIncomplete?.lesson.pattern ??
                          trackLessons.first.pattern)
                      .toUpperCase(),
                  style: noteLabel,
                ),
                Text(
                  pilotLessons.any(
                        (l) =>
                            l.id ==
                            (store.latestIncomplete?.lesson ??
                                    trackLessons.first)
                                .id,
                      )
                      ? 'INTERVIEW WARM-UP'
                      : 'INTERMEDIATE',
                  style: noteLabel,
                ),
              ],
            ),
            const SizedBox(height: 26),
            FilledButton.icon(
              onPressed: () => openLesson(
                store.latestIncomplete?.lesson ?? trackLessons.first,
              ),
              icon: const Icon(Icons.arrow_forward, size: 17),
              label: Text(
                store.latestIncomplete == null
                    ? 'Start guided practice'
                    : 'Resume practice',
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 22),
      const Wrap(
        spacing: 24,
        runSpacing: 10,
        children: [
          Text('01  Explain', style: noteLabel),
          Text('02  Trace', style: noteLabel),
          Text('03  Write code', style: noteLabel),
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
            '${reviewedInTrack()}/${trackLessons.length} REVIEWED',
            style: noteLabel,
          ),
        ],
      ),
      const SizedBox(height: 16),
      trackPicker(),
      const SizedBox(height: 12),
      ...trackLessons.indexed.map((item) => _lessonTile(item.$2, item.$1 + 1)),
      const SizedBox(height: 24),
      const Text(
        'C++ / Python / JavaScript / TypeScript',
        style: TextStyle(fontSize: 12, color: StudyColors.muted),
      ),
      const SizedBox(height: 10),
      const Text(
        'Your workbook saves on this device. Guided checkpoints are self-reviewed; reference-case matches do not establish verified solves.',
        style: TextStyle(fontSize: 12, color: StudyColors.muted, height: 1.6),
      ),
    ],
  );

  Widget _lessonTile(Lesson lesson, int number) => Column(
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
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      color: StudyColors.muted,
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
                        lesson.title,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        lesson.summary,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.5,
                          color: StudyColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  progressFor(lesson),
                  style: const TextStyle(
                    fontSize: 11,
                    color: StudyColors.muted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  );

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
      const Text(
        'Choose a focused track. Every lesson is available from the start; return to a pattern whenever you need it.',
        style: TextStyle(height: 1.6, color: StudyColors.muted),
      ),
      const SizedBox(height: 32),
      trackPicker(),
      const SizedBox(height: 24),
      const Text('AVAILABLE NOW', style: noteLabel),
      const SizedBox(height: 10),
      Text(
        track == 0 ? 'Interview warm-ups' : 'Intermediate foundations',
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
      ),
      const SizedBox(height: 10),
      Text(
        '${reviewedInTrack()} of ${trackLessons.length} self-reviewed · no test-verified solves yet',
        style: const TextStyle(fontSize: 13, color: StudyColors.muted),
      ),
      const SizedBox(height: 18),
      LinearProgressIndicator(
        value: reviewedInTrack() / trackLessons.length,
        minHeight: 3,
      ),
      const SizedBox(height: 24),
      Text(
        track == 0
            ? 'Build confidence with lookup, sorted search, and fixed windows.'
            : 'Practice windows, search boundaries, string frequencies, heaps, tree and graph traversal, prefix/suffix products, set-based sequences, dynamic programming, and greedy scans.',
        style: const TextStyle(
          fontSize: 13,
          height: 1.65,
          color: StudyColors.muted,
        ),
      ),
      const SizedBox(height: 16),
      ...trackLessons.indexed.map((item) => _lessonTile(item.$2, item.$1 + 1)),
      const SizedBox(height: 32),
      const Text('IN DEVELOPMENT', style: noteLabel),
      const SizedBox(height: 14),
      const ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text('Interview starter / 30'),
        subtitle: Text('Intermediate · core patterns'),
        trailing: Text('PLANNED', style: noteLabel),
      ),
      const ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text('Interview / 75'),
        subtitle: Text('The main path · connected practice'),
        trailing: Text('PLANNED', style: noteLabel),
      ),
      const ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text('Mastery / 300'),
        subtitle: Text('Advanced · deeper problem solving'),
        trailing: Text('PLANNED', style: noteLabel),
      ),
    ],
  );

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
      const Text(
        'Your attempts, drafts, and the questions that helped.',
        style: TextStyle(color: StudyColors.muted, height: 1.6),
      ),
      const SizedBox(height: 10),
      const Text(
        'Saved on this device. Clearing browser data or uninstalling the app removes local work.',
        style: TextStyle(fontSize: 12, color: StudyColors.muted),
      ),
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
}
