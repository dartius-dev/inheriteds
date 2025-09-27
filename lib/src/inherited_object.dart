import 'dart:async';
import 'dart:collection';

import 'package:dependents/dependents.dart';
import 'package:equalone/equalone.dart';
import 'package:flutter/widgets.dart';

part 'inherited_object_provider.dart';
part 'inherited_provider.dart';
part 'inherited_provider_dependency.dart';
part 'inherited_providers.dart';
part 'inherited_hub.dart';


typedef ContextBasedValue<T> = T Function(BuildContext context);
typedef ObjectWatchCallback<T extends Object> = Object? Function(T? widget);
typedef ValueWatchCallback<V, T extends Object> = V? Function(T? widget);


/// Simplifies the use of [InheritedWidget].
/// 
/// It allows you to create a widget that can be used to provide any object to its descendants, 
/// and also allows you to watch for specific changes in the object.
/// 
/// [InheritedObject] improves upon [InheritedWidget] by providing a more flexible and type-safe way to 
/// share objects down the widget tree.
/// 
/// Advantages:
/// - No need to create separate classes extending InheritedWidget or InheritedModel.
/// - No need to develop or manage special aspects for InheritedModel.
/// - Allows watching for specific changes in the provided object using customizable aspects and callbacks.
/// - Reduces unnecessary rebuilds by enabling more granular dependency tracking.
/// - Improves performance, especially with complex or frequently changing objects.
/// - Simplifies state management by making dependencies explicit and type-safe.
/// 
/// The object should be immutable and implement value equality to ensure proper equality checks.
/// You may use [EqualoneMixin] from [equalone](https://pub.dev/packages/equalone) package or other solutions for this purpose.
/// 
/// Should not be used directly, use [InheritedProvider] instead.
///
class InheritedObject<T> extends InheritedWidget {

  final T object;
  final InheritedObjectProviderState<T>? provider;

  const InheritedObject({
    super.key,
    required this.object,
    this.provider,
    required super.child,
  });

  static T get<T extends Object>(BuildContext context) => find<T>(context)!;

  static T? find<T extends Object>(BuildContext context) {
   if (context.getElementForInheritedWidgetOfExactType<InheritedObject<T>>()?.widget case InheritedObject<T> w) {
      return w.object;
    }
    return InheritedHub._find(context)?.entries[T]?.object as T?;
  }

  static T? maybeOf<T extends Object>(BuildContext context, {ObjectWatchCallback<T>? watch, Object? watchId}) {
    ObjectAspect<T>? aspect = watch != null ? ObjectAspect<T>(watch: watch, id: watchId) : null;
    return _maybeOf<T>(context, aspect);
  }

  static V? maybeValueOf<V,T extends Object>(BuildContext context, {
    required ValueWatchCallback<V,T> value, ObjectWatchCallback<T>? watch, Object? watchId
  }) {
    final aspect = ObjectValueAspect<V,T>(value, watch: watch ?? value, id: watchId);
    return aspect.valueOf(_maybeOf<T>(context, aspect));
  }

  static T  of<T extends Object>(BuildContext context, {ObjectWatchCallback<T>? watch, Object? watchId}) 
    => maybeOf<T>(context, watch: watch, watchId: watchId)!;

  static V valueOf<V,T extends Object>(BuildContext context, {
    required ValueWatchCallback<V,T> value, ObjectWatchCallback<T>? watch, Object? watchId
  }) => maybeValueOf<V,T>(context, value: value, watch: watch, watchId: watchId)!;

  static T? _maybeOf<T extends Object>(BuildContext context, [AObjectAspect<T>? aspect]) {
    if (
      context.dependOnInheritedWidgetOfExactType<InheritedObject<T>>(aspect: aspect) 
      case final io when io!=null
    ) {
      return io.object;
    }

    return InheritedHub._maybeOf(context, HubObjectAspect<T>(aspect))?.entries[T]?.object as T?;
  }


  @override
  bool updateShouldNotify(InheritedObject<T> oldWidget) => shouldNotify(oldWidget);

  bool shouldNotify(InheritedObject<T> oldWidget, [AObjectAspect? aspect]) {
    return aspect!=null 
      ? !Equalone.deepEquals(aspect(object), aspect(oldWidget.object))
      : object!=oldWidget.object;
  }

  @override
  InheritedObjectElement<T> createElement() => InheritedObjectElement<T>(this);  
}

///
///
///
class InheritedObjectElement<T> extends InheritedElement {

  InheritedObjectElement(InheritedObject<T> super.widget);
  

  @override
  InheritedObject<T> get widget => super.widget as InheritedObject<T>;

  @override
  void updateDependencies(Element dependent, covariant AObjectAspect? aspect) {
    final dependencies = getDependencies(dependent) as Set<AObjectAspect>?;
    if (dependencies?.isEmpty==true) {
      return;
    }

    if (aspect == null) {
      setDependencies(dependent, const <AObjectAspect>{});
    } else {
      assert((){
        if (_newFrame) {
          _frameCount++;
          _newFrame = false;
          WidgetsBinding.instance.addPostFrameCallback((_) => _newFrame = true);
        }
        final prev = dependencies?.skipWhile((e)=>e!=aspect).firstOrNull as _DebugObjectAspect?;
        if(prev==aspect && prev!.frame==_frameCount) {
          throw ObjectAspectError(
            '${aspect.runtimeType}${switch(aspect){ final ObjectAspectMixin e => '(id=${e.id})', _=>''}} is already registered in the same frame. '
          );
        }
        aspect = _DebugObjectAspect(aspect!, _frameCount);
        return true;
      }());

      // add a last specified aspect to dependencies
      setDependencies(dependent, (dependencies ?? <AObjectAspect>{})..remove(aspect)..add(aspect!));
    }
  }

  @override
  void notifyDependent(covariant InheritedObject<T> oldWidget, Element dependent) {
    final dependencies = getDependencies(dependent) as Set<AObjectAspect>?;
    if (dependencies == null) {
      return;
    }
    if (dependencies.isEmpty || dependencies.any((aspect)=>widget.shouldNotify(oldWidget, aspect))){
      dependent.didChangeDependencies();
    }
  }
  static int  _frameCount = 0; 
  static bool _newFrame   = true; 
}

@immutable
class _DebugObjectAspect<T extends Object> with AObjectAspect<T> {
  final AObjectAspect<T> aspect;
  final int frame;
  const _DebugObjectAspect(this.aspect, this.frame);

  Object? get id => aspect.id;

  @override
  Object? call(T? object) {
    return aspect(object);
  }

  @override
  bool operator ==(Object other) {
    if (other is _DebugObjectAspect) other = other.aspect;
    return aspect == other;
  }
  
  @override
  int get hashCode => aspect.hashCode;

}

///
///
///
abstract mixin class AObjectAspect<T extends Object> {
  /// [id] should be a value comparable with [operator==].
  /// Set [id] when using some dependencies in one build context.
  Object? get id;

  Object? call(T? object);

  @override
  bool operator ==(Object other) => other is AObjectAspect<T> && runtimeType==other.runtimeType && id==other.id;
  
  @override
  int get hashCode => Object.hash(runtimeType, id);
}

mixin AObjectValueAspect<V,T extends Object> on AObjectAspect<T> {
  V? valueOf(T? object); 
}

///
///
///
class ObjectAspect<T extends Object> with AObjectAspect<T>, ObjectAspectMixin<T> {

  /// set [id] if you want to use some dependencies in one build context 
  @override final Object? id;

  /// [watch] is a callback to watch the object value
  @override final ObjectWatchCallback<T>?  watch;

  const ObjectAspect({this.id, this.watch});
}

///
///
///
class ObjectValueAspect<V,T extends Object> with AObjectAspect<T>, ObjectAspectMixin<T>, AObjectValueAspect<V,T> {
  @override 
  final Object? id;

  @override
  ObjectWatchCallback<T> get watch => _watch ?? valueOf;
  
  @override
  V? valueOf(T? object) => _value(object); 

  const ObjectValueAspect(this._value, {this.id, ObjectWatchCallback<T>? watch}) : _watch = watch;

  final ValueWatchCallback<V,T> _value;
  final ObjectWatchCallback<T>? _watch;
}

///
///
///
mixin ObjectAspectMixin<T extends Object> on AObjectAspect<T> {
  ObjectWatchCallback<T>? get watch;

  @override
  Object? call(T? object) => watch?.call(object);
}

///
///
///
class ObjectAspectError extends Error {
  final String message;
  ObjectAspectError(this.message);

  @override
  String toString() {
    return "ObjectAspectError: $message";
  }  
}