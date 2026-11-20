import 'package:material_ui/material_ui.dart';

Future<T?> modal<T>(BuildContext context, double width, Widget content) {
  return showDialog<T>(
    context: context,
    barrierDismissible: true,
    builder: (cx) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: width),
          child: content,
        ),
      ),
    ),
  );
}
