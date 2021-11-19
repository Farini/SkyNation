//
//  LifeSupportSystems.swift
//  SkyTestSceneKit
//
//  Created by Farini on 8/29/20.
//  Copyright © 2020 Farini. All rights reserved.
//

import Foundation

/// A Tab for selection of the LSSView themes
enum LSSTab:String, CaseIterable {
    case Air
    case Resources
    case Machinery
    case Power
    case System
    
    var emoji:String {
        switch self {
            case .Air: return "☁️"
            case .Resources: return "♲"
            case .Machinery: return "⚙️"
            case .Power: return "🔋" // ⚡️
            case .System: return "📈"
        }
    }
    
    var beginState:LSSControlState {
        switch self {
            case .Air: return .Air
            case .Resources: return .Resources(type: .None)
            case .Machinery: return .Machinery(type: .None)
            case .Power: return .Energy
            case .System: return .Systems
        }
    }
}

/// The State (selection) of the LSSView
enum LSSControlState {
    case Air
    case Resources(type:BoxTankSelectType)
    case Machinery(type:MachineSelectType)
    case Energy
    case Systems
    
    var tab:LSSTab {
        switch self {
            case .Air: return .Air
            case .Resources(_): return .Resources
            case .Machinery(_): return .Machinery
            case .Energy: return .Power
            case .Systems: return .System
        }
    }
}

/// Selection State for the LSSView - Resources
enum BoxTankSelectType {
    case None
    case Box(box:StorageBox)
    case Tank(tank:Tank)
}

/// Selection State for the LSSView - Peripherals
enum MachineSelectType {
    case None
    case Machine(peripheral:PeripheralObject)
    
    func isSelected(peripheral:PeripheralObject) -> Bool {
        switch self {
            case .Machine(let oPeri):
                return oPeri.id == peripheral.id
            default:
                return false
        }
    }
}

// New
enum TankSorting {
    case byEmptiness
    case byType
}

/**
 Life Support Systems Controller
 
 This controller is used both for objects `Station` and `CityData`. It has various statistics about those objects, as well as some data related to what the object is going to be like, in the near future
 */
class LSSController: ObservableObject {
    
    var gameScene:GameSceneType
    var station:Station?
    var city:CityData?
    
    // State
    @Published var viewState:LSSControlState = LSSControlState.Air
    @Published var selectedTab:LSSTab = LSSTab.Air
    
    // Resources
    @Published var air:AirComposition
    @Published var batteries:[Battery] = []
    @Published var boxes:[StorageBox] = []
    @Published var peripherals:[PeripheralObject] = []
    @Published var food:[String] = []
    
    @Published var tanks:[Tank] = []
    @Published var tankSorting:TankSorting = .byType
    
    @Published var headCount:Int = 0
    
    // Air
    @Published var requiredAir:Int = 1          // Sum  of modules' volume
    @Published var liquidWater:Int = 0
    
    // Energy
    @Published var zCurrentLevel:Int = 0            // Sum of batteries.current
    @Published var zCapLevel:Int = 1                // Sum of batteries.capacity
    @Published var zPanels:[SolarPanel] = []        // Energy Input?
    /// Energy consumption of Peripherals
    @Published var zConsumeMachine:Int = 0
    /// Energy Consumption of Modules (or Tech)
    @Published var zConsumeModules:Int = 0
    /// EnergyConsumption by Humans
    @Published var zConsumeHumans:Int = 0
    /// Energy Produced
    @Published var zProduction:Int = 0
    @Published var zDelta:Int = 0                   // How much energy gainin/losing
    
    // Accounting
    @Published var accountDate:Date = Date()
    @Published var accountingReport:AccountingReport?
    @Published var accountingProblems:[String] = []
    @Published var peripheralNotes:[String] = []
    
    // Waste Management
    @Published var wLiquidCapacity:Int = 0
    @Published var wLiquidCurrent:Int = 0
    @Published var wSolidCapacity:Int = 0
    @Published var wSolidCurrent:Int = 0
    
    // Peripheral Usage
    @Published var periUseIssues:[String] = []
    @Published var periUseMessages:[String] = []
    
    // MARK: - Methods
    
    func updateTabSelection(tab:LSSTab) {
        self.selectedTab = tab
        self.viewState = tab.beginState
    }
    
    func updateState(newState:LSSControlState) {
        self.selectedTab = newState.tab
        self.viewState = newState
        
        self.periUseIssues = []
        self.periUseMessages = []
    }
    
    func updateAllData() {
        switch self.gameScene {
            case .SpaceStation:
                guard let station = self.station else { fatalError() }
                self.updateStationData(station: station)
            case .MarsColony:
                guard let city = self.city else { fatalError() }
                self.updateCityData(city: city)
        }
    }
    
    // MARK: - Tank Management
    
    func mergeTanks(into tank:Tank) {
        print("Merging Tanks")
        
        // Merge tanks here
        let candidates = self.tanks.filter({ $0.type == tank.type && $0.id != tank.id }).sorted(by: { $0.current < $1.current })
        
        var amountToFill = tank.availabilityToFill()
        for oTank in candidates {
            if amountToFill <= 0 { break }
            if oTank.current <= amountToFill {
                print("Merging tank: \(oTank.id) into tank:\(tank.id)")
                amountToFill -= oTank.current
                tank.current += oTank.current
                oTank.current = 0
            } else {
                print("no merge")
            }
        }
        
        print("Tank Done Merging. Now:\(tank.current) of \(tank.capacity)")
        
        // Save
        switch gameScene {
            case .MarsColony:
                guard let city = city else { fatalError() }
                city.tanks = self.tanks
                // Save City
                self.saveCity(city: city)
            case .SpaceStation:
                guard let station = station else { fatalError() }
                station.truss.tanks = self.tanks
                // Save Station
                self.saveStation(station: station)
        }
        
        self.updateAllData()
    }
    
    func releaseToAir(tank:Tank, amt:Int) {
        
        let type:TankType = tank.type
        
        var backupTank:Tank?
        switch gameScene {
            case .MarsColony:
                guard let city = city else { fatalError() }
                backupTank = city.tanks.filter({ $0.id == tank.id }).first
            case .SpaceStation:
                guard let station = station else { fatalError() }
                backupTank = station.truss.tanks.filter({ $0.id == tank.id }).first
        }
        
        guard let theTank = backupTank else { return }
        theTank.current -= amt
        
        switch type {
            case .air: self.air.mergeWith(newAirAmount: amt) //station.air.mergeWith(newAirAmount: amt)
            case .co2: self.air.co2 += amt //station.air.co2 += amt
            case .o2: self.air.o2 += amt //station.air.o2 += amt
            case .h2o: self.air.h2o += amt //station.air.h2o += amt
            case .n2: self.air.n2 += amt //station.air.n2 += amt
            default:break
        }
        
        // Set empty
        if theTank.current == 0 {
            theTank.type = .empty
        }
        
        switch gameScene {
            case .MarsColony:
                guard let city = city else { fatalError() }
                // Save City
                self.saveCity(city: city)
            case .SpaceStation:
                guard let station = station else { fatalError() }
                // Save Station
                self.saveStation(station: station)
        }
        
        self.viewState = .Resources(type: .Tank(tank: theTank))
    }
    
    func canReleaseToAir(tank:Tank, amt:Int) -> Bool {
        let releasableTankTypes:[TankType] = [.air, .co2, .o2, .n2, .h2o]
        if !releasableTankTypes.contains(tank.type) { return false }
        
        let totalAirNeeded = self.requiredAir
        let totalAirVolume = self.air.getVolume()
        
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
    
    func reorderTanks() {
        switch tankSorting {
            case .byType:
                self.tankSorting = .byEmptiness
                self.updateAllData()
            case .byEmptiness:
                self.tankSorting = .byType
                self.updateAllData()
        }
    }
    
    /// Throw away tank
    func discardTank(tank:Tank) {
        
        self.tanks.removeAll(where: { $0.id == tank.id })
        
        switch gameScene {
            case .SpaceStation:
                guard let station = station else { fatalError() }
                station.truss.tanks.removeAll(where: { $0.id == tank.id })
                self.saveStation(station: station)
            case .MarsColony:
                guard let city = city else { fatalError() }
                city.tanks.removeAll(where: { $0.id == tank.id })
                self.saveCity(city: city)
        }
        
        self.viewState = .Resources(type: .None)
    }
    
    func defineTankType(tank:Tank, newType:TankType) {
        
        switch gameScene {
            case .SpaceStation:
                guard let station = station else { fatalError() }
                if let tankIndex = station.truss.tanks.firstIndex(of: tank) {
                    let theTank = station.truss.tanks[tankIndex]
                    theTank.type = newType
                    theTank.current = 0
                    theTank.capacity = newType.capacity
                    
                    self.tanks = station.truss.tanks
                    self.updateState(newState: .Resources(type: .Tank(tank: theTank)))
                    self.updateAllData()
                }
                
                self.saveStation(station: station)
                
            case .MarsColony:
                guard let city = city else { fatalError() }
                if let tankIndex = city.tanks.firstIndex(of: tank) {
                    let theTank = city.tanks[tankIndex]
                    theTank.type = newType
                    theTank.current = 0
                    theTank.capacity = newType.capacity
                    self.tanks = city.tanks
                    
                    self.updateState(newState: .Resources(type: .Tank(tank: theTank)))
                    self.updateAllData()
                }
                
                self.saveCity(city: city)
        }
    }
    
    // MARK: - Peripheral Management
    
    /// Uses a Peripheral
    func instantUse(peripheral:PeripheralObject) {
        
        // Peripherals that can be used (instantly)
        self.periUseIssues = []
        self.periUseMessages = []
        
        // Charge Energy
        var charge:Bool = false
        switch gameScene {
            case .SpaceStation:
                guard let station = station else { fatalError() }
                charge = station.truss.consumeEnergy(amount: 100)
            case .MarsColony:
                guard let city = city else { fatalError() }
                charge = city.consumeEnergyFromBatteries(amount: 100)
        }
        
        if charge == true {
            periUseMessages.append("100 Energy was used.")
        } else {
            periUseIssues.append("Not enough energy to use this peripheral.")
            return
        }
 
        switch gameScene {
            case .SpaceStation:
                guard let station = station else { fatalError() }
                
                switch peripheral.peripheral {
                    
                    case .ScrubberCO2:
                        if station.air.co2 < 4 {
                            periUseIssues.append("Scrubber needs at least 4 CO2 to work. Current: \(station.air.co2)")
                            return
                        } else {
                            station.air.co2 -= 4
                            periUseMessages.append("4 CO2 removed from the air.")
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
                                periUseMessages.append("Hydrogen Tank is now \(hydrogenTank.current)L.")
                            } else {
                                periUseIssues.append("No Hydrogen tank to fill. Had to throw the Hydrogen away")
                            }
                            // Oxygen goes in the air
                            station.air.o2 += Int(waterUse / 2) // Half O2 from 10 * H2O
                            
                        } else {
                            periUseIssues.append("No water tank was found. Electrolizer needds water to do electrolysis")
                            return
                        }
                        
                    case .Methanizer:
                        
                        // 3. Methanizer        -CO2, -H2, +CH4, +O2
                        if station.air.co2 > 10 {
                            // Get hydrogen (Needed)
                            let hydroUse:Int = 10
                            if let hydrogenTank = station.truss.tanks.filter({ $0.type == .h2 }).sorted(by: { $0.current > $1.current }).first, hydrogenTank.current >= hydroUse {
                                
                                // -CO2
                                station.air.co2 -= 10
                                periUseMessages.append("10 CO2 removed from the air")
                                
                                hydrogenTank.current -= hydroUse
                                
                                // Methane Tank (Optional)
                                let methaneGive = 10
                                if let methaneTank = station.truss.tanks.filter({ $0.type == .ch4 }).sorted(by: { $0.current < $1.current }).first {
                                    methaneTank.current = min(methaneTank.capacity, methaneTank.current + methaneGive)
                                    periUseMessages.append("Methane tank is now \(methaneTank.current)L")
                                } else {
                                    periUseIssues.append("No Methane tank (CH4) was found. Had to throw it away.")
                                }
                                
                                // O2 Tank (Optional)
                                let oxygenGive = 10
                                if let oxygenTank = station.truss.tanks.filter({ $0.type == .o2 }).sorted(by: { $0.current < $1.current }).first {
                                    oxygenTank.current = min(oxygenTank.capacity, oxygenTank.current + oxygenGive)
                                } else {
                                    periUseIssues.append("No Oxygen tank (O2) was found. Had to throw it away.")
                                }
                                
                            } else {
                                periUseIssues.append("No Hydrogen tank (H2) was found. Methanizer needs hydrogen to make methane.")
                                return
                            }
                        } else {
                            periUseIssues.append("CO2 in air is less than 10")
                            return
                        }
                    
                    case .WaterFilter:
                        
                        // 4. WaterFilter
                        let sewerUsage = 12
                        if let sewer = station.truss.extraBoxes.filter({ $0.type == .wasteLiquid }).sorted(by: { $0.current > $1.current }).first, sewer.current >= sewerUsage {
                            
                            let multiplier = 0.75 + 0.1 * Double(peripheral.level) // 50% + 10% each level
                            let waterGain = Int(multiplier * Double(sewerUsage))
                            
                            if let waterTank = station.truss.tanks.filter({ $0.type == .h2o}).sorted(by: { $0.current < $1.current}).first {
                                waterTank.current = min((waterTank.current + waterGain), waterTank.capacity)
                                sewer.current -= sewerUsage
                                periUseMessages.append("\(waterGain)L of water has been added to tank, which now has \(waterTank.current)L.")
                                return
                            } else {
                                periUseMessages.append("No water tank (H2O) was found. Had to throw the water away.")
                            }
                            
                        } else {
                            periUseIssues.append("Not enough waste water to complete this operation.")
                            return
                        }
                        
                    case .BioSolidifier:
                        
                        // 5. BioSolidifier     -wasteSolid, + Fertilizer
                        let sewerUsage = 12
                        if let sewer = station.truss.extraBoxes.filter({ $0.type == .wasteSolid }).sorted(by: { $0.current > $1.current }).first, sewer.current >= sewerUsage {
                            
                            // Reduce Sewage
                            sewer.current = max(0, sewer.current - sewerUsage)
                            
                            if Bool.random() == true {
                                // Make Fertilizer
                                let multiplier = 0.75 + 0.1 * Double(peripheral.level) // 60% + 10% each level
                                
                                if let fertBox = station.truss.extraBoxes.filter({ $0.type == .Fertilizer }).sorted(by: { $0.current < $1.current }).first {
                                    let fertilizerGain = Int(multiplier * Double(sewerUsage))
                                    fertBox.current = fertBox.current + fertilizerGain
                                    
                                    
                                    
                                    periUseMessages.append("Fertilizer box gained \(fertilizerGain)Kg.")
                                } else {
                                    periUseMessages.append("Could not find a Fertilizer storage box to store the fertilizer produced. Throwing it away.")
                                }
                            } else {
                                // Make Methane
                                let multiplier = 0.6 + 0.1 * Double(peripheral.level) // 60% + 10% each level
                                let methaneGain = Int(multiplier * Double(sewerUsage))
                                if let methaneTank = station.truss.tanks.filter({ $0.type == .ch4 }).sorted(by: { $0.current < $1.current }).first {
                                    methaneTank.current = min(TankType.ch4.capacity, methaneTank.current + methaneGain)
                                    periUseMessages.append("Methande Tank gained \(methaneGain)L. Now has \(methaneTank.current)L.")
                                    
                                }
                            }
                            
                        } else {
                            periUseIssues.append("Not enough solid waste to complete this operation.")
                            return
                        }
                        
                    default:
                        print("Error. Another Peripheral has instant use? \(peripheral.peripheral.rawValue) id:\(peripheral.id)")
                        return
                    
                }
                
                self.saveStation(station: station)
                
                
            case .MarsColony:
                guard let city = city else { fatalError() }
                
                switch peripheral.peripheral {
                    case .ScrubberCO2:
                        if city.air.co2 < 4 {
                            periUseIssues.append("Scrubber needs at least 4 CO2 to work. Current: \(city.air.co2)")
                            return
                        } else {
                            city.air.co2 -= 4
                            periUseMessages.append("4 CO2 removed from the air.")
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
                                periUseMessages.append("Hydrogen Tank is now \(hydrogenTank.current)L.")
                            } else {
                                periUseMessages.append("No Hydrogen tank to fill. Had to throw the Hydrogen away")
                            }
                            // Oxygen goes in the air
                            city.air.o2 += Int(waterUse / 2) // Half O2 from 10 * H2O
                        } else {
                            periUseIssues.append("No water tank was found. Electrolizer needds water to do electrolysis")
                            return
                        }
                        
                    case .Methanizer:
                        // 3. Methanizer        -CO2, -H2, +CH4, +O2
                        if city.air.co2 > 10 {
                            // Get hydrogen (Needed)
                            let hydroUse:Int = 10
                            if let hydrogenTank = city.tanks.filter({ $0.type == .h2 }).sorted(by: { $0.current > $1.current }).first, hydrogenTank.current >= hydroUse {
                                
                                // -CO2
                                city.air.co2 -= 10
                                periUseMessages.append("10 CO2 removed from the air")
                                
                                hydrogenTank.current -= hydroUse
                                
                                // Methane Tank (Optional)
                                let methaneGive = 10
                                if let methaneTank = city.tanks.filter({ $0.type == .ch4 }).sorted(by: { $0.current < $1.current }).first {
                                    methaneTank.current = min(methaneTank.capacity, methaneTank.current + methaneGive)
                                    periUseMessages.append("Methane tank is now \(methaneTank.current)L")
                                } else {
                                    periUseMessages.append("No Methane tank (CH4) was found. Had to throw it away.")
                                }
                                
                                // O2 Tank (Optional)
                                let oxygenGive = 10
                                if let oxygenTank = city.tanks.filter({ $0.type == .o2 }).sorted(by: { $0.current < $1.current }).first {
                                    oxygenTank.current = min(oxygenTank.capacity, oxygenTank.current + oxygenGive)
                                } else {
                                    periUseMessages.append("No Oxygen tank (O2) was found. Had to throw it away.")
                                }
                                
                            } else {
                                periUseIssues.append("No Hydrogen tank (H2) was found. Methanizer needs hydrogen to make methane.")
                                return
                            }
                        } else {
                            periUseIssues.append("CO2 in air is less than needed by Methanizer (10) to complete this.")
                            return
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
                                periUseMessages.append("\(waterGain)L of water has been added to tank, thats now \(waterTank.current)L.")
                                return
                            } else {
                                periUseMessages.append("No water tank (H2O) was found. Had to throw the water away.")
                            }
                            
                        } else {
                            periUseIssues.append("Not enough waste water to complete this operation.")
                            return
                        }
                        
                    case .BioSolidifier:
                        
                        // 5. BioSolidifier     -wasteSolid, + Fertilizer
                        let sewerUsage = 10
                        if let sewer = city.boxes.filter({ $0.type == .wasteSolid }).sorted(by: { $0.current > $1.current }).first, sewer.current >= sewerUsage {
                            
                            let multiplier = 0.6 + 0.1 * Double(peripheral.level) // 60% + 10% each level
                            let methaneGain = Int(multiplier * Double(sewerUsage))
                            
                            sewer.current = max(0, sewer.current - sewerUsage)
                            
                            if Bool.random() == true {
                                // Make Fertilizer
                                let multiplier = 0.6 + 0.1 * Double(peripheral.level) // 60% + 10% each level
                                let fertilizerGain = Int(multiplier * Double(sewerUsage))
                                
                                if let fertBox = city.boxes.filter({ $0.type == .Fertilizer }).sorted(by: { $0.current < $1.current }).first {
                                    fertBox.current = fertBox.current + fertilizerGain
                                    periUseMessages.append("Fertilizer box gained \(fertilizerGain)Kg.")
                                } else {
                                    periUseMessages.append("Could not find a Fertilizer storage box to store the fertilizer produced. Throwing it away.")
                                }
                            } else {
                                // Make Methane
                                if let methaneTank = city.tanks.filter({ $0.type == .ch4 }).sorted(by: { $0.current < $1.current }).first {
                                    methaneTank.current = min(TankType.ch4.capacity, methaneTank.current + methaneGain)
                                    periUseMessages.append("Methande Tank gained \(methaneGain)L.")
                                }
                            }
                            
                        
                        } else {
                            periUseIssues.append("Not enough solid waste to complete this operation.")
                            return
                        }
                        
                    default:
                        print("Error. Another Peripheral has instant use? \(peripheral.peripheral.rawValue) id:\(peripheral.id)")
                }
                
                self.saveCity(city: city)
        }
       
        self.updateAllData()
        
    }
    
    /// Fixes a Peripheral
    func fixBroken(peripheral:PeripheralObject) {
        
        // Peripherals that can be used (instantly)
        self.periUseIssues = []
        self.periUseMessages = []
        
        switch gameScene {
            case .SpaceStation:
                
                guard let station = station else { fatalError() }
                if station.truss.consumeEnergy(amount: 10) == true {
                    peripheral.isBroken.toggle()
                    peripheral.lastFixed = Date()
                    
                    self.saveStation(station: station)
                } else {
                    self.periUseIssues.append("Not enough energy to fix \(peripheral.peripheral.rawValue)")
                }
                
            case .MarsColony:
                guard let city = city else { fatalError() }
                if city.consumeEnergyFromBatteries(amount: 10) == true {
                    peripheral.isBroken.toggle()
                    peripheral.lastFixed = Date()
                    
                    self.saveCity(city: city)
                } else {
                    self.periUseIssues.append("Not enough energy to fix \(peripheral.peripheral.rawValue)")
                }
        }
    }
    
    /// Powering a Peripheral On/Off
    func powerToggle(peripheral:PeripheralObject) {
        
        print("Toggling Power on peripheral: \(peripheral.peripheral.rawValue)")
        peripheral.powerOn.toggle()
        
        switch gameScene {
            case .SpaceStation:
                
                guard let station = station else { fatalError() }
                self.saveStation(station: station)
                
            case .MarsColony:
                guard let city = city else { fatalError() }
                self.saveCity(city: city)
        }
    }
    
    // MARK: - Saving
    
    func saveCity(city:CityData) {
        do {
            try LocalDatabase.shared.saveCity(city)
        } catch {
            print("⚠️ Something went wrong saving city !!!")
        }
    }
    
    func saveStation(station:Station) {
        // Save
        do {
            try LocalDatabase.shared.saveStation(station)
        } catch {
            print("‼️ Could not save station.: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Init and Updates
    
    init(scene:GameSceneType) {
        self.gameScene = scene
        switch scene {
            case .SpaceStation:
                let myStation = LocalDatabase.shared.station
                self.station = myStation
                self.air = myStation.air
                
                
            case .MarsColony:
                guard let myCity = LocalDatabase.shared.cityData else {
                    fatalError("No City")
                }
                self.city = myCity
                self.air = myCity.air
        }
        
        self.updateAllData()
    }
    
    /// Updates all the data to display (Mars City)
    private func updateCityData(city:CityData) {
        
        let tmpBatteries:[Battery] = city.batteries
        
        // Resources
        self.air = city.air
        self.batteries = tmpBatteries
        // self.tanks = city.tanks
        self.boxes = city.boxes
        self.peripherals = city.peripherals
        
        switch tankSorting {
            case .byEmptiness:
                self.tanks = city.tanks.sorted(by: { $0.current < $1.current })
            case .byType:
                self.tanks = city.tanks.sorted(by: { $0.type.rawValue < $1.type.rawValue })
        }
        
        // Headcount
        self.headCount = city.inhabitants.count
        
        // Food
        var totalFood = city.food
        for bioBox in city.bioBoxes.filter({ $0.mode == .multiply }) {
            totalFood.append(contentsOf: bioBox.population.filter({ bioBox.perfectDNA == $0 }))
        }
        self.food = totalFood
        
        // Tanks + Water
        self.tanks = city.tanks.sorted(by: { $0.type.rawValue.compare($1.type.rawValue) == .orderedAscending })
        let waterTanks:[Tank] = city.tanks.filter({ $0.type == .h2o })
        self.liquidWater = waterTanks.map({ $0.current }).reduce(0, +)
        
        // Accountability
        let reqAir = city.checkRequiredAir()
        self.requiredAir = reqAir
        
        // Z: Energy
        let battSumCurrent:Int = tmpBatteries.compactMap({ $0.current }).reduce(0, +)
        let battSumCap:Int = tmpBatteries.compactMap({ $0.capacity }).reduce(0, +)
        self.zCurrentLevel = battSumCurrent
        self.zCapLevel = battSumCap
        self.zPanels = city.solarPanels
        // Consumption
        let modulesCount = city.tech.count
        let modulesConsume = modulesCount * GameLogic.energyPerModule
        // Peripherals Consumption
        let consumptions:Int = peripherals.filter({$0.powerOn == true}).compactMap({ $0.peripheral.energyConsumption }).reduce(0, +)
        self.zConsumeMachine = consumptions
        self.zConsumeModules = modulesConsume
        self.zConsumeHumans = Array(repeating: GameLogic.personalEnergyConsumption(), count: headCount).reduce(0, +)
        
        // Energy Collection
        var energyCollection:Int = 5
        let mb = max(energyCollection, ServerManager.shared.serverData?.outposts.filter({ $0.type == .Energy }).compactMap({ $0.type.energyDelta }).reduce(0, +) ?? 0)
        energyCollection = mb
        
        self.zProduction = city.powerGeneration() + energyCollection
        let totalConsume = zConsumeModules + zConsumeMachine + zConsumeHumans
        self.zDelta = self.zProduction - totalConsume
        
        // Accounting
        self.accountDate = city.accountingDate ?? Date()
        self.accountingReport = city.accounting
        self.accountingProblems = city.accounting?.problems ?? []
        self.peripheralNotes = city.accounting?.peripheralNotes ?? []
        
        // Waste Management
        let liquidWasteBoxes = city.boxes.filter({ $0.type == .wasteLiquid })
        self.wLiquidCapacity = liquidWasteBoxes.compactMap({ $0.capacity }).reduce(0, +)
        self.wLiquidCurrent = liquidWasteBoxes.compactMap({ $0.current }).reduce(0, +)
        
        let solidWasteBoxes = city.boxes.filter({ $0.type == .wasteSolid })
        self.wSolidCapacity = solidWasteBoxes.compactMap({ $0.capacity }).reduce(0, +)
        self.wSolidCurrent = solidWasteBoxes.compactMap({ $0.current }).reduce(0, +)
    }
    
    /// Updates all the data to  display (Station)
    private func updateStationData(station:Station) {
        
        let tmpBatteries:[Battery] = station.truss.batteries
        
        // Resources
        self.air = station.air
        self.batteries = tmpBatteries
        self.boxes = station.truss.extraBoxes
        self.peripherals = station.peripherals
        
        switch tankSorting {
            case .byEmptiness:
                self.tanks = station.truss.tanks.sorted(by: { $0.current < $1.current })
            case .byType:
                self.tanks = station.truss.tanks.sorted(by: { $0.type.rawValue < $1.type.rawValue })
        }
        
        
        // Headcount
        self.headCount = station.habModules.map({ $0.inhabitants.count }).reduce(0, +)
        
        // Food
        var totalFood = station.food
        for bioModule in station.bioModules {
            for bioBox in bioModule.boxes.filter({ $0.mode == .multiply }) {
                totalFood.append(contentsOf: bioBox.population.filter({ bioBox.perfectDNA == $0 }))
            }
        }
        self.food = totalFood
        
        // Tanks + Water
        self.tanks = station.truss.tanks.sorted(by: { $0.type.rawValue.compare($1.type.rawValue) == .orderedAscending })
        let waterTanks:[Tank] = station.truss.tanks.filter({ $0.type == .h2o })
        self.liquidWater = waterTanks.map({ $0.current }).reduce(0, +)
        
        // Accountability
        let reqAir = station.calculateNeededAir()
        self.requiredAir = reqAir
        
        // Z: Energy
        let battSumCurrent:Int = tmpBatteries.compactMap({ $0.current }).reduce(0, +)
        let battSumCap:Int = tmpBatteries.compactMap({ $0.capacity }).reduce(0, +)
        self.zCurrentLevel = battSumCurrent
        self.zCapLevel = battSumCap
        self.zPanels = station.truss.solarPanels
        // Consumption
        let modulesCount = station.labModules.count + station.habModules.count + station.bioModules.count
        let modulesConsume = modulesCount * GameLogic.energyPerModule
        self.zConsumeModules = modulesConsume
        // Peripherals Consumption
        let consumptions:Int = peripherals.filter({ $0.powerOn == true}).compactMap({ $0.peripheral.energyConsumption }).reduce(0, +)
        self.zConsumeMachine = consumptions
        self.zConsumeHumans = Array(repeating: GameLogic.personalEnergyConsumption(), count: headCount).reduce(0, +)
        self.zProduction = station.truss.solarPanels.compactMap({ $0.maxCurrent() }).reduce(0, +)
        let totalConsume = zConsumeModules + zConsumeMachine + zConsumeHumans
        self.zDelta = self.zProduction - totalConsume
        
        // Accounting
        self.accountDate = station.accountingDate
        self.accountingReport = station.accounting
        self.accountingProblems = station.accounting?.problems ?? []
        self.peripheralNotes = station.accounting?.peripheralNotes ?? []

        // Waste Management
        let liquidWasteBoxes = station.truss.extraBoxes.filter({ $0.type == .wasteLiquid })
        self.wLiquidCapacity = liquidWasteBoxes.compactMap({ $0.capacity }).reduce(0, +)
        self.wLiquidCurrent = liquidWasteBoxes.compactMap({ $0.current }).reduce(0, +)
        
        let solidWasteBoxes = station.truss.extraBoxes.filter({ $0.type == .wasteSolid })
        self.wSolidCapacity = solidWasteBoxes.compactMap({ $0.capacity }).reduce(0, +)
        self.wSolidCurrent = solidWasteBoxes.compactMap({ $0.current }).reduce(0, +)
        
    }
}
