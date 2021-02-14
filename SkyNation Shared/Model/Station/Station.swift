//
//  Station.swift
//  SkyTestSceneKit
//
//  Created by Farini on 9/13/20.
//  Copyright © 2020 Farini. All rights reserved.
//

import Foundation

class Station:Codable {
    
    var modules:[Module]
    var labModules:[LabModule]
    var habModules:[HabModule]
    var bioModules:[BioModule]
    
    var air:AirComposition
    var peripherals:[PeripheralObject]
    
    var truss:Truss
    var accounting:AccountingReport?
    
    // Recipes that can be made
    var unlockedRecipes:[Recipe]
    var labActivities:[LabActivity]?
    
    var earthOrder:PayloadOrder?
    
    var accountingDate:Date
    
    var unlockedTechItems:[TechItems]
    
    var food:[String]
    
    var garage:Garage
    
    // MARK: - Accounting
    
    /// Set overtime to 'true' if you want to force the accounting past the current Date
    func runAccounting(overtime:Bool = false) {
        
        // 1. Date
        // 1.A Get the date
        // 1.B Get hours and time constraints
        
        let formatter = GameFormatters.fullDateFormatter
        
        var lastDate = accountingDate
        
        print("\n 🌎 [STATION ACCOUNTING] \n------")
        print("Last Accounting Date: \(formatter.string(from: lastDate))")
        
        var m = Calendar.current.dateComponents([.year, .month, .weekOfYear, .weekday, .day, .hour, .minute], from: lastDate)
        m.setValue(0, for: .minute)
        m.setValue(0, for: .second)
        m.setValue(0, for: .nanosecond)
        
        lastDate = Calendar.current.date(from: m) ?? Date()
        print("Last date (rounded): \(formatter.string(from: lastDate))")
        
        guard let nextDate = Calendar.current.date(from: m)?.addingTimeInterval(3600) else { fatalError() }
        print("Current accounting date: \(formatter.string(from: nextDate))")
        
        if !overtime && Date().compare(nextDate) == .orderedAscending {
            print("Accounting not ready yet")
            return
        }
        
        // Problem...
        var problems:[String] = []
        
        // 2. Solar panels
        
        // Fill Batteries
        let panels = truss.solarPanels
        var energyGenerated:Int = 0
        for panel in panels {
            energyGenerated += panel.maxCurrent()
        }
        print("Energy Generated: \(energyGenerated)")
        let energyInput = energyGenerated
        for bat in truss.batteries {
            let receivable = bat.capacity - bat.current
            if receivable >= energyGenerated {
                bat.current += energyGenerated
                energyGenerated = 0
                break
            } else {
                bat.current = bat.capacity
                energyGenerated -= receivable
            }
        }
        
        // 3. LSS Peripherals
        print("\n⚙️ [Peripherals] ---")
        
        var tempWater:Int = truss.tanks.filter({ $0.type == .h2o }).map({$0.current}).reduce(0, +)
        var tempAir:AirComposition = air    // The air being modified
        var accumulatedUrine:Int = 0    // Amount of urine left over from capacity of boxes
        var accumulatedPoop:Int = 0     // Amount of poop left over from capacity of boxes
        let tempEnergy = truss.batteries.map({$0.current}).reduce(0, +) + energyGenerated
        
        let report = AccountingReport(time: nextDate, energy: tempEnergy, zInput: energyInput, air: air, water: tempWater)
        
        // Peripherals
        for peripheral in peripherals {
            // power on -> broken = false || power on -> not broken = true || power off = false
            let isWorking = peripheral.powerOn == true && peripheral.isBroken == false //? (peripheral.isBroken ? false:true):false
            print("\n\t \(peripheral.peripheral.rawValue) \(peripheral.isBroken) \(peripheral.powerOn) \(peripheral.level)")
            print("\t Working:\(isWorking)")
            print("\t Fixed: \(peripheral.lastFixed?.description ?? "never")")
            print("\t Power Consumption: \(peripheral.powerConsumption())")
            
            // Energy.
            // Increase power consumption if working
            // Run air through
            if isWorking {
                if truss.consumeEnergy(amount: peripheral.powerConsumption()) {
                    let airResult = peripheral.runAirMods(air: tempAir)
                    tempAir = airResult.output
                    if airResult.waterProduced != 0 {
                        tempWater += airResult.waterProduced
                    }
                }
            } else {
                report.addProblem(string: "⛔️ \(peripheral.peripheral.rawValue) is broken")
                problems.append("⛔️ Broken Peripheral")
                continue
            }
            
            // Breaking
            if peripheral.breakable {
                // Put this in the peripheral object
                let chanceToBreak = GameLogic.chances(hit: 1.0, total: 50.0)
                if chanceToBreak {
                    print("\n ⚠️ Should break peripheral !! \n\n")
                    peripheral.isBroken = true
                    problems.append("✋ Broken Peripheral")
                    report.addProblem(string: "⛔️ \(peripheral.peripheral.rawValue) is broken")
                    continue
                }
            }
            
            switch peripheral.peripheral {
                case .ScrubberCO2:
                    if tempAir.co2 > 3 {
                        tempAir.co2 -= 3
                    }
                case .Condensator:
                    if tempAir.h2o > 4 {
                        tempAir.h2o -= 4
                        tempWater += 4
                        report.addNote(string: "Condensator removed 4Kg of water vapor")
                    }
                case .Electrolizer:
                    // Make electrolisys if air is bad
                    let conditions = [AirQuality.Lethal, AirQuality.Medium, AirQuality.Bad]
                    if conditions.contains(tempAir.airQuality()) {
                        tempWater -= 3
                        tempAir.o2 += 3
                        tempAir.h2 += 6
                        report.addNote(string: "Electrolizer used 3Kg of water, and made 3g of O2")
                    }
                case .Methanizer:
                    if tempAir.co2 > 2 {
                        if let hydrogenTank = truss.tanks.filter({ $0.type == .h2 }).sorted(by: { $0.current > $1.current}).first, hydrogenTank.current >= 2 {
                            if let methaneTank = truss.tanks.filter({ $0.type == .ch4 }).sorted(by: { $0.current < $1.current }).first, methaneTank.current < methaneTank.capacity - 1 {
                                tempAir.co2 -= 2
                                hydrogenTank.current -= 2
                                methaneTank.current += 2
                                report.addNote(string: "Methanizer produced 2Kg of methane")
                            }
                        }
                    }
                case .WaterFilter:
                    // Filter water. Remove from poop(StorageBox), add to tank(h2o)
                    if let dirty = truss.extraBoxes.filter({ $0.type == .wasteLiquid }).sorted(by: { $0.current > $1.current }).first {
                        if let drinkable = truss.tanks.filter({ $0.type == .h2o }).sorted(by: { $0.current < $1.current }).first {
                            guard dirty.current > 5 else { continue }
                            if dirty.current < 10 {
                                dirty.current -= 2
                                drinkable.current += 1
                            } else {
                                // up to 10, or 10% + lvl
                                let lvl = peripheral.level + 1
                                let amt = Int(0.1 * Double(dirty.current)) + lvl
                                dirty.current -= (amt + 1)
                                drinkable.current = min(drinkable.current + amt, drinkable.capacity)
                                report.addNote(string: "Water filter recycled \(amt)L of water")
                            }
                        }
                    }
                case .BioSolidifier:
                    // Remove from poop(StorageBox), add to Fertilizer
                    if let poop = truss.extraBoxes.filter({ $0.type == .wasteSolid }).sorted(by: { $0.current > $1.current }).first {
                        if let box = truss.extraBoxes.filter({ $0.type == .Fertilizer }).sorted(by: { $0.current < $1.current }).first {
                            if poop.current < 10 {
                                poop.current -= 2
                                box.current += 1
                            } else {
                                // up to 10, or 10% + lvl
                                let lvl = peripheral.level + 1
                                let amt = Int(0.1 * Double(poop.current)) + lvl
                                poop.current -= (amt + 1)
                                box.current = min(box.current + amt, box.capacity)
                                report.addNote(string: "BioSolid made \(amt)Kg of fertilizer")
                            }
                        }
                    }
                default:
                    continue
            }
        }
        
        // Tanks - Regulate amount of oxygen in air
        let airConditions = [AirQuality.Lethal, AirQuality.Medium, AirQuality.Bad]
        if airConditions.contains(tempAir.airQuality()) {
            // Increase oxygen
            let oxyTanks = truss.tanks.filter({ $0.type == .o2 })
            
            report.addNote(string: "Adding O2 from tanks into the air")
            
            for o2Tank in oxyTanks {
                let oNeeded = tempAir.needsOxygen()
                if oNeeded > o2Tank.current {
                    tempAir.o2 += o2Tank.current
                    o2Tank.current = 0
                } else {
                    o2Tank.current -= oNeeded
                    tempAir.o2 += oNeeded
                }
            }
        }
        
        // 4. Humans
        // + Air Transformation
        // + Water vapor Generation (evaporation)
        // + Water Consumption
        // + Dirty Water Generation (pee)
        // + Energy Consumption
        // + Food Consumption
        // + Solid Waste Generation
        // + Mood
        // + Activity check
        
        print("Air before humans...")
        print(tempAir.describe())
        
        print("\n⚙️ [PEOPLE] ---")
        let inhabitants = habModules.flatMap({$0.inhabitants}) //.reduce(0, +)    // Reduce (see: https://stackoverflow.com/questions/24795130/finding-sum-of-elements-in-swift-array)
        let radiatorsBoost:Bool = peripherals.filter({ $0.peripheral == .Radiator }).count * 3 >= inhabitants.count ? true:false
        
        for person in inhabitants {
            
            let newAir = person.consumeAir(airComp: tempAir)
            print("\t 🤓: \(person.name)\t 😷:\(person.healthPhysical)")
            print("\t 💨: \(newAir.airQuality().rawValue)")
            tempAir = newAir
            
            // consume water
            if tempWater >= GameLogic.waterConsumption {
                tempWater -= GameLogic.waterConsumption
                if person.healthPhysical < 50 {
                    person.healthPhysical += 3
                }
            } else {
                // No Water
                let dHealth = max(0, person.healthPhysical - 2)
                person.healthPhysical = dHealth
                problems.append("💦 Lack of Water")
                report.addProblem(string: "\(person.name) 💦 Lack of Water")
            }
            
            // consume energy
            if truss.consumeEnergy(amount: 1) == false {
                let dHappy = max(0, person.happiness - 2)
                person.happiness = dHappy
                problems.append("⚡️ Lack of Energy")
                report.addProblem(string: "⚡️ Lack of Energy")
            }
            
            // Consume food
            let bioBoxes = bioModules.flatMap({ $0.boxes })
            var foodConsumed:String?
            
            // Look for BioBoxes
            for box in bioBoxes {
                let newFood = box.population.filter({$0 == box.perfectDNA})
                if let randomFood = newFood.randomElement(), newFood.count > 5 {
                    if let ridx = box.population.firstIndex(of: randomFood) {
                        // Food success
                        foodConsumed? = randomFood
                        box.population.remove(at: ridx)
                        person.foodEaten.append(randomFood)
                    }
                }
            }
            // or consume from station
            if foodConsumed == nil {
                if let lastFood = food.first {
//                    person.foodEaten.append(lastFood)
//                    if person.healthPhysical < 50 {
//                        person.healthPhysical += 1
//                    }
                    person.consumeFood(lastFood, bio: false)
                    food.removeLast()
                } else {
                    // No Food
                    let dHealth = max(0, person.healthPhysical - 2)
                    person.healthPhysical = dHealth
                    if person.teamWork > 10 {
                        person.teamWork -= 1
                    }
                    problems.append("🍽 No food for \(person.name)")
                    report.addProblem(string: "🍽 No food for \(person.name)")
                }
            }
            
            // + Mood & adjustments
            person.randomMood()
            
            // Cuppola -> Happy
            if person.happiness < 95 {
                if unlockedTechItems.contains(.Cuppola) {
                    if Bool.random() == true {
                        person.happiness += 2
                    }
                }
            } else {
                // Happiness > 95, Health > 75, increase life expectancy
                if Bool.random() && Bool.random() && Bool.random() && Bool.random() && person.healthPhysical > 75 {
                    if Bool.random() || Bool.random() {
                        person.teamWork = min(100, person.teamWork + 1)
                    } else {
                        person.lifeExpectancy += 1
                    }
                }
            }
            
            // Temperature Control
            if radiatorsBoost {
                
                if person.healthPhysical < 75 && Bool.random() {
                    person.healthPhysical += 1
                }
                
                if person.happiness < 20 && Bool.random() {
                    person.happiness += 1
                }
            } else {
                
                if person.happiness > 20 && Bool.random() && Bool.random() {
                    person.happiness -= 1
                }
            }
            
            // WASTE MANAGEMENT
            
            // wasteLiquid (pee)
            accumulatedUrine += Bool.random() ? 1:2
            
            // solidWaste (poop)
            if Bool.random() {
                accumulatedPoop += 1
            }
            
            if person.healthPhysical < 20 {
                problems.append("\(person.name) is very sick! 🤮")
                report.addProblem(string: "\(person.name) is very sick! 🤮")
            }
            if person.happiness < 20 {
                problems.append("\(person.name) is unhappy! 😭")
                report.addProblem(string: "\(person.name) is unhappy! 😭")
            }
            
            // DEATH
            if person.healthPhysical < 1 {
                self.prepareDeath(of: person)
                continue
            }
            
            // + Activity check (cleanup)
            person.clearActivity()
            
            // Aging Humans (Once a week)
            if m.hour == 1 && m.weekday == 1 {
                
                person.age += 1
                var ageExtended:String = "\(person.age)"
                if ageExtended.last == "1" { ageExtended = "st" } else if ageExtended.last == "2" { ageExtended = "nd" } else if ageExtended.last == "3" { ageExtended = "rd" } else { ageExtended = "th" }
                problems.append("\(person.name)'s \(person.age)\(ageExtended) birthday!")
                if person.age > person.lifeExpectancy {
                    problems.append("\(person.name) is diying of age. Farewell!")
                    report.addProblem(string: "💀 \(person.name) is diying of age. Farewell!")
                }
            }
        }
        
        // put the water back in the containers
        let waterSpill = truss.refillTanks(of: .h2o, amount: tempWater)
        if waterSpill > 0 {
            problems.append("💦 Water spilling: \(waterSpill)")
            report.addNote(string: "💦 Water tanks are full")
        }
        
        // put back urine
        let urineSpill = truss.refillContainers(of: .wasteLiquid, amount: accumulatedUrine)
        if urineSpill > 0 {
            problems.append("💦 Urine spilling: \(urineSpill)")
            report.addNote(string: "Waste Water tanks are full")
        }
        
        // put back poop
        let poopSpill = truss.refillContainers(of: .wasteSolid, amount: accumulatedPoop)
        if poopSpill > 0 {
            problems.append("💩 Solid waste spilling: \(poopSpill)")
            report.addNote(string: "💩 Solid Waste containers are full")
        }
        
        // 5. Modules
        // + Energy Consumption
        let modulesCount = habModules.count + labModules.count + bioModules.count
        let energyForModules = modulesCount * GameLogic.energyPerModule
        let emResult = truss.consumeEnergy(amount: energyForModules)
        if emResult == true {
            print("Modules consumed energy")
            report.addNote(string: "Modules consumed ⚡️ \(energyForModules)")
        }
        
        // Report...
        let finishEnergy = truss.batteries.map({ $0.current }).reduce(0, +)
        report.results(water: tempWater, urine: accumulatedUrine, poop: accumulatedPoop, air: tempAir, energy:finishEnergy)
        
        
        // put the air back
        self.air = tempAir
        print("Air after humans...")
        print(tempAir.describe())
        
        // Air Adjustments
        let airNeeded = calculateNeededAir()
        if airNeeded > tempAir.getVolume() {
            let delta = airNeeded - tempAir.getVolume()
            if let airTank = truss.tanks.filter({ $0.type == .air }).first {
                let airXfer = min(delta, airTank.current)
                problems.append("💨 Air adjustment: \(airXfer)")
                report.addNote(string: "💨 tanks released \(airXfer)L of air")
                airTank.current -= airXfer
                air.mergeWith(newAirAmount: airXfer)
                report.reportNeededAir(amount: airXfer)
            }
        }
        // Oxygen Adjust
        let oxyNeeded = tempAir.needsOxygen()
        if oxyNeeded > 0 {
            if let oxygenTank:Tank = truss.tanks.filter({ $0.type == .o2 && $0.current > 10 }).first {
                let oxygenUse = min(oxyNeeded, oxygenTank.current)
                // Update Tank
                oxygenTank.current -= oxygenUse
                tempAir.o2 += oxygenUse
            }
        }
        // Remove Empty Tanks
        truss.tanks.removeAll(where: { $0.current <= 0 })
        
        // Report
        self.accounting = report
        
        // + Antenna -> + Money
        let antennaMoney = truss.moneyFromAntenna()
        print("\n 🤑💵 Antenna Money: \(antennaMoney)")
        if let player = LocalDatabase.shared.player {
            player.money += antennaMoney
            print(" 🤑💵 Player money: \(player.money)")
            report.addNote(string: "💵 \(player.money) (📡 + \(antennaMoney))")
        } else {
            print("No Player, no money")
        }
        
        // Advance the date
        self.accountingDate = nextDate
        if nextDate.addingTimeInterval(3600).compare(Date()) == .orderedAscending {
            print("Next Accouting...")
            self.runAccounting()
        } else {
            // Report Problems
            print("\n\n 💀 *** [PROBLEMS ENCOUNTERED] *** ")
            for problem in problems {
                print(problem)
            }
            LocalDatabase.shared.accountingProblems = problems
            
            print("--- [END OF ACCOUNTING] ---\n")
        }
    }
    
    /// When Accounting sees a person with health physycal < 1
    private func prepareDeath(of person:Person) {
        GameMessageBoard.shared.newAchievement(type: .experience, qtty: nil, message: "\(person.name) has passed away!")
        let hab = habModules.filter({ $0.inhabitants.contains(person) }).first
        hab?.inhabitants.removeAll(where: { $0.id == person.id })
    }
    
    /// Checks air for required vs supply
    func checkRequiredAir() -> Int {
        
        let labs = labModules.count
        let habs = habModules.count
        let bios = bioModules.count
        
        // Each Requires 75?
        let totalCount = labs + habs + bios
        let requiredAir = totalCount * GameLogic.airPerModule
        let suppliedAir = self.air.getVolume()
        
        print("--- Air:")
        print("--- Required: \(requiredAir)")
        print("--- Supplied: \(suppliedAir)")
        return requiredAir
        
    }
    
    /// Adds an amount of air to the Station air
    func addControlledAir(amount:Int) {
        self.air.mergeWith(newAirAmount: amount)
    }
    
    /// Calculates `Volume` of air needed in Station
    func calculateNeededAir() -> Int {
        
        var moduleCount = labModules.count + habModules.count + bioModules.count
        if (garage.xp > 0 || garage.simulationXP > 0) { moduleCount += 1 }
        if unlockedTechItems.contains(.Cuppola) { moduleCount += 1 }
        
        let airNeeded = GameLogic.airPerModule * moduleCount
        return airNeeded
    }
    
    /// Returns the module associated with ID (Lab, Hab, Bio)
    func lookupModule(id:UUID) -> Codable? {
        print("Looking up: \(id)")
        for mod in labModules {
            print("Lab mod -> \(mod.type)")
            if mod.id == id {
                print("Found lab")
                return mod
            }
        }
        for mod in habModules {
            print("Lab mod -> \(mod.type)")
            if mod.id == id {
                print("Found lab")
                return mod
            }
        }
        for mod in bioModules {
            print("Lab mod -> \(mod.type)")
            if mod.id == id {
                print("Found lab")
                return mod
            }
        }
        
        for mod in modules {
            if mod.id == id {
                print("Found Unbuild module")
                return mod
            }
        }
        
        return nil
    }
    
    func lookupRawModule(id:UUID) -> Module {
        guard let  module = modules.filter({$0.id == id}).first else {
            fatalError()
        }
        return module
    }
    
    func collectRecipe(recipe:Recipe, lab:LabModule) -> Bool {
        
        for tmpLab in self.labModules {
            if tmpLab.id == lab.id {
                tmpLab.activity = nil
            }
        }
        
        switch recipe {
            // Going to TRUSS
            case .SolarPanel:
            print("Solar")
//            let panel = SolarPanel()
            truss.addRecipeSolar(panel: SolarPanel())
            
            // Battery
            case .Battery:
            let battery = Battery(capacity: 100, current: 0)
//            let result = truss.addRecipeBattery(battery: battery)
                truss.batteries.append(battery)
                
//            print("Added Battery: \(result)")
            return true
            
            case .StorageBox:
            print("Another Storage box")
            case .Radiator:
            print("Radiator")
            
            // PERIPHERALS
            case .Methanizer:
            let m = PeripheralObject(peripheral: .Methanizer)
            self.peripherals.append(m)
            case .Electrolizer:
            let l = PeripheralObject(peripheral: .Electrolizer)
            self.peripherals.append(l)
            case .ScrubberCO2:
            let s = PeripheralObject(peripheral: .ScrubberCO2)
            self.peripherals.append(s)
            case .Condensator:
            print("Go to LSS")
            let c = PeripheralObject(peripheral: .Condensator)
            self.peripherals.append(c)
            
            
            case .Roboarm:
            print("Roboarm")
            case .Module, .Node:
            print("Node and Module dont do anything here. (See Tech Tree)")
            
            default:
            print("Another case")
        }
        return false
    }
    
    // Peripherals
    
    /**
     Removes a `Peripheral` object. (Usually when transferring to a `SpaceVehicle.
     - Parameters:
     - tank: The `Peripheral` object to be moved.
     - Returns: A `boolean` indicating whther it was successful. */
    func removePeripheral(peripheral:PeripheralObject) -> Bool {
        if let idx = peripherals.firstIndex(where: { $0.id == peripheral.id }) {
            peripherals.remove(at: idx)
            return true
        } else {
            return false
        }
    }
    
    // MARK: - Living, Rooms, and People
    // DEPRECATE SOME OF THESE - WONT NEED ALL OF THEM
    
    /// Returns how many rooms available in the station
    func checkForRoomsAvailable() -> Int {
        var availableRooms:Int = 0
        for hab in habModules {
            let limit:Int = 3
            availableRooms += (limit - hab.inhabitants.count)
        }
        return availableRooms
    }
    
    /// Tries to add a Person to a Hab Module. Returns success.
    func addToStaff(person:Person) -> Bool {
        
        // Check if that person is already there
        for hab in habModules {
            if hab.inhabitants.contains(person) {
                return false
            }
        }
        
        // Check Limit
        for hab in habModules {
            let limit:Int = 3
            if hab.inhabitants.count < limit {
                hab.inhabitants.append(person)
                return true
            }
        }
        return false
    }
    
    func getPeople() -> [Person] {
        var folks:[Person] = []
        for hab in habModules {
            folks.append(contentsOf: hab.inhabitants)
        }
        return folks
    }
    
    /**
     Initializes a new `Station` with the provided `StationBuilder`
     
     - Parameters:
     - builder: The SerialBuilder object
     
     - Returns: A beautiful, brand-new SpaceStation,
     custom-built just for you.
     */
    init(stationBuilder:StationBuilder) {
        
        // Modules Built
        modules = stationBuilder.getModules()
        
        // Scrubbers
        let scrubberActive = PeripheralObject(peripheral: .ScrubberCO2)
        let scrubberBroken = PeripheralObject(peripheral: .ScrubberCO2)
        scrubberBroken.isBroken = true
        peripherals = [scrubberBroken, scrubberActive]
        
        // Modules
        labModules = []
        habModules = []
        bioModules = []
        air = AirComposition()
        truss = Truss()
        
        unlockedRecipes = [.Condensator, .Electrolizer, .SolarPanel, .Radiator, .tank, .Battery]
        
        accountingDate = Date()
        unlockedTechItems = [TechItems.rootItem]
        
        // Initial food (10 items)
        var tmpFood:[String] = []
        for _ in 0...10 {
            let dna = PerfectDNAOption.allCases.randomElement()!
            tmpFood.append(dna.rawValue)
        }
        food = tmpFood
        
        
        self.garage = Garage()
    }
}

class AccountingReport:Codable {
    
    var id:UUID
    var date:Date
    
    var energyStart:Int
    var energyInput:Int
    var waterStart:Int
    
    var brokenPeripherals:[UUID]
    var airStart:AirComposition
    
    var airFinish:AirComposition?
    var energyFinish:Int?
    var waterFinish:Int?
    var wasteWaterFinish:Int?
    var poopFinish:Int?
    
    var tankAirAdjustment:Int?
    
    // Issues encountered when accounting (lack of water, food, O2, etc.)
    var problems:[String]?
    
    // Other notes worth taking
    var notes:[String]?
    
    init(time:Date, energy:Int, zInput:Int, air:AirComposition, water:Int) {
        self.id = UUID()
        date = time
        energyStart = energy
        energyInput = zInput
        airStart = air
        waterStart = water
        brokenPeripherals = []
    }
    
    func results(water:Int, urine:Int, poop:Int, air:AirComposition, energy:Int) {
        
        airFinish = air
        energyFinish = energy
        waterFinish = water
        wasteWaterFinish = urine
        poopFinish = poop
        
    }
    
    func reportNeededAir(amount:Int) {
        tankAirAdjustment = amount
    }
    
    /// Adds a problem to the accounting
    func addProblem(string:String) {
        var newProblems = problems ?? []
        newProblems.append(string)
        self.problems = newProblems
    }
    
    /// Gets the problems to display
    func listProblems() -> [String] {
        return problems ?? []
    }
    
    /// Adds a note to the report
    func addNote(string:String) {
        var newNotes = notes ?? []
        newNotes.append(string)
        self.notes = newNotes
    }
    
    /// Gets the notes to display
    func listNotes() -> [String] {
        return notes ?? []
    }
    
    static func example() -> AccountingReport? {
        return LocalDatabase.shared.station?.accounting
    }
}

// Partial Report?
// Accounting Peers (Person, Module, Peripheral)
// consumed items
// produced items
// ----
// Module: 10 energy ||  ---
// Person: 2 Water, 1 Food || 1 poop, 1 pee

/**
 A Container with ingredients, tanks and people
 This is a bit more organized `PayloadOrder`
 */
class PayloadOrder: Codable {
    
    static let basePrice:Int = 3000
    
    var ingredients:[StorageBox]
    var tanks:[Tank]
    var people:[Person]
    
    var delivered:Bool
    var collected:Bool?
    
    var deliveryDate:Date?
    
    /// Initializes an empty container
    init() {
        ingredients = []
        tanks = []
        people = []
        delivered = false
        collected = false
    }
    
    /// Another initializer for dates
    init(scheduled date:Date) {
        ingredients = []
        tanks = []
        people = []
        delivered = false
        self.deliveryDate = date
    }
    
    func isEmpty() -> Bool {
        return ingredients.isEmpty && tanks.isEmpty && people.isEmpty
    }
    
    /// To order from **Station**
    func orderNewIngredient(type:Ingredient) {
        let newBox = StorageBox(ingType: type, current: type.boxCapacity())
        self.ingredients.append(newBox)
    }
    
    /// Adds a new tank (Ordering from **Station**)
    func orderNewTank(type:TankType) {
        let newTank:Tank = Tank(type: type, full: true)
        self.tanks.append(newTank)
    }
    
    /// To order (From Station)
    func addPerson(person:Person) {
        people.append(person)
    }
    
    /// To add (To SpaceVehicle)
    func addCurrentBox(box:StorageBox) {
        self.ingredients.append(box)
    }
    
    /// To add (To SpaceVehicle)
    func addCurrent(ingredient:StorageBox) {
        self.ingredients.append(ingredient)
    }
    
    /// Calculates Weight for **SpaceVehicle**
    func calculateWeight() -> Int {
        return (ingredients.count + tanks.count + people.count)
    }
    
    /// Calculates cost of order
    func calculateTotal() -> Int {
        
        var price = PayloadOrder.basePrice
        for ingredient in ingredients {
            price += ingredient.type.price
        }
        
        for tank in tanks {
            price += tank.type.price
        }
        
        for _ in people {
            price += GameLogic.orderPersonPrice
        }
        
        return price
    }
    
    /// Sets all the arrays to empty
    func resetOrder() {
        ingredients = []
        tanks = []
        people = []
        delivered = false
        deliveryDate = nil
    }
}
