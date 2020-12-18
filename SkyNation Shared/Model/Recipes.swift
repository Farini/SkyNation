//
//  Recipes.swift
//  SkyTestSceneKit
//
//  Created by Farini on 10/29/20.
//  Copyright © 2020 Farini. All rights reserved.
//

import Foundation

/// **Recipe** names - recipes create a `Peripheral` or other objects
enum Recipe:String, Codable, CaseIterable, Hashable {
    
    case Module
    case Node
    
    // [Peripherals]
    case condensator
    case ScrubberCO2
    case Electrolizer
    case Methanizer
    case Radiator
    case solarPanel
    case battery
    case storageBox
    case tank
    case Roboarm
    
    // MARK: - Improvements
    
    // FIXME: - Modifications
    // ⚠️ Needs to add:
    case  WaterFilter      // Transforms part of wasteLiquid back into water (or water vapor, to be easier)
    case  BioSolidifier    // Transforms wasteSolid into fertilizer?
    
    /// Gets the ingredients for recipe
    func ingredients() -> [Ingredient:Int] {
        switch self {
        case .Module: return [.Aluminium:35]
        case .Node: return [.Aluminium:15]
        case .tank: return [.Aluminium:8]
        default: return [.Aluminium:15, .Polimer:8, .Copper:4]
        }
    }
    
    var elaborate:String {
        switch self {
            case .condensator: return "Condensates the water vapor in the air into liquid water."
            case .ScrubberCO2: return "Cleans carbon dioxide from the air."
            case .Electrolizer: return "Makes electrolisys of the water, converting into oxygen + hydrogen"
            case .Methanizer: return "Transforms hydrogen and carbon dioxide into methane."
            case .Radiator: return "Maintains temperature."
            case .solarPanel: return "Generates power and charges the batteries."
            case .battery: return "Stores energy"
            case .BioSolidifier: return "Transforms poop into fertilizer."
            default: return ""
        }
    }
    
    /// Skills required
    func skillSet() -> [Skills:Int] {
        switch self {
        case .tank: return [:]
        default: return [.Mechanic:1, .Biologic:1]
        }
    }
    
    /// Returns null if doesn't require
    func requiresTechTreePass() -> String? {
        switch self {
            case .ScrubberCO2: return self.rawValue
            case .Methanizer: return self.rawValue
            case .Roboarm: return self.rawValue
                
            default: return nil
        }
    }
    
    /// The time until the recipe is ready
    func getDuration() -> Int {
        switch self {
        case .ScrubberCO2: return 5
        case .Methanizer: return 8
        
        default: return 2
        }
    }
    
    func makeProduct(argument:Any) -> Codable? {
        switch self {
        case .tank:
            if let string = argument as? String, let ttype:TankType = TankType(rawValue: string) {
                let tank = Tank(type:ttype)
                return tank
            }
        default: return nil
        }
        return nil
    }
    
}
