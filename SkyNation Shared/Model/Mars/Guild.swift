//
//  Guild.swift
//  SkyNation
//
//  Created by Carlos Farini on 3/12/21.
//

import Foundation

/**
 The `Position` index of **City**, or **Outpost** */
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
            // Cities
            case .city1: return "City-01"
            case .city2: return "City-02"
            case .city3: return "City-03"
            case .city4: return "City-04"
            case .city5: return "City-05"
            case .city6: return "City-06"
            case .city7: return "City-07"
            case .city8: return "City-08"
            case .city9: return "City-09"
            // OPS
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

enum GuildTerrainType:String, Codable, CaseIterable {
    case Terrain1
    case Terrain2
    case Terrain3
}

struct Guild:Codable {
    
    var id: UUID
    
    //    @Field(key: "name")
    var name: String
    
    var president:[String:UUID?]?
    
    var members:[String:UUID?]?
    var citizens:[UUID]
    var isOpen:Bool
    
    /// Election Date (To change President)
    //    @Field(key: "election")
    var election:Date
    
    var terrain:String?
    
    // Cities
    var cities:[DBCity]?
    
    // Outposts
    var outposts:[DBOutpost]?
    
    static var example:Guild {
        let guild = Guild(id: UUID(), name: "Example", president: ["President":UUID()], members: nil, citizens: [UUID(), UUID(), UUID()], isOpen: true, election: Date(), terrain: "Terrain1", cities:nil, outposts: nil)
        return guild
    }
    
    func makeSummary() -> GuildSummary {
        let cityIDs = self.cities?.compactMap({ $0.id })
        let outpostIDs = self.outposts?.compactMap({ $0.id })
        let summary = GuildSummary(id: self.id, name: self.name, isOpen: self.isOpen, citizens: self.citizens, cities: cityIDs ?? [], outposts: outpostIDs ?? [])
        return summary
    }
    
}

/// the guild. Full Content Format
struct GuildFullContent:Codable {
    
    var id:UUID
    
    var name: String
    
    // https://docs.vapor.codes/4.0/fluent/relations/
    var president:SKNUserPost?
    
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

struct GuildSummary:Codable {
    
    var id:UUID
    var name:String
    var isOpen:Bool
    
    var citizens:[UUID]
    var cities:[UUID]
    var outposts:[UUID]
}

