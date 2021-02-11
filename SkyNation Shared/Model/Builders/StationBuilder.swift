//
//  StationBuilder.swift
//  SkyNation
//
//  Created by Carlos Farini on 1/31/21.
//

import Foundation
import SceneKit

/// The type of BuildItemfor the **SerialBuilder**
enum BuildComponent:String, Codable, CaseIterable {
    case Node
    case Module
    case Truss
    case Peripheral
}

/// The indexes where `Module` objects can be placed
enum ModuleIndex:String, Codable, CaseIterable {
    
    // mod0 is the one facing down, mod1 is the Front
    case mod0, mod1, mod2, mod3, mod4, mod5, mod6, mod7, mod8, mod9, mod10 //, modGarage
    
    func position() -> Vector3D {
        switch self {
            case .mod0: return Vector3D(x: 0, y: -2, z: 0)
            case .mod1: return Vector3D(x: 0, y: 0, z: 2)
            case .mod2: return Vector3D(x: 0, y: 0, z: -10)
            case .mod3: return Vector3D(x: 0, y: 0, z: -22)
            case .mod4: return Vector3D(x: 0, y: 0, z: -34)
            case .mod5: return Vector3D(x: 0, y: 0, z: -46)
            case .mod6: return Vector3D(x: 0, y: -2, z: -12)
            case .mod7: return Vector3D(x: 0, y: -2, z: 0) // Doesn't exist
            case .mod8: return Vector3D(x: 0, y: -2, z: -36)
            case .mod9: return Vector3D(x: 0, y: 2, z: -36)
            case .mod10: return Vector3D(x: 0, y: -2, z: -24)
            //            case .modGarage: return Vector3D(x: 0, y: 0, z: -46)
        }
    }
    
    func orientation() -> Orientation3D {
        switch self {
            case .mod0: return .Down
            case .mod6: return .Down
            case .mod8: return .Down
            case .mod9: return .Up
            case .mod10: return .Down
                
            default: return .Front
        }
    }
}

/// The Material to go on the Module.
enum ModuleSkin:String, Codable, CaseIterable {
    
    case ModuleBake
    case diffuse1
    case BioModule
    case LabModule
    case HabModule
    
    /// The name to display from the menu
    var displayName:String {
        switch self {
            case .BioModule: return "Biology"
            case .HabModule: return "Habitation"
            case .LabModule: return "Laboratory"
            case .ModuleBake: return "Do not touch"
            case .diffuse1: return "Default"
        }
    }
    
    /// The name (path) of the UV to load
    var uvMapName:String {
        switch self {
            case .BioModule: return "BioModule"
            case .HabModule: return "HabModule"
            case .LabModule: return "LabModule"
            case .ModuleBake: return "ModuleBake4"
            case .diffuse1: return "ModuleDif1"
        }
    }
}

/**
 A Class that Builds the Space `Station` Object to make a `SCNScene` */
class StationBuilder:Codable {
    
    // Single Dimensional Array
    var buildList:[StationBuildItem]
    var lights:[BuildableLight] = []
    var scene:SCNScene?
    
    // MARK: - Initializers
    
    // Initting
    // Initialize the array with node0, node1, .modf, .mod0, .mod1
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
            
            arrayOfModules.append(newModule)
            
            //            switch modex {
            //                case .mod3:
            //                    // Node 2
            //                    let node2 = StationBuildItem(pos: Vector3D(x: 0, y: 0, z: -12), euler: Vector3D.zero, type: .Node)
            //                    arrayOfNodes.append(node2)
            //                case .mod4:
            //                    // Node 3
            //                    let node3 = StationBuildItem(pos: Vector3D(x: 0, y: 0, z: -24), euler: Vector3D.zero, type: .Node)
            //                    arrayOfNodes.append(node3)
            //                case .mod5:
            //                    // Node 4
            //                    let node4 = StationBuildItem(pos: Vector3D(x: 0, y: 0, z: -36), euler: Vector3D.zero, type: .Node)
            //                    arrayOfNodes.append(node4)
            //                default:
            //                    continue
            //            }
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
        
        // Lights
        
    }
    
    // MARK: - Codable
    
    private enum CodingKeys:String, CodingKey {
        case buildList
        case lights
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        buildList = try values.decode([StationBuildItem].self, forKey: .buildList)
        lights = try values.decodeIfPresent([BuildableLight].self, forKey: .lights) ?? []
    }
    
    // MARK: - Items
    
    /// sets the lights to the buildable pieces array
    func loadLights(lights:[BuildableLight]) {
        print("Loading lights")
        self.lights = lights
    }
    
    /// Adds tech to the array of buildable parts
    func loadTechTree(tech:[TechItems]) {
        print("Load Tech tree items here")
    }
    
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
            // Send notification "Finished Scene" to GameController
            // So it can present :)
            print("Scene Building has finished building")
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
        // 6. Camera
        // 7. Truss
        
        // 1. Modules + Nodes
        for buildPart in buildList {
            print("Build part type: \(buildPart.type.rawValue)")
            if let newNode = buildPart.loadFromScene() {
                scene.rootNode.addChildNode(newNode)
            }
        }
        
        // 3. Tech Items
        for item in station.unlockedTechItems {
            print("Display item for tech: \(item)")
            if let model = item.loadToScene() {
                scene.rootNode.addChildNode(model)
            }
        }
        
        // 4. Accessories (Antenna)
        let antenna = Antenna3DNode()
        antenna.position = SCNVector3(22.0, 1.5, 0.0)
        scene.rootNode.addChildNode(antenna)
        
        // 5. Lights
        // Folder >> Lights?
        
        // 6. Camera
        
        // Create an invisible sphere camera node ?
        // https://stackoverflow.com/questions/25654772/rotate-scncamera-node-looking-at-an-object-around-an-imaginary-sphere
        
        // Remove Old Camera
        if let oldCam = scene.rootNode.childNode(withName: "Camera", recursively: false) {
            oldCam.removeFromParentNode()
        }
        
//        let camera = SCNCamera()
//        camera.usesOrthographicProjection = false
//        camera.focalLength = 150
//        camera.fieldOfView = 9.148
//        camera.sensorHeight = 24
//        camera.zNear = 0.1
//        camera.zFar = 500
//
//        let cameraNode = SCNNode()
//        cameraNode.position = SCNVector3(x: 105, y: 75, z: 135)
//        cameraNode.camera = camera
//
//        let cameraOrbit = SCNNode()
//        cameraOrbit.name = "cameraOrbit"
//        cameraOrbit.position = SCNVector3(x: 0, y: 0, z: 0)
//
//        cameraOrbit.addChildNode(cameraNode)
//        scene.rootNode.addChildNode(cameraOrbit)
        
        let newCamera = GameCamera()
        scene.rootNode.addChildNode(newCamera)

        // ------------------------------------
        
        
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
            print("Truss Component: \(item.posIndex)")
            guard let pos = item.getPosition() else { continue }
            guard let eul = item.getRotation() else { continue }
            switch item.allowedType {
                case .Solar:
                    if item.itemID != nil {
                        print("Solar Panel: \(item.posIndex) pos:\(pos), euler:\(eul)")
                        let solarScene = SCNScene(named: "Art.scnassets/SpaceStation/Accessories/SolarPanel.scn")
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
        }else{
            if let ship = scene.rootNode.childNode(withName: "Ship", recursively: false) {
                ship.removeFromParentNode()
            }
            
            // Load Earth
            let earth = SCNScene(named: "Art.scnassets/Earth.scn")!.rootNode.childNode(withName: "Earth", recursively: true)!.clone()
            earth.position = SCNVector3(0, -18, 0)
            
            scene.rootNode.addChildNode(earth)
        }
        
        // NEWS
        // Check Activities
//        var newsLines:[String] = []
//        if gameScene == .SpaceStation {
//            if let labs = station?.labModules {
//                for lab in labs {
//                    print("*** Found lab: \(lab.id)")
        
        // ------------------
        // Post Notification Scene is ready

        // Tell SceneDirector that scene is loaded
//        SceneDirector.shared.controllerDidLoadScene(controller: self)
        
        // Store Property
//        self.scene = scene
        
        // Complete
        completion(scene)
    }
    
    
    
}

/**
 Build Item: Modules, Nodes, and main scene data. Part of the `StationBuilder` object */
class StationBuildItem:Codable {
    
    var id:UUID
    var position:Vector3D
    var rotation:Vector3D
    var type:BuildComponent //(node, module)
    
    // (Not needed)
    // var researched:Bool
    var skin:String?
    var modex:String?
    // static func makeFromTech
    
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
        self.skin = "ModuleColor"
        self.modex = modex.rawValue
    }
    
    
}

/// A Struct that represents a `Light node` to be added to the scene
struct BuildableLight:Codable {
    
    var id:UUID
    
    var lightSwitch:Bool
    var lightIndex:Int
    
    // Color
    var red:Double
    var green:Double
    var blue:Double
    
    var intensty:Double
    
}


