//
//  Station+Account.swift
//  SkyNation
//
//  Created by Carlos Farini on 9/30/21.
//

import Foundation

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
        return LocalDatabase.shared.station.accounting
    }
}

extension Station {
    
    func runAccountingCycle(_ start:Date) -> Date {
        
        // Solar panels
        let powerGeneration = truss.powerGeneration()
        let startingEnergy = truss.batteries.compactMap({ $0.current }).reduce(0, +)
        var totalEnergy:Int = powerGeneration + startingEnergy
        // print("Energy Spilling (extra): \(energySpill)")
        
        // Water + Air
        var water:Int = truss.getAvailableWater()
        let currentAir = air
        
        // Start Report
        let report = AccountingReport(time: start, powerGen: powerGeneration, energy: startingEnergy, water: water, air: currentAir)
        
        // MARK: - Peripherals
        for peripheral:PeripheralObject in peripherals {
            
            // Energy.
            // Increase power consumption if working
            // Check if peripheral will consume power (when broken, useResult will be 0)
            let useResult:Int = peripheral.powerConsume(crack: true)
            
            // Check if peripheral is broken
            if peripheral.isBroken {
                report.brokenPeripherals.append(peripheral.id)
                report.addProblem(string: "⛔️ Peripheral \(peripheral.peripheral.rawValue) is broken")
            }
            
            if useResult == 0 {
                report.addNote(string: "\(peripheral.peripheral.rawValue) is turned off.")
                continue
            }
            
            if useResult > 0 {
                
                // Energy
                var powerConsumeResult:Bool = false
                if totalEnergy >= useResult {
                    powerConsumeResult = true
                    totalEnergy -= useResult
                }
                
                // let trussResult = truss.consumeEnergy(amount: useResult)
                if (powerConsumeResult == true) && (peripheral.isBroken == false) {
                    
                    let production = peripheral.getConsumables()
                    var didFail:Bool = false
                    
                    // Subtracting Consumables
                cLoop:for (key, value) in production where value < 0 {
                    
                    guard didFail == false else { break cLoop }
                    
                    // Ingredient
                    if let ingredient = Ingredient(rawValue: key) {
                        
                        let missingIngredients = truss.validateResources(ingredients:[ingredient:abs(value)])
                        
                        if !missingIngredients.isEmpty {
                            report.problems.append("Not enough ingredients for peripheral \(peripheral.peripheral.rawValue)")
                            didFail = true
                        } else {
                            let payment = truss.payForResources(ingredients: [ingredient:abs(value)])
                            report.peripheralNotes.append("\(peripheral.peripheral.rawValue) consumed \(abs(value)) Kg of \(ingredient.rawValue)")
                            print("Account Pay: \(payment)")
                        }
                        
                    } else
                    
                    // Tank
                    if let tank = TankType(rawValue: key) {
                        
                        if tank == .h2o {
                            // water is separate
                            water -= abs(value)
                            report.notes.append("\(peripheral.peripheral.rawValue) consumed \(abs(value))L of water.")
                        } else {
                            if truss.tanks.filter({ $0.type == tank }).compactMap({ $0.current }).reduce(0, +) < abs(value) {
                                report.problems.append("Not enough of \(tank.name) for peripheral")
                                didFail = true
                            } else {
                                let _ = truss.chargeFrom(tank: tank, amount: value)
                                report.peripheralNotes.append("\(peripheral.peripheral.rawValue) consumed: \(abs(value))L of \(tank.rawValue)")
                            }
                        }
                        
                        
                    } else
                    
                    // vapor
                    if key == "vapor" {
                        // vapor in air
                        if air.h2o < abs(value) {
                            report.problems.append("Not enough vapor for \(peripheral.peripheral.rawValue)")
                            didFail = true
                        } else {
                            self.air.h2o -= abs(value) // this actually subtracts
                            report.peripheralNotes.append("\(peripheral.peripheral.rawValue) consumed: \(abs(value))L of vapor")
                        }
                        
                    } else
                    
                    // oxygen in air (not tank)
                    if key == "oxygen" {
                        
                        if air.o2 < abs(value) {
                            report.problems.append("Not enough oxygen for \(peripheral.peripheral.rawValue)")
                            didFail = true
                        } else {
                            self.air.o2 -= abs(value) // this actually subtracts
                            report.peripheralNotes.append("\(peripheral.peripheral.rawValue) produced: \(abs(value))L of oxygen")
                        }
                    } else
                    
                    // CO2
                    if key == "CarbDiox" {
                        
                        // Carbon dioxide in air (CO2)
                        if air.co2 < abs(value) {
                            report.problems.append("Not enough CO2 for \(peripheral.peripheral.rawValue)")
                            didFail = true
                        } else {
                            self.air.co2 -= abs(value) // This actually subtracts
                            report.peripheralNotes.append("\(peripheral.peripheral.rawValue) produced: \(value) CO2")
                        }
                    }
                }
                    
                    guard didFail == false else { continue }
                    
                    // Adding
                    for (key, value) in production where value > 0 {
                        if let ingredient = Ingredient(rawValue: key) {
                            // Ingredient
                            let ingSpill = truss.refillContainers(of: ingredient, amount: value)
                            if ingSpill > 0 {
                                report.problems.append("Could not refill \(ingredient). No Boxes.")
                            } else {
                                report.notes.append("\(peripheral.peripheral) refilled \(key) with \(value)Kg.")
                            }
                        } else if let tank = TankType(rawValue: key) {
                            // Tank
                            if tank == .h2o {
                                // Water
                                water += value
                                report.notes.append("\(peripheral.peripheral) refilled \(key) with \(value)L.")
                            } else {
                                // Other Tanks
                                let spill = truss.refillTanks(of: tank, amount: value)
                                if spill > 0 {
                                    report.problems.append("Could not refill \(tank)")
                                } else {
                                    report.notes.append("\(peripheral.peripheral) refilled \(key) with \(value)L.")
                                }
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
        
        // MARK: - Humans
        let inhabitants:[Person] = habModules.flatMap({$0.inhabitants})
        let headcount = inhabitants.count
        let radiatorsBoost:Bool = peripherals.filter({ $0.peripheral == .Radiator }).count * 3 >= headcount ? true:false
        
        // Waste
        var producedPee:Int = 0
        var producedPoo:Int = 0
        
        // Tech Score: -1 (can go up to 3), or if there is less than 3 inhabitants, 0 (up to 4)
        var techScore:Int = headcount > 3 ? -1:0
        let techArray = [TechItems.Airlock, TechItems.Roboarm, TechItems.Cuppola]
        let techitems:[TechItems] = unlockedTechItems.filter({ techArray.contains($0) })
        techScore += techitems.count
        if techitems.contains(.Cuppola) { techScore += 1 }
        if radiatorsBoost == true { techScore += 1 }
        
        let playerXP = LocalDatabase.shared.player.experience
        
        for person in inhabitants {
            
            // Report First Line
            // Name Size Adjust
            var nameStr = person.name
            while nameStr.count < 16 {
                nameStr += " "
            }
            
            // Personal Note
            var personalNote = "\(nameStr)\t 😷 \(person.healthPhysical) 😃 \(person.happiness) ❤️ \(person.lifeExpectancy)"
            
            // Health (Water, Food, Air)
            personalAccountingHealth(person, water: &water, reportLine: &personalNote)
            
            // Happy (Food variety, techScore, energy, playerXP)
            personalAccountingHappy(person, techScore: techScore, playerXP: playerXP, energy: &totalEnergy, reportLine: &personalNote)
            
            // Life Expectancy (Health + happy)
            personalAccountingLifeExpect(person)
            
            print(personalNote)
            report.humanNotes.append(personalNote)
            
            // WASTE MANAGEMENT
            producedPee += Bool.random() ? 1:2
            producedPoo += Bool.random() ? 0:1
            
            // Activity check (cleanup)
            person.clearActivity()
            
            // Report Problems
            if person.healthPhysical < 20 {
                report.addProblem(string: "\(person.name) is very sick! 🤮")
            }
            if person.happiness < 20 {
                report.addProblem(string: "\(person.name) is unhappy! 😭")
            }
            
            // DEATH
            if person.healthPhysical < 1 {
                report.addProblem(string: "💀 \(person.name) is diying of age. Farewell!")
                self.prepareDeath(of: person)
                continue
            }
            
            // Aging Humans (Once a week)
            let calcomps = Calendar.current.dateComponents([.hour, .weekday], from: start)
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
        
        // MARK: - Modules + Energy Consumption
        
        let modulesCount = habModules.count + labModules.count + bioModules.count
        let energyForModules = modulesCount * GameLogic.energyPerModule
        let emResult = truss.consumeEnergy(amount: energyForModules)
        if emResult == true {
//            print("Modules consumed energy")
            report.addNote(string: "Modules consumed ⚡️ \(energyForModules)")
        }
        
        if water < 1 {
            report.addProblem(string: "💦 ran out of water")
        }
        if totalEnergy < 50 {
            report.addProblem(string: "⚡️ too little energy")
        }
        if self.food.isEmpty {
            report.addProblem(string: "🦴 not enough food")
        }
        
        // MARK: - Returning things
        
        // put the water back in the containers
        let waterReset = truss.resetWaterTanks(newWater: water)
        if waterReset > 0 {
            report.addNote(string: "💧 Water tanks are full")
        }
        
        // put back urine
        let urineSpill = truss.refillContainers(of: .wasteLiquid, amount: producedPee)
        if urineSpill > 0 {
            report.addProblem(string: "💦 Waste Water containers are full")
        } else {
            report.addNote(string: "💦 Waste Water increased by \(producedPee)")
        }
        
        // put back poop
        let poopSpill = truss.refillContainers(of: .wasteSolid, amount: producedPoo)
        if poopSpill > 0 {
            report.addNote(string: "💩 Solid Waste containers are full")
        } else {
            report.addNote(string: "💩 Solid Waste increased by \(producedPoo)")
        }
        
        // put back energy
        truss.resetEnergyLevels(to: totalEnergy)
        
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
        
        // Remove Empty Tanks - oxygen and water only
        if GameSettings.shared.clearEmptyTanks == true {
            truss.tanks.removeAll(where: { $0.current <= 0 && ($0.type == .o2 || $0.type == .h2o) })
        }
        
        // Merge Tanks
        if GameSettings.shared.autoMergeTanks == true {
            truss.mergeTanks()
        }
        
        // BioBoxes
        let allBoxes = bioModules.flatMap({ $0.boxes })
        for bioBox in allBoxes {
            self.bioAccounting(bioBox, report: report)
        }
        
        // Antenna & Money
        let antennaMoney = truss.moneyFromAntenna()
        print("\n 🤑 Antenna Money: \(antennaMoney)")
        let player = LocalDatabase.shared.player
        if habModules.compactMap({ $0.inhabitants }).count > 0 {
            player.money += antennaMoney
            print(" 💵 Player money: \(player.money)")
            report.addNote(string: "💵 \(player.money) (📡 + \(antennaMoney))")
            
        } else {
            print("No people -> No money")
            report.addNote(string: "💵 No inhabitants, no money 🥺")
        }
        
        
        // Finish
        self.accounting = report
        return start.addingTimeInterval(3600)
    }
    
    /**
     
     Method to consume energy where it tries to consume from spill first, then asks the truss for energy from Batteries
     - Parameter spill: The amount of energy spilled from Battery recharge
     - Parameter amount:  Amount of enery to be consumed
     - Returns: A boolean indicating whether the energy was successfully charged.
     
     # Discussion
     If the spill is not enough to cover the `amount`, then the energy will be consumed from  `truss.batteries`
     
     * You can write bullets by starting with an asterisk then a space.
     * Indent your asterisks to create sublists
     1. You can write numbered listed by starting with 1.
     1. Subsequent items can also be numbered 1. and Xcode will renumber them automatically.
     
     # Headings
     */
    
    
    // Human Happiness Score vs Health
    /*
     
     *** Happiness ***
     
     [ Starting Point ]
     - Random Value [-1, 0, 1]
     
     [ TECH + Peripherals ]
     1. Check for radiators vs headcount
     2. Check for Cuppola
     3. Check for Airlock
     4. Check for Roboarm
     
     [ Personal ]
     1. Check current happiness
     2. Check Food Consumed
     
     3. Check if running a task (not studying)
     3.a. Account for 'teamwork'
     3.b. Consume Energy
     3.c. Increase time if energy not enough
     
     ---
     4. Make random mood
     5. Report random mood + Change
     
     *** Health ***
     
     1. Check current Happiness
     2. Consume Air
     3. Consume Food
     4. Consume Water
     
     *** Life Expectancy ***
     
     - min: age - 1
     - goal: 75
     - max: 100
     - logic:
     - increase if happy && health > 50
     - L.E. < 75, better chances
     - L.E. > 75, small chances (max 100)
     - decrease if unhappy && health < 50
     - L.E. > 75, better chances
     - L.E. < 75, small chances (min age)
     
     
     *** Death ***
     
     - life expectancy < age
     - delta < 5 { chances = 25% }
     - delta > 5 && delta < 10 { chances = 50% }
     - delta > 10 { chances = 100% }
     
     - health < 1
     - chances = 50%
     
     */
    
    fileprivate func personalAccountingHealth(_ person:Person, water:inout Int, reportLine:inout String) {
        
        // Discussion.:
        // Water:       -1...1
        // Air:         -3...1
        // Food:        -1...1
        // Happy:       -1...1
        // Struggles:   +1...-1
        // Balance:     -1...1
        // Total:       -6...4
        
        var healthDelta:Int = 0
        
        // Water
        let consumeWater = person.healthPhysical > 30 ? GameLogic.waterConsumption:GameLogic.waterConsumption + 1
        if water >= consumeWater {
            // ok
            water -= consumeWater
            healthDelta += 1
            // reportLine += "\t +💧"
        } else {
            // no water
            healthDelta -= 1
            // reportLine += "\t -💧"
        }
        
        // Air
        let quality = air.airQuality()
        
        if air.o2 >= 2 {
            // ok
            air.o2 -= 2
            // Produce CO2, and vapor
            air.co2 += 1
            air.h2o += 1
            
            switch quality {
                case .Great:
                    healthDelta += 1
                    // reportLine += " +💨"
                case .Good: if Bool.random() { healthDelta += 1 }
                case .Medium: break
                case .Bad:
                    healthDelta -= 1
                    // reportLine += " -💨"
                case .Lethal: healthDelta -= 3
                    // reportLine += " -💨"
            }
        } else {
            healthDelta -= 5
        }
        
        // Food
        if let firstFood = self.food.first {
            self.food.removeFirst()
            person.foodEaten.append(firstFood)
            let postFood = person.foodEaten.suffix(5)
            person.foodEaten = Array(postFood)
            healthDelta += 1
            // reportLine += " +🍽"
        } else {
            // Check Bioboxes
            if GameSettings.shared.serveBioBox == true {
                let bboxes = bioModules.flatMap({ $0.boxes }).filter({ $0.mode == .multiply && $0.population.count > 3 })
                if let nextBox = bboxes.sorted(by: { $0.population.count > $1.population.count }).first,
                   let nextFood = nextBox.population.last {
                    nextBox.population.removeLast()
                    // person.consumedFood(nextFood, bio:true)
                    person.foodEaten.append(nextFood)
                    let postFood = person.foodEaten.suffix(5)
                    person.foodEaten = Array(postFood)
                    healthDelta += 1
                    // reportLine += " +🍽"
                } else {
                    healthDelta -= 3
                    // reportLine += " -🍽"
                }
            } else {
                healthDelta -= 4 // not on gamesettings
                // reportLine += " -🍽"
            }
        }
        
        // Happy
        if person.happiness < 30 {
            healthDelta -= 1
        } else if person.happiness > 70 {
            healthDelta += 1
        }
        
        // Struggles (Hard to cross thresholds)
        if person.healthPhysical < 30 {
            healthDelta += 1
        } else if person.healthPhysical > 70 {
            healthDelta -= 1
        }
        
        // Balance Happiness & Health
        if person.happiness > person.healthPhysical {
            healthDelta += 1
        } else if person.happiness < person.healthPhysical {
            healthDelta -= 1
        }
        
        // Health
        reportLine += "\t 𝝙 \(healthDelta)" // " ❤️\(healthDelta)"
        let finalHealth = max(0, min(100, person.healthPhysical + healthDelta))
        person.healthPhysical = finalHealth
    }
    
    fileprivate func personalAccountingHappy(_ person:Person, techScore:Int, playerXP:Int, energy:inout Int, reportLine:inout String) {
        
        // Discussion.:
        // Tech Score:  -1...4 if there is less than 3 inhabitants, 0 (up to 4)
        // Repeat food: -1 || Bool? (+1)
        // Busy:        -1 || Bool? (+1)
        // Energy:      -1...0 || activity? (0, -1)
        // Random:      -2...2
        // Semi-Total:  -6...8
        // Struggles:   2...-1
        /*
         1. Check current happiness
         2. Check Food Consumed
         
         3. Check if running a task (not studying)
         3.a. Account for 'teamwork'
         3.b. Consume Energy
         3.c. Increase time if energy not enough
         
         ---
         4. Make random mood
         5. Report random mood + Change
         */
        
        
        var happyDelta:Int = techScore
        
        // Check repeated food
        let fArray = person.foodEaten
        let fSet = Set(fArray)
        if fSet.count < 3 && fArray.count >= 4 {
            happyDelta -= 1
            // reportLine += " -🍻"
        } else if fSet.count > 4 {
            if Bool.random() {
                happyDelta += 1
                // reportLine += " +🍻"
            }
        }
        
        // Busy - They don't like activity
        if person.isBusy() {
            if !(person.activity?.activityName ?? "none").contains("study") {
                happyDelta -= 4
            }
        } else {
            if Bool.random() { happyDelta += 1 }
        }
        
        // Energy
        let zConsume = GameLogic.personalEnergyConsumption()
        if energy > zConsume {
            energy -= zConsume
            happyDelta += 1
        } else {
            if let activity = person.activity {
                activity.dateEnds.addTimeInterval(600) // 10 minutes more
            } else {
                happyDelta -= 4
            }
        }
        
        // Random Mood
        var moods:[Int] = [-1, 0, 1, 2]
        if playerXP > 25 {
            moods.append(-2)
            if playerXP > 75 {
                moods.append(-3)
                if playerXP > 125 {
                    moods.append(-4)
                }
            }
        }
        let randomMood = moods.randomElement() ?? 0
        happyDelta += randomMood
        
        // Struggles
        if person.happiness > 70 {
            happyDelta -= 3
        } else if person.happiness < 30 {
            happyDelta += 2
        }
        
        // Balance Happiness & Health
        if person.healthPhysical > person.happiness {
            happyDelta += 1
        } else if person.healthPhysical < person.happiness {
            happyDelta -= 1
        }
        
        // Happy
        reportLine += ", \(happyDelta)" //" 😁(\(happyDelta))"
        let finalHappy = max(0, min(100, person.happiness + happyDelta))
        person.happiness = finalHappy
        
        
    }
    
    fileprivate func personalAccountingLifeExpect(_ person:Person) {
        
        var deltaLife:[Int] = [0]
        
        // Happiness
        if person.happiness > 70 {
            deltaLife.append(1)
        } else if person.happiness < 30 {
            deltaLife.append(-1)
        }
        
        // Health
        if person.healthPhysical > 70 {
            deltaLife.append(1)
        } else if person.healthPhysical < 30 {
            deltaLife.append(-1)
        }
        
        // Balance
        if person.lifeExpectancy > 90 {
            if Bool.random() { deltaLife.append(-1) }
        } else if person.lifeExpectancy < 75 {
            if Bool.random() { deltaLife.append(1) }
        }
        
        // Final
        let finalExpectancy = max(30, min(100, person.lifeExpectancy + (deltaLife.randomElement() ?? 0)))
        person.lifeExpectancy = finalExpectancy
    }
    
    /// When Accounting sees a person with health physycal < 1, this will kill them
    private func prepareDeath(of person:Person) {
        GameMessageBoard.shared.newAchievement(type: .experience, money: 0, message: "💀 \(person.name) has passed away!")
        let hab = habModules.filter({ $0.inhabitants.contains(person) }).first
        hab?.inhabitants.removeAll(where: { $0.id == person.id })
    }
    
    private func bioAccounting(_ bioBox:BioBox, report:AccountingReport) {
        
        let stage = bioBox.mode
        let boxLimit = bioBox.populationLimit
        let dnaOption = DNAOption(rawValue: bioBox.perfectDNA) ?? .banana
        
        switch stage {
            case .grow:
                // Check if population is over limit
                if bioBox.population.count >= boxLimit {
                    break
                }
                
                // Population shouldn't be empty
                if bioBox.population.count == 0 {
                    let newPopulation = DNAGenerator.populate(dnaChoice: dnaOption, popSize: 1)
                    bioBox.population = newPopulation
                    break
                }
                
                var newBorns:Int = 0
                let pct = Double(bioBox.population.count) / Double(bioBox.populationLimit)
                if pct < 0.25 {
                    // double population
                    newBorns = bioBox.population.count * 2
                } else if pct < 0.5 {
                    // 30%
                    newBorns = Int(Double(bioBox.population.count) * 0.33)
                } else if pct < 1.0 {
                    // add 2
                    newBorns = 2
                }
                
                if truss.consumeEnergy(amount: newBorns * 10) {
                    let newPopulation = DNAGenerator.populate(dnaChoice: dnaOption, popSize: newBorns)
                    bioBox.population.append(contentsOf: newPopulation)
                } else {
                    report.addProblem(string: "No energy to grow BioBox")
                }
                
            case .evolve, .serving:
                break
                
            case .multiply:
                
                // Check if population is over limit
                if bioBox.population.count >= boxLimit {
                    break
                }
                
                let consume = truss.consumeEnergy(amount: 10)
                if consume {
                    // multiply box
                    // Check if perfect DNA already found
                    let populi = bioBox.population
                    // let perfect = bioBox.perfectDNA
                    if populi.contains(dnaOption.rawValue) {
                        // Already contains. No need to generate genetic code
                        let countBegins = bioBox.population.filter({ $0 == dnaOption.rawValue })
                        // Each perfect dna multiplies by 2
                        let nextCount = min(countBegins.count * 2, bioBox.populationLimit)
                        let newPopulation = Array(repeating: dnaOption.rawValue, count: nextCount)
                        bioBox.population = newPopulation
                        
                    }
                }
        }
    }
}


