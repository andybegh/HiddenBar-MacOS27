//
//  HotKeyManager.swift
//  Hidden Bar
//
//  Maintained by Andrea Beghè in 2026.
//  Copyright © 2026 Andrea Beghè. Licensed under the MIT License.
//

import Foundation
import HotKey

class HotKeyManager {
    static var hotKey: HotKey? {
        didSet {
            guard let hotKey = hotKey else { return }
            
            hotKey.keyDownHandler = { [] in
                switch (Preferences.statusBarPolicy) {
                case (.collapsed):
                    Preferences.statusBarPolicy = .partialExpand
                default:
                    Preferences.statusBarPolicy = .collapsed
                }
            }
        }
    }
    
    
    static func setupHotKey() {
        guard let globalKey = Preferences.globalKey else {return}
        hotKey = HotKey(keyCombo: KeyCombo(carbonKeyCode: globalKey.keyCode, carbonModifiers: globalKey.carbonFlags))
    }
}
