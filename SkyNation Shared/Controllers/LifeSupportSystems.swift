//
//  LifeSupportSystems.swift
//  SkyTestSceneKit
//
//  Created by Farini on 8/29/20.
//  Copyright © 2020 Farini. All rights reserved.
//

import Foundation

class LSSModel:ObservableObject {
    
    var station:Station
    
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
    @Published var airVolume:Int            // Air Volume
    @Published var airPressure:Double       // volume / required air
    
    @Published var levelO2:Double
    @Published var levelCO2:Double
    
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
        airVolume = theAir.getVolume()
        airPressure = Double(theAir.getVolume()) / Double((reqAir + 1)) * 100.0
        
        self.levelO2 = (Double(theAir.o2) / Double(theAir.getVolume())) * 100
        self.levelCO2 = (Double(theAir.co2) / Double(theAir.getVolume())) * 100
        
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
        airVolume = theAir.getVolume()
        airPressure = Double(theAir.getVolume()) / Double((reqAir + 1)) * 100.0
        
        self.levelO2 = (Double(theAir.o2) / Double(theAir.getVolume())) * 100
        self.levelCO2 = (Double(theAir.co2) / Double(theAir.getVolume())) * 100
        
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
    
    func consumeEnergy(amt:Int) -> Bool {
        for battery in batteries {
            if battery.consume(amt: amt) == true {
                updateEnergyLevels()
                return true
            }
        }
        return false
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
    
    func recharge() {
        print("Recharge is being deprecated")
//        for item in station.truss.solarPanels {
//            bloop: for battery in batteries {
//                if battery.charge() == true {
//                    print("Charged from max current \(item.maxCurrent())")
//                    break bloop
//                }
//            }
//        }
    }
    
    // MARK: - Peripheral Control
    
    /// Powering a Peripheral On/Off
    func powerToggle(peripheral:PeripheralObject) {
        print("Toggling Power on peripheral: \(peripheral.peripheral.rawValue)")
        peripheral.powerOn.toggle()
    }
    
    /// Fix a Peripheral Object
    func fixBroken(peripheral:PeripheralObject) {
        peripheral.isBroken.toggle()
        peripheral.lastFixed = Date()
        saveAccounting()
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
    
    // MARK: - Accounting
    
    /// Runs the accounting (don't save)
    func runAccounting() {
        print("Going to run accounting...")
        station.runAccounting()
        updateDisplayVars()
        accountingProblems = LocalDatabase.shared.accountingProblems
//        accountingReport = station.accounting
    }
    
    /// Save Station
    func saveAccounting() {
        LocalDatabase.shared.saveStation(station: station)
    }
    
    
    deinit {
//        timer.invalidate()
    }
}
