import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FileService {
  Future<String> readAsString(String path) async {
    return File(path).readAsString();
  }

  Future<void> writeAsString(String path, String content) async {
    await File(path).writeAsString(content);
  }
}

final fileServiceProvider = Provider<FileService>((ref) {
  return FileService();
});
