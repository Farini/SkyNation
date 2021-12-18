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
    
    /*
        get local player
        check restrictions
        post score (experience)
        assign gcid?
     */
    
    private init() {
        // Get local player
        
        // Game Center
        GKLocalPlayer.local.authenticateHandler = { viewController, error in
            
            if let viewController = viewController {
                // Present the view controller so the player can sign in.
                print("View Controller \(viewController)")
                
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
            
//            self.postPlayerExperience()
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
    
    func postPlayerExperience() {
        
        // Make sure player objects are here, and authenticated
        guard let gcPlayer:GKLocalPlayer = gcPlayer, gcPlayer.isAuthenticated == true else {
            print("\n\n Player not authenticated in GameCenter")
            return }
        let gPlayer:SKNPlayer = LocalDatabase.shared.player
        
        // Make sure experience is more than 1
        guard gPlayer.experience > 1 else {
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
}
