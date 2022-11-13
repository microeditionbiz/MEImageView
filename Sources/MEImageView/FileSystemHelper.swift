//  FileSystemHelper.swift
//  MEImageView
//
//  Created by Pablo Ezequiel Romero Giovannoni on 23/11/2019.
//  Copyright © 2019 Pablo Ezequiel Romero Giovannoni. All rights reserved.
//

import Foundation

private let fileManager = FileManager.default

public enum FileSystemHelper {

    public static func fileExist(at url: URL) -> Bool {
        let path = url.path
        return fileManager.fileExists(atPath: path)
    }
    
    public static func removeFile(at fileURL: URL) throws {
        if Self.fileExist(at: fileURL) {
            try fileManager.removeItem(at: fileURL)
        }
    }
    
    public static func copyFile(from initialUrl: URL, to finalURL: URL) throws {
        try Self.removeFile(at: finalURL)
        try fileManager.copyItem(at: initialUrl, to: finalURL)
    }
    
    public static func cachesUrl() -> URL {
        return fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
    
    public static func directoryURL() -> URL {
        return fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
}
