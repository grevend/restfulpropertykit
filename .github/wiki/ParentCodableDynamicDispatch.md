# ParentCodableDynamicDispatch

ParentCodableDynamicDispatch is a weakly typed wrapper to dispatch wrap method
calls to a *ParentCodable* object.

``` swift
public protocol ParentCodableDynamicDispatch 
```

This protocol is a solution for the Swift limitation of protocols with associated types only
being usable for generic constraints.

Example demonstrating the `is` operator usage issue:

``` 
// Error: Protocol 'ParentCodable' can only be used as a generic
// constraint because it has Self or associated type requirements.
if someCodable is ParentCodable {
    ...
}

// Solution:
if someParentCodable is ParentCodableDynamicDispatch {
    ...
}
```

Example demonstrating the `wrap(child: ChildCodable)` usage issue:

``` 
// Error: Protocol 'ParentCodable' can only be used as a generic
// constraint because it has Self or associated type requirements.
if let someParentCodableType = someCodableType as? ParentCodable.Type {
    someParentCodableType.wrap(child: someChildCodable)
}

// Solution:
if let someParentCodableType = someCodableType as? ParentCodableDynamicDispatch.Type {
    someParentCodableType.dynamicWrap(child: someChildCodable)
}
```

> 

## Requirements

### dynamicWrap(child:​)

Should delegate the call and child value to a strongly typed
`ParentCodable.wrap(child:​ ChildCodable)` implementation.

``` swift
static func dynamicWrap(child: Any) -> Any
```

> 

#### Parameters

  - child: The value to be wrapped by a parent type implementing this protocol implicitly using `ParentCodable`.

#### Returns

An instance of the parent type wrapping the child value.
