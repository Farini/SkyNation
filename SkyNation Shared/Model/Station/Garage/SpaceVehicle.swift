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
            case .T12: return [.Mechanic:1, .Datacomm:1, .Material:1]
            case .T18: return [.Mechanic:2, .Datacomm:2, .Material:1, .Handy:2]
            case .T22: return [.Mechanic:3, .Electric:2, .Datacomm:2, .Handy:2, .Material:2]
        }
    }
    
    /// The required ingredients to make this engine
    var ingredients:[Ingredient:Int] {
        switch self {
            case .Hex6: return [.Aluminium:10, .DCMotor:6, .Iron:6]
            case .T12: return [.Aluminium:14, .DCMotor:12, .Iron:8, .Ceramic:6, .Circuitboard:2]
            case .T18: return [.Aluminium:22, .DCMotor:18, .Iron:10, .Ceramic:10, .Circuitboard:4, .Polimer:5]
            case .T22: return [.Aluminium:32, .DCMotor:22, .Iron:18, .Ceramic:15, .Circuitboard:9, .Polimer:13]
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
    
    // Deprecate
    // case Exploring      // Vehicle Arrived on mars and is exploring (rover)
    // case Station        // Travelling back home
    
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
    // case GrandMaster    // Can do the job of .handy?
}

class SpaceVehicle:Codable, Identifiable, Equatable {
    
    var id:UUID = UUID()
    var engine:EngineType
    var marsBot:MarsBot?
    var status:VehicleStatus = .Creating  // Station, Mars, Building (Station while building)
    
    // Resources
    var tanks:[Tank] = []           // Recommended 1 Methane + 1 Oxygen
    var batteries:[Battery] = []
    var peripherals:[PeripheralObject] = []
    var boxes:[StorageBox] = []
    var passengers:[Person] = []
    var air:AirComposition?
    
    // Bioboxes
    
    
    var solar:[SolarPanel] = []
    var antenna:PeripheralObject?

    // Travel Info
    var name:String = "Untitled"    // name it
    var simulation:Int = 0          // hours simulating
    var dateTravelStarts:Date?      // Date ref
    var travelTime:TimeInterval?    // Time?
    var dateAccount:Date?
    
    init(engine:EngineType) {
        self.engine = engine
    }
    
    func startBuilding() {
        var time:Double = 0
        time += engine.time
        self.simulation = 0
        self.status = .Creating
        self.dateTravelStarts = Date().addingTimeInterval(TimeInterval(time))
        self.travelTime = Double(time)
    }
    
    /// Sets the Vehicle to start travelling to Mars
    func startTravelling() {
        status = .Mars
        dateTravelStarts = Date()
        travelTime = 60 * 60 * 24 * 7
    }
    
    func arriveDate() -> Date {
        let startDate = dateTravelStarts!
        let arriveDate = startDate.addingTimeInterval(travelTime ?? 0)
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
                    let oneWeek:TimeInterval = 60 * 60 * 24 * 7
                    let dateEnd = dateBegin.addingTimeInterval(oneWeek)
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
    
    func runAccounting() {
        // Accounting
        // ---------------------
        // 0 - Update the dateAccounting. If doesn't exist, create date now
        // 0 - Energy input -> Charge batteries
        // 1 - Peripherals cant work without energy
        // 2 - Calculate Weight to see how much propulsion is needed
        // 3 - Account for humans (if any)
        // 4 - Sattelite consumes energy after arrives
        // 5 - Antenna consumes energy until arrives
        
        // 0 - Update the dateAccounting. If doesn't exist, create date now
        if let lastAccount = dateAccount {
            let nextAccount = lastAccount.addingTimeInterval(3600) // 1hr
            if Date().compare(nextAccount) == .orderedDescending {
                // need to run account
            }else{
                print("no need to run account")
                return
            }
        } else {
            // Accounting hasn't been setup yet
            self.dateAccount = Date()
            return
        }
        
        // 0 - Energy input -> Charge batteries
        var energyProd:Int = 0
        for panel in solar {
            energyProd += panel.maxCurrent()
        }
        while energyProd > 0 {
            for battery in batteries {
                battery.current += 1
                energyProd -= 1
            }
        }
        
        // TODO: - Peripheral
        // 1 - Peripherals cant work without energy Needs to add *Peripheral* to vehicle
        
        // 2 - Calculate Weight to see how much propulsion is needed
        if checkFuel() == true {
            print("Fuel Test passed")
        }else{
            print("Fuel Test failed")
        }
        
        // 3 - Account for humans (if any)
        // 4 - Sattelite consumes energy after arrives
        // 5 - Antenna consumes energy until arrives
        // 6 - Update the dateAccounting. If doesn't exist, create date now
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
        
        if let antenna = antenna {
            print("Antenna level: \(antenna.level)")
            weight += 1
        }
        
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
        vehicle.simulation = 1
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
        vehicle.travelTime = 604800
        vehicle.simulation = 2
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
//        vehicle.heatshield = .eighteen
        vehicle.status = .Mars
        vehicle.travelTime = 604800
        vehicle.simulation = 2
        vehicle.name = "Tester T18"
        
        return vehicle
    }
    
    // Equatable
    static func == (lhs: SpaceVehicle, rhs: SpaceVehicle) -> Bool {
        return lhs.id == rhs.id
    }
    
}

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
