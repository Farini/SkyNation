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
    var position:Vector3D
    var dorms:Int // this will have to be an object, like HabModule
    
    var air:AirComposition
    
    // Resources
    var boxes:[StorageBox]
    var tanks:[Tank]
    var batteries:[Battery]
    var bioBoxes:[BioBox]
    var cityTech:[CityTech]
    
    init(user:SKNUser, position:Vector3D) {
        self.owner = user.localID
        self.position = position
        self.dorms = 3
        self.air = AirComposition(amount: 200)
        self.boxes = []
        self.tanks = []
        self.batteries = []
        self.bioBoxes = []
        self.cityTech = [.HQ]
    }
    
    func keepInMemory() {
        LocalDatabase.shared.city = self
    }
}

enum CityTech:String, Codable, CaseIterable {
    case HQ
    case Lab1
    case Hab1
    case HQ1
    case HQ2
}

enum OutpostType:String, CaseIterable, Codable {
    case Water
    case Silica
    case Energy
    case Biosphere
}

struct Outpost:Codable {
    
    var id:UUID
    var model:String
    var position:Vector3D
    
    var type:OutpostType
    var job:OutpostJob
}

struct OutpostJob: Codable {
    var wantedSkills:[String]
    var wantedIngredients:[String]
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
