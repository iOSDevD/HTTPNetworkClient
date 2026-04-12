//
//  APIError.swift
//  HTTPNetworkClient
//
//  Created by iOSDevD on 4/7/26.
//  Copyright (c) 2026 iOSDevD
//  Licensed under the MIT License. See LICENSE file in the project root.
//

import Foundation

/// Errors that can occur while executing and decoding an API request.
///
/// `APIError` groups the most common failure modes produced by the HTTP
/// client, including invalid responses, transport failures, HTTP status code
/// failures, and response decoding issues.
enum APIError: Error, Sendable {
    /// The server response could not be interpreted as a valid HTTP response.
    case invalidResponse
    
    /// Decoding the response body into the expected model failed.
    ///
    /// - Parameter Error: The underlying decoding error.
    case decodingError(Error)
    
    /// The request failed before a valid HTTP response was received.
    ///
    /// - Parameter Error: The underlying networking error.
    case networkError(Error)
    
    /// The server returned a `5xx` HTTP status code.
    ///
    /// - Parameters:
    ///   - statusCode: The HTTP status code returned by the server.
    ///   - data: The raw response body, if one was received.
    case serverError(statusCode: Int, data: Data?)
    
    /// The server returned a `4xx` HTTP status code.
    ///
    /// - Parameters:
    ///   - statusCode: The HTTP status code returned by the server.
    ///   - data: The raw response body, if one was received.
    case clientError(statusCode: Int, data: Data?)
}
