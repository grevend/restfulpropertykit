//
//  RestfulPropertyKit.swift
//  RestfulPropertyKit
//
//  Created by David Greven on 12.04.21.
//  Copyright (c) 2021 David Greven. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

// swiftlint:disable line_length
// swiftlint:disable file_length

import Foundation
import Security
import Combine
import SwiftUI

/// A type that can wrap a child *Codable* value into a representation of itself.
///
/// Protocol *ParentCodable* can only be used as a generic constraint because it has
/// `Self` or associated type requirements.
///
/// - Requires: The type `ChildCodable` must conform to protocol `Codable`.
///
/// - Since: Sprint 1
public protocol ParentCodable: Codable, ParentCodableDynamicDispatch where ChildCodable: Codable {
    /// The associated child type implementing the *Decodable* and *Encodable*
    /// protocols.
    associatedtype ChildCodable

    /// Wraps a value of type *ChildCodable* into a representation of itself.
    ///
    /// - Parameter child: The value to be wrapped by the parent type.
    ///
    /// - Returns: An instance of the parent type wrapping the child value.
    ///
    /// - Since: Sprint 1
    static func wrap(child: ChildCodable) -> Self
}

/// ParentCodableDynamicDispatch is a weakly typed wrapper to dispatch wrap method
/// calls to a *ParentCodable* object.
///
/// This protocol is a solution for the Swift limitation of protocols with associated types only
/// being usable for generic constraints.
///
/// Example demonstrating the `is` operator usage issue:
/// ~~~
/// // Error: Protocol 'ParentCodable' can only be used as a generic
/// // constraint because it has Self or associated type requirements.
/// if someCodable is ParentCodable {
///     ...
/// }
///
/// // Solution:
/// if someParentCodable is ParentCodableDynamicDispatch {
///     ...
/// }
/// ~~~
///
/// Example demonstrating the `wrap(child: ChildCodable)` usage issue:
/// ~~~
/// // Error: Protocol 'ParentCodable' can only be used as a generic
/// // constraint because it has Self or associated type requirements.
/// if let someParentCodableType = someCodableType as? ParentCodable.Type {
///     someParentCodableType.wrap(child: someChildCodable)
/// }
///
/// // Solution:
/// if let someParentCodableType = someCodableType as? ParentCodableDynamicDispatch.Type {
///     someParentCodableType.dynamicWrap(child: someChildCodable)
/// }
/// ~~~
///
/// - Since: Sprint 1
public protocol ParentCodableDynamicDispatch {
    /// Should delegate the call and child value to a strongly typed
    /// `ParentCodable.wrap(child: ChildCodable)` implementation.
    ///
    /// - Parameter child: The value to be wrapped by a parent type implementing
    /// this protocol implicitly using `ParentCodable`.
    ///
    /// - Returns: An instance of the parent type wrapping the child value.
    ///
    /// - Since: Sprint 1
    static func dynamicWrap(child: Any) -> Any
}

/// ParentCodable extension that provides the implicit default implementation of
/// `ParentCodableDynamicDispatch.dynamicWrap(child: Any)`.
///
/// Default implementation:
/// ~~~
/// static func dynamicWrap(child: Any) -> Any {
///     self.wrap(child: child as! ChildCodable)
/// }
/// ~~~
///
/// - Since: Sprint 1
public extension ParentCodable {
    /// Default implementation for `ParentCodableDynamicDispatch.dynamicWrap(child: Any)`.
    ///
    /// - Parameter child: The value to be wrapped by a parent type implementing
    /// *ParentCodable*.
    ///
    /// Provided implicit implementation:
    /// ~~~
    /// static func dynamicWrap(child: Any) -> Any {
    ///     self.wrap(child: child as! ChildCodable)
    /// }
    /// ~~~
    ///
    /// - Since: Sprint 1
    fileprivate static func dynamicWrap(child: Any) -> Any {
        // swiftlint:disable force_cast
        self.wrap(child: child as! ChildCodable)
        // swiftlint:enable force_cast
    }
}

/// Class-based value wrapper to easily reference the value and avoid copying the data in certain
/// contexts.
///
/// The REST API uses this class and its mutable counterpart for passing the data of the `@Rest`
/// property wrapper to internal logic, requiring a reference to the value even if it is a struct or enum.
///
/// - Since: Sprint 1
public class RestValueReference<Value> {
    /// The referenced value. Visibility is set to `fileprivate` to allow the implementation of
    /// `RestMutableValueReference<Value>` while restricting other subclasses from modifying
    /// the referenced value.
    fileprivate(set) var value: Value

    /// Returns a new instance of *RestValueReference* containing a value of type `Value`.
    ///
    /// - Parameter value: The value to be referenced.
    ///
    /// - Returns: The newly created instance referencing the given value.
    ///
    /// - Since: Sprint 1
    public init(value: Value) {
        self.value = value
    }
}

/// The mutable counterpart of *RestValueReference\<Value\>*. Subclassing is not possible since it is
/// final and the value setter in *RestValueReference* is *fileprivate*.
///
/// Class-based value wrapper to easily reference and mutate the value while avoiding copying the data
/// in certain contexts.
///
/// The REST API uses this class for passing the data of the `@Rest` property wrapper to internal logic,
/// requiring a mutable reference to the value even if it is a struct or enum.
///
/// Usage:
/// ~~~
/// someReference.update(with: newValue)
/// ~~~
///
/// - Since: Sprint 1
public final class RestMutableValueReference<Value>: RestValueReference<Value> {
    /// Mutates or replaces the referenced value.
    ///
    /// Usage:
    /// ~~~
    /// someReference.update(with: newValue)
    /// ~~~
    ///
    /// - Parameter with: A new or mutated value of the same type.
    ///
    /// - Since: Sprint 1
    public func update(with value: Value) {
        self.value = value
    }
}

/// The protocol used for all *REST* request provider implementations.
///
/// - Since: Sprint 1
public protocol RestRequestProvider {
    /// Returns a publisher that wraps a URL session for a given URL request.
    ///
    /// The publisher publishes data when the task completes, or terminates if the task fails with an error.
    ///
    /// - Parameter request: The URL request for which to create a request.
    ///
    /// - Returns: A publisher that wraps a data task for the URL request.
    ///
    /// - Since: Sprint 1
    func restRequestPublisher(for request: URLRequest) -> AnyPublisher<URLSession.DataTaskPublisher.Output, URLError>
}

/// Default *RestRequestProvider* implementation for *URLSession*.
///
/// - Since: Sprint 1
extension URLSession: RestRequestProvider {
    /// Returns a publisher that wraps a URL session for a given URL request.
    ///
    /// The publisher publishes data when the task completes, or terminates if the task fails with an error.
    ///
    /// - Parameter request: The URL request for which to create a request.
    ///
    /// - Returns: A publisher that wraps a data task for the URL request.
    ///
    /// - Since: Sprint 1
    public func restRequestPublisher(for request: URLRequest) -> AnyPublisher<DataTaskPublisher.Output, URLError> {
        self.dataTaskPublisher(for: request).eraseToAnyPublisher()
    }
}

/// A collection of internal Publisher extension methods to simplify the internal REST API logic without
/// shared protocol `where` clause.
///
/// - Since: Sprint 1
fileprivate extension Publisher {
    /// Transforms all elements from the upstream publisher into `Result` objects and wraps all
    /// failures in `.failure` instances.
    ///
    /// Replaces:
    /// ~~~
    /// somePublisher
    ///     .map(Result.success)
    ///     .catch { Just(.failure($0)) }
    ///     .eraseToAnyPublisher()
    /// ~~~
    ///
    /// - Returns: A publisher that transforms elements from the upstream publisher into `Result`
    /// objects and wraps all failures in `.failure` instances that it then publishes.
    ///
    /// - Since: Sprint 1
    func convertToResult() -> AnyPublisher<Result<Output, Failure>, Never> {
        self.map(Result.success)
            .catch { Just(.failure($0)) }
            .eraseToAnyPublisher()
    }

    /// Attaches a subscriber that resolves the provided closure-based promise.
    ///
    /// Replaces:
    /// ~~~
    /// somePublisher
    ///     .sink(receiveCompletion: { _ in }) { result in
    ///         somePromise(result)
    ///     }
    /// ~~~
    ///
    /// - Parameter promise: The closure-based promise that should be resolved for the first
    /// given value.
    ///
    /// - Returns: A cancellable instance, which you use when you end resolving the received value.
    /// Deallocation of the result will tear down the subscription stream.
    ///
    /// - Requires: The publisher `self` must have the `Output` type `Result<_,_>`.
    ///
    /// - Warning: This abstraction over the `.sink` method ignores the receiveCompletion values.
    ///
    /// - Since: Sprint 1
    func resolve<Value, Error>(promise: @escaping ((Self.Output) -> Void)) -> AnyCancellable where Self.Output == Result<Value, Error> {
        self.sink(receiveCompletion: { _ in }, receiveValue: { result in
            promise(result)
        })
    }

    /// Composite publisher operation that transforms, resolves, and cancels the upstream publisher.
    ///
    /// The operation consist of the following steps:
    /// 1. Updates the given `RestMutableValueReference<Value>` with the non-empty elements
    /// from the upstream publisher without canceling the upstream publisher.
    /// 2. Attaches a subscriber that resolves the provided closure-based promise.
    /// 3. Stores the previously returned `AnyCancellable` in the referenced `Set`.
    ///
    /// Replaces:
    /// ~~~
    /// somePublisher
    ///     .assignAndContinue(value: someValue)
    ///     .resolve(promise: somePromise)
    ///     .store(in: &someSet)
    /// ~~~
    ///
    /// - Parameters:
    ///     - value: The mutable value reference that the publisher elements should be assigned to.
    ///     - promise: The closure-based promise that should be resolved for the first given value.
    ///     - in: The `Set` of `AnyCancellable` objects.
    ///
    /// - Requires: The publisher `self` must have the `Output` type `Result<_,_>` and
    /// `Failure` type `Never`.
    ///
    /// - Warning: The used abstraction over the `.sink` method ignores the receiveCompletion values.
    ///
    /// - Since: Sprint 1
    func assignResolveAndStore<Value, Error>(value: RestMutableValueReference<Value>, promise: @escaping ((Result<Value, Error>) -> Void), in set: inout Set<AnyCancellable>) where Self.Output == Result<Value, Error>, Self.Failure == Never {
        self.assignAndContinue(value: value)
            .resolve(promise: promise)
            .store(in: &set)
    }

    /// Nested composite publisher operation that transforms, resolves, and cancels the upstream publisher.
    ///
    /// The operation consist of the following steps:
    /// 1. Transforms all elements from the upstream publisher into `Result` objects and wraps all
    /// failures in `.failure` instances.
    /// 2. Updates the given `RestMutableValueReference<Value>` with the non-empty elements
    /// from the upstream publisher without canceling the upstream publisher.
    /// 3. Attaches a subscriber that resolves the provided closure-based promise.
    /// 4. Stores the previously returned `AnyCancellable` in the referenced `Set`.
    ///
    /// Replaces:
    /// ~~~
    /// somePublisher
    ///     .convertToResult()
    ///     .assignResolveAndStore(value: someValue, promise: somePromise, in: &someSet)
    /// ~~~
    ///
    /// - Parameters:
    ///     - value: The mutable value reference that the publisher elements should be assigned to.
    ///     - promise: The closure-based promise that should be resolved for the first given value.
    ///     - in: The `Set` of `AnyCancellable` objects.
    ///
    /// - Warning: The used abstraction over the `.sink` method ignores the receiveCompletion values.
    ///
    /// - Since: Sprint 1
    func convertAssignResolveAndStore(value: RestMutableValueReference<Self.Output>, promise: @escaping ((Result<Self.Output, Failure>) -> Void), in set: inout Set<AnyCancellable>) {
        self.convertToResult()
            .assignResolveAndStore(value: value, promise: promise, in: &set)
    }
}

/// An internal Publisher extension method to simplify the internal REST API logic for publishers `where`
/// the `Failure` type equals `Never`.
///
/// - Requires: The type `Self.Failure` must conform `Never`.
///
/// - Since: Sprint 1
fileprivate extension Publisher where Self.Failure == Never {
    /// Updates the given `RestMutableValueReference<Value>` with the non-empty elements
    /// from the upstream publisher without canceling the upstream publisher.
    ///
    /// Replaces:
    /// ~~~
    /// somePublisher.map { result in
    ///     result.map {
    ///         value.update(with: $0)
    ///         return $0
    ///     }
    /// }
    /// ~~~
    ///
    /// - Parameter value: The mutable value reference that the publisher elements should be
    /// assigned to without canceling the upstream publisher.
    ///
    /// - Returns: The `Publishers.Map` instance of the outer transformation.
    ///
    /// - Requires: The publisher `self` must have the `Output` type `Result<_,_>` and
    /// `Failure` type `Never`.
    ///
    /// - Since: Sprint 1
    func assignAndContinue<Value, Error>(value: RestMutableValueReference<Value>) -> Publishers.Map<Self, Output> where Self.Output == Result<Value, Error> {
        self.map { result in
            result.map {
                value.update(with: $0)
                return $0
            }
        }
    }
}

/// A *Decodable* and *Encodable* bearer token representation with an attached type.
///
/// JSON representation:
/// ```json
/// {
///     "token": "someTokenValue",
///     "accountInfo": {
///         "accountType": "someTypeValue"
///     }
/// }
/// ```
///
/// - Since: Sprint 1
public struct RestBearerToken: Codable {
    /// The token value.
    public let value: String
    /// The bearer type representation.
    public let type: RestBearerType

    /// The decoding and encoding keys used for mapping the *RestBearerToken* properties.
    ///
    /// This enum with string literal values will be implicitly used by the `JSON` decoder and
    /// encoder to map the property names.
    ///
    /// Mapping:
    /// ~~~
    /// "token" => value
    /// "accountInfo" => type
    /// ~~~
    ///
    /// - Since: Sprint 1
    private enum CodingKeys: String, CodingKey {
        case value = "token", type = "accountInfo"
    }
}

/// A *Decodable* and *Encodable* bearer type representation.
///
/// JSON representation:
/// ```json
/// {
///     "accountType": "someTypeValue"
/// }
/// ```
///
/// - Since: Sprint 1
public struct RestBearerType: Codable {
    /// The type value.
    public let value: String

    /// The decoding and encoding keys used for mapping the *RestBearerType* properties.
    ///
    /// This enum with string literal values will be implicitly used by the `JSON` decoder and
    /// encoder to map the property names.
    ///
    /// Mapping:
    /// ~~~
    /// "accountType" => value
    /// ~~~
    ///
    /// - Since: Sprint 1
    private enum CodingKeys: String, CodingKey {
        case value = "accountType"
    }
}

/// The *REST* property wrapper.
///
/// Allows to send post and get requests with bearer authentication and values that are automatically
/// type marshalled.
///
/// Property access:
/// ~~~
/// struct Fruit: Codable {
///     let name: String
///     let size: Int
///     let color: String
/// }
///
/// ...
///
/// @Rest(path: "fruitoftheday") var fruit: Fruit = Fruit(name: "strawberry", size: 3, color: "red")
///
/// ...
///
/// print(fruit) // wrappedValue access
/// print($fruit.wrappedValue) // wrappedValue access
///
/// print($fruit) // projectedValue (aka query) access
///
/// print($fruit.projectedValue) // nested projectedValue (aka binding) access
/// print($fruit.name) // nested projectedValue (aka binding) property (aka property binding) access
/// ~~~
///
/// Usage for authentication:
/// ~~~
/// struct Account: Codable {
///     var email: String
///     var password: String
/// }
///
/// struct SomeView: View {
///     @Rest(path: "signin", bearer: false) var account: Account = Account(email: "", password: "")
///
///     var body: some View {
///         TextField("Email placeholder", text: self.$account.email)
///         TextField("Password placeholder", text: self.$account.password)
///         Button("Sign In") {
///             self.$account>?.success { ... }
///         }
///     }
/// }
/// ~~~
///
/// Usage for get request:
/// ~~~
/// struct Fruit: Codable {
///     let name: String
///     let size: Int
///     let color: String
/// }
///
/// struct SomeView: View {
///     @Rest(path: "fruitoftheday") var fruit: Fruit = Fruit(name: "strawberry", size: 3, color: "red")
///
///     var body: some View {
///         Text(fruit.name)
///             .onAppear { self.$fruit>?.sink { _ in } }
///     }
/// }
/// ~~~
///
/// Usage for get request with query parameters:
/// ~~~
/// struct Fruit: Codable {
///     let name: String
///     let size: Int
///     let color: String
/// }
/// struct Fruits: Codable {
///     var values: [Fruit] = []
/// }
///
/// struct SomeView: View {
///     @Rest(path: "fruits", params: ["limit": 10]) var fruits: Fruits = Fruits()
///
///     var body: some View {
///         Text(fruits.values[0].name)
///             .onAppear { self.$fruits>?.sink { _ in } }
///    }
/// }
/// ~~~
///
/// Usage for get request with property key path:
/// ~~~
/// struct Fruit: Codable {
///     let name: String
///     let size: Int
///     let color: String
/// }
/// struct Fruits: ParentCodable {
///     var values: [Fruit] = []
///
///     static func wrap(child: [Fruit]) -> Self {
///         return Fruits(values: child)
///     }
/// }
///
/// struct SomeView: View {
///     @Rest(path: "fruits", parent: Fruits.self, prop: \.values) var fruits: [Fruit] = []
///
///     var body: some View {
///         Text(fruits[0].name)
///             .onAppear { self.$fruits>?.sink { _ in } }
///     }
/// }
/// ~~~
///
/// Usage for get request with query parameters and property key path:
/// ~~~
/// struct Fruit: Codable {
///     let name: String
///     let size: Int
///     let color: String
/// }
/// struct Fruits: ParentCodable {
///     var values: [Fruit] = []
///
///     static func wrap(child: [Fruit]) -> Self {
///         return Fruits(values: child)
///     }
/// }
///
/// struct SomeView: View {
///     @Rest(path: "fruits", params: ["limit": 10], parent: Fruits.self, prop: \.values) var fruits: [Fruit] = []
///
///     var body: some View {
///         Text(fruits[0].name)
///             .onAppear { self.$fruits>?.sink { _ in } }
///     }
/// }
/// ~~~
///
/// Usage for post request with existing value:
/// ~~~
/// struct Account: Codable {
///     var email: String
///     var password: String
/// }
///
/// struct SomeView: View {
///     @Rest(path: "signup") var account: Account = Account(email: "", password: "")
///
///     var body: some View {
///         TextField("Email placeholder", text: self.$account.email)
///         TextField("Password placeholder", text: self.$account.password)
///         Button("Sign Up") {
///             self.$account<!.success { ... }
///         }
///     }
/// }
/// ~~~
///
/// Usage for post request with new value:
/// ~~~
/// struct Account: Codable {
///     var email: String
///     var password: String
/// }
///
/// struct SomeView: View {
///     @Rest(path: "signup") var account: Account = Account(email: "", password: "")
///
///     var body: some View {
///         TextField("Email placeholder", text: self.$account.email)
///         TextField("Password placeholder", text: self.$account.password)
///         Button("Sign Up") {
///             (self.$account <- someNewAccount).success { ... }
///         }
///     }
/// }
/// ~~~
///
/// # References
/// [Property Wrapper](https://docs.swift.org/swift-book/LanguageGuide/Properties.html#ID617)
///
/// [Key Paths](https://github.com/apple/swift-evolution/blob/master/proposals/0161-key-paths.md)
///
/// - Requires: The parent type `Parent` and the value type `Value` must conform to protocol `Codable`.
///
/// - Since: Sprint 1
@propertyWrapper public struct Rest<Parent, Value> where Parent: Codable, Value: Codable {
    /// The mutable reference to the wrapped property value.
    private var _wrappedValue: RestMutableValueReference<Value>
    /// The query associated with this wrapped property.
    private var query: RestQueryImpl<Parent, Value>

    /// Implicitly used computed property for `@propertyWrapper`.
    ///
    /// Provides access to the wrapped value.
    ///
    /// Usage:
    /// ~~~
    /// struct Fruit: Codable {
    ///     let name: String
    ///     let size: Int
    ///     let color: String
    /// }
    ///
    /// ...
    ///
    /// @Rest(path: "fruitoftheday") var fruit: Fruit = Fruit(name: "strawberry", size: 3, color: "red")
    ///
    /// ...
    ///
    /// print(fruit) // wrappedValue access
    /// print(fruit.name) // wrappedValue property access
    /// ~~~
    ///
    /// - Since: Sprint 1
    public var wrappedValue: Value {
        get {
            _wrappedValue.value
        }
        set {
            _wrappedValue.update(with: newValue)
        }
    }

    /// Creates a *Rest* property wrapper instance.
    ///
    /// Usage:
    /// ~~~
    /// @Rest(path: "somePath") var someProp: SomeType = SomeType(...)
    /// ~~~
    ///
    /// - Parameters:
    ///   - wrappedValue: The value wrapped by this property wrapper.
    ///   - path: The url request path component.
    ///   - bearer: True if the bearer token should be send as part of the request.
    ///
    /// - Returns: A new *Rest* property wrapper instance.
    ///
    /// - Since: Sprint 1
    public init(wrappedValue: Value, path: String, bearer: Bool = true) where Parent == Value {
        self._wrappedValue = RestMutableValueReference(value: wrappedValue)
        self.query = RestQueryImpl(self._wrappedValue, RestQueryMetadata(urlComponents: RestURLComponents(path: path), bearer: bearer, parent: Parent.self, prop: \Value.self))
    }

    /// Creates a *Rest* property wrapper instance.
    ///
    /// Usage:
    /// ~~~
    /// @Rest(path: "somePath", params: ["someKey": someValue]) var someProp: SomeType = SomeType(...)
    /// ~~~
    ///
    /// - Parameters:
    ///   - wrappedValue: The value wrapped by this property wrapper.
    ///   - path: The url request path component.
    ///   - params: The url request query parameter component.
    ///   - bearer: True if the bearer token should be send as part of the request.
    ///
    /// - Returns: A new *Rest* property wrapper instance.
    ///
    /// - Since: Sprint 1
    public init<ParamKey, ParamValue>(wrappedValue: Value, path: String, params: [ParamKey: ParamValue], bearer: Bool = true) where Parent == Value, ParamKey: CustomStringConvertible, ParamValue: CustomStringConvertible {
        self._wrappedValue = RestMutableValueReference(value: wrappedValue)
        self.query = RestQueryImpl(self._wrappedValue, RestQueryMetadata(urlComponents: RestURLComponents(path: path, params: Dictionary(uniqueKeysWithValues: params.map { (key: $0.key.description, value: $0.value.description) })), bearer: bearer, parent: Parent.self, prop: \Value.self))
    }

    /// Creates a *Rest* property wrapper instance.
    ///
    /// Usage:
    /// ~~~
    /// @Rest(path: "somePath", parent: SomeParentType.self, prop: \.somePropKey) var someProp: SomeType = SomeType(...)
    /// ~~~
    ///
    /// - Parameters:
    ///   - wrappedValue: The value wrapped by this property wrapper.
    ///   - path: The url request path component.
    ///   - bearer: True if the bearer token should be send as part of the request.
    ///   - parent: The parent type conforming to the `ParentCodable` protocol.
    ///   - prop: The property to be extracted from the parent type.
    ///
    /// - Returns: A new *Rest* property wrapper instance.
    ///
    /// - Since: Sprint 1
    public init(wrappedValue: Value, path: String, bearer: Bool = true, parent: Parent.Type, prop: KeyPath<Parent, Value>) where Parent: ParentCodable, Parent.ChildCodable == Value {
        self._wrappedValue = RestMutableValueReference(value: wrappedValue)
        self.query = RestQueryImpl(self._wrappedValue, RestQueryMetadata(urlComponents: RestURLComponents(path: path), bearer: bearer, parent: parent, prop: prop))
    }

    /// Creates a *Rest* property wrapper instance.
    ///
    /// Usage:
    /// ~~~
    /// @Rest(path: "somePath", params: ["someKey": someValue], parent: SomeParentType.self, prop: \.somePropKey) var someProp: SomeType = SomeType(...)
    /// ~~~
    ///
    /// - Parameters:
    ///   - wrappedValue: The value wrapped by this property wrapper.
    ///   - path: The url request path component.
    ///   - params: The url request query parameter component.
    ///   - bearer: True if the bearer token should be send as part of the request.
    ///   - parent: The parent type conforming to the `ParentCodable` protocol.
    ///   - prop: The property to be extracted from the parent type.
    ///
    /// - Returns: A new *Rest* property wrapper instance.
    ///
    /// - Since: Sprint 1
    public init<ParamKey, ParamValue>(wrappedValue: Value, path: String, params: [ParamKey: ParamValue], bearer: Bool = true, parent: Parent.Type, prop: KeyPath<Parent, Value>) where ParamKey: CustomStringConvertible, ParamValue: CustomStringConvertible, Parent: ParentCodable, Parent.ChildCodable == Value {
        self._wrappedValue = RestMutableValueReference(value: wrappedValue)
        self.query = RestQueryImpl(self._wrappedValue, RestQueryMetadata(urlComponents: RestURLComponents(path: path, params: Dictionary(uniqueKeysWithValues: params.map { (key: $0.key.description, value: $0.value.description) })), bearer: bearer, parent: parent, prop: prop))
    }

    /// Implicitly used computed property for `@propertyWrapper`.
    ///
    /// Provides access to the associated query. Visibility is set to `fileprivate` to restrict
    /// query mutations.
    ///
    /// Usage:
    /// ~~~
    /// struct Fruit: Codable {
    ///     let name: String
    ///     let size: Int
    ///     let color: String
    /// }
    ///
    /// ...
    ///
    /// @Rest(path: "fruitoftheday") var fruit: Fruit = Fruit(name: "strawberry", size: 3, color: "red")
    ///
    /// ...
    ///
    /// print($fruit) // projectedValue (aka query) access
    ///
    /// print($fruit.projectedValue) // nested projectedValue (aka binding) access
    /// print($fruit.name) // nested projectedValue (aka binding) property (aka property binding) access
    /// ~~~
    ///
    /// - Since: Sprint 1
    public var projectedValue: RestQueryImpl<Parent, Value> {
        get {
            query
        }
        set {
            query = newValue
        }
    }
}

/// The result type of a *REST* query.
///
/// This result type contains a reference to the query as well as a future that will resolve to the new value or an error.
///
/// - Requires: `QueryType` must conform to protocol `RestQuery`.
///
/// - Since: Sprint 1
public final class RestQueryResult<QueryType> where QueryType: RestQuery {
    /// The query associated with this result.
    public let query: QueryType
    /// The query result as a future that will resolve to the new value or an error.
    public let result: Future<QueryType.QueryValue, RestQueryError>

    /// Creates a *RestQueryResult* instance.
    ///
    /// - Parameters:
    ///   - query: The associated query.
    ///   - result: A future that will resolve to the new value or an error.
    ///
    /// - Returns: A new *RestQueryType* instance.
    ///
    /// - Since: Sprint 1
    fileprivate init(query: QueryType, result: Future<QueryType.QueryValue, RestQueryError>) {
        self.query = query
        self.result = result
    }

    /// Attaches a subscriber with closure-based behavior.
    ///
    /// Upon completion the `success(received:)` operator’s received closure indicates the successful termination of the query result.
    ///
    /// Usage:
    /// ~~~
    /// someQueryResult.success {
    ///     ...
    /// }
    /// ~~~
    ///
    /// This method creates and returns a subscriber.
    ///
    /// - Parameter received: The closure to execute on successful completion.
    ///
    /// - Since: Sprint 1
    public func success(received: @escaping (() -> Void)) {
        self.query.cancellable.insert(result.sink(receiveCompletion: { completion in
            internalDebugPrint("Success: ", completion)
            guard case .failure = completion else {
                received()
                return
            }
        }, receiveValue: { _ in }))
    }

    /// Attaches a subscriber with closure-based behavior.
    ///
    /// Upon completion the `failure(received:)` operator’s received closure indicates the failure of the query.
    ///
    /// Usage:
    /// ~~~
    /// someQueryResult.failure {
    ///     ...
    /// }
    /// ~~~
    ///
    /// This method creates and returns a subscriber.
    ///
    /// - Parameter received: The closure to execute on failed completion.
    ///
    /// - Since: Sprint 1
    public func failure(received: @escaping (() -> Void)) {
        self.query.cancellable.insert(result.sink(receiveCompletion: { completion in
            internalDebugPrint("Failure: ", completion)
            if case .failure = completion {
                received()
            }
        }, receiveValue: { _ in }))
    }

    /// Attaches a subscriber with closure-based behavior.
    ///
    /// Use `sink(receiveCompletion:receiveValue:)` to observe values received by the future publisher and process them using a closure you specify.
    /// Upon completion the `sink(receiveCompletion:receiveValue:)` operator’s receiveCompletion closure indicates the successful termination of the stream.
    ///
    /// Usage:
    /// ~~~
    /// someQueryResult.sink(receiveCompletion: { completion in
    ///     ...
    /// }, receiveValue: { value in
    ///     ...
    /// })
    /// ~~~
    ///
    /// This method creates the subscriber and immediately requests an unlimited number of values, prior to returning the subscriber.
    ///
    /// - Parameters:
    ///   - receiveCompletion: The closure to execute on completion.
    ///   - receiveValue: The closure to execute on receipt of a value.
    ///
    /// - Since: Sprint 1
    public func sink(receiveCompletion: @escaping ((Subscribers.Completion<RestQueryError>) -> Void), receiveValue: @escaping ((QueryType.QueryValue) -> Void)) {
        self.query.cancellable.insert(result.sink(receiveCompletion: receiveCompletion, receiveValue: receiveValue))
    }

    /// Attaches a subscriber with closure-based behavior.
    ///
    /// Use `sink(receiveValue:)` to observe values received by the future publisher and process them using a closure you specify.
    ///
    /// Usage:
    /// ~~~
    /// someQueryResult.sink { value in
    ///     ...
    /// }
    /// ~~~
    ///
    /// This method creates the subscriber and immediately requests an unlimited number of values, prior to returning the subscriber.
    ///
    /// - Parameter receiveValue: The closure to execute on receipt of a value.
    ///
    /// - Since: Sprint 1
    public func sink(receiveValue: @escaping ((QueryType.QueryValue) -> Void)) {
        self.query.cancellable.insert(result.sink(receiveCompletion: { completion in
            internalDebugPrint("Sink Ignored Completion: ", completion)
        }, receiveValue: receiveValue))
    }
}

/// The protocol all rest query implementations should conform to.
///
/// - Requires: The parent type `QueryParent` and the value type `QueryValue` must conform
///  to protocol `Codable`.
///
/// - Since: Sprint 1
@dynamicMemberLookup public protocol RestQuery: AnyObject where QueryParent: Codable, QueryValue: Codable {
    /// The parent type.
    associatedtype QueryParent
    /// The value type.
    associatedtype QueryValue

    /// The metadata associated with this query.
    var metadata: RestQueryMetadata<QueryParent, QueryValue> { get set }
    /// The value wrapped by the property attached to this query.
    var wrappedValue: QueryValue { get set }
    /// A binding for the wrapped value.
    var projectedValue: Binding<QueryValue> { get }

    var cancellable: Set<AnyCancellable> { get set }

    /// Creates a copy of the provided current query with a different params component.
    ///
    /// - Parameters:
    ///   - current: The current query.
    ///   - params: The new params for the query copy.
    ///
    /// - Since: Sprint 1
    init(current: Self, params: [String: String])

    /// Sends a get request based on the metadata associated with this query.
    ///
    /// - Parameter prop: True if the property key should be used on the parent request result to unwrap the value.
    ///
    /// - Returns: A future that will resolve to the request result or an error.
    ///
    /// - Since: Sprint 1
    func get(prop: Bool) -> Future<QueryValue, RestQueryError>

    /// Sends a post request based on the metadata associated with this query.
    ///
    /// - Parameters:
    ///     - prop: True if the property key should be used on the parent request result to unwrap the value.
    ///     - newValue: The value that should be sent as the body part of the `HTTPS` request.
    ///
    /// - Returns: A future that will resolve to the new value or an error.
    ///
    /// - Since: Sprint 1
    func post(prop: Bool, newValue: QueryValue) -> Future<QueryValue, RestQueryError>
}

/// Provides an implicit non overridable default subscript operator implementation to allow dynamic member lookup to
/// map the type properties to bindings.
///
/// - Since: Sprint 1
public extension RestQuery {
    /// Lazily creates and stores bindings for the properties of the request return type as part of the query metadata.
    ///
    /// - Parameter dynamicMember: The read-only property key path.
    ///
    /// - Since: Sprint 1
    subscript<Subject>(dynamicMember keyPath: KeyPath<QueryValue, Subject>) -> Binding<Subject> {
        if self.metadata.bindings.keys.contains(keyPath) {
            // swiftlint:disable force_cast
            return self.metadata.bindings[keyPath] as! Binding<Subject>
            // swiftlint:enable force_cast
        } else {
            let binding = Binding(get: {
                self.wrappedValue[keyPath: keyPath]
            }, set: { _ in
                print("[REST] \(self.wrappedValue) does not allow to update property!")
            })
            self.metadata.bindings[keyPath] = binding
            return binding
        }
    }

    /// Lazily creates and stores bindings for the properties of the request return type as part of the query metadata.
    ///
    /// - Parameter dynamicMember: The writable property key path.
    ///
    /// - Since: Sprint 1
    subscript<Subject>(dynamicMember keyPath: WritableKeyPath<QueryValue, Subject>) -> Binding<Subject> {
        if self.metadata.bindings.keys.contains(keyPath) {
            // swiftlint:disable force_cast
            return self.metadata.bindings[keyPath] as! Binding<Subject>
            // swiftlint:enable force_cast
        } else {
            let binding = Binding(get: {
                self.wrappedValue[keyPath: keyPath]
            }, set: { [self] newValue in
                self.wrappedValue[keyPath: keyPath] = newValue
            })
            self.metadata.bindings[keyPath] = binding
            return binding
        }
    }
}

/// The *RestQuery* error type.
///
/// - Since: Sprint 1
public enum RestQueryError: Error {
    /// The query is missing an operation implementation.
    case missingImplementation
    /// The dynamic dispatch failed to invoke the typesafe wrap method successfully.
    case dynamicWrapDispatch
    /// The construction of the request URL failed.
    case url(URLError)
    /// The request result did not contain a response.
    case urlReponse
    /// The status code was not in the expected range.
    case statusCode(Int)
    /// The bearer token is missing for request with implicit or explicit `@Rest(bearer: true)`.
    case bearer
    /// The decoding of the query result or bearer token failed.
    case decode(DecodingError)
    /// The encoding of the query content failed.
    case encode(EncodingError)
    /// Some other issue.
    case other(Error)
}

/// The query parameter concatenation operator.
///
/// - Since: Sprint 1
infix operator ++: MultiplicationPrecedence

/// The query parameter concatenation operator.
///
/// Creates a copy of the on the left hand side provided query with an additional set of query parameters.
///
/// Usage:
/// ~~~
/// let newQuery = $someQuery ++ ["someKey": someValue]
/// ~~~
///
/// - Parameters:
///   - lhs: The query instance the new copy will be based on.
///   - rhs: The additional set of query parameters.
///
/// - Returns: The query copy with additional query parameters.
///
/// - Requires: The query type `Query` must conform to the `RestQuery` protocol.
/// `Query.QueryParent` and `Query.QueryValue` should equal `Parent` and `Value`.
/// `ParamKey` and `ParamValue` must conform to both `CustomStringConvertible`
/// and `Hashable`.
///
/// ### Reference
/// [Custom Operators](https://docs.swift.org/swift-book/LanguageGuide/AdvancedOperators.html#ID46)
///
/// - Since: Sprint 1
public func ++ <Query, Parent, Value, ParamKey, ParamValue>(lhs: Query, rhs: [ParamKey: ParamValue]) -> Query where Query: RestQuery, Query.QueryParent == Parent, Query.QueryValue == Value, ParamKey: CustomStringConvertible, ParamKey: Hashable, ParamValue: CustomStringConvertible, ParamValue: Hashable {
    rhs.isEmpty ? lhs : Query(current: lhs, params: lhs.metadata.urlComponents.params.merging(Dictionary(uniqueKeysWithValues: rhs.map { (key: $0.key.description, value: $0.value.description) })) { (_, new) in new })
}

/// The query get request operator.
///
/// - Since: Sprint 1
postfix operator >?

/// The query get request operator.
///
/// Makes a get request that will either resolve to the request result or an error.
///
/// Usage:
/// ~~~
/// $someQuery>?.sink { ... }
/// ~~~
///
/// - Parameter query: The query instance used to make the get request.
///
/// - Returns: A future that will resolve to the request result or an error.
///
/// - Requires: The query type `Query` must conform to the `RestQuery` protocol.
/// `Query.QueryParent` and `Query.QueryValue` should equal `Parent` and `Value`.
///
/// ### Reference
/// [Custom Operators](https://docs.swift.org/swift-book/LanguageGuide/AdvancedOperators.html#ID46)
///
/// - Since: Sprint 1
public postfix func >? <Query, Value>(query: Query) -> RestQueryResult<Query> where Query: RestQuery, Query.QueryParent == Query.QueryValue, Value == Query.QueryValue {
    RestQueryResult(query: query, result: query.get(prop: false))
}

/// The query get request operator.
///
/// Makes a get request that will either resolve to the extracted property value of the request result
/// or an error.
///
/// Usage:
/// ~~~
/// $someQuery>?.sink { ... }
/// ~~~
///
/// - Parameter query: The query instance used to make the get request.
///
/// - Returns: A future that will resolve to the extrated property value of the request result or an error.
///
/// - Requires: The query type `Query` must conform to the `RestQuery` protocol.
/// `Query.QueryParent` must conform to the `ParentCodable` protocol.
/// `Query.QueryParent.ChildCodable` must equal `Query.QueryValue`
/// `Query.QueryValue` must equal `Value`.
///
/// ### Reference
/// [Custom Operators](https://docs.swift.org/swift-book/LanguageGuide/AdvancedOperators.html#ID46)
///
/// - Since: Sprint 1
public postfix func >? <Query, Value>(query: Query) -> RestQueryResult<Query> where Query: RestQuery, Query.QueryParent: ParentCodable, Query.QueryParent.ChildCodable == Query.QueryValue, Query.QueryValue == Value {
    RestQueryResult(query: query, result: query.get(prop: true))
}

/// The query post currently wrapped value operator.
///
/// - Since: Sprint 1
postfix operator <!

/// The query post currently wrapped value operator.
///
/// Makes a post request that will resolve to the new value or an error.
///
/// Usage:
/// ~~~
/// $someQuery<!.sink { ... }
/// ~~~
///
/// - Parameter query: The query instance used to make the post request.
///
/// - Returns: A future that will resolve to the new value or an error.
///
/// - Requires: The query type `Query` must conform to the `RestQuery` protocol.
/// `Query.QueryParent` and `Query.QueryValue` should equal `Parent` and `Value`.
///
/// ### Reference
/// [Custom Operators](https://docs.swift.org/swift-book/LanguageGuide/AdvancedOperators.html#ID46)
///
/// - Since: Sprint 1
public postfix func <! <Query, Value>(query: Query) -> RestQueryResult<Query> where Query: RestQuery, Query.QueryParent == Query.QueryValue, Value == Query.QueryValue {
    RestQueryResult(query: query, result: query.post(prop: false, newValue: query.wrappedValue))
}

/// The query post currently wrapped value operator.
///
/// Makes a post request that will resolve to the new value or an error.
///
/// Usage:
/// ~~~
/// $someQuery<!.sink { ... }
/// ~~~
///
/// - Parameter query: The query instance used to make the post request.
///
/// - Returns: A future that will resolve to the new value or an error.
///
/// - Requires: The query type `Query` must conform to the `RestQuery` protocol.
/// `Query.QueryParent` must conform to the `ParentCodable` protocol.
/// `Query.QueryParent.ChildCodable` must equal `Query.QueryValue`
/// `Query.QueryValue` must equal `Value`.
///
/// ### Reference
/// [Custom Operators](https://docs.swift.org/swift-book/LanguageGuide/AdvancedOperators.html#ID46)
///
/// - Since: Sprint 1
public postfix func <! <Query, Value>(query: Query) -> RestQueryResult<Query> where Query: RestQuery, Query.QueryParent: ParentCodable, Query.QueryParent.ChildCodable == Query.QueryValue, Query.QueryValue == Value {
    RestQueryResult(query: query, result: query.post(prop: true, newValue: query.wrappedValue))
}

/// The query post new value operator.
///
/// - Since: Sprint 1
infix operator <-: MultiplicationPrecedence

/// The query post new value operator.
///
/// Makes a post request that will resolve to the new value or an error.
///
/// Usage:
/// ~~~
/// ($someQuery <- someNewValue).sink { ... }
/// ~~~
///
/// - Parameters:
///   - lhs: The query instance used to make the post request.
///   - rhs: The value that should be sent as the body part of the `HTTPS` request.
///
/// - Returns: A future that will resolve to the new value or an error.
///
/// - Requires: The query type `Query` must conform to the `RestQuery` protocol.
/// `Query.QueryParent` and `Query.QueryValue` should equal `Parent` and `Value`.
///
/// ### Reference
/// [Custom Operators](https://docs.swift.org/swift-book/LanguageGuide/AdvancedOperators.html#ID46)
///
/// - Since: Sprint 1
public func <- <Query, Value>(lhs: Query, rhs: Value) -> RestQueryResult<Query> where Query: RestQuery, Query.QueryParent == Query.QueryValue, Value == Query.QueryValue {
    RestQueryResult(query: lhs, result: lhs.post(prop: false, newValue: rhs))
}

/// The query post new value operator.
///
/// Makes a post request that will resolve to the new value or an error.
///
/// Usage:
/// ~~~
/// ($someQuery <- someNewValue).sink { ... }
/// ~~~
///
/// - Parameters:
///   - lhs: The query instance used to make the post request.
///   - rhs: The value that should be send as the body part of the `HTTPS` request.
///
/// - Returns: A future that will resolve to the new value or an error.
///
/// - Requires: The query type `Query` must conform to the `RestQuery` protocol.
/// `Query.QueryParent` must conform to the `ParentCodable` protocol.
/// `Query.QueryParent.ChildCodable` must equal `Query.QueryValue`.
/// `Query.QueryValue` must equal `Value`.
///
/// ### Reference
/// [Custom Operators](https://docs.swift.org/swift-book/LanguageGuide/AdvancedOperators.html#ID46)
///
/// - Since: Sprint 1
public func <- <Query, Value>(lhs: Query, rhs: Value) -> RestQueryResult<Query> where Query: RestQuery, Query.QueryParent: ParentCodable, Query.QueryParent.ChildCodable == Query.QueryValue, Query.QueryValue == Value {
    RestQueryResult(query: lhs, result: lhs.post(prop: true, newValue: rhs))
}

/// The query results depdents on operator.
///
/// - Since: Sprint 1
infix operator ->>: AdditionPrecedence

/// The query results depdents on operator.
///
/// Joins two queries on the success of the left-hand side. If the operation succeeds, the right-hand side is triggered.
///
/// Usage:
/// ~~~
/// ($someQuery <- someValue ->> $someDependentQuery<!).success {
///     ...
/// }
/// ~~~
///
/// - Parameters:
///   - lhs: The query instance used to make the dependable request.
///   - rhs: The dependent query that's triggered on the success of the left-hand side.
///
/// - Returns: A future that will resolve to the new value or an error.
///
/// - Requires: The query type `Query` must conform to the `RestQuery` protocol.
///
/// ### Reference
/// [Custom Operators](https://docs.swift.org/swift-book/LanguageGuide/AdvancedOperators.html#ID46)
///
/// - Since: Sprint 1
public func ->> <Query>(lhs: RestQueryResult<Query>, rhs: RestQueryResult<Query>) -> RestQueryResult<Query> where Query: RestQuery {
    RestQueryResult(query: rhs.query, result: Future { promise in
        lhs.success {
            rhs.query.cancellable.insert(rhs.result.sink(receiveCompletion: { completion in
                internalDebugPrint("Depends On Completion: ", completion)
                if case .failure(let error) = completion {
                    promise(.failure(error))
                }
            }, receiveValue: { value in
                internalDebugPrint("Depends On Success: ", value)
                promise(.success(value))
            }))
        }
    })
}

/// The nested `nil` in `Binding` coalescing operator.
///
/// - Since: Sprint 1
infix operator ??

/// The nested `nil` in `Binding` coalescing operator.
///
/// Usage:
/// ~~~
/// let someBindingWithDefault = someBindingWithOptional ?? someDefaultValue
/// ~~~
///
/// - Parameters:
///   - lhs: The binding containing an optional value.
///   - rhs: The default value if the nested optional is none.
///
/// - Returns: A binding wrapping the original instance providing fallback logic.
///
/// ### Reference
/// [Custom Operators](https://docs.swift.org/swift-book/LanguageGuide/AdvancedOperators.html#ID46)
///
/// - Since: Sprint 1
public func ?? <Value>(lhs: Binding<Value?>, rhs: Value) -> Binding<Value> {
    return Binding(get: {
        lhs.wrappedValue ?? rhs
    }, set: { value in
        lhs.wrappedValue = value
    })
}

/// Allows to configure the *REST API*.
///
/// Usage:
/// ~~~
/// RestConfiguration.host = "someHost"
/// ~~~
///
/// - Since: Sprint 1
public final class RestConfiguration {
    /// The URL host component.
    public static var host: String = ""
    /// Is debug session?
    public static var debug: Bool = false
    /// Should the requests be mocked?
    fileprivate static var mock: Bool = false
    /// The default request provider (*URLSession.shared*) or a mocked variation.
    ///
    /// - Since: Sprint 1
    public static var requestProvider: RestRequestProvider {
        mock ? mockRequestProvider : URLSession.shared
    }
    /// The mocked request provider.
    fileprivate static var mockRequestProvider: RestRequestProvider = URLSession.shared
}

/// Only prints the given message in debug mode.
///
/// - Parameters:
///   -  message: The message to print.
///   - value: The typed value part of the message.
///
/// - Since: Sprint 1
fileprivate func internalDebugPrint<T>(_ message: String, _ value: T) {
    if RestConfiguration.debug {
        print("[RestfulPropertyKit] \(message)")
        debugPrint(value)
    }
}

// swiftlint:disable identifier_name

/// [EXPERIMENTAL] Mocks all requests made in the block closure using the given *RestRequestProvider*.
///
/// Usage:
/// ~~~
/// restMock(someMockProvider) {
///     someQuery <- someValue
/// }
/// ~~~
///
/// - Parameters:
///   - provider: The mock request provider.
///   - block: The computation using mocked requests.
///
/// - Returns: The result of the computation inside of the closure.
///
/// - Since: Sprint 1
public func _restMock<Result>(with provider: RestRequestProvider, block: (() -> Result)) -> Result {
    RestConfiguration.mockRequestProvider = provider
    RestConfiguration.mock = true
    let result = block()
    RestConfiguration.mock = false
    return result
}
// swiftlint:enable identifier_name

/// This structure constructs URLs according to RFC 3986.
///
/// ### Reference
/// [RFC 3986](https://tools.ietf.org/html/rfc3986)
///
/// - Since: Sprint 1
public struct RestURLComponents {
    /// The URL scheme component.
    public let scheme: String
    /// The URL host component.
    public let host: String
    /// The URL path component.
    public let path: String
    /// The URL params component.
    public let params: [String: String]

    /// Creates a *RestURLComponents* instance.
    ///
    /// - Parameters:
    ///   - scheme: The URL scheme component.
    ///   - host: The URL host component.
    ///   - path: The URL path component.
    ///   - params: The URL params component.
    ///
    /// - Returns: The created *RestURLComponents* instance.
    ///
    /// - Since: Sprint 1
    fileprivate init(scheme: String, host: String, path: String, params: [String: String]) {
        self.scheme = scheme
        self.host = host
        self.path = path
        self.params = params
    }

    /// Creates a *RestURLComponents* instance.
    ///
    /// - Parameters:
    ///   - path: The URL path component.
    ///   - params: The URL params component.
    ///
    /// - Returns: The created *RestURLComponents* instance.
    ///
    /// - Since: Sprint 1
    fileprivate init(path: String, params: [String: String] = [:]) {
        self.init(scheme: "https", host: RestConfiguration.host, path: path, params: params)
    }

    /// Creates a copy of the provided current URL components with a different params component.
    ///
    /// - Parameters:
    ///   - current: The current URL components.
    ///   - params: The new params for the URL components copy.
    ///
    /// - Returns: The copy with a different params component.
    ///
    /// - Since: Sprint 1
    fileprivate init(current: RestURLComponents, params: [String: String]) {
        self.init(scheme: current.scheme, host: current.host, path: current.path, params: params)
    }

    /// Returns a constructed URL from its constituent parts.
    ///
    /// - Parameter params: Should the constructed query include parameters.
    ///
    /// - Returns: The constructed URL.
    ///
    /// - Since: Sprint 1
    public func url(params: Bool = true) -> URL {
        var components = URLComponents()

        components.scheme = self.scheme
        components.host = self.host
        components.path = self.path.starts(with: "/") ? self.path : "/" + self.path
        components.queryItems = params ? self.params.map {
            URLQueryItem(name: $0.key, value: $0.value)
        } : nil

        return components.url!
    }
}

/// A representation of the *RestQuery* metadata.
///
/// - Since: Sprint 1
public struct RestQueryMetadata<Parent, Value> {
    /// The URL components of the requests.
    public let urlComponents: RestURLComponents
    /// Should the bearer token be send as part of the requests.
    public let bearer: Bool
    /// The parent type.
    fileprivate let parent: Parent.Type
    /// The parent type keypath to extract the requested value.
    public let prop: KeyPath<Parent, Value>
    /// The bindings to the parent type properties.
    fileprivate var bindings: [PartialKeyPath<Value>: Any]
    /// The bearer token used for authorization.
    public var token: RestBearerToken? {
        if let token = UserDefaults.standard.string(forKey: "bearerToken"), let type = UserDefaults.standard.string(forKey: "bearerType") {
            return RestBearerToken(value: token, type: RestBearerType(value: type))
        }
        return nil
    }

    /// Creates a *RestQueryMetadata* instance.
    ///
    /// - Parameters:
    ///   - urlComponents: The URL components of the query.
    ///   - bearer: Should the bearer token be send as part of the query.
    ///   - parent: The parent type of the query result type.
    ///   - prop: The parent type keypath to extract the query result value.
    ///   - bindings: The bindings to the parent type properties.
    ///
    /// - Returns: The created *RestQueryMetadata* instance.
    ///
    /// - Since: Sprint 1
    fileprivate init(urlComponents: RestURLComponents, bearer: Bool, parent: Parent.Type, prop: KeyPath<Parent, Value>, bindings: [PartialKeyPath<Value>: Any] = [:]) {
        self.urlComponents = urlComponents
        self.bearer = bearer
        self.parent = parent
        self.prop = prop
        self.bindings = bindings
    }

    /// Creates a copy of the provided query metadata with a different URL params component.
    ///
    /// - Parameters:
    ///   - current: The current query metadata.
    ///   - params: The new URL params for the query metadata copy.
    ///
    /// - Returns: The copy with a different params component.
    ///
    /// - Since: Sprint 1
    fileprivate init(current: RestQueryMetadata, params: [String: String]) {
        self.init(urlComponents: RestURLComponents(current: current.urlComponents, params: params), bearer: current.bearer, parent: current.parent, prop: current.prop, bindings: current.bindings)
    }
}

/// An implementation of *RestQuery* protocol.
///
/// - Requires: The parent type `QueryParent` and the value type `QueryValue` must conform
///  to protocol `Codable`.
///
/// - Since: Sprint 1
public final class RestQueryImpl<Parent, Value>: RestQuery where Parent: Codable, Value: Codable {
    /// The internal mutable wrapped value reference.
    private var _wrappedValue: RestMutableValueReference<Value>
    /// A binding for the wrapped value.
    public var projectedValue: Binding<Value>
    /// The metadata associated with this query.
    public var metadata: RestQueryMetadata<Parent, Value>
    /// The `Set` of cancellable query requests.
    public var cancellable: Set<AnyCancellable> = Set(minimumCapacity: 1)

    /// The value wrapped by the property attached to this query.
    ///
    /// - Since: Sprint 1
    public var wrappedValue: Value {
        get {
            _wrappedValue.value
        }
        set {
            _wrappedValue.update(with: newValue)
        }
    }

    /// Creates a *RestQueryImpl* instance.
    ///
    /// - Parameters:
    ///   - wrappedValue: The mutable reference to the wrapped value.
    ///   - metadata: The metadata associated with this query.
    ///
    /// - Returns: The created *RestQueryImpl* instance.
    ///
    /// - Since: Sprint 1
    fileprivate init(_ wrappedValue: RestMutableValueReference<Value>, _ metadata: RestQueryMetadata<Parent, Value>) {
        self._wrappedValue = wrappedValue
        self.metadata = metadata
        self.projectedValue = Binding(get: {
            wrappedValue.value
        }, set: { newValue in
            wrappedValue.update(with: newValue)
        })
    }

    /// Creates a copy of the provided current query with a different params component.
    ///
    /// - Parameters:
    ///   - current: The current query.
    ///   - params: The new params for the query copy.
    ///
    /// - Returns: The created copy *RestQueryImpl* instance.
    ///
    /// - Since: Sprint 1
    required convenience public init(current: RestQueryImpl<Parent, Value>, params: [String: String]) {
        self.init(current._wrappedValue, RestQueryMetadata(current: current.metadata, params: params))
    }

    /// Sends a get request based on the metadata associated with this query.
    ///
    /// - Parameter prop: True if the property key should be used on the parent request result to unwrap the value.
    ///
    /// - Returns: A future that will resolve to the request result or an error.
    ///
    /// - Since: Sprint 1
    public func get(prop: Bool) -> Future<Value, RestQueryError> {
        prop ? getValueWithPath() : getValue()
    }

    /// Creates and returns a publisher for a get request.
    ///
    /// Constructs the query URL, sets the necessary `HTTP` header fields and creates a publisher with error handling.
    ///
    /// - Returns: The created request publisher.
    ///
    /// - Since: Sprint 1
    private func requestGet() -> AnyPublisher<Parent, RestQueryError> {
        var urlRequest = URLRequest(url: self.metadata.urlComponents.url())
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")

        internalDebugPrint("Object Parent Type: ", self.metadata.parent)
        internalDebugPrint("Object Property: ", self.metadata.prop)
        internalDebugPrint("Object Bindings: ", self.metadata.bindings)
        internalDebugPrint("Send Bearer: ", self.metadata.bearer)
        internalDebugPrint("Request URL: ", self.metadata.urlComponents.url())

        if self.metadata.bearer && self.metadata.token != nil {
            urlRequest.setValue("Bearer \(self.metadata.token!.value)", forHTTPHeaderField: "Authorization")
            internalDebugPrint("Authorization: Bearer ", self.metadata.token?.value)
        } else {
            return Fail(error: .bearer).eraseToAnyPublisher()
        }

        urlRequest.httpMethod = "GET"
        internalDebugPrint("Http Method: ", urlRequest.httpMethod)

        return RestConfiguration.requestProvider.restRequestPublisher(for: urlRequest)
            .map { $0.data }
            .decode(type: metadata.parent, decoder: JSONDecoder())
            .mapError { error in
                switch error {
                case let decodeError as DecodingError:
                    return .decode(decodeError)
                case let urlError as URLError:
                    return .url(urlError)
                default:
                    return .other(error)
                }
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    /// Transforms the URL response of a post request to the provided value or an error.
    ///
    /// This method is also responsible for verifying the status code and storing returned bearer tokens.
    ///
    /// - Parameters:
    ///   - newValue: The new value send as part of the post request.
    ///   - bearer: Should the bearer token be send as part of the query.
    ///
    /// - Returns: A closure returning the request `Result` containing the new value or an error.
    ///
    /// - Since: Sprint 1
    private func postValueTransform(newValue: Value, bearer: Bool) -> (Result<(data: Data, reponse: URLResponse), RestQueryError>) -> Result<Value, RestQueryError> {
        { result in
            switch result {
            case let .success((data, response)):
                guard let castReponse = response as? HTTPURLResponse else {
                    return .failure(.urlReponse)
                }

                guard (200 ... 299) ~= castReponse.statusCode else {
                    internalDebugPrint("Http Reponse Body: ", String(data: data, encoding: .utf8))

                    return .failure(.statusCode(castReponse.statusCode))
                }

                if !bearer {
                    do {
                        let token = try JSONDecoder().decode(RestBearerToken.self, from: data)

                        internalDebugPrint("Received Bearer Token: ", token.value)

                        UserDefaults.standard.set(token.value, forKey: "bearerToken")
                        UserDefaults.standard.set(token.type.value, forKey: "bearerType")
                    } catch let error {
                        return .failure(error is DecodingError ? .decode((error as? DecodingError)!) : .other(error))
                    }
                }

                return .success(newValue)
            case let .failure(error):
                return .failure(error)
            }
        }
    }

    /// Creates and returns a publisher for a post request.
    ///
    /// Constructs the query URL, sets the necessary `HTTP` header fields and creates a publisher with error handling.
    ///
    /// - Returns: The created request publisher.
    ///
    /// - Since: Sprint 1
    private func requestPost(newValue: Value, body: Parent) -> AnyPublisher<Result<Value, RestQueryError>, Never> {
        var urlRequest = URLRequest(url: self.metadata.urlComponents.url(params: false))
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")

        internalDebugPrint("Object Parent Type: ", self.metadata.parent)
        internalDebugPrint("Object Property: ", self.metadata.prop)
        internalDebugPrint("Object Bindings: ", self.metadata.bindings)
        internalDebugPrint("Send Bearer: ", self.metadata.bearer)
        internalDebugPrint("Request URL: ", self.metadata.urlComponents.url(params: false))

        if self.metadata.bearer && self.metadata.token != nil {
            urlRequest.setValue("Bearer \(self.metadata.token!.value)", forHTTPHeaderField: "Authorization")
            internalDebugPrint("Authorization: Bearer ", self.metadata.token?.value)
        }

        urlRequest.httpMethod = "POST"
        internalDebugPrint("Http Method: ", urlRequest.httpMethod)

        do {
            try urlRequest.httpBody = JSONEncoder().encode(body)

            if let body = urlRequest.httpBody {
                internalDebugPrint("Http Body: ", String(decoding: body, as: UTF8.self))
            } else {
                internalDebugPrint("Missing Request.httpBody for POST", "")
            }
        } catch let error {
            return Just(.failure(error is DecodingError ? .decode((error as? DecodingError)!) : .other(error)))
                .eraseToAnyPublisher()
        }

        return RestConfiguration.requestProvider.restRequestPublisher(for: urlRequest)
            .map { $0 }
            .mapError { RestQueryError.url($0) }
            .convertToResult()
            .map(postValueTransform(newValue: newValue, bearer: self.metadata.bearer))
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    /// Creates and returns a publisher for a get request that extracts the value.
    ///
    /// Constructs the query URL, sets the necessary `HTTP` header fields, creates a publisher with error handling and extracts the value.
    ///
    /// - Returns: A future that will resolve to the request result or an error.
    ///
    /// - Since: Sprint 1
    private func getValue() -> Future<Value, RestQueryError> {
        return Future { promise in
            self.requestGet().map {
                // swiftlint:disable force_cast
                $0 as! Value
                // swiftlint:enable force_cast
            }
            .convertAssignResolveAndStore(value: self._wrappedValue, promise: promise, in: &self.cancellable)
        }
    }

    /// Creates and returns a publisher for a get request that extracts the value from the parent type instance.
    ///
    /// Constructs the query URL, sets the necessary `HTTP` header fields, creates a publisher with error handling and extracts the value.
    ///
    /// - Returns: A future that will resolve to the request result or an error.
    ///
    /// - Since: Sprint 1
    private func getValueWithPath() -> Future<Value, RestQueryError> {
        return Future { promise in
            self.requestGet().map { $0[keyPath: self.metadata.prop] }
                .convertAssignResolveAndStore(value: self._wrappedValue, promise: promise, in: &self.cancellable)
        }
    }

    /// Sends a post request based on the metadata associated with this query.
    ///
    /// - Parameters:
    ///     - prop: True if the property key should be used on the parent request result to unwrap the value.
    ///     - newValue: The value that should be send as the body part of the `HTTPS` request.
    ///
    /// - Returns: A future that will resolve to the new value or an error.
    ///
    /// - Since: Sprint 1
    public func post(prop: Bool, newValue: Value) -> Future<Value, RestQueryError> {
        prop ? postValueWithPath(newValue: newValue) : postValue(newValue: newValue)
    }

    /// Creates and returns a publisher for a post request that extracts the value.
    ///
    /// Constructs the query URL, sets the necessary `HTTP` header fields, creates a publisher with error handling and extracts the value.
    ///
    /// - Returns: A future that will resolve to the request result or an error.
    ///
    /// - Since: Sprint 1
    private func postValue(newValue: Value) -> Future<Value, RestQueryError> {
        return Future { promise in
            // swiftlint:disable force_cast
            self.requestPost(newValue: newValue, body: newValue as! Parent)
                .assignResolveAndStore(value: self._wrappedValue, promise: promise, in: &self.cancellable)
            // swiftlint:enable force_cast
        }
    }

    /// Creates and returns a publisher for a post request that extracts the value from the parent type instance.
    ///
    /// Constructs the query URL, sets the necessary `HTTP` header fields, creates a publisher with error handling and extracts the value.
    ///
    /// - Returns: A future that will resolve to the request result or an error.
    ///
    /// - Since: Sprint 1
    private func postValueWithPath(newValue: Value) -> Future<Value, RestQueryError> {
        return Future { promise in
            if let dispatch = self.metadata.parent as? ParentCodableDynamicDispatch.Type {
                // swiftlint:disable force_cast
                self.requestPost(newValue: newValue, body: dispatch.dynamicWrap(child: newValue) as! Parent)
                    .assignResolveAndStore(value: self._wrappedValue, promise: promise, in: &self.cancellable)
                // swiftlint:enable force_cast
            } else {
                promise(.failure(.dynamicWrapDispatch))
            }
        }
    }
}

// swiftlint:enable line_length
// swiftlint:enable file_length
