//
//  Guild+Enums.swift
//  SkyNation
//
//  Created by Carlos Farini on 1/17/22.
//

import Foundation

enum GuildTerrainType:String, Codable, CaseIterable {
    case Terrain1
    case Terrain2
    case Terrain3
}

// MARK: - UI Variables stored on DB

/// Enumeration of Icons possible for the Guild
enum GuildIcon:String, Codable, CaseIterable, Equatable {
    
    case moon
    case eclipse
    case club
    case spade
    case diamond
    case star
    case sunDust
    
    var imageName:String {
        switch self {
            case .moon: return "moon"
            case .eclipse: return "circlebadge.2"
            case .club: return "suit.club"
            case .spade: return "suit.spade"
            case .diamond: return "suit.diamond"
            case .star: return "star"
            case .sunDust: return "sun.dust"
        }
    }
}

import SwiftUI

/// Possible colors for a Guild
enum GuildColor:String, Codable, CaseIterable {
    
    case red
    case blue
    case green
    case gray
    
    /// The SwiftUI color
    var color:Color {
        switch self {
            case .red: return Color.red
            case .blue: return Color.blue
            case .green: return Color(.sRGB, red: 0.0, green: 1.0, blue: 0.1, opacity: 1.0)
            case .gray: return Color.init(.sRGB, white: 0.75, opacity: 1.0)
        }
    }
}
