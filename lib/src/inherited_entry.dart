part of 'inherited_object.dart';
  

///
///
///
class InheritedEntries extends StatelessWidget {
  final List<InheritedEntry> entries;
  final Widget child;
  const InheritedEntries(this.entries, {super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return child.chain(entries, (io, child) => io.copyWithChild(child));
  }
}


mixin InheritedEntry on Widget {
  InheritedEntry copyWithChild(Widget child);
}   