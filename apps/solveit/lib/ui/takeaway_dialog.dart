import 'package:flutter/material.dart';
import '../features/coaching/session_controller.dart';

Future<void> editTakeaway(
  BuildContext context,
  SessionController session,
  PracticeStore store,
) async {
  final result = await showDialog<String>(
    context: context,
    builder: (_) => _TakeawayEditor(initialText: session.takeaway),
  );
  if (result == null) return;
  session.saveTakeaway(result);
  await store.flush();
  if (store.saveFailed && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Could not save the takeaway. Retry from the save status.',
        ),
      ),
    );
  }
}

class _TakeawayEditor extends StatefulWidget {
  const _TakeawayEditor({required this.initialText});
  final String initialText;

  @override
  State<_TakeawayEditor> createState() => _TakeawayEditorState();
}

class _TakeawayEditorState extends State<_TakeawayEditor> {
  late final TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('One thing to remember'),
    content: TextField(
      controller: controller,
      autofocus: true,
      minLines: 3,
      maxLines: 6,
      maxLength: 500,
      decoration: const InputDecoration(
        labelText: 'Your takeaway',
        hintText: 'What mistake or pattern will you remember next time?',
        alignLabelWithHint: true,
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: () => Navigator.pop(context, controller.text),
        child: const Text('Save takeaway'),
      ),
    ],
  );
}
