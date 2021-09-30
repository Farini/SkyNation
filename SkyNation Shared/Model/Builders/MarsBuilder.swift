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
    var guildGarage:[SpaceVehicleTicket] = []
    
    var guild:GuildFullContent?
    var scene:SCNScene
    
    /// Warning User has no guild, or been kicked out of previous
    var hasNoGuild:Bool = false
    
    
    // Request Guild Details
    
    /**
        Populates the data. Use `randomize` to populate randomly (create a example/sample)
     */
    func getServerInfo() {
        
        if GameSettings.onlineStatus {
            
            print("Getting Server Info")
            
            let player = LocalDatabase.shared.player
            guard let _ = player.guildID else {
                print("No Guild ID for player: \(player.name)")
                self.hasNoGuild = true
                return
            }
            
            ServerManager.shared.inquireFullGuild(force:true) { guild, error in
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
        } else {
            
            // Randomly Created Data
            
            print("\n *** Random Data *** \n")
            
            var randomGuild = GuildFullContent()
            self.cities = randomGuild.cities
            self.outposts = randomGuild.outposts
            self.players = randomGuild.citizens
            self.guild = randomGuild
            
            // Populate my city:
            // var myDBCity:DBCity?
            // var myCityData:CityData?
            let mc:DBCity = DBCity(id: UUID(), guild: ["guild":randomGuild.id], name: "Fariland", accounting: Date(), owner: ["id":LocalDatabase.shared.player.playerID], posdex: Posdex.city9.rawValue, gateColor: 0, experience:0)
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
        SKNS.arrivedVehiclesInGuildMap() { gVehicles, error in
            if let gVehicles = gVehicles {
                print("Guild garage vehicles: \(gVehicles.count)")
                self.guildGarage = gVehicles
                for vehicle in gVehicles {
                    if vehicle.owner == LocalDatabase.shared.player.playerID {
                        print("Vehicle is mine: \(vehicle.engine)")
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
        
        getServerInfo()
        
        // Load CityData
        self.myCityData = LocalDatabase.shared.cityData
    }
    
    // Load Scene
    class func loadScene() -> SCNScene? {
//        let nextScene = SCNScene(named: "Art.scnassets/Mars/GuildMap.scn")
        let nextScene = SCNScene(named: "Art.scnassets/Mars/MarsMap.scn")
        return nextScene
    }
    
}

// MARK: - Scene

extension MarsBuilder {
    
    func populateScene() -> SCNScene { //[GamePOV] {
        
        print("\n * GUILD SCENE\n-----------------")
        let root:SCNNode = scene.rootNode
        for child in root.childNodes {
            print("Root child: \(child.name ?? "<untitled>")")
        }
        
        // Terrain
        guard let terrain:SCNNode = root.childNode(withName: "Terrain", recursively: false) else {
            fatalError("Missing Terrain Node")
        }
        print("\nTerrain.: Vertex Count: \(terrain.geometry?.sources.filter({ $0.semantic == .vertex }).compactMap({ $0.vectorCount }).reduce(0, +) ?? 0)")
        
        // Light
//        let lightNode:SCNNode = root.childNode(withName: "Light", recursively: false)!
        let lightNode:SCNNode = root.childNode(withName: "Lights", recursively: false)?.childNodes.first ?? SCNNode()
        // light position: 4.076,34.945,-1.005
        // light euler: 29.656, 49.397, 93.817
        if let light = lightNode.light {
            print("\n [ * Light ]")
            print("Intensity: \(light.intensity)")
            print("Shadows: \(light.castsShadow.description)")
            print("Extend: \(light.areaExtents.description)")
            print("Projection: \(light.automaticallyAdjustsShadowProjection.description)\n")
        }
        
        var cameraPOVs:[GamePOV] = []
        
        // Cities
        print("\n [ CITIES ] ")
        let citiesParent = root.childNode(withName: "Cities", recursively: false)!
        for tmpCity in citiesParent.childNodes {
            
            let cityName:String = tmpCity.name ?? "unknown"
            
            guard let posdex:Posdex = Posdex.allCases.filter({ $0.sceneName == cityName }).first  else { continue }
            
            let optCity:DBCity? = cities.filter({ $0.posdex == posdex.rawValue }).first
            
            let gateNode:CityGateNode = CityGateNode(posdex: posdex, city: optCity)
            
            if let mycid = LocalDatabase.shared.player.cityID, mycid == optCity?.id {
                // My City
                print("my city +++")
                if let pov:SCNNode = gateNode.childNode(withName: "POV", recursively: true) {
                    print("*** my city *** - load special? ")
                    let pov = GamePOV(position: pov.position, target: gateNode, name: "Gate", yRange: nil, zRange: nil, zoom: nil)
                    cameraPOVs.append(pov)
                }
            }
            
            // Adjust position to Scene
            gateNode.position = tmpCity.position
            gateNode.eulerAngles = tmpCity.eulerAngles
            citiesParent.addChildNode(gateNode)
            print("City: \(posdex.sceneName). Angles:\(gateNode.eulerAngles) - \(tmpCity.eulerAngles)")
            
        }
        
        // Outposts
        print("\n [ OUTPOSTS ] ")
        let outpostsParent = root.childNode(withName: "Outposts", recursively: false)!
        for child in outpostsParent.childNodes {
            let opNodeName = child.name ?? "unknown"
            if let pp:Posdex = Posdex.allCases.filter({ $0.sceneName == opNodeName }).first {
                
                // Check New Nodes
                
                if let outpost = outposts.filter({ $0.posdex == pp.rawValue }).first {
                    
                    // Power Plants
                    let powerPlantsDexes:[Posdex] = [.power1, .power2, .power3, .power4]
                    if powerPlantsDexes.contains(pp) {
                        let newPowerPlant = PowerPlantNode(posdex: pp, outpost: outpost)
                        newPowerPlant.position = child.position
                        newPowerPlant.eulerAngles = child.eulerAngles
                        outpostsParent.addChildNode(newPowerPlant)
                        
                        child.removeFromParentNode()
                    }
                    
                    // Antenna
                    if pp == .antenna {
                        let antenna = MarsAntennaNode(posdex: pp, outpost: outpost)
                        antenna.position = child.position
                        antenna.eulerAngles = child.eulerAngles
                        outpostsParent.addChildNode(antenna)
                        
                        child.removeFromParentNode()
                    }
                    
                    // Landing Pad - Also Too Big! (0.25?)
                    if pp == .launchPad {
                        let lPad = LandingPadNode(posdex: pp, outpost: outpost)
                        lPad.position = child.position
                        lPad.eulerAngles = child.eulerAngles
                        outpostsParent.addChildNode(lPad)
                        
                        child.removeFromParentNode()
                    }
                    
                    // Mining
                    let miningDexes:[Posdex] = [.mining1, .mining2, .mining3]
                    if miningDexes.contains(pp) {
                        let newMining = MiningNode(posdex: pp, outpost: outpost)
                        newMining.position = child.position
                        newMining.eulerAngles = child.eulerAngles
                        outpostsParent.addChildNode(newMining)
                        
                        child.removeFromParentNode()
                    }
                    
                    // Biosphere
                    let bioDexes:[Posdex] = [.biosphere1, .biosphere2]
                    if bioDexes.contains(pp) {
                        let biosphere = BiosphereNode(posdex: pp, outpost: outpost)
                        biosphere.position = child.position
                        biosphere.eulerAngles = child.eulerAngles
                        outpostsParent.addChildNode(biosphere)
                        
                        child.removeFromParentNode()
                    }
                    
                    // Observatory
                    if pp == .observatory {
                        let observatory = ObservatoryNode(posdex: pp, outpost: outpost)
                        observatory.position = child.position
                        observatory.eulerAngles = child.eulerAngles
                        
                        outpostsParent.addChildNode(observatory)
                        
                        child.removeFromParentNode()
                    }
                    
                    
                    print("\(pp.sceneName) | \(outpost.type.rawValue), lvl:\(outpost.level)")
                    
                } else {
                    print("Outpost (unbuilt) | \(pp.sceneName)")
                }
            }
        }
        
        // Camera + POVs
        // CamPovs
        let camParent = scene.rootNode.childNode(withName: "CamPovs", recursively: false)!
//        let camParent = scene.rootNode.childNode(withName: "OtherCams", recursively: false)!
        let topCam = camParent.childNode(withName: "TopCam", recursively: false)!
        let topPov = GamePOV(position: topCam.position, target: terrain, name: "Eagle eye", yRange: nil, zRange: nil, zoom: nil)
        
        cameraPOVs.append(topPov)
        
        for camChild in camParent.childNodes {
            if (camChild.name ?? "").contains("Camera-") {
//                if (camChild.name ?? "").contains("Diag") {
                let dPov = GamePOV(copycat: camChild, name: camChild.name!, yRange: nil, zRange: nil, zoom: nil)
//                let diagPov = GamePOV(position: camChild.position, target: camParent, name: camChild.name!, yRange: nil, zRange: nil, zoom: nil)
                cameraPOVs.append(dPov)
            }
        }
        
        let gameCam = GameCamera(pov: cameraPOVs.first!, array: cameraPOVs)
        scene.rootNode.addChildNode(gameCam)
        
        
        // EVehicle Animation
        let vehicleScene = SCNScene(named: "Art.scnassets/Mars/EVehicle.scn")
        if let vehicle = vehicleScene?.rootNode.childNode(withName: "EVehicle", recursively: false)?.clone() {
            print("Found Vehicle")
            
            let roadBuilder = RoadsBuilder()
            var pathToFollow = roadBuilder.makeMainRoad()
            vehicle.position = pathToFollow.first!
            
            root.addChildNode(vehicle)
            
            // Actions to Move Vehicle
            var vehicleActions:[SCNAction] = []
            
            // Orientation Node
            let orientationNode = SCNNode()
            root.addChildNode(orientationNode)
            
            // Actions for the orientation node
            var orientationActions:[SCNAction] = []
            
            // Constraint vehicle to look at orientationNode
            let shipLook = SCNLookAtConstraint(target: orientationNode)
            shipLook.localFront = SCNVector3(0, 0, 1)
            shipLook.worldUp = SCNVector3(0, 1, 0)
            shipLook.isGimbalLockEnabled = true
            vehicle.constraints = [shipLook]
            
            // Populate Path Animations
            while !pathToFollow.isEmpty {
                
                pathToFollow.remove(at: 0)
                if let next = pathToFollow.first {
                    
                    let act = SCNAction.move(to: next, duration: 0.4)
                    
                    if pathToFollow.count > 1 {
                        let dest = pathToFollow[1]
                        let oriact = SCNAction.move(to: dest, duration: 0.4)
                        orientationActions.append(oriact)
                    }
                    
                    vehicleActions.append(act)
                    
                    // add box
//                    let box = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
//                    let boxNode = SCNNode(geometry: box)
//                    boxNode.geometry?.materials.first?.diffuse.contents = NSColor.blue
//                    boxNode.position = SCNVector3(Double(next.x), Double(next.y + 0.4), Double(next.z))
//                    scene.rootNode.addChildNode(boxNode)
                }
            }
            
            // Animate Orientation node
            let oriSequence = SCNAction.sequence(orientationActions)
            orientationNode.runAction(oriSequence)
            
            // Animate Vehicle node
            let sequence = SCNAction.sequence(vehicleActions)
            vehicle.runAction(sequence) {
                print("Vehicle finished sequence")
            }
            
        } else {
            print(" _+_+_+_+_+ No Vehicle")
        }
        // EVehicle
        
        
        return self.scene
        
    }
}

extension Posdex {
    
    func extractModel() -> SCNNode? {
        switch self {
//            case .city1, .city2, .city3, .city4, .city5, .city6, .city7, .city8, .city9:
//                return SCNScene(named: "Art.scnassets/Mars/Gate2.scn")!.rootNode.childNodes.first!
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
            default: return nil
        }
    }
}
