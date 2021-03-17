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
    var city:CityData?
    
    // Init from local database, after Player
    init(player:SKNPlayer) {
        self.player = player
        self.user = SKNUserPost(player: player)
        // Start Fetching
        self.start()
    }
    
    func start() {
//        SKNS.resolveLogin { (loggedUser, error) in
//            if let logUser = loggedUser {
//                self.user = logUser
////                if logUser.guildID != nil {
////                    self.fetchGuild()
////                }
//            } else {
//
//            }
//        }
    }
    
    func fetchGuild() {
        
    }
}
