//
//  FrontController.swift
//  SkyNation
//
//  Created by Carlos Farini on 1/26/22.
//

import Foundation
import SceneKit

class FrontController:ObservableObject {
    
    @Published var player:SKNPlayer
    @Published var playerName:String
    @Published var isNewPlayer:Bool
    
    @Published var guildMAp:GuildMap?
    @Published var playerGuildState:PlayerGuildState
    
    @Published var stationScene:SCNScene?
    @Published var playerLoggedIn:PlayerUpdate?
    
    @Published var warningList:[String] = []
    @Published var loadedList:[String] = []
    
    init() {
        
        let gPlayer = LocalDatabase.shared.player
        self.player = gPlayer //LocalDatabase.shared.player
        self.playerName = gPlayer.name
        
        var shouldLogin:Bool = false
        
        // Check if new Player
        if gPlayer.isNewPlayer() == true {
            isNewPlayer = true
            self.playerGuildState = .noEntry
            
        } else {
            // Old Player
            isNewPlayer = false
            shouldLogin = true
        }
        
        // CityAccounting
        if let myCity:CityData = LocalDatabase.shared.cityData {
            DispatchQueue.global(qos: .background).async {
                myCity.accountingLoop(recursive: true) { messages in
                    print("Mars Accounting Finished: \(messages.joined(separator: " ,"))")
                }
            }
        }
        
        let manager = ServerManager.shared
        if let serverData = manager.serverData,
           let guildMap = serverData.guildMap,
           gPlayer.guildID == guildMap.id {
            
            self.playerGuildState = .joined(guild: guildMap)
            // Should login
            
        } else {
            if gPlayer.marsEntryPass().result == true {
                self.playerGuildState = .noGuild
            } else {
                self.playerGuildState = .noEntry
            }
        }
        
        if shouldLogin == true {
            self.playerLogin()
        } else {
            // ----------
            // Important
            //
            // Must put the view state into "Editing"
            // ----------
        }
    }
    
    // Player Actions
    
    /// Recursively checks Player login status with `ServerManager`
    func playerLogin(attempts:Int = 0) {
        
        if attempts > 3 { return }
        print("Getting Server Status. Repeated \(attempts) times.")
        
        let manager = ServerManager.shared
        
        switch manager.loginStatus {
            case .playerAuthorized(let playerUpdate):
                
                DispatchQueue.main.async {
                    self.playerLoggedIn = playerUpdate
                    self.loadedList.append("🎮 Player \(playerUpdate.name) is in.")
                    print("🎮 Authorized Player \(playerUpdate.name)")
                    if let scene = self.stationScene,
                       GameSettings.shared.autoStartScene == true {
                        self.startGame(scene: scene)
                    }
                }
                return
                
                
            case .serverError(let originReason, let error, _):
                let uistring = "ERROR: \(originReason), \(error?.localizedDescription ?? "")"
                self.warningList.append(uistring)
                print(uistring)
                
            case .notStarted:
                print("SERVER DATA NOT STARTED AFTER 3 SECONDS")
                DispatchQueue.init(label: "login wait").asyncAfter(deadline: .now() + 3.0) { [weak self] in
                    if let self = self {
                        self.playerLogin(attempts: attempts + 1)
                        self.loadedList.append("🏁 False start \(attempts)")
                        print("🏁 False start \(attempts)")
                    } else {
                        return
                    }
                }
                
            case .createdPlayerWaitingAuth(let newPlayer):
                print("Waiting for Server to Finish login for \(newPlayer.name)")
                DispatchQueue.init(label: "login wait").asyncAfter(deadline: .now() + 3.0) { [weak self] in
                    if let self = self {
                        self.playerLogin(attempts: attempts + 1)
                    } else {
                        return
                    }
                }
            case .playerUnauthorized(let player):
                print("‼️ Player Unauthorized ‼️ \(player.name)")
                self.warningList.append("ERROR: ‼️ Player Unauthorized ‼️")
                if attempts > 2 {
                    // create another player
                    manager.relogin(with: player, forceCreate: true)
                }
            case .simulatingData(let serverData):
                print("Simulating Data for player: \(serverData.player.name)")
        }
        
    }
    
    /// Now the Player edits first, and then login, avoiding the name "Test Player"
    func didEditPlayer(new name:String, avatar:AvatarCard, completion:((PlayerUpdate?, Error?) -> ())?) {
        
        let player = self.player
        player.name = name
        player.avatar = avatar.name
        
        // Save Locally
        guard ((try? LocalDatabase.shared.savePlayer(player)) != nil) else {
            completion?(nil, LocalDatabaseError.noFile)
            return
        }
        
        // Update Server
        let manager = ServerManager.shared
        if manager.loginStatus.isWaitingLoad == true {
            DispatchQueue.init(label: "login wait").asyncAfter(deadline: .now() + 1.5) {
                self.playerLogin(attempts: 0)
            }
        } else {
            manager.relogin(with: player, forceCreate: false)
            DispatchQueue.init(label: "login wait").asyncAfter(deadline: .now() + 1.5) {
                self.playerLogin(attempts: 0)
            }
        }

    }
    
    // MARK: - Game Start
    
    /// Runs Accounting, and loads the Station Scene
    func loadGameData() {
        
        let builder = LocalDatabase.shared.stationBuilder
        let station = LocalDatabase.shared.station
        
        DispatchQueue(label: "StationAccounting").async {
            station.accountingLoop(recursive: true) { comments in
                for comment in comments {
                    print("COMMENTS: \(comment)")
                }
            }
        }
        
        DispatchQueue(label:"StationBuilder").async {
            
            builder.prepareScene(station: station) { loadedScene in
                
                builder.scene = loadedScene
                
                DispatchQueue.main.async {
                    self.stationScene = loadedScene
                    self.loadedList.append("🎬 Space Station is loaded.")
                    print("🎬 Game Scene loaded")
                    if let pup = self.playerLoggedIn,
                    GameSettings.shared.autoStartScene == true {
                        
                        print("Player \(pup.name) logged in. Auto staring.")
                        self.startGame(scene: loadedScene)
                    }
                }
            }
        }
        
    }
    
    func startGame(scene:SCNScene) {
        
        // Check if new player
        if self.isNewPlayer == true || self.player.isNewPlayer() == true {
            // needs to run tutorial
            
        } else {
            
        }
    }
    
    
}
