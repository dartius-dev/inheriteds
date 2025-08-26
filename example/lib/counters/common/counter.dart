import 'package:equalone/equalone.dart';

abstract class Counter with EqualoneMixin{
  final int value;

  const Counter(this.value);

  Counter incremented();

  @override
  List<Object?> get equalones => [value];
}
