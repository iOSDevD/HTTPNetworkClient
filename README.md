# HTTPNetworkClient

`HTTPNetworkClient` provides a lightweight way to communicate with a REST API using typed requests and async/await.

## Overview

The package is built around three core types:

- `APIRequest` describes an endpoint and its expected response type.
- `RequestBuilder` creates `URLRequest` values using a shared base URL and default headers.
- `HTTPAPIClientFactory` creates an `APIClient` backed by `HTTPAPIClient`.

## Using `HTTPAPIClientFactory`

### 1. Create a response model

```swift
import Foundation

struct User: Decodable {
    let id: Int
    let name: String
    let email: String
}
```

### 2. Define an `APIRequest`

```swift
import Foundation
import HTTPNetworkClient

struct GetUserRequest: APIRequest {
    typealias Response = User

    let userID: Int

    var path: String { "/users/\(userID)" }
    var method: HTTPMethod { .GET }
    var headers: [String: String]? { nil }
    var queryItems: [URLQueryItem]? { nil }
    var body: Data? { nil }
}
```

### 3. Create a client with `HTTPAPIClientFactory`

```swift
import Foundation
import HTTPNetworkClient

let builder = RequestBuilder(
    baseURL: URL(string: "https://api.example.com")!,
    defaultHeaders: [
        "Accept": "application/json",
        "Authorization": "Bearer <token>"
    ]
)

let client = HTTPAPIClientFactory.make(builder: builder)
```

### 4. Send the request

```swift
let user = try await client.send(GetUserRequest(userID: 42))
print(user.name)
```

## Custom session and decoder

`HTTPAPIClientFactory` also lets you inject a custom `URLSession` and `JSONDecoder`.

```swift
import Foundation
import HTTPNetworkClient

let builder = RequestBuilder(
    baseURL: URL(string: "https://api.example.com")!,
    defaultHeaders: ["Accept": "application/json"]
)

let configuration = URLSessionConfiguration.default
configuration.timeoutIntervalForRequest = 30

let decoder = JSONDecoder()
decoder.keyDecodingStrategy = .convertFromSnakeCase

let client = HTTPAPIClientFactory.make(
    builder: builder,
    session: URLSession(configuration: configuration),
    decoder: decoder
)
```
