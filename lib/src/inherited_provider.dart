part of 'inherited_object.dart';


///
///
///
class InheritedProvider<T> extends InheritedDataProvider<T> {
    final FutureOr<void> Function(T newObject, T oldObject)? onUpdate;

    const InheritedProvider({
      super.key, required super.initialObject, super.hubEntry = false, super.dependencies, this.onUpdate, super.child
    });


  static InheritedProviderState<T>? maybeOf<T>(BuildContext context) {
    return InheritedObjectProvider.maybeOf<T, InheritedProviderState<T>>(context);
  }

  static InheritedProviderState<T> of<T>(BuildContext context) 
    => maybeOf<T>(context)!;

  static void update<T>(BuildContext context, T Function(T object) update, {void Function()? or}) {
    if (maybeOf<T>(context) case final InheritedProviderState<T> provider) {
      provider.update(update(provider._object));
    } else {
      if (or == null) throw FlutterError("No $InheritedProvider<$T> found in context");
      or.call();
    }
  }

  @override
  InheritedProvider<T> copyWithChild(Widget child) {
    return InheritedProvider<T>(
      key: key,
      initialObject: initialObject,
      hubEntry: hubEntry,
      dependencies: dependencies,
      onUpdate: onUpdate,
      child: child,
    );
  }

  @override
  InheritedObjectProviderState<T> createState() => InheritedProviderState<T>();

}

///
class InheritedProviderState<T> extends InheritedDataProviderState<T>
{
  InheritedProvider<T> get widget => super.widget as InheritedProvider<T>;

  @override
  @protected
  void notify(T object) {
    if (widget.onUpdate != null && _objectNotifier.value != object) {
      widget.onUpdate!(object, _objectNotifier.value);
    }
    super.notify(object);
  }

  void update(T object) {
    if (_object == object) return;
    setObject(object, forceBuild: true);
  }
}

///
/// 
///
class InheritedDataProvider<T> extends InheritedObjectProvider<T> with DependenciesMixin<T> 
{
  @override
  final T initialObject;
  @override
  final bool hubEntry;
  @override
  final List<ProviderDependency<T, dynamic>>? dependencies;

  const InheritedDataProvider({
    super.key, required this.initialObject, this.hubEntry = false, this.dependencies, super.child
  });

  @override
  InheritedDataProvider<T> copyWithChild(Widget child) {
    return InheritedDataProvider<T>(
      key: key,
      initialObject: initialObject,
      hubEntry: hubEntry,
      dependencies: dependencies,
      child: child,
    );
  }

  @override
  InheritedObjectProviderState<T> createState() => InheritedDataProviderState<T>();
}

///
class InheritedDataProviderState<T> 
  extends InheritedObjectProviderState<T>
  with InheritedProviderDependentStateMixin<T>
{
  late final ValueNotifier<T> _objectNotifier = ValueNotifier<T>(widget.initialObject);

  @override
  ChangeNotifier get notifier => _objectNotifier;

  InheritedDataProvider<T> get widget => super.widget as InheritedDataProvider<T>;

  @override
  List<ProviderDependency<T, dynamic>>? get dependencies => widget.dependencies;

  @override
  void dispose() {
    _objectNotifier.dispose();
    super.dispose();
  }

  @override
  @protected
  void notify(T object) {
    _objectNotifier.value = object;
  }
}


///
///
///
class InheritedProviders extends StatelessWidget {
  final List<InheritedObjectProvider> entries;
  final Widget child;
  const InheritedProviders(this.entries,{super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return entries.isEmpty ? child : entries.reversed.skip(1).fold(
      _copyWithChild(entries.last, child),
      (previous, current) => _copyWithChild(current, previous)
    ); // Chain the providers and return the final widget
  }

  InheritedObjectProvider _copyWithChild(InheritedObjectProvider provider, Widget child) {
    final copy = provider.copyWithChild(child);
    assert(
      copy.runtimeType == provider.runtimeType,
      '${provider.runtimeType}.copyWithChild() must return an instance of the same type, but ${copy.runtimeType} was returned.'
    );
    return copy;
  }
}

