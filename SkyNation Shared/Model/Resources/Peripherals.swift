//
//  Peripherals.swift
//  SkyTestSceneKit
//
//  Created by Farini on 8/29/20.
//  Copyright © 2020 Farini. All rights reserved.
//

import Foundation

enum PeripheralType:String, Codable, CaseIterable {
    
    /// Converts water vapor into liquid water
    case Condensator
    
    /// Removes CO2 in the air
    case ScrubberCO2
    
    /// Makes electrolisys (Converts water into oxygen + hydrogen
    case Electrolizer
    
    /// Converts CO2 + H2 into Methane CH4
    case Methanizer
    
    /// Temperature control
    case Radiator
    
    // MARK: - Special Classes
    
    /// Makes energy from the sun
    case solarPanel
    
    /// Stores energy
    case battery
    
    /// Stores Ingredients
    case storageBox     // Container
    
    /// Stores `TankType` (Gases and liquid)
    case storageTank    // Container
    
    /// Transforms part of wasteLiquid back into water (or water vapor, to be easier)
    case WaterFilter
    
    /// Transforms wasteSolid into fertilizer
    case BioSolidifier
    
    // MARK: - Model Building
    
    /// Where delivery ships can dock
//    case DockingPoint
    
    /// Makes Spacewalk much easier (helps reduce chances of breaking peripherals(
    // case Airlock
    
    /// Makes inhabitants happier
    case Cuppola
    
    /// Makes building `SpaceVehicle` much faster
    case GarageArm
    
    /// Helps to reduce breaking `PeripheralObject`
    case Roboarm
    
    /// Where `SpaceVehicle`objects are built
    case Garage
    
    /// Makes money for the station
    case Antenna
    
    // MARK: - Required in Mars
    
    case AirTrap
    
    case PowerGen
    
    // EVBot (E-Vehicle)
    
    
    // MARK: - Calculated Variables
    
    /// The name of the `Model3D` to add to the scene (if any)
    var modelName:String? {
        // Return only the Peripheral objects that are added to the scene
        switch self {
            case .Radiator: return "Radiator"
            case .solarPanel: return "SolarPanel"
//            case .DockingPoint: return "Docker"
//            case .Airlock: return "Airlock"
            case .Cuppola: return "Cuppola"
            case .Roboarm: return "Roboarm"
            case .Garage: return "Garage"
            case .Antenna: return "Antenna"
            default: return nil
        }
    }
    
    var describer:String {
        switch self {
            
            case .Antenna: return "This makes money for the Station"
            case .Condensator: return "Condensates the water vapor emitted by humans into drinkable water"
            case .Electrolizer: return "Performs electrolisys of the water. Splitting into Hydrogen + Oxygen"
            case .Methanizer: return "Makes methane from CO2 + H2"
            case .Radiator: return "Maintains ideal temperature in the Space Station, and makes the inhabitants happier. 1 for 3 people required."
            case .ScrubberCO2: return "Extracts the CO2 from the air"
            case .Roboarm: return "Does a series of things"
            case .WaterFilter: return "Transforms part of waste water into drinkable water"
            case .BioSolidifier: return "Transforms solid waste into fertilizer"
            
            case .AirTrap: return "Takes CO2 from the Martian's thin atmosphere"
            case .PowerGen: return "Makes energy from Methane and Oxygen."
            default: return "It is unknown what this thing does."
        }
    }
    
    var instantUse:String {
        switch self {
            case .ScrubberCO2:
                return "Scrubber needs at least 4 CO2 in the air to work. You may spend 100 energy to cleanup 4 CO2."
            case .Electrolizer:
                return "Electrolizer needs 10L of water to convert it into 10 H2 + 5 O2"
            case .Methanizer:
                return "10 CO2 in the air & 10 H2 >>> +10 CH4 & 10 O2"
            case .WaterFilter:
                return "10L waste water >>> At least 5L of potable water. Upgrade Peripheral to get a better percentage."
            case .BioSolidifier:
                return "10L solid waste >>> At least 5Kg Fertilizer. Upgrade Peripheral to get a better percentage."
            default: return ""
        }
    }
    
    /// Whether peripheral can break
    var breakable:Bool {
        switch self {
            case .Condensator, .ScrubberCO2, .Electrolizer, .Radiator, .WaterFilter, .BioSolidifier, .AirTrap: return true
        default: return false
        }
    }
    
    /// Whether this peripheral can be levelled up.
    var updatable:Bool {
        switch self {
            case .Antenna, .GarageArm, .Roboarm, .solarPanel, .WaterFilter, .BioSolidifier: return true
            default: return false
        }
    }
    
    /// Energy Consumption at **Level 0**
    var energyConsumption:Int {
        switch self {
            case .Condensator, .ScrubberCO2: return 12
            case .Electrolizer: return 18
            case .Methanizer, .Radiator, .WaterFilter: return 25
            case .Antenna, .BioSolidifier: return 30
            case .AirTrap: return 30
            default: return 0
        }
    }
}

/// An object that produces, or transforms `Ingredients`
class PeripheralObject:Codable, Identifiable, Equatable {
    
    var id:UUID
    var peripheral:PeripheralType
    var breakable:Bool
    var isBroken:Bool
    var level:Int
    
    var lastFixed:Date?
    
    /// Turn it `on/off` to use, or save energy
    var powerOn:Bool
    
    /// Information (Name, Position, Orientation) to build a `SCNNode` in the scene
//    var model:Model3D?
    
    /// Initializes a Peripheral Object from its equivalent `PeripheralType`
    init(peripheral:PeripheralType) {
        id = UUID()
        self.peripheral = peripheral
        breakable = peripheral.breakable
        level = 0
        isBroken = false
        powerOn = true
    }
    
    /**
     Indicates the power consumption. Used in Accounting
     - Parameters:
     - crack: A *boolean*  indicating if device should break - `isBroken`
     - Returns: The amount of energy it consumes, if it does. */
    func powerConsume(crack:Bool) -> Int {

        if powerOn == true {
            // Power is on
            // Consume Energy
            // return peripheral.energyConsumption
            
            if breakable { // It can only break if it is breakabale and the power is on
                if isBroken {
                    // already broken
                    return peripheral.energyConsumption
                } else {
                    // can break
                    if !crack { return peripheral.energyConsumption }
                    let chanceToBreak = GameLogic.chances(hit: 1.0, total: 50.0)
                    if chanceToBreak {
                        self.isBroken = true
                    }
                    return peripheral.energyConsumption
                }
            } else {
                // unbreakable
                return peripheral.energyConsumption
            }
            
        } else {
            // Power is off
            return 0
        }
    }
    
    func powerConsumption() -> Int {
        return peripheral.energyConsumption
    }
    
    /// Key Value for `Peripheral` consumption, or production
    func getConsumables() -> [String:Int] {
        
        switch peripheral {
            case .ScrubberCO2: return [TankType.co2.rawValue: 3, "CarbDiox":-3]
            case .Condensator: return [TankType.h2o.rawValue: 3, "vapor": -3]
            case .Electrolizer: return [TankType.h2o.rawValue: -2, "oxygen":2, TankType.h2.rawValue:4]
            case .Methanizer: return ["CarbDiox":-4, TankType.h2.rawValue:-4, TankType.ch4.rawValue:4, TankType.o2.rawValue:4]
            case .WaterFilter: return [Ingredient.wasteLiquid.rawValue: -5, TankType.h2o.rawValue:5]
            case .BioSolidifier:
                var random:[String:Int] = Bool.random() == true ? ([Ingredient.Fertilizer.rawValue:2]):[TankType.ch4.rawValue:4]
                random[Ingredient.wasteSolid.rawValue] = -2
                return random
            case .PowerGen: return [TankType.ch4.rawValue: -5, "energy":5]
            case .AirTrap: return [TankType.co2.rawValue:4, TankType.allCases.randomElement()!.rawValue:1]
            
            default: return [:]
        }
    }
    
    
    // Deprecate
    func runAirMods(air input:AirComposition) -> (output:AirComposition, waterProduced:Int) {
        
        var tmpWater:Int = 0
        let newAir:AirComposition = input
        
        switch peripheral {
            case .Condensator:
//                print("Condensate")
                let vapor = newAir.h2o
                if vapor > 5 {
                    tmpWater += 2
                    newAir.h2o -= 2
                }
                return (newAir, tmpWater)
            case .ScrubberCO2:
//                print("Scrubs")
                let co2 = newAir.co2
                if co2 > 3 {
                    newAir.co2 -= 2
                }
                return (newAir, tmpWater)
            default: return (input, 0)
        }
    }
    
    func filterWater(dirty:StorageBox, drinkable:Tank) {
        
        guard dirty.type == .wasteLiquid && drinkable.type == .h2o else {
            return
        }
        
        let dirtyAmount = dirty.current
        let cleanAmount = drinkable.current
        
        if dirtyAmount < 5 { return }
        if dirtyAmount < 10 {
            dirty.current -= 2
            drinkable.current += 1
        } else {
            // up to 10, or 10% + lvl
            let lvl = self.level + 1
            let amt = Int(0.1 * Double(dirtyAmount)) + lvl
            dirty.current -= amt
            drinkable.current = min(cleanAmount + amt, drinkable.capacity)
        }
    }
    
    static func == (lhs: PeripheralObject, rhs: PeripheralObject) -> Bool {
        return lhs.id == rhs.id
    }
}

import SwiftUI

extension PeripheralObject {
    func getImage() -> Image? {
        switch self.peripheral {
//            case .Airlock:
//                return Image("Airlock")
            case .Antenna:
                return Image("Antenna")
            case .Condensator:
                return Image("Condensator")
            case .Methanizer:
                return Image("Methanizer")
            case .Radiator:
                return Image("Radiator")
            case .Roboarm:
                return Image("Roboarm")
            case .ScrubberCO2:
                return Image("Scrubber")
            case .solarPanel:
                return Image("SolarPanel")
            case .storageTank:
                return Image("Tank")
            case .WaterFilter:
                return Image("WaterFilter")
            case .BioSolidifier:
                return Image("BioSolidifier")
            case .Electrolizer:
                return Image("Electrolizer")
            case .PowerGen:
                return Image(systemName: "power") // togglepower
            case .AirTrap:
                return Image(systemName: "wind")
            default:
                print("Don't have an image for that yet")
                return nil
        }
    }
}

