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
    
    /// Returns the number of loops (hours) the accounting needs, and the date it needs next
    func accountingTimeSheet() -> (loops:Int, date:Date) {
        
        let formatter = GameFormatters.fullDateFormatter
        var lastDate = accountingDate
        var m = Calendar.current.dateComponents([.year, .month, .weekOfYear, .weekday, .day, .hour, .minute], from: lastDate)
        m.setValue(0, for: .minute)
        m.setValue(0, for: .second)
        m.setValue(0, for: .nanosecond)
        lastDate = Calendar.current.date(from: m) ?? Date()
        
        guard let nextDate = Calendar.current.date(from: m)?.addingTimeInterval(3600) else { fatalError() }
        
        if GameSettings.shared.debugAccounting {
            print("\n 🌎 [STATION ACCOUNTING] \n------")
            print("Last Accounting Date: \(formatter.string(from: lastDate))")
            print("Last date (rounded): \(formatter.string(from: lastDate))")
            print("Current accounting date: \(formatter.string(from: nextDate))")
        }
        
        if Date().compare(nextDate) == .orderedAscending {
            if GameSettings.shared.debugAccounting {
                print("Accounting not ready yet")
            }
            return (0, nextDate)
        } else {
            let hours = Calendar.current.dateComponents([.hour], from: nextDate, to: Date()).hour ?? Int.max
            return (hours, nextDate)
        }
    }
    
    /**
     Runs the accounting loop.
     - Parameters:
     - recursive: Wether it should repeat until the date now has arrived.
     - completion:  A completion block with an array of possible messages . */
    func accountingLoop(recursive:Bool, completion:(_ errors:[String]) -> ()) {
        
//        print("Run accounting")
        let accountingSheet = accountingTimeSheet()
        var loops = recursive ? accountingSheet.loops:min(accountingSheet.loops, 1) // when not recursive, just one loop (unless accounting has nothing)
        var nextDate = accountingSheet.date
        
        let response:String = "📊 Accounting Recursive: \(recursive), loops:\(loops), date:\(GameFormatters.dateFormatter.string(from: nextDate))"
        
        while loops > 0 {
            let followUp = accountCycle(starting: nextDate)
            nextDate = followUp
            self.accountingDate = nextDate
            loops -= 1
        }
        
        completion([response])
    }
    
    /// Main Accounting function
    private func accountCycle(starting:Date) -> Date {
        
        // Solar panels
        let powerGeneration = truss.powerGeneration()
        let leftOverPower = truss.refillBatteries(amount: powerGeneration)
        
        // report
        var water:Int = truss.getAvailableWater()
        let currentAir = air
        
        let _ = truss.getAvailableRoom(for: .wasteLiquid)   // Amount of urine left over from capacity of boxes
        let _ = truss.getAvailableRoom(for: .wasteSolid)    // Amount of poop left over from capacity of boxes
        var producedPee:Int = 0
        var producedPoo:Int = 0
        
        let report = AccountingReport(time: starting, powerGen: powerGeneration, energy: leftOverPower, water: water, air: currentAir)
        
        // Peripherals
        for peripheral in peripherals {
            // Energy.
            // Increase power consumption if working
            let useResult = peripheral.powerConsume(crack: true)
            if useResult > 0 {
                
                if peripheral.isBroken {
                    report.brokenPeripherals.append(peripheral.id)
                    report.addProblem(string: "⛔️ Peripheral \(peripheral.peripheral.rawValue) is broken")
                }
                
                let trussResult = truss.consumeEnergy(amount: useResult)
                if trussResult && peripheral.isBroken == false {
                    // Now it can work
                    
                    let production = peripheral.getConsumables()
                    var didFail:Bool = false
                    
                    // Subtracting
                    for (key, value) in production where value < 0 {
                        if let ingredient = Ingredient(rawValue: key) {
                            // Ingredient
                            let array = truss.validateResources(ingredients:[ingredient:abs(value)])
                            if !array.isEmpty {
                                report.problems.append("Not enough ingredients for peripheral \(peripheral.peripheral.rawValue)")
                                didFail = true
                            } else {
                                let payment = truss.payForResources(ingredients: [ingredient:value])
                                report.peripheralNotes.append("\(peripheral.peripheral.rawValue) produced: \(value) \(ingredient.rawValue)")
                                print("Account Pay: \(payment)")
                            }
                            
                        } else if let tank = TankType(rawValue: key) {
                            // Tank
                            if truss.tanks.filter({ $0.type == tank }).compactMap({ $0.current }).reduce(0, +) < abs(value) {
                                report.problems.append("Not enough of \(tank.name) for peripheral")
                                didFail = true
                            } else {
                                let _ = truss.chargeFrom(tank: tank, amount: value)
                                report.peripheralNotes.append("\(peripheral.peripheral.rawValue) produced: \(value) \(tank.rawValue)")
                            }
                        } else if key == "vapor" {
                            
                            if air.h2o < abs(value) {
                                report.problems.append("Not enough vapor for \(peripheral.peripheral.rawValue)")
                                didFail = true
                            } else {
                                self.air.h2o += value // this actually subtracts
                                report.peripheralNotes.append("\(peripheral.peripheral.rawValue) produced: \(value) vapor")
                            }
                            // vapor in air
                        } else if key == "oxygen" {
                            // oxygen in air, not tank
                            if air.o2 < abs(value) {
                                report.problems.append("Not enough oxygen for \(peripheral.peripheral.rawValue)")
                                didFail = true
                            } else {
                                self.air.o2 += value // this actually subtracts
                                report.peripheralNotes.append("\(peripheral.peripheral.rawValue) produced: \(value) oxygen")
                            }
                        } else if key == "CarbDiox" {
                            
                            // Carbon dioxide in air (CO2)
                            if air.co2 < abs(value) {
                                report.problems.append("Not enough CO2 for \(peripheral.peripheral.rawValue)")
                                didFail = true
                            } else {
                                self.air.co2 += value // This actually subtracts
                                report.peripheralNotes.append("\(peripheral.peripheral.rawValue) produced: \(value) CO2")
                            }
                        }
                    }
                    
                    guard didFail == false else { continue }
                    
                    // Adding
                    for (key, value) in production where value > 0 {
                        if let ingredient = Ingredient(rawValue: key) {
                            // Ingredient
                            let spill = truss.refillContainers(of: ingredient, amount: value)
                            if spill > 0 {
                                report.problems.append("Could not find refill \(ingredient) completely")
                            }
                        } else if let tank = TankType(rawValue: key) {
                            // Tank
                            let spill = truss.refillTanks(of: tank, amount: value)
                            if spill > 0 {
                                report.problems.append("Could not refill \(tank) completely")
                            }
                        } else if key == "vapor" {
                            // vapor in air
                            // No peripherals produce Vapor
                            
                        } else if key == "oxygen" {
                            // oxygen in air, not tank
                            self.air.o2 += value
                        }
                    }
                    
                }
                
            } else { continue }
        }
        
        // OXYGEN - Regulate amount of oxygen in air
        let airConditions = [AirQuality.Lethal, AirQuality.Medium, AirQuality.Bad]
        if airConditions.contains(self.air.airQuality()) {
            
            // Increase oxygen
            let oxyTanks = truss.tanks.filter({ $0.type == .o2 && $0.current > 0 }).sorted(by: { $0.current > $1.current })
            var oxygenNeeds = self.air.needsOxygen()
            var added:Int = 0
            
            for o2Tank in oxyTanks {
                //                let oNeeded = tempAir.needsOxygen()
                if o2Tank.current >= oxygenNeeds {
                    added += oxygenNeeds
                    self.air.o2 += oxygenNeeds
                    o2Tank.current -= oxygenNeeds
                    oxygenNeeds = 0
                    
                } else {
                    added += o2Tank.current
                    self.air.o2 += o2Tank.current
                    oxygenNeeds -= o2Tank.current
                    o2Tank.current = 0
                }
            }
            
            report.addNote(string: "Added \(added)L of O2 to the air")
        }
        
        // Humans
        let inhabitants = habModules.flatMap({$0.inhabitants})
        let radiatorsBoost:Bool = peripherals.filter({ $0.peripheral == .Radiator }).count * 3 >= inhabitants.count ? true:false
        for person in inhabitants {
            print("\(person.name)\t 😷:\(person.healthPhysical) 😃:\(person.happiness) ❤️:\(person.lifeExpectancy)")
            let personalNote = "\(person.name)\t 😷:\(person.healthPhysical) 😃:\(person.happiness) ❤️:\(person.lifeExpectancy)"
            report.humanNotes.append(personalNote)
            
            // Air
            let newAir = person.consumeAir(airComp: self.air)
            self.air = newAir
            
            // Water
            if water >= GameLogic.waterConsumption {
                water -= GameLogic.waterConsumption
                person.consumedWater(success: true)
                
            } else {
                // No Water
                person.consumedWater(success: false)
                report.addProblem(string: "💦 No water for \(person.name)")
            }
            
            // Energy
            let randomEnergy:Int = [1,2,3].randomElement()!
            person.consumedEnergy(success: truss.consumeEnergy(amount: randomEnergy))
            
            // Food
            if let lastFood:String = food.last {
                person.consumedFood(lastFood)
                self.food.removeLast()
            } else {
                // Look for bio boxes
                let bboxes = bioModules.flatMap({ $0.boxes }).filter({ $0.mode == .multiply && $0.population.count > 3 })
                if let nextBox = bboxes.sorted(by: { $0.population.count > $1.population.count }).first {
                    if let nextFood = nextBox.population.last {
                        nextBox.population.removeLast()
                        person.consumedFood(nextFood, bio:true)
                    }
                } else {
                    // no food
                    person.consumedFood("")
                }
            }
            
            // Mood
            person.randomMood(tech:unlockedTechItems)
            
            // Radiator
            if radiatorsBoost && person.healthPhysical < 75 && person.happiness < 30 {
                person.healthPhysical += 1
                person.happiness += 1
            }
            
            // WASTE MANAGEMENT
            producedPee += Bool.random() ? 1:2
            producedPoo += Bool.random() ? 0:1
            
            if person.healthPhysical < 20 {
                report.addProblem(string: "\(person.name) is very sick! 🤮")
            }
            if person.happiness < 20 {
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
            let calcomps = Calendar.current.dateComponents([.hour, .weekday], from: starting)
            if calcomps.hour == 1 && calcomps.weekday == 1 {
                
                person.age += 1
                var ageExtended:String = "\(person.age)"
                if ageExtended.last == "1" { ageExtended = "st" } else if ageExtended.last == "2" { ageExtended = "nd" } else if ageExtended.last == "3" { ageExtended = "rd" } else { ageExtended = "th" }
                report.humanNotes.append("🎉 \(person.name)'s \(person.age)\(ageExtended) birthday! 🥳")
                if person.age > person.lifeExpectancy {
                    report.addProblem(string: "💀 \(person.name) is diying of age. Farewell!")
                    self.prepareDeath(of: person)
                }
            }
        }
        
        // Returning things
        
        // put the water back in the containers
        let waterSpill = truss.refillTanks(of: .h2o, amount: water)
        if waterSpill > 0 {
            report.addNote(string: "💧 Water tanks are full")
        }
        
        // put back urine
        let urineSpill = truss.refillContainers(of: .wasteLiquid, amount: producedPee)
        if urineSpill > 0 {
            report.addProblem(string: "💦 Waste Water containers are full")
        }
        
        // put back poop
        let poopSpill = truss.refillContainers(of: .wasteSolid, amount: producedPoo)
        if poopSpill > 0 {
            report.addNote(string: "💩 Solid Waste containers are full")
        }
        
        // Modules + Energy Consumption
        let modulesCount = habModules.count + labModules.count + bioModules.count
        let energyForModules = modulesCount * GameLogic.energyPerModule
        let emResult = truss.consumeEnergy(amount: energyForModules)
        if emResult == true {
            print("Modules consumed energy")
            report.addNote(string: "Modules consumed ⚡️ \(energyForModules)")
        }
        
        // Report...
        let finishEnergy = truss.batteries.map({ $0.current }).reduce(0, +)
        report.results(water: water, urine: producedPee, poop: producedPoo, air: self.air, energy:finishEnergy)
        
        // Air Adjustments
        let airNeeded = calculateNeededAir()
        let currentVolume = self.air.getVolume()
        
        if airNeeded > currentVolume {
            let delta = airNeeded - currentVolume
            if let airTank = truss.tanks.filter({ $0.type == .air }).first {
                let airXfer = min(delta, airTank.current)
                report.addNote(string: "💨 tanks released \(airXfer)L of air")
                airTank.current -= airXfer
                air.mergeWith(newAirAmount: airXfer)
                report.reportNeededAir(amount: airXfer)
            }
        }
        
        // Oxygen Adjust
        let oxyNeeded = self.air.needsOxygen()
        if oxyNeeded > 0 {
            if let oxygenTank:Tank = truss.tanks.filter({ $0.type == .o2 && $0.current > 10 }).first {
                let oxygenUse = min(oxyNeeded, oxygenTank.current)
                // Update Tank
                oxygenTank.current -= oxygenUse
                self.air.o2 += oxygenUse
            }
        }
        
        // Remove Empty Tanks - oxygen only
        if GameSettings.shared.clearEmptyTanks == true {
            truss.tanks.removeAll(where: { $0.current <= 0 && ($0.type == .o2 || $0.type == .h2o) })
        }
        truss.mergeTanks()
        
        // + Antenna -> + Money
        let antennaMoney = truss.moneyFromAntenna()
        print("\n 🤑 Antenna Money: \(antennaMoney)")
        if let player = LocalDatabase.shared.player {
            player.money += antennaMoney
            print(" 💵 Player money: \(player.money)")
            report.addNote(string: "💵 \(player.money) (📡 + \(antennaMoney))")
        } else {
            print("No Player, no money")
        }
        
        // Finish
        self.accounting = report
        return starting.addingTimeInterval(3600)
    }
    
    /// When Accounting sees a person with health physycal < 1
    private func prepareDeath(of person:Person) {
        GameMessageBoard.shared.newAchievement(type: .experience, message: "💀 \(person.name) has passed away!") //newAchievement(type: .experience, qtty: nil, message: "\(person.name) has passed away!")
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
            let dna = DNAOption.allCases.filter{$0.orderable}.randomElement()!
            tmpFood.append(dna.rawValue)
        }
        food = tmpFood
        
        
        self.garage = Garage()
    }
}

struct EnergyReport:Codable {
    
    var solarInput:Int
    
    var batteriesBefore:Int
    var batteriesAfter:Int
    
    /// The total power consumed in an Accounting cycle
    var powerConsumption:Int
}

class AccountingReport:Codable {
    
    var id:UUID
    var date:Date
    
    var energyStart:Int
    var energyInput:Int
    var waterStart:Int
    
    // Issues encountered when accounting (lack of water, food, O2, etc.)
    var problems:[String]
    
    // Other notes worth taking
    var notes:[String]
    var powerNotes:[String]
    var peripheralNotes:[String]
    var humanNotes:[String]
    
    var brokenPeripherals:[UUID]
    
    var airStart:AirComposition
    var airFinish:AirComposition?
    
    var energyFinish:Int?
    var waterFinish:Int?
    var wasteWaterFinish:Int?
    var poopFinish:Int?
    
    var tankAirAdjustment:Int?
    
    init(time:Date, powerGen:Int, energy:Int, water:Int, air:AirComposition) {
        
        self.id = UUID()
        date = time
        energyStart = energy
        energyInput = powerGen
        airStart = air
        waterStart = water
        
        brokenPeripherals = []
        problems = []
        notes = []
        
        powerNotes = []
        peripheralNotes = []
        humanNotes = []
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
        var newProblems = problems
        newProblems.append(string)
        self.problems = newProblems
    }
    
    /// Gets the problems to display
    func listProblems() -> [String] {
        return problems
    }
    
    /// Adds a note to the report
    func addNote(string:String) {
        var newNotes = notes
        newNotes.append(string)
        self.notes = newNotes
    }
    
    /// Gets the notes to display
    func listNotes() -> [String] {
        return notes
    }
    
    static func example() -> AccountingReport? {
        return LocalDatabase.shared.station?.accounting
    }
}

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
