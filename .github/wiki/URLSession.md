# Extensions on URLSession

## Methods

### `restRequestPublisher(for:)`

Returns a publisher that wraps a URL session for a given URL request.

``` swift
public func restRequestPublisher(for request: URLRequest) -> AnyPublisher<DataTaskPublisher.Output, URLError> 
```

The publisher publishes data when the task completes, or terminates if the task fails with an error.

> 

#### Parameters

  - request: The URL request for which to create a request.

#### Returns

A publisher that wraps a data task for the URL request.
