# \_restMock(with:block:)

\[EXPERIMENTAL\] Mocks all requests made in the block closure using the given *RestRequestProvider*.

``` swift
public func _restMock<Result>(with provider: RestRequestProvider, block: (() -> Result)) -> Result 
```

Usage:

``` 
restMock(someMockProvider) {
    someQuery <- someValue
}
```

> 

## Parameters

  - provider: The mock request provider.
  - block: The computation using mocked requests.

## Returns

The result of the computation inside of the closure.
