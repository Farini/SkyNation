//
//  ServerDatabase.swift
//  SkyNation
//
//  Created by Carlos Farini on 3/14/21.
//

import Foundation

/**
 A class that holds all Server variables. Stores information, and manage connections? */
class ServerDatabase {
    
    var user:SKNUserPost
    var player:SKNPlayer
    
    var guild:Guild?
    // guildCities
    // guildOutposts
    
    var city:CityData?
    
    var errorMessage:String = ""
    
    // incomingVehicles // All arriving vehicles from Guild
    // playerVehicles   // arriving vehicles from Player
    
    /// Singleton initializers are lazy.
    static let shared = ServerDatabase()
    init() {
        guard let player = LocalDatabase.shared.player
            else {
            fatalError()
        }
        let user = SKNUserPost(player: player)
        self.player = player
        self.user = user
    }
    
    // In order...?
    var lastLogin:Date?
    func login() {
        // Check last login. Avoid redundant updates
        if let log = lastLogin, Date().timeIntervalSince(log) < 60 {
            return
        }
        SKNS.resolveLogin { (player, error) in
            if let player = player {
                DispatchQueue.main.async {
                    self.player = player
                    self.lastLogin = Date()
                    self.user = SKNUserPost(player: player)
                    if let _ = player.guildID {
                        self.fetchGuild()
                    }
                }
                
            } else {
                // Error
                self.errorMessage = error?.localizedDescription ?? "Could not connect to serer"
            }
        }
    }
    
    func fetchGuild() {
        
    }
    
    func fetchCity() {
        
    }
    
    func fetchVehicles() {
        
    }
}
