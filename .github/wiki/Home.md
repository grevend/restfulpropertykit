# Types

  - [RestValueReference](https://github.com/grevend/restfulpropertykit/wiki/RestValueReference):
    Class-based value wrapper to easily reference the value and avoid copying the data in certain
    contexts.
  - [RestMutableValueReference](https://github.com/grevend/restfulpropertykit/wiki/RestMutableValueReference):
    The mutable counterpart of *RestValueReference\<Value\>*. Subclassing is not possible since it is
    final and the value setter in *RestValueReference* is *fileprivate*.
  - [RestQueryResult](https://github.com/grevend/restfulpropertykit/wiki/RestQueryResult):
    The result type of a *REST* query.
  - [RestConfiguration](https://github.com/grevend/restfulpropertykit/wiki/RestConfiguration):
    Allows to configure the *REST API*.
  - [RestQueryImpl](https://github.com/grevend/restfulpropertykit/wiki/RestQueryImpl):
    An implementation of *RestQuery* protocol.
  - [RestQueryError](https://github.com/grevend/restfulpropertykit/wiki/RestQueryError):
    The *RestQuery* error type.
  - [RestBearerToken](https://github.com/grevend/restfulpropertykit/wiki/RestBearerToken):
    A *Decodable* and *Encodable* bearer token representation with an attached type.
  - [RestBearerType](https://github.com/grevend/restfulpropertykit/wiki/RestBearerType):
    A *Decodable* and *Encodable* bearer type representation.
  - [Rest](https://github.com/grevend/restfulpropertykit/wiki/Rest):
    The *REST* property wrapper.
  - [RestURLComponents](https://github.com/grevend/restfulpropertykit/wiki/RestURLComponents):
    This structure constructs URLs according to RFC 3986.
  - [RestQueryMetadata](https://github.com/grevend/restfulpropertykit/wiki/RestQueryMetadata):
    A representation of the *RestQuery* metadata.

# Protocols

  - [NoArgInit](https://github.com/grevend/restfulpropertykit/wiki/NoArgInit):
    Opt-in conformance for structures with no argument initializer.
  - [ParentCodable](https://github.com/grevend/restfulpropertykit/wiki/ParentCodable):
    A type that can wrap a child *Codable* value into a representation of itself.
  - [ParentCodableDynamicDispatch](https://github.com/grevend/restfulpropertykit/wiki/ParentCodableDynamicDispatch):
    ParentCodableDynamicDispatch is a weakly typed wrapper to dispatch wrap method
    calls to a *ParentCodable* object.
  - [RestRequestProvider](https://github.com/grevend/restfulpropertykit/wiki/RestRequestProvider):
    The protocol used for all *REST* request provider implementations.
  - [RestQuery](https://github.com/grevend/restfulpropertykit/wiki/RestQuery):
    The protocol all rest query implementations should conform to.

# Global Functions

  - [\_restMock(with:​block:​)](https://github.com/grevend/restfulpropertykit/wiki/_restMock\(with:block:\)):
    \[EXPERIMENTAL\] Mocks all requests made in the block closure using the given *RestRequestProvider*.

# Operators

  - [???](https://github.com/grevend/restfulpropertykit/wiki/%3F%3F%3F):
    The nested `nil` in `Binding` coalescing operator.
  - [\<-](https://github.com/grevend/restfulpropertykit/wiki/%3C-):
    The query post new value operator.
  - [-\>\>](https://github.com/grevend/restfulpropertykit/wiki/-%3E%3E):
    The query results depdents on operator.
  - [++](https://github.com/grevend/restfulpropertykit/wiki/++):
    The query parameter concatenation operator.
  - [\>?](https://github.com/grevend/restfulpropertykit/wiki/%3E%3F):
    The query get request operator.
  - [\<\!](https://github.com/grevend/restfulpropertykit/wiki/%3C!):
    The query post currently wrapped value operator.

# Extensions

  - [URLSession](https://github.com/grevend/restfulpropertykit/wiki/URLSession)
