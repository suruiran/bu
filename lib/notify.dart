import 'package:flutter/material.dart';

enum NotifyKind { Success, Error, Warn, Info }

Color _notifyColor(BuildContext context, NotifyKind kind) {
  final colorScheme = Theme.of(context).colorScheme;
  switch (kind) {
    case NotifyKind.Success:
      return Colors.green;
    case NotifyKind.Error:
      return colorScheme.error;
    case NotifyKind.Warn:
      return Colors.orange;
    case NotifyKind.Info:
      return colorScheme.primary;
  }
}

void notify(
  BuildContext context,
  String msg, {
  NotifyKind kind = NotifyKind.Info,
  Duration? duration,
  Widget? content,
}) {
  final sb = SnackBar(
    content:
        content ??
        Text(
          msg,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onInverseSurface,
          ),
        ),
    backgroundColor: _notifyColor(context, kind),
    duration: duration ?? Duration(milliseconds: 4000),
    showCloseIcon: true,
  );
  ScaffoldMessenger.of(context).showSnackBar(sb);
}
