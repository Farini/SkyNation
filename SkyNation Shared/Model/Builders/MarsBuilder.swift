//
//  MarsBuilder.swift
//  SkyNation
//
//  Created by Carlos Farini on 3/9/21.
//

import Foundation
import SceneKit

class MarsBuilder {
    
    static var shared:MarsBuilder = MarsBuilder()
    
    var cities:[DBCity] = []
    var myDBCity:DBCity?
    var myCityData:CityData?
    
    var outposts:[DBOutpost] = []
    var players:[PlayerContent] = []
    
    /// Vehicles stationed in Guild
    var guildGarage:[SpaceVehicleContent] = []
    
    var guild:GuildFullContent?
    var scene:SCNScene
    
    private init() {
        print("Initting Mars Director")
        guard let scene = MarsBuilder.loadScene() else { fatalError() }
        self.scene = scene
        getServerInfo()
    }
    
    // Load Scene
    class func loadScene() -> SCNScene? {
        let nextScene = SCNScene(named: "Art.scnassets/Mars/GuildMap.scn")
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
        
        SKNS.loadGuild { (guild, error) in
            if let guild:GuildFullContent = guild {
                self.guild = guild
                print("**********************")
                print("Guild Result: \(guild.name)")
                print("**********************")
                for city:DBCity in guild.cities {
                    print("City: Posdex:\(city.posdex), \(city.name)")
                    if let cid = city.owner?["id"] {
                        if cid != nil && cid == player.cityID {
                            print("This city is mine!")
                            self.myDBCity = city
                        }
                    }
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
                
                self.getArrivedVehicles()
                
            } else {
                print("No guild in result")
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    /// Gets all vehicles that arrived
    func getArrivedVehicles() {
        print("Getting Arrived Vehicles")
        SKNS.arrivedVehiclesInGuildFile { gVehicles, error in
            if let gVehicles = gVehicles {
                print("Guild garage vehicles: \(gVehicles.count)")
                self.guildGarage = gVehicles
                for vehicle in gVehicles {
                    if vehicle.owner == LocalDatabase.shared.player?.playerID {
                        print("Vehicle is mine: \(vehicle.engine)")
                        print("Contents (count): \(vehicle.boxes.count + vehicle.tanks.count + vehicle.batteries.count + vehicle.passengers.count + vehicle.peripherals.count)")
                        
                        // Bring contents to city
                        // Update City
                        // Post city update
                    }
                }
            } else {
                print("⚠️ Error: Could not get arrived vehicles. error -> \(error?.localizedDescription ?? "n/a")")
            }
        }
    }
    
    // Request My City
    func getMyCityInfo() {
        
        if let myCity = myDBCity {
            SKNS.loadCity(posdex: Posdex(rawValue:myCity.posdex)!) { (cityData, error) in
                if let cityData = cityData {
                    print("Updating my CityData object")
                    self.myCityData = cityData
                } else {
                    print("Could not update my citydata. Error: \(error?.localizedDescription ?? "n/a")")
                    self.myCityData = nil
                }
            }
        }
    }
    
    // Load objects that represent outposts, cities, etc.
    func loadSceneObjects() {
        
    }
    
    // Selection
    
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
