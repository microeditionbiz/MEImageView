//
//  URL+.swift
//  
//
//  Created by Pablo Ezequiel Romero Giovannoni on 13/11/2022.
//

import Foundation
import CryptoKit

extension URL {
    func sha256Hash() -> String {
        let data = Data(self.path.utf8)
        let hashed = SHA256.hash(data: data)
        return hashed
            .compactMap { String(format: "%02x", $0) }
            .joined()
    }
}
