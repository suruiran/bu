import 'package:bu/schema.dart';
import 'package:flutter/material.dart';

enum YaoType {
  Null(0, isYang: false, isChanging: false),
  LaoYin(6, isYang: false, isChanging: true),
  ShaoYang(7, isYang: true, isChanging: false),
  ShaoYin(8, isYang: false, isChanging: false),
  LaoYang(9, isYang: true, isChanging: true);

  final int value;
  final bool isYang;
  final bool isChanging;

  const YaoType(this.value, {required this.isYang, required this.isChanging});

  factory YaoType.fromValue(int val) {
    return YaoType.values.firstWhere((e) => e.value == val);
  }

  Color color(Schema schema) {
    return schema.color(value);
  }
}

class YaoWidget extends StatelessWidget {
  final YaoType type;
  final double height;
  final Schema schema;

  const YaoWidget({
    super.key,
    required this.type,
    required this.schema,
    this.height = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: type.value == 0
          ? _buildNull(context)
          : type.isYang
          ? _buildYangYao()
          : _buildYinYao(),
    );
  }

  Widget _buildNull(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
    );
  }

  Widget _buildYangYao() {
    return Container(decoration: BoxDecoration(color: type.color(schema)));
  }

  Widget _buildYinYao() {
    return Row(
      children: [
        Expanded(
          flex: 46,
          child: Container(
            decoration: BoxDecoration(color: type.color(schema)),
          ),
        ),
        const Spacer(flex: 8),
        Expanded(
          flex: 46,
          child: Container(
            decoration: BoxDecoration(color: type.color(schema)),
          ),
        ),
      ],
    );
  }
}

class HexagramWidget extends StatelessWidget {
  final List<int> yaos;
  final double width;
  final double yaoHeight;
  final double spacing;
  final Schema schema;

  const HexagramWidget({
    super.key,
    required this.yaos,
    required this.schema,
    this.width = 200.0,
    this.yaoHeight = 14.0,
    this.spacing = 10.0,
  });

  Widget _yaoAt(int val, bool islast) {
    return Padding(
      padding: EdgeInsets.only(bottom: islast ? 0 : spacing),
      child: YaoWidget(
        type: YaoType.fromValue(val),
        schema: schema,
        height: yaoHeight,
      ),
    );
  }

  List<Widget> _yaos(List<int> vals, int begin, int end) {
    return [
      for (int i = begin; i < end; i++) _yaoAt(vals[i], i == vals.length - 1),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final reversedYaos = yaos.reversed.toList();

    return SizedBox(
      width: width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ..._yaos(reversedYaos, 0, 3),
          SizedBox(height: yaoHeight),
          ..._yaos(reversedYaos, 3, reversedYaos.length),
        ],
      ),
    );
  }
}
