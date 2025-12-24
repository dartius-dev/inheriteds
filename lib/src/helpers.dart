import 'package:flutter/widgets.dart';

extension WidgetChainExt on Widget {

  // Chains the entries and returns the final widget
  Widget chain<T>(List<T> entries, Widget Function(T, Widget) bind) {
    return entries.isEmpty ? this : entries.reversed.skip(1).fold(
      bind(entries.last, this),
      (previous, current) => bind(current, previous)
    ); 

  }
}