//
//  Guild.swift
//  SkyNation
//
//  Created by Carlos Farini on 3/12/21.
//

import Foundation

/** The `Position` index of **City**, or **Outpost** */
enum Posdex:Int, Codable, CaseIterable {
    
    case hq = 0
    
    // 9 Cites
    case city1
    case city2
    case city3
    case city4
    case city5
    case city6
    case city7
    case city8
    case city9
    
    // 13 Outposts (+ hq = 14)
    case antenna // 10
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
    case power4 // 22
    case hotel
    
    /// Position on the map
    var position:Vector3D {
        switch self {
            case .city1: return Vector3D(x: 31.09, y: -4.869, z: 41.877)
            case .city2: return Vector3D(x: 28.0, y: -4.988, z: 27.0)
            case .city3: return Vector3D(x: 29.5, y: -4.988, z: -20.0)
            case .city4: return Vector3D(x: 30.7, y: -4.988, z: -37.5)
            case .city5: return Vector3D(x: -1.25, y: -4.988, z: 45.0)
            case .city6: return Vector3D(x: -37.75, y: -4.988, z: 18.0)
            case .city7: return Vector3D(x: -16.0, y: -4.988, z: 9.0)
            case .city8: return Vector3D(x: -27.25, y: -4.988, z: -19.0)
            case .city9: return Vector3D(x: 5.086, y: -4.988, z: -34.118)
            case .hq: return Vector3D.zero
            default: return Vector3D.zero
        }
    }
    
    /// Orientation on the map.
    var eulerAngles:Vector3D {
        switch self {
            case .city1: return Vector3D(x: 0.0, y: 1.57, z: 0.0)
            case .city2: return Vector3D(x: 0.0, y: 1.57, z: 0.0)
            case .city3: return Vector3D(x: -0.0, y: 1.57, z: 0.0)
            case .city4: return Vector3D(x: 3.1416, y: -0.733, z: 3.1416)
            case .city5: return Vector3D(x: 0.0, y: 1.57, z: 0.0)
            case .city6: return Vector3D(x: 3.1416, y: -1.361, z: 3.1416)
            case .city7: return Vector3D(x: 0.0, y: 1.57, z: 0.0)
            case .city8: return Vector3D(x: 3.1416, y: -0.9948 , z: 3.1416)
            case .city9: return Vector3D(x: 3.1416, y: -1.2217, z: 3.1416)
                
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
            case .launchPad: return "LPad"
                
            case .mining1: return "Mining-01"
            case .mining2: return "Mining-02"
            case .mining3: return "Mining-03"
            case .observatory: return "Observatory"
            case .power1: return "Power-01"
            case .power2: return "Power-02"
            case .power3: return "Power-03"
            case .power4: return "Power-04"
                
            case .hotel: return "Hotel"
                
            default: return "\(self.rawValue)"
        }
    }
}

enum GuildTerrainType:String, Codable, CaseIterable {
    case Terrain1
    case Terrain2
    case Terrain3
}

/// Guild: "a medieval association of craftsmen or merchants, often having considerable power." - in Mars!
struct Guild:Codable {
    
    var id:UUID
    
    var name:String
    
    // icon
    var icon:String
    
    // color
    var color:String
    
    var president:[String:UUID?]?
    
    var members:[String:UUID?]?
    var citizens:[UUID]
    var isOpen:Bool
    
    /// Election Date (To change President)
    var election:Date
    
    var terrain:String?
    
    // Cities
    var cities:[DBCity]?
    
    // Outposts
    var outposts:[DBOutpost]?
    
    static var example:Guild {
        let guild = Guild(id: UUID(), name: "Example", icon:GuildIcon.allCases.randomElement()!.rawValue, color:GuildColor.allCases.randomElement()!.rawValue, president: ["President":UUID()], members: nil, citizens: [UUID(), UUID(), UUID()], isOpen: true, election: Date(), terrain: "Terrain1", cities:nil, outposts: nil)
        return guild
    }
    
    func makeSummary() -> GuildSummary {
        let cityIDs = self.cities?.compactMap({ $0.id })
        let outpostIDs = self.outposts?.compactMap({ $0.id })
        let summary = GuildSummary(id: self.id, name: self.name, isOpen: self.isOpen, citizens: self.citizens, cities: cityIDs ?? [], outposts: outpostIDs ?? [], icon: icon, color: color)
        return summary
    }
    
    static func makeGuild(name:String, president:SKNPlayer?, citizens:[UUID] = [], makeCities:Int = 0) -> Guild {
        let guild = Guild(id: UUID(), name: name, icon:GuildIcon.allCases.randomElement()!.rawValue, color:GuildColor.allCases.randomElement()!.rawValue, president: ["id":president?.playerID ?? nil], members: nil, citizens: citizens, isOpen: Bool.random(), election: Date(), terrain: "Terrain1", cities:nil, outposts: nil)
        return guild
    }
    
}

/// the Guild. Full Content Format, with DBOutposts and DBCities
struct GuildFullContent:Codable, Identifiable {
    
    var id:UUID
    
    var name: String
    
    // https://docs.vapor.codes/4.0/fluent/relations/
    var president:UUID?
    
    var citizens:[PlayerContent]
    
    // icon
    var icon:String
    
    // color
    var color:String
    
    var isOpen:Bool
    
    /// Election Date (To change President)
    var election:Date
    
    var terrain:GuildTerrainType
    
    // Cities
    var cities:[DBCity]
    
    // Outposts
    var outposts:[DBOutpost]
    
    // MARK: - Data Generation
    
//    func makeExample() -> GuildFullContent {
//        let gid = UUID()
//        let gName = "Test Guild"
//        let players = SKNPlayer.randomPlayers(5)
//        let open = Bool.random()
    
//    }
    
    /// Random Data
    init(data random:Bool = true) {
        let gid = UUID()
        self.id = gid
        let randomGuildNames = ["CryptoMars","Venusians","Planetarium","Sky Alliance"]
        self.name = randomGuildNames.randomElement()!
        self.president = nil
        let players = SKNPlayer.randomPlayers(5)
        var pCitizens:[PlayerContent] = []
        for p in players {
            let c = PlayerContent(player: p)
            pCitizens.append(c)
        }
        self.citizens = pCitizens
        self.isOpen = Bool.random()
        self.election = Date().addingTimeInterval(Double.random(in: 35...8956))
        self.terrain = .Terrain1
        
        // Cities
        var tmpCities:[DBCity] = []
        for pidx in 0...4 {
            let owner = pidx < players.count ? players[pidx]:nil
            let newCity = DBCity.generate(gid: gid, owner: owner, posdex: Posdex(rawValue: pidx + 1)!)
            tmpCities.append(newCity)
        }
        self.cities = tmpCities
        
        // Outposts
        var ops:[DBOutpost] = []
        for opdex in 10...22 {
            let op = DBOutpost(gid: gid, type: OutpostType.allCases.randomElement()!, posdex: Posdex(rawValue: opdex)!)
            ops.append(op)
        }
        self.outposts = ops
        
        self.icon = GuildIcon.allCases.randomElement()!.rawValue
        self.color = GuildColor.allCases.randomElement()!.rawValue
        
    }
    
    
    func makeSummary() -> GuildSummary {
        let cityIDs = self.cities.compactMap({ $0.id })
        let outpostIDs = self.outposts.compactMap({ $0.id })
        let summary = GuildSummary(id: self.id, name: self.name, isOpen: self.isOpen, citizens: self.citizens.compactMap({ $0.id }), cities: cityIDs , outposts: outpostIDs , icon: icon, color: color)
        return summary
    }
    
}

/// A Small representation of Guild object. Convenient for presenting a Guild in the screen
struct GuildSummary:Codable, Identifiable {
    
    var id:UUID
    var name:String
    var isOpen:Bool
    
    var citizens:[UUID]
    var cities:[UUID]
    var outposts:[UUID]
    
    // icon
    var icon:String
    
    // color
    var color:String
}

/// A Version of a Guild used to create a new guild in the server
struct GuildCreate:Codable {
    
    var name:String
    var icon:GuildIcon
    var color:GuildColor
    var president:UUID
    
    var isOpen:Bool
    var invites:[String]
    
}

// MARK: - UI Variables stored on DB

/// Enumeration of Icons possible for the Guild
enum GuildIcon:String, Codable, CaseIterable, Equatable {
    
    case moon
    case eclipse
    case club
    case spade
    case diamond
    case star
    case sunDust
    
    var imageName:String {
        switch self {
            case .moon: return "moon"
            case .eclipse: return "circlebadge.2"
            case .club: return "suit.club"
            case .spade: return "suit.spade"
            case .diamond: return "suit.diamond"
            case .star: return "star"
            case .sunDust: return "sun.dust"
        }
    }
}

import SwiftUI

enum GuildColor:String, Codable, CaseIterable {
    case red
    case blue
    case green
    case gray
    
    var color:Color {
        switch self {
            case .red: return Color.red
            case .blue: return Color.blue
            case .green: return Color(.sRGB, red: 0.0, green: 1.0, blue: 0.1, opacity: 1.0)
            case .gray: return Color.init(.sRGB, white: 0.75, opacity: 1.0)
        }
    }
}

/**
 Content suitable for map
 */
final class GuildMap:Codable {
    
    // Description
    var id:UUID
    var name:String
    var icon:String
    var color:String
    var experience:Int
    var markdown:String
    
    // Citizens
    var isOpen:Bool
    var citizens:[PlayerContent]
    
    /// List of Players that got invited to Guild
    var invites:[UUID]
    
    /// List of players that want to join Guild
    var joinlist:[UUID]
    
    /// ID of the president
    var president:UUID?
    
    // Map
    var cities:[DBCity]
    var outposts:[DBOutpost]
    var mission:GuildMission?
    var roads:String
    var mapLevel:String
    var terrain:GuildTerrainType // (String)
    
    // last
    var lastUpdate:Date // updateAt, or distant past
    var account:Date?
    
    var election:Election?
    var chat:[ChatMessage]?
    var vehicles:[SpaceVehicleTicket]?
    
    init(randomized:Bool = true) {
        self.id = UUID()
        self.name = "random"
        self.icon = GuildIcon.allCases.randomElement()!.rawValue
        self.color = GuildColor.allCases.randomElement()!.rawValue
        self.experience = 0
        self.markdown = "Some Markdown"
        self.isOpen = false
        self.citizens = []
        self.invites = [UUID()]
        self.joinlist = [UUID()]
        self.president = nil
        self.cities = []
        self.outposts = []
        self.mission = GuildMission()
        self.roads = ""
        self.mapLevel = ""
        self.terrain = .Terrain1
        self.lastUpdate = Date()
        self.account = Date()
        
        self.election = nil
        self.chat = []
        self.vehicles = []
        
    }
    
    // better initializer
    /// Population: amount of citizens
    init(name:String = "Test Guild", population:Int, mission:GuildMission = GuildMission(), makePresident:Bool) {
        
        self.id = UUID()
        self.name = name
        self.icon = GuildIcon.allCases.randomElement()!.rawValue
        self.color = GuildColor.allCases.randomElement()!.rawValue
        
        self.experience = 10 * population
        self.markdown = "Guild Default Markdown"
        self.isOpen = false
        
        var populi:[PlayerContent] = []
        for _ in 0..<population {
            let new = PlayerContent(player: SKNPlayer())
            populi.append(new)
        }
        self.citizens = populi
        
        self.invites = [UUID()]
        self.joinlist = []
        
        // President
        if makePresident == true {
            if let randomPresident = populi.randomElement() {
                self.president = randomPresident.id
            }
        } else {
            self.president = nil
        }
        
        self.cities = []
        self.outposts = []
        
        self.mission = mission
        
        self.roads = ""
        self.mapLevel = ""
        self.terrain = .Terrain1
        self.lastUpdate = Date()
        self.account = Date()
        
        self.election = nil
        self.chat = []
        self.vehicles = []
    }
    
    
    func makeSummary() -> GuildSummary {
        let gSum = GuildSummary(id: self.id, name: self.name, isOpen: self.isOpen, citizens: self.citizens.compactMap({ $0.id }), cities: self.cities.compactMap({ $0.id }), outposts: self.outposts.compactMap({ $0.id }), icon: self.icon, color: self.color)
        return gSum
    }
    
    /// Compares what is new
    func compareFlags(newMap:GuildMap) -> [ServerManager.GuildFlag] {

        var newFlags:[ServerManager.GuildFlag] = []

        // messages
        let myChat:Set<ChatMessage> = Set(self.chat ?? [])
        if let newChat = newMap.chat {
            for newPost in newChat {
                if myChat.contains(where: { $0.id == newPost.id }) == false {
                    newFlags.append(.messages)
                }
            }
        }
        
        // election
        if let newElection = newMap.election {
            if newElection.getStage() == .running {
                newFlags.append(.election)
            }
        }
        // citizens
        let oldCitizens = Set<PlayerContent>(self.citizens)
        let newCitizens = Set<PlayerContent>(newMap.citizens)
        let addedCitizens = newCitizens.subtracting(oldCitizens)
        let lostCitizens = oldCitizens.subtracting(newCitizens)
        if addedCitizens.isEmpty == false || lostCitizens.isEmpty == false {
            newFlags.append(.citizens)
        }
        
        // vehicles
        let oldVehicles = Set<SpaceVehicleTicket>(self.vehicles ?? [])
        let newVehicles = Set<SpaceVehicleTicket>(newMap.vehicles ?? [])
        let addedVehicles = newVehicles.subtracting(oldVehicles)
        if addedVehicles.isEmpty == false {
            newFlags.append(.vehicles)
        }
        
        // missions
        if let newMission = newMap.mission {
            if let oldMission = self.mission {
                if newMission.mission != oldMission.mission {
                    // Different mission entirely
                    newFlags.append(.missions)
                } else {
                    let oldPage = oldMission.pageOf().page
                    let newPage = newMission.pageOf().page
                    // Different page (task)
                    if oldPage != newPage {
                        newFlags.append(.missions)
                    }
                }
            }
        }
        
        return newFlags
    }
    
    /*
     Missing:
     ✅ president   (set at init)
     ✅ citizens    (set at init)
     ✅ mission
     ⚠️ chat
     ⚠️ Vehicles
     */
    
    /*
    func addMission(mission:GuildMission) {
        self.mission = mission
    }
    
    // Upon Request...
    
    func addElection(election:Election) {
        self.election = election
    }
    
    func addChat(messages:[ChatMessage]) {
        self.chat = messages
    }
    
    func addVehicles(vehicles:[SpaceVehicleModel]) {
        self.vehicles = vehicles
    }
    */
    
    /*
     Notes:
     Keeping the chat here allows you to increment the count of messages (client side)
     This means we can send a notification when there is an unread message
     */
    
}
