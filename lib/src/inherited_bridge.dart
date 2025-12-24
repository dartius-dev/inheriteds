part of 'inherited_object.dart';

/// Inherits object of type [T] from the [fromContext] and provides it to its [child].
/// 
/// Is used to bridge inherited objects between different branches of the widget tree.
/// 
/// Useful when pushing new routes or showing dialogs/modals where the context is different.
/// 
/// ```dart
/// Navigator.of(context).push(
///   MaterialPageRoute<void>( 
///     builder: (BuildContext context) =>  
///       InheritedBridge<YourType>(
///         fromContext: context
///         child: YourWidget(),
///       ), 
///   ),
/// );
/// ```
/// 
class InheritedBridge<T> extends StatelessWidget with InheritedEntry {
  final BuildContext fromContext;
  final Widget? child;
  const InheritedBridge({super.key, required this.fromContext, this.child});

  @override
  InheritedBridge<T> copyWithChild(Widget child) {
    return InheritedBridge<T>(
      key: key,
      fromContext: fromContext,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final io = fromContext.getElementForInheritedWidgetOfExactType<InheritedObject<T>>()!.widget as InheritedObject<T>;
    return ListenableBuilder(
      listenable: io.provider!.notifier, 
      builder: (_, __) => InheritedObject<T>(
        object: io.provider!.object,
        provider: io.provider,
        child: child!,
      ),
    );
  }
}

