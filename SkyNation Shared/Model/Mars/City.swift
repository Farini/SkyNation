//
//  City.swift
//  SkyNation
//
//  Created by Carlos Farini on 2/27/21.
//

import Foundation


struct Terrain:Codable {
    
    var id:UUID
    var model:String
    var guild:UUID
    var type:GuildTerrainType
    
    var cities:[DBCity]         // Each city with its own file, but generally from this level, we want the basic city (database)
    var outposts:[Outpost]
    
    // Incoming Vehicles?
    
    init() {
        self.id = UUID()
        self.model = Terrain.randomName()
        self.guild = UUID()
        self.type = .Terrain1
        self.cities = []
        self.outposts = []
    }
    
    static func randomName() -> String {
        return ["Name A", "Name B", "Name C"].randomElement()!
    }
}



// MARK: - City

struct DBCity:Codable {
    
    var id:UUID
    
    var guild:[String:UUID?]?
    
    var name:String
    
    var accounting:Date
    
    var owner:[String:UUID?]?
    
    var posdex:Int
}

struct City {
    
    var owner:UUID?
    var name:String = ""
    var posdex:Posdex
    
    var position:Vector3D
    var habs:[CityHab] // this will have to be an object, like HabModule
    
    // Resources
    var air:AirComposition
    var boxes:[StorageBox]
    var tanks:[Tank]
    var batteries:[Battery]
    var bioBoxes:[BioBox]
    
    // Tech
    var cityTech:[CityTech]
    
    var bots:[MarsBot]?
    
    init(user:SKNUserPost, posdex:Posdex) {
        self.owner = user.localID
        self.position = posdex.position
        self.habs = [CityHab(id: UUID(), capacity: 4, inhabitants: [], name: "untitled", skin: "skin", position: .zero)]
        self.air = AirComposition(amount: 200)
        self.boxes = []
        self.tanks = []
        self.batteries = []
        self.bioBoxes = []
        self.cityTech = [.HQ]
        self.posdex = posdex
    }
    
    func keepInMemory() {
        LocalDatabase.shared.city = self
    }
}

/// The Complete City Data
struct CityData:Codable, Identifiable {
    
    var id:UUID
    var owner:SKNUserPost?
    var position:Vector3D?
    
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
}


struct CityHab:Codable {
    
    var id:UUID
    var capacity:Int            // Limit of people
    var inhabitants:[Person]    // People
    var name:String             // any name given
    var skin:String             // If we decide so...
    var position:Vector3D
}

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


