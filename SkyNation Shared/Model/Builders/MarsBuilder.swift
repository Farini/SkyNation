//
//  MarsBuilder.swift
//  SkyNation
//
//  Created by Carlos Farini on 3/9/21.
//

import Foundation
import SceneKit

class MarsBuilder {
    
    init() {
        print("Initting Mars Director")
        getServerInfo()
    }
    
    // Load Scene
    // Art.scnassets/Mars/MarsTerrain5 copy.scn
    func loadScene() -> SCNScene? {
        let nextScene = SCNScene(named: "Art.scnassets/Mars/GuildMap.scn")
        return nextScene
    }
    
    // Request Player
    // Request Guild
    // Request Guild Details
    func getServerInfo() {
        
        print("Getting Server Info")
        guard let player = LocalDatabase.shared.player else {
            print("No Player")
            return
        }
        guard let _ = player.guildID else {
            print("No Guild ID for player: \(player.name)")
            return
        }
        
        SKNS.guildInfo(user: SKNUser(player: player)) { (guild, error) in
            
            if let guild:GuildFullContent = guild {
                print("**********************")
                print("Guild Result: \(guild.name)")
                print("**********************")
                for city in guild.cities {
                    print("City: Posdex:\(city.posdex), \(city.name)")
                }
                for outpost in guild.outposts {
                    print("OutPost: \(outpost.type)")
                }
                for player in guild.citizens {
                    print("Player Content: \(player.name)")
                }
            } else {
                print("No guild in result")
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
              
    }
}
