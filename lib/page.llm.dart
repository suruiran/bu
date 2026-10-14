part of 'page.dart';

final _llmi18ns = (
  Begin: i18n.add("Please help me interpret the following hexagram:"),
  Hexagram: i18n.add("Hexagram"),
  Judgment: i18n.add("Judgment"),
  ChangingLines: i18n.add("Changing lines"),
  ChangedHexagram: i18n.add("Changed hexagram"),
  MySubject: i18n.add("My subject"),
  End: i18n.add("Please give a detailed explanation."),
  EndWithSubject: i18n.add(
    "Please give a detailed explanation based on my subject.",
  ),
  AskLLM: i18n.add("Ask LLM"),
  AskLLMFailed: i18n.add("Ask LLM failed"),
);
final AskLLMI18ns = _llmi18ns;

extension _PageLLm on _HomePageState {
  Future<void> _askLLM() async {
    if (!mounted || _temp_gua == null) return;

    final gua = _temp_gua!;

    final buf = StringBuffer();

    buf.writeln(FlutterI18n.translate(context, _llmi18ns.Begin));
    buf.writeln();

    buf.writeln(
      "## ${FlutterI18n.translate(context, _llmi18ns.Hexagram)}: ${gua.raw.name}",
    );
    buf.writeln("### ${FlutterI18n.translate(context, _llmi18ns.Judgment)}");
    buf.writeln();
    buf.writeln(gua.raw.ci);
    buf.writeln();

    if (gua.yaos.isNotEmpty) {
      buf.writeln();
      buf.writeln(
        "### ${FlutterI18n.translate(context, _llmi18ns.ChangingLines)}",
      );
      for (var yao in gua.yaos) {
        buf.writeln(yao.ci);
      }
    }

    if (gua.changed != null) {
      buf.writeln();
      buf.writeln(
        "## ${FlutterI18n.translate(context, _llmi18ns.ChangedHexagram)}: ${gua.changed!.name}",
      );
      buf.writeln("### ${FlutterI18n.translate(context, _llmi18ns.Judgment)}");
      buf.writeln();
      buf.writeln(gua.changed!.ci);
    }

    buf.writeln();

    final subject = _subject.trim();
    if (subject.isNotEmpty) {
      buf.writeln("## ${FlutterI18n.translate(context, _llmi18ns.MySubject)}");
      buf.writeln();
      buf.writeln(subject);
    }

    buf.writeln();
    buf.writeln(
      FlutterI18n.translate(
        context,
        subject.isNotEmpty ? _llmi18ns.EndWithSubject : _llmi18ns.End,
      ),
    );

    final prompt = buf.toString();
    final url = Uri.tryParse(_settings!.llmConfig.url);
    if (url == null) return;
    final uri = Uri.https(url.host, url.path, {
      _settings!.llmConfig.query: prompt,
    });
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
      notify(
        context,
        FlutterI18n.translate(context, _llmi18ns.AskLLMFailed),
        kind: NotifyKind.Error,
      );
    }
  }

  Widget _askLLMBtn() {
    return IconButton(
      onPressed: _askLLM,
      icon: const Icon(Icons.question_answer, size: 36),
      tooltip: FlutterI18n.translate(context, _llmi18ns.AskLLM),
    );
  }
}
