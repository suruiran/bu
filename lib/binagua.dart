import 'dart:convert';

import 'package:bu/gen/assets.gen.dart';
import 'package:flutter/services.dart';
import 'package:json_annotation/json_annotation.dart';

part 'binagua.g.dart';

@JsonSerializable()
class GuaInfo {
  String name;
  String ci;
  List<String> yaos;

  GuaInfo(this.name, this.ci, this.yaos);

  factory GuaInfo.fromJson(Map<String, dynamic> json) =>
      _$GuaInfoFromJson(json);

  Map<String, dynamic> toJson() => _$GuaInfoToJson(this);
}

Map<String, GuaInfo> ALL_GUA_INFOS = {};

Future<void> load_guas() async {
  final String jsonString = await rootBundle.loadString(Assets.guas);
  final raw = jsonDecode(jsonString) as Map<String, dynamic>;
  for (final pair in raw.entries) {
    ALL_GUA_INFOS[pair.key] = GuaInfo.fromJson(pair.value);
  }
}

typedef YaoDisplay = ({String ci, int value});

class GuaDisplay {
  final GuaInfo raw;
  final List<YaoDisplay> yaos;
  final GuaInfo? changed;

  GuaDisplay(this.raw, this.yaos, this.changed);
}

GuaDisplay parseGua(List<int> result) {
  final key = result.reversed.map((v) {
    switch (v) {
      case 6 || 8:
        {
          return "0";
        }
      case 7 || 9:
        {
          return "1";
        }
      default:
        {
          throw ArgumentError("unexpect yao value: $v");
        }
    }
  }).join();

  final raw = ALL_GUA_INFOS[key]!;

  final List<YaoDisplay> yaos = [];
  for (var i = 0; i < result.length; i++) {
    final val = result[i];
    switch (val) {
      case 6 || 9:
        {
          yaos.add((ci: raw.yaos[i], value: val));
          break;
        }
    }
  }

  GuaInfo? changed;
  if (yaos.isNotEmpty) {
    final changedKey = result.reversed
        .map((v) {
          switch (v) {
            case 6:
              return 7;
            case 9:
              return 8;
            case 7:
            case 8:
              return v;
            default:
              throw ArgumentError("unexpect yao value: $v");
          }
        })
        .map((e) => e == 7 ? "1" : "0")
        .join();

    changed = ALL_GUA_INFOS[changedKey]!;
  }

  return GuaDisplay(raw, yaos, changed);
}
