//
//  StationBuilder.swift
//  SkyNation
//
//  Created by Carlos Farini on 1/31/21.
//

import Foundation
import SceneKit

/**
 A Class that Builds the Space `Station` Object to make a `SCNScene`
    - Maybe it doesnt need to be `Codable`. Not being stored, anyways. */
class StationBuilder { //:Codable {
    
    /// Items involved in building the Space Station scene.
    var buildList:[StationBuildItem]
    
    // Camera
    var gameCamera:GameCamera?
    
    /// The `Space Station` Scene that is built
    var scene:SCNScene?
    
    /*
     var isNewGame:Bool
     
     var cameras:[GameCamera]
     var currentCamera:GameCamera
     
     var news:[String]
     
     var scene:SCNScene!
     static var originScene:SCNScene
     
     func rebuild?
     
     [ callbacks ] - protocol?
     - display news
     - update scene
     - control scene animations?
     - update Overlay
     
     */
    
    // MARK: - Initializers
    
    
    // Initialize the array with node0, node1, .modf, .mod0, .mod1
    /// Initializes the scene for the first time.
    init() {
        // 5 Initial Objects
        // Create node0, and node1
        // Create mod0, mod1, mod2
        
        // First Node
        let node0 = StationBuildItem(pos: Vector3D(x: 0, y: -12, z: 0), euler: Vector3D.zero, type: .Node)
        // Module facing down
        let module0 = StationBuildItem(module: .mod0) //BuildItem(module: .mod0)
        
        // Second Node (Top left)
        let node2 = StationBuildItem(pos: Vector3D.zero, euler: Vector3D.zero, type: .Node)
        
        // Front Module, and back (mod1, mod2)
        let moduleFront = StationBuildItem(module: .mod1)
        let moduleBack = StationBuildItem(module: .mod2)
        
        self.buildList = [node0, module0, node2, moduleFront, moduleBack]
        
    }
    
    
    /// Initialize with a `Station`, if there is one
    init(station:Station) {
        
        // First Node
        let node0 = StationBuildItem(pos: Vector3D(x: 0, y: -12, z: 0), euler: Vector3D.zero, type: .Node)
        // Second Node (Top left)
        let node1 = StationBuildItem(pos: Vector3D.zero, euler: Vector3D.zero, type: .Node)
        
        var arrayOfNodes:[StationBuildItem] = [node0, node1]
        var arrayOfModules:[StationBuildItem] = []
        
        for module in station.modules {
            
            let modex = module.moduleDex
            
            let newModule = StationBuildItem(module: modex)
            // Assign ID
            newModule.id = module.id
            // Module Skin
            newModule.skin = module.skin
            
            // let p = module.moduleDex.position()
            
            arrayOfModules.append(newModule)
            
        }
        
        for tech in station.unlockedTechItems {
            switch tech {
                case .node2:
                    // Node 2
                    let node2 = StationBuildItem(pos: Vector3D(x: 0, y: 0, z: -12), euler: Vector3D.zero, type: .Node)
                    arrayOfNodes.append(node2)
                case .node3:
                    // Node 3
                    let node3 = StationBuildItem(pos: Vector3D(x: 0, y: 0, z: -24), euler: Vector3D.zero, type: .Node)
                    arrayOfNodes.append(node3)
                case .node4:
                    // Node 4
                    let node4 = StationBuildItem(pos: Vector3D(x: 0, y: 0, z: -36), euler: Vector3D.zero, type: .Node)
                    arrayOfNodes.append(node4)
                default: continue
            }
        }
        
        self.buildList = arrayOfNodes + arrayOfModules
    }
    
    // MARK: - Codable
    
    /*
    private enum CodingKeys:String, CodingKey {
        case buildList
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        buildList = try values.decode([StationBuildItem].self, forKey: .buildList)
    }
    */
    
    // MARK: - Items
    
    /// Gets the Modules (for IDs)
    func getModules() -> [Module] {
        var array:[Module] = []
        
        for item in buildList {
            if item.type == .Module {
                guard let modex = ModuleIndex(rawValue:item.modex ?? "") else { fatalError() }
                array.append(Module(id: item.id, modex: modex))
            }
        }
        
        return array
    }
    
    // MARK: - Scene Building
    
    /// Build Scene on Background, to present
    func build(station:Station) {
        
        self.prepareScene(station:station) { scene in
            // Send notification "Finished Scene"
            // So it can present :)
            print("Station Builder has finished building")
            self.scene = scene
        }
        
    }
    
}

// MARK: - SceneKit

extension StationBuilder {
    
    /// Prepares the scene, with a completion handler
    func prepareScene(station:Station, _ completion:(SCNScene) -> ()) {
        
        let scene = SCNScene(named: "Art.scnassets/SpaceStation/SpaceStation.scn")!
        
        // ------------------
        // Main Empty Parents
        // 1. Modules
        // 2. Nodes
        // 3. Tech Items
        // 4. Accessories
        // 5. Lights
        // 6. Truss
        // 7. Camera
        
        // 1. Modules + Nodes
        for buildPart in buildList {
            print("Build: \(buildPart.type.rawValue)")
            if buildPart.position.x == 0 && buildPart.position.y == -12 && buildPart.position.z == 0 {
                let dock = SCNScene(named: "Art.scnassets/SpaceStation/Accessories/Dock.scn")!
                // Dock
                let node = dock.rootNode.childNode(withName: "Dock", recursively: false)!
                node.name = "Dock"
                scene.rootNode.addChildNode(node)
                
            } else {
                if let newNode = buildPart.loadFromScene() {
                    scene.rootNode.addChildNode(newNode)
                }
            }
            
        }
        
        // 3. Tech Items
        print("Loading unlocked Technology...")
        for item in station.unlockedTechItems {
            
            if let model:SCNNode = item.loadToScene() {
                scene.rootNode.addChildNode(model)

                // Debug
                if GameSettings.debugScene {
                    print("Loading Tech Node for: \(item)")
                }
            }
        }
        
        // 4. Accessories (Antenna)
        let antennaPeripheral = station.truss.antenna
        let antenna = Antenna3DNode(peripheral: antennaPeripheral)
        antenna.position = SCNVector3(20.7, 1.5, 0.0)
        scene.rootNode.addChildNode(antenna)
        
        // 5. Lights
        
        
        // 6. Truss
        
        // Truss (Solar Panels, Radiator, and Roboarm)
        let trussNode = scene.rootNode.childNode(withName: "Truss", recursively: true)!
        
        // Delete Previous Solar Panels
        for child in trussNode.childNodes {
            if child.name == "SolarPanel" {
                print("Removing old solar panel")
                child.removeFromParentNode()
            }
        }
        
        // Add Solar Panels and Radiators to Truss
        for item in station.truss.tComponents {
//            print("Truss Component: \(item.posIndex)")
            guard let pos = item.getPosition() else { continue }
            guard let eul = item.getRotation() else { continue }
            
            switch item.allowedType {
                case .Solar:
                    if item.itemID != nil {
//                        print("Solar Panel: \(item.posIndex) pos:\(pos), euler:\(eul)")
                        let solarScene = SCNScene(named: "Art.scnassets/SpaceStation/Accessories/SolarPanel2.scn")
                        if let solarPanel = solarScene?.rootNode.childNode(withName: "SolarPanel", recursively: true)?.clone() {
                            solarPanel.position = SCNVector3(pos.x, pos.y, pos.z)
                            solarPanel.eulerAngles = SCNVector3(eul.x, eul.y, eul.z)
                            solarPanel.scale = SCNVector3.init(x: 1.5, y: 2.4, z: 2.4)
                            trussNode.addChildNode(solarPanel)
                        }
                    }
                    
                case .Radiator:
//                    print("Radiator slot: \(item.posIndex) pos:\(pos), euler:\(eul)")
                    if item.itemID != nil {
                        print("Radiator: \(item.posIndex) pos:\(pos), euler:\(eul)")
                        let radiatorNode = RadiatorNode()
                        radiatorNode.position = SCNVector3(pos.x, pos.y, pos.z)
                        radiatorNode.eulerAngles = SCNVector3(eul.x, eul.y, eul.z)
                        radiatorNode.scale = SCNVector3.init(x: 1.5, y: 1.5, z: 1.5)
                        radiatorNode.setupAngles(new: nil)
                        trussNode.addChildNode(radiatorNode)
                    } else {
                        continue
                    }
                case .RoboArm: continue
                    
            }
        }
        
        
        // Earth or ship (Order)
        if let order = station.earthOrder {
            
            // Load Ship
            print("We have an order! Delivered: \(order.delivered)")
            
            var ship:DeliveryVehicleNode? = DeliveryVehicleNode()
            ship?.position.z = -50
            ship?.position.y = -50 // -17.829
            scene.rootNode.addChildNode(ship!)
            
            #if os(macOS)
            ship?.eulerAngles = SCNVector3(x:90.0 * (.pi/180.0), y:0, z:0)
            #else
            ship?.eulerAngles = SCNVector3(x:90.0 * (Float.pi/180.0), y:0, z:0)
            #endif
            
            // Move
            let move = SCNAction.move(by: SCNVector3(0, 30, 50), duration: 12.0)
            move.timingMode = .easeInEaseOut
            
            // Kill Engines
            let killWaiter = SCNAction.wait(duration: 6)
            let killAction = SCNAction.run { shipNode in
                print("Kill Engines")
                ship?.killEngines()
            }
            let killSequence = SCNAction.sequence([killWaiter, killAction])
            
            let rotate = SCNAction.rotateBy(x: -90.0 * (.pi/180.0), y: 0, z: 0, duration: 5.0)
            let group = SCNAction.group([move, rotate, killSequence])
            
            ship?.runAction(group, completionHandler: {
                print("Ship arrived at location")
                for child in ship?.childNodes ?? [] {
                    child.particleSystems?.first?.birthRate = 0
                }
            })
        }else{
            
            // Remove Ship
            if let ship = scene.rootNode.childNode(withName: "Ship", recursively: false) {
                ship.removeFromParentNode()
            }
            
            // Load Earth
            let earth = EarthNode()
            scene.rootNode.addChildNode(earth)
        }
        
        
        // 7. Camera
        
        // Create an invisible sphere camera node ?
        // https://stackoverflow.com/questions/25654772/rotate-scncamera-node-looking-at-an-object-around-an-imaginary-sphere
        
        // Remove Old Camera
        if let oldCam = scene.rootNode.childNode(withName: "Camera", recursively: false) {
            oldCam.removeFromParentNode()
        }
        
        // Truss Camera
        let tCam = GamePOV(position: SCNVector3(x: 25, y: 20, z: 20), target:trussNode, name: "Truss", yRange: nil, zRange: nil, zoom: nil)
        var camArray:[GamePOV] = []
        camArray.append(tCam)
        
        if let cuppola = scene.rootNode.childNode(withName: "Cuppola", recursively: false) {
            let pos = SCNVector3(20, 7, cuppola.position.z - 3)
            let cam = GamePOV(position: pos, target: cuppola, name: "Cuppola", yRange: nil, zRange: nil, zoom: nil)
            camArray.append(cam)
        } else if let airlock = scene.rootNode.childNode(withName: "Airlock", recursively: false) {
            let pos = SCNVector3(20, 7, airlock.position.z - 3)
            let cam = GamePOV(position: pos, target: airlock, name: "Airlock", yRange: nil, zRange: nil, zoom: nil)
            camArray.append(cam)
        }
        if let lastNode = scene.rootNode.childNodes.filter({ $0.position.z < -30 && $0.name == "Node1" }).first {
            let pos = SCNVector3(20, 10, lastNode.position.z - 5)
            let cam = GamePOV(position: pos, target: lastNode, name: "Rear", yRange: nil, zRange: nil, zoom: nil)
            camArray.append(cam)
        }
        
        if let garage = scene.rootNode.childNode(withName: "Garage", recursively: false) {
            let cam = GamePOV(position: SCNVector3(10, 5, -65), target: garage, name: "Garage", yRange: nil, zRange: nil, zoom: nil)
            camArray.append(cam)
        }
        
        
        // Game Camera
        let newCamera = GameCamera(pov: camArray.first!, array: camArray, gameScene: .SpaceStation)
        self.gameCamera = newCamera
        
        scene.rootNode.addChildNode(newCamera)
        
        
        // Complete
        completion(scene)
    }
    
}

extension StationBuildItem {
    
    /// Gets the modules and nodes geometries and texture maps.
    func loadFromScene() -> SCNNode? {
        var nodeCount:Int = 1
        switch type {
            case .Node:
                //                print("Load a node")
                let nodeScene = SCNScene(named: "Art.scnassets/SpaceStation/Node2.scn")!
                if let nodeObj = nodeScene.rootNode.childNode(withName: "Node2", recursively: false)?.clone() {
                    nodeObj.name = "Node\(nodeCount)"
                    nodeCount += 1
                    let pos = position
#if os(macOS)
                    nodeObj.position = SCNVector3(x: CGFloat(pos.x), y: CGFloat(pos.y), z: CGFloat(pos.z))
#else
                    nodeObj.position = SCNVector3(pos.x, pos.y, pos.z) // (x:pos.x, y:pos.y, z:pos.z)
#endif
                    return nodeObj
                }else{
                    print("404 not found")
                    return nil
                }
                
            case .Module:
                
                /*
                 Reconstruct
                 Get the correct geometry
                 There are 2 geometries. One for the old materials, and one for the new
                 */
                var model:SCNNode = skin?.getGeometryNode() ?? ModuleSkin.makeANode()
                
                // Position
                let pos = position
#if os(macOS)
                model.position = SCNVector3(x: CGFloat(pos.x), y: CGFloat(pos.y), z: CGFloat(pos.z))
#else
                model.position = SCNVector3(pos.x, pos.y, pos.z)
#endif
                // Change name to id
                model.name = id.uuidString
                
                // rotation
                let vec = rotation
                let sceneVec = SCNVector3(vec.x, vec.y, vec.z)
                model.eulerAngles = sceneVec
                
                return model
                    
                
                /*
                // Geometry
                let moduleScene = SCNScene(named: "Art.scnassets/SpaceStation/Module.scn")!
                if let nodeObj = moduleScene.rootNode.childNode(withName: "Module", recursively: false)?.clone() {
                    
                    let uvMapName = "\(skin?.uvMapName ?? ModuleSkin.allCases.randomElement()!.uvMapName).png"
                    
                    // MATERIAL | SKIN
                    
                    var skinImage:SKNImage?
                    if let bun = Bundle.main.url(forResource: "Art", withExtension: ".scnassets") {
                        let pp = bun.appendingPathComponent("/UV Images/ModuleSkins/\(uvMapName)")
                        if let image = SKNImage(contentsOfFile: pp.path) {
                            //                            print("Found Image")
                            skinImage = image
                        } else {
                            print("\n\t ⚠️ Error: Could not find Skin Image!")
                        }
                    } else {
                        print("\n\t ⚠️ Error: Bundle for Skin not found !")
                    }
                    for material in nodeObj.geometry?.materials ?? [] {
                        print("Material name:\(material.name ?? "n/a")")
                        if let image = skinImage {
                            material.diffuse.contents = image
                        }
                    }
                    if let image = SKNImage(named: uvMapName) {
                        nodeObj.geometry!.materials.first!.diffuse.contents = image
                    }
                    
                    // Position
                    let pos = position
#if os(macOS)
                    nodeObj.position = SCNVector3(x: CGFloat(pos.x), y: CGFloat(pos.y), z: CGFloat(pos.z))
#else
                    nodeObj.position = SCNVector3(pos.x, pos.y, pos.z)
#endif
                    // Change name to id
                    nodeObj.name = id.uuidString
                    
                    let vec = rotation
                    let sceneVec = SCNVector3(vec.x, vec.y, vec.z)
                    nodeObj.eulerAngles = sceneVec
                    
                    return nodeObj
                } else {
                    print("Module not found ID:\(id) \(self.type) ")
                    return nil
                }
                */
                
                
            case .Peripheral, .Truss:
                print("Deprecate ?")
                return nil
        }
    }
}

extension ModuleSkin {
    
    /// Makes a default node
    static func makeANode() -> SCNNode {
        
        guard let moduleScene = SCNScene(named: "Art.scnassets/SpaceStation/Module.scn"),
              let buildingNode:SCNNode = moduleScene.rootNode.childNode(withName: "ModuleB", recursively: false)?.clone() else {
            fatalError()
              }
        
        let random:ModuleSkin = ModuleSkin.BatteryMod
        
        // These materials are more complex
        
        let myMat = buildingNode.geometry?.materials.first(where: { $0.name == "Bingo" })
        if let myMat = myMat {
            if let folder = random.textureFolder {
                
                // Color
                if let albedo = random.albedo {
                    myMat.diffuse.contents = SKNImage(contentsOfFile: folder.appendingPathComponent(albedo).path)
                } else {
                    myMat.diffuse.contents = SCNColor.white
                }
                
                if let ao = random.occlusion {
                    myMat.ambientOcclusion.contents = SKNImage(contentsOfFile: folder.appendingPathComponent(ao).path)
                } else {
                    myMat.ambientOcclusion.contents = SCNColor.white
                }
                
                if let metalic = random.metalic {
                    myMat.metalness.contents = SKNImage(contentsOfFile: folder.appendingPathComponent(metalic).path)
                } else {
                    myMat.metalness.contents = 0.0
                }
                if let rough = random.roughness {
                    myMat.roughness.contents = SKNImage(contentsOfFile: folder.appendingPathComponent(rough).path)
                } else {
                    myMat.roughness.contents = 0.5
                }
                if let normal = random.normal {
                    myMat.normal.contents = SKNImage(contentsOfFile: folder.appendingPathComponent(normal).path)
                } else {
                    myMat.normal.contents = nil
                }
            }
        }
        
        
        return buildingNode
    }
    
    /// Returns the correct geometry for this material
    func getGeometryNode() -> SCNNode? {
        
        guard let moduleScene = SCNScene(named: "Art.scnassets/SpaceStation/Module.scn") else {
            print("Something wrong with Module Scene.")
            return nil
        }
        
        // Start building node
        var buildingNode:SCNNode?
        var isSingleMaterial:Bool = true
        
        // Get the correct geometry
        switch self {
            case .ModuleBake, .diffuse1, .BioModule, .LabModule, .HabModule:
                buildingNode = moduleScene.rootNode.childNode(withName: "Module", recursively: false)?.clone()
            case .BatteryMod, .Capsule, .Drawing, .Panels, .SleekCables:
                isSingleMaterial = false
                buildingNode = moduleScene.rootNode.childNode(withName: "ModuleB", recursively: false)?.clone()
        }
        
        guard let buildingNode:SCNNode = buildingNode else {
            print("Could not get the main node")
            return nil
        }

        
        if isSingleMaterial == true {
            // single material
            if let folder = textureFolder,
               let image = albedo {
                let tmpPath = folder.appendingPathComponent(image).path
                print("Path: \(tmpPath)")
                
                buildingNode.geometry?.materials.first?.diffuse.contents = SKNImage(contentsOfFile: folder.appendingPathComponent(image).path)
                    
            }
        } else {
            
            // These materials are more complex
            
            let myMat = buildingNode.geometry?.materials.first(where: { $0.name == "Bingo" })
            if let myMat = myMat {
                if let folder = textureFolder {
                    // Color
                    if let albedo = albedo {
                        myMat.diffuse.contents = SKNImage(contentsOfFile: folder.appendingPathComponent(albedo).path)
                    } else {
                        myMat.diffuse.contents = SCNColor.white
                    }
                    if let ao = occlusion {
                        myMat.ambientOcclusion.contents = SKNImage(contentsOfFile: folder.appendingPathComponent(ao).path)
                    } else {
                        myMat.ambientOcclusion.contents = SCNColor.white
                    }
                    if let metalic = metalic {
                        myMat.metalness.contents = SKNImage(contentsOfFile: folder.appendingPathComponent(metalic).path)
                    } else {
                        myMat.metalness.contents = 0.0
                    }
                    if let rough = roughness {
                        myMat.roughness.contents = SKNImage(contentsOfFile: folder.appendingPathComponent(rough).path)
                    } else {
                        myMat.roughness.contents = 0.5
                    }
                    if let normal = normal {
                        myMat.normal.contents = SKNImage(contentsOfFile: folder.appendingPathComponent(normal).path)
                    } else {
                        myMat.normal.contents = nil
                    }
                }
            }
        }
        
        return buildingNode
    }
}


// MARK: - Animations from Space Station

extension GameController {
    
    /// Brings the Earth, to order - Removes the Ship
    func deliveryIsOver() {
        
        guard gameScene == .SpaceStation else { return }
        
        print("Animating ship out of scene")
        
        // Animate the ship out of the scene
        if let ship = scene.rootNode.childNode(withName: "Ship", recursively: false) as? DeliveryVehicleNode {
            
            // Remove Delivery Vehicle
            ship.beginExitAnimation()
            
            // Load Earth
            let earth = EarthNode()
            scene.rootNode.addChildNode(earth)
            
            earth.beginEntryAnimation()
            
            
        } else {
            print("ERROR - Could not find Delivery Vehicle, A.K.A. Ship")
        }
    }
    
    /// Removes the earth, add the Ship
    func deliveryIsArriving() {
        
        guard gameScene == .SpaceStation else { return }
        gameOverlay.generateNews(string: "📦 Delivery arriving...")
        
        // Remove the earth
        if let earth = scene.rootNode.childNode(withName: "Earth", recursively: true) as? EarthNode {
            
            earth.beginExitAnimation()
            print("Earth going, Ship arriving")
            
            
            // Load Ship
            var ship:DeliveryVehicleNode? = DeliveryVehicleNode()
            ship?.position.z = -50
            ship?.position.y = -50 // -17.829
            scene.rootNode.addChildNode(ship!)
            
#if os(macOS)
            ship?.eulerAngles = SCNVector3(x:90.0 * (.pi/180.0), y:0, z:0)
#else
            ship?.eulerAngles = SCNVector3(x:90.0 * (Float.pi/180.0), y:0, z:0)
#endif
            
            // Move
            let move = SCNAction.move(by: SCNVector3(0, 30, 50), duration: 12.0)
            move.timingMode = .easeInEaseOut
            
            // Kill Engines
            let killWaiter = SCNAction.wait(duration: 6)
            let killAction = SCNAction.run { shipNode in
                print("Kill Waiter")
                ship?.killEngines()
            }
            let killSequence = SCNAction.sequence([killWaiter, killAction])
            
            let rotate = SCNAction.rotateBy(x: -90.0 * (.pi/180.0), y: 0, z: 0, duration: 5.0)
            let group = SCNAction.group([move, rotate, killSequence])
            
            ship?.runAction(group, completionHandler: {
                print("Ship arrived at location")
                for child in ship?.childNodes ?? [] {
                    child.particleSystems?.first?.birthRate = 0
                }
            })
            
        } else {
            print("ERROR - Could not the earth !!!")
            
            
            
        }
    }
    
    /// Updates Which Solar Panels to show on the Truss, and Roboarm
    func updateTrussLayout() {
        
        // Truss (Solar Panels)
        print("Truss Layout Update:")
        let trussNode = scene.rootNode.childNode(withName: "Truss", recursively: true)!
        
        // Delete Previous Solar Panels
        for child in trussNode.childNodes {
            if child.name == "SolarPanel" {
                print("Removing old solar panel")
                child.removeFromParentNode()
            }
        }
        
        for item in station?.truss.tComponents ?? [] {
            print("Truss Component: \(item.posIndex)")
            guard let pos = item.getPosition() else { continue }
            guard let eul = item.getRotation() else { continue }
            switch item.allowedType {
                case .Solar:
                    if item.itemID != nil {
                        print("Solar Panel: \(item.posIndex) pos:\(pos), euler:\(eul)")
                        let solarScene = SCNScene(named: "Art.scnassets/SpaceStation/Accessories/SolarPanel2.scn")
                        if let solarPanel = solarScene?.rootNode.childNode(withName: "SolarPanel", recursively: true)?.clone() {
                            solarPanel.position = SCNVector3(pos.x, pos.y, pos.z)
                            solarPanel.eulerAngles = SCNVector3(eul.x, eul.y, eul.z)
                            solarPanel.scale = SCNVector3.init(x: 1.5, y: 2.4, z: 2.4)
                            trussNode.addChildNode(solarPanel)
                        }
                    }
                case .Radiator:
                    print("Radiator slot: \(item.posIndex) pos:\(pos), euler:\(eul)")
                    if item.itemID != nil {
                        print("Radiator: \(item.posIndex) pos:\(pos), euler:\(eul)")
                        let radiatorNode = RadiatorNode()
                        radiatorNode.position = SCNVector3(pos.x, pos.y, pos.z)
                        radiatorNode.eulerAngles = SCNVector3(eul.x, eul.y, eul.z)
                        radiatorNode.scale = SCNVector3.init(x: 1.5, y: 1.5, z: 1.5)
                        radiatorNode.setupAngles(new: nil)
                        trussNode.addChildNode(radiatorNode)
                    } else {
                        continue
                    }
                case .RoboArm: continue
                    
            }
        }
    }
    
    /// Reloads the Station Scene with new tech items
    func loadLastBuildItem() {
        print("Loading last build item")
        let builder = LocalDatabase.shared.reloadBuilder(newStation: self.station)
        let lastTech = builder.buildList.last
        if let theNode = lastTech?.loadFromScene() {
            print("Found node to build last tech item: \(theNode.name ?? "n/a")")
            if lastTech?.type == .Module {
                if let lastModule = LocalDatabase.shared.station.modules.last {
                    self.modules.append(lastModule)
                    theNode.name = lastModule.id.uuidString
                }
            }
            scene.rootNode.addChildNode(theNode)
        }
    }
}

/**
 Build Item: Modules, Nodes, and main scene data. Part of the `StationBuilder` object */
class StationBuildItem:Codable {
    
    var id:UUID
    var position:Vector3D
    var rotation:Vector3D
    var type:BuildComponent //(node, module)
    
    var skin:ModuleSkin?
    var modex:String?
    
    /// To init from StationBuilder
    init(pos:Vector3D, euler:Vector3D, type:BuildComponent?) {
        self.id = UUID()
        self.position = pos
        self.rotation = euler
        self.type = type ?? .Node
    }
    
    /// To Init with a Module Index
    init(module modex:ModuleIndex) {
        self.id = UUID()
        self.position = modex.position()
        self.rotation = modex.orientation().vector
        self.type = .Module
        self.skin = ModuleSkin.allCases.randomElement()! //"ModuleColor"
        self.modex = modex.rawValue
    }
    
}

// MARK: - Module + Builder Enums

/// The type of BuildItemfor the **StationBuilder**
enum BuildComponent:String, Codable, CaseIterable {
    case Node
    case Module
    case Truss
    case Peripheral
}

