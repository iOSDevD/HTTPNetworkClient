//
//  APIRequest.swift
//  HTTPNetworkClient
//
//  Created by iOSDevD on 4/7/26.
//  Copyright (c) 2026 iOSDevD
//  Licensed under the MIT License. See LICENSE file in the project root.
//

import Foundation

/// A protocol that describes a typed API request.
///
/// Conformers provide the components necessary to construct a `URLRequest`,
/// including HTTP method, path, headers, query items, and an optional body.
/// The associated `Response` type defines the expected shape of the decoded
/// response payload for this request.
public protocol APIRequest {
    /// The decodable type expected from the server for this request.
    associatedtype Response: Decodable
    
    /// The relative path to append to the base URL (e.g., "/trips").
    var path: String { get }
    /// The HTTP method to use when issuing the request.
    var method: HTTPMethod { get }
    /// Optional additional headers to include with the request.
    var headers: [String: String]? { get }
    /// Optional query parameters to append to the URL.
    var queryItems: [URLQueryItem]? { get }
    /// Optional HTTP body for the request, typically JSON-encoded data.
    var body: Data? { get }
}


/// Supported HTTP methods for API requests.
public enum HTTPMethod: String {
    case GET, POST
}
