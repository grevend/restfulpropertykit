# RestURLComponents

This structure constructs URLs according to RFC 3986.

``` swift
public struct RestURLComponents 
```

### Reference

[RFC 3986](https://tools.ietf.org/html/rfc3986)

> 

## Properties

### `scheme`

The URL scheme component.

``` swift
public let scheme: String
```

### `host`

The URL host component.

``` swift
public let host: String
```

### `path`

The URL path component.

``` swift
public let path: String
```

### `params`

The URL params component.

``` swift
public let params: [String: String]
```

## Methods

### `url(params:)`

Returns a constructed URL from its constituent parts.

``` swift
public func url(params: Bool = true) -> URL? 
```

> 

#### Parameters

  - params: Should the constructed query include parameters.

#### Returns

The constructed URL.
