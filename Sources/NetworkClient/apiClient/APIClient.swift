//  APIClient.swift
//  HTTPNetworkClient
//
//  Created by iOSDevD on 4/7/26.
//  Copyright (c) 2026 iOSDevD
//  Licensed under the MIT License. See LICENSE file in the project root.
//

import Foundation

/// A type that sends `APIRequest` values and returns decoded responses.
///
/// `APIClient` abstracts the transport layer for typed network requests.
/// Conforming types are responsible for building and executing the underlying
/// request, validating the response, and decoding the response payload into
/// the request's associated `Response` type.
public protocol APIClient {
    /// Sends an `APIRequest` and decodes its response.
    ///
    /// - Parameter request: The typed request to execute.
    /// - Returns: The decoded response model defined by `request`.
    /// - Throws: An error if request construction fails, the network request
    ///   cannot be completed, the response is invalid, or decoding fails.
    func send<T: APIRequest>(_ request: T) async throws -> T.Response
}
