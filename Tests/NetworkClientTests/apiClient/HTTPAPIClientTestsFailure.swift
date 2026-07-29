//  HTTPAPIClientTestsFailure.swift
//  HTTPNetworkClient
//
//  Created by iOSDevD on 4/8/26.
//  Copyright (c) 2026 iOSDevD
//  Licensed under the MIT License. See LICENSE file in the project root.
//

import Foundation
import Testing
@testable import HTTPNetworkClient

struct FailureGetUserRequest: APIRequest {
    typealias Response = String

    let testIdentifier: String

    var path: String { "/user" }
    var method: HTTPMethod { .GET }
    var headers: [String: String]? { ["X-Test-ID": testIdentifier] }
    var queryItems: [URLQueryItem]? { nil }
    var body: Data? { nil }
}

private final class FakeURLResponse: URLResponse, @unchecked Sendable {
    override init(
        url: URL,
        mimeType: String? = nil,
        expectedContentLength: Int = 0,
        textEncodingName: String? = nil
    ) {
        super.init(
            url: url,
            mimeType: mimeType,
            expectedContentLength: expectedContentLength,
            textEncodingName: textEncodingName
        )
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

@Suite("HTTP Client Tests - Failure")
struct HTTPAPIClientTestsFailure {
    @Test("Client Error Codes", arguments: 400...499)
    func testClientFailure(clientErrorCode: Int) async throws {
        let inputTestIdentifier = "testClientError-\(UUID().uuidString)"
        let client = await makeClientForTestId(inputTestIdentifier)
        let request = await makeTestRequestForTestId(inputTestIdentifier)

        MockURLProtocol.setHandler(for: inputTestIdentifier) { request in
            let dummyData = Data()
            let response = try makeFailureResponse(
                for: request,
                statusCode: clientErrorCode
            )
            return (response, dummyData)
        }

        let error = await #expect(throws: APIError.self) {
            try await client.send(request)
        }
        
        if case let .clientError(statusCode: code, data: _) = error {
            #expect(code == clientErrorCode)
        } else {
            Issue.record("Expected .clientError but got \(String(describing: error))")
        }
    }
    @Test("Server Error Codes", arguments: 500...599 )
    func testServerFailure(serverErrorCode: Int) async throws {
        let inputTestIdentifier = "testServerError-\(UUID().uuidString)"
        
        let client = await makeClientForTestId(inputTestIdentifier)
        
        let request = await makeTestRequestForTestId(inputTestIdentifier)
        
        MockURLProtocol.setHandler(for: inputTestIdentifier) { request in
            let dummyData = Data()
            let response = try makeFailureResponse(
                for: request,
                statusCode: serverErrorCode
            )
            return (response, dummyData)
        }
        
        let error = await #expect(throws: APIError.self) {
            try await client.send(request)
        }
        
        if case let .serverError(statusCode: code, data: _) = error {
            #expect(code == serverErrorCode)
        } else {
            Issue.record("Expected .serverError but got \(String(describing: error))")
        }
    }
    @Test("Unsupported Error code")
    func testInvalidResponse() async throws {
        let inputTestIdentifier = "testClientError-\(UUID().uuidString)"
        
        let client = await makeClientForTestId(inputTestIdentifier)
       
        let request = await makeTestRequestForTestId(inputTestIdentifier)
        
        MockURLProtocol.setHandler(for: inputTestIdentifier) { request in
            let dummyData = Data()
            let response = try makeFailureResponse(for: request, statusCode: 600)
            return (response, dummyData)
        }
        
        let error = await #expect(throws: APIError.self) {
            try await client.send(request)
        }
        
        #expect({
            if case .invalidResponse = error { true } else { false }
        }())

    }
    @Test("Network Error code")
    func testNetworkError() async throws {
        let inputTestIdentifier = "testNetworkError-\(UUID().uuidString)"
        
        let client = await makeClientForTestId(inputTestIdentifier)
       
        let request = await makeTestRequestForTestId(inputTestIdentifier)
        
        // mockResponseId does not match inputTestIdentifier, MockURLProtocol
        // will throw URLError.badServerResponse
        let mockResponseId = inputTestIdentifier + "Test"
        MockURLProtocol.setHandler(for: mockResponseId) { request in
            let dummyData = Data()
            let response = try makeFailureResponse(for: request, statusCode: 600)
            return (response, dummyData)
        }
        
        let error = await #expect(throws: APIError.self) {
            try await client.send(request)
        }
        
        #expect({
            if case let .networkError(underlying) = error {
                // Optionally assert the specific URLError.Code if you propagate it
                if let urlError = underlying as? URLError {
                    return urlError.code == .badServerResponse
                }
                return true // At least it’s a networkError
            } else {
                return false
            }
        }())

    }
    
    @Test("Non HTTPURLResponse")
    func testNonHTTPURLResponse() async throws {
        let inputTestIdentifier = "testNonHTTPURLResponse-\(UUID().uuidString)"
        
        let client = await makeClientForTestId(inputTestIdentifier)
       
        let request = await makeTestRequestForTestId(inputTestIdentifier)
        
        MockURLProtocol.setHandler(for: inputTestIdentifier) { request in
            guard let url = request.url else {
                throw URLError(.badURL)
            }
            let dummyData = Data()
            let response = FakeURLResponse(url: url)
            return (response, dummyData)
        }
        
        let error = await #expect(throws: APIError.self) {
            try await client.send(request)
        }
        
        #expect({
            if case .invalidResponse = error { true } else { false }
        }())

    }
    
    @Test("Decoding Error")
    func testClientDecodingError() async throws {
        let inputTestIdentifier = "testServerError-\(UUID().uuidString)"
        
        let client = await makeClientForTestId(inputTestIdentifier)
        
        let request = await makeTestRequestForTestId(inputTestIdentifier)
        
        // Stub a successful 200 response
        let json = try loadJSON("userDecodingError")
        
        MockURLProtocol.setHandler(for: inputTestIdentifier) { request in
            let response = try makeFailureResponse(for: request, statusCode: 200)
            return (response, json)
        }
        
        let error = await #expect(throws: APIError.self) {
            try await client.send(request)
        }
        
        if case let .decodingError(decodingError) = error, case let DecodingError.typeMismatch(type, _) = decodingError {
            #expect(type is String.Type)
        } else {
            Issue.record("Expected .decodingError but got \(String(describing: error))")
        }
    }
}

extension HTTPAPIClientTestsFailure {
    func makeClientForTestId(_ inputTestIdentifier: String) async -> HTTPAPIClient {
        // Configure URLSession with our MockURLProtocol
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: config)
        
        let builder = RequestBuilder(
            baseURL: URL(string: "https://example.com")!,
            defaultHeaders: ["Accept": "application/json"]
        )
        return HTTPAPIClient(builder: builder, session: session)
    }
    
    func makeTestRequestForTestId(_ inputTestIdentifier: String) async -> FailureGetUserRequest {
        FailureGetUserRequest(testIdentifier: inputTestIdentifier)
    }
}

private func makeFailureResponse(
    for request: URLRequest,
    statusCode: Int
) throws -> HTTPURLResponse {
    guard let url = request.url else {
        throw URLError(.badURL)
    }

    guard let response = HTTPURLResponse(
        url: url,
        statusCode: statusCode,
        httpVersion: nil,
        headerFields: ["Content-Type": "application/json"]
    ) else {
        throw URLError(.cannotParseResponse)
    }

    return response
}
