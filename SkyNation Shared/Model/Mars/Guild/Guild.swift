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
        let guild = Guild(id: UUID(), name: name, icon:GuildIcon.allCases.randomElement()!.rawValue, color:GuildColor.allCases.randomElement()!.rawValue, president: ["id":president?.serverID ?? nil], members: nil, citizens: citizens, isOpen: Bool.random(), election: Date(), terrain: "Terrain1", cities:nil, outposts: nil)
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
struct GuildSummary:Codable {
    
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

/// Object used to elect a president and vote
struct Election:Codable {
    
    var id: UUID?
    
    var guild:[String:UUID?]
    
    // Vote Count
    
    /// Citizen x votes casted
    var casted:[UUID:Int]
    
    /// Citizen x votes received
    var voted:[UUID:Int]
    
    var createdAt:Date?
    
    var start:Date?
    
    /// The date election should start
    func startDate() -> Date {
        let prestart = self.createdAt ?? Date.distantPast
        let realStart = prestart.addingTimeInterval(60.0 * 60.0 * 24.0 * 7)
        return realStart
    }
    
    func endDate() -> Date {
        return self.startDate().addingTimeInterval(60.0 * 60.0 * 24.0)
    }
    
    func electionHasEnded() -> Bool {
        let electionStarts = self.startDate()
        let electionEnds = electionStarts.addingTimeInterval(60.0 * 60.0 * 24.0)
        return Date().compare(electionEnds) != .orderedAscending
    }
    
    
    // Voting Functions
//    func vote(from:UUID, to:UUID, token:GameToken?) -> Bool {
//
//        let dateNow = Date()
//        if dateNow.compare(startDate()) == .orderedDescending && dateNow.compare(endDate()) == .orderedAscending {
//
//            let playerVoteCount = self.casted[from, default:0]
//
//            var canVote:Bool = false
//
//            if playerVoteCount >= 3 {
//                if let token = token,
//                   token.usedDate == nil {
//                    canVote = true
//                }
//            } else {
//                canVote = true
//            }
//
//            if canVote == true {
//
//                // Do the voting
//                self.casted[from, default:0] += 1
//                self.voted[to, default:0] += 1
//            }
//
//            return canVote
//
//        } else {
//            // Not a good date
//            return false
//        }
//    }
    
//    func calculateVictory() -> UUID? {
//
//        var winner:UUID?
//        var maxVotes:Int = 0
//
//        for (key, value) in self.voted {
//            if value > maxVotes {
//                winner = key
//            }
//        }
//
//        if let winner = winner,
//           guild.citizens.contains(winner) {
//            return winner
//        } else {
//            return nil
//        }
//    }
 
    
}

/// Any event that has a start, runnins, and finished status. Mostly used by GuildMissions and GuildElections
enum GuildEventStage:String, Codable, CaseIterable {
    
    /// Election hasn't started.
    case notStarted
    
    /// Election is running 'until'
    case running
    
    /// Election Finished. Needs Updating
    case finished
    
    /// A String to be displayed on UI about this status
    var displayString:String {
        switch self {
            case .notStarted: return "not started"
            default: return self.rawValue
        }
    }
    
}

/// Contains president(PlayerContent), `Election` object and `GuildEventStage` of the election.
struct GuildElectionData:Codable {
    
    var president:PlayerContent?
    var election:Election
    var electionStage:GuildEventStage
    
    /// Election progress comparing start, end and now.
    func progress() -> Double {
        
        let start = election.startDate()
        let finish = election.endDate()
        let dateNow = Date()
        
        if dateNow.compare(start) == .orderedAscending {
            return 0
        } else {
            if dateNow.compare(finish) == .orderedAscending {
                let totalInterval = finish.timeIntervalSince(start)
                let partInterval = dateNow.timeIntervalSince(start)
                return partInterval / totalInterval
            } else {
                return 1.0
            }
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
