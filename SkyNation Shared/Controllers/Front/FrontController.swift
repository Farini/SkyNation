//
//  FrontController.swift
//  SkyNation
//
//  Created by Carlos Farini on 1/26/22.
//

import Foundation
import SceneKit

// MARK: - Avatar

class AvatarCard: Identifiable, Equatable {
    
    var id:UUID = UUID()
    var name:String
    var selected:Bool
    
    init(name:String) {
        self.id = UUID()
        self.selected = false
        self.name = name
    }
    
    static func == (lhs: AvatarCard, rhs: AvatarCard) -> Bool {
        return lhs.id == rhs.id
    }
}

class FrontController:ObservableObject {
    
    @Published var player:SKNPlayer
    @Published var playerName:String
    @Published var isNewPlayer:Bool
    
    @Published var guildMap:GuildMap?
    @Published var playerGuildState:PlayerGuildState
    
    @Published var stationScene:SCNScene?
    @Published var playerLoggedIn:PlayerUpdate?
    
    @Published var warningList:[String] = []
    @Published var loadedList:[String] = []
    
    /// Pass false here to not login. It won't load the scene either.
    init(simulating login:Bool = true, newPlayer:Bool = false) {
        
        let gPlayer = LocalDatabase.shared.player
        self.player = gPlayer //LocalDatabase.shared.player
        self.playerName = gPlayer.name
        
        var shouldLogin:Bool = false
        
        // Check if new Player
        if gPlayer.isNewPlayer() == true {
            isNewPlayer = true
            self.playerGuildState = .noEntry
            shouldLogin = false
        } else {
            // Old Player
            isNewPlayer = false
            shouldLogin = true
        }
        
        // --- Simulating options ---
        // 1. New Player
        if newPlayer == true {
            self.isNewPlayer = true
        }
        // 2. Option to not login every time
        if login == false {
            self.playerGuildState = .noEntry
            return
        }
        // --- --- ---
        
        // Login Status
        let manager = ServerManager.shared
        if let serverData = manager.serverData,
           let guildMap = serverData.guildMap,
           gPlayer.guildID == guildMap.id {
            
            self.playerGuildState = .joined(guild: guildMap)
            // Should login
            
        } else {
            if gPlayer.marsEntryPass().result == true {
                // pass, no guild
                self.playerGuildState = .noGuild
            } else {
                // no pass
                self.playerGuildState = .noEntry
            }
        }
        
        if shouldLogin == true {
            self.playerLogin()
        } else {
            /*
            // Important!
            // Must put the view state into "Editing"
            // It seems the interface is already doing that
            */
        }
        
        self.player.lastSeen = Date()
        
        // Game Data
        loadGameData()
        
        // City Accounting
        runCityAccounting()
    }
    
    /// Runs the `CityData` accounting on a background thread.
    func runCityAccounting() {
        
        if let myCity:CityData = LocalDatabase.shared.cityData {
            DispatchQueue.global(qos: .background).async {
                myCity.accountingLoop(recursive: true) { messages in
                    do {
                        try LocalDatabase.shared.saveCity(myCity)
                        print("Mars Accounting Finished: \(messages.joined(separator: " ,"))")
                    } catch {
                        print("Error in Mars accounting... \(error.localizedDescription)")
                    }
                }
            }
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
                self.warningList.append("ERROR: Player unauthorized ‼️")
                if attempts > 2 {
                    // create another player
                    manager.relogin(with: player, forceCreate: true)
                }
            case .simulatingData(let serverData):
                print("Simulating Data for player: \(serverData.player.name)")
        }
        
    }
    
    /// Now the Player edits first, and then login, avoiding the name "Test Player"
    func didEditPlayer(new name:String, avatar:String, completion:((PlayerUpdate?, Error?) -> ())?) {
        
        let player = self.player
        player.name = name
        player.avatar = avatar
        
        // Save Locally
        guard ((try? LocalDatabase.shared.savePlayer(player)) != nil) else {
            completion?(nil, LocalDatabaseError.noFile)
            return
        }
        
        // FIXME: Solve this
        
        if let pid = player.playerID,
           let pass = player.keyPass {
            
            print("Editing player ID:\(pid), \(pass)")
            
            // Updating
            // if fails to update, needs to create.
            SKNS.updatePlayer { pUpdate, error in
                if let pUpdate = pUpdate {
                    // save changes
                    DispatchQueue.main.async {
                        self.player.receiveUpdates(pupdate: pUpdate)
                    }
                } else {
                    // Deal with Error
                    if let error = error {
                        self.warningList.append(error.localizedDescription)
                        if let authError = error as? ServerDataError {
                            switch authError {
                                case .failedAuthorization, .notFound:
                                    // needs to create, or reset pass
                                    SKNS.requestNewPass { newPlayerUp, newError in
                                        if let newPlayerUp = newPlayerUp {
                                            self.player.receiveUpdates(pupdate: newPlayerUp)
                                        }
                                    }
                                default: self.warningList = ["Something is wrong."]
                            }
                        }
                    }
                }
            }
        } else {
            // Creating
            // after creating, needs to login again.
            SKNS.createNewPlayer(localPlayer: player) { pupdate, error in
                if let pupdate = pupdate {
                    DispatchQueue.main.async {
                        self.player.receiveUpdates(pupdate: pupdate)
                    }
                } else {
                    if let error = error {
                        DispatchQueue.main.async {
                            self.warningList = [error.localizedDescription]
                        }
                    }
                }
            }
        }
        /**
        Check if new player?
        Decide if we are creating a player, or updating one
        If we are creating, we need to circle back and login again.
        if we are updating, we can do one of the following:
            a. Use `ServerManager`
            b. Use `SKNS` directly
        */
        
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
    
    /// Takes the Player to the Game
    func startGame(scene:SCNScene) {
        
        
        let note = Notification(name: .startGame)
        NotificationCenter.default.post(note)
        
//        // Check if new player
//        if self.isNewPlayer == true || self.player.isNewPlayer() == true {
//
//            // needs to run tutorial
//
//             let note = Notification(name: .startGame)
//             NotificationCenter.default.post(note)
//
//        } else {
//
//        }
    }
    
}
