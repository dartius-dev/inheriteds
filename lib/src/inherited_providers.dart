
part of 'inherited_object.dart';

class InheritedProviders extends StatelessWidget {
  final List<InheritedObjectProvider> entries;
  final Widget child;
  const InheritedProviders(this.entries,{super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return entries.reversed.skip(1).fold(
      entries.last.copyWithChild(child),
      (previous, current) => current.copyWithChild(previous)
    ); // Chain the providers and return the final widget
  }
}