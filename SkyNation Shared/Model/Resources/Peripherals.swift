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
    
    // MARK: - Model Building
    
    /// Where delivery ships can dock
    case DockingPoint
    
    /// Makes Spacewalk much easier (helps reduce chances of breaking peripherals(
    case Airlock
    
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
    
    /// Transforms part of wasteLiquid back into water (or water vapor, to be easier)
    case WaterFilter
    
    /// Transforms wasteSolid into fertilizer
    case BioSolidifier
    
    // Add to methods
    
    /// How much each level contributes to its production
    // var enegyConsumptionMultiplier
    
    /// Whether this Peripheral can be used off Accounting time
    // var canBoost:Bool
    
    // MARK: - Calculated Variables
    
    /// The name of the `Model3D` to add to the scene (if any)
    var modelName:String? {
        // Return only the Peripheral objects that are added to the scene
        switch self {
            case .Radiator: return "Radiator"
            case .solarPanel: return "SolarPanel"
            case .DockingPoint: return "Docker"
            case .Airlock: return "Airlock"
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
            case .Condensator, .ScrubberCO2, .Electrolizer, .Radiator, .WaterFilter, .BioSolidifier: return true
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
            case .Condensator, .ScrubberCO2: return 10
            case .Electrolizer: return 15
            case .Methanizer, .Radiator, .WaterFilter: return 20
            case .Antenna, .BioSolidifier: return 25
            
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
    var model:Model3D?
    
    /// Initializes a Peripheral Object from its equivalent `PeripheralType`
    init(peripheral:PeripheralType) {
        id = UUID()
        self.peripheral = peripheral
        breakable = peripheral.breakable
        level = 0
        isBroken = false
        powerOn = true
    }
    
    func powerConsumption() -> Int {
        return peripheral.energyConsumption
    }
    
    func runAirMods(air input:AirComposition) -> (output:AirComposition, waterProduced:Int) {
        
        var tmpWater:Int = 0
        let newAir:AirComposition = input
        
        switch peripheral {
            case .Condensator:
//                print("Condensate")
                let vapor = newAir.h2o
                if vapor > 2 {
                    tmpWater += 2
                    newAir.h2o -= 2
                }
                return (newAir, tmpWater)
            case .ScrubberCO2:
//                print("Scrubs")
                let co2 = newAir.co2
                if co2 > 2 {
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

// MARK: - Storage
// Boxes are in 'Ingredients.swift'

// MARK: - Tanks
// Moved to 'Tanks.swift'

// MARK: - Energy
// Moved to 'Energy.swift'

