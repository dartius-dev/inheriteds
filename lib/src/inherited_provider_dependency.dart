part of 'inherited_object.dart';

///
///
///
mixin DependenciesMixin<T> {
  List<ProviderDependency<T, dynamic>>? get dependencies;
}

///
///
///
mixin InheritedProviderDependentStateMixin<T> on InheritedObjectProviderState<T> {
  Widget? _child;

  List<ProviderDependency<T, dynamic>>? get dependencies;

  @override
  void didUpdateWidget(InheritedObjectProvider<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.child!=oldWidget.child || 
        ( widget is DependenciesMixin<T> && 
            !Equalone.shallowEquals(
              (widget as DependenciesMixin<T>).dependencies, 
              (oldWidget as DependenciesMixin<T>).dependencies)
        )
    ) {
      _child = null;
    }
  }

  @override
  Widget get child => _child ??= buildChild(widget.child!);

  Widget buildChild(Widget child) {
    if (dependencies?.isNotEmpty ?? false) {
      return child.chain(dependencies!, (dep, child) => dep.copyWithChild(child, this));
      // child = dependencies!.reversed.skip(1).fold(
      //   dependencies!.last.copyWithChild(child, this),
      //   (previous, current) => current.copyWithChild(previous, this)
      // ); 
    }
    return child;
  }
}

///
///
///
final class ProviderDependency<TO, TD> extends DependencyWidget<TD> with EqualoneMixin {

  final TO Function(TO, TD) update;

  const ProviderDependency({
    super.listenable,
    super.listenableList,
    required super.dependency,
    required this.update,
  }) : _provider = null;

  @override
  List<Object?> get equalones => [listenable, Equalone.shallow(listenableList), dependency, child, key];

  @protected
  ProviderDependency<TO, TD> copyWithChild(Widget child, InheritedProviderDependentStateMixin<TO> provider) {
    return ProviderDependency<TO, TD>.constructor(
      listenable: listenable,
      listenableList: listenableList,
      dependency: dependency,
      update: update,
      provider: provider,
      child: child,
    );
  }

  const ProviderDependency.constructor({
    super.listenable,
    super.listenableList,
    required super.dependency,
    required this.update,
    required InheritedProviderDependentStateMixin<TO> provider,
    required super.child,
  }) : _provider = provider;

  final InheritedProviderDependentStateMixin<TO>? _provider;

  @override
  State<StatefulWidget> createState() => _ProviderDependencyState<TO, TD>();

}

class _ProviderDependencyState<TO, TD> extends DependencyState<TD, ProviderDependency<TO, TD>> {

  @override
  void updateDependency(TD value) {
    super.updateDependency(value);
    Timer.run(()=>widget._provider!.setObject(widget.update(widget._provider!.object, value)));
  }

  @override
  Widget buildContent(BuildContext context) {
    return widget.child!;
  }
}

