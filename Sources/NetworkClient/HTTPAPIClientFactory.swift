//  HTTPAPIClientFactory.swift
//  HTTPNetworkClient
//
//  Created by iOSDevD on 4/7/26.
//  Copyright (c) 2026 iOSDevD
//  Licensed under the MIT License. See LICENSE file in the project root.
//

import Foundation

/// A simple public factory for constructing HTTPAPIClient instances
/// using session object and decoder
public enum HTTPAPIClientFactory {
    
    /// Creates an `APIClient` configured with the provided request builder,
    /// session, and decoder.
    ///
    /// - Parameters:
    ///   - builder: The `RequestBuilder` used to convert `APIRequest` values
    ///     into `URLRequest` instances.
    ///   - session: The `URLSession` used to execute requests. Defaults to
    ///     `URLSession.shared`.
    ///   - decoder: The `JSONDecoder` used to decode successful responses.
    ///     Defaults to a new `JSONDecoder` instance.
    /// - Returns: A concrete `APIClient` implementation backed by
    ///   `HTTPAPIClient`.
    public static func make(builder: RequestBuilder, session: URLSession = .shared, decoder: JSONDecoder = .init()) -> APIClient {
        return HTTPAPIClient(builder: builder, session: session, decoder: decoder)
    }
}
