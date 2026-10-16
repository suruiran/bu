import 'package:bu/about.page.advsettings.dart';
import 'package:bu/gen/assets.gen.dart';
import 'package:bu/i18n.dart';
import 'package:bu/i18n.dart' as i18n;
import 'package:bu/modal.dart';
import 'package:bu/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:url_launcher/url_launcher.dart';

part 'about.page.info.g.dart';

final _i18ns = (
  About: i18n.add("About"),
  Version: i18n.add("Version {ver}"),
  License: i18n.add("License {lic}"),
  Description: i18n.add(_desc),
);
final AboutI18ns = _i18ns;

class AboutPage extends StatelessWidget {
  final Settings settings;
  final Future<void> Function(Settings) update;

  const AboutPage({super.key, required this.settings, required this.update});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: I18nText(_i18ns.About)),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: EdgeInsetsGeometry.fromLTRB(32, 16, 32, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Assets.icon.image(width: 120),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: .center,
                  children: [
                    SelectableText(
                      '卜',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    SelectableText('Bu', style: TextStyle(fontSize: 24)),
                  ],
                ),
                const SizedBox(height: 8),
                I18nText(_i18ns.Description),
                const SizedBox(height: 24),
                Text(
                  FlutterI18n.translate(
                    context,
                    _i18ns.Version,
                    translationParams: {"ver": _version},
                  ),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: .center,
                  children: [
                    TextButton.icon(
                      onPressed: () => launchUrl(
                        Uri.parse('http://github.com/suruiran/bu'),
                        mode: LaunchMode.externalApplication,
                      ),
                      icon: const Icon(Icons.open_in_new, size: 16),
                      label: const Text('GitHub'),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      FlutterI18n.translate(
                        context,
                        _i18ns.License,
                        translationParams: {"lic": "The Unlicense"},
                      ),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () async {
                    final tmp = settings.copy();
                    final result = await modal(
                      context,
                      (MediaQuery.sizeOf(context).width * 0.6).clamp(200, 400),
                      AdvSettingsDialog(settings: tmp),
                    );
                    if (result == null) return;
                    await update(result);
                  },
                  icon: const Icon(Icons.settings, size: 16),
                  label: const Text('Advanced Settings'),
                ),
                exportI18nsBtns(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
