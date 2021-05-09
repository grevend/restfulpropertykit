# RestConfiguration

Allows to configure the *REST API*.

``` swift
public final class RestConfiguration 
```

Usage:

``` 
RestConfiguration.host = "someHost"
```

> 

## Properties

### `host`

The URL host component.

``` swift
public static var host: String = ""
```

### `timeoutInterval`

The request timeout interval.

``` swift
public static var timeoutInterval: TimeInterval = 10000
```

### `debug`

Is debug session?

``` swift
public static var debug: Bool = false
```

### `requestProvider`

The default request provider (*URLSession.shared*) or a mocked variation.

``` swift
public static var requestProvider: RestRequestProvider 
```

> 
