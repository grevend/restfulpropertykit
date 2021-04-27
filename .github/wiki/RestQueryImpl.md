# RestQueryImpl

An implementation of *RestQuery* protocol.

``` swift
public final class RestQueryImpl<Parent, Value>: RestQuery where Parent: Codable, Value: Codable 
```

> 

> 

## Inheritance

[`RestQuery`](https://github.com/grevend/restfulpropertykit/wiki/RestQuery)

## Initializers

### `init(current:params:)`

Creates a copy of the provided current query with a different params component.

``` swift
required convenience public init(current: RestQueryImpl<Parent, Value>, params: [String: String]) 
```

> 

#### Parameters

  - current: The current query.
  - params: The new params for the query copy.

#### Returns

The created copy *RestQueryImpl* instance.

## Properties

### `projectedValue`

A binding for the wrapped value.

``` swift
public var projectedValue: Binding<Value>
```

### `metadata`

The metadata associated with this query.

``` swift
public var metadata: RestQueryMetadata<Parent, Value>
```

### `cancellable`

The `Set` of cancellable query requests.

``` swift
public var cancellable: Set<AnyCancellable> 
```

### `wrappedValue`

The value wrapped by the property attached to this query.

``` swift
public var wrappedValue: Value 
```

> 

## Methods

### `get(prop:)`

Sends a get request based on the metadata associated with this query.

``` swift
public func get(prop: Bool) -> Future<Value, RestQueryError> 
```

> 

#### Parameters

  - prop: True if the property key should be used on the parent request result to unwrap the value.

#### Returns

A future that will resolve to the request result or an error.

### `post(prop:newValue:)`

Sends a post request based on the metadata associated with this query.

``` swift
public func post(prop: Bool, newValue: Value) -> Future<Value, RestQueryError> 
```

> 

#### Parameters

  - prop: True if the property key should be used on the parent request result to unwrap the value.
  - newValue: The value that should be send as the body part of the `HTTPS` request.

#### Returns

A future that will resolve to the new value or an error.
