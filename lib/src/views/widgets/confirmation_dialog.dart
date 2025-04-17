import 'package:fluent_ui/fluent_ui.dart';

Future<void> showConfirmationDialog(
  BuildContext context, {
  bool noButtonIsFilled = false,
  required String content,
  required Function() onConfirmedAction,
  required Function() onDeclinedAction,
  BoxConstraints constraints = kDefaultContentDialogConstraints,
}) async {
  await showDialog(
    context: context,
    builder: (_) {
      return ContentDialog(
        style: const ContentDialogThemeData(
            titleStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
        )),
        title: const Text('Предупреждение'),
        content: Text(content),
        actions: noButtonIsFilled
            ? [
                Button(
                  onPressed: onConfirmedAction,
                  child: const Text('Да'),
                ),
                FilledButton(
                  onPressed: onDeclinedAction,
                  child: const Text('Нет'),
                ),
              ]
            : [
                FilledButton(
                  onPressed: onConfirmedAction,
                  child: const Text('Да'),
                ),
                Button(
                  onPressed: onDeclinedAction,
                  child: const Text('Нет'),
                ),
              ],
        constraints: constraints,
      );
    },
  );
}
