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
    
    var imageName:String {
        switch self {
            case .Loading: return "opticaldisc"
            case .EditingPlayer: return "person"
            case .Server: return "shield"
            case .Settings: return "gearshape"
        }
    }
}

/// A state to display about the status of the `Player` in relation to `Guild`
enum GuildJoinState {
    
    /// Loading data from server
    case loading    // OPT: none
    
    /// Player does NOT have an .Entry token
    case noEntry    // OPT: none
    
    /// Player has no GuildID
    case noGuild    // OPT: Browse, Create
    
    /// Joined
    case joined(guild:GuildFullContent) // OPT: Leave Guild
    
    /// Player been kicked
    case kickedOut  // OPT: Browse, Create
    
    /// Selecting which Guild to Join
    case choosing   // OPT: Join, Create
    
    case leaving    // OPT: none
    
    case creating
    
    case error(error:Error) // OPT: try again?
    
    var message:String {
        switch self {
            case .loading: return "Loading..."
            case .noGuild: return "You haven't joined a Guild. Choose one to join."
            case .joined(let guild): return "Your Guild.: \(guild.name)"
            case .choosing: return "Choose a Guild"
            case .kickedOut: return "Oh no! It seems you were kicked out, or Guild does not exist anymore."
            case .noEntry: return "You need an Entry Token to join a Guild"
            case .leaving: return "Leaving Guild"
            case .creating: return "Creating Guild"
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
            if playerName.count > 12 {
                playerName = String(playerName.prefix(12))
            }
            if player.name != playerName {
                self.hasChanges = true
            }
        }
    }
    
    // Local DB + Player begins
    @Published var hasChanges:Bool
    @Published var playerID:UUID
    @Published var isNewPlayer:Bool
    @Published var savedChanges:Bool
    @Published var stationSceneLoaded:Bool = false
    
    /// MARK: - Online Data
    
    /// Keep track of updated player (login)
    @Published var updatedPlayer:PlayerUpdate?
    
    // Guild Selection (Choosing)
    @Published var guildJoinState:GuildJoinState = .loading
    @Published var joinableGuilds:[GuildSummary] = []
    @Published var selectedGuildObj:GuildFullContent?
    private var otherFetchedGuilds:[GuildFullContent] = []
    
    /// The Guild this player has joined.
    @Published var myGuild:GuildFullContent?
    
    /// A list of things that are loaded
    @Published var loadedList:[String] = []
    
    /// A list of errors to display
    @Published var warningList:[String] = []
    
    // MARK: - Methods
    
    init() {
        
        // Player
        let player = LocalDatabase.shared.player
        self.player = player
        
        if player.name == "Test Player" && player.experience == 0 && abs(Date().timeIntervalSince(player.beganGame)) < 10 {
            // New Player
            playerName = player.name
            playerID = player.localID
            isNewPlayer = true
            hasChanges = true
            savedChanges = false
            viewState = GameSettingsTab.EditingPlayer
            
        } else {
            // Old Player
            isNewPlayer = false
            self.player = player
            playerID = player.localID
            playerName = player.name
            hasChanges = false
            savedChanges = true
            viewState = GameSettingsTab.Loading
            
        }
        
        self.updateLoadedList()
        
        // Accounting
        if let myCity:CityData = LocalDatabase.shared.cityData {
            DispatchQueue(label: "Accounting").async {
                myCity.accountingLoop(recursive: true) { messages in
                    print("Mars Accounting Finished: \(messages.joined(separator: " ,"))")
                }
            }
        }
    }
    
    /// Updates the front list showing the loading status of Data
    func updateLoadedList() {
        
        var items:[String] = []
        
        if GameSettings.onlineStatus == true {
            
            let player = LocalDatabase.shared.player
            
            items.append("★ Loaded Player \(player.name)")
            
            if let pid = player.serverID {
                
                items.append("Player ID: \(pid.uuidString)")
                
                if let gid = player.guildID {
                    items.append("Guild ID: \(gid.uuidString.prefix(8))")
                }
                
                if let cid = player.cityID {
                    items.append("City ID:  \(cid.uuidString.prefix(8))")
                }
            }
            
            // Scene Loaded
            if stationSceneLoaded {
                items.append("★ Station loaded: \(stationSceneLoaded)")
            } else {
                items.append("Loading station")
            }
            
            // Make sure we are online (above)
            let manager = ServerManager.shared
            print("Server Manager Starting. Logged in: \(manager.playerLogged)")
            
        } else {
            items.append("🚫 Offline Mode")
        }
        
        self.loadedList = items
    }
    
    /// TABS - Called when Player selects a different tab.
    func didSelectTab(newTab:GameSettingsTab) {
        print("Did select tab !!!")
        switch newTab {
            case .Server:
                print("Selected Server")
                self.viewState = .Server
                self.enterServerTab()
            case .EditingPlayer:
                print("Selected `Player` \(self.viewState)")
                self.viewState = .EditingPlayer
            case .Settings:
                print("Selected `Settings` \(self.viewState)")
                self.viewState = .Settings
            case .Loading:
                print("Back to Loading \(self.viewState)")
                self.viewState = .Loading
        }
    }
    
    // MARK: - Player Editing
    
    /// Saving Player
    func savePlayer() {
        player.name = playerName
        do {
            try LocalDatabase.shared.savePlayer(player)
        } catch {
            print("Error saving Player.: \(error.localizedDescription)")
        }
        self.hasChanges = false
        self.savedChanges = true
        self.updateLoadedList()
    }
    
    /// Choosing Avatar
    func didSelectAvatar(card:AvatarCard) {
        
        self.player.avatar = card.name
        self.savePlayer()
        
        self.viewState = .EditingPlayer
    }
    
    // MARK: - Guild Tab + Online
    
    func updateServerWith(player:SKNPlayer) {
        
        self.warningList = []
        
        SKNS.updatePlayer { pUpdate, error in
            if let pUpdate = pUpdate {
                self.updatedPlayer = pUpdate
                
            } else {
                // Deal with Error
                if let error = error {
                    self.warningList.append(error.localizedDescription)
                }
            }
        }
    }
    
    /// Entering Server Tab - Fetch Player's Guild, (or list), and Player status
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
        
        // Player has entry
        
        
        // Server Tab stuff
        if let gid = player.guildID {
            
            print("Player GuildID: \(gid)")
            
            // Avoid loading Guild multiple times.
            if GameSettings.onlineStatus == false { return }
            if let myGuild = myGuild {
                print("Already got my Guild.: \(myGuild.name) Returning")
                return
            }
            
            self.fetchMyGuild()
            
        } else {
            // No Guild
            self.guildJoinState = .noGuild
            self.fetchGuilds()
        }
    }
    
    /// Gets My Guild and update guildJoinState
    func fetchMyGuild() {
        
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
    }
    
    /// Fetches all `Joinable` Guilds
    func fetchGuilds() {
        
        
        SKNS.browseInvitesFromGuilds { guildArray, error in
            if let guildArray = guildArray {
                DispatchQueue.main.async {
                    self.joinableGuilds.append(contentsOf: guildArray)
                }
            }
        }
        
        SKNS.browseGuilds { (guilds, error) in
            if let array = guilds {
                print("Updating Guilds")
                DispatchQueue.main.async {
                    self.joinableGuilds.append(contentsOf: array)
                }
                self.loadedList.append("Fetched \(array.count) Guilds")
            } else {
                if let error = error {
                    self.warningList.append(error.localizedDescription)
                } else {
                    self.warningList.append("Something else happened. Not an error, but no Guilds")
                    print("Something else happened. Not an error, but no Guilds")
                }
            }
        }
    }
    
    func startCreatingGuild() {
        self.guildJoinState = .creating
    }
    
    func didCreateGuild(guildCreate:GuildCreate) {
        
        self.joinableGuilds = []
        self.otherFetchedGuilds = []
        
        // Create Guild. If server doesn't respond,
        // we need to give player back their token
        SKNS.createGuild(creator: guildCreate) { guildSum, error in
            if let guildSum = guildSum {
                print("\n\nGuild Sum In \(guildSum)")
                SKNS.postCreate(newGuildID: guildSum.id) { newGuild, newError in
                    print("Post Creating...")
                    if let newGuild:GuildFullContent = newGuild {
                        print("Post Create. New Guild \(newGuild.name)")
                        DispatchQueue.main.async {
                            // Player created guild!
                            self.player.guildID = newGuild.id
                            self.guildJoinState = .joined(guild: newGuild)
                            self.selectedGuildObj = newGuild
                            print("Post Created Guild.")
                            // Save Player
                            do {
                                try LocalDatabase.shared.savePlayer(self.player)
                            } catch {
                                print("Could not save Player \(error.localizedDescription)")
                            }
                        }
                    } else {
                        print("Could not create guild (2nd). Returning token?")
                        DispatchQueue.main.async {
                            self.player.wallet.tokens.append(GameToken(beginner: UUID()))
                            self.guildJoinState = .choosing
                            self.fetchGuilds()
                        }
                    }
                }
            } else {
                print("Could not create guild (1st). Returning token?")
                DispatchQueue.main.async {
                    self.player.wallet.tokens.append(GameToken(beginner: UUID()))
                    self.guildJoinState = .choosing
                    self.fetchGuilds()
                }
            }
            
        }
    }
    
    func leaveGuild() {
        
        guard let oldGuildID = self.player.guildID else {
            print("No guild to leave")
            return
        }
        print("Player leaving guild ID:\(oldGuildID)")
        
        SKNS.leaveGuild { playerContent, error in
            if let playerContent = playerContent {
                print("New Player content after leaving: \(playerContent)")
                DispatchQueue.main.async {
                    self.player.guildID = nil
                    do {
                        try LocalDatabase.shared.savePlayer(self.player)
                        self.guildJoinState = .noGuild
                    } catch {
                        print("Error: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    /// Gets one Guild's Details to display for user (Choosing Guild)
    func fetchGuildDetails(guildSum:GuildSummary) {
        
        if let fetched:GuildFullContent = otherFetchedGuilds.first(where: { $0.id == guildSum.id }) {
            
            self.selectedGuildObj = fetched
            return
            
        } else {
            SKNS.fetchGuildDetails(gid: guildSum.id) { fullGuild, error in
                if let fullGuild = fullGuild {
                    DispatchQueue.main.async {
                        self.selectedGuildObj = fullGuild
                        self.otherFetchedGuilds.append(fullGuild)
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
                        
                        do {
                            try LocalDatabase.shared.savePlayer(self.player)
                        } catch {
                            print("Error saving Player.: \(error.localizedDescription)")
                        }
                        // print("Saved Player: \(save)")
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
    
    /// Runs Accounting, and loads the Station Scene
    func loadGameData() {
        
        let builder = LocalDatabase.shared.stationBuilder
        let station = LocalDatabase.shared.station
        
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
                        
                        do {
                            try LocalDatabase.shared.saveStation(station)
                        } catch {
                            print("Error saving Player.: \(error.localizedDescription)")
                        }
                        
                        print("⚠️ Game Data Loaded 🏆")
                    }
                }
            }
        }
    }
    
    /// Checks ServerManager for status - It takes a while to happen, so we can check on server status, because there it takes a while as well.
    func checkServerStatus(attempts:Int = 0) {
        
        if attempts > 3 { return }
        print("Getting Server Status. Repeated \(attempts) times.")

        let manager = ServerManager.shared
        
        switch manager.loginStatus {
            case .playerAuthorized(let playerUpdate):
                self.loadedList.append("Player \(playerUpdate.name) logged in.")
                self.updatedPlayer = playerUpdate
                print("🎮 Authorized Player \(player.name)")
                self.loadedList.append("🎮 \(player.name) - Ready.")
                if self.hasChanges == false && self.savedChanges == true && GameSettings.shared.autoStartScene == true {
                    self.startGame()
                }
            case .serverError(let originReason, let error, _):
                self.loadedList.append("ERROR: \(originReason), \(error?.localizedDescription ?? "Try again?")")
                self.warningList.append("ERROR: \(originReason), \(error?.localizedDescription ?? "Try again?")")
                
            case .notStarted:
                print("SERVER DATA NOT STARTED AFTER 3 SECONDS")
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
                    if let self = self {
                        self.checkServerStatus(attempts: attempts + 1)
                    } else {
                        return
                    }
                }
            case .createdPlayerWaitingAuth(let newPlayer):
                print("Waiting for Server to Finish login for \(newPlayer.name)")
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                    if let self = self {
                        self.checkServerStatus(attempts: attempts + 1)
                    } else {
                        return
                    }
                }
            case .playerUnauthorized(let player):
                print("‼️ Player Unauthorized ‼️ \(player.name)")
                self.warningList.append("ERROR: ‼️ Player Unauthorized ‼️")
                
            case .simulatingData(let serverData):
                print("Simulating Data for player: \(serverData.player.name)")
        }
    }
    
    /// Action from Button `Start Game`
    func startGame() {
        let note = Notification(name: .startGame)
        NotificationCenter.default.post(note)
    }
    
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
}
