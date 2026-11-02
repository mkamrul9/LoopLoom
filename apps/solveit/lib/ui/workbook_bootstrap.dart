import 'dart:async';
import 'package:flutter/material.dart';
import '../data/local_database.dart';
import '../data/lesson_catalog.dart';
import '../data/session_repository.dart';
import '../features/coaching/coach_provider.dart';
import '../features/coaching/session_controller.dart';

class WorkbookBootstrap extends StatefulWidget {
  const WorkbookBootstrap({super.key, required this.builder});
  final Widget Function(PracticeStore) builder;
  @override
  State<WorkbookBootstrap> createState() => _WorkbookBootstrapState();
}

class _WorkbookBootstrapState extends State<WorkbookBootstrap>
    with WidgetsBindingObserver {
  late Future<PracticeStore> opening;
  PracticeStore? loaded;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    opening = open();
  }

  Future<PracticeStore> open() async {
    final repository = SembastSessionRepository(await openPracticeDatabase());
    try {
      final store = await PracticeStore.load(
        repository,
        allLessons,
        coach: configuredCoach(),
      );
      if (!mounted) {
        store.dispose();
      } else {
        loaded = store;
      }
      return store;
    } catch (_) {
      await repository.close();
      rethrow;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      final store = loaded;
      if (store != null) unawaited(store.flush());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<PracticeStore>(
    future: opening,
    builder: (context, snapshot) {
      if (snapshot.hasData) return widget.builder(snapshot.data!);
      if (snapshot.hasError) {
        return Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Your workbook could not be opened.',
                    style: TextStyle(fontSize: 22),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Check that local storage is available, then try again. Existing saved work has been kept.',
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: () => setState(() => opening = open()),
                    child: const Text('Try again'),
                  ),
                ],
              ),
            ),
          ),
        );
      }
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(height: 18),
              Text('Opening your workbook…'),
            ],
          ),
        ),
      );
    },
  );
}
