# RestBearerToken

A *Decodable* and *Encodable* bearer token representation with an attached type.

``` swift
public struct RestBearerToken: Codable 
```

JSON representation:

``` json
{
    "token": "someTokenValue",
    "accountInfo": {
        "accountType": "someTypeValue"
    }
}
```

> 

## Inheritance

`Codable`

## Properties

### `value`

The token value.

``` swift
public let value: String
```

### `type`

The bearer type representation.

``` swift
public let type: RestBearerType
```
