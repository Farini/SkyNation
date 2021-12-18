//
//  GameLogic.swift
//  SkyNation
//
//  Created by Carlos Farini on 8/18/21.
//

import Foundation

// MARK: - Notifications

extension Notification.Name {
    
    static let URLRequestFailed  = Notification.Name("URLRequestFailed")        // Any URL Request that fails sends this messsage
    
    // static let DidAddToFavorites = Notification.Name("DidAddToFavorites")       // Add To Favorites Notification
    
    static let UpdateSceneWithTech = Notification.Name("UpdateSceneWithTech")
    
    /// To Close Views
    static let closeView = Notification.Name("CloseView")
    
    /// To go from Loading screen to Game
    static let startGame = Notification.Name("StartGame")
    
    /// To Open the GameCenter (GameKit)
    static let openGameCenter = Notification.Name("OpenGameCenter")
    
    /// Change Module Properties (Name, Skin, Unbuild)
    static let changeModule = Notification.Name("ChangeModuleProperties")
    
    /// Notifies Scene Overlay that Vehicle has been launched
//    static let spaceVehicleLaunch = Notification.Name("DidLaunchSpaceVehicle")
    
}

/**
 Main Logic items for the game.
 Use this class to set limits, boundaries, and constraints */
struct GameLogic {
    
    /// Amount of Sky Coins that a Token is worth.
    static let moneyForToken:Int = 10_000
    
    /// The maximum amount of items in a new order (EarthOrder)
    static let earthOrderLimit:Int = 6
    static let orderTankPrice:Int = 10
    static let orderPersonPrice:Int = 150
    
    /// The default `capacity` of a battery
    static let batteryCapacity:Int = 100
    
    /// Amount of air a module requires
    static let airPerModule:Int = 225
    static let energyPerModule:Int = 4
    
    /// Water consumption per `Person`
    static let waterConsumption:Int = 3
    
    /// Energy Consumption per `Person`
    static func personalEnergyConsumption() -> Int {
        return [1,2,3].randomElement()!
    }
    
    /// The default time a `Person` spends studying
    static let personStudyTime:Double = 60.0 * 60.0 * 24.0 * 3.0
    
    /// Cost of building a `BioBox` (Water)
    static let bioBoxWaterConsumption:Int = 3
    
    /// Cost of building a `BioBox` (Energy)
    static let bioBoxEnergyConsumption:Int = 7
    
    /// The time that takes to a `SpaceVehicle` can reach Mars.
    static let vehicleTravelTime:Double = 60.0 * 60.0 * 24 * 3
    
    // MARK: - Functions
    
    static func radiansFrom(_ degrees:Double) -> Double {
        return degrees * .pi/180
    }
    
    static func fibonnaci(index:Int) -> Int {
        guard index > 1 else { return 1 }
        return fibonnaci(index: index - 1) + fibonnaci(index:index-2)
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

/**
 Enumeration of all GameFiles.
 - discussion:
    - fileName: The name of the file to be fetched
    - fileType: The Codable Type for this file
*/

enum GameFile {
    
    case player
    case station
    case messages
    case settings
    case cityData
    case server
    case travels
    
    var fileName:String {
        switch self {
            case .player:   return "Player.json"
            case .station:  return "Station.json"
            case .messages: return "GameMessages.json"
            case .settings: return "GameSettings.json"
            case .cityData: return "MarsCity.json"
            case .server:   return "SKNSData.json"
            case .travels:  return "Travelling.json"
        }
    }
    
    var fileType:Codable.Type {
        switch self {
            case .player:   return SKNPlayer.self
            case .station:  return Station.self
            case .messages: return [GameMessage].self
            case .settings: return GameSettings.self
            case .cityData: return CityData.self
            case .server:   return ServerData.self
            case .travels:  return [SpaceVehicle].self
        }
    }
}

struct GameWindow {
    
    /// Easiest way to close the current Dialogue
    static func closeWindow() {
        NotificationCenter.default.post(Notification(name: .closeView))
    }
}
