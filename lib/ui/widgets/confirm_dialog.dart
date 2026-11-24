import 'package:flutter/material.dart';

Future<bool> showConfirmDialog({
  required BuildContext context,
  required String title,
  required String content,
  required String confirmLabel,
  String cancelLabel = 'Cancel',
  Color confirmColor = Colors.redAccent,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext, false);
                  },
                  child: Text(cancelLabel),
                ),
              ),
              Expanded(
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext, true);
                  },
                  child: Text(
                    confirmLabel,
                    style: TextStyle(color: confirmColor),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    },
  );
  return confirmed ?? false;
}
