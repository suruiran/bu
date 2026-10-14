import 'dart:math';

import 'package:bu/colorpick.dart';
import 'package:bu/utils/int.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_i18n/widgets/i18n_text.dart';
import 'package:json_annotation/json_annotation.dart';

import 'package:bu/i18n.dart' as i18n;

part 'schema.g.dart';

final _i18ns = (ShiCao: i18n.add("ShiCao"), TongQian: i18n.add("TongQian"));
final SchemaI18ns = _i18ns;

const DefaultYaoColors = [
  Color.fromARGB(255, 247, 194, 66),
  Color.fromARGB(255, 38, 69, 61),
  Color.fromARGB(255, 15, 60, 172),
  Color.fromARGB(255, 203, 27, 69),
];

const FULL = 10000;
const HALF = 5000;

List<String>? colorsToJSON(List<Color>? colors) {
  return colors?.map((v) => v.toHexString()).toList(growable: false);
}

List<Color>? colorsFromJSON(dynamic v) {
  if (v is! List) return null;
  final tmp = <Color>[];
  for (final e in v) {
    if (e is! String) return null;
    final c = parseColor(e);
    if (c == null) return null;
    tmp.add(c);
  }
  return tmp.length == 4 ? tmp : null;
}

@JsonSerializable()
class Schema {
  String uuid;
  String name;
  List<int> weights;
  @JsonKey(toJson: colorsToJSON, fromJson: colorsFromJSON)
  List<Color>? colors;

  Schema(this.uuid, this.name, this.weights, this.colors);

  factory Schema.fromJson(Map<String, dynamic> json) => _$SchemaFromJson(json);
  Map<String, dynamic> toJson() => _$SchemaToJson(this);

  Schema copy() {
    return Schema(
      uuid,
      name,
      weights.toList(growable: false),
      colors?.toList(growable: false),
    );
  }

  bool vld() {
    if (weights.length != 4) return false;
    if (weights.any((v) => v < 0)) return false;
    if (weights[0] + weights[2] != HALF) return false;
    if (weights[1] + weights[3] != HALF) return false;
    return true;
  }

  int gen({List<int>? es}) {
    final List<int> input = [];
    input.addAll(intToBytes(Random.secure().nextInt(1 << 32)));
    if (es != null) {
      input.addAll(es);
    }
    final hash = sha256.convert(input).bytes;
    var val = 0;
    for (final b in hash) {
      val = (val * 256 + b) % FULL;
    }
    return _genbyval(val);
  }

  int _genbyval(int val) {
    var sum = 0;
    var idx = -1;
    for (var w in weights) {
      idx++;
      sum += w;
      if (sum > val) {
        break;
      }
    }
    return idx + 6;
  }

  Color color(int value) {
    return (colors ?? DefaultYaoColors)[value - 6];
  }

  Widget nameWidget() {
    return isbuiltin() ? I18nText(name) : Text(name);
  }

  bool isbuiltin() {
    for (var ele in BuiltInSchemas) {
      if (ele.uuid == uuid) return true;
    }
    return false;
  }
}

final BuiltInSchemas = [
  Schema("01a11258-8f3c-7f7b-95a7-29e2e84b927e", _i18ns.ShiCao, [
    625,
    3125,
    4375,
    1875,
  ], DefaultYaoColors),
  Schema("01a11258-b604-7b74-baf4-c347177c52dc", _i18ns.TongQian, [
    1250,
    3750,
    3750,
    1250,
  ], DefaultYaoColors),
];
