//
//  Assets.swift
//  Hidden Bar
//
//  Maintained by Andrea Beghè in 2026.
//  Copyright © 2026 Andrea Beghè. Licensed under the MIT License.
//

import AppKit

struct Assets {
    static let collapseImage = NSImage(named: NSImage.Name((Global.isUsingLTRTypeSystem) ? "ic_expand" : "ic_collapse"))
    static let expandImage = NSImage(named: NSImage.Name((Global.isUsingLTRTypeSystem) ? "ic_collapse" : "ic_expand"))
    static let seperatorImage = NSImage(named: NSImage.Name("ic_line"))
}
