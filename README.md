# inheriteds
![pub version](https://img.shields.io/pub/v/inheriteds)
[![live demo](https://github.com/dartius-dev/inheriteds/raw/main/example/livedemo.svg)](https://dartius-dev.github.io/inheriteds/)
[![example](https://github.com/dartius-dev/inheriteds/raw/main//example/example.svg)](https://github.com/dartius-dev/inheriteds/blob/main/example/)


A robust Flutter state management solution focused on simplifying dependency injection and object propagation throughout widget trees.

`inheriteds` extends the capabilities of `InheritedWidget`, offering a unified API for managing immutable objects, dependencies, and state updates. It enables scalable, type-safe, and composable state management, making it suitable for both simple and complex Flutter applications. Key features include dependency chaining, centralized provider registration, minimal boilerplate, and seamless integration with existing widgets.

## Why use `inheriteds`?

Make any **immutable** object an **inherited** object and **control** it simply and conveniently!

Wrap your widget tree with an `InheritedProvider` and provide the initial value for the object:

```dart
InheritedProvider<User>(
  initialObject: const User(name: "Bob", age: 21),
  child: MyApp(),
)
```

To access the object anywhere below the wrapped widget tree, use `InheritedObject.of`:

```dart
final user = InheritedObject.of<User>(context);
```

This establishes a dependency and rebuilds the current widget whenever the object is updated.

To update the object, use `InheritedProvider.update`:

```dart
InheritedProvider.update<User>(context, (user) {
  return user.copyWith(age: user.age + 1);
});
```

<!-- **And that's NOT all! There's even more to discover...** -->

## Getting Started

Add to your `pubspec.yaml`:
```yaml
dependencies:
  inheriteds: 
```

Import in your Dart code:
```dart
import 'package:inheriteds/inheriteds.dart';
```
# Contents

- [inheriteds](#inheriteds)
  - [Why use `inheriteds`?](#why-use-inheriteds)
  - [Getting Started](#getting-started)
- [Contents](#contents)
  - [Overview](#overview)
    - [Motivation](#motivation)
    - [Features](#features)
    - [Advantages](#advantages)
    - [Problems Solved](#problems-solved)
  - [Usage](#usage)
    - [InheritedObject](#inheritedobject)
      - [Static Methods for Access](#static-methods-for-access)
      - [Static Methods for Safe Access](#static-methods-for-safe-access)
      - [Why is this better than aspect?](#why-is-this-better-than-aspect)
      - [`watchId` — what is it?](#watchid--what-is-it)
    - [InheritedObjects](#inheritedobjects)
    - [InheritedProvider](#inheritedprovider)
      - [Static Methods](#static-methods)
      - [Provider's `notifier`](#providers-notifier)
    - [InheritedProviders](#inheritedproviders)
    - [InheritedHub](#inheritedhub)
      - [When does this really matter?](#when-does-this-really-matter)
    - [ProviderDependency](#providerdependency)
    - [InheritedDataProvider](#inheriteddataprovider)
    - [InheritedObjectProvider](#inheritedobjectprovider)
  - [Additional information](#additional-information)
  - [License](#license)

## Overview

### Motivation

Managing state and dependencies in Flutter can become cumbersome as applications grow. Standard solutions like `InheritedWidget` and `Provider` often lack flexibility for advanced scenarios, such as:
- Chaining multiple dependencies
- Propagating objects across deeply nested widget trees
- Centralized state management with minimal boilerplate

`inheriteds` solves these problems by introducing:
- **InheritedObject**: A simple and convenient alternative to `InheritedModel` for any immutable object.
- **InheritedProvider**: A generic provider for any object type, supporting dependency chains and updates.
- **InheritedHub**: Centralized registry for providers, enabling global access and coordination.
- **ProviderDependency**: Declarative dependency injection and update logic.

### Features

- Type-safe state management for any object type
- Dependency chaining and composition
- Centralized hub for provider registration and lookup
- Minimal boilerplate, easy integration
- Works seamlessly with existing Flutter widgets
- Debug-friendly: easy to inspect and trace state changes

### Advantages

- **Scalable**: Handles complex dependency graphs with ease
- **Composable**: Chain and combine providers and dependencies declaratively
- **Centralized**: Use InheritedHub for global state coordination
- **Type-safe**: No runtime type errors when accessing objects
- **Minimalistic**: Reduces boilerplate compared to other solutions

### Problems Solved

- Tedious manual wiring of dependencies in large widget trees
- Lack of composability in standard state management approaches
- Difficulty in propagating and updating objects across multiple widgets
- Boilerplate-heavy patterns for dependency injection

## Usage

### InheritedObject

`InheritedObject` allows you to share any immutable object with descendant widgets and automatically rebuilds them when the object changes. It’s a lightweight alternative to `InheritedWidget` and `InheritedModel`, designed for minimal boilerplate and easy state propagation.

**Key features:**
- Share immutable objects with descendant widgets
- Automatic rebuilds when the object changes
- Simple and efficient state propagation

Just provide an immutable object, and `InheritedObject` takes care of notifying dependents when updates occur.

```dart

  return InheritedObject(
    object: const User(name: "Bob", age: 21),
    child: child,
  );
```

Access the object anywhere below:

```dart
  final user = InheritedObject.of<User>(context);
```

This approach works well for managing local state or in simple scenarios ([see example](https://github.com/dartius-dev/inheriteds/blob/main/example/lib/counters/inherited_object_counter_screen.dart)). However, as your app grows or requires more advanced state management, using `InheritedObject` directly can become verbose and repetitive. 

For most practical cases — especially when you want to reduce manual wiring and boilerplate—it's recommended to use `InheritedProvider`.

[InheritedProvider](#inheritedprovider) streamlines state sharing and updates throughout your widget tree, making your code cleaner and easier to maintain.

#### Static Methods for Access
`InheritedObject` offers static methods for accessing objects and values in your widget tree. These methods make it easy to retrieve shared state, and provide a powerful alternative to the `aspect` mechanism found in `InheritedModel`.

`InheritedObject` offers a set of static methods for efficient and flexible access to shared objects and their values within your widget tree:

- `InheritedObject.of<T>(context)`: Returns the nearest object of type `T` and establishes a dependency, causing the widget to rebuild when the object changes.
- `InheritedObject.valueOf<V, T>(context, value: (obj) => ...)`: Selects a specific field or computed value from the object of type `T`. The widget only rebuilds when the selected value changes, enabling fine-grained updates.
- `InheritedObject.get<T>(context)`: Retrieves the object of type `T` without establishing a dependency, so the widget will not rebuild when the object changes.

These methods allow you to choose between reactive (with rebuilds) and non-reactive (without rebuilds) access patterns, helping you optimize state management and UI performance.

#### Static Methods for Safe Access

`InheritedObject` provides several methods for safely accessing objects and values that may not be present in the widget tree. These methods return `null` if the requested object or value is not found, helping you avoid runtime errors:

- `InheritedObject.maybeOf<T>(context)`: Returns the nearest object of type `T` if available, or `null` if not found. Establishes a dependency if the object exists.
- `InheritedObject.maybeValueOf<V, T>(context, value: (obj) => ...)`: Safely selects a value from the object of type `T`, returning `null` if the object is not found.
- `InheritedObject.find<T>(context)`: Finds an object of type `T` for advanced lookups without establishing a dependency (no rebuilds). Returns `null` if not found.

These null-safe methods are useful when you want to handle missing dependencies gracefully or when objects may not always be available in the current context.


#### Why is this better than aspect?
With `InheritedModel`, you use `aspect` to control which parts of the model trigger rebuilds. Inheriteds makes this easier and more flexible: you can select any field or computed value, and your widget will only rebuild when that value changes. This leads to more efficient updates and cleaner code.

```dart
// Only rebuild when the user's name changes
final userName = InheritedObject.valueOf<String, User>(
  context, value: (user) => user.name
);

// Only rebuild when the total price changes
final totalPrice = InheritedObject.valueOf<int, ShopOrder>(
  context, value: (order) => order.totalPrice
);

// Only rebuild when the total price crossing the threshold of 100
final above = InheritedObject.valueOf<int, ShopOrder>(
  context, value: (order) => order.totalPrice > 100
);
```

This pattern helps you optimize performance and keep your UI responsive, especially in large apps with complex state graphs.

#### `watchId` — what is it?

Consider this example:

```dart
Widget build(context) {
  final name = InheritedObject.of<User>(context, watch: (u) => u!.name).name;
  final age = InheritedObject.of<User>(context, watch: (u) => u!.age).age;
  ...
}
```

This code will result in an error:

> ObjectAspectError: ObjectAspect<User>(id=null) is already registered in the same frame.

Why does this happen?

In this example, we are trying to create two dependencies with different `watch` conditions in the same `context`. `InheritedObject` cannot automatically distinguish between these `watch` functions, so this error occurs.

To avoid this error, you should help `InheritedObject` identify each `watch` by assigning a unique `watchId` for each dependency:

```dart
Widget build(context) {
  final name = InheritedObject.of<User>(context, watch: (u) => u!.name, watchId:'A').name;
  final age = InheritedObject.of<User>(context, watch: (u) => u!.age, watchId:'B').age;
  ...
}
```

There is no need to do this for different `BuildContext` instances:
```dart
Widget build(context) {
  final name = InheritedObject.of<User>(context, watch: (u) => u!.name).name;
  return Builder(builder: (context) {
    final age = InheritedObject.of<User>(context, watch: (u) => u!.age,).age;
    ...;
  });
}
```

> ObjectAspectError: ObjectValueAspect<num, ShopOrder>(id=null) is already registered in the same frame.

### InheritedObjects

`InheritedObjects` is a widget that lets you combine and provide multiple `InheritedObject` instances at once. This is especially useful when your widget tree depends on several objects and you want to keep your structure clean and organized.

With `InheritedObjects`, you can:
- Group multiple `InheritedObject` widgets for better structure
- Avoid deeply nested widget trees

For example, if your app needs to provide both a `User` and a `Settings` object to the widget tree, you can group them with `InheritedObjects`:

```dart
InheritedObjects(
  [
    InheritedObject<User>(
      object: const User(name: "Bob", age: 21),
    ),
    InheritedObject<Settings>(
      object: const Settings(theme: "dark"),
    ),
  ],
  child: MyApp(),
)
```

Now, any widget below can access both objects:

```dart
final user = InheritedObject.of<User>(context);
final settings = InheritedObject.of<Settings>(context);
```

### InheritedProvider

`InheritedProvider` is a convenient widget for providing immutable objects to the widget tree and managing their updates. It eliminates manual wiring and boilerplate, making state sharing and dependency injection much simpler and more scalable.

With `InheritedProvider`, you can:
- Provide any object type to descendant widgets
- Update objects and automatically rebuild dependents
- Chain multiple providers for complex state graphs
- Centralize state management with minimal code


Wrap your widget tree with an `InheritedProvider`:

```dart
InheritedProvider<User>(
  initialObject: const User(name: "Bob", age: 21),
  child: child,
)
```

Access the object anywhere below the provider:

```dart
final user = InheritedObject.of<User>(context);
```

Update the object and trigger rebuilds:

```dart
InheritedProvider.update<User>(context, (user) {
  return user.copyWith(age: user.age + 1);
});
```

This approach is recommended for most real-world apps, as it keeps your code clean and maintainable.

#### Static Methods

`InheritedProvider` offers several static methods for convenient access and updates:

- `InheritedProvider.of<T>(context)`: Returns the nearest provider state for type `T`, throws if not found.
- `InheritedProvider.maybeOf<T>(context)`: Returns the nearest provider state for type `T`, or `null` if not found.
- `InheritedProvider.update<T>(context, T Function(T object) update, {void Function()? or})`: Updates the object managed by the nearest provider. If no provider is found, optionally calls the `or` callback.

These methods make it easy to interact with providers anywhere in your widget tree, enabling safe access, updates, and custom fallback logic.

#### Provider's `notifier`

`InheritedProviderState` exposes a `notifier` property, which is a `ChangeNotifier` that you can use to listen for updates to the provided object. This allows you to react to changes and trigger side effects in your project whenever the state managed by the provider changes.

You can access the `notifier` of `InheritedProviderState` by calling `InheritedProvider.of`:

```dart
final notifier = InheritedProvider.of<User>(context).notifier;
```

You can then add listeners to the notifier:

```dart
notifier.addListener(() {
  // Respond to updates, e.g., refresh data or trigger animations
});
```

**Benefits:**

- Direct access to a `ChangeNotifier` for listening to updates
- Enables custom reactions and side effects on state changes

This approach provides a flexible way to observe and respond to state changes managed by `InheritedProvider`, making it easy to integrate with existing Flutter patterns.

### InheritedProviders

Similar to `InheritedObjects`, `InheritedProviders` allows you to combine and provide multiple `InheritedProvider` instances in a single place. This is especially useful when your widget tree depends on several independent objects or states, and you want to keep your provider setup clean and organized.

```dart
InheritedProviders(
  [
    InheritedProvider<User>(
      initialObject: const User(name: "Bob", age: 21),
    ),
    InheritedProvider<Settings>(
      initialObject: const Settings(theme: "dark"),
    ),
  ],
  child: MyApp(),
)
```

Now, any widget below can access both objects:

```dart
final user = InheritedObject.of<User>(context);
final settings = InheritedObject.of<Settings>(context);
```


### InheritedHub

`InheritedHub` is a centralized registry for managing and accessing multiple providers across your entire app. It enables global coordination of state and dependencies, making it easy to share objects and update them from anywhere in the widget tree.

With `InheritedHub` and by setting `hubEntry` in `InheritedProvider`, you can:
- Register and look up providers globally
- Coordinate updates and dependencies between different parts of your app
- Simplify complex state graphs and reduce boilerplate

This approach is ideal for large applications that require global state management or advanced dependency injection.

By controlling the value of `hubEntry`, you specify whether the `InheritedProvider` should be registered in the `InheritedHub` or not.

> **Note:** `InheritedHub` is typically placed above your `MyApp` widget, while `InheritedProvider` can be nested deep within the widget tree. This allows global access and coordination, even for providers created far below.


Below are code snippets demonstrating how to use `InheritedHub` for global state management and access.

Entry point: Wrap your app with InheritedHub to enable global provider registration.
```dart
  runApp(
    InheritedHub(
      child: MyApp(),
    ),
  );
```

Deep in the widget tree: Register a provider with `hubEntry: true` to make it globally accessible.
```dart
  InheritedProvider<User>(
    initialObject: const User(name: "Bob", age: 21),
    hubEntry: true, // Registers this provider in the InheritedHub
    child: child,
  );
```

Anywhere in the app: Access the globally registered object
```dart
    final user = InheritedObject.of<User>(context); 
```

You can also update the object globally from anywhere:
```dart
InheritedProvider.update<User>(context, (user) {
  return user.copyWith(age: user.age + 1);
});
```

#### When does this really matter?

Ever found yourself frustrated because you just can't reach the state or object you need — especially after opening a dialog or navigating to a new screen? It's in those moments, when your context is suddenly "too high" in the widget tree, that global access becomes not just convenient, but essential. 

With `InheritedHub` and `InheritedProvider(hubEntry: true)`, you never lose connection to your shared state, no matter where you are in your app. Because `InheritedHub` allowing you to access shared objects globally, regardless of the current context.

> Don't forget to set `hubEntry: true` in `InheritedProvider` to enable global access.



### ProviderDependency

`ProviderDependency` allows you to declare dependencies between different providers and control how objects are updated in response to changes. This makes it easy to build complex, reactive state graphs where updates propagate automatically through your widget tree.

With `ProviderDependency`, you can:
- Specify which objects depend on others
- Automatically update dependent objects when their sources change
- Simplify coordination between related pieces of state

> This approach is useful for apps with interconnected models or when you want to keep your state logic declarative and maintainable.

Suppose you have a `ShopOrder` object that depends on a `ShopPrice` object. You can declare this dependency so that when prices change, the order updates automatically:

```dart
final shopOrderDependency = ProviderDependency<ShopOrder, ShopPrice>(
  // Describes the dependency that required by the dependent provider.
  dependency: (context) => InheritedObject.of<ShopPrice>(context),

  // Defines the function or mechanism for updating the dependency. 
  // Used to pass new value to changes in the dependency.
  update: (order, price) => order!.updatedBy(price!),
);

InheritedProviders(
  providers: [
    InheritedProvider<ShopPrice>(
      initialObject: const ShopPrice({'Apple': 100, 'Banana': 50, 'Orange': 70}),
    ),
    InheritedProvider<ShopOrder>(
      initialObject: const ShopOrder([]),
      // define dependencies (ore on more)
      dependencies: [shopOrderDependency],
    ),
  ],
  child: ShopScreen(),
)
```

Now, whenever the `ShopPrice` object is updated, the `ShopOrder` object will be rebuilt using the provided update logic ([see example](https://github.com/dartius-dev/inheriteds/blob/main/example/lib/shop/shop_screen.dart)).

> `ProviderDependency` is built on top of the `dependents` package. Explore all its features and usage scenarios in the [`dependents` package documentation](https://pub.dev/packages/dependents).


### InheritedDataProvider

`InheritedDataProvider` is a flexible foundation for building your own specialized providers. While it can be used as a read-only provider for exposing inherited data, it also supports advanced features such as registration in `InheritedHub` and updates triggered by configured dependencies.

- Extend to create custom provider widgets with specialized logic
- Use as a read-only provider for immutable or reactive data
- Register in `InheritedHub` for global access
- Enable updates via dependency chains, even if direct updates are disabled

For simple scenarios, you can wrap your widget tree with `InheritedDataProvider`:

```dart
InheritedDataProvider<User>(
  initialObject: const User(name: "Bob", age: 21),
  child: child,
)
```

Access the object anywhere below the provider:

```dart
final user = InheritedObject.of<User>(context);
```

You can also register the provider in `InheritedHub` for global access, or configure dependencies to allow updates based on changes in other objects—even if the provider itself is read-only.

Extend `InheritedDataProvider` when you need full control over provider behavior, registration, and update logic for advanced state management patterns.

### InheritedObjectProvider

While `InheritedProvider` and `InheritedDataProvider` covers most use cases, sometimes you need a custom provider with specialized logic for object creation, updates, or registration. The `InheritedObjectProvider` base class lets you build your own provider widgets, giving you full control over how objects are managed and exposed to the widget tree.

Key features:
- Extend to implement custom state management or registration logic
- Control how and when objects are updated
- Integrate with `InheritedHub` for global access
- Enforce invariants or side effects during state changes

Use `InheritedObjectProvider` when you need advanced behaviors that go beyond the default provider’s capabilities.



## Additional information

See the `/example` folder to explore practical usage and scenarios. 

* [Try the live demo here.](https://dartius-dev.github.io/inheriteds/).
* [Example’s source code](https://github.com/dartius-dev/inheriteds/blob/main/example/lib/)

Issues and suggestions are welcome!

## License

MIT
