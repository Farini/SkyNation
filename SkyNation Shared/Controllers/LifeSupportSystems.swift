//
//  LifeSupportSystems.swift
//  SkyTestSceneKit
//
//  Created by Farini on 8/29/20.
//  Copyright © 2020 Farini. All rights reserved.
//

import Foundation

enum LSSTab:String, CaseIterable {
    case Air
    case Resources
    case Machinery
    case Power
    case System
}

enum LSSViewState {
    case Air
    case Resources(type:RSSType)
    case Machinery(object:PeripheralObject?)
    case Energy
    case Systems
}

enum RSSType {
    case Peripheral(object:PeripheralObject)
    case Tank(object:Tank)
    case Box(object:StorageBox)
    case None
}

protocol LSSDelegate {
    
    func consumeEnergy(amt:Int) -> Bool
    
    // Tanks & Boxes Control
    func discardTank(_ tank:Tank)
    func mergeTanks(_ origin:Tank)
    func defineType(_ tank:Tank, type:TankType)
    func emptyTank(_ tank:Tank)
    func canReleaseInAir(tank:Tank, amt:Int) -> Bool
    func doReleaseInAir(tank:Tank, amt:Int)
    
    // Peripheral Control
    func instantUse(peripheral:PeripheralObject)
    func powerToggle(peripheral:PeripheralObject)
    func fixBroken(peripheral:PeripheralObject)
    func getPeripherals() -> [PeripheralObject]
    
}

class LSSModel:ObservableObject, LSSDelegate {
    
    var station:Station
    
    // State
    @Published var viewState:LSSViewState = LSSViewState.Air
    @Published var segment:LSSTab = .Power {
        didSet {
            print("Did set tab: \(segment.rawValue)")
            didSelect(segment: segment)
        }
    }
    
    @Published var air:AirComposition
    @Published var batteries:[Battery]                 // Batteries
    @Published var tanks:[Tank]                        // Tanks
    @Published var boxes:[StorageBox]
    @Published var peripherals:[PeripheralObject]
    
    @Published var inhabitants:Int                     // Count of
    
    // Air
    @Published var requiredAir:Int          // Sum  of modules' volume
    @Published var liquidWater:Int
    @Published var availableFood:[String]
    
    // Energy
    @Published var levelZ:Double
    @Published var levelZCap:Double
    @Published var solarPanels:[SolarPanel] = []
    @Published var batteriesDelta:Int       // How much energy gainin/losing
    
    /// Energy consumption of Peripherals
    @Published var consumptionPeripherals:Int
    /// Energy Consumption of Modules
    @Published var consumptionModules:Int
    /// Energy Produced
    @Published var energyProduction:Int
  
    // Accounting
    
    @Published var accountDate:Date
    @Published var accountingProblems:[String] = LocalDatabase.shared.accountingProblems
    @Published var accountingReport:AccountingReport?
    
    @Published var peripheralIssues:[String] = []
    @Published var peripheralMessages:[String] = []
    
    // MARK: - Methods
    
    init() {
        
        guard let myStation = LocalDatabase.shared.station else {
            fatalError("No station")
        }
        self.station = myStation
        self.accountDate = myStation.accountingDate
        
        // Solar Panels
        self.solarPanels = myStation.truss.solarPanels
        let totalCharge = myStation.truss.solarPanels.map({ $0.maxCurrent() }).reduce(0, +)
        self.energyProduction = totalCharge
        
        // Batteries
        let batteryPack = myStation.truss.batteries
        self.batteries = batteryPack
        
        if !batteryPack.isEmpty {
            let totalCurrent = batteryPack.map({ $0.current }).reduce(0, +)
            let totalCapacity = batteryPack.map({ $0.capacity }).reduce(0, +)

            self.levelZ = Double(totalCurrent)
            self.levelZCap = Double(totalCapacity)
            
        }else{
            // For tests purposes
            let b1 = Battery(capacity: 1000, current: 800)
            self.batteries = [b1]
            self.levelZ = 800
            self.levelZCap = 1000
        }
        
        // Peripherals
        self.peripherals = myStation.peripherals.sorted(by: { $0.peripheral.rawValue.compare($1.peripheral.rawValue) == .orderedAscending })
        
        let workingPeripherals = myStation.peripherals.filter({ $0.isBroken == false && $0.powerOn == true })
        let energyFromPeripherals:Int = workingPeripherals.map({$0.peripheral.energyConsumption}).reduce(0, +)
        self.consumptionPeripherals = energyFromPeripherals
        
        // Account for energy change
        var deltaZ = totalCharge - energyFromPeripherals
        
        // Modules Consumption
        let modulesCount = myStation.labModules.count + myStation.habModules.count + myStation.bioModules.count
        
        let modulesConsume = modulesCount * GameLogic.energyPerModule
        self.consumptionModules = modulesConsume
        deltaZ -= modulesConsume
        
        self.batteriesDelta = deltaZ
        
        // Air
        let reqAir = station.calculateNeededAir()
        self.requiredAir = reqAir
        
        let theAir = myStation.air
        air = theAir
        
        // Tanks + Water
        self.tanks = myStation.truss.tanks.sorted(by: { $0.type.rawValue.compare($1.type.rawValue) == .orderedAscending })
        let waterTanks:[Tank] = myStation.truss.tanks.filter({ $0.type == .h2o })
        self.liquidWater = waterTanks.map({ $0.current }).reduce(0, +)
        
        // Ingredients (Boxes)
        self.boxes = myStation.truss.extraBoxes.sorted(by: { $0.type.rawValue.compare($1.type.rawValue) == .orderedAscending })
        
        // People
        self.inhabitants = myStation.habModules.map({ $0.inhabitants.count }).reduce(0, +) //myStation.people.count
        
        // Food
        let stationFood = station.food
        var totalFood = stationFood
        for bioModule in station.bioModules {
            for bioBox in bioModule.boxes.filter({ $0.mode == .multiply}) {
                totalFood.append(contentsOf: bioBox.population.filter({ bioBox.perfectDNA == $0 }))
            }
        }
        self.availableFood = totalFood
        
        // Accounting
        self.accountingReport = station.accounting
        
        // After initialized
        self.peripherals.append(myStation.truss.antenna)
        updateEnergyLevels()
        
    }
    
    // Segment Selection
    func didSelect(segment:LSSTab) {
        switch segment {
            case .Air: self.viewState = .Air
            case .Resources: self.viewState = .Resources(type: .None)
            case .Machinery: self.viewState = .Machinery(object:nil)
            case .Power:self.viewState = .Energy
            case .System: self.viewState = .Systems
        }
    }
    
    // Resource Selection
    func didSelect(utility:Codable) {
        print("Did select Utility")
        if let peripheral = utility as? PeripheralObject {
            print("Peripheral")
            self.viewState = .Machinery(object:peripheral) //.Resources(type: .Peripheral(object: peripheral))
        } else if let tank = utility as? Tank {
            print("Tank")
            self.viewState = .Resources(type: .Tank(object: tank))
        } else if let box = utility as? StorageBox {
            print("Box")
            self.viewState = .Resources(type: .Box(object: box))
        }
    }
    
    // Updating UI
    
    func updateDisplayVars() {
        
        let myStation = station
        
        // Solar Panels
        self.solarPanels = myStation.truss.solarPanels
        let totalCharge = myStation.truss.solarPanels.map({ $0.maxCurrent() }).reduce(0, +)
        self.energyProduction = totalCharge
        
        // Batteries
        let batteryPack = myStation.truss.batteries
        self.batteries = batteryPack
        if !batteryPack.isEmpty {
            let totalCurrent = batteryPack.map({ $0.current }).reduce(0, +)
            let totalCapacity = batteryPack.map({ $0.capacity }).reduce(0, +)
            
            self.levelZ = Double(totalCurrent)
            self.levelZCap = Double(totalCapacity)
        }
        
        // Peripherals
        self.peripherals = myStation.peripherals
        let workingPeripherals = myStation.peripherals.filter({ $0.isBroken == false && $0.powerOn == true })
        let energyFromPeripherals:Int = workingPeripherals.map({$0.peripheral.energyConsumption}).reduce(0, +)
        self.consumptionPeripherals = energyFromPeripherals
        
        // Account for energy change
        var deltaZ = totalCharge - energyFromPeripherals
        
        // Modules Consumption
        let modulesCount = myStation.labModules.count + myStation.habModules.count + myStation.bioModules.count
        
        // FIXME: - Module Consumption (Update)
        let modulesConsume = modulesCount * GameLogic.energyPerModule
        self.consumptionModules = modulesConsume
        deltaZ -= modulesConsume
        
        self.batteriesDelta = deltaZ
        
        // FIXME: - Adjust Air variables (Update)
        // Air
        let reqAir = station.calculateNeededAir()
        self.requiredAir = reqAir
        
        let theAir = myStation.air
        air = theAir
        
        // Tanks + Water
        self.tanks = myStation.truss.tanks
        let waterTanks:[Tank] = myStation.truss.tanks.filter({ $0.type == .h2o })
        
        self.liquidWater = waterTanks.map({ $0.current }).reduce(0, +)
        
        // Ingredients (Boxes)
        self.boxes = myStation.truss.extraBoxes
        
        // People
        self.inhabitants = myStation.habModules.map({ $0.inhabitants.count }).reduce(0, +) //myStation.people.count
        
        // Food
        let stationFood = station.food
        var totalFood = stationFood
        for bioModule in station.bioModules {
            for bioBox in bioModule.boxes.filter({ $0.mode == .multiply}) {
                totalFood.append(contentsOf: bioBox.population.filter({ bioBox.perfectDNA == $0 }))
            }
        }
        self.availableFood = totalFood
        
        // Accounting
        self.accountingReport = station.accounting
        
        // After initialized
        self.peripherals.append(myStation.truss.antenna)
        updateEnergyLevels()
        
    }
    
    func updateEnergyLevels() {
        
        var totalCapacity:Int = 0
        var accumEnergy:Int = 0
        
        for battery in batteries {
            accumEnergy += battery.current
            totalCapacity += battery.capacity
        }
        
        self.levelZ = Double(accumEnergy)
        self.levelZCap = Double(totalCapacity)
    }
    
    // Consume
    
    func consumeEnergy(amt:Int) -> Bool {
        for battery in batteries {
            if battery.consume(amt: amt) == true {
                updateEnergyLevels()
                return true
            }
        }
        return false
    }
    
    // MARK: - Peripheral Control
    
    /// To Use a `PeripheralObject` instantly
    func instantUse(peripheral:PeripheralObject) {
        
        // Peripherals that can be used (instantly)
        self.peripheralIssues = []
        self.peripheralMessages = []
        
        // 100 Energy
        let charge = station.truss.consumeEnergy(amount: 100)
        if charge {
            peripheralMessages.append("100 Energy was used.")
        } else {
            peripheralIssues.append("Not enough energy to use this peripheral.")
            return
        }
        
        switch peripheral.peripheral {
            
            case .ScrubberCO2:
                
                // 1. Scrubber          -3 CO2
                if station.air.co2 >= 4 {
                    station.air.co2 -= 4
                    peripheralMessages.append("4 CO2 removed from the air.")
                } else {
                    peripheralIssues.append("Scrubber needs at least 4 CO2 to work. Current: \(station.air.co2)")
                }
                
            case .Electrolizer:
                
                // 2. Electrolizer      -H2O + H + O
                let waterUse:Int = 10
                if let waterTank = station.truss.tanks.filter({ $0.type == .h2o }).sorted(by: { $0.current > $1.current }).first, waterTank.current >= waterUse {
                    waterTank.current -= waterUse
                    // 10 * h2o = 10 * h2 + 5 * o2
                    // Try to put into Hydrogen Tank
                    if let hydrogenTank = station.truss.tanks.filter({ $0.type == .h2 }).sorted(by: { $0.current < $1.current }).first {
                        hydrogenTank.current = min(hydrogenTank.capacity, hydrogenTank.current + waterUse)
                        peripheralMessages.append("Hydrogen Tank is now \(hydrogenTank.current)L.")
                    } else {
                        peripheralIssues.append("No Hydrogen tank to fill. Had to throw the Hydrogen away")
                    }
                    // Oxygen goes in the air
                    station.air.o2 += Int(waterUse / 2) // Half O2 from 10 * H2O
                } else {
                    peripheralIssues.append("No water tank was found. Electrolizer needds water to do electrolysis")
                }
                
            case .Methanizer:
                
                // 3. Methanizer        -CO2, -H2, +CH4, +O2
                if station.air.co2 > 10 {
                    // Get hydrogen (Needed)
                    let hydroUse:Int = 10
                    if let hydrogenTank = station.truss.tanks.filter({ $0.type == .h2 }).sorted(by: { $0.current > $1.current }).first, hydrogenTank.current >= hydroUse {
                        
                        // -CO2
                        station.air.co2 -= 10
                        peripheralMessages.append("10 CO2 removed from the air")
                        
                        hydrogenTank.current -= hydroUse
                        
                        // Methane Tank (Optional)
                        let methaneGive = 10
                        if let methaneTank = station.truss.tanks.filter({ $0.type == .ch4 }).sorted(by: { $0.current < $1.current }).first {
                            methaneTank.current = min(methaneTank.capacity, methaneTank.current + methaneGive)
                            peripheralMessages.append("Methane tank is now \(methaneTank.current)L")
                        } else {
                            peripheralIssues.append("No Methane tank (CH4) was found. Had to throw it away.")
                        }
                        
                        // O2 Tank (Optional)
                        let oxygenGive = 10
                        if let oxygenTank = station.truss.tanks.filter({ $0.type == .o2 }).sorted(by: { $0.current < $1.current }).first {
                            oxygenTank.current = min(oxygenTank.capacity, oxygenTank.current + oxygenGive)
                        } else {
                            peripheralIssues.append("No Oxygen tank (O2) was found. Had to throw it away.")
                        }
                        
                    } else {
                        peripheralIssues.append("No Hydrogen tank (H2) was found. Methanizer needs hydrogen to make methane.")
                    }
                } else {
                    peripheralIssues.append("CO2 in air is less than 10")
                }
                
            case .WaterFilter:
                
                // 4. WaterFilter       -wasteWater, + h2o
                let sewerUsage = 10
                if let sewer = station.truss.extraBoxes.filter({ $0.type == .wasteLiquid }).sorted(by: { $0.current > $1.current }).first, sewer.current >= sewerUsage {
                    
                    let multiplier = 0.5 + 0.1 * Double(peripheral.level) // 50% + 10% each level
                    let waterGain = Int(multiplier * Double(sewerUsage))
                    
                    if let waterTank = station.truss.tanks.filter({ $0.type == .h2o}).sorted(by: { $0.current < $1.current}).first {
                        waterTank.current = min((waterTank.current + waterGain), waterTank.capacity)
                        sewer.current -= sewerUsage
                        peripheralMessages.append("\(waterGain)L of water has been added to tank, thats now \(waterTank.current)L.")
                        return
                    } else {
                        peripheralIssues.append("No water tank (H2O) was found. Had to throw the water away.")
                    }

                } else {
                    peripheralIssues.append("Not enough waste water to complete this operation.")
                }
                
            case .BioSolidifier:
                
                // 5. BioSolidifier     -wasteSolid, + Fertilizer
                let sewerUsage = 10
                if let sewer = station.truss.extraBoxes.filter({ $0.type == .wasteSolid }).sorted(by: { $0.current > $1.current }).first, sewer.current >= sewerUsage {
                    
                    let multiplier = 0.5 + 0.1 * Double(peripheral.level) // 50% + 10% each level
                    let fertilizerGain = Int(multiplier * Double(sewerUsage))
                    
                    if let fertBox = station.truss.extraBoxes.filter({ $0.type == .Fertilizer }).sorted(by: { $0.current < $1.current }).first {
                        fertBox.current = min(fertBox.capacity, fertBox.current + fertilizerGain)
                    } else {
                        peripheralIssues.append("Could not find a Fertilizer storage box to store the fertilizer produced. Throwing it away.")
                    }
                } else {
                    peripheralIssues.append("Not enough solid waste to complete this operation.")
                }
                
            default:
                print("Error. Another Peripheral has instant use? \(peripheral.peripheral.rawValue) id:\(peripheral.id)")
        }
    }
    
    /// Powering a Peripheral On/Off
    func powerToggle(peripheral:PeripheralObject) {
        print("Toggling Power on peripheral: \(peripheral.peripheral.rawValue)")
        peripheral.powerOn.toggle()
        saveStation()
    }
    
    /// Fix a Peripheral Object
    func fixBroken(peripheral:PeripheralObject) {
        peripheral.isBroken.toggle()
        peripheral.lastFixed = Date()
        saveStation()
        self.didSelect(utility: peripheral)
        
    }
    
    // MARK: - Tanks and Boxes Control
    
    /// Throw away tank
    func discardTank(_ tank:Tank) {
        self.station.truss.tanks.removeAll(where: { $0.id == tank.id })
        self.tanks.removeAll(where: { $0.id == tank.id })
        self.viewState = .Resources(type: .None)
    }
    
    /// Merges same `TankType`
    func mergeTanks(_ origin:Tank) {
        print("Merging Tanks")
        
        // Merge tanks here
        let candidates = station.truss.tanks.filter({ $0.type == origin.type && $0.id != origin.id }).sorted(by: { $0.current < $1.current })
        
        var amountToFill = origin.availabilityToFill()
        for tank in candidates {
            if amountToFill <= 0 { break }
            if tank.current <= amountToFill {
                print("Merging tank: \(tank.id) into tank:\(origin.id)")
                amountToFill -= tank.current
                origin.current += tank.current
                tank.current = 0
            } else {
                print("no merge")
            }
        }
        print("Tank Done Merging. Now:\(origin.current) of \(origin.capacity)")
    }
    
    /// Defines a `TankType` for the tank
    func defineType(_ tank:Tank, type:TankType) {
        
        if let tankIndex = station.truss.tanks.firstIndex(of: tank) {
            
            let theTank = station.truss.tanks[tankIndex]
            theTank.type = type
            theTank.current = 0
            theTank.capacity = type.capacity
            
            // Update Tanks
            self.tanks = station.truss.tanks
            self.viewState = .Resources(type: .Tank(object: theTank))
            
        } else {
            print("Error: Could not find")
        }
    }
    
    /// Makes the tank emtpy
    func emptyTank(_ tank:Tank) {
        if let actualTank = station.truss.tanks.first(where:{ $0.id == tank.id }) {
            actualTank.current = 0
            actualTank.type = .empty
            self.viewState = .Resources(type: .Tank(object: actualTank))
        } else {
            print("Error: Could not find tank to empty")
        }
    }
    
    func canReleaseInAir(tank:Tank, amt:Int) -> Bool {
        
        let releasableTankTypes:[TankType] = [.air, .co2, .o2, .n2, .h2o]
        if !releasableTankTypes.contains(tank.type) { return false }
        
        let totalAirNeeded = station.calculateNeededAir()
        let totalAirVolume = station.air.getVolume()
        
        // 120%?
        let ratio:Double = Double(totalAirVolume) / Double(totalAirNeeded)
        
        // Max air is 120% of air needed
        let maxRatio:Double = 1.2
        
        let maxNeededDouble:Int = Int((maxRatio * Double(totalAirNeeded)).rounded())
        if (totalAirVolume + amt) < maxNeededDouble {
            return true
        }
        
        print("There is too much air! Ratio: \(ratio.rounded())")
        
        return false
    }
    
    func doReleaseInAir(tank:Tank, amt:Int) {
        
        let type:TankType = tank.type
        
        guard let theTank = station.truss.tanks.filter({ $0.id == tank.id }).first else { return }
        theTank.current -= amt
        
        switch type {
            case .air: station.air.mergeWith(newAirAmount: amt)
            case .co2: station.air.co2 += amt
            case .o2: station.air.o2 += amt
            case .h2o: station.air.h2o += amt
            case .n2: station.air.n2 += amt
            default:break
        }
        
        // Air
        let reqAir = station.calculateNeededAir()
        self.requiredAir = reqAir
        
        let theAir = station.air
        air = theAir
//        airVolume = theAir.getVolume()
//        airPressure = Double(theAir.getVolume()) / Double((reqAir + 1)) * 100.0
        
//        self.levelO2 = (Double(theAir.o2) / Double(theAir.getVolume())) * 100
//        self.levelCO2 = (Double(theAir.co2) / Double(theAir.getVolume())) * 100
        
        self.viewState = .Resources(type: .Tank(object: tank))
    }
    
    func getPeripherals() -> [PeripheralObject] {
        return station.peripherals
    }
    
    // MARK: - Accounting
    
    /// Save Station
    func saveStation() {
        LocalDatabase.shared.saveStation(station: station)
    }
    
}

class CityLSSController: ObservableObject, LSSDelegate {
    
    // State
    @Published var viewState:LSSViewState = LSSViewState.Energy
    @Published var segment:LSSTab = .Power {
        didSet {
            print("Did set tab: \(segment.rawValue)")
            didSelect(segment: segment)
        }
    }
    
    @Published var air:AirComposition
    @Published var batteries:[Battery]                 // Batteries
    @Published var tanks:[Tank]                        // Tanks
    @Published var boxes:[StorageBox]
    @Published var peripherals:[PeripheralObject]
    
    @Published var inhabitants:Int                     // Count of
    
    // Air
    @Published var requiredAir:Int          // Sum  of modules' volume
    @Published var liquidWater:Int
    @Published var availableFood:[String]
    
    // Energy
    @Published var levelZ:Double
    @Published var levelZCap:Double
    @Published var solarPanels:[SolarPanel] = []
    @Published var batteriesDelta:Int       // How much energy gainin/losing
    
    /// Energy consumption of Peripherals
    @Published var consumptionPeripherals:Int
    /// Energy Consumption of Modules
    @Published var consumptionModules:Int
    /// Energy Produced
    @Published var energyProduction:Int
    
    // Accounting
    
    @Published var accountDate:Date
    @Published var accountingProblems:[String] = LocalDatabase.shared.accountingProblems
    @Published var accountingReport:AccountingReport?
    
    @Published var peripheralIssues:[String] = []
    @Published var peripheralMessages:[String] = []
    
    
    init() {
        
        // Force it now, but try to make it so that it doesn't have a fatal error?
        
        guard let myCity = LocalDatabase.shared.loadCity() else {
            fatalError("No station")
        }
        
        self.accountDate = myCity.accountingDate ?? Date()
        
        // Solar Panels
        self.solarPanels = myCity.solarPanels
        let totalCharge = myCity.solarPanels.map({ $0.maxCurrent() }).reduce(0, +)
        self.energyProduction = totalCharge
        
        // Batteries
        let batteryPack = myCity.batteries
        self.batteries = batteryPack
        let totalCurrent = batteryPack.map({ $0.current }).reduce(0, +)
        let totalCapacity = max(1, batteryPack.map({ $0.capacity }).reduce(0, +))
        
        self.levelZ = Double(totalCurrent)
        self.levelZCap = Double(totalCapacity)
        
//        if !batteryPack.isEmpty {
//            let totalCurrent = batteryPack.map({ $0.current }).reduce(0, +)
//            let totalCapacity = batteryPack.map({ $0.capacity }).reduce(0, +)
//
//            self.levelZ = Double(totalCurrent)
//            self.levelZCap = Double(totalCapacity)
//
//        }else{
//            // For tests purposes
//            let b1 = Battery(capacity: 1000, current: 800)
//            self.batteries = [b1]
//            self.levelZ = 800
//            self.levelZCap = 1000
//        }
        
        // Peripherals
        self.peripherals = myCity.peripherals.sorted(by: { $0.peripheral.rawValue.compare($1.peripheral.rawValue) == .orderedAscending })
        
        let workingPeripherals = myCity.peripherals.filter({ $0.isBroken == false && $0.powerOn == true })
        let energyFromPeripherals:Int = workingPeripherals.map({$0.peripheral.energyConsumption}).reduce(0, +)
        self.consumptionPeripherals = energyFromPeripherals
        
        // Account for energy change
        var deltaZ = totalCharge - energyFromPeripherals
        
        // Modules Consumption
        let modulesCount = 3
        
        let modulesConsume = modulesCount * GameLogic.energyPerModule
        self.consumptionModules = modulesConsume
        deltaZ -= modulesConsume
        
        self.batteriesDelta = deltaZ
        
        // Air
        let reqAir = myCity.checkRequiredAir()
        self.requiredAir = reqAir
        
        //        let theAir = myCity.air
        self.air = myCity.air
        
        // Tanks + Water
        self.tanks = myCity.tanks.sorted(by: { $0.type.rawValue.compare($1.type.rawValue) == .orderedAscending })
        let waterTanks:[Tank] = myCity.tanks.filter({ $0.type == .h2o })
        self.liquidWater = waterTanks.map({ $0.current }).reduce(0, +)
        
        // Ingredients (Boxes)
        self.boxes = myCity.boxes.sorted(by: { $0.type.rawValue.compare($1.type.rawValue) == .orderedAscending })
        
        // People
        self.inhabitants = myCity.inhabitants.count //myStation.people.count
        
        // Food
        let stationFood = myCity.food ?? []
        var totalFood = stationFood
        
        for bioBox in (myCity.bioBoxes ?? []).filter({ $0.mode == .multiply }) {
            totalFood.append(contentsOf: bioBox.population.filter({ bioBox.perfectDNA == $0 }))
        }
        
        self.availableFood = totalFood
        
        // Accounting
        self.accountingReport = myCity.accounting
        
        // After initialized
        updateEnergyLevels()
        
    }
    
    // MARK: - Selectors
    
    // Segment Selection
    func didSelect(segment:LSSTab) {
        switch segment {
            case .Air: self.viewState = .Air
            case .Resources: self.viewState = .Resources(type: .None)
            case .Machinery: self.viewState = .Machinery(object:nil)
            case .Power:self.viewState = .Energy
            case .System: self.viewState = .Systems
        }
    }
    
    // Resource Selection
    func didSelect(utility:Codable) {
        print("Did select Utility")
        if let peripheral = utility as? PeripheralObject {
            print("Peripheral")
            self.viewState = .Machinery(object:peripheral) //.Resources(type: .Peripheral(object: peripheral))
        } else if let tank = utility as? Tank {
            print("Tank")
            self.viewState = .Resources(type: .Tank(object: tank))
        } else if let box = utility as? StorageBox {
            print("Box")
            self.viewState = .Resources(type: .Box(object: box))
        }
    }
    
    // Updating
    
    func updateDisplayVars() {
        
        guard let city = LocalDatabase.shared.city else { return }
        
        // Solar Panels
        self.solarPanels = city.solarPanels
        let totalCharge = city.solarPanels.map({ $0.maxCurrent() }).reduce(0, +)
        self.energyProduction = totalCharge
        
        // Batteries
        let batteryPack = city.batteries
        self.batteries = batteryPack
        if !batteryPack.isEmpty {
            let totalCurrent = batteryPack.map({ $0.current }).reduce(0, +)
            let totalCapacity = batteryPack.map({ $0.capacity }).reduce(0, +)
            
            self.levelZ = Double(totalCurrent)
            self.levelZCap = Double(totalCapacity)
        }
        
        // Peripherals
        self.peripherals = city.peripherals
        let workingPeripherals = city.peripherals.filter({ $0.isBroken == false && $0.powerOn == true })
        let energyFromPeripherals:Int = workingPeripherals.map({$0.peripheral.energyConsumption}).reduce(0, +)
        self.consumptionPeripherals = energyFromPeripherals
        
        // Account for energy change
        var deltaZ = totalCharge - energyFromPeripherals
        
        // Modules Consumption
        let modulesCount = 3
        
        // FIXME: - Module Consumption (Update)
        let modulesConsume = modulesCount * GameLogic.energyPerModule
        self.consumptionModules = modulesConsume
        deltaZ -= modulesConsume
        
        self.batteriesDelta = deltaZ
        
        // FIXME: - Adjust Air variables (Update)
        // Air
        let reqAir = city.checkRequiredAir()
        self.requiredAir = reqAir
        
        let theAir = city.air
        air = theAir
        
        // Tanks + Water
        self.tanks = city.tanks
        let waterTanks:[Tank] = city.tanks.filter({ $0.type == .h2o })
        
        self.liquidWater = waterTanks.map({ $0.current }).reduce(0, +)
        
        // Ingredients (Boxes)
        self.boxes = city.boxes
        
        // People
        self.inhabitants = city.inhabitants.count //myStation.people.count
        
        // Food
        let stationFood = city.food
        var totalFood:[String] = stationFood ?? []
        
        for bioBox in (city.bioBoxes ?? []).filter({ $0.mode == .multiply}) {
            totalFood.append(contentsOf: bioBox.population.filter({ bioBox.perfectDNA == $0 }))
        }
        
        self.availableFood = totalFood
        
        // Accounting
        self.accountingReport = city.accounting
        
        // After initialized
        updateEnergyLevels()
    }
    
    func updateEnergyLevels() {
        
        var totalCapacity:Int = 0
        var accumEnergy:Int = 0
        
        for battery in batteries {
            accumEnergy += battery.current
            totalCapacity += battery.capacity
        }
        
        self.levelZ = Double(accumEnergy)
        self.levelZCap = Double(totalCapacity)
    }
    
    // Consume
    
    func consumeEnergy(amt:Int) -> Bool {
        for battery in batteries {
            if battery.consume(amt: amt) == true {
                updateEnergyLevels()
                return true
            }
        }
        return false
    }
    
    // MARK: - Tanks and Boxes Control
    
    /// Throw away tank
    func discardTank(_ tank:Tank) {
        //        tanks.removeAll(where: { $0.id == tank.id })
        self.tanks.removeAll(where: { $0.id == tank.id })
        self.viewState = .Resources(type: .None)
    }
    
    /// Merges same `TankType`
    func mergeTanks(_ origin:Tank) {
        print("Merging Tanks")
        
        // Merge tanks here
        let candidates = tanks.filter({ $0.type == origin.type && $0.id != origin.id }).sorted(by: { $0.current < $1.current })
        
        var amountToFill = origin.availabilityToFill()
        for tank in candidates {
            if amountToFill <= 0 { break }
            if tank.current <= amountToFill {
                print("Merging tank: \(tank.id) into tank:\(origin.id)")
                amountToFill -= tank.current
                origin.current += tank.current
                tank.current = 0
            } else {
                print("no merge")
            }
        }
        print("Tank Done Merging. Now:\(origin.current) of \(origin.capacity)")
    }
    
    /// Defines a `TankType` for the tank
    func defineType(_ tank:Tank, type:TankType) {
        
        if let tankIndex = tanks.firstIndex(of: tank) {
            
            let theTank = tanks[tankIndex]
            theTank.type = type
            theTank.current = 0
            theTank.capacity = type.capacity
            
            // Update Tanks
            //            self.tanks = station.truss.tanks
            self.viewState = .Resources(type: .Tank(object: theTank))
            
        } else {
            print("Error: Could not find")
        }
    }
    
    /// Makes the tank emtpy
    func emptyTank(_ tank:Tank) {
        if let actualTank = tanks.first(where:{ $0.id == tank.id }) {
            actualTank.current = 0
            actualTank.type = .empty
            self.viewState = .Resources(type: .Tank(object: actualTank))
        } else {
            print("Error: Could not find tank to empty")
        }
    }
    
    func canReleaseInAir(tank:Tank, amt:Int) -> Bool {
        
        guard let city = LocalDatabase.shared.city else { return false }
        
        let releasableTankTypes:[TankType] = [.air, .co2, .o2, .n2, .h2o]
        if !releasableTankTypes.contains(tank.type) { return false }
        
        let totalAirNeeded = city.checkRequiredAir()
        let totalAirVolume = city.air.getVolume()
        
        // 120%?
        let ratio:Double = Double(totalAirVolume) / Double(totalAirNeeded)
        
        // Max air is 120% of air needed
        let maxRatio:Double = 1.2
        
        let maxNeededDouble:Int = Int((maxRatio * Double(totalAirNeeded)).rounded())
        if (totalAirVolume + amt) < maxNeededDouble {
            return true
        }
        
        print("There is too much air! Ratio: \(ratio.rounded())")
        
        return false
    }
    
    func doReleaseInAir(tank:Tank, amt:Int) {
        
        guard let city = LocalDatabase.shared.city else { return }
        
        let type:TankType = tank.type
        
        guard let theTank = tanks.filter({ $0.id == tank.id }).first else { return }
        theTank.current -= amt
        
        switch type {
            case .air: city.air.mergeWith(newAirAmount: amt)
            case .co2: city.air.co2 += amt
            case .o2: city.air.o2 += amt
            case .h2o: city.air.h2o += amt
            case .n2: city.air.n2 += amt
            default:break
        }
        
        // Air
        let reqAir = city.checkRequiredAir()
        self.requiredAir = reqAir
        
        let theAir = city.air
        air = theAir
        
        self.viewState = .Resources(type: .Tank(object: tank))
    }
    
    // MARK: - Peripheral Control
    
    /// To Use a `PeripheralObject` instantly
    func instantUse(peripheral:PeripheralObject) {
        
        guard let city = LocalDatabase.shared.loadCity() else { return }
        
        // Peripherals that can be used (instantly)
        self.peripheralIssues = []
        self.peripheralMessages = []
        
        // 100 Energy
        let charge = city.consumeEnergyFromBatteries(amount: 100)
        if charge {
            peripheralMessages.append("100 Energy was used.")
        } else {
            peripheralIssues.append("Not enough energy to use this peripheral.")
            return
        }
        
        switch peripheral.peripheral {
            
            case .ScrubberCO2:
                
                // 1. Scrubber          -3 CO2
                if city.air.co2 >= 4 {
                    city.air.co2 -= 4
                    peripheralMessages.append("4 CO2 removed from the air.")
                } else {
                    peripheralIssues.append("Scrubber needs at least 4 CO2 to work. Current: \(city.air.co2)")
                }
                
            case .Electrolizer:
                
                // 2. Electrolizer      -H2O + H + O
                let waterUse:Int = 10
                if let waterTank = city.tanks.filter({ $0.type == .h2o }).sorted(by: { $0.current > $1.current }).first, waterTank.current >= waterUse {
                    waterTank.current -= waterUse
                    // 10 * h2o = 10 * h2 + 5 * o2
                    // Try to put into Hydrogen Tank
                    if let hydrogenTank = city.tanks.filter({ $0.type == .h2 }).sorted(by: { $0.current < $1.current }).first {
                        hydrogenTank.current = min(hydrogenTank.capacity, hydrogenTank.current + waterUse)
                        peripheralMessages.append("Hydrogen Tank is now \(hydrogenTank.current)L.")
                    } else {
                        peripheralIssues.append("No Hydrogen tank to fill. Had to throw the Hydrogen away")
                    }
                    // Oxygen goes in the air
                    city.air.o2 += Int(waterUse / 2) // Half O2 from 10 * H2O
                } else {
                    peripheralIssues.append("No water tank was found. Electrolizer needds water to do electrolysis")
                }
                
            case .Methanizer:
                
                // 3. Methanizer        -CO2, -H2, +CH4, +O2
                if city.air.co2 > 10 {
                    // Get hydrogen (Needed)
                    let hydroUse:Int = 10
                    if let hydrogenTank = city.tanks.filter({ $0.type == .h2 }).sorted(by: { $0.current > $1.current }).first, hydrogenTank.current >= hydroUse {
                        
                        // -CO2
                        city.air.co2 -= 10
                        peripheralMessages.append("10 CO2 removed from the air")
                        
                        hydrogenTank.current -= hydroUse
                        
                        // Methane Tank (Optional)
                        let methaneGive = 10
                        if let methaneTank = city.tanks.filter({ $0.type == .ch4 }).sorted(by: { $0.current < $1.current }).first {
                            methaneTank.current = min(methaneTank.capacity, methaneTank.current + methaneGive)
                            peripheralMessages.append("Methane tank is now \(methaneTank.current)L")
                        } else {
                            peripheralIssues.append("No Methane tank (CH4) was found. Had to throw it away.")
                        }
                        
                        // O2 Tank (Optional)
                        let oxygenGive = 10
                        if let oxygenTank = city.tanks.filter({ $0.type == .o2 }).sorted(by: { $0.current < $1.current }).first {
                            oxygenTank.current = min(oxygenTank.capacity, oxygenTank.current + oxygenGive)
                        } else {
                            peripheralIssues.append("No Oxygen tank (O2) was found. Had to throw it away.")
                        }
                        
                    } else {
                        peripheralIssues.append("No Hydrogen tank (H2) was found. Methanizer needs hydrogen to make methane.")
                    }
                } else {
                    peripheralIssues.append("CO2 in air is less than 10")
                }
                
            case .WaterFilter:
                
                // 4. WaterFilter       -wasteWater, + h2o
                let sewerUsage = 10
                if let sewer = city.boxes.filter({ $0.type == .wasteLiquid }).sorted(by: { $0.current > $1.current }).first, sewer.current >= sewerUsage {
                    
                    let multiplier = 0.5 + 0.1 * Double(peripheral.level) // 50% + 10% each level
                    let waterGain = Int(multiplier * Double(sewerUsage))
                    
                    if let waterTank = city.tanks.filter({ $0.type == .h2o}).sorted(by: { $0.current < $1.current}).first {
                        waterTank.current = min((waterTank.current + waterGain), waterTank.capacity)
                        sewer.current -= sewerUsage
                        peripheralMessages.append("\(waterGain)L of water has been added to tank, thats now \(waterTank.current)L.")
                        return
                    } else {
                        peripheralIssues.append("No water tank (H2O) was found. Had to throw the water away.")
                    }
                    
                } else {
                    peripheralIssues.append("Not enough waste water to complete this operation.")
                }
                
            case .BioSolidifier:
                
                // 5. BioSolidifier     -wasteSolid, + Fertilizer
                let sewerUsage = 10
                if let sewer = city.boxes.filter({ $0.type == .wasteSolid }).sorted(by: { $0.current > $1.current }).first, sewer.current >= sewerUsage {
                    
                    let multiplier = 0.5 + 0.1 * Double(peripheral.level) // 50% + 10% each level
                    let fertilizerGain = Int(multiplier * Double(sewerUsage))
                    
                    if let fertBox = city.boxes.filter({ $0.type == .Fertilizer }).sorted(by: { $0.current < $1.current }).first {
                        fertBox.current = min(fertBox.capacity, fertBox.current + fertilizerGain)
                    } else {
                        peripheralIssues.append("Could not find a Fertilizer storage box to store the fertilizer produced. Throwing it away.")
                    }
                } else {
                    peripheralIssues.append("Not enough solid waste to complete this operation.")
                }
                
            default:
                print("Error. Another Peripheral has instant use? \(peripheral.peripheral.rawValue) id:\(peripheral.id)")
        }
    }
    
    /// Powering a Peripheral On/Off
    func powerToggle(peripheral:PeripheralObject) {
        print("Toggling Power on peripheral: \(peripheral.peripheral.rawValue)")
        peripheral.powerOn.toggle()
        //        saveStation()
    }
    
    /// Fix a Peripheral Object
    func fixBroken(peripheral:PeripheralObject) {
        peripheral.isBroken.toggle()
        peripheral.lastFixed = Date()
        //        saveStation()
        self.didSelect(utility: peripheral)
        
    }
    
    func getPeripherals() -> [PeripheralObject] {
        return LocalDatabase.shared.loadCity()?.peripherals ?? []
    }
    
    /// Save Station
    func saveCity() {
        guard let city = LocalDatabase.shared.city else { return }
        city.boxes = self.boxes
        city.tanks = self.tanks
        city.air = self.air
        city.peripherals = self.peripherals
        do {
            try LocalDatabase.shared.saveCity(city)
        } catch {
            print("Error! Could not save city")
        }
    }
    
}
