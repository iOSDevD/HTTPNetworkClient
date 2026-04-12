//  TestFileUtils.swift
//  HTTPNetworkClient
//
//  Created by iOSDevD on 4/7/26.
//  Copyright (c) 2026 iOSDevD
//  Licensed under the MIT License. See LICENSE file in the project root.
//

import Foundation

func loadJSON(_ filename: String, callerPath: String = #filePath) throws -> Data {
    // 1. Get the directory of the .swift file that is calling this function
    let currentDirectory = URL(fileURLWithPath: callerPath).deletingLastPathComponent()
    
    // 2. Look for the JSON file in that SAME folder on your hard drive
    let jsonFileURL = currentDirectory.appendingPathComponent("\(filename).json")
    
    // 3. Load the data directly from the disk
    do {
        return try Data(contentsOf: jsonFileURL)
    } catch {
        fatalError("❌ Could not find or read \(filename).json at: \(jsonFileURL.path)")
    }
}
