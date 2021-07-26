//
//  Recipes.swift
//  SkyTestSceneKit
//
//  Created by Farini on 10/29/20.
//  Copyright © 2020 Farini. All rights reserved.
//

import Foundation
import SwiftUI

/// **Recipe** names - recipes create a `Peripheral` or other objects
enum Recipe:String, Codable, CaseIterable, Hashable {
    
    case Module
    case Node
    
    // [Peripherals]
    case Condensator
    case ScrubberCO2
    case Electrolizer
    case Methanizer
    case Radiator
    case SolarPanel
    case Battery
    case StorageBox
    case tank
    case Roboarm
    case WaterFilter      // Transforms part of wasteLiquid back into water (or water vapor, to be easier)
    case BioSolidifier    // Transforms wasteSolid into fertilizer?
    
    // Cement           puzzlepiece
    case Cement
    // ChargedGlass     plus.circle
    case ChargedGlass
    // Alloy            triangle.circle
    case Alloy
    
    // E-Vehicle        bolt.car
    
    // MegaTank?        capsule.portrait
    
    // Polimer?         [see ingred.]
    // Solar Cell?      [see ingred.]
    
    /// Gets the ingredients for recipe
    func ingredients() -> [Ingredient:Int] {
        switch self {
            case .Module: return [.Aluminium:35, .Polimer:5]
            case .Node: return [.Aluminium:15]
            case .SolarPanel: return [.Polimer:3, .SolarCell:5]
            case .Condensator: return [.Aluminium:2, .Copper:1, .Polimer:1]
            case .ScrubberCO2: return [.Polimer:1, .Copper:1, .DCMotor:1]
            case .Electrolizer: return [.Polimer:4, .Copper:3, .Lithium:2]
            case .Methanizer: return [.Polimer:6, .Ceramic:2, .Circuitboard:1]
            case .Radiator: return [.Aluminium:6, .Ceramic:3, .Lithium:3]
            case .Battery: return [.Lithium:8, .Copper:4]
            case .StorageBox: return [.Polimer:5, .Aluminium:1]
            case .tank: return [.Aluminium:8, .Iron:1, .Polimer:1]
            case .Roboarm: return [.Circuitboard:4, .DCMotor:3, .Aluminium:8, .Polimer:16]
            case .WaterFilter: return [.Ceramic:3, .Copper:4, .Lithium:2, .Iron:2]
            case .BioSolidifier: return [.Ceramic:2, .Copper:4, .Sensor:1, .Iron:2]
                
            case .Cement: return [.Silica:4, .Polimer:2]
            case .ChargedGlass: return [.Polimer:10, .Silica:5, .Ceramic:4, .Lithium:4, .Sensor:3]
            case .Alloy: return [.Iron:10, .Aluminium:3, .CarbonFiber:5, .Lithium:2, .Copper:4]
        }
    }
    
    /// A String that explains what this recipe does.
    var elaborate:String {
        switch self {
            case .Condensator: return "Condensates the water vapor in the air into liquid water."
            case .ScrubberCO2: return "Cleans carbon dioxide from the air."
            case .Electrolizer: return "Makes electrolisys of the water, converting into oxygen + hydrogen"
            case .Methanizer: return "Transforms hydrogen and carbon dioxide into methane."
            case .Radiator: return "Maintains temperature."
            case .SolarPanel: return "Generates power and charges the batteries."
            case .Battery: return "Stores energy"
            case .BioSolidifier: return "Transforms poop into fertilizer."
            default: return ""
        }
    }
    
    /// Skills required
    func skillSet() -> [Skills:Int] {
        switch self {
            case .Module: return [.Material:1]
            case .Node: return [.Handy:1]
            case .SolarPanel: return [.Handy:2, .Electric:1]
            case .ScrubberCO2: return [.Material:1, .Handy:1]
            case .Methanizer: return [.Mechanic:1, .Electric:1]
            case .Radiator: return [.Material:1, .Mechanic:1]
            case .StorageBox: return [.Material:1]
            case .Roboarm: return [.Electric:1, .SystemOS:1, .Mechanic:2]
            case .WaterFilter: return [.Electric:1, .Mechanic:1, .Material:2]
            case .BioSolidifier: return [.Electric:1, .Mechanic:2, .Material:2]
            default: return [.Handy:1]
        }
    }
    
    /// The time until the recipe is ready
    func getDuration() -> Int {
        
        switch self {
            
            case .Module: return 60 * 60 * 5        // 5h
            case .Node: return 60 * 30              // 30m
            case .SolarPanel: return 60 * 40        // 40m
            case .ScrubberCO2: return 60 * 60 * 2   // 2h
            case .Methanizer: return 60 * 60 * 3    // 3h
            case .Radiator: return 60 * 60 * 1      // 1h
            case .StorageBox: return 60 * 20        // 20m
            case .Roboarm: return 60 * 60 * 6       // 6h
            case .WaterFilter: return 60 * 60 * 2   // 2h
            case .BioSolidifier: return 60 * 60 * 3 // 3h
            case .Battery: return 60 * 15           // 15m
            case .Condensator: return 60 * 5        // 5m
            case .Electrolizer: return 60 * 10      // 10m
            case .tank: return 60 * 60 * 2          // 2h
            
            case .Cement: return 60 * 2 // 2m
            case .ChargedGlass: return 60 * 60 // 1h
            case .Alloy: return 60 * 3 // 3m
        }
    }
    
    func makeProduct(argument:Any) -> Codable? {
        switch self {
        case .tank:
            if let string = argument as? String, let ttype:TankType = TankType(rawValue: string) {
                let tank:Tank = Tank(type:ttype)
                return tank
            }
        default: return nil
        }
        return nil
    }
    
    var image:Image {
        switch self {
            case .Condensator: return PeripheralObject(peripheral: .Condensator).getImage()!
            case .ScrubberCO2: return PeripheralObject(peripheral: .ScrubberCO2).getImage()!
            case .Electrolizer: return PeripheralObject(peripheral: .Electrolizer).getImage() ?? Image(systemName: "questionmark")
            case .Methanizer: return PeripheralObject(peripheral: .Methanizer).getImage() ?? Image(systemName: "questionmark")
            case .Radiator: return PeripheralObject(peripheral: .Radiator).getImage() ?? Image(systemName: "questionmark")
            case .SolarPanel: return PeripheralObject(peripheral: .solarPanel).getImage() ?? Image(systemName: "questionmark")
            case .Battery: return Image("carBattery")
            case .tank: return Image("Tank")
            case .WaterFilter: return PeripheralObject(peripheral: .WaterFilter).getImage()!
            case .BioSolidifier: return PeripheralObject(peripheral: .BioSolidifier).getImage()!
                
            case .Cement: return Recipe.Cement.image
            case .ChargedGlass: return Recipe.ChargedGlass.image
                
            default: return Image(systemName: "questionmark")
        }
    }
}

extension Recipe {
    
    static var marsCases:[Recipe] {
        // Recipes not included in Mars
        let excluded:Set<Recipe> = Set([Recipe.Module, Recipe.Node, Recipe.Roboarm])
        
        return Array(Set(Recipe.allCases).subtracting(excluded))
    }
}
