# RestQueryMetadata

A representation of the *RestQuery* metadata.

``` swift
public struct RestQueryMetadata<Parent, Value> 
```

> 

## Properties

### `urlComponents`

The URL components of the requests.

``` swift
public let urlComponents: RestURLComponents
```

### `bearer`

Should the bearer token be send as part of the requests.

``` swift
public let bearer: Bool
```

### `prop`

The parent type keypath to extract the requested value.

``` swift
public let prop: KeyPath<Parent, Value>
```

### `token`

The bearer token used for authorization.

``` swift
public var token: RestBearerToken? 
```
