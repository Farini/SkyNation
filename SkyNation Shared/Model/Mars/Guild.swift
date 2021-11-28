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

struct GuildCreate:Codable {
    
    var name:String
    var icon:GuildIcon
    var color:GuildColor
    var president:UUID
    
    var isOpen:Bool
    var invites:[String]
    
}

// MARK: - UI Variables stored on DB

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

enum GuildEventStage:String, Codable, CaseIterable {
    
    /// Election hasn't started.
    case notStarted
    
    /// Election is running 'until'
    case running
    
    /// Election Finished. Needs Updating
    case finished
    
}

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

// MARK: - Missions

// Testing...
/*
 How to test this?
 Test that you gell all the possible missions until nextMission() == nil
 Test that multiplayers can boost time effectively
 Test that you can unlock an Outpost after certain mission
 Test how we are going to deliver it to server
 Outposts should have a "ghost" format, with a transluscent material
 
 */

enum MissionNumber:Int, CaseIterable, Codable {
    
    // start
    case arrival = 0
    
    // decorative cases
    case elevatorLift
    // remove some rock
    // windmill (between power plants)
    
    // road cases should be roadName. For now lets go with numbers
    case roadOne
    case roadTwo
    case roadThree
    
    // outposts cases
    case waterMining
    // antenna
    // landing pad update
    // powerplant2
    // powerplant3
    // power plant4
    // mining 2
    // mining 3
    // biosphere 1
    // biosphere 2
    // observatory
    
    /*
     [pre-made]: Power plant 1, City1
     in order...
     arrival, elevator lift, road1, antenna, windmill,      [5]
     road 2, city2, power plant2, Landpad update, mining 1, [5]
     road3, city3, observatory1, mining2, removeRock1       [5]
     road4, city4, observatory2, biosphere1, removeRock2    [5]
     road5, city5, biosphere2, mining3, removeRock3         [5]
     road6, city6, mining4, power plant3, removeRock4       [5]
     power plant4, HQ, Arena, Hotel                         [5]
                                                            [35]
     */
    
    /*
     Add Scene Decoration, and production to guildMap.roads, or guildMap.mapLevel
     */
    
    
    // MARK: - Details
    
    var missionTitle:String { return "Mission # \(self.rawValue)" }
    
    /// Define the mission
    var missionStatement:String { return "" }
    
    // MARK: - Requirements
    
    /// Any Skills, TankType, or Ingredient, energy or even Guild.XP that is required by mission
    var requirements:[String:Int] {
        switch self {
            case .arrival: return [:]
//            case .firstRoad: return [Skills.Handy.rawValue:1]
            default: return [:]
        }
    }
    
    // var skippable:Bool // whether can skip
    var skippable:Bool {
        switch self {
            default: return false
        }
    }
    
    /// How many times needs to repeat
    var tasks:Int {
        switch self {
            case .roadTwo: return 2
            default: return 0
        }
    }
    
    /// How long it takes for Mission to finish
    var timing:Int {
        let minutes:Int = 60
        let hours:Int = minutes * 60
        
        // timing should be a few hours
        switch self {
            case .arrival: return 5 * minutes
            case .roadTwo: return 2 * hours
            default: return 4 * hours
        }
        
    }
    
    /// How much an additional player lowers the time
    var timeKnock:Int {
        // should knock half-hour?
        return 50
    }
    
    // MARK: - Rewards
    
    /// Scene Assets added to scene
    var sceneAssetName:String? {
        switch self {
            case .elevatorLift: return "ElevatorLift"
            default: return nil
        }
    }
    
    /// Anything that adds to the guild production goes here
    var production:[String:Int] {
        switch self {
            default: return [:]
        }
    }
    
    /// experience added to Guild
    var guildXP:Int {
        switch self {
            default: return 0
        }
    }
    
}

class GuildMission:Codable, Identifiable {
    
    var id:UUID?
    
    /// This should also work as an ID
    var mission:MissionNumber
    var currentTask:Int
    
    var start:Date
    var status:GuildEventStage
    
    /// Citizens ID that are working on it. (Optionally Token ID's to shorten time)
    var workers:[UUID]
    
    /// Gets the next possible mission
    func nextMission() -> MissionNumber? {
        let cRaw = mission.rawValue + 1
        if let mission = MissionNumber(rawValue: cRaw) {
            return mission
        } else {
            // Finished?
            return nil
        }
    }
    
    /// Calculates the ending of a task
    func calculatedEnding() -> Date? {
        
        // make sure task has started, or there is no ending.
        guard status != .notStarted else { return nil }
        
        // ending a task
        let missionTime:TimeInterval = TimeInterval(mission.timing)
        
        // Cut the time with players
        let cutoff = Double(mission.timeKnock * workers.count)
        let totalTime = missionTime - cutoff
        
        return start.addingTimeInterval(totalTime)
        
    }
    
    /// Returns a `page` of `total` style to see how many tasks are left
    func pageOf() -> (page:Int, total:Int) {
        return (page:currentTask, total:mission.tasks)
    }
    
    /// Returns how many tasks (loops) until finish
    func needsTasks() -> Int {
        return mission.tasks - currentTask
    }
    
    func updateStatus() -> GuildEventStage {
        // no workers = not started
        guard !workers.isEmpty else { return .notStarted }
        
        let finish = calculatedEnding() ?? Date.distantFuture
        if Date().compare(finish) == .orderedAscending {
            return .running
        } else {
            return .finished
        }
    }
    
    /// Moves to the next Task, if completed
    func renew() {
        
        let finish = calculatedEnding() ?? Date.distantFuture
        if Date().compare(finish) == .orderedAscending {
            // not finished
            print("not finished")
        } else {
            print("task finished")
            // finished
            if needsTasks() > 0 {
                // Needs more tasks
                self.currentTask += 1
                self.reset()
            } else {
                // this is the last task, get the next mission
                if let next = nextMission() {
                    self.currentTask = 0
                    self.reset()
                    self.mission = next
                } else {
                    // All missions are finished
                    print("All missions finished")
                    return
                }
            }
        }
    }
    
    /// Sets workers to empty, and status to 'notStarted'
    func reset() {
        self.workers = []
        self.status = .notStarted
//        self.currentTask = 0
    }
    
    /// Gets the names for all assets until this mission
    func getAllAssets() -> [String] {
        var assets:[String] = []
        for i in 0..<mission.rawValue {
            if let missionAsset = MissionNumber(rawValue: i)?.sceneAssetName {
                assets.append(missionAsset)
            }
        }
        return assets
    }
    
    // MARK: - Actions
    
    func startWorking(pid:UUID) {
        
        if status != .notStarted {
            print("Attention. Start working on a status: \(status.rawValue). Should be not started.")
        }
        self.start = Date()
        self.status = .running
        self.workers.append(pid)
        
        // update
        self.renew()
    }
    
    /// Adds a player to contributions, and reduces the time to be over. This needs to be updated to server anyways
    func makeProgress(pid:UUID) {
        
        // let before = calculatedEnding()
        let b4 = mission
        
        // update mission
        // self.renew()
        
        // Make sure it starts
        if status == .notStarted {
//            self.start = Date()
//            self.status = .running
            self.startWorking(pid: pid)
            return
        }
        
        self.workers.append(pid)
        
        // Check date again
        self.renew()
        
        if b4 == self.mission {
            print("same progress. nothing changed")
        } else {
            print("Did update to mission")
        }
    }
    
    func registerEndOfMission() {
        
        self.status = .finished
        
        // pause
        if let next:MissionNumber = nextMission() {
            // there is a mission next.
            print("Next mission: \(next)")
            
            // Server Updates
            // request server to update mission number
            // server must verify that the incoming requests for upgrade missions
            // need to be the next level from the current level, not allowing a player to skip (unless skippable)
            
            // Update request (Finished)
            // post request with GuildMission
            // on a request to update, it must be one of these cases:
            // next (task) vs (task + 1),
            // next (missionNumber) vs (missionNumber + 1)
            //
            
            // Cooperate request (Start, or makeProgress, or TokenPayment)
            // post request with GuildMission
            // count workers as a Set (eliminate duplicates)
            // workers.count must be workers.count + 1
            //
            
            // then...
            self.renew()
        }
    }
    
    init() {
        self.mission = .arrival
        self.currentTask = 0
        self.start = Date()
        self.status = .notStarted
        self.workers = []
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
