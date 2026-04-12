//  HTTPAPIClient.swift
//  HTTPNetworkClient
//
//  Created by iOSDevD on 4/7/26.
//  Copyright (c) 2026 iOSDevD
//  Licensed under the MIT License. See LICENSE file in the project root.
//

import Foundation

final class HTTPAPIClient: APIClient {
    
    private let session: URLSession
    private let builder: RequestBuilder
    private let decoder: JSONDecoder
    
    init(builder: RequestBuilder, session: URLSession = .shared, decoder: JSONDecoder = .init()) {
        self.session = session
        self.builder = builder
        self.decoder = decoder
    }
    
    func send<T: APIRequest>(_ request: T) async throws -> T.Response {
        
        let urlRequest = try builder.build(request)
        do {
            let (data, response) = try await session.data(for: urlRequest)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            let statusCode = httpResponse.statusCode
            
            switch statusCode {
            case 200...299:
                do {
                    return try decoder.decode(T.Response.self, from: data)
                } catch {
                    throw APIError.decodingError(error)
                }
            case 400...499:
                throw APIError.clientError(statusCode: statusCode, data: data)
            case 500...599:
                throw APIError.serverError(statusCode: statusCode, data: data)
            default:
                throw APIError.invalidResponse
            }
        } catch let error as APIError {
            throw error // already mapped
        } catch {
            throw APIError.networkError(error)
        }
    }
}
