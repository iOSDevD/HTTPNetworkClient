//  HTTPAPIClientFactoryTests.swift
//  HTTPNetworkClient
//
//  Created by iOSDevD on 4/9/26.
//  Copyright (c) 2026 iOSDevD
//  Licensed under the MIT License. See LICENSE file in the project root.
//

import Foundation
import Testing
@testable import HTTPNetworkClient

struct HTTPAPIClientFactoryTests {

    @Test("Factory returns an APIClient instance")
    func testFactoryReturnsAPIClient() async throws {
        let builder = RequestBuilder(baseURL: URL(string: "https://example.com")!, defaultHeaders: [:])
        let client = HTTPAPIClientFactory.make(builder: builder)
        #expect((client as Any) is APIClient, "Compile-time type must APIClient and is not nil")
    }

}
