//
//  MockURLProtocol.swift
//  HTTPNetworkClient
//
//  Created by iOSDevD on 4/7/26.
//  Copyright (c) 2026 iOSDevD
//  Licensed under the MIT License. See LICENSE file in the project root.
//

import Foundation

// Local URLProtocol to stub responses
// Usage:
// Set handlers per test using the "X-Test-ID" header to isolate responses.
// e.g. MockURLProtocol.setHandler(for: "myTestId") { request in ... }
// and add header `X-Test-ID: myTestId` to your URLRequest to select the handler.
final class MockURLProtocol: URLProtocol {
    typealias Handler = (URLRequest) throws -> (URLResponse, Data)

    private static let handlersLock = NSLock()
    nonisolated(unsafe) private static var handlers: [String: Handler] = [:]

    static func setHandler(for testID: String, handler: @escaping Handler) {
        handlersLock.lock()
        defer { handlersLock.unlock() }
        handlers[testID] = handler
    }

    static func handler(for testID: String) -> Handler? {
        handlersLock.lock()
        defer { handlersLock.unlock() }
        return handlers[testID]
    }

    static func removeHandler(for testID: String) {
        handlersLock.lock()
        defer { handlersLock.unlock() }
        handlers.removeValue(forKey: testID)
    }

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        let testId = request.value(forHTTPHeaderField: "X-Test-ID") ?? "default"
        guard let handler = Self.handler(for: testId) else {
            client?.urlProtocol(self, didFailWithError: URLError(.badServerResponse))
            return
        }

        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}
