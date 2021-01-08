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
    
    // MARK: - Improvements
    
    // FIXME: - Modifications
    // ⚠️ Needs to add:
    // add WaterFilter      // Transforms part of wasteLiquid back into water (or water vapor, to be easier)
    // add BioSolidifier    // Transforms wasteSolid into fertilizer?
    
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
    
    /// Whether peripheral can break
    var breakable:Bool {
        switch self {
        case .Condensator, .ScrubberCO2, .Electrolizer, .Radiator: return true
        default: return false
        }
    }
    
    /// Whether this peripheral can be levelled up.
    var updatable:Bool {
        switch self {
            case .Antenna, .GarageArm, .Roboarm, .solarPanel: return true
            default: return false
        }
    }
    
    /// Energy Consumption at **Level 0**
    var energyConsumption:Int {
        switch self {
            case .Condensator, .ScrubberCO2: return 10
            case .Electrolizer: return 15
            case .Methanizer, .Radiator: return 20
            case .Antenna: return 25
            default: return 0
        }
    }
}

/// An object that produces, or transforms `Ingredients`
class PeripheralObject:Codable, Identifiable {
    
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
                print("Condensate")
                let vapor = newAir.h2o
                if vapor > 2 {
                    tmpWater += 2
                    newAir.h2o -= 2
                }
                return (newAir, tmpWater)
            case .ScrubberCO2:
                print("Scrubs")
                let co2 = newAir.co2
                if co2 > 2 {
                    newAir.co2 -= 2
                }
                return (newAir, tmpWater)
            default: return (input, 0)
        }
    }
}

// MARK: - Storage

/// A box container that holds solid `Ingredients`
class StorageBox:Codable, Identifiable, Hashable {
    
    var id:UUID = UUID()
    var type:Ingredient
    var capacity:Int { return type.boxCapacity() }
    var current:Int = 0
    
    init(ingType:Ingredient, current:Int) {
        self.type = ingType
        self.current = current
    }
    
    /**
     Fills the Box with the input.
     - Parameters:
     - input: The amount to fill
     - Returns: The amount left over, if the box is full   */
    func fillUp(_ input:Int) -> Int {
        let maxIntake = capacity - current
        if input >= maxIntake {
            self.current = capacity
            return input - maxIntake
        }else {
            self.current += input
            return 0
        }
    }
    
    static func == (lhs: StorageBox, rhs: StorageBox) -> Bool {
        return lhs.id == rhs.id
    }
    
    // Make a class hashable: https://www.hackingwithswift.com/example-code/language/how-to-conform-to-the-hashable-protocol
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Tanks

/// What a `Tank` holds
enum TankType:String, Codable, CaseIterable, Hashable {
    
    case o2
    case co2
    case n2
    case h2o
    case h2
    case ch4
    case air
    case empty
    
    var capacity:Int {
        switch self {
            case .o2: return 100
            case .co2: return 25
            case .n2: return 50
            case .h2o: return 25
            case .h2: return 10
            case .ch4: return 50
            case .air: return 50
            case .empty: return 0
        }
    }
    
    var name:String {
        switch self {
            case .o2: return "Oxygen"
            case .co2: return "Carbon dioxide"
            case .n2: return "Nitrogen"
            case .h2o: return "Water"
            case .h2: return "Hydrogen"
            case .ch4: return "Methane"
            case .air: return "Breathable air"
            case .empty: return "Empty"
        }
    }
}

/// A `Tank` that holds gases and liquids `Ingredients`
class Tank:Codable, Identifiable, Hashable {
    
    var id:UUID = UUID()
    var type:TankType
    var capacity:Int { return type.capacity }
    var current:Int
    
    init(type:TankType, full:Bool? = false) {
        self.type = type
        self.current = full! ? type.capacity:0
    }
    
    /**
     Fills the tank with the input.
     - Parameters:
     - input: The amount to fill
     - Returns: The amount left over, if the tank is full   */
    func fillUp(_ input:Int) -> Int {
        let maxIntake = capacity - current
        if input >= maxIntake {
            self.current = capacity
            return input - maxIntake
        }else {
            self.current += input
            return 0
        }
    }
    
    static func == (lhs: Tank, rhs: Tank) -> Bool {
        return lhs.id == rhs.id
    }
    
    // Make a class hashable: https://www.hackingwithswift.com/example-code/language/how-to-conform-to-the-hashable-protocol
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Energy

/// Stores energy
class Battery:Codable, Identifiable, Hashable {
    
    var id:UUID = UUID()
    var type:String = "Battery"
    var capacity:Int
    var current:Int
    
    /// A  battery has 100 capacity. When shooped comes full. When made recipe, empty
    init(shopped:Bool) {
        self.capacity = GameLogic.batteryCapacity
        if shopped {
            self.current = GameLogic.batteryCapacity
        }else{
            self.current = 0
        }
    }
    
    init(capacity:Int, current:Int) {
        self.capacity = capacity
        self.current = current
    }
    
    func maxCharge() -> Int {
        return capacity - current
    }
    
    func charge(amount:Int) -> Bool {
        if current == capacity { return false }
        current += amount
        return true
    }
    
    func consume(amt:Int) -> Bool {
        if current >= amt {
            current -= amt
            return true
        }else{
            return false
        }
    }
    
//    func storageType() -> StorageType { return .Battery }
    
    // Equatable
    static func == (lhs: Battery, rhs: Battery) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        
    }
}

// MARK: - Solar Panel

enum SolarTypeSize:Int, Codable, CaseIterable {
    case bigStation
    case smallVehicle
    case bigMars
    var name:String {
        switch self {
        case .bigStation: return "Big Station"
        case .smallVehicle: return "Small Vehicle"
        case .bigMars: return "Big Mars"
        }
    }
    var size:Int {
        switch self {
        case .bigStation: return 10
        case .smallVehicle: return 4
        case .bigMars: return 16
        }
    }
}

struct SolarPanel:Codable, Identifiable {
    
    var id:UUID = UUID()
    var size:Int        // size of panel
    
    var breakable:Bool
    var isBroken:Bool
    var type:SolarTypeSize
    
    /// Information (Name, Position, Orientation) to build a `SCNNode` in the scene
    var model:Model3D?
    
    init() {
        // Check model
        size = 10
        breakable = false
        isBroken = false
        type = .bigStation
    }
    
    init(with sts:SolarTypeSize) {
        self.type = sts
        self.isBroken = false
        self.breakable = sts == .smallVehicle ? true:false
        self.size = sts.size
    }
    
    /// The energy generated
    func maxCurrent() -> Int {
        return size * 20
    }  // output current
    
}
