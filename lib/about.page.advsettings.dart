import 'package:bu/i18n.dart' as i18n;
import 'package:bu/settings.dart';
import 'package:flutter/material.dart';

final _i18ns = (AdvancedSettings: i18n.add("Advanced Settings"));
final AdvSettingsI18ns = _i18ns;

class AdvSettingsDialog extends StatefulWidget {
  final Settings settings;

  const AdvSettingsDialog({super.key, required this.settings});

  @override
  State<StatefulWidget> createState() => _AdvSettingsDialogState();
}

class _AdvSettingsDialogState extends State<AdvSettingsDialog> {
  bool _isCustom = false;
  String? _url;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          DropdownButton(
            isExpanded: true,
            items: SupportedLLMConfigs.map((v) {
              return DropdownMenuItem(value: v.url, child: Text(v.url));
            }).toList(growable: false),
            onChanged: (v) {},
          ),
        ],
      ),
    );
  }
}
