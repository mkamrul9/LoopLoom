// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter

import 'dart:async';
import 'dart:html' as html;

Future<String?> openWorkbookBackupFile() async {
  final input = html.FileUploadInputElement()
    ..accept = '.json,application/json,text/plain'
    ..style.position = 'fixed'
    ..style.left = '-10000px'
    ..style.width = '1px'
    ..style.height = '1px'
    ..style.opacity = '0';
  final body = html.document.body;
  if (body == null) throw StateError('The browser page is not ready.');

  final selected = Completer<bool>();
  final changed = input.onChange.listen((_) {
    if (!selected.isCompleted) selected.complete(true);
  });
  final cancelled = input.on['cancel'].listen((_) {
    if (!selected.isCompleted) selected.complete(false);
  });
  body.children.add(input);
  try {
    // This call happens synchronously inside the user's button press, which
    // keeps the browser's file chooser inside its user-activation policy.
    input.click();
    if (!await selected.future.timeout(
      const Duration(minutes: 2),
      onTimeout: () => false,
    )) {
      return null;
    }
    final file = input.files?.first;
    if (file == null) return null;
    if (file.size > 2000000) {
      throw const FormatException('Choose a backup smaller than 2 MB.');
    }
    final reader = html.FileReader();
    final readComplete = Completer<void>();
    final loaded = reader.onLoad.listen((_) {
      if (!readComplete.isCompleted) readComplete.complete();
    });
    final failed = reader.onError.listen((_) {
      if (!readComplete.isCompleted) {
        readComplete.completeError(
          const FormatException('The selected backup could not be read.'),
        );
      }
    });
    reader.readAsText(file);
    try {
      await readComplete.future.timeout(const Duration(seconds: 30));
    } finally {
      await loaded.cancel();
      await failed.cancel();
    }
    final result = reader.result;
    if (result is! String) {
      throw const FormatException('The selected backup is not text.');
    }
    return result;
  } finally {
    await changed.cancel();
    await cancelled.cancel();
    input.remove();
  }
}

Future<bool> saveWorkbookBackupFile(String contents, String fileName) async {
  final body = html.document.body;
  if (body == null) throw StateError('The browser page is not ready.');
  final blob = html.Blob([contents], 'application/json;charset=utf-8');
  final url = html.Url.createObjectUrlFromBlob(blob);
  final link = html.AnchorElement(href: url)
    ..download = fileName
    ..style.display = 'none';
  body.children.add(link);
  try {
    link.click();
    return true;
  } finally {
    link.remove();
    Timer(const Duration(seconds: 1), () => html.Url.revokeObjectUrl(url));
  }
}
