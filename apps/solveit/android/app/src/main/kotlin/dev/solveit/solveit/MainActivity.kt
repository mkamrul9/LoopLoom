package dev.solveit.solveit

import android.app.Activity
import android.content.ActivityNotFoundException
import android.content.Intent
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream
import java.io.IOException

class MainActivity : FlutterActivity() {
    private val backupChannel = "app.looploom/backup_files"
    private val requestCode = 7831
    private val maxBackupBytes = 2_000_000
    private var pendingResult: MethodChannel.Result? = null
    private var pendingSaveContents: String? = null
    private var pendingSave = false

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, backupChannel)
            .setMethodCallHandler { call, result ->
                if (pendingResult != null) {
                    result.error("busy", "Another file request is still open.", null)
                    return@setMethodCallHandler
                }

                when (call.method) {
                    "openWorkbookBackupFile" -> openBackupPicker(result)
                    "saveWorkbookBackupFile" -> {
                        val contents = call.argument<String>("contents")
                        val fileName = call.argument<String>("fileName")
                        if (contents == null || fileName == null) {
                            result.error("invalid_arguments", "Backup content is missing.", null)
                        } else if (contents.toByteArray(Charsets.UTF_8).size > maxBackupBytes) {
                            result.error("too_large", "The backup is larger than 2 MB.", null)
                        } else {
                            saveBackupPicker(contents, fileName, result)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun openBackupPicker(result: MethodChannel.Result) {
        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
            addCategory(Intent.CATEGORY_OPENABLE)
            type = "*/*"
            putExtra(Intent.EXTRA_MIME_TYPES, arrayOf("application/json", "text/plain"))
        }
        launchPicker(intent, result, saving = false)
    }

    private fun saveBackupPicker(
        contents: String,
        fileName: String,
        result: MethodChannel.Result,
    ) {
        val intent = Intent(Intent.ACTION_CREATE_DOCUMENT).apply {
            addCategory(Intent.CATEGORY_OPENABLE)
            type = "application/json"
            putExtra(Intent.EXTRA_TITLE, fileName)
        }
        pendingSaveContents = contents
        launchPicker(intent, result, saving = true)
    }

    private fun launchPicker(
        intent: Intent,
        result: MethodChannel.Result,
        saving: Boolean,
    ) {
        pendingResult = result
        pendingSave = saving
        try {
            startActivityForResult(intent, requestCode)
        } catch (error: ActivityNotFoundException) {
            pendingResult = null
            pendingSaveContents = null
            pendingSave = false
            result.error("no_file_handler", "No system file picker is available.", null)
        }
    }

    @Deprecated("Deprecated in Android; retained for the Flutter activity result bridge.")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode != this.requestCode) return

        val result = pendingResult ?: return
        val saving = pendingSave
        val contents = pendingSaveContents
        pendingResult = null
        pendingSaveContents = null
        pendingSave = false

        if (resultCode != Activity.RESULT_OK || data?.data == null) {
            result.success(if (saving) false else null)
            return
        }

        val uri: Uri = data.data!!
        try {
            if (saving) {
                val bytes = contents?.toByteArray(Charsets.UTF_8)
                    ?: throw IOException("Backup content is unavailable.")
                contentResolver.openOutputStream(uri, "wt")?.use { output ->
                    output.write(bytes)
                } ?: throw IOException("The selected destination could not be opened.")
                result.success(true)
            } else {
                result.success(readBackup(uri))
            }
        } catch (error: BackupTooLargeException) {
            result.error("too_large", "Choose a backup smaller than 2 MB.", null)
        } catch (error: Exception) {
            result.error("file_io", error.message ?: "The backup file could not be accessed.", null)
        }
    }

    private fun readBackup(uri: Uri): String {
        val stream = contentResolver.openInputStream(uri)
            ?: throw IOException("The selected backup could not be opened.")
        val bytes = ByteArrayOutputStream()
        stream.use { input ->
            val buffer = ByteArray(8_192)
            var total = 0
            while (true) {
                val count = input.read(buffer)
                if (count < 0) break
                total += count
                if (total > maxBackupBytes) throw BackupTooLargeException()
                bytes.write(buffer, 0, count)
            }
        }
        return bytes.toString(Charsets.UTF_8.name())
    }

    private class BackupTooLargeException : IOException()
}
