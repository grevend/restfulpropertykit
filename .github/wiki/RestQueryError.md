# RestQueryError

The *RestQuery* error type.

``` swift
public enum RestQueryError: Error 
```

> 

## Inheritance

`Error`

## Enumeration Cases

### `missingImplementation`

The query is missing an operation implementation.

``` swift
case missingImplementation
```

### `dynamicWrapDispatch`

The dynamic dispatch failed to invoke the typesafe wrap method successfully.

``` swift
case dynamicWrapDispatch
```

### `url`

The construction of the request URL failed.

``` swift
case url(URLError)
```

### `urlValidation`

The validation of the request URL failed.

``` swift
case urlValidation
```

### `urlReponse`

The request result did not contain a response.

``` swift
case urlReponse
```

### `statusCode`

The status code was not in the expected range.

``` swift
case statusCode(Int)
```

### `bearer`

The bearer token is missing for request with implicit or explicit `@Rest(bearer:​ true)`.

``` swift
case bearer
```

### `decode`

The decoding of the query result or bearer token failed.

``` swift
case decode(DecodingError)
```

### `encode`

The encoding of the query content failed.

``` swift
case encode(EncodingError)
```

### `cancelled`

The query request was cancelled.

``` swift
case cancelled
```

### `other`

Some other issue.

``` swift
case other(Error)
```
