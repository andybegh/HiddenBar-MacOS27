//
//  String+Extension.swift
//  Hidden Bar
//
//  Maintained by Andrea Beghè in 2026.
//  Copyright © 2026 Andrea Beghè. Licensed under the MIT License.
//

import Foundation

extension String {
    
    // localize
    var localized: String {
        return NSLocalizedString(self, comment: self)
    }
}
