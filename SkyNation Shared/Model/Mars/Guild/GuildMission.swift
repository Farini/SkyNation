//
//  GuildMission.swift
//  SkyNation
//
//  Created by Carlos Farini on 11/29/21.
//

import Foundation

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
    
    /* [Starting Point]
     
     Power plant 1,
     Power plant 2 (Placeholder),
     Basic LPad,
     Antenna,
     City1,
     City2
     
    */
    
    // start
    case arrival = 0
    
    // decorative cases
    case elevatorLift
    
    // road cases should be roadName. For now lets go with numbers
    case mainRoad
    case city3
    case city4
    
    case southTourRoad
    case upgradeLPad
    
    case westRoad
    case city5
    case city6
    
    case southBioRoad
    case unlockBiosphere1
    case unlockWaterMining
    
    case g5Road
    case g6Road
    
    case northRoad
    case unlockPower3
    case unlockPower4
    case unlockObservatory
    
    case eastTourRoad
    case unlockBiosphere2
    
    // outposts cases
    
    
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
    // windmill (between power plants)
    // remove some rock
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
    var missionStatement:String {
        switch self {
            case .arrival: return "Starts the Guild and sets up the main assets."
            case .elevatorLift: return "An elevator that brings the recently arrived vechicles down to the cities level."
            case .mainRoad: return "This road connects the four first cities to the rest of the guild map"
            case .city3, .city4, .city5, .city6: return "Another city is available to be picked by a player"
            case .southTourRoad: return "South Tour Road; A road that connects new outposts to the rest of the guild."
            case .upgradeLPad: return "Upgrades the landing pad, to accomodate more Space Vehicles ariiving."
            case .westRoad: return "West Road; A road that connects new cities to the rest of the guild."
            case .southBioRoad: return "Bio Road; A road that connects a new Biosphere to the rest of the guild."
            case .unlockBiosphere1: return "Unlocks the first Biosphere of the Guild. A Biosphere is an outpost that grows plants and food."
            case .unlockWaterMining: return "Unlocks water mining, which gets the ice from the soil and converts it into H2O"
            case .g5Road, .g6Road: return "Another road that connects cities to the rest of the Guild"
            
            case .northRoad: return "North Road; A road that connects more outposts to the rest of the guild."
            case .unlockPower3: return "Power Plant 3 - Unlocks another Power Plant that generates power for the Guild's cities"
            case .unlockPower4: return "Power Plant 4 - Unlocks another Power Plant that generates power for the Guild's cities"
            case .unlockObservatory: return "Unlocks the observatory, where astronomers study the universe."
            case .eastTourRoad: return "East Tour Road; A road that connects more outposts to the rest of the guild."
            case .unlockBiosphere2:return "Biosphere 2 Unlocks tanother biosphere for the Guild. A Biosphere is an outpost that grows plants and food."
        }
    }
    
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
            case .arrival: return 0
            case .elevatorLift: return 1
            case .mainRoad: return 3
            case .city3, .city4, .city5, .city6: return 1
            case .southTourRoad: return 3
            case .upgradeLPad: return 2
            case .westRoad: return 1
            case .southBioRoad: return 0
            case .unlockBiosphere1: return 2
            case .unlockWaterMining: return 2
            case .g5Road: return 0
            case .g6Road: return 0
            case .northRoad: return 2
            case .unlockPower3, .unlockPower4: return 2
            case .unlockObservatory: return 5
            case .eastTourRoad: return 3
            case .unlockBiosphere2: return 2
        }
    }
    
    /// How long it takes for each task of Mission to finish
    var timing:Int {
        let minutes:Int = 60
        let hours:Int = minutes * 60
        
        // timing should be a few hours
        switch self {
            case .arrival: return 5 * minutes
            case .elevatorLift: return 20 * minutes
            case .mainRoad, .westRoad, .southTourRoad, .eastTourRoad, .northRoad, .southBioRoad: return 4 * hours
            case .city3, .city4, .city5, .city6: return 2 * hours
            case .upgradeLPad, .unlockBiosphere1, .unlockWaterMining: return 3 * hours
            case .g5Road: return 1 * hours
            case .g6Road: return 1 * hours
            case .unlockPower3, .unlockPower4: return 4 * hours
            case .unlockObservatory: return 2 * hours
            case .unlockBiosphere2: return 2 * hours
//            default: return 4 * hours
        }
    }
    
    /// How much an additional player lowers the time
    var timeKnock:Int {
        // should knock half-hour?
        let minutes:Int = 60
//        let hours:Int = minutes * 60
        
        // timing should be a few hours
        switch self {
            case .arrival: return 1 * minutes
            case .elevatorLift: return 5 * minutes
                // Roads
            case .mainRoad, .westRoad, .southTourRoad: return 15 * minutes
            case .eastTourRoad, .northRoad, .southBioRoad: return 3 * minutes
            case .city3, .city4, .city5, .city6: return 10 * minutes
            case .upgradeLPad, .unlockBiosphere1, .unlockWaterMining: return 15 * minutes
            case .g5Road: return 10 * minutes
            case .g6Road: return 10 * minutes
            case .unlockPower3, .unlockPower4: return 20 * minutes
            case .unlockObservatory: return 20 * minutes
            case .unlockBiosphere2: return 20 * minutes
                //            default: return 4 * hours
        }
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
    }
    
    /// Gets the names for all assets until this mission
//    func getAllAssets() -> [String] {
//        var assets:[String] = []
//        for i in 0..<mission.rawValue {
//            if let missionAsset = MissionNumber(rawValue: i)?.sceneAssetName {
//                assets.append(missionAsset)
//            }
//        }
//        return assets
//    }
    
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
