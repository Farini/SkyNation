//
//  TechTree.swift
//  SkyTestSceneKit
//
//  Created by Farini on 9/23/20.
//  Copyright © 2020 Farini. All rights reserved.
//

import Foundation

// MARK: - TECH ITEMS

/// Enum of names of **TechItems**
enum TechItems:String, Codable, CaseIterable, Identifiable {
    
    /// Conveniently identifies this item versus others
    var id: String {
        return self.rawValue
    }
    
    case rootItem
    
    // (Recipes)
    case recipeScrubber // * -> Generates tech tree code
    case recipeMethane
    
    // Buildables (Modules)
    case node2
    case module4
    case node3
    case module5
    case node4
    case module6
    case garage
    
    // Optional (extra) Modules
    case module7 // Module 7 is below node 2 (It may have the cuppola)
    
    // Buildables (Peripherals)
    case Cuppola
    case Roboarm
    case AntennaUp
    
    // MARK: - Improvements
    
    // (Recipes)
    case recipeWaterFilter      // Transforms part of wasteLiquid back into water (or water vapor, to be easier)
    case recipeBioSolidifier    // Transforms wasteSolid into fertilizer?
    
    // (Buildables - Peripherals)
    case Airlock
    case GarageArm
    
    // (Buildables - Modules)
    case module8
    case module9
    case module10
    
    // (Level Ups)
    case AU1
    case AU2
    case AU3
    case AU4
    
    // FIXME: - Modifications
    /* ⚠️ Needs to add:
    ⚠️ Important: Update Serial Builder after modifying this enum, or see below (loadItem) for buildables... */
    
    /**
     ⚠️ Needs Implementation:
     Initializes a new `SCNNode` to be added to the scene
     
     - Parameters:
     - peripheral: A `PeripheralObject` containing var model:`Model3d` (Optional). Overrides the loading.
     
     - Returns: The `Model3D` info to be added to the scene
     */
    
    
    // MARK: - Requirements
    
    /// Ingredients required to research this tech
    func ingredients() -> [Ingredient:Int] {
        
        switch self {
            case .Cuppola: return [.Aluminium:25, .Circuitboard:1, .Polimer:10]
            case .Roboarm: return [.Circuitboard:8, .Iron:5, .Aluminium:15, .Polimer:25]
        case .node2, .node3, .node4: return Recipe.Node.ingredients()
        case .module4, .module5, .module6: return Recipe.Module.ingredients()
        default: return [.Aluminium:15, .Polimer:8, .Copper:4]
        }
    }
    
    /// Energy required to research this tech
    func energy() -> Int {
        switch self {
            case .recipeScrubber: return 20
            case .recipeMethane: return 45
            case .Cuppola: return 50
            case .Roboarm: return 120
            case .module4, .module5, .module6: return 50
            case .node2, .node3, .node4: return 20
            case .garage: return 280
            default: return 0
        }
    }
    
    /// Amount of seconds it takes to complete this tech research
    func getDuration() -> Int {
        switch self {
            case .AU1, .AU2, .AU3, .AU4, .AntennaUp: return 60 * 60 * 4 // 4h
            case .module10, .module9, .module8, .module7 : return 60 * 60 * 6 // 6h
            case .module6, .module5, .module4: return 60*60*4 // 4h
            case .node2, .node3, .node4: return 60 * 30 // 30 min
            case .Cuppola: return 60*60*6 // 6h
            case .recipeMethane: return 60*60*2 // 2h
            case .recipeScrubber: return 60*60*2 // 2h
            case .recipeWaterFilter: return 60*60*6 // 6h
            case .recipeBioSolidifier: return 60*60*8 // 8h
            case .Airlock: return 60*60*5 // 5h
            case .Roboarm: return 60*60*8 // 8h
            case .garage: return 60*60*12 // 12h
            case .rootItem: return 1    // 1s
            case .GarageArm: return 60*60*48 //48h
        }
    }
    
    /// The name that appears on the tech tree
    var shortName:String {
        switch self {
            case .rootItem: return "Root"
            case .node2, .node3, .node4: return "Node"
            case .module4, .module5, .module6: return "Module"
            case .module7, .module8, .module9, .module10: return "Opt. Module"
            case .garage: return "Garage"
            case .GarageArm: return "GarageBot"
            case .AU1, .AU2, .AU3, .AU4: return "⬆️ Antenna"
            case .recipeMethane: return "Methanizer"
            case .recipeScrubber: return "Scrubber"
            case .recipeBioSolidifier: return "💩 Biosolids"
            case .recipeWaterFilter: return "Water filter"
            case .Cuppola: return "Cuppola"
            case .Airlock: return "Airlock"
            case .Roboarm: return "Bot Arm"
            default: return self.rawValue
        }
    }
    
    /// Returns a full description of what this `TechItem` does.
    func elaborate() -> String {
        switch self {
            case .AU1, .AU2, .AU3, .AU4, .AntennaUp: return "Upgrade the antenna. It brings more money to the station."
            case .module10, .module9, .module8, .module7, .module6, .module5, .module4: return "Builds another module, and makes progress toward the garage."
            case .node2, .node3, .node4: return "Builds a node. Nodes connect modules, which makes more progress towards the Garage."
            case .Cuppola: return "Cuppola may make your inhabitants happier"
            case .recipeMethane: return "The Methanizer transforms carbon dioxide and water into methane."
            case .recipeScrubber: return "A scrubber cleans up the carboin dioxide from the air."
            case .recipeWaterFilter: return "Transforms the liquid waste back into water."
            case .recipeBioSolidifier: return "Transforms poop into fertilizer."
            case .Airlock: return "Airlock makes inhabitants happier."
            case .Roboarm: return "Makes fixing faster and and inhabitants happier."
            case .garage: return "Allows the Station to make vehicles to transport things to Mars"
            case .rootItem: return "Builds the first nodes and modukes that belong to the initial state of the station."
            case .GarageArm: return "Makes the building of vehicles faster."
        }
    }
    
    /// `Human` Skills required to research this tech
    func skillSet() -> [Skills:Int] {
        switch self {
            case .node2, .node3, .node4: return [.Handy:1]
            case .module4, .module5, .module6: return [.Material:1, .Handy:1]
            case .garage: return [.Material:2, .Handy:2]
            case .recipeScrubber: return [.Handy:1, .Electric:1]
            case .recipeMethane: return [.Electric:1, .Handy:2]
            case .recipeBioSolidifier: return [.Handy:2, .Electric:1]
            case .recipeWaterFilter: return [.Biologic:1]
            case .module7, .module8, .module9, .module10: return [.Material:1, .Handy:1, .Electric:1]
            case .Roboarm: return [.Mechanic:1, .Electric:1, .Datacomm:1]
            case .AU1, .AU2, .AU3, .AU4, .AntennaUp: return [.Datacomm:1]
            case .Airlock: return [.Material:1, .Electric:1, .Handy:1]
            case .Cuppola: return [.Material:2, .Mechanic:1, .Handy:1]
            case .rootItem: return [:]
            case .GarageArm: return [.SystemOS:2, .Material:2, .Datacomm:2, .Electric:2]
        }
    }
}

// MARK: - TECH TREE

class TechTree: Equatable, Identifiable, Hashable {
    
    var value:String        // Reference to TechItem
    var unlocked:Bool = false
    var dateStarted:Date?
    var duration:Int = 0    // Should come from item
    
    var children: [TechTree] = []
    weak var parent: TechTree?
    var item:TechItems
    
    // Constructors
    
    init() {
        // First Item
        let item1 = TechItems.rootItem
        self.item = item1
        self.value = item1.rawValue
        self.unlocked = true
        self.dateStarted = Date().addingTimeInterval(-1.0)
        self.duration = 0
        
        // Children - From the bottom to the top
        
        // Module 6 + Garage
        let garageArm = TechTree(item: .GarageArm)
        let garage = TechTree(item: .garage)
        garage.add(child: garageArm)
        let mod6 = TechTree(item: .module6)
        mod6.add(child: garage)
        
        // Node 4
        let mod10 = TechTree(item: .module10)
        let mod9 = TechTree(item: .module9)
        mod9.add(child: mod10)
        let node4 = TechTree(item: .node4)
        node4.add(child: mod6)
        node4.add(child: mod9)
        let methanizer = TechTree(item: .recipeMethane)
        
        // Module 5
        let mod5 = TechTree(item: .module5)
        mod5.add(child: node4)
        mod5.add(child: methanizer)
        
        let bioSolid = TechTree(item: .recipeBioSolidifier)
        let au1 = TechTree(item: .AU1)
        au1.add(child: bioSolid)
        let airlock = TechTree(item: .Airlock)
        airlock.add(child: au1)
        let au3 = TechTree(item: .AU3)
        let waterFilter = TechTree(item: .recipeWaterFilter)
        waterFilter.add(child: au3)
        let cuppola = TechTree(item: .Cuppola)
        cuppola.add(child: waterFilter)
        
        let mod7 = TechTree(item: .module7)
        mod7.add(child: cuppola)
        mod7.add(child: airlock)
        
        // Node 3
        let mod8 = TechTree(item: .module8)
        let au2 = TechTree(item: .AU2)
        au2.add(child: mod8)
        let scrubber = TechTree(item: .recipeScrubber)
        scrubber.add(child: au2)
        let nod3 = TechTree(item: .node3)
        nod3.add(child: mod5)
        nod3.add(child: scrubber)
        let au4 = TechTree(item:.AU4)
        let roboArm = TechTree(item: .Roboarm)
        roboArm.add(child: au4)
        
        // Module 4
        let mod4 = TechTree(item: .module4)
        mod4.add(child: nod3)
        mod4.add(child: roboArm)
        
        // Node 2
        let nod2 = TechTree(item: .node2)
        nod2.add(child: mod4)
        nod2.add(child: mod7)
        
        self.add(child: nod2)
        
    }
    
    init(item:TechItems) {
        self.value = item.rawValue
        self.duration = item.getDuration()
        self.item = item
    }
    
    func add(child: TechTree) {
        children.append(child)
        child.parent = self
    }
    
    func accountForItems(items:[TechItems]) {
        for item in items {
            if let realItem = search(value: item.rawValue) {
                realItem.unlocked = true
                realItem.dateStarted = Date.distantPast
                for child in realItem.children {
                    child.unlocked = true
                }
            }
        }
    }
    
    // Query
    
    func search(value: String) -> TechTree? {
        if value == self.value {
            return self
        }
        for child in children {
            if let found = child.search(value: value) {
                return found
            }
        }
        return nil
    }
    
    // Properties Manipulation
    
    func startResearch() {
        if !unlocked {
            print("Error - Not unlocked")
            return
        }
        if let _ = dateStarted { return }
        dateStarted = Date()
        self.duration = TechItems(rawValue: self.value)!.getDuration()
    }
    
    func isFinishedResearch() -> Bool {
        if let start = self.dateStarted {
            let delta = Double(duration) // * 60.0 * 60.0 // in hrs
            // Started
            let finish = start.addingTimeInterval(delta)
            if finish.compare(Date()) == .orderedAscending {
                // has finished
                for child in children { child.unlocked = true }
                return true
            } else {
                // not finished
                return false
            }
        }else{
            return false
        }
    }
    
    func unlock() {
        unlocked = true
    }
    
    func showUnlocked() -> [TechTree]? {
        return getUnlocked(node: self)
    }
    
    func getUnlocked(node:TechTree) -> [TechTree]  {
        
        var builder:[TechTree] = []
        var stack:[TechTree] = [self]
        
        while !stack.isEmpty {
            let other = stack.first!
            if other.unlocked {
                if other.isFinishedResearch() {
                    for child in other.children {
                        child.unlock()
                        stack.append(child)
                    }
                }else if other.dateStarted == nil{
                    builder.append(other)
                }
            }
            stack.removeFirst()
        }
        
        return builder
    }
    
    func showCompletedItems() {
        let array = getCompletedItemsFrom(node: self)
        for item in array {
            print("Completed: \(item.describeMe())")
        }
    }
    
    func getCompletedItemsFrom(node:TechTree, collected:[TechTree] = []) -> [TechTree] {
        
        print("Check Completed \(node.value): \(node.isFinishedResearch())")
        var builder:[TechTree] = collected
//        var visited:[TechTree] = []
        
        if node.isFinishedResearch() {
//            builder.append(node)
            for child in children.filter({$0.isFinishedResearch()}) {
                builder.append(contentsOf: child.getCompletedItemsFrom(node: child, collected: builder))
            }
            return builder
        }else{
            return []
        }
    }
    
    func describeMe() -> String {
        var string = "Tech: \(value) \t Unlocked:\(unlocked)"
        // Check Start
        if let dateStarted = dateStarted {
            string += "\t Started:\(Int(Date().timeIntervalSince(dateStarted))) sec ago."
            let dateFinish = dateStarted.addingTimeInterval(Double(duration))
            if dateFinish.compare(Date()) == .orderedAscending {
                string += "\t [FINISHED]"
                for child in children {
                    child.unlock()
                }
            }
        }
        return string
    }
    
    // height
    func listNodesAt(_ n: Int) -> [TechTree] {
        return getElementsAt(n, node: self)
    }
    private func getElementsAt(_ n: Int, node:TechTree, traversingDepth: Int = 0) -> [TechTree] {
        var array = [TechTree]()
        if traversingDepth < n {
            for child in children {
                // print("for \(child.value)")
                array = array + child.getElementsAt(n, node: child, traversingDepth: traversingDepth + 1)
            }
        } else if traversingDepth == n {
            // print("ap \(node.value)")
            array.append(self)
        }
        return array
    }
    
    static func == (lhs: TechTree, rhs: TechTree) -> Bool {
        return lhs.value == rhs.value
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(value)
    }
    
}

extension TechTree: CustomStringConvertible {
    var description: String {
        var text = "\(value)"
        if !children.isEmpty {
            text += " {" + children.map { $0.description }.joined(separator: ", ") + "} "
        }
        return text
    }
}

extension TimeInterval{
    
    func stringFromTimeInterval() -> String {
        
        let time = NSInteger(self)
        
//        let ms = Int((self.truncatingRemainder(dividingBy: 1)) * 1000)
        let seconds = time % 60
        let minutes = (time / 60) % 60
        let hours = (time / 3600)
        
        return String(format: "%dh %0.2dm %0.2ds",hours,minutes,seconds)
        
    }
}
