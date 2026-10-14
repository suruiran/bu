import 'package:bu/colorpick.dart';
import 'package:bu/schema.dart';
import 'package:bu/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:uuid/uuid.dart';
import 'package:bu/i18n.dart' as i18n;

final _i18ns = (
  LaoYin: i18n.add("LaoYin"),
  ShaoYang: i18n.add("ShaoYang"),
  ShaoYin: i18n.add("ShaoYin"),
  LaoYang: i18n.add("LaoYang"),
  NameIsRequired: i18n.add("name is required"),
  NameAlreadyExists: i18n.add("{name} already exists."),
  SchemaName: i18n.add("Schema name"),
  Cancel: i18n.add("Cancel"),
  Del: i18n.add("Delete"),
  SaveSchema: i18n.add("Save schema"),
  PickColor: i18n.add("Pick color"),
);
final SchemaDialogI18ns = _i18ns;

final _uuidgen = Uuid();

class SchemaDialog extends StatefulWidget {
  final Schema? _schema;
  final Settings _settings;

  const SchemaDialog(this._schema, this._settings, {super.key});

  @override
  State<SchemaDialog> createState() => _SchemaDialogState();
}

class _SchemaDialogState extends State<SchemaDialog> {
  final _formKey = GlobalKey<FormState>();
  late Settings _settings;
  late Schema? _schema;

  String? _name;
  List<int> _weights = [
    (HALF / 2).floor(),
    (HALF / 2).floor(),
    (HALF / 2).floor(),
    (HALF / 2).floor(),
  ];
  List<Color> _colors = DefaultYaoColors;

  _SchemaDialogState();

  @override
  void initState() {
    super.initState();
    _settings = widget._settings.copy();
    _schema = widget._schema;
    if (_schema != null) {
      _name = _schema!.name;
      _weights = _schema!.weights;
      _colors = _schema!.colors ?? DefaultYaoColors;
    }
  }

  void _submit() {
    Navigator.of(context).pop(_settings);
  }

  void _cancel() {
    Navigator.of(context).pop();
  }

  void _setWeight(int i, int value) {
    value = value.clamp(0, HALF);
    final w = List<int>.from(_weights);
    switch (i) {
      case 0:
        {
          w[0] = value;
          w[2] = HALF - value;
          break;
        }
      case 1:
        {
          w[1] = value;
          w[3] = HALF - value;
          break;
        }
      case 2:
        {
          w[2] = value;
          w[0] = HALF - value;
          break;
        }
      case 3:
        {
          w[3] = value;
          w[1] = HALF - value;
          break;
        }
    }
    setState(() => _weights = w);
  }

  String _dongYaoLabel(int idx) {
    switch (idx) {
      case 0:
        {
          return FlutterI18n.translate(context, _i18ns.LaoYin);
        }
      case 1:
        {
          return FlutterI18n.translate(context, _i18ns.ShaoYang);
        }
      case 2:
        {
          return FlutterI18n.translate(context, _i18ns.ShaoYin);
        }
      case 3:
        {
          return FlutterI18n.translate(context, _i18ns.LaoYang);
        }
      default:
        {
          throw Error();
        }
    }
  }

  Widget _buildWeightSlider(int i) {
    final w = _weights;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '${_dongYaoLabel(i)} ${(w[i] * 100 / FULL).toStringAsFixed(2).padLeft(5, "0")}%',
              ),
              IconButton(
                iconSize: 18,
                tooltip: FlutterI18n.translate(context, _i18ns.PickColor),
                onPressed: () async {
                  final pc = await pickColor(context, _colors[i]);
                  setState(() {
                    final ncs = List<Color>.from(_colors);
                    ncs[i] = pc;
                    _colors = ncs;
                  });
                },
                icon: const Icon(Icons.colorize),
                style: IconButton.styleFrom(foregroundColor: _colors[i]),
              ),
            ],
          ),
          Slider(
            value: w[i].toDouble(),
            min: 0,
            max: HALF.toDouble(),
            divisions: 1000,
            label: '${w[i]}',
            onChanged: (v) => _setWeight(i, v.round()),
            activeColor: _colors[i],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> eles = [
      Padding(
        padding: EdgeInsetsGeometry.fromLTRB(16, 12, 12, 16),
        child: Form(
          key: _formKey,
          child: TextFormField(
            initialValue: _name,
            onChanged: (value) {
              setState(() {
                _name = value;
              });
            },
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return FlutterI18n.translate(context, _i18ns.NameIsRequired);
              }
              value = value.trim();
              final editingUuid = _schema?.uuid;
              if (_settings.schemas.any(
                (v) => v.name == value && v.uuid != editingUuid,
              )) {
                return FlutterI18n.translate(
                  context,
                  _i18ns.NameAlreadyExists,
                  translationParams: {"name": value},
                );
              }
              return null;
            },
            autofocus: true,
            decoration: InputDecoration(
              border: UnderlineInputBorder(),
              labelText: FlutterI18n.translate(context, _i18ns.SchemaName),
            ),
          ),
        ),
      ),
    ];
    eles.addAll([
      const Divider(),
      _buildWeightSlider(0),
      _buildWeightSlider(1),
      _buildWeightSlider(2),
      _buildWeightSlider(3),
    ]);

    final List<Widget> btns = [
      TextButton.icon(
        onPressed: () {
          _cancel();
        },
        icon: const Icon(Icons.cancel),
        label: I18nText(_i18ns.Cancel),
      ),
    ];

    if (_schema != null) {
      btns.add(
        TextButton.icon(
          onPressed: () {
            if (_schema == null) return;
            _settings.schemas.removeWhere((e) => e.uuid == _schema?.uuid);
            _submit();
          },
          icon: const Icon(Icons.delete),
          label: I18nText(_i18ns.Del),
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.error,
          ),
        ),
      );
    }

    btns.add(
      TextButton.icon(
        label: I18nText(_i18ns.SaveSchema),
        onPressed: () {
          if (!(_formKey.currentState?.validate() ?? false)) return;

          var uuid = "";
          if (_schema != null) {
            uuid = _schema!.uuid;
            _settings.schemas.removeWhere((e) => e.uuid == _schema?.uuid);
          } else {
            uuid = _uuidgen.v7();
          }

          final ns = Schema(
            uuid,
            _name!.trim(),
            _weights,
            List<Color>.from(_colors),
          );
          _settings.schemas.add(ns);

          _submit();
        },
        icon: const Icon(Icons.save),
      ),
    );

    eles.add(Divider());

    eles.add(
      Padding(
        padding: EdgeInsetsGeometry.fromLTRB(16, 0, 16, 16),
        child: Row(mainAxisAlignment: .spaceBetween, children: btns),
      ),
    );

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [...eles]),
      ),
    );
  }
}
