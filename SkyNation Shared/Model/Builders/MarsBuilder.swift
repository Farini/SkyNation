//
//  MarsBuilder.swift
//  SkyNation
//
//  Created by Carlos Farini on 3/9/21.
//

import Foundation
import SceneKit

enum MGuildState:Error {
    case loaded
    case serverDown
    case badRequest
    case locally
    case notJoined
    case nonExistant
    case other(error:Error)
}

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
    
    /// Warning User has no guild, or been kicked out of previous
    var hasNoGuild:Bool = false
    
    // Scene Callback from clicking Mars Icon (Switch Scene)
    func requestMarsInfo(completion:@escaping(GuildFullContent?, MGuildState) -> ()) {
        
        print("\n Will load Mars Scene")
        
        guard let player = LocalDatabase.shared.player else {
            print("⚠️ No Player")
            return
        }
        guard let pid = player.guildID else {
            print("⚠️ No Guild ID for player: \(player.name)")
            return
        }
        
        print("Loading data for player: \(player.name), ID:\(pid)")
        
        // Should we load the guild on file when server is down/unavailable?
        // MGuildState
        // 1. server down
        // 2. bad request
        // 3. Locally?
        // 4. not joined
        // 5. no longer exists
        
        SKNS.loadGuild { (guild, error) in
            
            if let guild:GuildFullContent = guild {
                self.guild = guild
                print("\n**********************")
                print("Guild Loaded: \(guild.name)")
                print("**********************")
                for city:DBCity in guild.cities {
                    print("City: Pos:\(city.posdex) >> \(city.name)")
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
                
                completion(guild, .loaded)
                return
                
            } else {
                print("No guild in result")
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                    completion(nil, .other(error: error))
                    return
                }
            }
            
            // Try to load locally (from LocalDatabase)
            // if let guild = LocalDatabase.shared.guild...
            
            completion(nil, .badRequest)
            return
        }
        
        completion(nil, .serverDown)
    }
    
    // Request Guild Details
    /**
        Populates the data. Use `randomize` to populate randomly (create a example/sample)
     */
    func getServerInfo(randomize:Bool) {
        
        // Not random
        if !randomize {
            
            print("Getting Server Info")
            
            guard let player = LocalDatabase.shared.player else {
                print("No Player")
                return
            }
            guard let _ = player.guildID else {
                print("No Guild ID for player: \(player.name)")
                self.hasNoGuild = true
                return
            }
            
            ServerManager.shared.inquireFullGuild { guild, error in
                if let guild:GuildFullContent = guild {
                    self.guild = guild
                    print("\n**********************")
                    print("Guild Result: \(guild.name)")
                    print("**********************")
                    for city:DBCity in guild.cities {
                        print("City: Pos:\(city.posdex) >> \(city.name)")
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
                    self.hasNoGuild = true
                    
                    if let error = error {
                        print("Error: \(error.localizedDescription)")
                    }
                }
            }
            
           
        }
        
        // Random
        else {
            
            print("\n *** Random Data *** \n")
            
            var randomGuild = GuildFullContent()
            self.cities = randomGuild.cities
            self.outposts = randomGuild.outposts
            self.players = randomGuild.citizens
            self.guild = randomGuild
            
            // Populate my city:
            // var myDBCity:DBCity?
            // var myCityData:CityData?
            let mc:DBCity = DBCity(id: UUID(), guild: ["guild":randomGuild.id], name: "Fariland", accounting: Date(), owner: ["id":LocalDatabase.shared.player!.playerID], posdex: Posdex.city9.rawValue)
            let cd = CityData(example: true, id:mc.id)
            // add city
            randomGuild.cities.append(mc)
            self.cities.append(mc)
            
            self.myDBCity = mc
            self.myCityData = cd
            
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
    
    func didSelectAirButton() -> CityData? {
        // Look for My City
        // DB
        if let myDBCity = myDBCity {
            print("My City \(myDBCity.name)")
        }
        // CityData
        if let myCity = myCityData {
            print("My City: \(myCity.id)")
            return myCity
        } else {
            // No city
            print("You don't have a city. Create one.")
            return nil
        }
    }
    
    // MARK: - Initialize
    
    private init() {
        
        print("Initting Mars Builder")
        
        guard let scene = MarsBuilder.loadScene() else { fatalError() }
        self.scene = scene
        
        getServerInfo(randomize: false)
    }
    
    // Load Scene
    class func loadScene() -> SCNScene? {
        let nextScene = SCNScene(named: "Art.scnassets/Mars/GuildMap.scn")
        return nextScene
    }
    
}

// MARK: - Scene

extension MarsBuilder {
    
    func populateScene() {
        
        print("\n * GUILD SCENE\n-----------------")
        let root:SCNNode = scene.rootNode
        for child in root.childNodes {
            print("Root child: \(child.name ?? "<untitled>")")
        }
        
        // Terrain
        // Camera
        // Light
        
        // Outposts
        print("\n [ OUTPOSTS ] ")
        let outpostsParent = root.childNode(withName: "Outposts", recursively: false)!
        for child in outpostsParent.childNodes {
            let opNodeName = child.name ?? "unknown"
            if let pp:Posdex = Posdex.allCases.filter({ $0.sceneName == opNodeName }).first {
                if let outpost = outposts.filter({ $0.posdex == pp.rawValue }).first {
                    print("\(pp.sceneName) | \(outpost.type.rawValue), lvl:\(outpost.level)")
                    
                } else {
                    print("Outpost (unbuilt) | \(pp.sceneName)")
                }
            }
        }
        
        // Cities
        print("\n [ CITIES ] ")
        let citiesParent = root.childNode(withName: "Cities", recursively: false)!
        for tmpCity in citiesParent.childNodes {
            
            let cityNodeName = tmpCity.name ?? "unknown"
            if let pp:Posdex = Posdex.allCases.filter({ $0.sceneName == cityNodeName }).first {
                if let city = cities.filter({ $0.posdex == pp.rawValue }).first {
                    var ownerString:String = "unowned"
                    if let ownID = city.owner?.values.first { ownerString = ownID!.uuidString }
                    let userOwner = players.filter({ $0.id.uuidString == ownerString }).first?.name ?? "unowned"
                    print("City Node | \(pp.sceneName), owner:\(userOwner)")
                    
                    // Build gate
                    if let model:SCNNode = pp.extractModel()?.clone() {
                        print("Model: \(String(describing: model.name)). Replacing.")
                        
                        model.position = pp.position.sceneKitVector()
                        model.eulerAngles = pp.eulerAngles.sceneKitVector()
                        model.name = pp.sceneName

                        tmpCity.removeFromParentNode()
                        citiesParent.addChildNode(model)
                    }
                    
                } else {
                    
                    // Free slot >> Diamond
                    print("- Unowned \(pp.sceneName), posdex:\(pp.rawValue)")
                    let gateScene = SCNScene(named: "Art.scnassets/Mars/Gate.scn")!
                    let diamond = gateScene.rootNode.childNode(withName: "DiamondH", recursively: false)!.clone()
                    var dPos = tmpCity.position
                    dPos.y += 5
                    diamond.position = dPos
                    citiesParent.addChildNode(diamond)
                    
                }
            }
        }
    }
}

extension Posdex {
    
    func extractModel() -> SCNNode? {
        switch self {
            case .city1, .city2, .city3, .city4, .city5, .city6, .city7, .city8, .city9:
                return SCNScene(named: "Art.scnassets/Mars/Gate2.scn")!.rootNode.childNodes.first!
            case .power1, .power2, .power3, .power4:
                return SCNScene(named: "Art.scnassets/Mars/Outposts/PowerPlant.scn")!.rootNode
            case .mining1, .mining2, .mining3:
                return nil
            case .biosphere1, .biosphere2:
                return SCNScene(named: "Art.scnassets/Mars/Outposts/Biosphere.scn")!.rootNode
            case .antenna:
                return SCNScene(named: "Art.scnassets/Mars/Outposts/OPAntenna.scn")!.rootNode
            case .launchPad:
                return SCNScene(named: "Art.scnassets/Mars/Outposts/LandingPad.scn")!.rootNode
            case .arena: return nil
            case .hq: return nil
            case .observatory: return nil
//            default: return nil
        }
    }
}
