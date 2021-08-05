//
//  GameSettingsController.swift
//  SkyNation
//
//  Created by Carlos Farini on 2/22/21.
//

import Foundation

// MARK: - Controller

class GameSettingsController:ObservableObject {
    
    @Published var viewState:GameSettingsTab
    
    @Published var player:SKNPlayer
    @Published var playerName:String {
        didSet {
            if player.name != playerName {
                self.hasChanges = true
            }
        }
    }
    @Published var hasChanges:Bool
    @Published var playerID:UUID
    @Published var isNewPlayer:Bool
    @Published var savedChanges:Bool
    
    @Published var user:SKNPlayer?
    @Published var guild:Guild?
    
    // Guild Selection
    @Published var joinableGuilds:[GuildSummary] = []
    @Published var selectedGuildSum:GuildSummary?
    @Published var selectedGuildObj:GuildFullContent?
    
    @Published var fetchedString:String?
    
    /// A list of things to load
    @Published var loadedList:[String] = []
    
    @Published var stationSceneLoaded:Bool = false
    
    init() {
        
        // Player
        if let player = LocalDatabase.shared.player {
            isNewPlayer = false
            self.player = player
            playerID = player.localID
            playerName = player.name
            hasChanges = false
            savedChanges = true
//            user = SKNUserPost(player: player)
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
        
        self.updateLoadedList()
    }
    
    func updateLoadedList() {
        var items:[String] = []
        if let player = LocalDatabase.shared.player {
            items.append("★ Loaded Player \(player.name)")
            if let pid = player.serverID {
                items.append("L-PID \(pid.uuidString)")
            }
            if let gid = player.guildID {
                items.append("L-GID \(gid.uuidString.prefix(8))")
            }
            if let cid = player.cityID {
                items.append("L-CID \(cid.uuidString.prefix(8))")
            }
            
            // Scene Loaded
            if stationSceneLoaded {
                items.append("★ Station loaded: \(stationSceneLoaded)")
            } else {
                items.append("Loading station")
            }
            
            // Server Data Loaded
            if let user = user {
                if let pid = user.serverID {
                    items.append("U-PID \(pid.uuidString)")
                } else {
                    items.append("< No server ID >")
                }
//                if let gid = user.guildID {
//                    items.append("U-GID \(gid.uuidString)")
//                } else {
//                    items.append("< No Guild ID >")
//                }
//                if let cid = user.cityID {
//                    items.append("U-CID \(cid.uuidString)")
//                } else {
//                    items.append("< No City ID >")
//                }
            } else {
                items.append("User not connected")
            }
            
        }
        self.loadedList = items
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
        self.player.name = playerName
        
        if LocalDatabase.shared.savePlayer(player: player) {
            savedChanges = true
            hasChanges = false
        }
        
        self.viewState = .EditingPlayer
    }
    
    // MARK: - Server Tab
    
    func fetchUser() {
        
//        guard let user = user else {
//            print("No user")
//            return
//        }
        
//        let decoder = JSONDecoder()
//        decoder.dateDecodingStrategy = .secondsSince1970
        
        ServerManager.shared.inquireLogin { player, error in
            DispatchQueue.main.async {
                if let player = player {
                    self.user = player
                } else {
                    print("Did not find user. \(error?.localizedDescription ?? "")")
                }
            }
        }
        
    }
    
    func createGuild() {
//        guard let user = user else {
//            print("No user")
//            return
//        }
//
//        let decoder = JSONDecoder()
//        decoder.dateDecodingStrategy = .secondsSince1970
//
////        SKNS.createGuild(localPlayer: user, guildName: "Test Guild") { (data, error) in
////            if let data = data, let guild = try? decoder.decode(Guild.self, from: data) {
////                print("We got a Guild: \(guild.name)")
////                self.guild = guild
////            } else {
////                print("Failed creating guild. Reason: \(error?.localizedDescription ?? "n/a")")
////            }
////        }
    }
    
    func fetchGuilds() {
//        news = "Fetching Guilds..."
        SKNS.browseGuilds { (guilds, error) in
            if let array = guilds {
                print("Updating Guilds \(array.count)")
                self.joinableGuilds = array
//                self.highlightedGuild = array.first
//                self.news = "Here are the guilds"
            } else {
                if let error = error {
                    print("Error: \(error.localizedDescription)")
//                    self.news = error.localizedDescription
                } else {
//                    self.news = "Something else happened. Not an error, but no Guilds"
                    print("Something else happened. Not an error, but no Guilds")
                }
            }
            
        }
    }
    
    func joinGuild(sum:GuildSummary) {
        
        guard player.guildID == nil else {
            print("Error: Player already has a guild")
            return
        }
        
        SKNS.joinGuildPetition(guildID: sum.id) { (newGuildSum, error) in
            if let newGuild = newGuildSum {
                print("Player joined new guild! Success.")
                self.player.guildID = newGuild.id
                DispatchQueue.main.async {
                    let save = LocalDatabase.shared.savePlayer(player: self.player)
                    print("Saved Player: \(save)")
                }
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
            DispatchQueue(label: "Accounting").async {
                station.accountingLoop(recursive: true) { comments in
                    for comment in comments {
                        print("COMMENTS: \(comment)")
                    }
                    DispatchQueue.main.async {
                        builder.prepareScene(station: station) { loadedScene in
                            builder.scene = loadedScene
                            LocalDatabase.shared.saveStation(station: station)
                            self.stationSceneLoaded = true
                            self.updateLoadedList()
                            self.loadServerData()
                            LocalDatabase.shared.saveStation(station: station)
                            if let player = LocalDatabase.shared.player {
                                let pres = LocalDatabase.shared.savePlayer(player: player)
                                print("Station saved. Player: \(pres)")
                            }
                            print("⚠️ Are we finally ready? 🏆")
                            print("Enable buttons now ???")
                        }
                    }
                }
            }
        }
    }
    
    func loadServerData() {
        
        ServerManager.shared.inquireLogin { player, error in
            DispatchQueue.main.async {
                if let player = player {
                    print("Player login: ID:\(player.id.uuidString), LID: \(player.localID), SID: \(player.serverID?.uuidString ?? "< No server ID >")")
                    self.user = player
                    self.updateLoadedList()
                } else {
                    print("Did not find user. \(error?.localizedDescription ?? "")")
                }
            }
        }
        
    }
    
}
