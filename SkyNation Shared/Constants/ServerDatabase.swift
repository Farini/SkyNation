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
    
    func login() {
        
    }
    
    func fetchGuild() {
        
    }
    
    func fetchCity() {
        
    }
    
    func fetchVehicles() {
        
    }
}
