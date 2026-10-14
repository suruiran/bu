// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'binagua.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GuaInfo _$GuaInfoFromJson(Map<String, dynamic> json) => GuaInfo(
  json['name'] as String,
  json['ci'] as String,
  (json['yaos'] as List<dynamic>).map((e) => e as String).toList(),
);

Map<String, dynamic> _$GuaInfoToJson(GuaInfo instance) => <String, dynamic>{
  'name': instance.name,
  'ci': instance.ci,
  'yaos': instance.yaos,
};
