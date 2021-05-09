# ParentCodable

A type that can wrap a child *Codable* value into a representation of itself.

``` swift
public protocol ParentCodable: Codable, ParentCodableDynamicDispatch where ChildCodable: Codable 
```

Protocol *ParentCodable* can only be used as a generic constraint because it has
`Self` or associated type requirements.

> 

> 

## Inheritance

`Codable`, [`ParentCodableDynamicDispatch`](https://github.com/grevend/restfulpropertykit/wiki/ParentCodableDynamicDispatch)

## Default Implementations

### `dynamicWrap(child:)`

Default implementation for `ParentCodableDynamicDispatch.dynamicWrap(child:​ Any)`.

``` swift
static func dynamicWrap(child: Any) -> Any 
```

Provided implicit implementation:

``` 
static func dynamicWrap(child: Any) -> Any {
    self.wrap(child: child as! ChildCodable)
}
```

> 

#### Parameters

  - child: The value to be wrapped by a parent type implementing *ParentCodable*.

## Requirements

### ChildCodable

The associated child type implementing the *Decodable* and *Encodable*
protocols.

``` swift
associatedtype ChildCodable
```

### wrap(child:​)

Wraps a value of type *ChildCodable* into a representation of itself.

``` swift
static func wrap(child: ChildCodable) -> Self
```

> 

#### Parameters

  - child: The value to be wrapped by the parent type.

#### Returns

An instance of the parent type wrapping the child value.
