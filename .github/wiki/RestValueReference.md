# RestValueReference

Class-based value wrapper to easily reference the value and avoid copying the data in certain
contexts.

``` swift
public class RestValueReference<Value> 
```

The REST API uses this class and its mutable counterpart for passing the data of the `@Rest`
property wrapper to internal logic, requiring a reference to the value even if it is a struct or enum.

> 

## Initializers

### `init(value:)`

Returns a new instance of *RestValueReference* containing a value of type `Value`.

``` swift
public init(value: Value) 
```

> 

#### Parameters

  - value: The value to be referenced.

#### Returns

The newly created instance referencing the given value.
