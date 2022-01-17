//
//  GameCenterManager.swift
//  SkyNation
//
//  Created by Carlos Farini on 12/17/21.
//

import Foundation
import GameKit

/// Takes care of everything Game Center related
class GameCenterManager {
    
    static let shared = GameCenterManager()
    
    var isUnderage:Bool = true
    var isMultiplayer:Bool = false
    var isChatEnabled:Bool = false
    
    var gcid:String?
    var teamID:String?
    var gcPlayer:GKLocalPlayer?
    
    var lastExperience:Date?
    
    /// Initializes GameCenter
    private init() {
        
        // Game Center
        GKLocalPlayer.local.authenticateHandler = { viewController, error in
            
            if let viewController = viewController {
                
                // Present the view controller so the player can sign in.
                print("\n\nView Controller \(viewController) from GameCenter wants to be presented.")
                
                // Open Game Center
                NotificationCenter.default.post(name: .openGameCenter, object: viewController)
                
                return
            }
            if let error = error {
                // Player could not be authenticated.
                // Disable Game Center in the game.
                print("\n\n ⚠️ Error authenticating Game Center: \(error.localizedDescription)")
                return
            }
            
            // Player was successfully authenticated.
            // Check if there are any player restrictions before starting the game.
            
            if GKLocalPlayer.local.isUnderage {
                print("Hide explicit game content.")
            } else {
                self.isUnderage = false
            }
            
            if GKLocalPlayer.local.isMultiplayerGamingRestricted {
                print("Disable multiplayer game features.")
            } else {
                self.isMultiplayer = true
            }
            
            if GKLocalPlayer.local.isPersonalizedCommunicationRestricted {
                print("Disable in game communication UI.")
            } else {
                self.isChatEnabled = true
            }
            
            // let gcid = GKLocalPlayer.local.isPresentingFriendRequestViewController = true
            // let gcid = GKLocalPlayer.local.alias
            
            let gcid = GKLocalPlayer.local.gamePlayerID
            print("Game Center gamePlayerID: \(gcid)")
            self.gcid = gcid
            
            let teamID = GKLocalPlayer.local.teamPlayerID
            print("Game Center teamPlayerID: \(teamID)")
            self.teamID = teamID
            
            self.gcPlayer = GKLocalPlayer.local
            
            // Perform any other configurations as needed (for example, access point).
            let sknPlayer = LocalDatabase.shared.player
            if sknPlayer.experience > 0 {
                // dispatch
                DispatchQueue.init(label: "com.cfarini.reportAchievements").asyncAfter(deadline: .now() + 5.0, execute: {
                    self.reportAchievements()
                })
            }
        }
    }
    
    /// Returns whether LocalDatabase Player has gcid equals the `gcid` parameter.
    static func compareExistingPlayer(gcid:String) -> Bool {
        let dbID:String? = LocalDatabase.shared.player.gcid
        if let dbID = dbID {
            // local player has id
            if dbID == gcid {
                return true
            } else {
                return false
            }
        } else {
            // no id yet
            return false
        }
    }
    
    // MARK: - Leaderboards
    
    /// Update Player XP
    func postPlayerExperience() {
        
        // Make sure player objects are here, and authenticated
        guard let gcPlayer:GKLocalPlayer = gcPlayer, gcPlayer.isAuthenticated == true else {
            print("\n\n Player not authenticated in GameCenter")
            return
        }
        let gPlayer:SKNPlayer = LocalDatabase.shared.player
        
        // Make sure experience is more than 0
        guard gPlayer.experience > 0 else {
            print("\n\n Not enough experience to post")
            return }
        
        // Check if already updated
        if let lastExperience = lastExperience {
            let deadline = lastExperience.addingTimeInterval(3600) // 1hr
            if Date().compare(deadline) == .orderedDescending {
                print("Posted score recently")
                return
            }
        }
        print("\n\n Posting Experience Score")
        
        // Submit score
        GKLeaderboard.submitScore(gPlayer.experience, context: 0, player: gcPlayer, leaderboardIDs: ["Player_Experience_001"]) { error in
            if let error = error {
                print("⚠️ Leaderboard Error: \(error.localizedDescription)")
            } else {
                // Went through
                self.lastExperience = Date()
                print("Went through (Experience)")
            }
        }
    }
    
    // MARK: - Accomplishments
    
    /*
     Two ways
     1. Post Score
     2. Fetch Score -> Update
     */
    
    private enum AchievementID:String, CaseIterable {
        
        case waterFilter = "com.cfarini.build_a_water_filter"
        case condensator = "com.cfarini.build_condensator"
        case airlock = "com.cfarini.researchAirlock"
        
        func hasAchieved(station:Station) -> Bool {
            switch self {
                case .waterFilter:
                    return station.peripherals.filter({ $0.peripheral == .WaterFilter }).first != nil
                case .condensator:
                    return station.peripherals.filter({ $0.peripheral == .Condensator }).first != nil
                case .airlock:
                    return station.unlockedTechItems.contains(TechItems.Airlock) == true
            }
        }
    }
    
    func reportAchievements() {
        
        print("\nReporting GameCenter Achievements")
        
        let station = LocalDatabase.shared.station
        
        // Load the player's active achievements.
        GKAchievement.loadAchievements(completionHandler: { (achievements: [GKAchievement]?, error: Error?) in
            
            // Put together an array of unvisited
            var visited:[AchievementID] = []
            
            // The array of achievements to report
            var newAchievements:[GKAchievement] = []
            
            for gkAchievement in achievements ?? [] {
                let achieveID = gkAchievement.identifier
                if let aid = AchievementID(rawValue: achieveID) {
                    // Achievement Completed
                    if gkAchievement.isCompleted {
                        // Add one to array, so we don't visit this again
                        visited.append(aid)
                    } else {
                        // Not Completed
                        if aid.hasAchieved(station: station) == true {
                            // Set achievement completed
                            gkAchievement.percentComplete = 100.0
                            newAchievements.append(gkAchievement)
                        }
                    }
                } else {
                    print("Weird achievement ID: \(gkAchievement.identifier)")
                }
            }
            
            let toVisit:Set<AchievementID> = Set(AchievementID.allCases).subtracting(Set(visited))
            let visit:[AchievementID] = Array(toVisit)
            
            for visitor:AchievementID in visit {
                if visitor.hasAchieved(station: station) == true {
                    // Create new Achievement
                    let newAchievement = GKAchievement(identifier: visitor.rawValue)
                    newAchievement.percentComplete = 100.0
                    newAchievements.append(newAchievement)
                }
            }
            
            if newAchievements.isEmpty == true {
                return
            } else {
                GKAchievement.report(newAchievements) { reportError in
                    if let reportError = reportError {
                        // report error
                        print("Report Error: \(reportError.localizedDescription)")
                    }
                }
            }
            
            /*
            
            let achievementID = "101"
            var achievement: GKAchievement? = nil
            
            // Find an existing achievement.
            achievement = achievements?.first(where: { $0.identifier == achievementID})
            
            // Otherwise, create a new achievement.
            if achievement == nil {
                achievement = GKAchievement(identifier: achievementID)
            }
            
            // Insert code to report the percentage.
            
            if error != nil {
                // Handle the error that occurs.
                print("Error: \(String(describing: error))")
            }
            */
        })
    }
    
    func accomplishmentsLoop() {
        
        // Station
        let station = LocalDatabase.shared.station
        
        let peripherals = station.peripherals
        let beginPeripherals = 3
        let builtPeripherals:Int = peripherals.count - beginPeripherals
        print("Player has built \(builtPeripherals) peripherals")
        
        // Recipes:
        // 1. Scrubber
        // 2. Water Filter
        // 3. Methanizer
        // 4. Condensator
        if station.unlockedRecipes.contains(.ScrubberCO2) {
            print("Has made first scrubber")
        }
        if station.unlockedRecipes.contains(.WaterFilter) {
            print("Has made first Water Filter")
        }
        if station.unlockedRecipes.contains(.Methanizer) {
            print("Has made first methanizer")
        }
        if station.unlockedRecipes.contains(.Condensator) {
            print("Has made first condensator")
        }
        
        // Tech
        // 1. Garage
        if station.unlockedTechItems.contains(.garage) {
            print("Has made garage")
        }
        // 2. Methanizer
        if station.unlockedTechItems.contains(.recipeMethane) {
            print("Has made methanizer")
        }
        // 3. Ma Antenna
        if station.unlockedTechItems.contains(.AU1) && station.unlockedTechItems.contains(.AU2) && station.unlockedTechItems.contains(.AU3) && station.unlockedTechItems.contains(.AU4) {
            print("Has upgraded antenna 4 times")
        }
        // 4. Roboarm
        if station.unlockedTechItems.contains(.Roboarm) {
            print("Has made roboarm")
        }
        // 5. Cuppola
        if station.unlockedTechItems.contains(.Cuppola) {
            print("Has made cuppola")
        }
        // 6. BioSolids
        if station.unlockedTechItems.contains(.recipeBioSolidifier) {
            print("Has made bio solidifier tech")
        }
        // 7. Airlock
        if station.unlockedTechItems.contains(.Airlock) {
            print("Has made airlock")
        }
        // 8. Finished Tech
        if station.unlockedTechItems.count == TechItems.allCases.count {
            print("Has finished all station tech!")
        }
        
        // Mars (City)
        
        // Tech:
        // 1. Max Hab
        // 2. Max Bio
        // 3.
        
        // Mars (Guild)
        
        // 1. Missions
        
    }
}
