import 'package:flutter/material.dart';
import 'package:inheriteds/inheriteds.dart';

import 'counter.dart';

void counterPopup<T extends Counter>(BuildContext context) {
    showDialog(
      context: context,
      builder: (rootContext) {
        return AlertDialog(
          alignment: Alignment.topCenter,
          title: Text("Root context"),
          content: Text("$T.value: ${InheritedObject.maybeOf<T>(rootContext)?.value}"),
          actions: [
            TextButton(
              onPressed: () {
                // Update the counter value by accessing the InheritedProvider<T> via InheritedHub
                  InheritedProvider.update<T>(rootContext, (object) {
                    return object?.incremented() as T;
                  }, or: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("counter updating failed"), duration: const Duration(seconds: 1)),
                    );
                  });
              },
              child: const Icon(Icons.add),
            ),

            TextButton(
              onPressed: Navigator.of(rootContext).pop,
              child: Text("Close"),
            ),
          ],
        );
      },
    );
  }
