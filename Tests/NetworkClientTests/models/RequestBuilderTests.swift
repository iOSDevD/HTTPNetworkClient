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

struct RequestBuilderTests {
    
    @Test("Building request, adds base path, headers and query parameters")
    func testRequestBuilderHeader() async throws {
        let url = try #require(URL(string: "https://abcd-test.com"))
        
        let builder = RequestBuilder(baseURL: url, defaultHeaders: ["Authorization": "Bearer 12345"])
        
        struct FakeGetUserRequest: APIRequest {
            typealias Response = String
            var path: String { "/user" }
            var method: HTTPMethod { .GET }
            var headers: [String: String]? { localHeader }
            var queryItems: [URLQueryItem]? { [.init(name: "name", value: "john")] }
            var body: Data? { nil }
            
            private var localHeader: [String: String]
            init(_ inputTestIdentifier: String) {
                localHeader = ["X-Test-ID": inputTestIdentifier]
            }
        }
        
        let sut = try builder.build(FakeGetUserRequest("abcd"))
        
        #expect(sut.url?.absoluteString == "https://abcd-test.com/user?name=john", "Complete URL with base path and query items")
        
        let outputHeaders = try #require(sut.allHTTPHeaderFields?.keys, "HTTP headers can't be empty as there are default headers and test headers")
        
        let outputHeaderSet = Set<String>(outputHeaders)
        
        #expect(outputHeaderSet == Set(["X-Test-ID", "Authorization"]), "Both Default hader and test header should be present in the output headers")
    }
    
    @Test("Building request, overrides the common header key")
    func testRequestOverridesHeaders() async throws {
        let url = try #require(URL(string: "https://abcd-test.com"))

        let builder = RequestBuilder(baseURL: url, defaultHeaders: ["Authorization": "Bearer 12345"])

        struct FakeGetUserRequest: APIRequest {
            typealias Response = String
            var path: String { "/user" }
            var method: HTTPMethod { .GET }
            var headers: [String: String]? { ["Authorization": "Bearer 12345New"] }
            var queryItems: [URLQueryItem]? { [.init(name: "name", value: "john")] }
            var body: Data? { nil }
        }

        let sut = try builder.build(FakeGetUserRequest())

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
            "Only single header should be present. Default headers (\"Authorization\") passed during init should override when passed with build."
        )

        #expect(
            sut.allHTTPHeaderFields?["Authorization"] == "Bearer 12345New",
            "Authorization value should be overridden and must be 'Bearer 12345New' not 'Bearer 12345'"
        )
    }
    
}
