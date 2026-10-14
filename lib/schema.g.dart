// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schema.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Schema _$SchemaFromJson(Map<String, dynamic> json) => Schema(
  json['uuid'] as String,
  json['name'] as String,
  (json['weights'] as List<dynamic>).map((e) => (e as num).toInt()).toList(),
  colorsFromJSON(json['colors']),
);

Map<String, dynamic> _$SchemaToJson(Schema instance) => <String, dynamic>{
  'uuid': instance.uuid,
  'name': instance.name,
  'weights': instance.weights,
  'colors': colorsToJSON(instance.colors),
};
