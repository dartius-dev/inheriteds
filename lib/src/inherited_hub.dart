
part of 'inherited_object.dart';

/// Place [InheritedHub] at the root of your widget tree to collect [InheritedProvider]s with `hubEntry: true`.
/// This allows you to access provided objects anywhere below the [InheritedHub] without worrying about the current [BuildContext] 
/// or the location of [InheritedProvider]s.
/// 
/// [InheritedProvider]s  with `hubEntry: true` register their objects in the hub, so you don't need to ensure they are in 
/// the same subtree as your widget.
///
/// Use `InheritedObject.of<T>(context)` anywhere below the [InheritedHub] to retrieve an object of type `T`.
///
///
///
///
///
class InheritedHub extends StatefulWidget {
  final Widget child;
  const InheritedHub({super.key, required this.child});

  static _HubScope? _find(BuildContext context) {
    return (context.getElementForInheritedWidgetOfExactType<InheritedObject<_HubScope>>()?.widget as InheritedObject<_HubScope>?)?.object;
  }
  static _HubScope? _maybeOf(BuildContext context, [HubObjectAspect? aspect]) {
    return context.dependOnInheritedWidgetOfExactType<InheritedObject<_HubScope>>(aspect: aspect)?.object;
  }

  @override
  State<InheritedHub> createState() => InheritedHubState();
}

class InheritedHubState extends State<InheritedHub> {
  final List<InheritedObjectProviderState> _providers = [];
  late final InheritedHubState? _hub;

  _HubScope? _hubEntries;

  @override
  void initState() {
    super.initState();
    _hub = InheritedHub._find(context)?.hub;
  }

  void _register(InheritedObjectProviderState provider) {
    if (_providers.contains(provider)) return;
    assert(_providers.every((p) => p._type != provider._type), 
      'Provider of type ${provider._type} is already registered in the hub.');
    _hub?._register(provider);
    _providers.add(provider);
    _refresh();
  }

  void _unregister(InheritedObjectProviderState provider) {
    assert(_providers.contains(provider));
    _hub?._unregister(provider);
    _providers.remove(provider);
    _refresh();
  }

  void _onChanged(InheritedObjectProviderState provider) {
    assert(_providers.contains(provider));
    _hub?._onChanged(provider);
    _refresh();
  }

  void _refresh({bool forceBuild = true}) {
    _hubEntries = null; // Reset the hub entries to force rebuild
    if (forceBuild) Timer.run(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return InheritedObject<_HubScope>(
      object: _hubEntries ??= _HubScope(this),
      child: widget.child
    );
  }
}

///
///
///
class _HubScope with EqualoneMixin {
  final InheritedHubState hub;
  final Map<Type, _HubEntry> entries;
  
  T? get<T extends Object>() => entries[T]?.object as T?;

  _HubScope(this.hub) : entries = {
    for (final provider in hub._providers)
      provider._type: _HubEntry(provider, provider._object)
  };

  @override
  List<Object?> get equalones => entries.values.map((e) => e.object).toList();
}

class _HubEntry {
  final InheritedObjectProviderState provider;
  final Object? object;

  _HubEntry(this.provider, this.object);

  Type get type => provider._type;

}

///
///
///
class HubObjectAspect<T extends Object> with AObjectAspect<_HubScope> {
  
  @override
  Object? get id => objectAspect;

  Object? call(_HubScope? object) {
    final obj = object?.entries[T]?.object as T?;
    return objectAspect==null ? obj : objectAspect!(obj);
  }

  final AObjectAspect<T>? objectAspect;
  const HubObjectAspect([this.objectAspect]) : super();
}

///
///
///
class HubObjectValueAspect<V,T extends Object> with AObjectAspect<T>, ObjectAspectMixin<T>, AObjectValueAspect<V,T> {
  @override 
  final Object? id;

  @override
  ObjectWatchCallback<T> get watch => _watch ?? valueOf;
  
  @override
  V? valueOf(T? object) => _value(object); 

  const HubObjectValueAspect(this._value, {this.id, ObjectWatchCallback<T>? watch}) : _watch = watch;

  final ValueWatchCallback<V,T> _value;
  final ObjectWatchCallback<T>? _watch;
}