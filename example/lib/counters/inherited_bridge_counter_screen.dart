import 'package:flutter/material.dart';
import 'package:inheriteds/inheriteds.dart';

import 'common/counter.dart';
import 'common/counter_popup.dart';

///
/// An Object that holds a counter value.
///
class BridgeCounter extends Counter {

  const BridgeCounter(super.value);

  @override
  BridgeCounter incremented() => BridgeCounter(value + 1);
}

class InheritedBridgeCounterScreen extends StatelessWidget {
  const InheritedBridgeCounterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return InheritedProvider<BridgeCounter>(
      initialObject: const BridgeCounter(0),
      child: Builder( 
        // to provide context with InheritedProvider<BridgeCounter>
        builder: (context) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Using InheritedBridge', style: Theme.of(context).textTheme.displaySmall),
              const SizedBox(height: 30),
          
              OutlinedButton(
                onPressed: () => Navigator.push(context, PageRouteBuilder(
                  opaque: false,
                  pageBuilder: (pageContext, _, __) => InheritedBridge<BridgeCounter>(
                    fromContext: context,
                    child: Padding(padding: const EdgeInsets.only(top: 100), child: CounterPopup<BridgeCounter>()),
                  ),
                )),
                child: Text("Popup")
              ),
              const SizedBox(height: 30),
          
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("InheritedBridge: ", style: Theme.of(context).textTheme.titleLarge),
                  Builder(builder: (context) {
          
                    // Access the current value of the nearest InheritedObject<BridgeCounter>, which is provided by the InheritedProvider<BridgeCounter>.
                    // This will return the current value of the counter.
                    // The Builder will rebuild whenever the counter value changes.
                    // We should not use InheritedProvider.of<BridgeCounter>(context) here, as it will not listen for changes.
                    final counter = InheritedObject.of<BridgeCounter>(context).value;
                    return Text(
                      '$counter',
                      style: Theme.of(context).textTheme.headlineMedium,
                    );
                  }),
                  const SizedBox(width: 20),
                  OutlinedButton(onPressed: () {
          
                    // Update the counter value by accessing the InheritedProvider<BridgeCounter> and calling update() with the new value.
                    // This will trigger a rebuild of the InheritedObject<BridgeCounter> and all widgets that depend on it.
                    return InheritedProvider.update<BridgeCounter>(context, (object) {
                      // The update function receives the current object and should return the new object.
                      // Here we increment the counter value by calling incremented() on the current object.
                      return object.incremented();
                    });
                  }, child: const Icon(Icons.add))
                ],
              ),
            ],
          );
        }
      ),
    );
  }

}
