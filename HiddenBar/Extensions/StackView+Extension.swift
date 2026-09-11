//
//  StackView+Extension.swift
//  Hidden Bar
//
//  Maintained by Andrea Beghè in 2026.
//  Copyright © 2026 Andrea Beghè. Licensed under the MIT License.
//

import Cocoa

extension NSStackView {
    func removeAllSubViews() {
        for view in self.views {
            view.removeFromSuperview()
        }
    }
}
