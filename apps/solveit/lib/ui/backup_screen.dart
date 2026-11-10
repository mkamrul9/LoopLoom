import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/lesson_catalog.dart';
import 'readable_surface.dart';
import '../features/coaching/session_controller.dart';
import 'backup_file_transfer.dart';
import 'looploom_theme.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key, required this.store});
  final PracticeStore store;
  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  static const maxBackupBytes = 2000000;
  final input = TextEditingController();
  final exportText = TextEditingController();
  WorkbookBackupPlan? plan;
  bool restoreStudyPreferences = false;
  bool busy = false;
  String? status;

  String _exportBackup() {
    final text = widget.store.exportBackup();
    if (utf8.encode(text).length > maxBackupBytes) {
      throw const FormatException(
        'This workbook is larger than the 2 MB restore limit. Remove older or unusually large drafts before creating a portable backup.',
      );
    }
    return text;
  }

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
      exportText.clear();
    });
    try {
      final text = _exportBackup();
      setState(() => exportText.text = text);
      await Clipboard.setData(ClipboardData(text: text));
      if (mounted) {
        setState(
          () => status =
              'Backup copied. Paste it into a text file and keep that file for recovery.',
        );
      }
    } on FormatException catch (error) {
      if (mounted) setState(() => status = error.message);
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

  Future<void> saveBackupFile() async {
    setState(() {
      busy = true;
      status = null;
      exportText.clear();
    });
    try {
      final text = _exportBackup();
      setState(() => exportText.text = text);
      final date = DateTime.now().toIso8601String().substring(0, 10);
      final saved = await saveWorkbookBackupFile(
        text,
        'LoopLoom-workbook-$date.json',
      );
      if (mounted) {
        setState(
          () => status = saved
              ? 'Backup file saved. Keep it somewhere you trust; it contains readable private study data.'
              : 'File saving was cancelled. Your workbook has not changed.',
        );
      }
    } on FormatException catch (error) {
      if (mounted) setState(() => status = error.message);
    } catch (_) {
      if (mounted) {
        setState(
          () => status =
              'File saving is unavailable here. Use Copy workbook backup and save the text as a .json file.',
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> openBackupFile() async {
    setState(() {
      busy = true;
      status = null;
      plan = null;
    });
    try {
      final text = await openWorkbookBackupFile();
      if (!mounted) return;
      if (text == null) {
        setState(
          () => status = 'File selection was cancelled. Nothing changed.',
        );
        return;
      }
      input.text = text;
      reviewBackup();
      if (plan != null) {
        setState(
          () => status =
              'Backup file loaded. Review the summary below before restoring it.',
        );
      }
    } on FormatException catch (error) {
      if (mounted) setState(() => status = error.message);
    } on PlatformException catch (error) {
      if (mounted) {
        setState(
          () =>
              status = error.message ?? 'The backup file could not be opened.',
        );
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => status =
              'File selection is unavailable here. Paste the backup JSON below instead.',
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
        restoreStudyPreferences = false;
        status = null;
      });
    } on FormatException {
      setState(() {
        plan = null;
        restoreStudyPreferences = false;
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
      final result = await widget.store.importBackup(
        checked,
        allLessons,
        restoreStudyPreferences: restoreStudyPreferences,
      );
      if (mounted) {
        setState(() {
          plan = null;
          input.clear();
          status =
              '${result.added} attempts restored. ${result.skipped} existing attempts kept. ${result.savedAdded} saved problems added.${result.savedFailed
                  ? ' Study settings or saved problems could not be written; retry the local save.'
                  : restoreStudyPreferences && checked.studyPreferences != null
                  ? ' Study settings restored. Saved locally.'
                  : ' Saved locally.'}';
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
                    'Back up your attempts, code drafts, explanations, session notes, saved problems, and study preferences. The copy includes current unsaved edits and retained older records.',
                    style: TextStyle(height: 1.65),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Backups are plain JSON text and are not encrypted. Save the file or copy the text, then store it somewhere you trust. Nothing is uploaded.',
                    style: TextStyle(
                      height: 1.65,
                      color: context.palette.muted,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      FilledButton.icon(
                        onPressed: busy ? null : saveBackupFile,
                        icon: const Icon(Icons.download_outlined, size: 18),
                        label: const Text('Save backup file'),
                      ),
                      OutlinedButton.icon(
                        onPressed: busy ? null : copyBackup,
                        icon: const Icon(Icons.copy_outlined, size: 18),
                        label: const Text('Copy backup text'),
                      ),
                    ],
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
                    'Choose a backup file or paste its full JSON text below. Existing attempts stay as they are, including when the backup contains a different draft with the same attempt ID. Saved problems are combined. Unknown lesson versions are retained but may not open.',
                    style: TextStyle(
                      height: 1.65,
                      fontSize: 13,
                      color: context.palette.muted,
                    ),
                  ),
                  const SizedBox(height: 18),
                  OutlinedButton.icon(
                    onPressed: busy ? null : openBackupFile,
                    icon: const Icon(Icons.folder_open_outlined),
                    label: const Text('Choose a backup file'),
                  ),
                  const SizedBox(height: 14),
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
                    if (checked.studyPreferences != null) ...[
                      const SizedBox(height: 8),
                      CheckboxListTile(
                        value: restoreStudyPreferences,
                        onChanged: busy
                            ? null
                            : (value) => setState(
                                () => restoreStudyPreferences = value ?? false,
                              ),
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                        title: const Text('Restore profile & study settings'),
                        subtitle: Text(
                          'From backup: ${checked.studyPreferences!.displayName.isEmpty ? 'unnamed profile' : checked.studyPreferences!.displayName} · ${checked.studyPreferences!.preferredLanguage.label} · ${checked.studyPreferences!.weeklyGoalDays} days/week. Also restores appearance and diagnostic. AI consent and runner access stay on this device.',
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: busy ? null : restore,
                      child: Text(
                        busy
                            ? 'Restoring…'
                            : restoreStudyPreferences
                            ? 'Restore workbook and settings'
                            : 'Restore workbook',
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
                      onPressed: busy
                          ? null
                          : () async {
                              try {
                                await widget.store.retrySave();
                                if (mounted) {
                                  setState(
                                    () => status =
                                        'Saved problems saved locally.',
                                  );
                                }
                              } catch (_) {
                                if (mounted) {
                                  setState(
                                    () => status =
                                        'Local save still failed. Try again.',
                                  );
                                }
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
