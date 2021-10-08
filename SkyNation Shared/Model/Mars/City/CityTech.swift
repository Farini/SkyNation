//
//  CityTech.swift
//  SkyNation
//
//  Created by Carlos Farini on 8/13/21.
//

import Foundation

enum CityTech:String, Codable, CaseIterable, Identifiable {
    
    /// Conveniently identifies this item versus others
    var id: String {
        return self.rawValue
    }
    
    // Habs
    case Hab1
    case Hab2
    case Hab3
    case Hab4
    case Hab5
    case Hab6
    
//    case OutsideDome1
    // biosphere
    case Biosphere2 // up to 50?
    case Biosphere3 // up to 100
    case Biosphere4 // up to 200
    case Biosphere5 // up to 400
    
    case VehicleRoom1
    case VehicleRoom2
    case VehicleRoom3
    case VehicleRoom4
    
    // Recipes
    case recipeCement
    case recipeGlass
    case recipeVehicle          // Can be split in different resources
    case recipeAirTrap          // Can be split
    case recipeBig
    case recipeWaterSanitizer
    case recipeAlloy
    
    // new
    case recipeGenerator
    
    
    // MARK: - Logic
    
    /// Determines whether this tech can be researched. See CityData.tech, if the unlockedBy tech has been discovered, then this tech can be researched.
    var unlockedBy:CityTech? {
        switch self {
            case .Hab2: return .Hab1
            case .Hab3: return .Hab2
            case .Hab4: return .Hab3
            case .Hab5: return .Hab4
            case .Hab6: return .Hab5
                
            case .VehicleRoom4: return .VehicleRoom3
            case .VehicleRoom3: return .VehicleRoom2
            case .VehicleRoom2: return .VehicleRoom1
            case .VehicleRoom1: return .recipeVehicle
                
            case .recipeAirTrap: return .Hab3
            case .recipeGlass: return .Hab4
            case .recipeCement: return .Hab2
            case .recipeAlloy: return .VehicleRoom2
                
            default: return nil
        }
    }
    //    var unlocks:[CityTech] {
    //        switch self {
    //            case .Hab1: return [.Hab2, .recipeVehicle]
    //            default: return []
    //        }
    //    }
    
    // MARK: - Display
    
    var shortName:String {
        switch self {
            case .Hab1, .Hab2, .Hab3, .Hab4, .Hab5, .Hab6: return "Hab Module"
            default: return self.rawValue
        }
    }
    
    var elaborated:String {
        switch self {
            case .Hab1, .Hab2, .Hab3, .Hab4, .Hab5, .Hab6: return "Adds room for more people"
            default: return "Tech description goes here"
        }
    }
    
    // MARK: - Requirements
    
    /// Ingredients required to research this tech
    var ingredients:[Ingredient:Int] {
        switch self {
            case .Hab1: return [.Iron:1]
            case .Hab2: return [.Iron:14, .Ceramic:8, .DCMotor:1]
            case .Hab3: return [.Iron:20, .Ceramic:16, .Silica:2]
            default: return [:]
        }
    }
    
    /// Amount of seconds it takes to complete this tech research
    var duration:Int {
        switch self {
            default: return 1
        }
    }
    
    /// `Human` Skills required to research this tech
    var skillSet:[Skills:Int] {
        switch self {
            default: return [.Handy:1]
        }
    }
}

enum MarsRecipe:String, Codable, CaseIterable {
    
    case Cement     // Any Structure
    case Glass      // Any Structure
    case Alloy      // Any Structure
    
    case Generator  // Make energy from Methane
    
    case SolarCell
    case Polimer
    
    case MegaTank
    case MegaBox
    
    case EVehicle   // Extract Silica, Iron, Lithium, Crystals
}

struct CityTechTree {
    var uniqueTree:Tree<Unique<CityTech>>
    
    init() {
        
        let cement = Tree(CityTech.recipeCement)
        let glass = Tree(CityTech.recipeGlass)
        let airTrap = Tree(CityTech.recipeAirTrap)
        let alloy = Tree(CityTech.recipeAlloy)
        
        let hab6 = Tree(CityTech.Hab6)
        let hab5 = Tree(CityTech.Hab5, children:[hab6])
        let hab4 = Tree(CityTech.Hab4, children:[hab5, glass])
        let hab3 = Tree(CityTech.Hab3, children:[hab4, airTrap])
        let hab2 = Tree(CityTech.Hab2, children:[hab3, cement])
        
        // let vr4 = Tree(CityTech.VehicleRoom4)
//        let bio2 = Tree(CityTech.Biosphere2)
//        let bio3 = Tree(CityTech.Biosphere3)
        
        let bio5 = Tree(CityTech.Biosphere5)
        let bio4 = Tree(CityTech.Biosphere4, children: [bio5])
        let bio3 = Tree(CityTech.Biosphere3, children: [bio4])
        let bio2 = Tree(CityTech.Biosphere2, children: [bio3, alloy])
//        let vr3 = Tree(CityTech.VehicleRoom3, children:[vr4])
//        let vr2 = Tree(CityTech.VehicleRoom2, children:[alloy, vr3])
//        let vr1 = Tree(CityTech.VehicleRoom1, children:[vr2])
        
//        let recVehicle = Tree(CityTech.recipeVehicle, children:[vr1])
        
        // Finalize
        let binaryTree = Tree<CityTech>(CityTech.Hab1, children: [hab2, bio2])
        
        let uniqueTree:Tree<Unique<CityTech>> = binaryTree.map(Unique.init)
        self.uniqueTree = uniqueTree
    }
    
    /// Returns a `CityTech` array containing items that can be researched.
    func unlockedTechAfter(doneTech:[CityTech]) -> [CityTech] {
        
        var next = [self.uniqueTree]
        
        var array:[CityTech] = [uniqueTree.value.value]
        
        while let scope = next.first {

            if doneTech.contains(scope.value.value) {
                array.append(contentsOf: scope.children.compactMap({ $0.value.value }))
                next.append(contentsOf: scope.children)
            }
            next.removeFirst()
        }
        
        print("\n\n\n *** Discoverable ***")
        print(array.description)
        
        return array
        
    }
}
