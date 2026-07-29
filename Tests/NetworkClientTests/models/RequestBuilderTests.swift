//  RequestBuilderTests.swift
//  HTTPNetworkClient
//
//  Created by iOSDevD on 4/10/26.
//  Copyright (c) 2026 iOSDevD
//  Licensed under the MIT License. See LICENSE file in the project root.
//

import Foundation
import Testing
@testable import HTTPNetworkClient

private struct HeaderGetUserRequest: APIRequest {
    typealias Response = String

    let testIdentifier: String

    var path: String { "/user" }
    var method: HTTPMethod { .GET }
    var headers: [String: String]? { ["X-Test-ID": testIdentifier] }
    var queryItems: [URLQueryItem]? { [.init(name: "name", value: "john")] }
    var body: Data? { nil }
}

private struct OverridingGetUserRequest: APIRequest {
    typealias Response = String

    var path: String { "/user" }
    var method: HTTPMethod { .GET }
    var headers: [String: String]? { ["Authorization": "Bearer 12345New"] }
    var queryItems: [URLQueryItem]? { [.init(name: "name", value: "john")] }
    var body: Data? { nil }
}

struct RequestBuilderTests {
    @Test("Building request, adds base path, headers and query parameters")
    func testRequestBuilderHeader() async throws {
        let url = try #require(URL(string: "https://abcd-test.com"))
        let builder = RequestBuilder(
            baseURL: url,
            defaultHeaders: ["Authorization": "Bearer 12345"]
        )

        let sut = try builder.build(HeaderGetUserRequest(testIdentifier: "abcd"))

        #expect(
            sut.url?.absoluteString == "https://abcd-test.com/user?name=john",
            "Complete URL with base path and query items"
        )

        let outputHeaders = try #require(
            sut.allHTTPHeaderFields?.keys,
            "HTTP headers can't be empty as there are default headers and test headers"
        )

        let outputHeaderSet = Set<String>(outputHeaders)

        #expect(
            outputHeaderSet == Set(["X-Test-ID", "Authorization"]),
            "Both default and test headers should be present in the output headers"
        )
    }
    
    @Test("Building request, overrides the common header key")
    func testRequestOverridesHeaders() async throws {
        let url = try #require(URL(string: "https://abcd-test.com"))

        let builder = RequestBuilder(baseURL: url, defaultHeaders: ["Authorization": "Bearer 12345"])

        let sut = try builder.build(OverridingGetUserRequest())

        #expect(
            sut.url?.absoluteString == "https://abcd-test.com/user?name=john",
            "Complete URL with base path and query items"
        )

        let outputHeaders = try #require(
            sut.allHTTPHeaderFields?.keys,
            "HTTP headers can't be empty atleast one header should be present"
        )

        let outputHeaderSet = Set<String>(outputHeaders)

        #expect(
            outputHeaderSet == Set(["Authorization"]),
            "Only the Authorization header should be present after it is overridden."
        )

        #expect(
            sut.allHTTPHeaderFields?["Authorization"] == "Bearer 12345New",
            "Authorization should be overridden with the request value."
        )
    }
}
