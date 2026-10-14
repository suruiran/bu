import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_i18n/widgets/i18n_text.dart';
import 'package:bu/i18n.dart' as i18n;

final _i18ns = (GotIt: i18n.add("Got it"));

Color? parseColor(String v) {
  final iv = int.tryParse(v, radix: 16);
  if (iv == null) return null;
  return Color(iv);
}

Future<Color> pickColor(BuildContext context, Color val) async {
  Color tmp = val;
  Color result = val;

  await showDialog(
    context: context,
    builder: (_) {
      return AlertDialog(
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: tmp,
            onColorChanged: (nc) {
              tmp = nc;
            },
          ),
        ),
        actions: <Widget>[
          ElevatedButton(
            child: I18nText(_i18ns.GotIt),
            onPressed: () {
              result = tmp;
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
  return result;
}
