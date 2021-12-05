//
//  MarsBuilder.swift
//  SkyNation
//
//  Created by Carlos Farini on 3/9/21.
//

import Foundation
import SceneKit

/**
 This class is responsible for building the nodes required to present Mars Scene.
 */
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
    
    // New: 11/29/2021
    var guildMap:GuildMap?
    
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
                DispatchQueue.main.async {
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
    
    func fetchGuildMap(randomized:Bool = false) {
        
        print("Requesting Guild Map for scene.")
        
        if randomized == false {
            ServerManager.shared.requestGuildMap { gMap, error in
                if let gMap = gMap {
                    print("Guild map request returned for guild \(gMap.name)")
                    self.guildMap = gMap
                } else {
                    print("Guild map request returned error: \(error?.localizedDescription ?? "n/a")")
                }
            }
        } else {
            // Make a Guildmap
            // let guildmap = GuildMap()
            print("Needs to build a Guildmap with some info")
            self.guildMap = GuildMap()
        }
    }
    
    /// Gets all vehicles that arrived
    func getArrivedVehicles() {
        print("Getting Arrived Vehicles")
        SKNS.arrivedVehiclesInGuildMap() { gVehicles, error in
            DispatchQueue.main.async {
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
        
        // deprecate when ready.
        getServerInfo()
        
        // Get guildMap
        fetchGuildMap(randomized: false)
        
        // Load CityData
        self.myCityData = LocalDatabase.shared.cityData
    }
    
    // Load Scene
    private class func loadScene() -> SCNScene? {
        // let nextScene = SCNScene(named: "Art.scnassets/Mars/MarsMap.scn")
        let nextScene = SCNScene(named: "Art.scnassets/Mars/GuildMap.scn")
        return nextScene
    }
    
}

// MARK: - Scene

extension MarsBuilder {
    
    func populateScene() -> SCNScene {
        
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
        
        // Guild Mission
        /*
         Guild missions can add scene decorations, unlock outposts, unlock cities, and more.
         
         */
        var unlockedPosdexes:[Posdex] = []
        
        if let guildMap = guildMap {
            print("\n\n  Guild Map is here !!!")
            if let mission:GuildMission = guildMap.mission {
                print("Mission is here !!!")
                print("Mission \(mission.mission.missionTitle)")
                let models:[SCNNode] = mission.getModels()
                let decoLayer = root.childNode(withName: "Environment", recursively: false)!
                for model in models {
                    decoLayer.addChildNode(model)
                }
                // let unlock:[Posdex] = mission.unlockedPosdexes()
                unlockedPosdexes = mission.unlockedPosdexes()
            }
        } else {
            print("\n\n No Guildmap :(")
        }
        
        /*
         Cities and Outposts are loaded from empty nodes. Make sure to add those nodes to the scene, and then cross-check with GuildMap
         - Six Cities is the new limit
         - check if they can be loaded with 'placeholder'
         - Guilds should start with just one outpost (power plant)
         - add more power with some missions
         - observatory can generate money (Sky Coins)?
         - Disable all 'president' keys from server. Use governor (UUID) instead
         */
        
        // Cities
        print("\n [ CITIES ] ")
        let citiesParent = root.childNode(withName: "Cities", recursively: false)!
        for tmpCity in citiesParent.childNodes {
            
            let cityName:String = tmpCity.name ?? "unknown"
            
            guard let posdex:Posdex = Posdex.allCases.filter({ $0.sceneName == cityName }).first  else { continue }
            
            let optCity:DBCity? = cities.filter({ $0.posdex == posdex.rawValue }).first
            
            // Hide the Cities that aren't unlocked
            if optCity == nil && unlockedPosdexes.contains(posdex) == false {
                continue
            }
            
            // Create the gate node
            let gateNode:CityGateNode = CityGateNode(posdex: posdex, city: optCity)
            
            // Adjust position to Scene
            gateNode.position = tmpCity.position
            gateNode.eulerAngles = tmpCity.eulerAngles
            citiesParent.addChildNode(gateNode)
        
            // My City
            if let mycid = LocalDatabase.shared.player.cityID, mycid == optCity?.id {
                if let pov:SCNNode = gateNode.childNode(withName: "POV", recursively: true) {
                    print("loading my city gate node.")
                    let camPov = pov.childNode(withName: "Camera", recursively: false)!
                    
                    let pov = GamePOV(position: camPov.worldPosition, target: gateNode, name: "Gate", yRange: nil, zRange: nil, zoom: nil)
                    cameraPOVs.append(pov)
                }
            }
            
            print("City: \(posdex.sceneName). Angles:\(gateNode.eulerAngles) - \(tmpCity.eulerAngles)")
        }
        
        // Outposts
        print("\n [ OUTPOSTS ] ")
        let outpostsParent = root.childNode(withName: "Outposts", recursively: false)!
        for child in outpostsParent.childNodes {
            let opNodeName = child.name ?? "unknown"
            
            if let pp:Posdex = Posdex.allCases.filter({ $0.sceneName == opNodeName }).first {
                
                if unlockedPosdexes.contains(pp) == false {
                    continue
                }
                
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
                        print("Launch Pad - Landing Pad")
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
        let camParent = scene.rootNode.childNode(withName: "CamPovs", recursively: false)!
        let topCam = camParent.childNode(withName: "TopCam", recursively: false)!
        let topPov = GamePOV(position: topCam.position, target: terrain, name: "Eagle eye", yRange: nil, zRange: nil, zoom: nil)
        
        cameraPOVs.append(topPov)
        
        for camChild in camParent.childNodes {
            if (camChild.name ?? "").contains("Camera-") {
                let dPov = GamePOV(copycat: camChild, name: camChild.name!, yRange: nil, zRange: nil, zoom: nil)
                cameraPOVs.append(dPov)
            }
        }
        
        let gameCam = GameCamera(pov: cameraPOVs.first!, array: cameraPOVs, gameScene: .MarsColony)
        scene.rootNode.addChildNode(gameCam)
        
        // Roads
        let roadsScene = SCNScene(named: "Art.scnassets/Mars/MarsRoads2.scn")! // "Art.scnassets/Mars/MarsRoads.scn"
        if let guildMap = guildMap,
           let mission = guildMap.mission {
            // load the correct roads
            let roadNames = mission.unlockedRoads()
            for roadNode in roadsScene.rootNode.childNodes {
                if let roadName = RoadsBuilder.MarsRoadNames(rawValue: roadNode.name ?? "--") {
                    if roadNames.contains(roadName) == true {
                        let roadClone = roadNode.clone()
                        scene.rootNode.addChildNode(roadClone)
                    }
                }
            }
        } else {
            print("Loading all roads because couldn't find guildmap.mission")
            for roadNode in roadsScene.rootNode.childNodes {
                print("Adding road \(roadNode.name ?? "n/a")")
                let roadClone = roadNode.clone()
                scene.rootNode.addChildNode(roadClone)
            }
        }
        
        // EVehicle Animation
        let vehicleScene = SCNScene(named: "Art.scnassets/Mars/EVehicle.scn")
        if let vehicle = vehicleScene?.rootNode.childNode(withName: "EVehicle", recursively: false)?.clone() {
            print("Found Vehicle")
            
            // Road Builder
            let randomRoad = RoadsBuilder.MarsRoadNames.allCases.randomElement()!
            
            let roadBuilder = RoadsBuilder()
            var pathToFollow = roadBuilder.makeRoad(named: randomRoad) // roadBuilder.makeMainRoad()
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
                    
                    let act = SCNAction.move(to: next, duration: 0.9)
                    
                    if pathToFollow.count > 1 {
                        let dest = pathToFollow[1]
                        let oriact = SCNAction.move(to: dest, duration: 0.9)
                        orientationActions.append(oriact)
                    }
                    
                    vehicleActions.append(act)
                    
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

extension GuildMission {
    
    /**
     Gets the SceneKit models that should load up to this point in the mission.
     note that this is not a recursive functio. It should be ran only once to load all models.
     */
    func getModels() -> [SCNNode] {
        
        var models:[SCNNode] = []
        
        // Decor Scene
        let decoLayer = SCNScene(named: "Art.scnassets/Mars/MarsDeco.scn")!.rootNode
        
        // Notes:
        /*
         Don't forget to set the name of the node, location, euler angles, etc.
         */
        if mission.rawValue > MissionNumber.arrival.rawValue {
            
            // load arrival nodes
            models.append(SCNNode())
            
            if mission.rawValue > MissionNumber.elevatorLift.rawValue {
                // load elevator lift
                if let elevator = decoLayer.childNode(withName: "Elevator", recursively: false)?.clone() {
                    models.append(elevator)
                    if let car = elevator.childNode(withName: "ElevatorCar", recursively: false),
                       let posBottom = elevator.childNode(withName: "ElevPosBottom", recursively: false),
                       let posTop = elevator.childNode(withName: "ElevPosTop", recursively: false) {
                        car.position = posTop.position
                        let wait = SCNAction.wait(duration: 8.0)
                        let move = SCNAction.move(to: posBottom.position, duration: 8.0)
                        let moveBack = SCNAction.move(to: posTop.position, duration: 8.0)
                        let sequence = SCNAction.sequence([wait, move, wait, moveBack, wait])
                        let rep = SCNAction.repeatForever(sequence)
                        car.runAction(rep)
                    } else {
                        print("⚠️ Elevator car not animating")
                    }
                } else {
                    print("⚠️ Elevator car not animating")
                }
            }
            
        }
        
        return models
    }
    
    /**
     The `Posdex` array that is currently unlocked at this stage of the mission.
     */
    func unlockedPosdexes() -> [Posdex] {
        
        var unlocked:[Posdex] = [.city1, .city2, .launchPad, .power1, .power2]
        
        // example code. Needs updating
        // check if above certain part of mission, then add the posdex
        if mission.rawValue > MissionNumber.city3.rawValue {
            unlocked.append(.city3)
        }
        if mission.rawValue > MissionNumber.city4.rawValue {
            unlocked.append(.city4)
        }
        
        // Outposts
        // Water Mining
        if mission.rawValue > MissionNumber.unlockWaterMining.rawValue {
            unlocked.append(.mining1)
        }
        // Bio
        if mission.rawValue > MissionNumber.unlockBiosphere1.rawValue {
            unlocked.append(.biosphere1)
        }
        if mission.rawValue > MissionNumber.unlockBiosphere2.rawValue {
            unlocked.append(.biosphere2)
        }
        // power
        if mission.rawValue > MissionNumber.unlockPower3.rawValue {
            unlocked.append(.power3)
        }
        if mission.rawValue > MissionNumber.unlockPower4.rawValue {
            unlocked.append(.power4)
        }
        
        return unlocked
    }
    
    /**
     The Roads of the map that should be displaying..
     */
    func unlockedRoads() -> [RoadsBuilder.MarsRoadNames] {
        
        var roadsUnlocked:[RoadsBuilder.MarsRoadNames] = [.mainRoad]
        
        // example code. Needs updating
        // check if above certain part of mission, then add the posdex
        
        if mission.rawValue > MissionNumber.southTourRoad.rawValue {
            roadsUnlocked.append(.southTourRoad)
        }
        if mission.rawValue > MissionNumber.westRoad.rawValue {
            roadsUnlocked.append(.westRoad)
        }
        
        return roadsUnlocked
    }
}
