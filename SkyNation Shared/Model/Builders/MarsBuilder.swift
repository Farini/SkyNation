//
//  MarsBuilder.swift
//  SkyNation
//
//  Created by Carlos Farini on 3/9/21.
//

import Foundation
import SceneKit

class MarsBuilder {
    
    var cities:[DBCity] = []
    var outposts:[DBOutpost] = []
    var players:[PlayerContent] = []
    
    var guild:GuildFullContent?
    var scene:SCNScene?
    
    init() {
        print("Initting Mars Director")
        getServerInfo()
    }
    
    // Load Scene
    func loadScene() -> SCNScene? {
        let nextScene = SCNScene(named: "Art.scnassets/Mars/GuildMap.scn")
        self.scene = nextScene
        return nextScene
    }
    
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
        
        SKNS.guildInfo(user: SKNUserPost(player: player)) { (guild, error) in
            
            if let guild:GuildFullContent = guild {
                print("**********************")
                print("Guild Result: \(guild.name)")
                print("**********************")
                for city:DBCity in guild.cities {
                    print("City: Posdex:\(city.posdex), \(city.name)")
                }
                self.cities = guild.cities
                
                for outpost:DBOutpost in guild.outposts {
                    print("OutPost: \(outpost.type)")
                    
                }
                self.outposts = guild.outposts
                
                for player:PlayerContent in guild.citizens {
                    print("Player Content: \(player.name)")
                }
                self.players = guild.citizens
                
            } else {
                print("No guild in result")
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
              
    }
    
    // Load objects that represent outposts, cities, etc.
    func loadSceneObjects() {
        
    }
    
    func didTap(on posdex:Posdex) -> DBOutpost? {
        
        print("Tapped posdex: \(posdex.sceneName) (\(posdex.rawValue))")
        if outposts.isEmpty {
            print("No outposts")
            return nil
        }
        
        for op:DBOutpost in outposts {
            print("OP: Posdex: \(op.posdex)")
            if op.posdex == posdex.rawValue {
                print("OP Level: \(op.level)")
                if let job = op.getNextJob() {
                    print("⚠️ I have a job for you. Work, work!! \n Ingredients: \(job.wantedIngredients.count)\n Skills: \(job.wantedSkills.count)")
                } else {
                    print("No jobs here")
                }
                return op
            }
        }
        return nil
    }
    
    func didTap(city posdex:Posdex) -> DBCity? {
        if cities.isEmpty {
            print("No Cities")
            return nil
        }
        
        for city in cities {
            let cityDex = Posdex(rawValue: city.posdex)
            
            if cityDex == posdex {
                return city
            }
        }
        
        return nil
    }
    
}
