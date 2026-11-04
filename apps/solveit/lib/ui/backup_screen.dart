import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/lesson_catalog.dart';
import 'readable_surface.dart';
import '../features/coaching/session_controller.dart';
import 'looploom_theme.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key, required this.store});
  final PracticeStore store;
  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  final input = TextEditingController();
  final exportText = TextEditingController();
  WorkbookBackupPlan? plan;
  bool busy = false;
  String? status;
  @override
  void dispose() {
    input.dispose();
    exportText.dispose();
    super.dispose();
  }

  Future<void> copyBackup() async {
    setState(() {
      busy = true;
      status = null;
    });
    try {
      final text = widget.store.exportBackup();
      setState(() => exportText.text = text);
      await Clipboard.setData(ClipboardData(text: text));
      if (mounted) {
        setState(
          () => status =
              'Backup copied. Paste it into a text file and keep that file for recovery.',
        );
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => status =
              'Clipboard access was unavailable. Select and copy the backup text below. Your workbook has not changed.',
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  void reviewBackup() {
    try {
      final checked = widget.store.inspectBackup(input.text, allLessons);
      setState(() {
        plan = checked;
        status = null;
      });
    } on FormatException {
      setState(() {
        plan = null;
        status =
            'This backup could not be read. Use a complete LoopLoom version 1 backup, up to 2 MB and 500 attempts.';
      });
    }
  }

  Future<void> restore() async {
    final checked = plan;
    if (checked == null) return;
    setState(() {
      busy = true;
      status = null;
    });
    try {
      final result = await widget.store.importBackup(checked, allLessons);
      if (mounted) {
        setState(() {
          plan = null;
          input.clear();
          status =
              '${result.added} attempts restored. ${result.skipped} existing attempts kept. ${result.savedAdded} saved problems added.${result.savedFailed ? ' Saved problems could not be written; retry the local save.' : ' Saved locally.'}';
        });
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => status =
              'Restore could not be saved. Your existing attempts were kept. Check local save status, then try again.',
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => ReadableSurface(
    scale: widget.store.preferences.textScale,
    child: PopScope(
      canPop: !busy,
      child: Scaffold(
        appBar: AppBar(title: const Text('Workbook backup')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('KEEP YOUR WORK', style: noteLabel),
                  const SizedBox(height: 16),
                  const Text(
                    'A copy for later.',
                    style: TextStyle(fontSize: 30, letterSpacing: -.8),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Back up your attempts, code drafts, explanations, session notes, and saved problems. The copy includes current unsaved edits and retained older records.',
                    style: TextStyle(height: 1.65),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Backups are plain JSON text and are not encrypted. Copy the text into a file and store it somewhere you trust. Nothing is uploaded.',
                    style: TextStyle(
                      height: 1.65,
                      color: context.palette.muted,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 20),
                  OutlinedButton.icon(
                    onPressed: busy ? null : copyBackup,
                    icon: const Icon(Icons.copy_outlined, size: 18),
                    label: const Text('Copy workbook backup'),
                  ),
                  if (exportText.text.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    TextField(
                      controller: exportText,
                      readOnly: true,
                      minLines: 3,
                      maxLines: 6,
                      decoration: const InputDecoration(
                        labelText: 'Your backup text',
                        helperText:
                            'You can also select and copy this text manually.',
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 24),
                  const Text('Restore a copy', style: TextStyle(fontSize: 22)),
                  const SizedBox(height: 12),
                  Text(
                    'Paste the full backup text below. Existing attempts stay as they are, including when the backup contains a different draft with the same attempt ID. Saved problems are combined. Unknown lesson versions are retained but may not open.',
                    style: TextStyle(
                      height: 1.65,
                      fontSize: 13,
                      color: context.palette.muted,
                    ),
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: input,
                    enabled: !busy,
                    minLines: 4,
                    maxLines: 8,
                    maxLength: 2000000,
                    decoration: const InputDecoration(
                      labelText: 'Backup JSON',
                      alignLabelWithHint: true,
                      counterText: '',
                    ),
                    onChanged: (_) => setState(() {
                      plan = null;
                      status = null;
                    }),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: busy ? null : reviewBackup,
                    child: const Text('Review backup'),
                  ),
                  if (plan case final checked?) ...[
                    const SizedBox(height: 20),
                    Text(
                      '${checked.total} attempts in this backup. ${checked.additions} to add; ${checked.existing} already on this device. ${checked.savedLessonIds.length} saved problems to merge.',
                      style: const TextStyle(height: 1.65),
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: busy ? null : restore,
                      child: Text(
                        busy ? 'Restoring…' : 'Restore workbook',
                      ),
                    ),
                  ],
                  if (status != null) ...[
                    const SizedBox(height: 20),
                    Semantics(
                      liveRegion: true,
                      child: Text(
                        status!,
                        style: const TextStyle(height: 1.65),
                      ),
                    ),
                  ],
                  if (widget.store.preferencesSaveFailed) ...[
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: busy ? null : () async {
                        try {
                          await widget.store.retrySave();
                          if (mounted) setState(() => status = 'Saved problems saved locally.');
                        } catch (_) {
                          if (mounted) setState(() => status = 'Local save still failed. Try again.');
                        }
                      },
                      child: const Text('Retry local save'),
                    ),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
