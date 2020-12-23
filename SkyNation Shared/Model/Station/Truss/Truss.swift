//
//  Truss.swift
//  SkyTestSceneKit
//
//  Created by Farini on 9/13/20.
//  Copyright © 2020 Farini. All rights reserved.
//

import Foundation

class Truss:Codable {
    
    static let solarPanelsLimit:Int = 8
    static let extraBoxesLimit:Int = 12
    static let tanksLimit:Int = 18
    static let limitOfBatteries:Int = 10
    
    var solarPanels:[SolarPanel]
    var extraBoxes:[StorageBox]
    var tanks:[Tank]
    
    /// Gives energy to objects that need it
    var batteries:[Battery]
    
    /// Makes money for the `Station`
    var antenna:PeripheralObject
    
    /// Calculates the amount of money the `Antenna` makes
    func moneyFromAntenna() -> Int {
        var profits:Int = 100
        var level = antenna.level * 25
        if antenna.level > 3 {
            profits -= (antenna.level - 3) * 18
            level += antenna.level * 2
        }
        return profits + level
    }
    
    func getBatteries() -> [Battery] {
        return batteries
    }
    
    func getTanks() -> [Tank] {
        var tankArray:[Tank] = []
        for tank in tanks {
            tankArray.append(tank)
        }
        return tankArray
    }
    
    func addRecipeSolar(panel:SolarPanel) {
        var panels = solarPanels
        panels.append(panel)
        self.solarPanels = panels
    }
    
    func addTank(tankType:TankType) -> Bool {
        if Truss.tanksLimit > tanks.count {
            var tankArray = tanks
            let newTank = Tank(type: tankType, full: true)
            tankArray.append(newTank)
            self.tanks = tankArray
            return true
        }
        return false
    }
    
    // FIXME: - Modifications
    // ⚠️ Needs to add and test:
    var tComponents:[TrussComponent]
    
    
    // NEW (Under test 12/08/2020)
    func addNewSolarPanel() {
        // Automatically places a new Solar Panel, after its made
        // Check PeriPositions
        // Count the objects to set "positionIndex"
    }
    func addNewRadiator() {
        // Automatically places a new Radiator (PeripheralObject), after its made
        // Add radiator here
    }
    
    // FIXME: - Putting back in Containers
    // Put back....
    // Water
    // Pee (wasteLiquid)
    // Poop (wasteSolid)
    func refillTanks(of type:TankType, amount:Int) -> Int {
        var leftOvers:Int = amount
        let tanksArray = tanks.filter({ $0.type == type })
        for tank in tanksArray {
            if leftOvers <= 0 {
                return 0
            }else{
                let input = leftOvers
                let output = tank.fillUp(input)
                leftOvers = output
            }
        }
        return leftOvers
    }
    
    func refillContainers(of type:Ingredient, amount:Int) -> Int {
        var leftOvers = amount
        let boxArray = extraBoxes.filter({ $0.type == type })
        for box in boxArray {
            if leftOvers <= 0 {
                return 0
            } else {
                let input = leftOvers
                let output = box.fillUp(input)
                leftOvers = output
            }
        }
        return leftOvers
    }
    
    // MARK: - Charging
    
    /// Tries to consume the `energy` passed. `Returns` whether it was successful
    func consumeEnergy(amount:Int) -> Bool {
        var consumption = amount
        let ttl = batteries.map({ $0.current }).reduce(0, +)
        // return nil if not enough energy
        if ttl < consumption {
            return false
        } else {
            for b in batteries {
                if b.current < consumption {
                    consumption -= b.current
                    b.current = 0
                } else {
                    b.current -= consumption
                    consumption = 0
                }
            }
            return true
        }
    }
    
    func getAvailableEnergy() -> Int {
        return batteries.map({ $0.current }).reduce(0, +)
    }
    
    func canCharge(ingredients:[Ingredient:Int]) -> Bool {
        var pass:Bool = true
        for (ingr, qtty) in ingredients {
            let relevantBoxes = extraBoxes.filter({ $0.type == ingr })  // Filter
            let iHave = relevantBoxes.map({$0.current}).reduce(0, +)    // Reduce (see: https://stackoverflow.com/questions/24795130/finding-sum-of-elements-in-swift-array)
            if iHave < qtty {
                pass = false
            }
        }
        return pass
    }
    
    /**
     Checks if there are enough ingredients to cover the expenses.
    - Parameters:
    - ingredients: a key value of ingredient and quantity
    - Returns: An array of missing Ingredients (empty if none) */
    func validateResources(ingredients:[Ingredient:Int]) -> [Ingredient] {
        
        var lacking:[Ingredient] = []
        for (ingr, qtty) in ingredients {
            let relevantBoxes = extraBoxes.filter({ $0.type == ingr })  // Filter
            let iHave = relevantBoxes.map({$0.current}).reduce(0, +)    // Reduce (see: https://stackoverflow.com/questions/24795130/finding-sum-of-elements-in-swift-array)
            if iHave < qtty {
                lacking.append(ingr)
            }
        }
        return lacking
        
    }
    
    init() {
        // Solar Panels
        let solar1 = SolarPanel()
        self.solarPanels = [solar1]
        
        // Batteries
        let b1 = Battery(shopped: true)
        let b2 = Battery(shopped: true)
        self.batteries = [b1, b2]
        
        // Boxes
        let peepee = StorageBox(ingType: .wasteLiquid, current: 0)
        let poopoo = StorageBox(ingType: .wasteSolid, current: 0)
        self.extraBoxes = [peepee, poopoo]
        
        // Air, oxygen and water
        self.tanks = [Tank(type: .air, full: true), Tank(type: .o2, full: true), Tank(type: .h2o, full: true), Tank(type: .h2o, full: true)]
        
        // Antenna
        let newAntenna = PeripheralObject(peripheral: .Antenna)
        newAntenna.level = 1
        self.antenna = newAntenna
        
        // Components
        let tRobot = TrussComponent(index: 0)
        
        let sp1 = TrussComponent(index: 11)
        let solarAdd = sp1.insert(solar: solar1)
        if (!solarAdd) {
            print("Unable to add first solar panel")
        }
        let sp2 = TrussComponent(index: 12)
        let sp3 = TrussComponent(index: 13)
        let sp4 = TrussComponent(index: 14)
        let sp5 = TrussComponent(index: 15)
        let sp6 = TrussComponent(index: 16)
        let sp7 = TrussComponent(index: 17)
        let sp8 = TrussComponent(index: 18)
        
        let tR1 = TrussComponent(index: 31)
        let tR2 = TrussComponent(index: 32)
        let tR3 = TrussComponent(index: 33)
        let tR4 = TrussComponent(index: 34)
        
        self.tComponents = [tRobot, sp1, sp2, sp3, sp4, sp5, sp6, sp7, sp8, tR1, tR2, tR3, tR4]
         
    }
}

enum TrussItemType:String, Codable, CaseIterable {
    case Solar
    case Radiator
    case RoboArm
}

/// An object used to layout `PeripheralObject`and `SolarPanel` in the `Truss` so the user may place them where they want.
class TrussComponent:Codable, Identifiable, Equatable {
    
    /// The ID of this object
    var id:UUID
    
    /// The ID of the PeripheralObject, or SolarPanel
    var itemID:UUID?
    
    var posIndex:Int
    
    var allowedType:TrussItemType
    
    /// Implement this, to conveniently position and rotate object
//    func getPositionForPositionIndex() -> Model3D? {
//        return nil
//    }
    
    func getPosition() -> Vector3D? {
        switch posIndex {
            // Roboarm
            case 0: return Vector3D.zero
            
            // Solar Panels
            case 11: return Vector3D(x: 0, y: -18, z: 2.42)
            case 12: return Vector3D(x: 0, y: -14, z: 2.42)
            case 13: return Vector3D(x: 0, y: -18, z: -2.42)
            case 14: return Vector3D(x: 0, y: -14, z: -2.42)
            
            case 15: return Vector3D(x: 0, y: 14, z: 2.42)
            case 16: return Vector3D(x: 0, y: 18, z: 2.42)
            case 17: return Vector3D(x: 0, y: 14, z: -2.42)
            case 18: return Vector3D(x: 0, y: 18, z: -2.42)
            
            // Radiators
            case 31: return Vector3D(x: -2.42, y: -18, z: 0)
            case 32: return Vector3D(x: -2.42, y: -14, z: 0)
            case 33: return Vector3D(x: -2.42, y: 14, z: 0)
            case 34: return Vector3D(x: -2.42, y: 18, z: 0)
            
            default: return nil
        }
    }
    
    func getRotation() -> Vector3D? {
        switch posIndex {
            // Roboarm
            case 0: return Vector3D.zero
                
            // Solar Panels
            case 11: return Vector3D(x: GameLogic.radiansFrom(90), y: 0, z: GameLogic.radiansFrom(90))
            case 12: return Vector3D(x: GameLogic.radiansFrom(90), y: 0, z: GameLogic.radiansFrom(90))
            case 13: return Vector3D(x: GameLogic.radiansFrom(-90), y: 0, z: GameLogic.radiansFrom(90))
            case 14: return Vector3D(x: GameLogic.radiansFrom(-90), y: 0, z: GameLogic.radiansFrom(90))
                
            case 15: return Vector3D(x: GameLogic.radiansFrom(90), y: 0, z: GameLogic.radiansFrom(90))
            case 16: return Vector3D(x: GameLogic.radiansFrom(90), y: 0, z: GameLogic.radiansFrom(90))
            case 17: return Vector3D(x: GameLogic.radiansFrom(-90), y: 0, z: GameLogic.radiansFrom(90))
            case 18: return Vector3D(x: GameLogic.radiansFrom(-90), y: 0, z: GameLogic.radiansFrom(90))
                
            // Radiators
            case 31: return Vector3D(x: GameLogic.radiansFrom(90), y: GameLogic.radiansFrom(-90), z: 0)
            case 32: return Vector3D(x: GameLogic.radiansFrom(90), y: GameLogic.radiansFrom(-90), z: 0)
            case 33: return Vector3D(x: GameLogic.radiansFrom(90), y: GameLogic.radiansFrom(-90), z: 0)
            case 34: return Vector3D(x: GameLogic.radiansFrom(90), y: GameLogic.radiansFrom(-90), z: 0)
                
            default: return nil
        }
    }
    
    func insert(solar panel:SolarPanel) -> Bool {
        guard allowedType == .Solar && itemID == nil else { return false }
        self.itemID = panel.id
        return true
    }
    
    func insert(radiator:PeripheralObject) -> Bool {
        guard allowedType == .Radiator && itemID == nil else { return false }
        self.itemID = radiator.id
        return true
    }
    
    func remove(solar panel:SolarPanel) -> Bool {
        guard allowedType == .Solar else { return false }
        self.itemID = nil
        return true
    }
    
    func remove(radiator:PeripheralObject) -> Bool {
        guard allowedType == .Radiator else { return false }
        self.itemID = nil
        return true
    }
    
    init(index:Int) {
        self.id = UUID()
        switch index {
            case 0: self.allowedType = .RoboArm
            case 11...20: self.allowedType = .Solar
            case 31...50: self.allowedType = .Radiator
            default: fatalError()
        }
        self.posIndex = index
    }
    
    static func == (lhs: TrussComponent, rhs: TrussComponent) -> Bool {
        return lhs.id == rhs.id
    }
    
}

// MARK: - Air

/// General quality of the air, counting with **CO2**, **Oxygen**, and other properties
enum AirQuality:String {
    case Great
    case Good
    case Medium
    case Bad
    case Lethal
    
    func decrease() -> AirQuality {
        switch self {
            case .Great: return .Good
            case .Good: return .Medium
            case .Medium: return .Bad
            case .Bad: return .Lethal
            case .Lethal: return .Lethal
        }
    }
}

/// The air inside the **Station**, **SpaceVehicle**, etc.
class AirComposition:Codable {
    
    var volume:Int      // The amount of all particles
    
    var o2:Int          // min, max
    var co2:Int         // 0, max
    var n2:Int          // min, max
    var h2o:Int         // min, max (Humidity)
    var h2:Int          // 0, max
    var ch4:Int         // 0, max
    
    // Compute
    // compute acceptable ranges
    // compute "orange" ranges
    // compute red ranges
    // Shouldn't this be in GameLogic?
    func computeO2() -> (min:Double, max:Double, result:Double) {
        // green < 19, green > 25
        // orange <= 17, orange > 23
        // 17(O) < 20(G) < 21 > 23(G) > 25(O)
        let percentO2 = Double((o2/volume)) * 100
        let gmin = 0.17 * Double(volume)
        let gmax = 0.25 * Double(volume)
        return(min:gmin, max:gmax, result:percentO2)
    }
    
    /// Initializes - pass ammount if a Tank, or nil to start
    init(amount:Int? = GameLogic.airPerModule * 4) {
        guard let amt = amount else { fatalError() }
        self.volume = amt
        let totalAir = Double(amt)
        self.o2 = Int(totalAir * 0.21)
        if amt <= 300 {
            self.co2 = 1 // Int(totalAir * 0.0003)
        }else{
            self.co2 = 0
        }
        self.n2 = Int(totalAir * 0.78)
        self.h2o = Int(totalAir * 0.01)
        self.h2 = 0
        self.ch4 = 0
//        self.tanks = [:]
    }
    
    // one cycle
    func breathe(humans:Int) {
        //        let amt = Double(humans)
        o2 -= humans
        co2 += humans
        //        h2o += humans
    }
    
    // To filter CO2, it changes the volume
    func filterCO2(qtty:Int) {
        
        // there must be enough
        if co2 > (qtty * 10) {
            // energy that it takes to filter
            co2 -= qtty
            volume -= qtty
            // add the cartridges logic
        }
    }
    
    /// Adds an amount of air to this air
    func mergeWith(newAirAmount:Int) {
        // 70% nitrogen
        // 30% oxygen
        let nitroAmount = Int(Double(newAirAmount) * 0.7)
        let oxygenAmount = Int(Double(newAirAmount) * 0.3)
        self.n2 += nitroAmount
        self.o2 += oxygenAmount
    }
    
    // TODO: - Put air requirements in GameLogic
    /// Gets the Air Quality of the station
    func airQuality() -> AirQuality {
        
        let newVolume = o2 + co2 + n2 + h2 + ch4 // (Water vapor doesn't count?)
        var currentQuality:AirQuality = .Great
        
        // CO2
        let percentageCO2 = Double(co2) / Double(newVolume)
        if  percentageCO2 > 0.05 {
            currentQuality = currentQuality.decrease()
            if percentageCO2 > 0.15 {
                currentQuality = .Bad
                if percentageCO2 > 0.2 {
                    return .Lethal
                }
            }
        }
        
        // Oxygen
        let percentageO2 = Double(o2) / Double(newVolume)
        if percentageO2 < 0.2 {
            currentQuality = currentQuality.decrease()
            if percentageO2 < 0.1 {
                return .Lethal
            }
        }
        
        let percentageHydrogen = Double(h2) / Double(newVolume)
        if percentageHydrogen > 0.1 || ch4 > 5 {
            currentQuality = currentQuality.decrease()
            if percentageHydrogen > 0.2 || ch4 > 10 {
                return .Lethal
            }
        }
        
        return currentQuality
        
    }
    
    /// Calculate if needs oxygen
    func needsOxygen() -> Int {
        let pct:Double = Double(o2) / Double(volume)
        if pct < 0.22 {
            let needed = (Double(volume) * 0.22) - Double(o2)
            return Int(needed)
        } else {
            return 0
        }
    }
    
    /// Describes the air, with quality
    func describe() -> String {
        
        var tmp:String = ""
        let newVolume = o2 + co2 + n2 + h2 + ch4 // (Water vapor doesn't count?)
        tmp += "Volume:\(newVolume)\n"
        tmp += "Oxygen: \(o2)\n"
        tmp += "CO2: \(co2)\n"
        tmp += "Nitrogen: \(n2)\n"
        tmp += "H2O Vapor: \(h2o)\n"
        if h2 > 0 || ch4 > 0 {
            tmp += "H2: \(h2), Methane:\(ch4) \n"
        }
        tmp += "\t Quality: \(self.airQuality().rawValue)"
        return tmp
    }
}

