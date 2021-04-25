# RestMutableValueReference

The mutable counterpart of *RestValueReference\<Value\>*. Subclassing is not possible since it is
final and the value setter in *RestValueReference* is `fileprivate`.

``` swift
public final class RestMutableValueReference<Value>: RestValueReference<Value> 
```

Class-based value wrapper to easily reference and mutate the value while avoiding copying the data
in certain contexts.

The REST API uses this class for passing the data of the `@Rest` property wrapper to internal logic,
requiring a mutable reference to the value even if it is a struct or enum.

Usage:

``` 
someReference.update(with: newValue)
```

> 

## Inheritance

`RestValueReference<Value>`

## Methods

### `update(with:)`

Mutates or replaces the referenced value.

``` swift
public func update(with value: Value) 
```

Usage:

``` 
someReference.update(with: newValue)
```

> 

#### Parameters

  - with: A new or mutated value of the same type.
