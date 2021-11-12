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
    
    // MARK: - Display
    
    var shortName:String {
        switch self {
            case .Hab1, .Hab2, .Hab3, .Hab4, .Hab5, .Hab6: return "Habitation"
            case .Biosphere2, .Biosphere3, .Biosphere4, .Biosphere5: return "Bio Upgrade"
            case .recipeCement: return "Cement"
            case .recipeGlass: return "Glass"
            case .recipeVehicle   : return "Vehicle"
            case .recipeAirTrap   : return "Air Trap"
            case .recipeBig: return "Big Tanks"
            case .recipeWaterSanitizer: return "Sanitation"
            case .recipeAlloy: return "Alloy"
            case .recipeGenerator: return "Generator"
            default: return self.rawValue
        }
    }
    
    var elaborated:String {
        switch self {
            case .Hab1, .Hab2, .Hab3, .Hab4, .Hab5, .Hab6: return "Adds room for more people"
            case .Biosphere2, .Biosphere3, .Biosphere4, .Biosphere5: return "Additional slots for Biosphere. They serve as a source of food and DNA for the Guild's Biospheres."
            case .recipeCement: return "Makes a compost of Mars' soil. Equivalent to the Earth's Cement"
            case .recipeGlass: return "Enables the sunlight to pass through, while blocking all the radiation."
           
            case .recipeAirTrap   : return "Traps the martian air, for consumption. Mostly CO2 and some Hydrogen. Needs to be trnsformed into breathable air."
            case .recipeBig: return "Make Big Tanks"
            case .recipeWaterSanitizer: return "Sanitize the water found in Mars and is a better filter than the water filter itself."
            case .recipeAlloy: return "Makes Alloy"
            case .recipeGenerator: return "Generator makes electricity from CH4 + O2 combustion."
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
                
            case .Hab4, .Hab5, .Hab6: return [.Iron:25, .Ceramic:18, .Silica:12]
                
            case .Biosphere2, .Biosphere3, .Biosphere4, .Biosphere5: return [.Fertilizer:25, .Iron:6, .Sensor:6]
            case .recipeCement: return [.Fertilizer:6, .Aluminium:3, .Silica:8]
                
            case .recipeGlass: return [.Aluminium:16, .Copper:3, .Lithium:8]
            case .recipeVehicle   : return [.Aluminium:16, .Copper:3, .DCMotor:8]
            case .recipeAirTrap   : return [.DCMotor:6, .Sensor:3, .Lithium:8, .Copper:13]
                
            case .recipeBig: return [.Aluminium:8, .Copper:3, .Sensor:2]
            case .recipeWaterSanitizer: return [.Fertilizer:6, .Aluminium:3, .Silica:8, .Copper:8, .Polimer:12]
            case .recipeAlloy: return [.Aluminium:6, .Silica:8, .Copper:8, .Polimer:12]
            case .recipeGenerator: return [.DCMotor:16, .Lithium:22]
            
            default: return [:]
        }
    }
    
    /// Amount of seconds it takes to complete this tech research
    var duration:Int {
        switch self {
            
            case .Hab1: return 60       // 1m
            case .Hab2: return 360      // 6m
            case .Hab3: return 60 * 60  // 1h
            case .Hab4: return 80 * 80
            case .Hab5: return 100 * 100
            case .Hab6: return 100 * 100
                
                
            case .Biosphere2: return 360
            case .Biosphere3: return 60 * 60
            case .Biosphere4: return 60 * 60
            case .Biosphere5: return 60 * 60
                
            case .VehicleRoom1: return 360
            case .VehicleRoom2: return 60 * 60
            case .VehicleRoom3: return 60 * 60
            case .VehicleRoom4: return 80 * 80
            
            case .recipeCement: return 360
            case .recipeGlass: return 3600
            case .recipeVehicle: return 3600
            case .recipeAirTrap: return 360
            case .recipeBig: return 360
            case .recipeWaterSanitizer: return 3600
            case .recipeAlloy: return 360
            case .recipeGenerator: return 1200
        }
    }
    
    /// `Human` Skills required to research this tech
    var skillSet:[Skills:Int] {
        switch self {
                
            // default: return [.Handy:1]
            case .Hab1: return [.Handy:1]
            case .Hab2: return [.Handy:2]
            case .Hab3: return [.Handy:1, .Material:1]
            case .Hab4: return [.Handy:2, .Material:2]
            case .Hab5: return [.Handy:2, .Datacomm:1, .Material:1]
            case .Hab6: return [.Handy:2, .SystemOS:1, .Material:1]
                
            case .Biosphere2: return [.Biologic:1]
            case .Biosphere3: return [.Handy:1, .Biologic:1]
            case .Biosphere4: return [.Handy:2, .Biologic:2, .Datacomm:1]
            case .Biosphere5: return [.Handy:2, .Biologic:2, .SystemOS:1]
                
            case .VehicleRoom1: return [.Handy:1, .Mechanic:1]
            case .VehicleRoom2: return [.Handy:1, .Mechanic:1, .Datacomm:1]
            case .VehicleRoom3: return [.Handy:1, .Mechanic:1, .SystemOS:1]
            case .VehicleRoom4: return [.Handy:1, .Mechanic:1, .Datacomm:2, .SystemOS:1]
                
            case .recipeCement: return [.Handy:1]
            case .recipeGlass:  return [.Handy:2, .Material:2, .Electric:2]
            case .recipeVehicle:return [.Handy:2, .Mechanic:2, .Electric:1]
            case .recipeAirTrap:return [.Handy:1, .Mechanic:1]
            case .recipeBig:    return [.Handy:1]
            case .recipeWaterSanitizer: return [.Handy:1, .Electric:1, .Biologic:2]
            case .recipeAlloy:          return [.Handy:1, .Material:1]
            case .recipeGenerator:      return [.Handy:1, .Electric:1, .Datacomm:1]
        }
    }
}

struct CityTechTree {
    var uniqueTree:Tree<Unique<CityTech>>
    
    init() {
        
        let cement = Tree(CityTech.recipeCement)
        let glass = Tree(CityTech.recipeGlass)
        
        let alloy = Tree(CityTech.recipeAlloy)
        let generator = Tree(CityTech.recipeGenerator)
        let airTrap = Tree(CityTech.recipeAirTrap, children: [generator])
        
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
