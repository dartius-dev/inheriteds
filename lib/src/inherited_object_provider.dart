
part of 'inherited_object.dart';


///
///
///
abstract class InheritedObjectProvider<T> extends StatefulWidget {

  T get initialObject;
  
  bool get hubEntry => false;
  
  final Widget? child;

  const InheritedObjectProvider({super.key, this.child});

  InheritedObjectProvider<T> copyWithChild(Widget child);

  static P? of<T, P extends InheritedObjectProviderState<T>>(BuildContext context) 
      => maybeOf<T, P>(context)!;
      
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
abstract class AInheritedObjectProvider<T> {

}


///
///
///
abstract class InheritedObjectProviderState<T> extends State<InheritedObjectProvider<T>> implements AInheritedObjectProvider<T> {

  late final InheritedHubState? _hub;
  late T _object = widget.initialObject;
  Type get _type => T;

  Widget get child => widget.child!;

  T get object => _object;

  ChangeNotifier get notifier;
  
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
    if (oldWidget.initialObject != widget.initialObject && _object != widget.initialObject) {
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
  bool setObject(T object, {bool forceBuild = true}) {
    if (_object == object) return false;
    _object = object;
    _hub?._onChanged(this);
    if (forceBuild) setState(() {});
    return true;
  }

  @protected
  void notify(T object);

  @override
  Widget build(BuildContext context) {
    Timer.run(() => notify(_object));

    return InheritedObject<T>(
      object: _object,
      provider: this,
      child: child,
    );
  }

}
