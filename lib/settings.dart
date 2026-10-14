import 'dart:convert';

import 'package:bu/i18n.dart';
import 'package:bu/schema.dart';
import 'package:json_annotation/json_annotation.dart';

part 'settings.g.dart';

typedef LLMConfig = ({bool disable, String url, String query});

const LLMConfig defaulLLMCfg = (
  disable: false,
  url: "https://chat.deepseek.com/",
  query: "q",
);

@JsonSerializable(explicitToJson: true)
class Settings {
  String? language;

  List<Schema> schemas = [];

  @JsonKey(name: "llm.config")
  LLMConfig llmConfig = defaulLLMCfg;

  Settings();

  factory Settings.fromJson(Map<String, dynamic> json) =>
      _$SettingsFromJson(json);
  Map<String, dynamic> toJson() => _$SettingsToJson(this);

  static Settings fromJsonSafe(Map<String, dynamic>? json) {
    final result = Settings();
    if (json == null) return result._ensure();

    final languagev = json["language"];
    if (languagev is String && SupportedLanguages.contains(languagev)) {
      result.language = languagev;
    }

    final list = json['schemas'];
    if (list is List) {
      for (final e in list) {
        if (e is! Map<String, dynamic>) continue;
        try {
          result.schemas.add(Schema.fromJson(e));
        } catch (_) {}
      }
    }

    final llm = json['llm.config'];
    if (llm is Map<String, dynamic>) {
      result.llmConfig = (
        disable: llm['disable'] as bool? ?? defaulLLMCfg.disable,
        url: llm['url'] as String? ?? defaulLLMCfg.url,
        query: llm['query'] as String? ?? defaulLLMCfg.query,
      );
    }
    return result._ensure();
  }

  Settings _ensureSchemas() {
    if (schemas.isEmpty) {
      schemas = BuiltInSchemas.map((v) => v.copy()).toList();
      return this;
    }

    Map<String, ({Schema s, int i})> index = {};

    for (var i = 0; i < schemas.length; i++) {
      final ele = schemas[i];
      if (ele.isbuiltin()) continue;
      if (!ele.vld()) continue;
      index[ele.uuid] = (i: i, s: ele);
    }

    final customs = index.values.toList();
    customs.sort((a, b) => a.i - b.i);

    final List<Schema> tmp = BuiltInSchemas.map((v) => v.copy()).toList();
    tmp.addAll(customs.map((v) => v.s));

    schemas = tmp;
    return this;
  }

  Settings _ensure() {
    return _ensureSchemas();
  }

  Settings copy() {
    return Settings.fromJson(jsonDecode(jsonEncode(this)));
  }
}
