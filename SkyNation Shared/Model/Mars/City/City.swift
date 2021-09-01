//
//  City.swift
//  SkyNation
//
//  Created by Carlos Farini on 2/27/21.
//

import Foundation

// MARK: - City

/** Server's Database representation of  `CityData` */
struct DBCity:Codable, Identifiable, Hashable {
    
    var id:UUID
    
    var guild:[String:UUID?]?
    
    var name:String
    
    var accounting:Date
    
    var owner:[String:UUID?]?
    
    var posdex:Int
    
    var gateConfig:String?
    
    var gateColor:Int
    var experience:Int
    
    /// Generates a random city
    static func generate(gid:UUID, owner:SKNPlayer?, posdex:Posdex) -> DBCity {
        let cityNames = ["Mortadella", "Elysium", "Moyses", "Drakula"]
        let oid:[String:UUID?]? = owner != nil ? ["id":owner!.id]:nil
        let newCity = DBCity(id: UUID(), guild: ["id":gid], name: cityNames.randomElement()!, accounting: Date(), owner: oid, posdex: posdex.rawValue, gateColor: 0, experience:0)
        return newCity
    }
}

// MARK: - Local Database

/*
 Outpost Collection - City Data?
 1. Have a table with outpost indexes and date collected?
 */

/// The Complete City Data
class CityData:Codable, Identifiable {
    
    var id:UUID
    var posdex:Posdex
    
    
    // Persons
    var inhabitants:[Person]
    
    // + airComposition
    var air:AirComposition
    
    // MARK: - Resources
    
    // Ingredients
    var boxes:[StorageBox]
    
    // Tanks
    var tanks:[Tank]
    
    // Batteries
    var batteries:[Battery]
    
    // Peripherals
    var peripherals:[PeripheralObject]
    
    // SolarPanels
    var solarPanels:[SolarPanel]
    
    var bioBoxes:[BioBox]?
    var food:[String]?
    
    // MARK: - Tech Stack
    
    // Robots, or Vehicles
    var vehicles:[String]?
    
    // Tech Tree
    var tech:[CityTech]
//    var unlockedTech:[CityTech] = []
    
    // Recipes
    var unlockedRecipes:[Recipe]
    
    // + labActivity
    var labActivity:LabActivity?
    
    // + garage (Vehicles)
    var garage:Garage
    
    // Accounting
    var accountingDate:Date?
    var accounting:AccountingReport?
    
    /// Collected Items from Outpost
    var opCollection:[UUID:Date]? // ID of outpost -> Date collected
    
    // + accounting
    // + dateAccounting
    // + accountingReport
    
    // + food (String, or DNA ?)
    
    // MARK: - Methods
    
    // To add
    // + accounting
    
    /// Adds the product of a recipe to the city (i.e. Peripheral)
    func collectRecipe(recipe:Recipe) {
        
        switch recipe {
            // Going to TRUSS
            case .SolarPanel:
                print("Solar")
                self.solarPanels.append(SolarPanel())
                
            // Battery
            case .Battery:
                let battery = Battery(shopped: true)
                batteries.append(battery)
                
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
                let c = PeripheralObject(peripheral: .Condensator)
                self.peripherals.append(c)
            case .WaterFilter:
                let w = PeripheralObject(peripheral:.WaterFilter)
                self.peripherals.append(w)
            case .BioSolidifier:
                let b = PeripheralObject(peripheral: .BioSolidifier)
                self.peripherals.append(b)
                
            case .Alloy: self.boxes.append(StorageBox(ingType: .Alloy, current: Ingredient.Alloy.boxCapacity()))

            case .Cement: self.boxes.append(StorageBox(ingType: .Cement, current: Ingredient.Cement.boxCapacity()))
            case .ChargedGlass: self.boxes.append(StorageBox(ingType: .Glass, current: Ingredient.Glass.boxCapacity()))
            case .Module, .Node, .Radiator, .Roboarm, .StorageBox: print("Those don't work here")
            
            case .tank: self.tanks.append(Tank(type: .empty))
        }
        
    }
    
    func takeBox(box:StorageBox) {
        print("Taking box from city: \(box.type). Total boxes: \(boxes.count)")
        boxes.removeAll(where: { $0.id == box.id })
        print("Boxes after taking: \(boxes.count)")
    }
    
    /// Checks air for required vs supply
    func checkRequiredAir() -> Int {
        
        let base = GameLogic.airPerModule * 2 // 225 * 2 = 450
        var reqAir = base
        
        if tech.contains(.Hab1) { reqAir += GameLogic.airPerModule }
        if tech.contains(.Hab2) { reqAir += GameLogic.airPerModule }
        if tech.contains(.Hab3) { reqAir += GameLogic.airPerModule }
        if tech.contains(.Hab4) { reqAir += GameLogic.airPerModule }
        if tech.contains(.Hab5) { reqAir += GameLogic.airPerModule }
        if tech.contains(.Hab6) { reqAir += GameLogic.airPerModule }
        
        let suppliedAir = self.air.getVolume()
        
        print("--- Air:")
        print("--- Required: \(reqAir)")
        print("--- Supplied: \(suppliedAir)")
        return reqAir
        
    }
    
    /// Returns 1 if you have just as much as you need. Less if you have less
    func airPressure() -> Double {
        let requiredAir:Double = Double(self.checkRequiredAir())
        let available:Double = Double(self.air.getVolume())
        return requiredAir / available
    }
    
    /// When Accounting sees a person with health physycal < 1
    private func prepareDeath(of person:Person) {
        GameMessageBoard.shared.newAchievement(type: .experience, message: "💀 \(person.name) has passed away!")
        inhabitants.removeAll(where:  { $0.id == person.id })
    }
    
    /// Returns how many rooms available in the station
    func checkForRoomsAvailable() -> Int {
        
        let base = 3
        var available:Int = base
        
        if tech.contains(.Hab1) { available += 3 }
        if tech.contains(.Hab2) { available += 3 }
        if tech.contains(.Hab3) { available += 3 }
        if tech.contains(.Hab4) { available += 3 }
        if tech.contains(.Hab5) { available += 3 }
        if tech.contains(.Hab6) { available += 3 }
        
        return available
    }
    
    /**
     Checks if there are enough `ingredients` to cover the expenses.
     - Parameters:
     - ingredients: a key value of ingredient and quantity
     - Returns: An array of missing Ingredients (empty if none) */
    func validateResources(ingredients:[Ingredient:Int]) -> [Ingredient] {
        
        var lacking:[Ingredient] = []
        for (ingr, qtty) in ingredients {
            let relevantBoxes = boxes.filter({ $0.type == ingr })
            let iHave = relevantBoxes.map({$0.current}).reduce(0, +)
            if iHave < qtty {
                lacking.append(ingr)
            }
        }
        return lacking
    }
    
    /**
     Pays (reduce amount) for the resources needed. Note: Not responsible for saving.
     - Parameters:
     - ingredients: a key value pair of ingredient and quantity
     - Returns: A `boolean` indicating whther it was successful. */
    func payForResources(ingredients:[Ingredient:Int]) -> Bool {
        
        // Loop through ingredients
        for (ingr, qtty) in ingredients {
            // Get boxes that have that ingredient
            let relevantBoxes = boxes.filter({ $0.type == ingr })  // Filter
            var debt:Int = qtty
            boxLoop: for box in relevantBoxes {
                let boxQtty = box.current
                if boxQtty > debt {
                    box.current -= debt
                    debt = 0
                    break boxLoop
                } else if boxQtty == debt {
                    box.current = 0
                    debt = 0
                    // Box is empty. Remove it
                    boxes.removeAll(where: { $0.id == box.id })
                    break boxLoop
                } else if boxQtty < debt {
                    debt -= boxQtty
                    box.current = 0
                    // Box is empty. Remove it
                    boxes.removeAll(where: { $0.id == box.id })
                }
            }
            
            // End of box loop
            if debt > 0 {
                print("ERROR: COULD NOT PAY DEBT")
                return false
            }
        }
        // If it hasn't returned false at this point, its because ingredients are met.
        return true
    }
    
    /**
     Pays (reduce amount) for the resources needed. Note: Not responsible for saving.
     - Parameters:
     - dictionary: a key value pair of tank type and quantity
     - Returns: A `boolean` indicating whther it was successful. */
    func payForTanks(dictionary:[TankType:Int]) -> Bool {
        // Loop through ingredients
        for (ttype, qtty) in dictionary {
            // Get boxes that have that ingredient
            let relevantTanks = tanks.filter({ $0.type == ttype })  // Filter
            var debt:Int = qtty
            tLoop: for tank in relevantTanks {
                let tankQtty = tank.current
                if tankQtty > debt {
                    tank.current -= debt
                    debt = 0
                    break tLoop
                } else if tankQtty == debt {
                    tank.current = 0
                    debt = 0
                    // Box is empty. Remove it
                    tanks.removeAll(where: { $0.id == tank.id })
                    break tLoop
                } else if tankQtty < debt {
                    debt -= tankQtty
                    tank.current = 0
                    // Box is empty. Remove it
                    tanks.removeAll(where: { $0.id == tank.id })
                }
            }
            
            // End of tank loop
            if debt > 0 {
                print("ERROR: COULD NOT PAY DEBT")
                return false
            }
        }
        // If it hasn't returned false at this point, its because ingredients are met.
        return true
    }
    
    
    // MARK: - Initializers
    
    /// Initialize from a DBCity Object
    init(dbCity:DBCity) {
        self.id = dbCity.id
        guard let pDex = Posdex(rawValue: dbCity.posdex) else { fatalError() }
        self.posdex = pDex
        self.boxes = []
        self.tanks = []
        self.batteries = []
        self.inhabitants = []
        self.peripherals = []
        self.solarPanels = []
        self.bioBoxes = []
        self.vehicles = []
        self.tech = []
        self.air = AirComposition(amount: GameLogic.airPerModule * 2)
        self.unlockedRecipes = LocalDatabase.shared.station?.unlockedRecipes ?? []
        self.garage = Garage()
        
    }
    
    init(example:Bool, id:UUID? = nil) {
        
        self.id = id ?? UUID()
        self.posdex = Posdex.city9
        
        // Boxes
        let box1 = StorageBox(ingType: .Aluminium, current: 20)
        let box2 = StorageBox(ingType: .Copper, current: 20)
        let box4 = StorageBox(ingType: .Iron, current: 18)
        let box5 = StorageBox(ingType: .Lithium, current: 16)
        let box6 = StorageBox(ingType: .Polimer, current: 32)
        let box7 = StorageBox(ingType: .DCMotor, current: 2)
        self.boxes = [box1, box2, box4, box5, box6, box7]
        
        // Tanks
        let tank1 = Tank(type: .air, full: true)
        let tank2 = Tank(type: .o2, full: true)
        let tank3 = Tank(type: .co2, full: true)
        let tank4 = Tank(type: .h2, full: true)
        let tank5 = Tank(type: .ch4, full: true)
        self.tanks = [tank1, tank2, tank3, tank4, tank5]
        
        // Batteries
        let b1 = Battery(shopped: true)
        let b2 = Battery(shopped: true)
        let b3 = Battery(shopped: true)
        let b4 = Battery(shopped: true)
        self.batteries = [b1, b2, b3, b4]
        
        // People
        let person1 = Person(random: true)
        let person2 = Person(random: true)
        let person3 = Person(random: true)
        let person4 = Person(random: true)
        self.inhabitants = [person1, person2, person3, person4]
        
        // Peripherals
        let peri1 = PeripheralObject(peripheral: .Electrolizer)
        let peri2 = PeripheralObject(peripheral: .Methanizer)
        let peri3 = PeripheralObject(peripheral: .Radiator)
        let peri4 = PeripheralObject(peripheral: .ScrubberCO2)
        self.peripherals = [peri1, peri2, peri3, peri4]
        
        // Bioboxes
        let randomDNA = DNAOption.allCases.randomElement()!
        let bbox = BioBox(chosen: randomDNA, size: 20)
        bbox.population = Array(repeating: randomDNA.rawValue, count: 20)
        self.bioBoxes = [bbox]
        
        // Solar?
        self.solarPanels = []
        self.vehicles = []
        
        // Tech
        self.tech = [.Hab1]
        
        // Air
        self.air = AirComposition(mars: true)
        
        // Recipes
        self.unlockedRecipes = LocalDatabase.shared.station?.unlockedRecipes ?? []
        
        // Garage
        self.garage = Garage()
    }
    
    /// An example filled with data
    static func example() -> CityData {
        let instance = CityData(example: true)
        return instance
    }
}

// MARK: - Accounting

extension CityData {
    
    /**
     Runs the accounting loop.
     - Parameters:
     - recursive: Wether it should repeat until the date now has arrived.
     - completion:  A completion block with an array of possible messages . */
    func accountingLoop(recursive:Bool, completion:(_ errors:[String]) -> ()) {
        
        let accountingSheet = accountingTimeSheet()
        var loops = recursive ? accountingSheet.loops:min(accountingSheet.loops, 1) // when not recursive, just one loop (unless accounting has nothing)
        var nextDate = accountingSheet.date
        
        let response:String = "📊 Accounting Recursive: \(recursive), loops:\(loops), date:\(GameFormatters.dateFormatter.string(from: nextDate))"
        
        while loops > 0 {
            let followUp = accountingCycle(startDate: nextDate)
            nextDate = followUp
            self.accountingDate = nextDate
            loops -= 1
        }
        
        completion([response])
    }
    
    /*
     Better Account Loop (Function Above) - needsAccountingUpdates()?
     1. Pass the scene time.
     2. NEEDS to be recursive (complete before user goes on to do something else, and save the data)
     PAUSE the game if necessary
     BACKGROUND QUEUE - is where it should run.
     3. Have a completion Handler that reports whether it ran the accounting, or not.
     4. No error messages (no use)
     If not running the accounting, say so, and print just the date of next accounting.
     */
    
    /// Returns the number of loops (hours) the accounting needs, and the date it needs next
    func accountingTimeSheet() -> (loops:Int, date:Date) {
        
        let formatter = GameFormatters.fullDateFormatter
        
        if accountingDate == nil { self.accountingDate = Date() }
        var lastDate:Date = accountingDate ?? Date()
        
        var m = Calendar.current.dateComponents([.year, .month, .weekOfYear, .weekday, .day, .hour, .minute], from: lastDate)
        m.setValue(0, for: .minute)
        m.setValue(0, for: .second)
        m.setValue(0, for: .nanosecond)
        
        lastDate = Calendar.current.date(from: m) ?? Date()
        
        guard let nextDate = Calendar.current.date(from: m)?.addingTimeInterval(3600) else { fatalError() }
        
        if GameSettings.debugAccounting {
            print("\n 🌎 [STATION ACCOUNTING] \n------")
            print("Last Accounting Date: \(formatter.string(from: lastDate))")
            print("Last date (rounded): \(formatter.string(from: lastDate))")
            print("Current accounting date: \(formatter.string(from: nextDate))")
        }
        
        if Date().compare(nextDate) == .orderedAscending {
            if GameSettings.debugAccounting {
                print("Accounting not ready yet")
            }
            return (0, nextDate)
        } else {
            let hours = Calendar.current.dateComponents([.hour], from: nextDate, to: Date()).hour ?? Int.max
            return (hours, nextDate)
        }
    }
    
    /// Main Accounting function
    private func accountingCycle(startDate:Date) -> Date {
        
        // Get the initial Data, and build a report.
        
        // 1. Energy + Power Generation + Guild Power plants
        // City's solar panels
        let powerGen:Int = solarPanels.compactMap({ $0.maxCurrent() }).reduce(0, +)
        let startingEnergy:Int = self.batteries.compactMap({ $0.current }).reduce(0, +)
        
        // 2. Refill batteries function
        let energySpill:Int = self.refillBatteries(amount: powerGen)
        
        // 3. Water, Air, pee, poop
        let currentWater = tanks.filter({ $0.type == .h2o }).compactMap({ $0.current }).reduce(0, +)
        
        // 4. Start Report
        let report = AccountingReport(time: startDate, powerGen: powerGen, energy: startingEnergy, water: currentWater, air: self.air)
        
        if energySpill < 1 {
            report.addProblem(string: "Could not refill all batteries with energy.")
        }
        
        // Cycle through Peripherals
        for peripheral in peripherals {
            
            let useResult:Int = peripheral.powerConsume(crack: true)
            
            if useResult > 0 {
                // Used energy
                
                if peripheral.isBroken {
                    report.brokenPeripherals.append(peripheral.id)
                    report.addProblem(string: "⛔️ Peripheral \(peripheral.peripheral.rawValue) is broken")
                }
                
                let energyResult = consumeEnergyFromBatteries(amount: useResult)
                
                if energyResult == true && peripheral.isBroken == false {
                    
                    // Get production of Peripheral
                    let periDictionary:[String:Int] = peripheral.getConsumables()
                    var pFailToConsume:Bool = false
                    
                    // Subtracting (Consuming)
                    cLoop:for (key, value) in periDictionary where value < 0 {
                        
                        guard pFailToConsume == false else { break cLoop }
                        
                        let absConsume = abs(value)
                        
                        if let ingredient = Ingredient(rawValue: key) {
                            // Validate
                            let validationResult = self.validateResources(ingredients: [ingredient:absConsume])
                            if !validationResult.isEmpty {
                                // not enough
                                report.problems.append("Not enough \(ingredient.rawValue) for peripheral \(peripheral.peripheral.rawValue)")
                                pFailToConsume = true
                            } else {
                                let payment = payForResources(ingredients: [ingredient:abs(value)])
                                report.peripheralNotes.append("\(peripheral.peripheral.rawValue) consumed: \(absConsume) \(ingredient.rawValue)")
                                print("Account Pay: \(payment)")
                            }
                        } else if let tankType:TankType = TankType(rawValue: key) {
                            // Tank
                            if tanks.filter({ $0.type == tankType }).compactMap({ $0.current }).reduce(0, +) < absConsume {
                                // not enough
                                report.problems.append("Not enough of \(tankType.name) for peripheral \(peripheral.peripheral.rawValue)")
                                pFailToConsume = true
                            } else {
                                let paymentResult = payForTanks(dictionary: [tankType:abs(value)])
                                report.peripheralNotes.append("\(peripheral.peripheral.rawValue) consumed: \(abs(value)) \(tankType.rawValue)")
                                print("Account Pay: \(paymentResult)")
                            }
                        } else if key == "vapor" {
                            // vapor in air
                            if air.h2o < absConsume {
                                report.problems.append("Not enough vapor for \(peripheral.peripheral.rawValue)")
                                pFailToConsume = true
                            } else {
                                self.air.h2o -= absConsume
                                report.peripheralNotes.append("\(peripheral.peripheral.rawValue) consumed: \(absConsume) vapor")
                            }
                        } else if key == "oxygen" {
                            // oxygen in air, not tank
                            if air.o2 < absConsume {
                                report.problems.append("Not enough oxygen for \(peripheral.peripheral.rawValue)")
                                pFailToConsume = true
                            } else {
                                self.air.o2 -= absConsume // this actually subtracts
                                report.peripheralNotes.append("\(peripheral.peripheral.rawValue) consumed: \(absConsume) oxygen")
                            }
                        } else if key == "CarbDiox" {
                            
                            // Carbon dioxide in air (CO2)
                            if air.co2 < abs(value) {
                                report.problems.append("Not enough CO2 for \(peripheral.peripheral.rawValue)")
                                pFailToConsume = true
                            } else {
                                self.air.co2 -= absConsume
                                report.peripheralNotes.append("\(peripheral.peripheral.rawValue) consumed: \(absConsume) CO2 from air")
                            }
                        }
                    }
                    
                    // On fail, get out of loop
                    guard pFailToConsume == false else { continue }
                    
                    // Adding
                    for (key, value) in periDictionary where value > 0 {
                        
                        if let ingredient = Ingredient(rawValue: key) {
                            // Ingredient
                            let spill = refillContainers(of: ingredient, amount: value)
                            if spill > 0 {
                                report.problems.append("Could not find refill \(ingredient) completely")
                            } else {
                                report.notes.append("\(peripheral.peripheral) refilled \(key)")
                            }
                        } else if let tank = TankType(rawValue: key) {
                            // Tank
                            let spill = refillTanks(of: tank, amount: value)
                            if spill > 0 {
                                report.problems.append("Could not refill \(tank) completely")
                            } else {
                                report.notes.append("\(peripheral.peripheral) refilled \(key)")
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
            }
        }
        
        // Oxygen + Air adjustments
        // OXYGEN - Regulate amount of oxygen in air
        let airConditions = [AirQuality.Lethal, AirQuality.Medium, AirQuality.Bad]
        if airConditions.contains(self.air.airQuality()) {
            
            // Increase oxygen
            let oxyTanks = tanks.filter({ $0.type == .o2 && $0.current > 0 }).sorted(by: { $0.current > $1.current })
            var oxygenNeeds = self.air.needsOxygen()
            var added:Int = 0
            
            for o2Tank in oxyTanks {
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
        
        // Air Adjustments
        let airNeeded = self.checkRequiredAir()
        let currentVolume = self.air.getVolume()
        if airNeeded > currentVolume {
            let delta = airNeeded - currentVolume
            if let airTank = tanks.filter({ $0.type == .air }).first {
                let airXfer = min(delta, airTank.current)
                report.addNote(string: "💨 tanks released \(airXfer)L of air")
                airTank.current -= airXfer
                air.mergeWith(newAirAmount: airXfer)
                report.reportNeededAir(amount: airXfer)
            }
        }
        
        // Cycle through Humans
        var producedPee:Int = 0
        var producedPoo:Int = 0
        
        // Humans
        let radiatorsBoost:Bool = peripherals.filter({ $0.peripheral == .Radiator }).count * 3 >= inhabitants.count ? true:false
        for person in inhabitants {
            print("\(person.name)\t 😷:\(person.healthPhysical) 😃:\(person.happiness) ❤️:\(person.lifeExpectancy)")
            var nameStr = person.name
            while nameStr.count < 16 {
                nameStr += " "
            }
            let personalNote = "\(nameStr)\t 😷:\(person.healthPhysical) 😃:\(person.happiness) ❤️:\(person.lifeExpectancy)"
            report.humanNotes.append(personalNote)
            
            // Air
            let newAir = person.consumeAir(airComp: self.air)
            self.air = newAir
            
            // Water
            let waterResult = self.payForTanks(dictionary: [.h2o:GameLogic.waterConsumption])
            if waterResult == true {
                person.consumedWater(success: true)
            } else {
                // No Water
                person.consumedWater(success: false)
                report.addProblem(string: "💦 No water for \(person.name)")
            }

            // Energy
            let randomEnergy:Int = [1,2,3].randomElement()!
            let pEnergyResult = consumeEnergyFromBatteries(amount: randomEnergy)
            if pEnergyResult == true {
                person.consumedEnergy(success: true)
            } else {
                person.consumedEnergy(success: false)
                report.addProblem(string: "⚡️ No energy for \(person.name)")
            }
            
            // Food
            if let lastFood:String = food?.last {
                person.consumedFood(lastFood)
                self.food!.removeLast()
            } else {
                // Look for bio boxes
                if GameSettings.shared.serveBioBox == true {
                    let bboxes = bioBoxes?.filter({ $0.mode == .multiply && $0.population.count > 3 }) ?? []
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
            }
            
            // Mood
//            person.randomMood(tech:unlockedTechItems)
            
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
            let calcomps = Calendar.current.dateComponents([.hour, .weekday], from: startDate)
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
        
        // Returning Things
        
        // put back urine
        let urineSpill = refillContainers(of: .wasteLiquid, amount: producedPee)
        if urineSpill > 0 {
            report.addProblem(string: "💦 Waste Water containers are full")
        } else {
            report.addNote(string: "💦 Waste Water increased by \(producedPee)")
        }
        
        // put back poop
        let poopSpill = refillContainers(of: .wasteSolid, amount: producedPoo)
        if poopSpill > 0 {
            report.addProblem(string: "💩 Solid Waste containers are full")
        } else {
            report.addNote(string: "💩 Solid Waste increased by \(producedPoo)")
        }
        
        // Modules (Tech in this case) + Energy Consumption
        let modulesCount = tech.count
        let energyForModules = modulesCount * GameLogic.energyPerModule
        let emResult = self.consumeEnergyFromBatteries(amount: energyForModules)
        if emResult == true {
            print("City Tech consumed energy")
            report.addNote(string: "City consumed ⚡️ \(energyForModules)")
        }
        
        // Finish Report...
        let finishEnergy = batteries.map({ $0.current }).reduce(0, +)
        let finishWater = tanks.filter({ $0.type == .h2o }).map({ $0.current }).reduce(0, +)
        
        report.results(water: finishWater, urine: producedPee, poop: producedPoo, air: self.air, energy:finishEnergy)
        
        // Air Adjustments -> Skipping secondary air adjustment
        // Oxygen Adjust -> Skipping
        
        // Remove Empty Tanks - oxygen and water only
        if GameSettings.shared.clearEmptyTanks == true {
            tanks.removeAll(where: { $0.current <= 0 && ($0.type == .o2 || $0.type == .h2o) })
        } else {
            tanks.removeAll(where: { $0.discardEmpty == true })
        }
        
        // Merge Tanks
        if GameSettings.shared.autoMergeTanks == true {
            self.mergeTanks()
        }
        
        // Finish
        self.accounting = report
        return startDate.addingTimeInterval(3600)
    }
    
    // MARK: - Batteries & Energy
    
    /// Fills the batteries, and returns the left overs
    func refillBatteries(amount:Int) -> Int {
        var remaining:Int = amount
        for battery in batteries.sorted(by: { $0.current < $1.current }) {
            let receivable = battery.capacity - battery.current
            if receivable >= remaining {
                battery.current += remaining
                remaining = 0
                break
            } else {
                battery.current = battery.capacity
                remaining -= receivable
            }
        }
        guard remaining >= 0 else { fatalError() }
        return remaining
    }
    
    /// Consumes the amount of energy specified. Drains the batteries and returns whether success.
    func consumeEnergyFromBatteries(amount:Int) -> Bool {
        
        let orgBatteries = batteries.sorted(by: { $0.current < $1.current })
        
        var pendingConsumption:Int = amount
        
        for battery in orgBatteries {
            if pendingConsumption <= 0 { break }
            if battery.current == 0 { continue } else {
                if battery.current >= pendingConsumption {
                    battery.current -= pendingConsumption
                    pendingConsumption = 0
                } else {
                    pendingConsumption -= battery.current
                    battery.current = 0
                }
            }
        }
        
        if pendingConsumption <= 0 { return true }
        
        return false
    }
    
    /**
     Refills Containers (Pee, and poop))
     - Parameter type: The type of `StorageBox` to be refilled
     - Parameter amount: The amount of storage,  to go in the `StorageBox` array.
     - Returns: The amount that could **NOT** fit the `StorageBox`(es).
     */
    func refillContainers(of type:Ingredient, amount:Int) -> Int {
        var leftOvers = amount
        let boxArray = boxes.filter({ $0.type == type }).sorted(by: { $0.current < $1.current })
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
    
    /**
     Refills Tanks (Usually Water) after resetting them.
     - Parameter type: The type of `Tank` to be refilled
     - Parameter amount: The amount of liquid, or gas to go in the `Tank` array.
     - Returns: The amount that could **NOT** fit the `Tank`
     */
    func refillTanks(of type:TankType, amount:Int) -> Int {
        
        var leftOvers:Int = amount
        let tanksArray = tanks.filter({ $0.type == type }).sorted(by: { $0.current < $1.current })
        
        for tank in tanksArray {
//            tank.current = 0
            if leftOvers > 0 {
                let extra = tank.fillUp(leftOvers)
                leftOvers = max(extra, 0)
            }
        }
        
        return leftOvers
    }
    
    /// Marges the tanks that are half full. Discard if appropriate
    func mergeTanks() {
        
        for tankType in TankType.allCases {
            if tankType == .empty { continue }
            let relTanks = self.tanks.filter({ $0.type == tankType && $0.current < $0.capacity }).sorted(by: { $0.current > $1.current })
            if relTanks.count >= 2 {
                let firstLast = relTanks.prefix(2)
                let firstAmount = firstLast.first!.current
                let lastCapacity = firstLast.last!.capacity - firstLast.last!.current
                if lastCapacity >= firstAmount {
                    // Merge Tanks
                    self.tanks.first(where: { $0.id == firstLast.last!.id })!.current += firstAmount
                    self.tanks.first(where: { $0.id == firstLast.first!.id })!.current = 0
                    
                    // Check if should discard
                    var shouldDiscard:Bool = GameSettings.shared.clearEmptyTanks
                    // if marked as discard, discard anyways
                    if shouldDiscard == false && self.tanks.first(where: { $0.id == firstLast.first!.id })?.discardEmpty == true { shouldDiscard = true }
                    if shouldDiscard == true {
                        self.tanks.removeAll(where: { $0.id == firstLast.first!.id })
                    }
                    
                }
            } // else no merge
        }
    }
    
}
