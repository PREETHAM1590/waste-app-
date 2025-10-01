import 'package:flutter/material.dart';

void showInfoDialog(BuildContext context, String message, [bool isJson = false]) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Information'),
        content: SingleChildScrollView(
          child: SelectableText(
            message,
            style: isJson ? const TextStyle(fontFamily: 'monospace') : null,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}

void showLoader(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    },
  );
}

void removeDialog(BuildContext context) {
  Navigator.of(context).pop();
}
