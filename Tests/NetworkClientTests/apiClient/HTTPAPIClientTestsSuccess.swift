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

private struct SuccessUser: Decodable, Equatable {
    let id: Int
    let name: String
}

private struct SuccessGetUserRequest: APIRequest {
    typealias Response = SuccessUser

    let testIdentifier: String

    var path: String { "/user" }
    var method: HTTPMethod { .GET }
    var headers: [String: String]? { ["X-Test-ID": testIdentifier] }
    var queryItems: [URLQueryItem]? { nil }
    var body: Data? { nil }
}

@Suite("HTTP Client Tests - Success")
struct HTTPAPIClientTestsSuccess {
    @Test func testHTTPClientSuccess() async throws {
        let inputTestIdentifier = "testIdSuccess-\(UUID().uuidString)"

        // Configure URLSession with our MockURLProtocol
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: config)

        let builder = RequestBuilder(
            baseURL: URL(string: "https://example.com")!,
            defaultHeaders: ["Accept": "application/json"]
        )
        let client = HTTPAPIClient(builder: builder, session: session)

        let request = SuccessGetUserRequest(testIdentifier: inputTestIdentifier)

        // Stub a successful 200 response
        let json = try loadJSON("userSuccess")
        MockURLProtocol.setHandler(for: inputTestIdentifier) { request in
            let response = try makeSuccessResponse(for: request)
            return (response, json)
        }

        let user = try await client.send(request)
        #expect(user.id == 42)
        #expect(user.name == "Ada")
    }
}

private func makeSuccessResponse(for request: URLRequest) throws -> HTTPURLResponse {
    guard let url = request.url else {
        throw URLError(.badURL)
    }

    guard let response = HTTPURLResponse(
        url: url,
        statusCode: 200,
        httpVersion: nil,
        headerFields: ["Content-Type": "application/json"]
    ) else {
        throw URLError(.cannotParseResponse)
    }

    return response
}
