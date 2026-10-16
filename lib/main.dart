import 'dart:math';

import 'package:bu/about.page.dart';
import 'package:bu/i18n.dart';
import 'package:bu/page.dart';
import 'package:bu/schema.dart';
import 'package:bu/schema.editor.dart';
import 'package:bu/utils/env.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_i18n/flutter_i18n_delegate.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(App());
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() {
    return _AppState();
  }
}

class _AppState extends State<App> {
  late Color _seedColor;
  Locale? _locale;

  Color _randSeedColor() {
    final colors = Colors.primaries;
    return colors[Random().nextInt(colors.length)];
  }

  @override
  void initState() {
    super.initState();

    if (Env.isDebug) {
      final hcs = [
        HomePageI18ns.hashCode,
        AskLLMI18ns.hashCode,
        SharePictureI18ns.hashCode,
        AboutI18ns.hashCode,
        SchemaDialogI18ns.hashCode,
        SchemaI18ns.hashCode,
      ];
      // ignore: avoid_print
      print(hcs);
    }
    _seedColor = _randSeedColor();
  }

  ThemeData _mktheme(Brightness brightness) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _seedColor,
        brightness: brightness,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: _locale,
      supportedLocales: SupportedLocales,
      theme: _mktheme(Brightness.light),
      darkTheme: _mktheme(Brightness.dark),
      themeMode: ThemeMode.system,
      builder: (context, child) {
        final value = SystemUiOverlayStyle(
          systemNavigationBarColor: Theme.of(context).colorScheme.surface,
          systemNavigationBarDividerColor: Colors.transparent,
          systemNavigationBarIconBrightness: Theme.of(context).brightness,
        );
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: value,
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: HomePage((loc) {
        setState(() {
          _locale = loc;
        });
      }),
      localizationsDelegates: [
        FlutterI18nDelegate(
          translationLoader: makeTranslationLoader(),
          missingTranslationHandler: (_, _) {},
          keySeparator: ">>>><<<<",
        ),
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
    );
  }
}
