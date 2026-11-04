import 'package:flutter/material.dart';
import '../features/coaching/session_controller.dart';
import 'looploom_theme.dart';

class SaveStatus extends StatelessWidget {
  const SaveStatus({super.key, required this.store, this.compact = false});
  final PracticeStore store;
  final bool compact;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: store,
    builder: (context, _) {
      final failed = store.saveFailed || store.preferencesSaveFailed;
      final retryable =
          store.preferencesSaveFailed ||
          (store.saveFailed && !store.saveConflict);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                failed
                    ? Icons.error_outline
                    : store.saving
                    ? Icons.more_horiz
                    : Icons.check,
                size: 13,
                color: StudyColors.muted,
              ),
              const SizedBox(width: 6),
              Text(
                failed
                    ? 'Not saved'
                    : store.saving
                    ? 'Saving…'
                    : store.sessions.isEmpty
                    ? 'LOCAL WORKBOOK'
                    : 'Saved locally',
                style: const TextStyle(fontSize: 11, color: StudyColors.muted),
              ),
              if (retryable)
                TextButton(
                  onPressed: store.retrySave,
                  child: const Text('Retry'),
                ),
            ],
          ),
          if (store.saveConflict && !compact)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'Another window changed this attempt. Keep this tab open and copy your latest draft before reloading.',
                style: TextStyle(fontSize: 12, height: 1.6),
              ),
            ),
        ],
      );
    },
  );
}
