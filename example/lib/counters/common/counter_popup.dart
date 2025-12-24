import 'package:flutter/material.dart';
import 'package:inheriteds/inheriteds.dart';

import 'counter.dart';

void counterPopup<T extends Counter>(BuildContext context) {
  showDialog(
    context: context,
    builder: (rootContext) {
      return CounterPopup<T>();
    },
  );
}

class CounterPopup<T extends Counter> extends StatelessWidget {
  const CounterPopup({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        alignment: Alignment.topCenter,
        title: Text("Popup context"),
        content: Text("$T.value: ${InheritedObject.maybeOf<T>(context)?.value}"),
        actions: [
          TextButton(
            onPressed: () {
              // Update the counter value by accessing the InheritedProvider<T> via InheritedHub
              InheritedProvider.update<T>(context, (object) {
                return object.incremented() as T;
              }, or: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Failed to update counter"), duration: const Duration(seconds: 1)),
                );
              });
            },
            child: const Icon(Icons.add),
          ),

          TextButton(
            onPressed: Navigator.of(context).pop,
            child: Text("Close"),
          ),
        ],
      );;
  }
}

