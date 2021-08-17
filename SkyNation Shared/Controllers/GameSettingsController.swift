//
//  GameSettingsController.swift
//  SkyNation
//
//  Created by Carlos Farini on 2/22/21.
//

import Foundation

/// The Main tab of the game (Shows up at the start)
enum GameSettingsTab: String, CaseIterable {
    
    case Loading            // Loading the scene (can be interrupted)
    case EditingPlayer      // Editing Player Attributes
    case Server             // Checking Server Info
    case Settings           // Going through GameSettings
    
    var tabString:String {
        switch self {
            case .Loading, .Server, .Settings: return self.rawValue
            case .EditingPlayer: return "Player"
        }
    }
}

/// A state to display about the status of the `Player` in relation to `Guild`
enum GuildJoinState {
    
    /// Loading data from server
    case loading
    
    /// Player has no Guild
    case noGuild
    
    /// Player does NOT have an .Entry token
    case noEntry
    
    /// Player been kicked
    case kickedOut
    
    case choosing // Player choosing Guild
    
    /// Joined
    case joined(guild:GuildFullContent)
    case leaving
    
    case error(error:Error)
    
    var message:String {
        switch self {
            case .loading: return "Loading..."
            case .noGuild: return "You haven't joined a Guild. Choose one to join."
            case .joined(let guild): return "Your Guild.: \(guild.name)"
            case .choosing: return "Choose a Guild"
            case .kickedOut: return "Oh no! It seems you were kicked out, or Guild does not exist anymore."
            case .noEntry: return "You need an Entry Token to join a Guild"
            case .leaving: return "Leaving Guild"
            case .error(let error): return "Error.: \(error.localizedDescription)"
        }
    }
    
    /// Whether should have a "Join" Button
    var joinButton:Bool {
        switch self {
            case .choosing: return true
            default: return false
        }
    }
    
    /// Whether should have a "Leave" button
    var leaveButton:Bool {
        switch self {
            case .joined(_): return true
            default:return false
        }
    }
}

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
    @Published var stationSceneLoaded:Bool = false
    
    // Guild Selection
    @Published var guildJoinState:GuildJoinState = .loading
    // [Not Joined] -> Fetch
    @Published var joinableGuilds:[GuildSummary] = []
    @Published var selectedGuildObj:GuildFullContent?
    @Published var allFetchedGuilds:[GuildFullContent] = []
    // [Joined] -> Reload?
    @Published var myGuild:GuildFullContent?
    
    // Others
    @Published var fetchedString:String?
    
    /// A list of things to load
    @Published var loadedList:[String] = []
    
    // MARK: - Methods
    
    init() {
        
        // Player
        if let player = LocalDatabase.shared.player {
            isNewPlayer = false
            self.player = player
            playerID = player.localID
            playerName = player.name
            hasChanges = false
            savedChanges = true
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
    
    /// Updates the front list showing the loading status of Data
    func updateLoadedList() {
        
        var items:[String] = []
        
        if GameSettings.onlineStatus == true {
            
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
            }
        } else {
            items.append("🚫 Offline Mode")
        }
        
        self.loadedList = items
    }
    
    /// Saving Player
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
    
    /// Called when Player selects a different tab.
    func didSelectTab(newTab:GameSettingsTab) {
        print("Did select tab !!!")
        switch newTab {
            case .Server:
                print("Selected Server")
                self.viewState = .Server
                self.enterServerTab()
            case .EditingPlayer:
                print("Selected `Player` \(self.viewState)")
            case .Settings:
                print("Selected `Settings` \(self.viewState)")
            case .Loading:
                print("Back to Loading \(self.viewState)")
        }
    }
    
    /// Entering Server Tab - Fetch Guild (if any), and Player status
    func enterServerTab() {
        
        print("Entering Server Tab. guildJoinState: \(self.guildJoinState)")
        
        // Check Entry
        var enter:Bool = false
        let entryResult = player.marsEntryPass()
        if entryResult.result == false {
            if let entryToken = entryResult.token {
                if let r2 = player.requestEntryToken(token: entryToken) {
                    print("Found an Entry ticket \(r2.date)")
                    enter = true
                }
            }
        } else {
            print("Entry OK: \(entryResult.token?.id.uuidString ?? "n/a")")
            enter = true
        }
        if !enter {
            self.guildJoinState = .noEntry
            return
        }
        
        // Server Tab stuff
        if let gid = player.guildID {
            
            print("Player GuildID: \(gid)")
            
            ServerManager.shared.inquireFullGuild(force: false) { fullGuild, error in
                
                if let guild:GuildFullContent = fullGuild {
                    
                    if guild.id == self.player.guildID {
                        // Same O' Guild
                        
                        if guild.citizens.compactMap({ $0.id }).contains(self.player.playerID ?? UUID()) {
                            
                            self.myGuild = guild
                            self.guildJoinState = .joined(guild: guild)
                            
                        } else {
                            
                            // Kicked Out?
                            self.myGuild = nil
                            self.player.guildID = nil
                            self.guildJoinState = .kickedOut
                            
                        }
                    } else {
                        
                        // Different Guild
                        self.myGuild = nil
                        self.player.guildID = nil
                        self.guildJoinState = .kickedOut
                        
                    }
                } else {
                    
                    // No Guild, or Error
                    if let error = error {
                        self.guildJoinState = .error(error: error)
                    } else {
                        self.guildJoinState = .noGuild
                    }
                    
                }
            }
        } else {
            // No Guild
            self.guildJoinState = .noGuild
            self.fetchGuilds()
        }
    }
    
    func createGuild() {
        
        // FIXME: - Needs Implementation
        
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
    
    /// Fetches all `Joinable` Guilds
    func fetchGuilds() {
        
        SKNS.browseGuilds { (guilds, error) in
            if let array = guilds {
                print("Updating Guilds \(array.count)")
                self.joinableGuilds = array
                self.guildJoinState = .choosing
            } else {
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                } else {
                    print("Something else happened. Not an error, but no Guilds")
                }
            }
        }
    }
    
    /// Gets one Guild's Details to display for user (Choosing Guild)
    func fetchGuildDetails(guildSum:GuildSummary) {
        
        if let fetched:GuildFullContent = allFetchedGuilds.first(where: { $0.id == guildSum.id }) {
            
            self.selectedGuildObj = fetched
            return
            
        } else {
            SKNS.fetchGuildDetails(gid: guildSum.id) { fullGuild, error in
                if let fullGuild = fullGuild {
                    DispatchQueue.main.async {
                        self.selectedGuildObj = fullGuild
                    }
                } else {
                    print("‼️ Could not get full Guild")
                }
            }
        }
    }
    
    /// Request to join a Guild
    func requestJoin(_ guild:GuildFullContent) {
        
        guard let playerID = self.player.playerID,
              let gfc:GuildFullContent = selectedGuildObj else { return }
        
        print("Requesting Guild Join...")
        
        SKNS.joinGuildPetition(guildID: guild.id) { (newGuildSum, error) in
            
            if let newGuild:GuildSummary = newGuildSum {
                
                let citizens = newGuild.citizens
                if citizens.contains(playerID) && gfc.id == newGuild.id {
                    
                    DispatchQueue.main.async {
                        // OK.
                        self.player.guildID = newGuild.id
                        self.guildJoinState = .joined(guild: gfc)
                        
                        let save = LocalDatabase.shared.savePlayer(player: self.player)
                        print("Saved Player: \(save)")
                    }
                    
                } else {
                    // Unable
                    print("⚠️ Unable to join. Try again slowly.")
                }
            } else {
                print("⚠️ Player could not join Guild. \(error?.localizedDescription ?? "")")
                if let error = error {
                    DispatchQueue.main.async {
                        self.guildJoinState = .error(error: error)
                    }
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
    
    /// Runs Accounting, and loads the Station Scene
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
                            self.stationSceneLoaded = true
                            self.updateLoadedList()
                            self.loadServerData()
                            LocalDatabase.shared.saveStation(station: station)
                            
//                            if let player = LocalDatabase.shared.player {
//                                let pres = LocalDatabase.shared.savePlayer(player: player)
//                                print("Station saved. Player: \(pres)")
//                            }
                            
                            print("⚠️ Game Data Loaded 🏆")
                        }
                    }
                }
            }
        }
    }
    
    /// Runs the Game's login
    func loadServerData() {
        
        ServerManager.shared.inquireLogin { player, error in
            
            DispatchQueue.main.async {
                if let player:PlayerUpdate = player {
                    print("Player Update Login: ID:\(player.id.uuidString), LID: \(player.localID)")
//                    self.user = player
                    self.updateLoadedList()
                } else {
                    print("Did not find user. \(error?.localizedDescription ?? "")")
                }
            }
        }
        
    }
    
}
