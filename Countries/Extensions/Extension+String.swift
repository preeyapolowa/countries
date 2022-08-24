//
//  Extension+String.swift
//  Countries
//
//  Created by Preeyapol Owatsuwan on 24/8/2565 BE.
//

import Foundation

extension String {
    func hasPrefix<Prefix>(_ prefix: Prefix, caseSensitive: Bool) -> Bool where Prefix : StringProtocol {
        if caseSensitive { return self.hasPrefix(prefix) }
        return self.lowercased().hasPrefix(prefix.lowercased())
    }
}
