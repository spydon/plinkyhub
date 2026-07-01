import 'dart:js_interop';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

/// Options for [showDirectoryPicker].
extension type DirectoryPickerOptions._(JSObject _) implements JSObject {
  external factory DirectoryPickerOptions({String mode});
}

/// Options for [FileSystemDirectoryHandle.getFileHandle].
extension type GetFileHandleOptions._(JSObject _) implements JSObject {
  external factory GetFileHandleOptions({bool create});
}

/// A handle to a file system directory, returned by [showDirectoryPicker].
extension type FileSystemDirectoryHandle._(JSObject _) implements JSObject {
  @JS('getFileHandle')
  external JSPromise<FileSystemFileHandle> _getFileHandle(
    String name, [
    GetFileHandleOptions? options,
  ]);

  Future<FileSystemFileHandle> getFileHandle(
    String name, {
    bool create = false,
  }) => _getFileHandle(name, GetFileHandleOptions(create: create)).toDart;
}

/// A handle to a file system file.
extension type FileSystemFileHandle._(JSObject _) implements JSObject {
  @JS('getFile')
  external JSPromise<web.File> _getFile();

  Future<web.File> getFile() => _getFile().toDart;

  @JS('createWritable')
  external JSPromise<FileSystemWritableFileStream> _createWritable();

  Future<FileSystemWritableFileStream> createWritable() =>
      _createWritable().toDart;
}

/// A JavaScript error-like object exposing a nullable [name], used to
/// inspect `DOMException`s thrown across the JS interop boundary.
extension type _JSErrorLike._(JSObject _) implements JSObject {
  external String? get name;
}

/// A writable stream for writing data to a file on disk.
extension type FileSystemWritableFileStream._(JSObject _) implements JSObject {
  @JS('write')
  external JSPromise<JSAny?> _write(JSAny data);

  Future<void> write(Uint8List data) => _write(data.toJS).toDart;

  @JS('close')
  external JSPromise<JSAny?> _close();

  Future<void> close() => _close().toDart;
}

@JS('showDirectoryPicker')
external JSPromise<FileSystemDirectoryHandle> _showDirectoryPicker([
  DirectoryPickerOptions? options,
]);

@JS('showDirectoryPicker')
external JSFunction? get _showDirectoryPickerOrNull;

/// Whether the browser supports the File System Access API
/// (`showDirectoryPicker`). Returns `false` on Firefox and Safari.
bool get isFileSystemAccessSupported {
  try {
    return _showDirectoryPickerOrNull != null;
  } on Object {
    return false;
  }
}

/// Shows a directory picker dialog and returns a handle to the selected
/// directory. The user must interact with the page before calling this.
///
/// Returns `null` if the user cancels the picker.
Future<FileSystemDirectoryHandle?> showDirectoryPicker({
  bool readwrite = false,
}) async {
  try {
    final options = readwrite
        ? DirectoryPickerOptions(mode: 'readwrite')
        : null;
    return await _showDirectoryPicker(options).toDart;
  } on Object catch (error) {
    // User cancelled (AbortError) or browser does not support the API.
    debugPrint('showDirectoryPicker failed: $error');
    return null;
  }
}

/// Reads a file from a [FileSystemDirectoryHandle] as bytes.
///
/// Returns `null` if the file does not exist or cannot be read.
/// If the file is not found, retries with the lowercase filename as
/// a fallback (some Plinky devices use lowercase filenames).
Future<Uint8List?> readFileFromDirectory(
  FileSystemDirectoryHandle directory,
  String fileName,
) async {
  try {
    final fileHandle = await directory.getFileHandle(fileName);
    final file = await fileHandle.getFile();
    final arrayBuffer = await file.arrayBuffer().toDart;
    return arrayBuffer.toDart.asUint8List();
  } on Object {
    // Try lowercase fallback.
    final lowerName = fileName.toLowerCase();
    if (lowerName == fileName) {
      return null;
    }
    try {
      final fileHandle = await directory.getFileHandle(lowerName);
      final file = await fileHandle.getFile();
      final arrayBuffer = await file.arrayBuffer().toDart;
      return arrayBuffer.toDart.asUint8List();
    } on Object {
      return null;
    }
  }
}

/// Writes [data] to a file in the given [directory].
///
/// When [onProgress] is provided, data is sent in 64 KB chunks and
/// [onProgress] is called after each chunk with a value from 0.0 to 1.0.
///
/// [onFinalize] is called after all bytes are written but before the stream
/// is closed. Use it to show a "Finalizing..." status when the close may
/// take a while (e.g. the device is flushing to flash).
Future<void> writeFileToDirectory(
  FileSystemDirectoryHandle directory,
  String fileName,
  Uint8List data, {
  ValueChanged<double>? onProgress,
  VoidCallback? onFinalize,
}) async {
  try {
    final fileHandle = await directory.getFileHandle(fileName, create: true);
    final writable = await fileHandle.createWritable();
    if (onProgress == null || data.isEmpty) {
      await writable.write(data);
    } else {
      const chunkSize = 64 * 1024;
      var position = 0;
      while (position < data.length) {
        final end = min(position + chunkSize, data.length);
        await writable.write(data.sublist(position, end));
        position = end;
        onProgress(position / data.length);
      }
    }
    onFinalize?.call();
    await writable.close();
  } on Object catch (error) {
    // Rejected JS promises surface `DOMException`s, which are not Dart
    // `Exception`s and would otherwise escape callers' `on Exception`
    // handlers and crash the app.
    throw Exception(_describeWriteError(error, fileName));
  }
}

/// Builds a human-readable message for an error thrown while writing to the
/// Plinky drive, translating known `DOMException` names into guidance.
String _describeWriteError(Object error, String fileName) {
  final name = error is JSObject ? (error as _JSErrorLike).name : null;
  if (name == 'NoModificationAllowedError') {
    return 'Could not write "$fileName" to the Plinky drive. Make sure the '
        'Plinky is mounted in disk mode and is not write-protected, then '
        'try again.';
  }
  return 'Failed to write "$fileName" to the Plinky drive: $error';
}
