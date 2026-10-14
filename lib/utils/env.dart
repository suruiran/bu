import 'package:flutter/foundation.dart';

class Env {
  static final isAndroid = !kIsWeb && defaultTargetPlatform == .android;
  static final isIOS = !kIsWeb && defaultTargetPlatform == .iOS;
  static final isLinux = !kIsWeb && defaultTargetPlatform == .linux;
  static final isWindows = !kIsWeb && defaultTargetPlatform == .windows;
  static final isMac = !kIsWeb && defaultTargetPlatform == .macOS;

  static final isMobile = isAndroid || isIOS;
  static final isDesktop = isWindows || isLinux || isMac;

  static const isDebug = kDebugMode;
}
