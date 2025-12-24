# Changelog

All notable changes to this project will be documented in this file.

## [0.2.0]
- Added:
  - `InheritedBridge`: Bridges inherited objects across different branches of the widget tree.
  - `InheritedEntries`: Allows combining and providing multiple `InheritedEntry` instances at once, including:
    - `InheritedObject`
    - `InheritedObjectProvider` instances (`InheritedProvider`, `InheritedDataProvider`)
    - `InheritedBridge`
- Removed:
  - `InheritedObjects` (use `InheritedEntries` instead)
  - `InheritedProviders` (use `InheritedEntries` instead)
- Updated:
  - Example: Added usage of `InheritedBridge`.
- Fixed:
  - `InheritedObjectProvider.of`: Corrected return type.
  - `ProviderDependency.update`: Fixed argument types.

## [0.1.1]
- Changed
  - dependency of 'inheriteds' package is updated

## [0.1.0]
- Changed
  - Improved handling of nullable values for `InheritedObject` 
    - Added `InheritedObject.nullable`
    - Nullable types are now forbidden for `InheritedObject<T>`,
- Fixes:
  - Fixed: `_ProviderDependencyState.updateDependency` sets the object during the build stage.
  - Fixed: a late error when updating `InheritedObjectProviderState._hub`.

## [0.0.5]
- Changed
  - `InheritedProviders`: You can now specify empty `entries`.
  - `InheritedObjects`: You can now specify empty `entries`.

## [0.0.4]

- Changed
  - `InheritedProviders`: The `providers` parameter is now a positional argument and has been renamed to `entries`.
- Added
  - `InheritedObjects`: Enables adding multiple `InheritedObject`s using a single widget.
  
## [0.0.3]
- Added `InheritedDataProvider` 
  - read-only provider.
  - foundation for building your own providers 
- `InheritedObjectProviderState`
  - Added property object
  - Removed properties: hasObject, maybeObject


## [0.0.2]
- Updated README.md


## [0.0.1]
- Initial version of the library.

