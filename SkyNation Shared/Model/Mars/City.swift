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
}


/// The Complete City Data
class CityData:Codable, Identifiable {
    
    var id:UUID
    var posdex:Posdex
    
    // Modules
    
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
    
    // Robots, or Vehicles
    var vehicles:[String]?
    
    // To add:
    // + accounting + report
    // + airComposition
    // + bioBoxes?
    // + CityTech?
    
    
    // MARK: - Methods
    func takeBox(box:StorageBox) {
        print("Taking box from city: \(box.type). Total boxes: \(boxes.count)")
        boxes.removeAll(where: { $0.id == box.id })
        print("Boxes after taking: \(boxes.count)")
    }
    
    func takeIngredients(ingredients:[Ingredient:Int]) {
        
    }
    
    // MARK: - Initializers
    
    init(example:Bool) {
        
        self.id = UUID()
        self.posdex = Posdex.power1
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
        
        // Solar?
        self.solarPanels = []
        self.vehicles = []
    }
    
    /// An example filled with data
    static func example() -> CityData {
        let instance = CityData(example: true)
        return instance
    }
}


//struct CityHab:Codable {
//
//    var id:UUID
//    var capacity:Int            // Limit of people
//    var inhabitants:[Person]    // People
//    var name:String             // any name given
//    var skin:String             // If we decide so...
//    var position:Vector3D
//}

enum CityTech:String, Codable, CaseIterable {
    
    case Gate
    case Elevator
    
    case HQ
    case HQ1
    case HQ2
    
    // Hab
    /*
     Each hab has 9 people (4 + 3 + 2)
     3 habs inside = 27 people.
     2 habs outside = 45 people total */
    case Hab1
    case Hab2
    case Hab3
    case HabOut1
    case HabOut2
    case HabOut3
    
    // case Lab1
    
    case Bio1
    case Bio2
    case BioOut1
    
    case Cement
    case Foundry        // Melt metals found in mines
    case ChargedGlass   // Expose to sunlight, without problems
    case Biocell        // A cell used for Bio Outposts
    
    case OutsideBio
    case OutsidePark
    case OutsideHab
    
}


