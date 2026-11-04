import 'package:flutter/services.dart';

const _channel = MethodChannel('app.looploom/backup_files');

Future<String?> openWorkbookBackupFile() =>
    _channel.invokeMethod<String?>('openWorkbookBackupFile');

Future<bool> saveWorkbookBackupFile(String contents, String fileName) async =>
    await _channel.invokeMethod<bool>('saveWorkbookBackupFile', {
      'contents': contents,
      'fileName': fileName,
    }) ??
    false;
