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
    
    // Tech Tree
    var tech:[CityTech]
    
    // MARK: - To add:
    
    // + airComposition
    var air:AirComposition
    
    // + unlockedRecipes
    var unlockedRecipes:[Recipe]
    
    // + labActivity
    var labActivity:LabActivity?
    
    // + garage (Vehicles)
    var garage:Garage
    
    // + accounting + report
    // + dateAccounting
    // + accountingReport
    
    // + food (String, or DNA ?)
    
    // MARK: - Methods
    
    // To add
    // + accounting
    // + collectRecipe
    // + removeItem(peripheral, box, etc?)
    // + roomsAvailable
    
    func takeBox(box:StorageBox) {
        print("Taking box from city: \(box.type). Total boxes: \(boxes.count)")
        boxes.removeAll(where: { $0.id == box.id })
        print("Boxes after taking: \(boxes.count)")
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
        self.air = AirComposition(mars: true)
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

enum CityTech:String, Codable, CaseIterable, Identifiable {
    
    /// Conveniently identifies this item versus others
    var id: String {
        return self.rawValue
    }
    
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
    
    // MARK: - Logic
    
    /// Determines whether this tech can be researched. See CityData.tech, if the unlockedBy tech has been discovered, then this tech can be researched.
    var unlockedBy:CityTech? {
        switch self {
            case .Hab2: return .Hab1
            case .Hab3: return .Hab2
            case .Hab4: return .Hab3
            case .Hab5: return .Hab4
            case .Hab6: return .Hab5
            
            case .VehicleRoom4: return .VehicleRoom3
            case .VehicleRoom3: return .VehicleRoom2
            case .VehicleRoom2: return .VehicleRoom1
            case .VehicleRoom1: return .recipeVehicle
                
            case .recipeAirTrap: return .Hab3
            case .recipeGlass: return .Hab4
            case .recipeCement: return .Hab2
            case .recipeAlloy: return .VehicleRoom2
                
            default: return nil
        }
    }
//    var unlocks:[CityTech] {
//        switch self {
//            case .Hab1: return [.Hab2, .recipeVehicle]
//            default: return []
//        }
//    }
    
    // MARK: - Display
    
    var shortName:String {
        switch self {
            case .Hab1, .Hab2, .Hab3, .Hab4, .Hab5, .Hab6: return "Hab Module"
            default: return "Short"
        }
    }
    
    var elaborated:String {
        switch self {
            case .Hab1, .Hab2, .Hab3, .Hab4, .Hab5, .Hab6: return "Adds room for more people"
            default: return "Tech description goes here"
        }
    }
    
    // MARK: - Requirements
    
    /// Ingredients required to research this tech
    var ingredients:[Ingredient:Int] {
        switch self {
            case .Hab1: return [.Iron:10, .Ceramic:5]
            case .Hab2: return [.Iron:14, .Ceramic:8, .DCMotor:1]
            case .Hab3: return [.Iron:20, .Ceramic:16, .Silica:2]
            default: return [:]
        }
    }
    
    /// Amount of seconds it takes to complete this tech research
    var duration:Int {
        switch self {
            default: return 1
        }
    }
    
    /// `Human` Skills required to research this tech
    var skillSet:[Skills:Int] {
        switch self {
            default: return [.Material:2]
        }
    }
    
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

struct CityTechTree {
    var uniqueTree:Tree<Unique<CityTech>>
    
    init() {
        
        let cement = Tree(CityTech.recipeCement)
        let glass = Tree(CityTech.recipeGlass)
        let airTrap = Tree(CityTech.recipeAirTrap)
        let alloy = Tree(CityTech.recipeAlloy)
        
        let hab6 = Tree(CityTech.Hab6)
        let hab5 = Tree(CityTech.Hab5, children:[hab6])
        let hab4 = Tree(CityTech.Hab4, children:[hab5, glass])
        let hab3 = Tree(CityTech.Hab3, children:[hab4, airTrap])
        let hab2 = Tree(CityTech.Hab2, children:[hab3, cement])
        
        let vr4 = Tree(CityTech.VehicleRoom4)
        let vr3 = Tree(CityTech.VehicleRoom3, children:[vr4])
        let vr2 = Tree(CityTech.VehicleRoom2, children:[alloy, vr3])
        let vr1 = Tree(CityTech.VehicleRoom1, children:[vr2])
        
        let recVehicle = Tree(CityTech.recipeVehicle, children:[vr1])
        
        // Finalize
        let binaryTree = Tree<CityTech>(CityTech.Hab1, children: [hab2, recVehicle])
        
        let uniqueTree:Tree<Unique<CityTech>> = binaryTree.map(Unique.init)
        self.uniqueTree = uniqueTree
    }
}
