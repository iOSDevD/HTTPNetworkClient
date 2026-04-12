//  RequestBuilder.swift
//  HTTPNetworkClient
//
//  Created by iOSDevD on 4/7/26.
//  Copyright (c) 2026 iOSDevD
//  Licensed under the MIT License. See LICENSE file in the project root.
//

import Foundation

/// Builds `URLRequest` instances from types conforming to `APIRequest`.
///
/// Provide a `baseURL` and any `defaultHeaders` common to your API. Then call
/// `build(_:)` with a concrete `APIRequest` to produce a configured `URLRequest`.
public struct RequestBuilder {
    
    /// The base URL of the API (e.g., https://api.example.com).
    public let baseURL: URL
    /// Headers applied to every request, overridden by request-specific headers.
    public let defaultHeaders: [String: String]
    
    public init(baseURL: URL, defaultHeaders: [String : String]) {
        self.baseURL = baseURL
        self.defaultHeaders = defaultHeaders
    }
    
    /// Constructs a `URLRequest` from an `APIRequest`.
    ///
    /// - Parameter request: The typed API request describing the path, method, headers, query items, and body.
    /// - Throws: An error if URL components cannot be resolved.
    /// - Returns: A configured `URLRequest` ready to be sent.
    func build<T: APIRequest>(_ request: T) throws -> URLRequest {
        var url = baseURL.appendingPathComponent(request.path)
        
        if let queryItems = request.queryItems {
            var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            components?.queryItems = queryItems
            url = components?.url ?? url
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        
        // Merge headers
        let headers = defaultHeaders.merging(request.headers ?? [:]) { _, new in new }
        headers.forEach { urlRequest.setValue($1, forHTTPHeaderField: $0) }
        
        urlRequest.httpBody = request.body
        
        return urlRequest
    }
}
