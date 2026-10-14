import 'dart:convert';
import 'dart:io';

import 'package:bu/utils/env.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/loaders/file_translation_loader.dart';
import 'package:flutter_i18n/loaders/translation_loader.dart';
import 'package:path/path.dart' as plib;

Set<String> ALL_KEYS = {};

Future<void> _exportAllI18nKeysAndSync(List<String> languageCodes) async {
  if (!Env.isDesktop || !Env.isDebug) {
    throw StateError("Export i18n only works on Desktop in Debug mode.");
  }

  final sortedkeys = List<String>.from(ALL_KEYS);
  sortedkeys.sort();

  await Future.wait(languageCodes.map((v) => _one_language(v, sortedkeys)));
}

const _basePath = String.fromEnvironment('I18N_BASE_PATH');

const _missing_prefix = "__MISSING__:";

Future<void> _one_language(String lc, List<String> keys) async {
  if (_basePath.isEmpty) {
    throw StateError('I18N_BASE_PATH is empty');
  }

  final file = File(plib.join(_basePath, "$lc.json"));

  Map<String, String> prev = {};
  if (await file.exists()) {
    try {
      final raw = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      for (var pair in raw.entries) {
        final val = (pair.value as String).trim();
        if (val.isEmpty || val.startsWith(_missing_prefix)) {
          continue;
        }
        prev[pair.key] = val;
      }
    } catch (_) {}
  }

  Map<String, String> current = {};

  for (var key in keys) {
    current[key] = prev[key] ?? "$_missing_prefix$key";
  }

  await file.writeAsString(const JsonEncoder.withIndent('  ').convert(current));
}

TranslationLoader? makeTranslationLoader() {
  if (_basePath.isEmpty) {
    return FileTranslationLoader(basePath: "assets/i18ns", useScriptCode: true);
  }
  return null;
}

const SupportedLocales = [
  Locale('en'),
  Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
  Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
  Locale('ja'),
  Locale('ko'),
];

final SupportedLanguages = SupportedLocales.map((v) {
  if (v.scriptCode != null) return "${v.languageCode}_${v.scriptCode}";
  return v.languageCode;
}).toList(growable: false);

Locale? findSupportedLocale(String code) {
  final idx = SupportedLanguages.indexOf(code);
  if (idx < 0) return null;
  return SupportedLocales[idx];
}

Widget exportI18nsBtns() {
  if (_basePath.isEmpty) {
    return SizedBox.shrink();
  }
  return TextButton(
    onPressed: () async {
      await _exportAllI18nKeysAndSync(SupportedLanguages);
      // ignore: avoid_print
      print(">>> EXPORT I18NS DONE <<<");
    },
    child: Text("Export I18ns"),
  );
}

String add(String txt) {
  if (_basePath.isNotEmpty) {
    ALL_KEYS.add(txt);
    // ignore: avoid_print
    print("$txt ${ALL_KEYS.length}");
  }
  return txt;
}
