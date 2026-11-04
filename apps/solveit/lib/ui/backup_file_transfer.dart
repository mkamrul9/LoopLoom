import 'backup_file_transfer_stub.dart'
    if (dart.library.io) 'backup_file_transfer_io.dart'
    if (dart.library.html) 'backup_file_transfer_web.dart'
    as platform;

Future<String?> openWorkbookBackupFile() => platform.openWorkbookBackupFile();

Future<bool> saveWorkbookBackupFile(String contents, String fileName) =>
    platform.saveWorkbookBackupFile(contents, fileName);
