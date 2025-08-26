import 'package:flutter/material.dart';
import 'package:inheriteds/inheriteds.dart';

import 'common/counter.dart';
import 'common/counter_popup.dart';


///
/// An Object that holds a counter value.
///
class ProviderCounter extends Counter {

  const ProviderCounter(super.value);

  @override
  ProviderCounter incremented() => ProviderCounter(value + 1);
}


class InheritedProviderCounterScreen extends StatelessWidget {
  const InheritedProviderCounterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return InheritedProvider<ProviderCounter>(
      initialObject: const ProviderCounter(0),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Using InheritedProvider', style: Theme.of(context).textTheme.displaySmall),
          Text('InheritedProvider( hubEntry: false )', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 30),

          OutlinedButton(
            onPressed: () => counterPopup<ProviderCounter>(context),
            child: Text("Popup")
          ),
          const SizedBox(height: 30),

          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("ProviderCounter.value: ", style: Theme.of(context).textTheme.titleLarge),

              // Using Builder to declare a subtree that depends on the InheritedObject<ProviderCounter>.
              // This allows us to rebuild only specific part of the widget tree when the counter value changes.
              Builder(builder: (context) {

                // Access the current value of the nearest InheritedObject<ProviderCounter>, which is provided by the InheritedProvider<ProviderCounter>.
                // This will return the current value of the counter.
                // The Builder will rebuild whenever the counter value changes.
                // We should not use InheritedProvider.of<ProviderCounter>(context) here, as it will not listen for changes.
                final counter = InheritedObject.of<ProviderCounter>(context).value;
      
                return Text(
                  '$counter',
                  style: Theme.of(context).textTheme.headlineMedium,
                );
              }),
              const SizedBox(width: 20),

              Builder(builder: (context) => OutlinedButton(onPressed: () {
                  
                    // Update the counter value by accessing the InheritedProvider<ProviderCounter> and calling update() with the new value.
                    // This will trigger a rebuild of the InheritedObject<ProviderCounter> and all widgets that depend on it.
                    InheritedProvider.update<ProviderCounter>(context, (object) {
                      // The update function receives the current object and should return the new object.
                      // Here we increment the counter value by calling incremented() on the current object.
                      return object.incremented();
                    });
                  
                  }, child: const Icon(Icons.add))
              )
            ],
          )
        ],
      )
    );
  }
}
