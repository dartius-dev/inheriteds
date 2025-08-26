import 'package:flutter/material.dart';
import 'package:inheriteds/inheriteds.dart';
import '/home_page.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});
  
  @override
  Widget build(BuildContext context) {
    return InheritedHub(
      child: MaterialApp(
        title: 'Inheriteds Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home: const HomePage(title: 'Inheriteds - Demo'),
      ),
    );
  }
}

