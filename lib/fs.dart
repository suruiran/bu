import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:bu/utils/env.dart';
import 'package:path/path.dart' as plib;

import 'package:path_provider/path_provider.dart';

class Fs {
  static Future<File> _privateFile(String name) async {
    final dir = await getApplicationSupportDirectory();
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return File(plib.join(dir.path, name));
  }

  static Future<File?> downloadFile(String name) async {
    final dir = await getDownloadsDirectory();
    if (dir == null) return null;
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return File(plib.join(dir.path, name));
  }

  static Future<File> _tempFile(String name) async {
    final dir = await getTemporaryDirectory();
    return File(plib.join(dir.path, name));
  }

  static Future<File> _settingsFile() async {
    return await _privateFile("settings.json");
  }

  static Future<void> saveSettings(Map<String, dynamic> data) async {
    final file = await _settingsFile();
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(data));
  }

  static Future<Map<String, dynamic>?> loadSettings() async {
    try {
      final file = await _settingsFile();
      if (!await file.exists()) return null;
      final text = await file.readAsString();
      return jsonDecode(text) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  static Future<String?> savePic(String name, Uint8List data) async {
    try {
      final file = Env.isMobile
          ? await _tempFile(name)
          : await downloadFile(name) ?? await _tempFile(name);
      await file.writeAsBytes(data);
      return file.path;
    } catch (_) {
      return null;
    }
  }
}
