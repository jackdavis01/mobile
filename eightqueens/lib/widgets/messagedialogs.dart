import 'package:flutter/material.dart';

Future info2ButtonDialog(BuildContext context, bool barrierDismissible, MainAxisAlignment actionsAlignment,
    String title, String message, String button1text, String button2text,
    Function button1function, Function button2function, {EdgeInsets? insetPadding}) {
  return showDialog(
    barrierDismissible: barrierDismissible,
    builder: (context) {
      return AlertDialog(
        title: Text(title, textAlign: TextAlign.center),
        content: Text(message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18)),
        insetPadding: insetPadding,
        actionsAlignment: actionsAlignment,
        actions: <Widget>[
          TextButton(
            child: Text(button1text, style: const TextStyle(fontSize: 18.0)),
            onPressed: () {
              Navigator.of(context).pop();
              button1function();
            }),
            TextButton(
              child: Text(button2text, style: const TextStyle(fontSize: 18.0)),
              onPressed: () {
                Navigator.of(context).pop();
                button2function();
              }),
        ],
      );
    },
    context: context,
  );
}
