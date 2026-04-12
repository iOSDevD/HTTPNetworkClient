//  HTTPAPIClientTestsSuccess.swift
//  HTTPNetworkClient
//
//  Created by iOSDevD on 4/7/26.
//  Copyright (c) 2026 iOSDevD
//  Licensed under the MIT License. See LICENSE file in the project root.
//

import Foundation
import Testing
@testable import HTTPNetworkClient

@Suite("HTTP Client Tests - Success")
struct HTTPAPIClientTestsSuccess {
    @Test func testHTTPClientSuccess() async throws {
    
        struct User: Decodable, Equatable {
            let id: Int
            let name: String
        }

        let inputTestIdentifier = "testIdSuccess-\(UUID().uuidString)"
        struct GetUserRequest: APIRequest {
            typealias Response = User
            var path: String { "/user" }
            var method: HTTPMethod { .GET }
            var headers: [String : String]? { localHeader }
            var queryItems: [URLQueryItem]? { nil }
            var body: Data? { nil }
            private var localHeader: [String: String]
            init(_ inputTestIdentifier: String){
                localHeader = ["X-Test-ID": inputTestIdentifier]
            }
        }

        // Configure URLSession with our MockURLProtocol
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: config)

        let builder = RequestBuilder(baseURL: URL(string: "https://example.com")!, defaultHeaders: ["Accept": "application/json"]) 
        let client = HTTPAPIClient(builder: builder, session: session)

        let request = GetUserRequest(inputTestIdentifier)
        
        // Stub a successful 200 response
        let json = try loadJSON("userSuccess")
        MockURLProtocol.setHandler(for: inputTestIdentifier) { request in
            let url = request.url ?? URL(string: "https://example.com/user")!
            let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: ["Content-Type": "application/json"])!
            return (response, json)
        }

        let user = try await client.send(request)
        #expect(user.id == 42)
        #expect(user.name == "Ada")
    }
}
