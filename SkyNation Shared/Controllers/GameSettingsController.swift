//
//  GameSettingsController.swift
//  SkyNation
//
//  Created by Carlos Farini on 2/22/21.
//

import Foundation

// MARK: - Controller

class GameSettingsController:ObservableObject {
    
    @Published var viewState:GameSettingsTab // = .Loading
    
    @Published var player:SKNPlayer
    @Published var playerName:String {
        didSet {
            if player.name != playerName {
                self.hasChanges = true
            }
        }
    }
    
    @Published var user:SKNUser?
    @Published var guild:Guild?
    
    @Published var playerID:UUID
    @Published var isNewPlayer:Bool
    @Published var savedChanges:Bool
    @Published var hasChanges:Bool
    
    @Published var fetchedString:String?
    
    init() {
        
        // Player
        if let player = LocalDatabase.shared.player {
            isNewPlayer = false
            self.player = player
            playerID = player.localID
            playerName = player.name
            hasChanges = false
            savedChanges = true
            user = SKNUser(player: player)
            viewState = GameSettingsTab.Loading
        } else {
            let newPlayer = SKNPlayer()
            self.player = newPlayer
            playerName = newPlayer.name
            playerID = newPlayer.localID
            isNewPlayer = true
            hasChanges = true
            savedChanges = false
            viewState = GameSettingsTab.EditingPlayer
        }
    }
    
    /// Creates a player **Locally**
    func createPlayer() {
        player.name = playerName
        if LocalDatabase.shared.savePlayer(player: player) {
            savedChanges = true
            hasChanges = false
        }
    }
    
    func savePlayer() {
        player.name = playerName
        if LocalDatabase.shared.savePlayer(player: player) {
            savedChanges = true
            hasChanges = false
        }
    }
    
    /// Choosing Avatar
    func didSelectAvatar(card:AvatarCard) {
        self.player.avatar = card.name
        
        if LocalDatabase.shared.savePlayer(player: player) {
            savedChanges = true
            hasChanges = false
        }
        self.viewState = .EditingPlayer
    }
    
    func requestInfo() {
        SKNS.getSimpleData { (data, error) in
            if let data = data {
                print("We got data: \(data.count)")
                if let string = String(data: data, encoding: .utf8) {
                    self.fetchedString = string
                    return
                }
                let decoder = JSONDecoder()
                if let a = try? decoder.decode([SKNUser].self, from: data) {
                    self.fetchedString = "Users CT: \(a.count)"
                } else {
                    self.fetchedString = "Somthing else happened"
                }
            } else {
                print("Could not get data. Reason: \(error?.localizedDescription ?? "n/a")")
            }
        }
    }
    
    func fetchUser() {
        
        guard let user = user else {
            print("No user")
            return
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        
        SKNS.fetchPlayer(id: self.player.id) { (sknUser, error) in
            if let user = sknUser {
                print("Found user: \(user.id)")
                self.user = user
            } else {
                // Create
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                    return
                } else {
                    print("No User. Creating...")
                    SKNS.createPlayer(localPlayer: user) { (data, error) in
                        if let data = data, let newUser = try? decoder.decode(SKNUser.self, from: data) {
                            print("We got a new user !!!")
                            self.user = newUser
                        }
                    }
                }
            }
        }
    }
    
    func createGuild() {
        guard let user = user else {
            print("No user")
            return
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        
        SKNS.createGuild(localPlayer: user, guildName: "Test Guild") { (data, error) in
            if let data = data, let guild = try? decoder.decode(Guild.self, from: data) {
                print("We got a Guild: \(guild.name)")
                self.guild = guild
            } else {
                print("Failed creating guild. Reason: \(error?.localizedDescription ?? "n/a")")
            }
        }
    }
    
    // MARK: - Game Start
    
    /// Disabled state for the `StartGame` button
    func startGameDisabled() -> Bool {
        
        if isNewPlayer {
            print("New player. make sure to setup first")
            if hasChanges {
                print("Save Changes first")
            }
            if savedChanges {
                print("Changes are saved")
                return false
            }
            return true
            
        } else {
            return false
        }
    }
    
    func loadGameData() {
        let builder = LocalDatabase.shared.stationBuilder
        if let station = LocalDatabase.shared.station {
//            let accountingLoops = station.accountingTimeSheet()
            DispatchQueue(label: "Accounting").async {
                station.accountingLoop(recursive: true) { comments in
                    for comment in comments {
                        print("COMMENTS: \(comment)")
                    }
                    DispatchQueue.main.async {
                        builder.prepareScene(station: station) { loadedScene in
                            builder.scene = loadedScene
                            LocalDatabase.shared.saveStation(station: station)
                            print("⚠️ Are we finally ready? 🏆")
                            print("Enable buttons now ???")
                        }
                    }
                }
            }
            
//            builder.build(station:station)
        }
    }
    
}
