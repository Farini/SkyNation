//
//  SpaceVehicle.swift
//  SkyTestSceneKit
//
//  Created by Farini on 9/23/20.
//  Copyright © 2020 Farini. All rights reserved.
//

import Foundation

enum EngineType:String, Codable, CaseIterable, Hashable {
    case Hex6
    case T12
    case T18
    case T22
    
    /// How much the `Engine` can carry
    var payloadLimit:Int {
        switch self {
        case .Hex6: return 6
        case .T12: return 12
        case .T18: return 18
        case .T22: return 22
        }
    }
    
    /// Required experience to build this Engine
    var requiredXP:Int {
        switch self {
        case .Hex6: return 0
        case .T12: return 6
        case .T18: return 20
        case .T22: return 60
        }
    }
    
    /// The time for this engine to be ready
    var time:Double {
        switch self {
        case .Hex6: return 18000
        case .T12: return 43200
        case .T18: return 64800
        case .T22: return 86400
        }
    }
    
    /// Te collective skills to make this engine
    var skills:[Skills:Int] {
        switch self {
            case .Hex6: return [.Mechanic:1, .Datacomm:1]
            case .T12: return [.Mechanic:1, .Datacomm:1, .Material:1, .Handy:1]
            case .T18: return [.Mechanic:2, .Datacomm:1, .Material:1, .Electric:1, .Handy:2]
            case .T22: return [.Mechanic:2, .Datacomm:2, .Material:2, .SystemOS:1, .Handy:2]
        }
    }
    
    /// The required ingredients to make this engine
    var ingredients:[Ingredient:Int] {
        switch self {
            case .Hex6: return [.Aluminium:10, .DCMotor:6, .Iron:6]
            case .T12: return [.Aluminium:14, .DCMotor:12, .Iron:8, .Ceramic:6, .Circuitboard:2]
            case .T18: return [.Aluminium:22, .DCMotor:18, .Iron:10, .Ceramic:10, .Circuitboard:4, .Polimer:5]
            case .T22: return [.Aluminium:32, .DCMotor:22, .Iron:15, .Ceramic:15, .Circuitboard:9, .Polimer:8]
        }
    }
    
    var about:String {
        switch self {
            case .Hex6: return "Can carry a satellite to orbit Mars"
            case .T12: return "Can carry a small payload to Mars"
            case .T18: return "Can carry heavier payloads to Mars"
            case .T22: return "Payloads and Passengers can fit here"
        }
    }
    
    var imageSName:String {
        switch self {
            case .Hex6: return "aqi.low"
            case .T12: return "aqi.medium"
            case .T18: return "aqi.high"
            case .T22: return "snow"
        }
    }
    
    var imgSysName:String {
        switch self {
            case .Hex6: return  "EngineH6"
            case .T12: return   "EngineT12"
            case .T18: return   "EngineT18"
            case .T22: return   "EngineT20"
        }
    }
    
    var propulsionNitro:Int {
        switch self {
            case .Hex6: return 5
            case .T12:  return 10
            case .T18:  return -1
            case .T22:  return -1
        }
    }
    
    var propulsionCH4:Int {
        switch self {
            case .Hex6: return 3
            case .T12:  return 5
            case .T18:  return 20
            case .T22:  return 22
        }
    }
}

enum VehicleStatus:String, CaseIterable, Codable, Hashable {
    
    case Creating   // Creating Vehicle - Engine, Satellite
    case Created    // Creation Ready - May add Stuff (Payload, Tanks, etc.)
    
    case Mars           // Travelling to Mars
    case MarsOrbit      // Vehicle Arrived on mars and is in orbit. Register in SQL
    
    // Add these:
    // EDL              // Entry Descent and landing -> Store Data in GuildFile. Remove from SQL
    // waitingArea      // Add contents to CityData, Remove from GuildFile
    // marsHome         // Arrived in city
    
    case Settled          // [DELETE VEHICLE] Vehicle has arrived on mars, and brought things to the base
    case Diying           // [DELETE VEHICLE] Vehicle has crashed either before, or after arriving
    case OutOfFuel        // [delete vehicle] Vehicle is out of fuel
}

/// Mars Tech Equipped in SpaceVehicle
enum MarsBot:String, Codable, CaseIterable, Hashable {
    case Satellite
    case Rover          // Settles the city. Explores environment. Pictures from NASA?
    case Transporter    // Bring stuff in - first one settles the colony (Must have a pass (spent $10, or invited))
    case Terraformer    // Edit Terrain
    
    func ingredients() -> [Ingredient:Int] {
        switch self {
            case .Satellite: return [.Circuitboard:1, .Copper:3]
            case .Rover: return [.Circuitboard:2, .Copper:2, .Aluminium:8]
            case .Transporter: return [.Circuitboard:2, .DCMotor:2, .Aluminium:8]
            case .Terraformer: return [.Circuitboard:4, .DCMotor:6, .Aluminium:8, .Copper:4]
        }
    }
}

class SpaceVehicle:Codable, Identifiable, Equatable {
    
    var id:UUID = UUID()
    var engine:EngineType
    var name:String = "Untitled"    // name it
    var marsBot:MarsBot?
    var status:VehicleStatus = .Creating  // Station, Mars, Building (Station while building)
    
    // Resources
    var tanks:[Tank] = []           // Recommended 1 Methane + 1 Oxygen
    var batteries:[Battery] = []
    var peripherals:[PeripheralObject] = []
    var boxes:[StorageBox] = []
    var passengers:[Person] = []
    var bioBoxes:[BioBox] = []
    
    // Travel Info
    var dateTravelStarts:Date?      // Date ref
    var travelTime:TimeInterval?    // Time?
    var registration:UUID?
    
    init(engine:EngineType) {
        self.engine = engine
    }
    
    func startBuilding() {
        var time:Double = 0
        time += engine.time
        self.status = .Creating
        self.dateTravelStarts = Date() //.addingTimeInterval(TimeInterval(time))
        self.travelTime = Double(time)
    }
    
    /// Sets the Vehicle to start travelling to Mars
    func startTravelling() {
        status = .Mars
        dateTravelStarts = Date()
        travelTime = GameLogic.vehicleTravelTime
    }
    
    func arriveDate() -> Date {
        let startDate = dateTravelStarts!
        let arriveDate = startDate.addingTimeInterval(GameLogic.vehicleTravelTime)
        return arriveDate
    }
    
    /// Calculate how long to finish the current task (Creating, or Travelling)
    func calculateProgress() -> Double? {
        if let dateBegin = dateTravelStarts {
            switch status {
                case .Creating:
                    let dateEnd = dateBegin.addingTimeInterval(engine.time)
                    let totalSeconds = dateEnd.timeIntervalSince(dateBegin)
                    let elapsed = Date().timeIntervalSince(dateBegin)
                    let progress = elapsed / totalSeconds
                    if elapsed > totalSeconds {
                        return 1.0
                    } else {
                        return progress
                    }
                case .Mars:
                    let travelTime:TimeInterval = GameLogic.vehicleTravelTime
                    let dateEnd = dateBegin.addingTimeInterval(travelTime)
                    let totalSeconds = dateEnd.timeIntervalSince(dateBegin)
                    let elapsed = Date().timeIntervalSince(dateBegin)
                    let progress = elapsed / totalSeconds
                    if elapsed > totalSeconds {
                        return 1.0
                    } else {
                        return progress
                    }
                default: return nil
            }
        }
        return nil
    }
    
    /// Calculates the weight of this vehicle
    func calculateWeight() -> Int {
        
        print("\n Vehicle Weight \n------")
        
        let engineWeight = Int(Double(engine.payloadLimit) * 1.2)
        var weight:Int = 0 // engineWeight
        
        print("+ Engine: \(engineWeight)")
        
        for _ in tanks {
            weight += 1
        }
        print("+ Tanks: \(tanks.count)")
        
        for _ in batteries {
            weight += 1
        }
        print("+ Batteries: \(batteries.count)")
        
        for _ in peripherals {
            // weight += 1
        }
        
        for _ in boxes {
            weight += 1
        }
        
        for _ in passengers {
            weight += 1
        }
        
//        if let antenna = antenna {
//            print("Antenna level: \(antenna.level)")
//            weight += 1
//        }
        
        return weight
    }
    
    /// Check if enough fuel to complete trip
    func checkFuel() -> Bool {
        
        let weight = calculateWeight()
        let distance = 70
        
        var methane:Int = 0
        var oxygen:Int = 0
        var nitro:Int = 0
        
        // Methane + Oxygen
        for tank in tanks {
            switch tank.type {
                case .ch4:methane += tank.current
                case .o2: oxygen += tank.current
                case .n2: nitro += tank.current
                default: print("Not a fuel tank000")
            }
        }
        
        // Methane and Oxygen
        let neededMethane = max(Int(weight/50), 1) * Int(distance / 2)
        let neededOxygen = weight + Int(distance / 2)
        let neededNitro = weight * (distance / 10)
        
        print("\n Vehicle Fuel Check \n------")
        print("Vehicle Weight: \(weight)")
        print("Methane: \(methane) of \(neededMethane) \(methane >= neededMethane ? "Pass":"Fail")")
        print("Oxygen: \(oxygen) of \(neededOxygen) \(oxygen >= neededOxygen ? "Pass":"Fail")")
        print("Nitro: \(nitro) of \(neededNitro)")
        print("------")
        
        var percentage:Double = 0
        
        // Methane + Oxygen
        if methane >= neededMethane && oxygen >= neededOxygen {
            print("Enough Fuel !!\n")
            return true
        }else{
            percentage = min(Double(methane / neededMethane),Double(oxygen / neededOxygen))
        }
        
        // Nitro
        if nitro >= neededNitro {
            print("Enough Nitro !!\n")
            return true
        }else{
            percentage += Double(nitro / neededNitro)
        }
        
        // Combined
        if percentage >= 0.99 {
            print("Passed Combined Values")
            return true
        }
        
        return false
        
    }
    
    // MARK: - Ready Instances
    
    static func builtExample() -> SpaceVehicle {
        let vehicle = SpaceVehicle(engine: .Hex6)
        let t1 = Tank(type: .ch4, full: true)
        let b1 = Battery(capacity: 100, current: 90)
        vehicle.batteries = [b1]
        vehicle.tanks = [t1]
        return vehicle
    }
    
    /// Example of a big vehicle (for the loading screen)
    static func bigLoad() -> SpaceVehicle {
        
        let vehicle = SpaceVehicle(engine: .T18)
        let t1 = Tank(type: .ch4, full: true)
        let t2 = Tank(type: .o2, full: true)
        let nitro = Tank(type: .n2, full: true)
        let b1 = Battery(capacity: 100, current: 100)
        
        vehicle.tanks = [t1, t2, nitro]
        vehicle.batteries = [b1]
        vehicle.status = .Creating
        vehicle.name = "Boogie Down"
        
        return vehicle
    }
    
    /// Example of a travelling vehicle
    static func travellingExample() -> SpaceVehicle {
        
        let vehicle = SpaceVehicle(engine: .Hex6)
        
        let t1 = Tank(type: .ch4, full: true)
        let t2 = Tank(type: .o2, full: true)
        let b1 = Battery(capacity: 100, current: 100)
        let b2 = Battery(capacity: 100, current: 20)
        
        vehicle.tanks = [t1, t2]
        vehicle.batteries = [b1, b2]
        vehicle.status = .Mars
        vehicle.travelTime = GameLogic.vehicleTravelTime
        vehicle.name = "Tester"
        
        return vehicle
    }
    
    /// Example of a bigger vehicle (Travelling)
    static func biggerExample() -> SpaceVehicle {
        
        let vehicle = SpaceVehicle(engine: .T18)
        
        let t1 = Tank(type: .ch4, full: true)
        let t2 = Tank(type: .o2, full: true)
        let t3 = Tank(type: .ch4, full: true)
        let t4 = Tank(type: .o2, full: true)
        let nitro = Tank(type: .n2, full: true)
        
        let b1 = Battery(capacity: 100, current: 100)
        let b2 = Battery(capacity: 100, current: 20)
        
        vehicle.tanks = [t1, t2, t3, t4, nitro]
        vehicle.batteries = [b1, b2]
        vehicle.status = .Mars
        vehicle.travelTime = GameLogic.vehicleTravelTime
        vehicle.name = "Tester T18"
        
        return vehicle
    }
    
    // Equatable
    static func == (lhs: SpaceVehicle, rhs: SpaceVehicle) -> Bool {
        return lhs.id == rhs.id
    }
    
}

/*
 The database sets the ID
 If we add another UUID to SpaceVehicle, that could be the "Server Ticket" - The Server ID of the vehicle
 */

/// A copy of `SpaceVehicle` used to Post to the server
struct SpaceVehiclePost:Codable {
    
    // non-identifiable
    
    /// The ID of the original SpaceVehicle object.
    var localID:UUID
    
    var eta:Date
    var owner:UUID
    var engine:String
    var status:String
    
    
    init(spaceVehicle:SpaceVehicle, playerID:UUID) {
        self.localID = spaceVehicle.id
        self.eta = Date().addingTimeInterval(GameLogic.vehicleTravelTime)
        self.owner = playerID
        self.engine = spaceVehicle.engine.rawValue
        self.status = spaceVehicle.status.rawValue
    }
    
}

/// When Posting `SpaceVehiclePost`, this is the response. Link to Vehicle immediately. This is also the object that the server has
struct SpaceVehicleTicket:Codable {
    
    /// The ID, given by the server
    var id:UUID
    
    /// The ID of the original `SpaceVehicle`
    var localID:UUID
    
    var eta:Date
    var owner:UUID
    var engine:String
    var status:String
    
    // No Initializer - Decoded from Server
}

/*
struct SpaceVehicleModel:Codable {

    var id:UUID?
    var eta:Date
    var owner:UUID
    var engine:String
    var status:String

    init(spaceVehicle:SpaceVehicle, player:SKNUserPost) {
        self.id = spaceVehicle.id
        self.eta = Date().addingTimeInterval(60 * 60 * 24 * 5)
        self.owner = player.id
        self.engine = spaceVehicle.engine.rawValue
        self.status = spaceVehicle.status.rawValue
    }
}

struct SpaceVehicleContent:Codable {
    
    var id:UUID?
    var eta:Date
    var owner:UUID
    var engine:String
    var status:String
    
    var boxes:[StorageBox]
    var tanks:[Tank]
    var peripherals:[PeripheralObject]
    var batteries:[Battery]
    var passengers:[Person]
    
    /// Makes a `SpaceVehicleContent` instance of a SpaceVehicle
    init(with vehicle:SpaceVehicle) {
        self.id = vehicle.id
        self.eta = vehicle.arriveDate()
        owner = LocalDatabase.shared.player?.playerID ?? UUID()
        engine = vehicle.engine.rawValue
        status = vehicle.status.rawValue
        boxes = vehicle.boxes
        tanks = vehicle.tanks
        peripherals = vehicle.peripherals
        batteries = vehicle.batteries
        passengers = vehicle.passengers
    }
}
*/

