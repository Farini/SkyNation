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

/// Builds the **BuildItem** Objects and store in an array. Is used in Scene construction
class SerialBuilder:Codable {
    
    var nodes:[BuildItem]
    var modules:[Module]
    
    init() {
        
        var modArray:[Module] = []
        
        // Node 0
        let n0 = BuildItem(node: Vector3D(x: 0, y: -12, z: 0), orientation: .Up)
        let module0 = BuildItem(module: .mod0)
//        let peri1 = BuildItem(peripheral: "Lander", orientation: .Down)
        
        // module0.id
        let b = Module(id: module0.id, modex: .mod0)
        modArray.append(b)
        
//        module0.children = [peri1]
        n0.children = [module0]
        n0.unlocked = true
        
        // Node 1
        let n1 = BuildItem(node: Vector3D.zero, orientation: .Up)
        let moduleF = BuildItem(module: .mod1)
        let module1 = BuildItem(module: .mod2)
//        let solarPanel = BuildItem(peripheral: "Solar panel", orientation: .Front)
        
        let front = Module(id: moduleF.id, modex: .mod1)
        let m1 = Module(id:module1.id, modex: .mod2)
        modArray.append(front)
        modArray.append(m1)
        
//        moduleF.children = [solarPanel]
        n1.children = [moduleF, module1]
        n1.unlocked = true
        
        // Node 2
        let n2 = BuildItem(node: Vector3D(x: 0, y: 0, z: -12), orientation: .Up)
        let module2 = BuildItem(module: .mod3)
        let module7 = BuildItem(module: .mod7)
        let m2 = Module(id: module2.id, modex: .mod3)
        let m7 = Module(id: module7.id, modex: .mod7)
        modArray.append(m2)
        modArray.append(m7)
        
        n2.unlocked = false
        n2.children = [module2, module7]
        
        
        // Node 3
        let n3 = BuildItem(node: Vector3D(x: 0, y: 0, z: -24), orientation: .Up)
        let module3 = BuildItem(module: .mod4)
        let m3 = Module(id: module3.id, modex: .mod4)
        let module8 = BuildItem(module: .mod8)
        let m8 = Module(id: module8.id, modex: .mod8)
        modArray.append(m3)
        modArray.append(m8)
        n3.unlocked = false
        n3.children = [module3, module8]
        
        // Node 4 - Fourth (garage)
        let n4 = BuildItem(node: Vector3D(x: 0, y: 0, z: -36), orientation: .Up)
        let module4 = BuildItem(module: .mod5)
        let m4 = Module(id: module4.id, modex: .mod5)
        modArray.append(m4)
        
//        let garage = BuildItem(peripheral: "Garage", orientation: .Back)
//        module4.children = [garage]
        module4.children = []
        
        n4.unlocked = false
        n4.children = [module4]
        
        // Node 5 (Optional) Up
        
        self.nodes = [n0, n1, n2, n3, n4]
        self.modules = []
        
//        let modIDs = SerialBuilder.getModulesIDS(nodes: [n0, n1, n2, n3, n4])
//        for mid in modIDs {
//            let new = Module(id: mid)
//            self.modules.append(new)
//        }
        
        self.modules = modArray
        
        for node in nodes {
            node.describe()
        }
    }
    
    // Modules for ID Reference
    static func getModulesIDS(nodes:[BuildItem]) -> [UUID] {
        var moduleIDS:[UUID] = []
        for node in nodes {
            for child in node.children {
                if child.type == .Module {
                    moduleIDS.append(child.id)
                }
            }
        }
        return moduleIDS
    }
    
    func upgradeTech(item:TechItems) {
        
        switch item {
                
            case .module4:
                let modex:ModuleIndex = .mod3
                let pnode = nodes[2]
                let children = pnode.children
                
                guard let fModule:Module = modules.filter({ $0.moduleDex == modex }).first else { fatalError() }
                
                for moduleBuild:BuildItem in children {
                    print("Mod Child: \(moduleBuild.describe())")
                    if moduleBuild.id == fModule.id {
                        print("Unlocking Module: \(moduleBuild.describe())")
                        moduleBuild.unlocked = true
                        return
                    }
                }
                print("ERROR: Could not load module \(modex)")
                
            case .module5:
                let modex:ModuleIndex = .mod4
                let pnode = nodes[3]
                let children = pnode.children
                
                guard let fModule:Module = modules.filter({ $0.moduleDex == modex }).first else { fatalError() }
                
                for moduleBuild:BuildItem in children {
                    print("Mod Child: \(moduleBuild.describe())")
                    if moduleBuild.id == fModule.id {
                        print("Unlocking Module: \(moduleBuild.describe())")
                        moduleBuild.unlocked = true
                        return
                    }
                }
                print("ERROR: Could not load module \(modex)")
                
            case .module6:
                let modex:ModuleIndex = .mod5
                let pnode = nodes[4]
                let children = pnode.children
                
                guard let fModule:Module = modules.filter({ $0.moduleDex == modex }).first else { fatalError() }
                
                for moduleBuild:BuildItem in children {
                    print("Mod Child: \(moduleBuild.describe())")
                    if moduleBuild.id == fModule.id {
                        print("Unlocking Module: \(moduleBuild.describe())")
                        moduleBuild.unlocked = true
                        return
                    }
                }
                print("ERROR: Could not load module \(modex)")
                
            case .module7:
                let modex:ModuleIndex = .mod7
                let pnode = nodes[2]
                let children = pnode.children
                
                guard let fModule:Module = modules.filter({ $0.moduleDex == modex }).first else { fatalError() }
                
                for moduleBuild:BuildItem in children {
                    print("Mod Child: \(moduleBuild.describe())")
                    if moduleBuild.id == fModule.id {
                        print("Unlocking Module: \(moduleBuild.describe())")
                        moduleBuild.unlocked = true
                        return
                    }
                }
                print("ERROR: Could not load module \(modex)")
                
            case .node2:
                nodes[2].unlocked = true
//                let children = nodes[2].children
//                for child in children {
//                    child.unlocked = true
//                }
                let id = nodes[2].id
                print("Item: \(item) unlocked id \(id.uuidString)")
                LocalDatabase.shared.saveSerialBuilder(builder: self)
                
            case .node3:
                nodes[3].unlocked = true
//                for child in nodes[3].children {
//                    child.unlocked = true
//                }
                LocalDatabase.shared.saveSerialBuilder(builder: self)
            case .node4:
                nodes[4].unlocked = true
//                for child in nodes[4].children {
//                    child.unlocked = true
//                }
                LocalDatabase.shared.saveSerialBuilder(builder: self)
            case .Cuppola:
                print("Enable Cuppola")
                
            default:
                print("Nothing Happening")
        }
        
    }
}

/// An Item that represents a Node, Module, or Peripheral
class BuildItem:Codable {
    
    var id:UUID
    var modelInfo:Model3D
    var type:BuildComponent            // = [.Node, .Module, .Peripheral, .Truss]
    var acceptable:[BuildComponent]    // = [.Module, .Peripheral, .Truss]    // For children
    var children:[BuildItem]        // = []
    var unlocked:Bool               // = false
    var dateStarted:Date?
    
    /// Init **Node** type
    init(node position:Vector3D, orientation:Orientation3D?) {
        
        id = UUID()
        type = .Node
        acceptable = [.Module, .Peripheral, .Truss]
        children = []
        unlocked = false
        
        if let ori = orientation {
            let model = Model3D(name: "Node", orientation: ori, position: position)
            self.modelInfo = model
        }else{
            // nil = defaults (front and back)
            let model = Model3D(name: "Node", orientation: .Back, position: position)
            self.modelInfo = model
        }
    }
    
    /// Init **MODULE** type
    init(module modex:ModuleIndex) {
        id = UUID()
        type = .Module
        acceptable = [.Node, .Peripheral]
        children = []
        let position = modex.position()
        
        // Orientation
        let model = Model3D(name: "Module", orientation: modex.orientation(), position: position)
        self.modelInfo = model
        
        // Unlocked
        unlocked = false
        if modex == .mod0 || modex == .mod1 || modex == .mod2 {
            self.unlocked = true
        }
        
    }
    
    /// Init **PERIPHERAL** type
    init(peripheral named:String, orientation:Orientation3D?) {
        
        id = UUID()
        type = .Peripheral
        acceptable = []
        children = []
        unlocked = true // True because if there is a parent, we can build this.
        
        if let ori = orientation {
            let model = Model3D(name: named, orientation: ori, position: .zero)
            self.modelInfo = model
        }else{
            // nil = defaults (front and back)
            let model = Model3D(name: named, orientation: .Back, position: .zero)
            self.modelInfo = model
        }
    }
    
    func describe() {
        let name = modelInfo.name
        let myType = type
        let acceptTypes = acceptable
        print("\(name) type \(myType). Accept: \(acceptTypes)")
        if !children.isEmpty {
            print("Children...")
            for child in children {
                child.describe()
            }
        }
    }
    
}

// MARK: - File Management
extension SerialBuilder {
    
    /// Saves in **Desktop**
    func save() {
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        guard let encodedData:Data = try? encoder.encode(self) else {
            print("Cannot encode")
            fatalError()
        }
        
        // File size
        //        let bcf = ByteCountFormatter()
        //        bcf.allowedUnits = [.useKB]
        //        bcf.countStyle = .file
        //        let dataSize = bcf.string(fromByteCount: Int64(encodedData.count))
        //        print("Data Size: \(dataSize)")
        
        let fm = FileManager.default
        if let url = fm.urls(for: .desktopDirectory, in: .userDomainMask).first {
            print("First url")
            var fileURL = url.appendingPathComponent("SKNTest")
            print("File url \(fileURL)")
            fileURL = fileURL.appendingPathExtension("json")
            print("File url2 \(fileURL)")
            
            do {
                try encodedData.write(to: fileURL, options: [.atomic])
                print("Written")
            }catch {
                print("Bad stuff")
            }
        }
    }
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
    
//    func didFinishTech(item:TechItems, module:Module) {
//        // Notify director?
//        // append to buildList
//        let newBuild = StationBuildItem(module: module.moduleDex)
//        newBuild.id = module.id
//        buildList.append(newBuild)
//    }
    
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
    
    // Look for tech in station
    // Add the techs
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
    
    // Extension
    // func makeModel
    
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
