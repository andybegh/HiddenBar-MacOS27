//
//  NSView+Extension.swift
//  Hidden Bar
//
//  Maintained by Andrea Beghè in 2026.
//  Copyright © 2026 Andrea Beghè. Licensed under the MIT License.
//

import Foundation
import AppKit
extension NSView {
    var getOrigin:CGPoint? {
        return self.window?.frame.origin
    }
}
