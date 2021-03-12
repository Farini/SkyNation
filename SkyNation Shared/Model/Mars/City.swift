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

enum GuildTerrainType:String, Codable, CaseIterable {
    case Terrain1
    case Terrain2
    case Terrain3
}

struct Guild:Codable {
    
    var id: UUID
    
    //    @Field(key: "name")
    var name: String
    
    // https://docs.vapor.codes/4.0/fluent/relations/
    //    @OptionalParent(key:"player_id")
    var president:[String:UUID?]?
    
    /// The @Children property creates a one-to-many relation between two models. It does not store any values on the root model.
    //    @Children(for: \.$guild)
    var members:[String:UUID?]?
    var citizens:[UUID]
    var isOpen:Bool
    
    /// Election Date (To change President)
    //    @Field(key: "election")
    var election:Date
    
    //    @Enum(key: "terraintype")
    var terrain:GuildTerrainType
    
    // Cities
    var cities:[DBCity]?
    
    // Outposts
    var outposts:[DBOutpost]?
    
    static var example:Guild {
        let guild = Guild(id: UUID(), name: "Example", president: ["President":UUID()], members: nil, citizens: [UUID(), UUID(), UUID()], isOpen: true, election: Date(), terrain: .Terrain1, cities:nil, outposts: nil)
        return guild
    }
    
}

/// the guild. Full Content Format
struct GuildFullContent:Codable {
    
    var id:UUID
    
    var name: String
    
    // https://docs.vapor.codes/4.0/fluent/relations/
    var president:SKNUser?
    
    var citizens:[PlayerContent]
    
    var isOpen:Bool
    
    /// Election Date (To change President)
    var election:Date
    
    var terrain:GuildTerrainType
    
    // Cities
    var cities:[DBCity]
    
    // Outposts
    var outposts:[DBOutpost]
    
    
}


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
    
    init(user:SKNUser, posdex:Posdex) {
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

enum OutpostType:String, CaseIterable, Codable {
    
    case Water          // OK Produces Water
    case Silica         // OK Produces Silica
    case Energy         // OK Produces Energy
    case Biosphere      // OK Produces Food
    case Titanium       // OK Produces Titanium
    case Observatory    //
    case Antenna        // OK Comm
    case Launchpad      // OK Launch / Receive Vehicles
    case Arena          // Super Center
    case ETEC           // Extraterrestrial Entertainement Center
    
    var productionBase: [Ingredient:Int] {
        switch self {
            case .Water: return [.Water:20]
            case .Silica: return [.Silica:10]
            case .Energy: return [.Battery:20]
            case .Biosphere: return [.Food:100]
            case .Titanium: return [.Iron:5, .Aluminium:10]
            case .Observatory: return [:]
            case .Antenna: return [:]
            case .Launchpad: return [:]
            case .Arena: return [:]
            case .ETEC: return [:]
        }
    }
    
    /// Happiness Production
    var happyDelta:Int {
        switch self {
            case .Energy: return 0
            case .Water: return 0
            case .Silica: return -1
            case .Biosphere: return 3
            case .Titanium: return -1
            case .Observatory: return 2
            case .Antenna: return 1
            case .Launchpad: return 0
            case .Arena: return 5
            case .ETEC: return 3
        }
    }
    
    /// Energy production (Consumed as negative)
    var energyDelta:Int {
        switch self {
            case .Energy: return 100
            case .Water: return -20
            case .Silica: return -25
            case .Biosphere: return -15
            case .Titanium: return -25
            case .Observatory: return -5
            case .Antenna: return -5
            case .Launchpad: return -10
            case .Arena: return -50
            case .ETEC: return -20
        }
    }
}

class Outpost:Codable {
    
    var id:UUID
    var guild:UUID
    
    var model:String = ""
    var position:Vector3D
    var posdex:Posdex
    
    var type:OutpostType
    var job:OutpostJob
    var level:Int = 0
    
    func createAnOutpostJobPair() {
        let job = OutpostJob(wantedSkills: [.Biologic:5, .Medic:3, .SystemOS:5, .Handy:12],
                             wantedIngredients: [.Aluminium:1, .Fertilizer:80, .Food:25])
        self.job = job
    }
    
    func makeModel() {
        switch type {
            case .Water: print("Make Water")
                switch level {
                    case 0...5: print("Low Level")
                    case 6...10: print("Mid Level")
                    case 11...15: print("Advanced")
                    default:print("ERROR")
                }
            case .Silica: print("Make Silica")
            case .Energy: print("Make Energy")
            case .Biosphere: print("Make Biosphere")
            case .Titanium: print("Make Titanium")
            case .Observatory: print("Make Observatory")
            case .Antenna: print("Make Antenna")
            case .Launchpad: print("Make Launchpad")
            case .Arena: print("Make Arena")
            case .ETEC: print("Make ETEC")
        }
    }
}

struct OutpostJob: Codable {
    
    var wantedSkills:[Skills:Int] // [String:Int]
    var wantedIngredients:[Ingredient:Int] // [String:Int]
    
}

struct DBOutpost:Codable {
    
    
    var id:UUID
    
    
    var model:String
    
    var guild:[String:UUID?]?
    
    var type:OutpostType
    
    var level:Int
    
    var accounting:Date
    
    //    init() {}
    //
    //    init(id: UUID? = nil, modelName:String, guildID:UUID, oType:OutpostType, date:Date? = nil, newLevel:Int? = nil) {
    //
    //        print("Creating Outpost Model: \(modelName), in \(guild.name)")
    //
    //        self.id = id
    //        self.type = oType
    //        self.model = modelName
    //
    //        self.level = newLevel ?? 0
    //
    //        self.accounting = date ?? Date()
    //
    //    }
    
}

/**
 The `Position` index of **City**, or **Outpost**
 */
enum Posdex:Int, Codable, CaseIterable {
    
    case hq = 0
    case city1
    case city2
    case city3
    case city4
    case city5
    case city6
    case city7
    case city8
    case city9
    case antenna
    case arena
    case biosphere1
    case biosphere2
    case launchPad
    case mining1
    case mining2
    case mining3
    case observatory
    case power1
    case power2
    case power3
    case power4
    
    /// Position on the map
    var position:Vector3D {
        switch self {
            case .hq: return Vector3D.zero
            default: return Vector3D.zero
        }
    }
    
    var sceneName:String {
        switch self {
            case .antenna: return "Antenna"
            case .arena: return "Arena"
            case .biosphere1: return "Biosphere-01"
            case .biosphere2: return "Biosphere-02"
            case .launchPad: return "LandingPad"
            case .mining1: return "Mining-01"
            case .mining2: return "Mining-02"
            case .mining3: return "Mining-03"
            case .observatory: return "Observatory"
            case .power1: return "Power-01"
            case .power2: return "Power-02"
            case .power3: return "Power-03"
            case .power4: return "Power-04"
                
            default: return "\(self.rawValue)"
        }
    }
}
