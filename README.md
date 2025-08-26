# inheriteds
[![live demo](./example/livedemo.svg)](https://dartius-dev.github.io/inheriteds/)
[![example](./example/example.svg)](https://github.com/dartius-dev/inheriteds/blob/main/example/)
![beta](./example/beta.svg)


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
### InheritedProvider
### InheritedProviders
### ProviderDependency
### InheritedObjectProvider
### InheritedHub

## Additional information

See the `/example` folder to explore practical usage and scenarios. 

* [Try the live demo here.](https://dartius-dev.github.io/inheriteds/).
* [Example’s source code](https://github.com/dartius-dev/inheriteds/blob/main/example/lib/)

Issues and suggestions are welcome!

## License

MIT
