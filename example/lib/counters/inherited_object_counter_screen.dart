import 'package:flutter/material.dart';
import 'package:inheriteds/inheriteds.dart';

import 'common/counter.dart';

/// An object that holds a counter value.
class ObjectCounter extends Counter {
  const ObjectCounter(super.value);

  @override
  ObjectCounter incremented() => ObjectCounter(value + 1);
}

/// A screen demonstrating the use of InheritedObject for state management.
/// 
/// This widget implements the mechanics of an InheritedProvider using InheritedObject.
class InheritedObjectCounterScreen extends StatefulWidget {
  const InheritedObjectCounterScreen({super.key});

  @override
  State<InheritedObjectCounterScreen> createState() => InheritedObjectCounterScreenState();
}

class InheritedObjectCounterScreenState extends State<InheritedObjectCounterScreen> {
  ObjectCounter _counter = const ObjectCounter(0);

  void incrementCounter() {
    setState(() {
      _counter = _counter.incremented();
    });
  }

  @override
  Widget build(BuildContext context) {

    // Wrap CounterWidget with InheritedObject to provide the counter value
    // to the widget tree. This allows CounterWidget to access the counter value
    // using InheritedObject.of<ObjectCounter>(context).
    // CounterWidget will rebuild whenever the counter value changes.
    // This is similar to how InheritedProvider works, but uses InheritedObject directly.
    return InheritedObject(
      object: _counter,
      child: const CounterWidget(),
    );
  }
}

/// A widget that displays the counter value and provides a button to increment it.
class CounterWidget extends StatelessWidget {
  const CounterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Using InheritedObject', style: Theme.of(context).textTheme.displaySmall),
        const SizedBox(height: 30),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("ObjectCounter.value: ", style: Theme.of(context).textTheme.titleLarge),
            Builder(builder: (context) {

              // Access the current value of the nearest InheritedObject<ObjectCounter>.
              final counter = InheritedObject.of<ObjectCounter>(context);
              
              return Text(
                '${counter.value}',
                style: Theme.of(context).textTheme.headlineMedium,
              );
            }),
            const SizedBox(width: 20),
            OutlinedButton(
              onPressed: () {

                // Find the nearest ancestor state of type InheritedObjectCounterScreenState
                // and call its incrementCounter() method to update the counter.
                context.findAncestorStateOfType<InheritedObjectCounterScreenState>()!.incrementCounter();

              },
              child: const Icon(Icons.add),
            )
          ],
        )
      ],
    );
  }
}
