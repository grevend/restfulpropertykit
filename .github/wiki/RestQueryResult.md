# RestQueryResult

The result type of a *REST* query.

``` swift
public final class RestQueryResult<QueryType> where QueryType: RestQuery 
```

This result type contains a reference to the query as well as a future that will resolve to the new value or an error.

> 

> 

## Properties

### `query`

The query associated with this result.

``` swift
public let query: QueryType
```

### `result`

The query result as a future that will resolve to the new value or an error.

``` swift
public let result: Future<QueryType.QueryValue, RestQueryError>
```

## Methods

### `success(received:)`

Attaches a subscriber with closure-based behavior.

``` swift
public func success(received: @escaping (() -> Void)) 
```

Upon completion the `success(received:)` operator’s received closure indicates the successful termination of the query result.

Usage:

``` 
someQueryResult.success {
    ...
}
```

This method creates and returns a subscriber.

> 

#### Parameters

  - received: The closure to execute on successful completion.

### `failure(received:)`

Attaches a subscriber with closure-based behavior.

``` swift
public func failure(received: @escaping (() -> Void)) 
```

Upon completion the `failure(received:)` operator’s received closure indicates the failure of the query.

Usage:

``` 
someQueryResult.failure {
    ...
}
```

This method creates and returns a subscriber.

> 

#### Parameters

  - received: The closure to execute on failed completion.

### `sink(receiveCompletion:receiveValue:)`

Attaches a subscriber with closure-based behavior.

``` swift
public func sink(receiveCompletion: @escaping ((Subscribers.Completion<RestQueryError>) -> Void), receiveValue: @escaping ((QueryType.QueryValue) -> Void)) 
```

Use `sink(receiveCompletion:receiveValue:)` to observe values received by the future publisher and process them using a closure you specify.
Upon completion the `sink(receiveCompletion:receiveValue:)` operator’s receiveCompletion closure indicates the successful termination of the stream.

Usage:

``` 
someQueryResult.sink(receiveCompletion: { completion in
    ...
}, receiveValue: { value in
    ...
})
```

This method creates the subscriber and immediately requests an unlimited number of values, prior to returning the subscriber.

> 

#### Parameters

  - receiveCompletion: The closure to execute on completion.
  - receiveValue: The closure to execute on receipt of a value.

### `sink(receiveValue:)`

Attaches a subscriber with closure-based behavior.

``` swift
public func sink(receiveValue: @escaping ((QueryType.QueryValue) -> Void)) 
```

Use `sink(receiveValue:)` to observe values received by the future publisher and process them using a closure you specify.

Usage:

``` 
someQueryResult.sink { value in
    ...
}
```

This method creates the subscriber and immediately requests an unlimited number of values, prior to returning the subscriber.

> 

#### Parameters

  - receiveValue: The closure to execute on receipt of a value.
