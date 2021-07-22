//
//  City.swift
//  SkyNation
//
//  Created by Carlos Farini on 2/27/21.
//

import Foundation

// MARK: - City

/** Server's Database representation of  `CityData` */
struct DBCity:Codable {
    
    var id:UUID
    
    var guild:[String:UUID?]?
    
    var name:String
    
    var accounting:Date
    
    var owner:[String:UUID?]?
    
    var posdex:Int
    
    /// Generates a random city
    static func generate(gid:UUID, owner:SKNPlayer?, posdex:Posdex) -> DBCity {
        let cityNames = ["Mortadella", "Elysium", "Moyses", "Drakula"]
        let oid:[String:UUID?]? = owner != nil ? ["id":owner!.id]:nil
        let newCity = DBCity(id: UUID(), guild: ["id":gid], name: cityNames.randomElement()!, accounting: Date(), owner: oid, posdex: posdex.rawValue)
        return newCity
    }
}


/// The Complete City Data
class CityData:Codable, Identifiable {
    
    var id:UUID
    var posdex:Posdex
    
    // Ingredients
    var boxes:[StorageBox]
    
    // Tanks
    var tanks:[Tank]
    
    // Batteries
    var batteries:[Battery]
    
    // Persons
    var inhabitants:[Person]
    
    // Peripherals
    var peripherals:[PeripheralObject]
    
    // SolarPanels
    var solarPanels:[SolarPanel]
    
    var bioBoxes:[BioBox]?
    
    // Robots, or Vehicles
    var vehicles:[String]?
    
    // Tech?
    var tech:[String]?
    
//    var dateAccounting:Date
    
    // To add:
    // + accounting + report
    // + airComposition
    
    
    // MARK: - Methods
    func takeBox(box:StorageBox) {
        print("Taking box from city: \(box.type). Total boxes: \(boxes.count)")
        boxes.removeAll(where: { $0.id == box.id })
        print("Boxes after taking: \(boxes.count)")
    }
    
//    func takeIngredients(ingredients:[Ingredient:Int]) {
//
//    }
    
    // MARK: - Initializers
    
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
        self.tech = []
    }
    
    /// An example filled with data
    static func example() -> CityData {
        let instance = CityData(example: true)
        return instance
    }
}

enum CityTech:String, Codable, CaseIterable {
    
    // Habs
    case Hab1
    case Hab2
    case Hab3
    case Hab4
    case Hab5
    case Hab6
    
    case OutsideDome1
    
    case VehicleRoom1
    case VehicleRoom2
    case VehicleRoom3
    case VehicleRoom4
    
    // Recipes
    case recipeCement
    case recipeGlass
    case recipeVehicle          // Can be split in different resources
    case recipeAirTrap          // Can be split
    case recipeBig
    case recipeWaterSanitizer
    case recipeAlloy
    
}

enum MarsRecipe:String, Codable, CaseIterable {
    
    case Cement     // Any Structure
    case Glass      // Any Structure
    case Alloy      // Any Structure
    
    case SolarCell
    case Polimer
    
    case MegaTank
    case MegaBox
    
    case EVehicle   // Extract Silica, Iron, Lithium, Crystals
}

// Extra Peripherals
/*
 1. Air Trap
 2. Water Sanitizer
 3. Vehicle
 */



