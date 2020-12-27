//  GameConstants.swift
//  SkyNation
//  Created by Carlos Farini on 12/18/20.

import SwiftUI

/*
class GameSettings {
    
    var showTutorial:Bool
    
    static let shared = GameSettings()
    private init () {
        var shouldShowTutorial:Bool = true
        if let station = LocalDatabase.shared.station {
            if let mod = station.habModules.first {
                print("We have a module: \(mod.name)")
                shouldShowTutorial = false
            }
        }
        self.showTutorial = shouldShowTutorial
    }
}
*/

/**
 Main Logic items for the game.
 Use this class to set limits, boundaries, and constraints */
struct GameLogic {
    
    /// The maximum amount of items in a new order (EarthOrder)
    static let earthOrderLimit:Int = 6
    
    /// The default `capacity` of a battery
    static let batteryCapacity:Int = 100
    
    /// Amount of air a module requires
    static let airPerModule:Int = 225
    
    static func radiansFrom(_ degrees:Double) -> Double {
        return degrees * .pi/180
    }
    
    /**
     Calculates chances of an event happening - 100 default total
     - Parameter hit: The chance (divided by total)
     - Parameter total: The amount of trials (100 by default)
     - Returns: Whether the event happens, or not
     */
    static func chances(hit:Double, total:Double? = 100) -> Bool {
        guard let tot = total else { fatalError() }
        let result = Double.random(in: 0.0...tot)
        return result <= hit
    }
    
    // MARK: - Encrypting
    
    static func encrypt(string:String) -> String {
        guard !string.isEmpty else { return "" }
        let data = string.data(using: .utf8)
        if let encodedString = data?.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0)) {
            return encodedString
        }
        return ""
    }
    
    static func decrypt(string:String) -> String {
        guard !string.isEmpty else { return "" }
        if let decoded = Data(base64Encoded: string, options: Data.Base64DecodingOptions(rawValue: 0)).map({ String(data: $0, encoding: .utf8) }) {
            // Convert back to a string
            print("Decoded: \(decoded ?? "")")
            return decoded ?? ""
        }
        return ""
    }
}

/// Date and Number Formatters
struct GameFormatters {
    
    /// A Default Date Formatter
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
    
    /// Longer date formatter
    static let fullDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .long
        return formatter
    }()
    
    /// Default Number Formatter
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
}

// MARK: - File System

class GameFiles {
    
    static let shared = GameFiles()
    
    private init() {
        
    }
    
    static var documentsFolder:URL {
        guard let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else{
            fatalError("Default folder for ap not found")
        }
        return documents
    }
    
    static var appFolder:URL {
        guard let appSupportFolder = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else{
            fatalError("Default folder for ap not found")
        }
        return appSupportFolder
    }
}

// MARK: - Graphics

/// The Colors the game uses
struct GameColors {
    static let greenBackground = Color.green
    static let lightBlue = Color.blue
}

enum GameSceneType {
    case SpaceStation
    case MarsColony
}


/// Images used by the game
struct GameImages {
    
    /// A SwiftUI Image for a given Skill
    static func imageForSkill(skill:Skills) -> Image {
        switch skill {
            case .Biologic: return Image("SkillBio")
            case .Datacomm: return Image("SkillData")
            case .Electric: return Image("SkillElectric")
            case .Material: return Image("SkillMaterial")
            case .Mechanic: return Image("SkillMechanic")
            case .Medic: return Image("SkillMedic")
            case .SystemOS: return Image("SkillSystems")
            case .Handy: return Image(systemName: "hand.wave.fill")
            // handy
//            default: return Image(systemName: "questionmark")
        }
    }
    
    static func imageForTank() -> Image {
        return Image("Tank")
    }
    
    static func commonSystemImage(name:String) -> SKNImage? {
        #if os(macOS)
        guard let im = NSImage(systemSymbolName: name, accessibilityDescription: name) else { return nil }
        im.isTemplate = true
        return im as SKNImage
        #else
        guard let image = UIImage(systemName: name)?.withTintColor(.white, renderingMode: .alwaysTemplate) else { fatalError() }
//        image.tintColor = .white
        return image // as! SKNImage
        #endif
    }
    
    static var currencyImage:SKNImage {
        return SKNImage(named: "Currency")!
    }
    
}

extension Notification.Name {
    
    static let URLRequestFailed  = Notification.Name("URLRequestFailed")        // Any URL Request that fails sends this messsage
    static let DidAddToFavorites = Notification.Name("DidAddToFavorites")       // Add To Favorites Notification
    static let closeView = Notification.Name("CloseView")
    
//    static let GlobalQuoteUpdate = Notification.Name("GlobalQuoteUpdated")      // Need to check the object, as this may be called by several
//    static let scopeQuoteUpdate  = Notification.Name("CompanyInScopeUpdate")    // Company in scope
//    static let StockSearchResult = Notification.Name("StockSearchResult")       // Results of Stock search ([Company] object)
//
//    static let TradeFromSearch   = Notification.Name("TradeFromSearch")         // To open the CompanyDetailsController
//    static let showCompanyDetails = Notification.Name("ShowStockDetails")       // To open the CompanyDetailsController
//    static let showStockReport = Notification.Name("ShowStockReport")
//
//    static let PendingOrderExec  = Notification.Name("PendingOrderExec")
//
//    static let chartingUpdates = Notification.Name("ChartingUpdates")
//
//    // Update the app
//    static let appNeedsUpdate = Notification.Name("appNeedsUpdate")
//
//    // News
//    static let articlesFetchComplete = Notification.Name("articlesFetchComplete")
//
//    // Purchases
//    static let purchaseUpdates = Notification.Name("PurchaseUpdates")
//    static let purchaseRestore = Notification.Name("PurchaseRestore")
}



#if os(macOS)
public typealias SKNImage = NSImage
public typealias SCNColor = NSColor
#else
public typealias SKNImage = UIImage
public typealias SCNColor = UIColor
#endif
