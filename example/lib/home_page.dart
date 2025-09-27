import 'package:equalone/equalone.dart';
import 'package:flutter/material.dart';
import 'package:inheriteds/inheriteds.dart';
import 'package:url_launcher/url_launcher.dart';
import 'counters/inherited_object_counter_screen.dart';
import 'counters/inherited_provider_counter_screen.dart';
import 'counters/set_state_counter_screen.dart';

import 'counters/inherited_hub_counter_screen.dart';
import 'shop/shop_screen.dart';

///
///
///
class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  static const pubDevProject = "https://pub.dev/packages/inheriteds";
  static const githubProject = "https://github.com/dartius-dev/inheriteds/";
  static const githubExample = "${githubProject}blob/main/example/lib/";

  static const screens = [
     ScreenItem(
      title: 'SetState',
      icon: Icon(Icons.looks_one),
      widget: SetStateCounterScreen(),
      url: "${githubExample}counters/set_state_counter_screen.dart"
    ),
    ScreenItem(
      title: 'InheritedObject',
      icon: Icon(Icons.looks_two),
      widget: InheritedObjectCounterScreen(),
      url: "${githubExample}counters/inherited_object_counter_screen.dart"
    ),
    ScreenItem(
      title: 'InheritedProvider',
      icon: Icon(Icons.looks_3),
      widget: InheritedProviderCounterScreen(),
      url: "${githubExample}counters/inherited_provider_counter_screen.dart"
    ),
    ScreenItem(
      title: 'InheritedHub',
      icon: Icon(Icons.looks_4),
      widget: InheritedHubCounterScreen(),
      url: "${githubExample}counters/inherited_hub_counter_screen.dart"
    ),
    ScreenItem(
      title: 'Shop',
      icon: Icon(Icons.shopping_bag_rounded),
      widget: ShopScreen(),
      url: "${githubExample}shop/shop_screen.dart"
    ),
  ];   

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        leadingWidth: 130,
        leading: TextButton(
          onPressed: () => launchUrl(Uri.parse(pubDevProject)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            Text('inheriteds', style: const TextStyle(fontWeight: FontWeight.bold)),
            const Text('on pub.dev'),
          ])),
        actions: [TextButton(
          onPressed: () => launchUrl(Uri.parse(githubProject)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            Text('inheriteds', style: const TextStyle(fontWeight: FontWeight.bold)),
            const Text('on github.com'),
          ]))],
        ),

      body: ScreenView(screen: screens[_selectedIndex]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        items: screens
            .map((screen) => BottomNavigationBarItem(
                  icon: screen.icon,
                  label: screen.title,
                ))
            .toList(),
      ),
      floatingActionButton: screens[_selectedIndex].widget is! InheritedHubCounterScreen
          ? null
          : FloatingActionButton(
              onPressed: () {
                InheritedProvider.update<HubCounter>(context, (object) {
                  return object.incremented();
                });
              },
              tooltip: 'Hub usage',
              child: Builder(builder: (context) {
                final value = InheritedObject.maybeOf<HubCounter>(context)?.value ?? 0;
                return Text('Hub:\n$value + 1');
              }),
            ),
    );
  }
}

///
///
///
class ScreenItem with EqualoneMixin {

  final String title;
  final Widget icon;
  final Widget widget;
  final String? url;

  const ScreenItem({required this.title, required this.icon, this.url, required this.widget});

  @override
  List<Object?> get equalones => [title, icon, url, widget];
}

///
///
///
class ScreenView extends StatelessWidget {
  final ScreenItem screen;
  const ScreenView({super.key, required this.screen});

  @override
  Widget build(BuildContext context) {
    final child = Center(child: screen.widget);
    return screen.url ==null ? child : Column(
      children: [
        Expanded(
          child: child,
        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: TextButton(
              onPressed: () => launchUrl(Uri.parse(screen.url!)),
              child: Text('see source code', style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ),

      ],
    );
  }
}