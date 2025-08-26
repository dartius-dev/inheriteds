
part of 'inherited_object.dart';

///
///
///
abstract class InheritedObjectProvider<T> extends StatefulWidget {

  T get initialObject;
  
  bool get hubEntry => false;
  
  final Widget? child;

  const InheritedObjectProvider({super.key, this.child});

  InheritedProvider<T> copyWithChild(Widget child);

  static P? maybeOf<T, P extends InheritedObjectProviderState<T>>(BuildContext context) {
    if (
      context.getElementForInheritedWidgetOfExactType<InheritedObject<T>>()?.widget 
      case InheritedObject<T> w
    ) {
      return w.provider is P ? w.provider as P : null;
    }

    final hub = InheritedHub._find(context);
    return switch(hub?.entries[T]?.provider) { P state => state,  _ => null };
  }
}


///
///
///
abstract class InheritedObjectProviderState<T> extends State<InheritedObjectProvider<T>> {

  late final InheritedHubState? _hub;
  late final ValueNotifier<T?> _objectNotifier = ValueNotifier<T?>(widget.initialObject);
  late T _object = widget.initialObject;

  Type get _type => T;

  Widget get child => widget.child!;

  bool get hasObject => _object != null;
  
  T? get maybeObject => _object;

  ChangeNotifier get notifier => _objectNotifier;

  @override
  void initState() {
    assert(widget.child != null, "${widget}(${widget.initialObject}) must have a child widget");

    super.initState();
    _hub = widget.hubEntry ? InheritedHub._find(context)?.hub : null;
    _hub?._register(this);
  }

  @override
  void activate() {
    _hub = widget.hubEntry ? InheritedHub._find(context)?.hub : null;
    _hub?._register(this);
    super.activate();
  }

  @override
  void deactivate() {
    _hub?._unregister(this);
    super.deactivate();
  }

  @override
  void didUpdateWidget(InheritedObjectProvider<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialObject != widget.initialObject) {
      setObject(widget.initialObject, forceBuild: false);
    }
    if (oldWidget.hubEntry != widget.hubEntry) {
      if (widget.hubEntry) {
        _hub ??= InheritedHub._find(context)?.hub;
        _hub?._register(this);
      } else {
        _hub?._unregister(this);
      }
    }
  }

  @protected
  void setObject(T object, {bool forceBuild = true}) {
    if (_object == object) return;
    _object = object;
    _hub?._onChanged(this);
    if (forceBuild) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Timer.run(() => _objectNotifier.value = _object);

    // Widget child = _child ??= _buildDependencies(widget.child!);

    return InheritedObject<T>(
      object: _object,
      provider: this,
      child: child,
    );
  }

}