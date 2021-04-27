# RestQuery

The protocol all rest query implementations should conform to.

``` swift
@dynamicMemberLookup public protocol RestQuery: AnyObject where QueryParent: Codable, QueryValue: Codable 
```

> 

> 

## Inheritance

`AnyObject`

## Default Implementations

### `subscript(dynamicMember:)`

Lazily creates and stores bindings for the properties of the request return type as part of the query metadata.

``` swift
subscript<Subject>(dynamicMember keyPath: KeyPath<QueryValue, Subject>) -> Binding<Subject> 
```

> 

#### Parameters

  - dynamicMember: The read-only property key path.

### `subscript(dynamicMember:)`

Lazily creates and stores bindings for the properties of the request return type as part of the query metadata.

``` swift
subscript<Subject>(dynamicMember keyPath: WritableKeyPath<QueryValue, Subject>) -> Binding<Subject> 
```

> 

#### Parameters

  - dynamicMember: The writable property key path.

## Requirements

### QueryParent

The parent type.

``` swift
associatedtype QueryParent
```

### QueryValue

The value type.

``` swift
associatedtype QueryValue
```

### metadata

The metadata associated with this query.

``` swift
var metadata: RestQueryMetadata<QueryParent, QueryValue> 
```

### wrappedValue

The value wrapped by the property attached to this query.

``` swift
var wrappedValue: QueryValue 
```

### projectedValue

A binding for the wrapped value.

``` swift
var projectedValue: Binding<QueryValue> 
```

### cancellable

``` swift
var cancellable: Set<AnyCancellable> 
```

### init(current:​params:​)

Creates a copy of the provided current query with a different params component.

``` swift
init(current: Self, params: [String: String])
```

> 

#### Parameters

  - current: The current query.
  - params: The new params for the query copy.

### get(prop:​)

Sends a get request based on the metadata associated with this query.

``` swift
func get(prop: Bool) -> Future<QueryValue, RestQueryError>
```

> 

#### Parameters

  - prop: True if the property key should be used on the parent request result to unwrap the value.

#### Returns

A future that will resolve to the request result or an error.

### post(prop:​newValue:​)

Sends a post request based on the metadata associated with this query.

``` swift
func post(prop: Bool, newValue: QueryValue) -> Future<QueryValue, RestQueryError>
```

> 

#### Parameters

  - prop: True if the property key should be used on the parent request result to unwrap the value.
  - newValue: The value that should be sent as the body part of the `HTTPS` request.

#### Returns

A future that will resolve to the new value or an error.
