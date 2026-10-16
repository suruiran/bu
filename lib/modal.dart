import 'package:flutter/material.dart';

Future<T?> modal<T>(BuildContext context, double width, Widget content) {
  return showDialog<T>(
    context: context,
    barrierDismissible: true,
    builder: (cx) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
      child: AnimatedPadding(
        padding: EdgeInsetsGeometry.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: width),
            child: content,
          ),
        ),
      ),
    ),
  );
}
