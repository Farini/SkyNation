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
    
    // MARK: - Accounting + Management
    
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
            let followUp = self.runAccountingCycle(nextDate)
            nextDate = followUp
            self.accountingDate = nextDate
            loops -= 1
        }
        
        // Save player + Money
        let player = LocalDatabase.shared.player
        do {
            try LocalDatabase.shared.savePlayer(player)
        } catch {
            print("Error \(error.localizedDescription)")
        }
        
        completion([response])
    }
    
    
    /// Adds an amount of air to the Station air
    func addControlledAir(amount:Int) {
        self.air.mergeWith(newAirAmount: amount)
    }
    
    /// Calculates total `Volume` of air needed in Station (does not subtract current air volume)
    func calculateNeededAir() -> Int {
        
        var moduleCount = labModules.count + habModules.count + bioModules.count
        if (garage.xp > 0 || garage.simulationXP > 0) { moduleCount += 1 }
        if unlockedTechItems.contains(.Cuppola) { moduleCount += 1 }
        
        let airNeeded = GameLogic.airPerModule * moduleCount
        return airNeeded
    }
    
    func reportLSSIssues() -> [String] {
        
        var lss:[String] = []
        
        let oxygen = truss.tanks.filter({ $0.type == .o2 }).compactMap({ $0.current }).reduce(0, +)
        let water = truss.tanks.filter({ $0.type == .h2o }).compactMap({ $0.current }).reduce(0, +)
        let foodCount = food.count
        let headCount = self.getPeople().count
        let airQuality = self.air.airQuality()
        
        if oxygen < headCount * 5 {
            if oxygen == 0 {
                lss.append("No oxygen ‼️")
            } else {
                lss.append("⚠️ low on oxygen")
            }
        }
        if water < headCount * 10 {
            if water == 0 {
                lss.append("No water ‼️")
            } else {
                lss.append("💧 low on water")
            }
        }
        if foodCount < headCount * 4 {
            if foodCount == 0 {
                lss.append("No food ‼️")
            } else {
                lss.append("⚠️ low on food")
            }
        }
        
        switch airQuality {
            case .Medium: lss.append("⚠️ Air quality is medium")
            case .Bad: lss.append("⚠️ ❗️Air quality is bad")
            case .Lethal: lss.append("‼️ Air quality is lethal!")
            default: print("Air quality ok")
        }
        
        return lss
    }
    
    // MARK: - Module Ops
    
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
    
    
    // TODO: Here
    
    /// This enum defines what intro tutorial should be shown.
    enum IntroTutorialStage:String, CaseIterable {
        case prologue
        case intro
        case habModules
        case labModules
        case hiring
        case finished
    }
    
    /// Defines should show `HandTutorial` - to display at the beginning
    func shouldShowTutorial() -> IntroTutorialStage {
        
        if habModules.isEmpty == true {
            return .habModules
        } else if labModules.isEmpty == true {
            return .labModules
        } else {
            // calculate if player ordered people
            if self.getPeople().isEmpty == true {
                // Order
                return .hiring
            } else {
                return .finished
            }
        }
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
    
    /// Everyone from all HabModules
    func getPeople() -> [Person] {
        var folks:[Person] = []
        for hab in habModules {
            folks.append(contentsOf: hab.inhabitants)
        }
        return folks
    }
    
    /// Tries to remove a Person from the station. (Usually when loading a vehicle) - returns false if person cannot be found.
    func removePerson(person:Person) -> Bool {
        for habMod in habModules {
            if habMod.inhabitants.contains(person) {
                habMod.inhabitants.removeAll(where: { $0.id == person.id })
                return true
            }
        }
        
        print("Could not find: \(person.name)")
        return false
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
        air = AirComposition(amount: nil)
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
    
    // MARK: - Codable
    /*
    private enum CodingKeys:String, CodingKey {
        // case modules
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
    }
    */
}


/**
 A Container with ingredients, tanks and people
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
