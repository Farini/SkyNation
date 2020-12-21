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
        let peri1 = BuildItem(peripheral: "Lander", orientation: .Down)
        
        // module0.id
        let b = Module(id: module0.id, modex: .mod0)
        modArray.append(b)
        
        module0.children = [peri1]
        n0.children = [module0]
        n0.unlocked = true
        
        // Node 1
        let n1 = BuildItem(node: Vector3D.zero, orientation: .Up)
        let moduleF = BuildItem(module: .mod1)
        let module1 = BuildItem(module: .mod2)
        let solarPanel = BuildItem(peripheral: "Solar panel", orientation: .Front)
        
        let front = Module(id: moduleF.id, modex: .mod1)
        let m1 = Module(id:module1.id, modex: .mod2)
        modArray.append(front)
        modArray.append(m1)
        
        moduleF.children = [solarPanel]
        n1.children = [moduleF, module1]
        n1.unlocked = true
        
        // Node 2
        let n2 = BuildItem(node: Vector3D(x: 0, y: 0, z: -12), orientation: .Up)
        let module2 = BuildItem(module: .mod3)
        let m2 = Module(id: module2.id, modex: .mod3)
        modArray.append(m2)
        
        n2.unlocked = false
        n2.children = [module2]
        
        
        // Node 3
        let n3 = BuildItem(node: Vector3D(x: 0, y: 0, z: -24), orientation: .Up)
        let module3 = BuildItem(module: .mod4)
        let m3 = Module(id: module3.id, modex: .mod4)
        modArray.append(m3)
        n3.unlocked = false
        n3.children = [module3]
        
        // Node 4 - Fourth (garage)
        let n4 = BuildItem(node: Vector3D(x: 0, y: 0, z: -36), orientation: .Up)
        let module4 = BuildItem(module: .mod5)
        let m4 = Module(id: module4.id, modex: .mod5)
        modArray.append(m4)
        
        let garage = BuildItem(peripheral: "Garage", orientation: .Back)
        module4.children = [garage]
        
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
