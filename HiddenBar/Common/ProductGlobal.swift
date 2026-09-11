//
//  Global.swift
//  Hidden Bar
//
//  Maintained by Andrea Beghè in 2026.
//  Copyright © 2026 Andrea Beghè. Licensed under the MIT License.
//

import AppKit

extension Global { // Global Variables for Product
    // Detects RTL type system
    public static let isUsingLTRTypeSystem = (NSApplication.shared.userInterfaceLayoutDirection == .leftToRight);
    
    // Get main operation queue
    public static let mainQueue = OperationQueue.main
    
    // Get main runloop
    public static let runLoop = RunLoop.main
}
