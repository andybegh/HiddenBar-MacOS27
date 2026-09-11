//
//  Date+Extension.swift
//  Hidden Bar
//
//  Maintained by Andrea Beghè in 2026.
//  Copyright © 2026 Andrea Beghè. Licensed under the MIT License.
//

import Foundation

extension Date {
    static func dateString() -> String {
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "EEE dd MMM"
        return dateFormater.string(from: Date())
    }
    static func timeString() -> String {
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "hh:mm a"
        return dateFormater.string(from: Date())
    }
}
