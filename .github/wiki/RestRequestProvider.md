# RestRequestProvider

The protocol used for all *REST* request provider implementations.

``` swift
public protocol RestRequestProvider 
```

> 

## Requirements

### restRequestPublisher(for:​)

Returns a publisher that wraps a URL session for a given URL request.

``` swift
func restRequestPublisher(for request: URLRequest) -> AnyPublisher<URLSession.DataTaskPublisher.Output, URLError>
```

The publisher publishes data when the task completes, or terminates if the task fails with an error.

> 

#### Parameters

  - request: The URL request for which to create a request.

#### Returns

A publisher that wraps a data task for the URL request.
