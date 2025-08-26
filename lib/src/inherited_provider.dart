
part of 'inherited_object.dart';

///
/// 
///
class InheritedProvider<T> extends InheritedObjectProvider<T> with DependenciesMixin<T> {
  @override
  final T initialObject;
  @override
  final bool hubEntry;
  @override
  final List<ProviderDependency<T, dynamic>>? dependencies;

  final FutureOr<void> Function(T? newObject, T? oldObject)? onUpdate;
  
  const InheritedProvider({
    super.key, required this.initialObject, this.hubEntry = false, this.dependencies, this.onUpdate, super.child
  });

  static InheritedProviderState<T>? maybeOf<T>(BuildContext context) {
    return InheritedObjectProvider.maybeOf<T, InheritedProviderState<T>>(context);
  }

  static InheritedProviderState<T> of<T>(BuildContext context) 
    => maybeOf<T>(context)!;

  static void update<T>(BuildContext context, T Function(T object) update, {void Function()? or}) {
    if (maybeOf<T>(context) case final provider when provider != null) {
      provider.update(update(provider._object));
    } else {
      or?.call();
    }
  }

  // static InheritedObjectProviderState<T>? _maybeOf<T extends Object>(BuildContext context) {
  //   if (
  //     context.getElementForInheritedWidgetOfExactType<InheritedObject<T>>()?.widget 
  //     case InheritedObject<T> w
  //   ) {
  //     return w.provider is InheritedObjectProviderState<T> ? w.provider : null;
  //   }

  //   final hub = InheritedHub._find(context);
  //   return switch(hub?.entries[T]?.provider) {
  //     InheritedObjectProviderState<T> state => state, 
  //     _ => null
  //   };
  // }

  @override
  InheritedProvider<T> copyWithChild(Widget child) {
    return InheritedProvider<T>(
      key: key,
      initialObject: initialObject,
      hubEntry: hubEntry,
      dependencies: dependencies,
      child: child,
    );
  }

  @override
  InheritedObjectProviderState<T> createState() => InheritedProviderState<T>();
}

///
///
///
class InheritedProviderState<T> 
  extends InheritedObjectProviderState<T>
  with InheritedProviderDependentStateMixin<T>
{
  InheritedProvider<T> get widget => super.widget as InheritedProvider<T>;

  @override
  List<ProviderDependency<T, dynamic>>? get dependencies => widget.dependencies;

  void update(T object) {
    if (maybeObject == object) return;
    setObject(object, forceBuild: true);
  }
  
  @override
  @protected
  Future<void> setObject(T object, {bool forceBuild = true}) async {
    if (maybeObject == object) return;

    final oldObject = maybeObject;
    super.setObject(object, forceBuild: forceBuild);

    if (widget.onUpdate == null) return;
    if (widget.onUpdate!(object, oldObject) case Future future) {
      await future;
    }
  }
  
}

