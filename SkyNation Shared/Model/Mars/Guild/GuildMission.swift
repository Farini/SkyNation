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
    var missionStatement:String {
        switch self {
            case .arrival: return "Arrival Statement"
            case .elevatorLift: return "Build Elevator lift"
            default: return "Default mission statement goes here"
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
