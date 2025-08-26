import 'package:flutter/material.dart';

class SetStateCounterScreen extends StatefulWidget {
  const SetStateCounterScreen({super.key});

  @override
  State<SetStateCounterScreen> createState() => _SetStateCounterScreenState();
}

class _SetStateCounterScreenState extends State<SetStateCounterScreen> {
  int counter = 0;

  void _incrementCounter() {
    setState(() {
      counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Using setState', style: Theme.of(context).textTheme.displaySmall),
        const SizedBox(height: 30),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("counter: ", style: Theme.of(context).textTheme.titleLarge),
            Text(
              '$counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(width: 20),
            OutlinedButton(onPressed: _incrementCounter, child: const Icon(Icons.add))
          ],
        )
      ],
    );
  }
}
