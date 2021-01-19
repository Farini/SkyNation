//
//  SerialBuilder.swift
//  SkyTestSceneKit
//
//  Created by Farini on 9/23/20.
//  Copyright © 2020 Farini. All rights reserved.
//

import Foundation

/// The type of **BuildItem** for the **SerialBuilder**
enum BuildComponent:String, Codable, CaseIterable {
    case Node
    case Module
    case Truss
    case Peripheral
}

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

class StationBuilder:Codable {
    
    // Single Dimensional Array
    var buildList:[StationBuildItem]
    var lights:[BuildableLight] = []
    
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
    
    /// Initialize with a Station, if there is one
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
            
            switch modex {
                case .mod3:
                    // Node 2
                    let node2 = StationBuildItem(pos: Vector3D(x: 0, y: 0, z: -12), euler: Vector3D.zero, type: .Node)
                    arrayOfNodes.append(node2)
                case .mod4:
                    // Node 3
                    let node3 = StationBuildItem(pos: Vector3D(x: 0, y: 0, z: -24), euler: Vector3D.zero, type: .Node)
                    arrayOfNodes.append(node3)
                case .mod5:
                    // Node 4
                    let node4 = StationBuildItem(pos: Vector3D(x: 0, y: 0, z: -36), euler: Vector3D.zero, type: .Node)
                    arrayOfNodes.append(node4)
                default:
                    continue
            }
        }
        
        self.buildList = arrayOfNodes + arrayOfModules
        
        // Lights
        
    }
    
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
    
}

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
