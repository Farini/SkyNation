//
//  GameSettingsController.swift
//  SkyNation
//
//  Created by Carlos Farini on 2/22/21.
//

import Foundation
import GameKit

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

/// The relationship of Player vs Guild
enum PlayerGuildState {
    case noEntry
    case noGuild
    case joined(guild:GuildMap)
}

enum GuildNavViewState {
    case loading
    case browsing
    case creating
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
    
    // MARK: - Online Data
    
    /// Keep track of updated player (login)
    @Published var updatedPlayer:PlayerUpdate?
    
    /// The `GuildMap` object of the Guild this player has joined.
    @Published var guildMap:GuildMap?
    
    // Guild Selection (Choosing)
    /// Indicates whether player can join guild, etc.
    @Published var playerGuildState:PlayerGuildState = .noEntry
    /// Array of Guilds that can be joined
    @Published var joinableGuilds:[GuildSummary] = []
    /// The *SELECTED* Guild from the array - (currently displaying)
    @Published var selectedGuildMap:GuildMap?
    /// Any errors in `GuildNavigator`should come up here
    @Published var guildNavError:String = ""
    
    private var otherFetchedGuilds:[GuildFullContent] = []
    private var otherGuildMaps:[GuildMap] = []
    
    // joinRequestsSent
    // notifications if got accepted?
    
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
        
        // Game Center
        let gcm = GameCenterManager.shared
        gcm.postPlayerExperience()

    }
    
    /// Way around logging in. Retrieve all data from LocalDatabase.
    init(previewing database:Bool) {
        
        // Player
        let player = LocalDatabase.shared.player
        self.player = player
        // Old Player
        isNewPlayer = false
        playerID = player.localID
        playerName = player.name
        hasChanges = false
        savedChanges = true
        viewState = GameSettingsTab.Loading
        
        // Accounting
        if let myCity:CityData = LocalDatabase.shared.cityData {
            DispatchQueue(label: "Accounting").async {
                myCity.accountingLoop(recursive: true) { messages in
                    print("Mars Accounting Finished: \(messages.joined(separator: " ,"))")
                }
            }
        }
        
        if let serverData = try? LocalDatabase.loadServerData() {
            if let gMap = serverData.guildMap {
                self.guildMap = gMap
                self.playerGuildState = .joined(guild: gMap)
//                self.myGuild = gfc
//                self.guildJoinState = .joined(guild: gfc)
            } else {
                self.playerGuildState = .noGuild
            }
        } else {
            self.playerGuildState = .noGuild
        }
    }
    
    /// Updates the front list showing the loading status of Data
    func updateLoadedList() {
        
        var items:[String] = []
        
        if GameSettings.onlineStatus == true {
            
            let player = LocalDatabase.shared.player
            
            items.append("★ Loaded Player \(player.name)")
            
            if let pid = player.playerID {
                
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
    
    // MARK: - Guild Tab + Online
    
    /// Entering Server Tab - Fetch Player's Guild, (or list), and Player status
    func enterServerTab() {
        
//        print("Entering Server Tab. guildJoinState: \(self.guildJoinState)")
        
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
            self.playerGuildState = .noEntry
            return
        }
        
        // Player has entry
        
        
        // Check if has guild
        if let gid = player.guildID {
            
            print("Player GuildID: \(gid)")
            
            // Avoid loading Guild multiple times.
            if GameSettings.onlineStatus == false { return }
            if let gMap = guildMap {
                print("Already got my Guild.: \(gMap.name) Returning")
                return
            }
            
            self.fetchMyGuildMap(force: false)
            
        } else {
            self.playerGuildState = .noGuild
            self.fetchGuilds()
        }
    }
    
    /// Gets the `GuildMap` that belongs to the player.
    /// - parameters:
    /// - force: a bool indicating whether should fetch data immediately
    func fetchMyGuildMap(force:Bool) {
        
        if force == false {
            if let oldGuildMap = ServerManager.shared.serverData?.guildMap {
                self.playerGuildState = .joined(guild: oldGuildMap)
                return
            }
        }
        
        ServerManager.shared.requestGuildMap(force: force, maxDelay: force == true ? 1:10) { gMap, error in
            if let gMap:GuildMap = gMap {
                DispatchQueue.main.async {
                    self.guildMap = gMap
                    
                    if gMap.citizens.compactMap({ $0.id }).contains(self.player.playerID ?? UUID()) {
                        // citizen
                        self.playerGuildState = .joined(guild: gMap)
                        
                    } else {
                        // non-citizen. Kicked?
                        self.playerGuildState = .noGuild
                    }
                }
                
            } else {
                // No Guild, or Error
                if let error = error {
//                    self.guildJoinState = .error(error: error)
                    self.guildNavError = error.localizedDescription
                    
                } else {
//                    self.guildJoinState = .noGuild
                    self.playerGuildState = .noGuild
                }
            }
        }
    }
    
    
    /// Fetches all `Joinable` Guilds
    func fetchGuilds() {
        
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
    
    /// Searching Guilds
    func searchGuilds(string:String) {
        if string.count > 20 {
            print("String is too big")
            return
        }
        
        SKNS.searchGuildByName(string: string) { guilds, error in
            if !guilds.isEmpty {
                DispatchQueue.main.async {
                    for guild in guilds {
                        if self.joinableGuilds.contains(where: { $0.id == guild.id }) == false {
                            self.joinableGuilds.append(guild)
                        }
                    }
                }
            }
        }
    }
    
    /// Post Creation of Guild - Setup Outposts, Mission, etc.
    func didCreateGuild(guildCreate:GuildCreate) {
        
        self.joinableGuilds = []
        self.otherFetchedGuilds = []
        
        // Create Guild. If server doesn't respond,
        // we need to give player back their token
        SKNS.createGuild(creator: guildCreate) { guildSum, error in
            if let guildSum = guildSum {
                print("\n\nGuild Sum In \(guildSum)")
                SKNS.postMapping(newGuildID: guildSum.id) { newGmap, newError in
                    if let newGmap = newGmap {
                        DispatchQueue.main.async {
                            // Player created guild!
                            self.player.guildID = newGmap.id
                            self.guildMap = newGmap
                            self.playerGuildState = .joined(guild: newGmap)
                            
                            // Save Player
                            do {
                                try LocalDatabase.shared.savePlayer(self.player)
                                self.fetchMyGuildMap(force: true)
                            } catch {
                                print("Could not save Player \(error.localizedDescription)")
                            }
                        }
                        return
                    } else {
                        if let newError = newError {
                            self.guildNavError = "Could not create guild. \(newError.localizedDescription)"
                            return
                        } else {
                            self.guildNavError = "Could not create guild."
                        }
                    }
                }
            } else {
                if let error = error {
                    self.guildNavError = "Could not create guild. \(error.localizedDescription)"
                    return
                }
                self.guildNavError = "Could not create guild."
            }
        }
    }
    
    /// Player leaves guild. Delete guildID and set to .noGuild
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
//                        self.guildJoinState = .noGuild
                        self.playerGuildState = .noGuild
                    } catch {
                        print("Error: \(error.localizedDescription)")
                        self.warningList.append(error.localizedDescription)
                    }
                }
            } else {
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                    self.warningList.append(error.localizedDescription)
                } else {
                    print("Unknown error.")
                }
            }
        }
    }
    
    /// Gets one Guild's Details to display for user.
    func fetchGuildMapDetails(from guildSum:GuildSummary) {
        
        
        if let fetched:GuildMap = otherGuildMaps.first(where: { $0.id == guildSum.id }) {
            self.selectedGuildMap = fetched
            return
            // self.selectedGuildObj = fetched
            // return
            
        } else {
         
            // also, go through serverData?
         
            SKNS.browseGuildMap(gSum: guildSum) { guildMap, error in
                if let guildMap = guildMap {
                    // set obj
                    
                    // Save this Guildmap in servermanager
                    let manager = ServerManager.shared
                    manager.didBrowseAnotherGuild(gMap: guildMap)
                    
                    DispatchQueue.main.async {
                        self.selectedGuildMap = guildMap
                        self.otherGuildMaps.append(guildMap)
                    }
                    
                } else {
                    // deal with error
                    print("‼️ Could not get guildmap details")
                    self.guildNavError = error?.localizedDescription ?? "Could not fetch \(guildSum.name)'s details."
                }
            }
            
        }
         
    }
    
    /// Asks Guild for citizenship
    func requestCitizenship(_ guild:GuildMap) {
        
        // Check Player ID
        guard let playerID = self.player.playerID else { return }
        guard self.player.guildID == nil else {
            print("Player's Guild is not nil! \(self.player.guildID.debugDescription)")
            return
        }
        
        // check open
        if guild.isOpen == false {
            // check invites
            guard guild.invites.contains(playerID) == true else {
                print("Guild is locked and you're not invited")
                return
            }
        } else {
            // guild is open. no need invites
        }
        
        print("Requesting Guild Join...")
        
        SKNS.joinGuildPetition(guildID: guild.id) { (newGuildSum, error) in
            
            if let newGuild:GuildSummary = newGuildSum {
                let citizens = newGuild.citizens
                if citizens.contains(playerID) {
                    
                    DispatchQueue.main.async {
                        // OK.
                        self.player.guildID = newGuild.id
                        self.guildMap = guild
                        self.playerGuildState = .joined(guild: guild)
                        
                        do {
                            try LocalDatabase.shared.savePlayer(self.player)
                        } catch {
                            print("Error saving Player.: \(error.localizedDescription)")
                        }
                    }
                    
                } else {
                    // Unable
                    print("⚠️ Unable to join. Try again slowly.")
                }
            } else {
                print("⚠️ Player could not join Guild. \(error?.localizedDescription ?? "")")
                if let error = error {
                    DispatchQueue.main.async {
//                        self.guildJoinState = .error(error: error)
                        self.guildNavError = error.localizedDescription
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
    
    /// Recursively checks Player login status.
    func checkLoginStatus(attempts:Int = 0) {
        
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
                        self.checkLoginStatus(attempts: attempts + 1)
                    } else {
                        return
                    }
                }
            case .createdPlayerWaitingAuth(let newPlayer):
                print("Waiting for Server to Finish login for \(newPlayer.name)")
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                    if let self = self {
                        self.checkLoginStatus(attempts: attempts + 1)
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
