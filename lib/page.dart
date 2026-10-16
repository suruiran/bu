import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:bu/about.page.dart';
import 'package:bu/binagua.dart';
import 'package:bu/fs.dart';
import 'package:bu/i18n.dart';
import 'package:bu/i18n.dart' as i18n;
import 'package:bu/modal.dart';
import 'package:bu/notify.dart';
import 'package:bu/schema.dart';
import 'package:bu/settings.dart';
import 'package:bu/schema.editor.dart';
import 'package:bu/user_behavior.dart';
import 'package:bu/utils/fmttime.dart';
import 'package:bu/utils/env.dart';
import 'package:bu/yao.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

part 'page.llm.dart';
part 'page.share.dart';

class HomePage extends StatefulWidget {
  final ValueChanged<Locale?> _changeLocale;

  const HomePage(this._changeLocale, {super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

final _SubjectLabels = [
  i18n.add("What's on your mind?"),
  i18n.add("Anything you'd like to share?"),
  i18n.add("What's up?"),
  i18n.add("Share a thought..."),
];

final _i18ns = (
  Bu: i18n.add("Bu"),
  EditSchema: i18n.add("Edit schema"),
  Clear: i18n.add("Clear"),
  AddSchema: i18n.add("Add schema"),
  ShakePhone: i18n.add("Shake your phone or touch anywhere... 🤪"),
  WiggleMouse: i18n.add("Wiggle your mouse... 🤪"),
);
final HomePageI18ns = _i18ns;

String _rand_subject_label() {
  return _SubjectLabels[Random().nextInt(_SubjectLabels.length)];
}

class _HomePageState extends State<HomePage> {
  final _rbKey = GlobalKey();

  late final ValueChanged<Locale?> _changeLocale = widget._changeLocale;

  final _subject_controller = TextEditingController();
  final _subject_focus_node = FocusNode();
  String _subject = "";
  String _subjectLabel = _rand_subject_label();

  Settings? _settings;
  bool _loading = true;
  bool _doing = false;
  int _evtCount = 0;
  final _ubesCtrl = UserBehaviorEntropySourceController();

  Schema? _schema;
  List<int> _result = [0, 0, 0, 0, 0, 0];
  GuaDisplay? _temp_gua;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _subject_controller.dispose();
    _subject_focus_node.dispose();
    super.dispose();
  }

  bool _resultok() {
    return _result.length == 6 && !_result.any((v) => v == 0);
  }

  Future<void> _load() async {
    await load_guas();

    final settings = Settings.fromJsonSafe(await Fs.loadSettings());

    setState(() {
      _loading = false;
      _settings = settings;
      _schema = settings.schemas.first;
    });

    _changeLocale(findSupportedLocale(settings.language ?? ""));
  }

  Future<void> _showSchemaDialog(Schema? schema) async {
    if (!mounted || _loading || _settings == null) return;
    final result = await modal<Settings>(
      context,
      (MediaQuery.sizeOf(context).width * 0.6).clamp(200, 400),
      SchemaEditor(schema, _settings!),
    );
    if (!mounted || result == null) return;
    await _changeSettings(result);
  }

  Future<void> _changeSettings(Settings ns) async {
    await Fs.saveSettings(ns.toJson());
    setState(() {
      _settings = ns;
      if (_schema != null) {
        _schema = _settings?.schemas.firstWhere(
          (v) => v.uuid == _schema?.uuid,
          orElse: () => _settings!.schemas.first,
        );
      }
      _result = [0, 0, 0, 0, 0, 0];
    });
  }

  Future<void> _doBu() async {
    if (!mounted || _schema == null || _doing) return;
    _subject_focus_node.unfocus();

    final List<int> yaos = [0, 0, 0, 0, 0, 0];

    setState(() {
      _evtCount = 0;
      _doing = true;
      _result = yaos;
      _temp_gua = null;
    });

    int prevEvtCount = 0;

    for (var i = 0; i < 6; i++) {
      final List<int> es = [];
      final (stream, cancel) = _ubesCtrl.request();
      final subscription = stream.listen((ints) {
        es.addAll(ints);
        setState(() {
          _evtCount = es.length + prevEvtCount;
          prevEvtCount = _evtCount;
        });
      });
      await Future.delayed(const Duration(milliseconds: 600));
      subscription.cancel().ignore();
      cancel();
      if (!mounted) return;
      setState(() {
        yaos[i] = _schema!.gen(es: es);
      });
    }

    setState(() {
      _evtCount = 0;
      _doing = false;
      _temp_gua = _resultok() ? parseGua(_result) : null;
    });
  }

  Widget _buBtn() {
    return IconButton(
      onPressed: () {
        _doBu();
      },
      icon: _resultok()
          ? const Icon(Icons.replay_circle_filled, size: 36)
          : const Icon(Icons.play_circle, size: 36),
      tooltip: FlutterI18n.translate(context, _i18ns.Bu),
    );
  }

  Widget _gua_display(GuaInfo info) {
    final List<Widget> eles = [];
    eles.add(
      SelectableText(
        info.name,
        style: TextStyle(fontSize: 32, fontWeight: FontWeight.w500),
      ),
    );
    eles.add(SizedBox(height: 2));
    eles.add(SelectableText(info.ci));

    return Padding(
      padding: EdgeInsetsGeometry.fromLTRB(12, 0, 12, 0),
      child: Column(children: eles),
    );
  }

  Widget _yaos_display(List<YaoDisplay> yaos) {
    final List<Widget> eles = [];
    var i = 0;
    for (var yao in yaos.reversed) {
      i++;
      if (i != 1) {
        eles.add(SizedBox(height: 4));
      }
      eles.add(
        SelectableText(
          yao.ci,
          style: TextStyle(color: _schema!.color(yao.value)),
        ),
      );
    }
    return Padding(
      padding: EdgeInsetsGeometry.fromLTRB(16, 0, 16, 0),
      child: Column(children: eles),
    );
  }

  Widget _result_display() {
    final List<Widget> eles = [];
    eles.add(SizedBox(height: 12));
    final gua = _temp_gua!;

    eles.add(_gua_display(gua.raw));

    if (gua.yaos.isNotEmpty) {
      eles.add(SizedBox(height: 24));
      eles.add(_yaos_display(gua.yaos));
    }

    if (gua.changed != null) {
      eles.add(SizedBox(height: 24));
      eles.add(_gua_display(gua.changed!));
    }
    return Column(children: eles);
  }

  Widget _content() {
    final List<Widget> eles = [
      Center(
        child: HexagramWidget(yaos: _result, schema: _schema!),
      ),
    ];
    eles.add(
      Center(
        child: SizedBox(
          width: (MediaQuery.sizeOf(context).width * 0.6).clamp(0, 640),
          child: TextField(
            enabled: !_doing,
            keyboardType: TextInputType.multiline,
            minLines: 1,
            maxLines: 5,
            controller: _subject_controller,
            focusNode: _subject_focus_node,
            onChanged: (value) => _subject = value,
            decoration: InputDecoration(
              labelText: FlutterI18n.translate(context, _subjectLabel),
            ),
          ),
        ),
      ),
    );
    if (!_doing) {
      if (_resultok() && _temp_gua != null) {
        eles.add(_result_display());
      }
    }
    return RepaintBoundary(
      key: _rbKey,
      child: Container(
        color: Theme.of(context).colorScheme.surface,
        child: Padding(
          padding: EdgeInsetsGeometry.fromLTRB(0, 16, 0, 16),
          child: Column(children: eles),
        ),
      ),
    );
  }

  Widget _dropdown(BuildContext cx) {
    return SizedBox(
      width: (MediaQuery.sizeOf(cx).width * 0.4).clamp(0, 480),
      child: DropdownButton(
        isExpanded: true,
        value: _schema,
        selectedItemBuilder: (_) => _settings!.schemas
            .map(
              (v) =>
                  Align(alignment: Alignment.centerLeft, child: v.nameWidget()),
            )
            .toList(growable: false),
        items: _settings!.schemas
            .map((v) {
              final List<Widget> eles = [v.nameWidget()];
              if (!v.isbuiltin()) {
                eles.add(const SizedBox(width: 16));
                eles.add(
                  IconButton(
                    tooltip: FlutterI18n.translate(context, _i18ns.EditSchema),
                    onPressed: () {
                      Navigator.of(cx).pop();
                      _showSchemaDialog(v);
                    },
                    icon: const Icon(Icons.edit),
                  ),
                );
              }
              return DropdownMenuItem(
                value: v,
                child: Row(children: eles),
              );
            })
            .toList(growable: false),
        onChanged: _doing
            ? null
            : (value) {
                if (value == _schema) return;
                setState(() {
                  _schema = value as Schema?;
                  _result = [0, 0, 0, 0, 0, 0];
                });
              },
      ),
    );
  }

  Widget _clearBtn() {
    return IconButton(
      onPressed: () {
        setState(() {
          _temp_gua = null;
          _result = [0, 0, 0, 0, 0, 0];
          _subject_controller.clear();
          _subjectLabel = _rand_subject_label();
        });
      },
      icon: const Icon(Icons.clear_all, size: 36),
      tooltip: FlutterI18n.translate(context, _i18ns.Clear),
    );
  }

  @override
  Widget build(BuildContext cx) {
    if (_loading) {
      return Scaffold(
        body: Column(
          mainAxisAlignment: .center,
          children: [
            Center(child: Text("🌀...", style: TextStyle(fontSize: 36))),
          ],
        ),
      );
    }

    final List<Widget> btns = [];

    if (!_doing) {
      btns.add(_buBtn());
      if (_resultok() && _temp_gua != null) {
        btns.add(_clearBtn());
        btns.add(_askLLMBtn());
        btns.add(_sharePicBtn());
      }
    }

    final List<Widget> shakingTip = [];
    if (_doing) {
      shakingTip.add(SizedBox(height: 32));
      shakingTip.add(
        TweenAnimationBuilder<double>(
          key: ValueKey(_evtCount),
          tween: Tween<double>(begin: 1.0, end: 1.2),
          duration: const Duration(milliseconds: 100),
          builder: (ctx, scale, _) {
            return Transform.scale(
              scale: scale,
              alignment: Alignment.center,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  I18nText(
                    Env.isMobile ? _i18ns.ShakePhone : _i18ns.WiggleMouse,
                  ),
                  _evtCount > 0 ? SizedBox(width: 8) : SizedBox.shrink(),
                  _evtCount > 0
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(ctx).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$_evtCount',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(ctx)
                                  .colorScheme
                                  .onPrimaryContainer,
                            ),
                          ),
                        )
                      : SizedBox.shrink(),
                ],
              ),
            );
          },
        ),
      );
    }
    return UserBehaviorEntropySource(
      ctrl: _ubesCtrl,
      child: Scaffold(
        body: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(6, 12, 6, 12),
          child: Center(
            child: Column(
              mainAxisAlignment: .start,
              children: [
                SizedBox(height: 32),
                Row(
                  mainAxisAlignment: .center,
                  children: [
                    _dropdown(cx),
                    const SizedBox(width: 16),
                    IconButton(
                      tooltip: FlutterI18n.translate(context, _i18ns.AddSchema),
                      onPressed: _doing
                          ? null
                          : () {
                              _showSchemaDialog(null);
                            },
                      icon: const Icon(Icons.add_circle),
                    ),
                  ],
                ),
                SizedBox(height: 32),
                _content(),
                btns.isNotEmpty ? SizedBox(height: 32) : SizedBox.shrink(),
                Row(mainAxisAlignment: .center, children: btns),
                ...shakingTip,
              ],
            ),
          ),
        ),
        floatingActionButton: IconButton(
          onPressed: () {
            if (_settings == null) return;
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) =>
                    AboutPage(settings: _settings!, update: _changeSettings),
              ),
            );
          },
          icon: const Icon(Icons.info_outline),
        ),
      ),
    );
  }
}
