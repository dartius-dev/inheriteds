
part of 'inherited_object.dart';

class InheritedProviders extends StatelessWidget {
  final List<InheritedProvider> providers;
  final Widget child;
  const InheritedProviders({super.key, required this.providers, required this.child});

  @override
  Widget build(BuildContext context) {
    return providers.reversed.skip(1).fold(
      providers.last.copyWithChild(child),
      (previous, current) => current.copyWithChild(previous)
    ); // Chain the providers and return the final widget
  }
}