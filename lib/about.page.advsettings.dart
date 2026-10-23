import 'package:bu/i18n.dart' as i18n;
import 'package:bu/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

final _i18ns = (
  LLMConfig: i18n.add("LLM Config"),
  Url: i18n.add("URL"),
  Query: i18n.add("Prompt Query Key"),
  UrlIsRequired: i18n.add("URL is required"),
  UrlIsInvalid: i18n.add("URL is invalid"),
);
final AdvSettingsI18ns = _i18ns;

class AdvSettingsDialog extends StatefulWidget {
  final Settings settings;

  const AdvSettingsDialog({super.key, required this.settings});

  @override
  State<StatefulWidget> createState() => _AdvSettingsDialogState();
}

const Map<String, LLMConfig> _llms = {
  "ChatGPT": (query: "q", url: "https://chatgpt.com/"),
  "Claude": (query: "q", url: "https://claude.ai/new"),
  "DeepSeek": (query: "q", url: "https://chat.deepseek.com/"),
  "Grok": (query: "q", url: "https://grok.com/"),
  "Qianwen": (query: "q", url: "https://qianwen.com/"),
  "Kimi": (query: "", url: "https://kimi.com/"),
  "Gemini": (query: "", url: "https://gemini.google.com/app"),
  "Doubao": (query: "", url: "https://www.doubao.com/chat"),
};
final _llmnames = _llms.keys.toList(growable: false)..sort();

class _AdvSettingsDialogState extends State<AdvSettingsDialog> {
  final _formKey = GlobalKey<FormState>();

  String? _llm_name;
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _queryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _urlController.text = widget.settings.llmConfig.url;
    _queryController.text = widget.settings.llmConfig.query;
  }

  @override
  void dispose() {
    _urlController.dispose();
    _queryController.dispose();
    super.dispose();
  }

  void _update_llm_name() {
    if (_llm_name == null) return;
    final llm = _llms[_llm_name!];
    if (llm == null) return;
    _urlController.text = llm.url;
    _queryController.text = llm.query;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsetsGeometry.fromLTRB(16, 12, 12, 16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: .start,
                        children: [I18nText(_i18ns.LLMConfig)],
                      ),
                      Padding(
                        padding: EdgeInsetsGeometry.all(10),
                        child: Column(
                          children: [
                            TextFormField(
                              maxLines: 2,
                              minLines: 1,
                              controller: _urlController,
                              decoration: InputDecoration(
                                border: UnderlineInputBorder(),
                                label: I18nText(_i18ns.Url),
                                suffix: DropdownButton(
                                  style: TextStyle(fontSize: 12),
                                  value: _llm_name,
                                  items: _llmnames
                                      .map(
                                        (n) => DropdownMenuItem(
                                          value: n,
                                          child: Text(n),
                                        ),
                                      )
                                      .toList(growable: false),
                                  onChanged: (v) {
                                    setState(() {
                                      _llm_name = v;
                                      _update_llm_name();
                                    });
                                  },
                                ),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _llm_name = null;
                                });
                              },
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return FlutterI18n.translate(
                                    context,
                                    _i18ns.UrlIsRequired,
                                  );
                                }
                                final uobj = Uri.tryParse(value.trim());
                                if (uobj == null) {
                                  return FlutterI18n.translate(
                                    context,
                                    _i18ns.UrlIsInvalid,
                                  );
                                }
                                if (uobj.scheme != "http" &&
                                    uobj.scheme != "https") {
                                  return FlutterI18n.translate(
                                    context,
                                    _i18ns.UrlIsInvalid,
                                  );
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 12),
                            TextFormField(
                              controller: _queryController,
                              decoration: InputDecoration(
                                border: UnderlineInputBorder(),
                                labelText: FlutterI18n.translate(
                                  context,
                                  _i18ns.Query,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsetsGeometry.fromLTRB(0, 16, 16, 0),
                    child: Row(
                      mainAxisAlignment: .spaceBetween,
                      children: [
                        TextButton.icon(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          label: I18nText(i18n.CommonI18ns.Cancel),
                          icon: const Icon(Icons.cancel),
                        ),
                        TextButton.icon(
                          onPressed: () {
                            if (!(_formKey.currentState?.validate() ?? false)) {
                              return;
                            }
                            final nv = widget.settings.copy();
                            nv.llmConfig = (
                              query: _queryController.text.trim(),
                              url: _urlController.text.trim(),
                            );
                            Navigator.of(context).pop(nv);
                          },
                          label: I18nText(i18n.CommonI18ns.Save),
                          icon: const Icon(Icons.save),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
