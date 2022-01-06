//
//  GameSettings.swift
//  SkyNation
//
//  Created by Carlos Farini on 8/18/21.
//

import Foundation

/** General Settings with vars stored in UserDefauls */
class GameSettings:Codable {
    
    static let shared = GameSettings.load()
    
    // MARK: - App Modes - Helpers to debug, or run the app with properties
    
    /// Whether to debug Scene objects
    static let debugScene:Bool = false
    static let debugAccounting:Bool = false
    
    /// Whether game should connect to the server, or not
    static let onlineStatus:Bool = true
    
    // MARK: - Data
    
    /// To save in Cloud
    var useCloud:Bool = false
    
    // MARK: - Gameplay Options
    
    /// The scene that starts the game
    var startingScene:GameSceneType
    
    /// Bring up tutorial when game starts
    var showTutorial:Bool
    
    /// Wether the game should automatically clear empty tanks
    var clearEmptyTanks:Bool
    
    /// in auto-merge Tanks get automatically merged in accounting
    var autoMergeTanks:Bool
    
    /// Whether to render more expensive lights
    var showLights:Bool
    
    /// Serves food in biobox to astronauts.. Careful.: This could make you run out of DNA's
    var serveBioBox:Bool
    
    /// Whether scene should be loaded
    var autoStartScene:Bool?
    
    // MARK: - Sounds
    
    var musicOn:Bool
    var soundFXOn:Bool
    var dialogueOn:Bool
    
    // MARK: - New
    
    // make sure to get this in decoding as well.
    var showLabels:Bool?
    
    private init () {
        
        // Gameplay
        self.showTutorial = true
        self.startingScene = .SpaceStation
        self.showLights = true
        self.clearEmptyTanks = false
        self.autoMergeTanks = true
        self.serveBioBox = true
        
        // Sounds
        self.musicOn = true
        self.soundFXOn = true
        self.dialogueOn = true
        self.autoStartScene = false
        
        // new
        self.showLabels = true
    }
    
    static private func load() -> GameSettings {
        return LocalDatabase.shared.gameSettings
    }
    
    static func create() -> GameSettings {
        return GameSettings()
    }
    
    /// Saves the User `Settings`, or Preferences
    func save() {
        // Update showLabels
        if self.showLabels == nil {
            self.showLabels = true
        }
        
        do {
            try LocalDatabase.shared.saveSettings(settings:self)
        } catch {
            print("Error saving Settings.: \(error.localizedDescription)")
        }
        
    }
}
