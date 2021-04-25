# Rest

The *REST* property wrapper.

``` swift
@propertyWrapper public struct Rest<Parent, Value> where Parent: Codable, Value: Codable 
```

Allows to send post and get requests with bearer authentication and values that are automatically
type marshalled.

Property access:

``` 
struct Fruit: Codable {
    let name: String
    let size: Int
    let color: String
}

...

@Rest(path: "fruitoftheday") var fruit: Fruit = Fruit(name: "strawberry", size: 3, color: "red")

...

print(fruit) // wrappedValue access
print($fruit.wrappedValue) // wrappedValue access

print($fruit) // projectedValue (aka query) access

print($fruit.projectedValue) // nested projectedValue (aka binding) access
print($fruit.name) // nested projectedValue (aka binding) property (aka property binding) access
```

Usage for authentication:

``` 
struct Account: Codable {
    var email: String
    var password: String
}

struct SomeView: View {
    @Rest(path: "signin", bearer: false) var account: Account = Account(email: "", password: "")

    private var cancelable: RestMutableValueReference<AnyCancellable?> = RestMutableValueReference(value: nil)

    var body: some View {
        TextField("Email placeholder", text: self.$account.email)
        TextField("Password placeholder", text: self.$account.password)
        Button("Sign In") {
            cancelable.update(with: self.$account>?.sink(receiveCompletion: { _ in }, receiveValue: { _ in}))
        }
    }
}
```

Usage for get request:

``` 
struct Fruit: Codable {
    let name: String
    let size: Int
    let color: String
}

struct SomeView: View {
    @Rest(path: "fruitoftheday") var fruit: Fruit = Fruit(name: "strawberry", size: 3, color: "red")

    private var cancelable: RestMutableValueReference<AnyCancellable?> = RestMutableValueReference(value: nil)

    var body: some View {
        Text(fruit.name)
            .onAppear { cancelable.update(with: self.$fruit>?
                .sink(receiveCompletion: { _ in }, receiveValue: { _ in })) }
    }
}
```

Usage for get request with query parameters:

``` 
struct Fruit: Codable {
    let name: String
    let size: Int
    let color: String
}
struct Fruits: Codable {
    var values: [Fruit] = []
}

struct SomeView: View {
    @Rest(path: "fruits", params: ["limit": 10]) var fruits: Fruits = Fruits()

    private var cancelable: RestMutableValueReference<AnyCancellable?> = RestMutableValueReference(value: nil)

    var body: some View {
        Text(fruits.values[0].name)
            .onAppear { cancelable.update(with: self.$fruits>?
               .sink(receiveCompletion: { _ in }, receiveValue: { _ in })) }
   }
}
```

Usage for get request with property key path:

``` 
struct Fruit: Codable {
    let name: String
    let size: Int
    let color: String
}
struct Fruits: ParentCodable {
    var values: [Fruit] = []

    static func wrap(child: [Fruit]) -> Self {
        return Fruits(values: child)
    }
}

struct SomeView: View {
    @Rest(path: "fruits", parent: Fruits.self, prop: \.values) var fruits: [Fruit] = []

    private var cancelable: RestMutableValueReference<AnyCancellable?> = RestMutableValueReference(value: nil)

    var body: some View {
        Text(fruits[0].name)
            .onAppear { cancelable.update(with: self.$fruits>?
               .sink(receiveCompletion: { _ in }, receiveValue: { _ in })) }
    }
}
```

Usage for get request with query parameters and property key path:

``` 
struct Fruit: Codable {
    let name: String
    let size: Int
    let color: String
}
struct Fruits: ParentCodable {
    var values: [Fruit] = []

    static func wrap(child: [Fruit]) -> Self {
        return Fruits(values: child)
    }
}

struct SomeView: View {
    @Rest(path: "fruits", params: ["limit": 10], parent: Fruits.self, prop: \.values) var fruits: [Fruit] = []

    private var cancelable: RestMutableValueReference<AnyCancellable?> = RestMutableValueReference(value: nil)

    var body: some View {
        Text(fruits[0].name)
            .onAppear { cancelable.update(with: self.$fruits>?
               .sink(receiveCompletion: { _ in }, receiveValue: { _ in })) }
    }
}
```

Usage for post request with existing value:

``` 
struct Account: Codable {
    var email: String
    var password: String
}

struct SomeView: View {
    @Rest(path: "signup") var account: Account = Account(email: "", password: "")

    private var cancelable: RestMutableValueReference<AnyCancellable?> = RestMutableValueReference(value: nil)

    var body: some View {
        TextField("Email placeholder", text: self.$account.email)
        TextField("Password placeholder", text: self.$account.password)
        Button("Sign Up") {
            cancelable.update(with: self.$account<!
                .sink(receiveCompletion: { _ in }, receiveValue: { _ in}))
        }
    }
}
```

Usage for post request with new value:

``` 
struct Account: Codable {
    var email: String
    var password: String
}

struct SomeView: View {
    @Rest(path: "signup") var account: Account = Account(email: "", password: "")

    private var cancelable: RestMutableValueReference<AnyCancellable?> = RestMutableValueReference(value: nil)

    var body: some View {
        TextField("Email placeholder", text: self.$account.email)
        TextField("Password placeholder", text: self.$account.password)
        Button("Sign Up") {
            cancelable.update(with: (self.$account <- someNewAccount)
                .sink(receiveCompletion: { _ in }, receiveValue: { _ in}))
        }
    }
}
```

### References

[Property Wrapper](https://docs.swift.org/swift-book/LanguageGuide/Properties.html#ID617)

[Key Paths](https://github.com/apple/swift-evolution/blob/master/proposals/0161-key-paths.md)

> 

> 

## Initializers

### `init(wrappedValue:path:bearer:)`

Creates a *Rest* property wrapper instance.

``` swift
public init(wrappedValue: Value, path: String, bearer: Bool = true) where Parent == Value 
```

Usage:

``` 
@Rest(path: "somePath") var someProp: SomeType = SomeType(...)
```

> 

#### Parameters

  - wrappedValue: The value wrapped by this property wrapper.
  - path: The url request path component.
  - bearer: True if the bearer token should be send as part of the request.

#### Returns

A new *Rest* property wrapper instance.

### `init(wrappedValue:path:params:bearer:)`

Creates a *Rest* property wrapper instance.

``` swift
public init<ParamKey, ParamValue>(wrappedValue: Value, path: String, params: [ParamKey: ParamValue], bearer: Bool = true) where Parent == Value, ParamKey: CustomStringConvertible, ParamValue: CustomStringConvertible 
```

Usage:

``` 
@Rest(path: "somePath", params: ["someKey": someValue]) var someProp: SomeType = SomeType(...)
```

> 

#### Parameters

  - wrappedValue: The value wrapped by this property wrapper.
  - path: The url request path component.
  - params: The url request query parameter component.
  - bearer: True if the bearer token should be send as part of the request.

#### Returns

A new *Rest* property wrapper instance.

### `init(wrappedValue:path:bearer:parent:prop:)`

Creates a *Rest* property wrapper instance.

``` swift
public init(wrappedValue: Value, path: String, bearer: Bool = true, parent: Parent.Type, prop: KeyPath<Parent, Value>) where Parent: ParentCodable, Parent.ChildCodable == Value 
```

Usage:

``` 
@Rest(path: "somePath", parent: SomeParentType.self, prop: \.somePropKey) var someProp: SomeType = SomeType(...)
```

> 

#### Parameters

  - wrappedValue: The value wrapped by this property wrapper.
  - path: The url request path component.
  - bearer: True if the bearer token should be send as part of the request.
  - parent: The parent type conforming to the `ParentCodable` protocol.
  - prop: The property to be extracted from the parent type.

#### Returns

A new *Rest* property wrapper instance.

### `init(wrappedValue:path:params:bearer:parent:prop:)`

Creates a *Rest* property wrapper instance.

``` swift
public init<ParamKey, ParamValue>(wrappedValue: Value, path: String, params: [ParamKey: ParamValue], bearer: Bool = true, parent: Parent.Type, prop: KeyPath<Parent, Value>) where ParamKey: CustomStringConvertible, ParamValue: CustomStringConvertible, Parent: ParentCodable, Parent.ChildCodable == Value 
```

Usage:

``` 
@Rest(path: "somePath", params: ["someKey": someValue], parent: SomeParentType.self, prop: \.somePropKey) var someProp: SomeType = SomeType(...)
```

> 

#### Parameters

  - wrappedValue: The value wrapped by this property wrapper.
  - path: The url request path component.
  - params: The url request query parameter component.
  - bearer: True if the bearer token should be send as part of the request.
  - parent: The parent type conforming to the `ParentCodable` protocol.
  - prop: The property to be extracted from the parent type.

#### Returns

A new *Rest* property wrapper instance.

## Properties

### `wrappedValue`

Implicitly used computed property for `@propertyWrapper`.

``` swift
public var wrappedValue: Value 
```

Provides access to the wrapped value.

Usage:

``` 
struct Fruit: Codable {
    let name: String
    let size: Int
    let color: String
}

...

@Rest(path: "fruitoftheday") var fruit: Fruit = Fruit(name: "strawberry", size: 3, color: "red")

...

print(fruit) // wrappedValue access
print(fruit.name) // wrappedValue property access
```

> 

### `projectedValue`

Implicitly used computed property for `@propertyWrapper`.

``` swift
public var projectedValue: RestQueryImpl<Parent, Value> 
```

Provides access to the associated query. Visibility is set to `fileprivate` to restrict
query mutations.

Usage:

``` 
struct Fruit: Codable {
    let name: String
    let size: Int
    let color: String
}

...

@Rest(path: "fruitoftheday") var fruit: Fruit = Fruit(name: "strawberry", size: 3, color: "red")

...

print($fruit) // projectedValue (aka query) access

print($fruit.projectedValue) // nested projectedValue (aka binding) access
print($fruit.name) // nested projectedValue (aka binding) property (aka property binding) access
```

> 
