//
//  GameFonts.swift
//  SkyNation
//
//  Created by Carlos Farini on 8/18/21.
//

import SwiftUI

// MARK: - Numbers

/// Date and Number Formatters
struct GameFormatters {
    
    /// A Default Date Formatter
    static let dateFormatter:DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        formatter.timeZone = TimeZone.current
        
        return formatter
    }()
    
    /// Longer date formatter
    static let fullDateFormatter:DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateStyle = .long
        formatter.timeStyle = .long
        formatter.timeZone = TimeZone.current
        
        return formatter
    }()
    
    /// Time formatter with time only
    static let tinyTimeFormatter:DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        formatter.timeZone = TimeZone.current
        
        return formatter
    }()
    
    /// Tiny Formatter with day only
    static let tinyDayFormatter:DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        formatter.timeZone = TimeZone.current
        
        return formatter
    }()
    
    /// Returns a tiny String from date. If a day ago, date formatter, or else Time formatter only.
    static func flexibleDateFormatterString(date:Date) -> String {
        let delta = Date().timeIntervalSince(date)
        if delta >= 60.0 * 60.0 * 24.0 {
            return tinyDayFormatter.string(from: date)
        } else {
            return tinyTimeFormatter.string(from: date)
        }
    }
    
    /// Default Number Formatter. 1 to 2 decimal digits
    static let numberFormatter:NumberFormatter = {
        let format = NumberFormatter()
        format.minimumFractionDigits = 1
        format.maximumFractionDigits = 2
        format.numberStyle = NumberFormatter.Style.decimal
        #if os(macOS)
        format.hasThousandSeparators = true
        #else
        format.usesGroupingSeparator = true
        #endif
        
        return format
    }()
    
    /// Returns a String formatted as `HH, mm, ss`
    static func humanReadableTimeInterval(delta:Double) -> String {
        return TimeInterval(delta).stringFromTimeInterval()
    }
}

extension TimeInterval {
    
    /// The Time interval that represents 24 hours
    static var oneDay:TimeInterval = 60.0 * 60.0 * 24.0
    
    /// Returns a string with Hours, Minutes and seconds of the TimeInterval value
    func stringFromTimeInterval() -> String {
        
        let time = NSInteger(self)
        
        let seconds = time % 60
        let minutes = (time / 60) % 60
        let hours = (time / 3600)
        
        return String(format: "%dh %0.2dm %0.2ds", hours, minutes, seconds)
        
    }
}

// MARK: - Fonts

enum GameFont {
    
    /// Default title (.title2 on iOS)
    case title
    
    /// mac title2 ios title3
    case section
    
    /// body
    case writing
    
    /// footnote
    case little
    
    /// Returns the SwiftUI's Font
    func makeFont() -> Font {
        #if os(macOS)
        switch self {
            case .title: return .title
            case .section: return .title2
            case .writing: return .body
            case .little: return .footnote
        }
        #else
        switch self {
            case .title: return .title2
            case .section: return .title3
            case .writing: return .body
            case .little: return .footnote
        }
        #endif
    }
    
    /// Monospaced Font. Useful for lining up names
    static var monospacedBodyFont:Font {
        return Font.system(.body, design: .monospaced)
    }
    
    /// Bigger Monospaced Font title2 on mac, title3 on iOS
    static var monospacedSectionFont:Font {
        #if os(macOS)
        return Font.system(.title2, design: .monospaced)
        #else
        return Font.system(.title3, design: .monospaced)
        #endif
    }
}
