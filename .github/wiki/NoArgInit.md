# NoArgInit

Opt-in conformance for structures with no argument initializer.

``` swift
public protocol NoArgInit 
```

Example:

``` 
struct Account: Codable, NoArgInit {
    // The account email.
    var email: String = ""
    // The account password.
    var password: String = ""
}
```

> 

## Requirements

### init()

The required initializer with no argument.

``` swift
init()
```
