import 'package:flutter/material.dart';
import 'package:inheriteds/inheriteds.dart';

import 'common/counter.dart';
import 'common/counter_popup.dart';

///
/// An Object that holds a counter value.
///
class HubCounter extends Counter {

  const HubCounter(super.value);

  @override
  HubCounter incremented() => HubCounter(value + 1);
}

class InheritedHubCounterScreen extends StatelessWidget {
  const InheritedHubCounterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return InheritedProvider<HubCounter>(
      initialObject: const HubCounter(0),
      hubEntry: true,

      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Using InheritedProvider', style: Theme.of(context).textTheme.displaySmall),
          Text('InheritedProvider( hubEntry: true )', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 30),

          OutlinedButton(
            onPressed: () => counterPopup<HubCounter>(context),
            child: Text("Popup")
          ),
          const SizedBox(height: 30),

          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("InheritedHub: ", style: Theme.of(context).textTheme.titleLarge),
              Builder(builder: (context) {

                // Access the current value of the nearest InheritedObject<HubCounter>, which is provided by the InheritedProvider<HubCounter>.
                // This will return the current value of the counter.
                // The Builder will rebuild whenever the counter value changes.
                // We should not use InheritedProvider.of<HubCounter>(context) here, as it will not listen for changes.
                final counter = InheritedObject.of<HubCounter>(context).value;
                return Text(
                  '$counter',
                  style: Theme.of(context).textTheme.headlineMedium,
                );
              }),
              const SizedBox(width: 20),
              OutlinedButton(onPressed: () {

                // Update the counter value by accessing the InheritedProvider<HubCounter> and calling update() with the new value.
                // This will trigger a rebuild of the InheritedObject<HubCounter> and all widgets that depend on it.
                return InheritedProvider.update<HubCounter>(context, (object) {
                  // The update function receives the current object and should return the new object.
                  // Here we increment the counter value by calling incremented() on the current object.
                  return object.incremented();
                });
              }, child: const Icon(Icons.add))
            ],
          ),
        ],
      ),
    );
  }

}
