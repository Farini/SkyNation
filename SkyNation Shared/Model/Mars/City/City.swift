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

