// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Settings _$SettingsFromJson(Map<String, dynamic> json) => Settings()
  ..language = json['language'] as String?
  ..schemas = (json['schemas'] as List<dynamic>)
      .map((e) => Schema.fromJson(e as Map<String, dynamic>))
      .toList()
  ..llmConfig = _$recordConvert(
    json['llm.config'],
    ($jsonValue) => (
      query: $jsonValue['query'] as String,
      url: $jsonValue['url'] as String,
    ),
  );

Map<String, dynamic> _$SettingsToJson(Settings instance) => <String, dynamic>{
  'language': instance.language,
  'schemas': instance.schemas.map((e) => e.toJson()).toList(),
  'llm.config': <String, dynamic>{
    'query': instance.llmConfig.query,
    'url': instance.llmConfig.url,
  },
};

$Rec _$recordConvert<$Rec>(Object? value, $Rec Function(Map) convert) =>
    convert(value as Map<String, dynamic>);
