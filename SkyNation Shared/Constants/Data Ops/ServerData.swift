//
//  ServerDatabase.swift
//  SkyNation
//
//  Created by Carlos Farini on 3/14/21.
//

import Foundation

enum LoginStatus {
    
    /// The initial status
    case notStarted
    
    /// Requests returned error
    case serverError(reason:String, error:Error?, sknsError:ServerDataError?)
    
    /// Player successfully authorized
    case playerAuthorized(playerUpdate:PlayerUpdate)
    
    /// Player exists, has a pass AND playerID, but not authorized
    case playerUnauthorized(player:SKNPlayer)
    
    /// Player was created. Now waiting for auth.
    case createdPlayerWaitingAuth(playerUpdate:PlayerUpdate)
    
    case simulatingData(serverData:ServerData)
}

class ServerManager {
    
    static let shared = ServerManager()
    
    var serverData:ServerData?
    
    /// An Indicator of a change in variable, as a result from the server response
    enum PlayerFlag {
        case guildID    // new guildID
        case password   // new password
        case playerID   // new playerID (on create, update)?
        case lastSeen   // for other players?
    }
    var playerFlags:[PlayerFlag] = []
    
    /// An Indicator that something is new
    enum GuildFlag {
        case messages   // new chat messages
        case election   // election did change
        case citizens   // new citizen / kicked out
        case vehicles   // vehicles
        case missions   // mission change (pid not in it)
    }
    var guildFlags:[GuildFlag] = []
    
    /// Indicates if AuthorizedLogin happened and was successful
    var playerLogged:Bool // Initializes to false. Turns true when login success only.
    
    var loginStatus:LoginStatus
    
    private init() {
        
        self.playerLogged = false
        self.loginStatus = .notStarted
        
        let player = LocalDatabase.shared.player
        
        // Improvements in Login:
        
        // Comb through Player's object
            // Check PlayerID
                // Check pass
            // Log player in with player.playerID
            // Create here if playerID doesn't exist
            // Alternatively, wait to create in Player Update (view)
        // Detect flags [PlayerXP && noPlayer], [guildID && no guild], [cityID && noCity]
            // 1. [PlayerXP && noPlayer]: Just register new player (and mark with flag)
            // 2. [guildID && no guild]: Show message -> A. Guild doesn't exist, B. Kicked out
            // 3. [cityID && noCity] - Happens when player leaves a guild. Check if city should be "frozen"
        // Design Login Object with flags, etc.
        // Check for object updates (whats new?) - Player and GuildMap
            // 1. Player has Gift
            // 2. New Guild Messages
            // 3. Guild Outpost Updates
            // 4. Guild Mission Updates
            // 5. New Election State?
        
        /*
         Discussion: Substitute the above (new) for the following (old)....
         1. Check player ID
         2. Check pass
         --- Create new player
         --- Update old player
         [Player Flags]
         3. Check GuildID -> GuildID + Citizen check
         4. City ID
         */
        
        // New Method
        
        if let pid = player.playerID,
           let pass = player.keyPass,
           let server = ServerManager.loadServerData(),
           pass.isEmpty == false {
            print("Player can login pid:\(pid), pass:\(pass)")
            if GameSettings.onlineStatus == true {
                // Perform Login
                self.loginWithData(sd: server)
            } else {
                // Simulate
                print("Simulating Info !")
                self.loginStatus = .simulatingData(serverData: server)
            }
        } else {
            // Player can't login. Needs to create
            self.loginFirstPlayer(player: player)
        }
        self.serverData = ServerManager.loadServerData() ?? ServerData(player: player)
        
        
        /*
        // Old Method
        if let sd:ServerData = ServerManager.loadServerData() {
            
            // Local Server data stored
            self.serverData = sd
            
            if GameSettings.onlineStatus == true {
                // Validate Login
                self.loginWithData(sd: sd)
            } else {
                // Simulate Data
                self.loginStatus = .simulatingData(serverData: sd)
            }
            
        } else {
            
            // No Server Data Stored
            self.loginFirstPlayer(player: player)
        }
        */
    }
    
    private static func loadServerData() -> ServerData? {
        return LocalDatabase.shared.serverData
    }
    
    /// Performs Login with Authorization
    private func loginWithData(sd:ServerData) {
        
        if playerLogged == true {
            print("Player already logged in")
            return
        }
        
        // Player is the main holder of password. It is the first that gets updated when a password is set.
        let player = LocalDatabase.shared.player
        
        guard let pass = player.keyPass,
              let pid = player.playerID else {
            fatalError("‼️ Local Player doesn't have a pass, or pid. (See below)\n Pass:\(player.keyPass ?? "none"), PID:\(player.playerID?.uuidString ?? "none")")
        }
        
        
        SKNS.authorizeLogin(localPlayer: player, pid: pid, pass: pass) { playerUpdate, error in
            
            if let playerUpdate:PlayerUpdate = playerUpdate {
                // success
                print("Player authorized. Name:\(playerUpdate.name), \(playerUpdate.pass)")
                
                DispatchQueue.main.async {
//                    player.lastSeen = Date()
                    self.playerLogged = true
                    
                    // Flags
                    do {
                        let oldPlayer:PlayerUpdate = try PlayerUpdate.create(player: player)
                        let pFlags = oldPlayer.compareFlags(newPlayer: playerUpdate)
                        if !pFlags.isEmpty {
                            print("\n\n\n PLAYER UPDATE FLAGS !!\n \(pFlags.description)\n\n")
                            self.playerFlags = pFlags
                            
                            if pFlags.contains(.password) {
                                player.keyPass = playerUpdate.pass
                                do {
                                    try LocalDatabase.shared.savePlayer(player)
                                } catch {
                                    print("Error saving player \(error.localizedDescription)")
                                }
                            }
                        }
                    } catch {
                        // Could not create a PlayerUpdate Object
                    }
                    
                    let newServerData = ServerData(localData: sd)
                    self.serverData = newServerData
                    
                    self.loginStatus = .playerAuthorized(playerUpdate: playerUpdate)
                }
                
                
            } else {
                // failed
                print("‼️ Authorize Login Failed. Error: \(error?.localizedDescription ?? "no error")")
                self.loginStatus = .serverError(reason: "Error validating Login", error: error, sknsError: nil)
            }
        }
    }
    
    /// Possibly first login, or login after losing data.
    private func loginFirstPlayer(player:SKNPlayer) {
        
        if let pid = player.playerID,
           let pass = player.keyPass {
            
            // Check if there is an auth already.
            SKNS.authorizeLogin(localPlayer: player, pid: pid, pass: pass) { playerUpdate, error in
                
                if let playerUpdate:PlayerUpdate = playerUpdate {
                    // success
                    print("Player authorized. Name:\(playerUpdate.name), \(playerUpdate.pass)")
                    
                    DispatchQueue.main.async {
//                        player.lastSeen = Date()
                        let delta = abs(player.lastSeen.timeIntervalSinceNow)
                        if delta > 60 {
                            player.lastSeen = Date()
                        }
                        self.playerLogged = true
                        self.loginStatus = .playerAuthorized(playerUpdate: playerUpdate)
                        
                        // Flags
                        do {
                            let oldPlayer = try PlayerUpdate.create(player: player)
                            let pFlags = oldPlayer.compareFlags(newPlayer: playerUpdate)
                            if !pFlags.isEmpty {
                                print("\n\n\n PLAYER UPDATE FLAGS !!\n \(pFlags.description)\n\n")
                                self.playerFlags = pFlags
                                if pFlags.contains(.password) {
                                    player.keyPass = playerUpdate.pass
                                    do {
                                        try LocalDatabase.shared.savePlayer(player)
                                    } catch {
                                        print("Error saving player \(error.localizedDescription)")
                                    }
                                }
                            }
                        } catch {
                            // Could not create a PlayerUpdate Object
                        }
                        
                        // Update var serverData
                        if self.serverData != nil {
                            self.serverData!.player = player
                        } else {
                            self.serverData = ServerData(player: player)
                        }
                    }
                } else {
                    // failed
                    print("‼️ Authorize Login Failed. Error: \(error?.localizedDescription ?? "no error")")
                    self.loginStatus = .serverError(reason: "Error validating Login", error: error, sknsError: nil)
                }
            }
            
        } else {
            
            // create login
            SKNS.createNewPlayer(localPlayer: player) { playerUpdate, error in
                if let playerUpdate = playerUpdate {
                    DispatchQueue.main.async {
                        
                        // Save new Player
                        player.playerID = playerUpdate.id
                        player.keyPass = playerUpdate.pass
                        
                        // Save
                        do {
                            try LocalDatabase.shared.savePlayer(player)
                            print("New Player created in database")
                        } catch {
                            print("‼️ Could not save player.: \(error.localizedDescription)")
                        }
                        
                        self.loginStatus = .createdPlayerWaitingAuth(playerUpdate: playerUpdate)
                        
                        var sData:ServerData? = self.serverData
                        if let sData = sData {
                            sData.player.playerID = playerUpdate.id
                            sData.player.keyPass = playerUpdate.pass
                            self.serverData = sData
                            self.saveServerData()
                        } else {
                            sData = ServerData(player: player)
                        }
                        guard let sData = sData else { fatalError("Server Data Failed to create") }
                        
                        // Needs to validate login
                        self.loginWithData(sd:sData)
                        
                    }
                } else {
                    // Deal with error
                    self.loginStatus = .serverError(reason: "Could not create new player", error: error, sknsError: nil)
                }
            }
        }
    }
    
    /*
    /// Gets the Full Guild Content
    func inquireFullGuild(force:Bool, completion:@escaping(GuildFullContent?, Error?) -> ()) {
        
        guard let serverData:ServerData = serverData else {
            completion(nil, ServerDataError.noServerDataFile)
            return
        }
        
        serverData.requestPlayerGuild(force: force) { fullGuild, error in
            DispatchQueue.main.async {
                completion(fullGuild, error)
            }
        }
        
    }
    */
    
    
    /// max delay is in seconds
    ///  gets the map with instructions
    ///  - parameters:
    ///  - force: whether force to reload
    ///  maxDelay: maximum allowed data delay (in seconds)
    func requestGuildMap(force:Bool = false, maxDelay:Int = 60, completion:@escaping(GuildMap?, Error?) -> ()) {
        
        guard let serverData:ServerData = serverData else {
            completion(nil, ServerDataError.noServerDataFile)
            return
        }
        
        let oldGuildMap = serverData.guildMap
        
        serverData.requestGuildMap(force, deadline: maxDelay) { guildMap, error in
            
            // Set the GuildFlags
            if let newGuildMap = guildMap,
            let oldGuildMap = oldGuildMap {
                let guildFlags:[GuildFlag] = oldGuildMap.compareFlags(newMap: newGuildMap)
                self.guildFlags = guildFlags
            }
            
            // Completion
            completion(guildMap, error)
        }
        
    }
    
    /*
    func notifyJoinedGuild(guildSum:GuildSummary) {
        guard let serverData:ServerData = serverData else {
            return
        }
        serverData.requestPlayerGuild(force: true) { fullGuild, error in
            if let fullGuild = fullGuild {
                print("Joined Guild Success \(fullGuild.name)")
            } else {
                print("‼️ Error notifying join Guild: \(error?.localizedDescription ?? "n/a")")
            }
        }
    }
    */
    
    // Outpost Data
    func requestOutpostData(dbOutpost:DBOutpost, force:Bool, completion:@escaping((Outpost?, Error?) -> ())) {
        
        guard let serverData = serverData else {
            completion(nil, ServerDataError.noServerDataFile)
            return
        }
        
        serverData.requestOutpostData(dbOutpost: dbOutpost, force: force) { outpost, error in
            
            if let error = error as? ServerDataError {
                if error == .noOutpostFile {
                    print("Will create Outpost Data in Server!")
                    // Needs to create an outpost file
                    // SKNS can solve this
                    SKNS.createOutpostData(dbOutpost: dbOutpost) { newOutpost, newError in
                        if let newOutpost:Outpost = newOutpost {
                            self.serverData!.outposts.append(newOutpost)
                            self.saveServerData()
                            print("✅ Outpost Data created in server")
                        } else {
                            print("Outpost Data could not be created: \(error.localizedDescription)")
                            completion(nil, error)
                        }
                    }
                }
            } else {
                print("Request Outpost Data Response in...")
                completion(outpost, error)
//                if let outpost = outpost,
//                   let serverData = self.serverData {
//                    serverData.
//                }
            }
        }
    }
    
    /// Stores the Guild Details in Database.
    func didBrowseAnotherGuild(gMap:GuildMap) {
        
        // Method to store fetched Guilds and Other Players.
        
        let addingPlayers:[PlayerContent] = gMap.citizens
        
        if let serverData = serverData {
            
            if let otherGuilds = serverData.otherGuilds {
                let newGuilds = otherGuilds + [gMap]
                serverData.otherGuilds = newGuilds
                
            } else {
                serverData.otherGuilds = [gMap]
                
            }
            
            if let otherPlayers = serverData.otherPlayers {
                let newPlayers = otherPlayers + addingPlayers
                serverData.otherPlayers = newPlayers
            } else {
                serverData.otherPlayers = addingPlayers
            }
        }
    }
    
    // MARK: - Saving
    
    func saveServerData() {
        if let sdata = serverData {
            // Save
            do {
                try LocalDatabase.shared.saveServerData(sdata)
            } catch {
                print("‼️ Could not save server data.: \(error.localizedDescription)")
            }
        } else {
            print("‼️ No Server Data to save ‼️")
        }
    }
    
}

/** A class that holds all Server variables. Stores information, and manage connections. */
class ServerData:Codable {
    
    // Player
    var player:SKNPlayer
    
    /// My GuildSummary
    var dbGuild:GuildSummary?
    
    /// DEPRECATING -> for mac v1.3, iOS v. 1.3 -> Remove from CodingKeys and from here.
    var guildfc:GuildFullContent?
    
    /// The GuildMap containing most guild info
    var guildMap:GuildMap?
    
    var otherGuilds:[GuildMap]?
    
    /// Other Players
    var partners:[PlayerContent] = []
    var otherPlayers:[PlayerContent]?
    
    /// Guild's `DBCity` array
    var cities:[DBCity] = []
    
    /// City that belongs to this user
    var city:CityData?
    
    /// Guild's outposts (Full Data)
    var outposts:[Outpost] = []
    
    // Vehicles
    var vehicles:[SpaceVehicle] = []
    var guildVehicles:[SpaceVehicleTicket] = []
    
    // Election
    var election:Election?
    
    // Errors
    var errorMessage:String = ""
    
    // MARK: - Player's Guild
    
    /// Date Guild was last Fetched - DEPRECATED
    var lastGuildFetch:Date?
    
    /// Date that `GuildMap` has been fetched
    var lastMapFetch:Date?
    
    // DEPRECATE
    var lastOutpostFetch:Date?
    
    /// Date that last fetched vehicles.
    ///
    /// This is the `Guild` vehicles
    ///
    /// > Tip: Deprecate this too if you can't decide.
    ///
    /// Not sure what to do next.
    var lastFetchedVehicles:Date?
    
    func requestGuildMap(_ force:Bool = false, deadline:Int = 60, completion:@escaping(GuildMap?, Error?) -> ()) {
        
        // Check if needs update
        let delay:TimeInterval = Double(deadline) // 60 seconds
        let dateFetch = lastMapFetch ?? Date.distantPast
        
        let currentDelay = Date().timeIntervalSince(dateFetch)
        
        if force == false {
            if currentDelay < delay {
                if let guildMap = guildMap {
                    completion(guildMap, nil)
                    return
                }
            }
        }
        
        SKNS.buildGuildMap { guildMap, error in
            if let guildMap = guildMap {
                self.guildMap = guildMap
                self.lastMapFetch = Date()
                
                // Save
                do {
                    try LocalDatabase.shared.saveServerData(self)
                    completion(guildMap, nil)
                } catch {
                    print("‼️ Could not save Server Data.: \(error.localizedDescription)")
                    completion(nil, error)
                }
                
            }
        }
    }
    
    // Guildmap Flags (whats new)
    
    // MARK: - Outpost Data
    
    func requestOutpostData(dbOutpost:DBOutpost, force:Bool, completion:@escaping(Outpost?, Error?) -> ()) {
        
        // Check if needs update
//        let delay:TimeInterval = 60.0
//        if let log = lastOutpostFetch,
//           let object:Outpost = self.outposts.first(where: { $0.id == dbOutpost.id }),
//           Date().timeIntervalSince(log) < delay,
//           force == false {
//            completion(object, nil)
//            return
//        }
        
        // Check server
        SKNS.requestOutpostData(dbOutpost: dbOutpost) { outpost, error in
            if let outpost:Outpost = outpost {
                print("Outpost Fetched: \(outpost.type)")
                completion(outpost, nil)
                // Update the fetched date
                self.lastOutpostFetch = Date()
                self.saveOutpost(outpost: outpost)
                return
            }
            if let error = error {
                if let nofile = error as? ServerDataError {
                    print("No file error")
                    completion(nil, nofile)
                } else {
                    print("Another error. (File is ok)")
                    completion(nil, error)
                }
                return
            }
        }
    }
    
    func saveOutpost(outpost:Outpost) {
        if let opindex = self.outposts.firstIndex(where: { $0.id == outpost.id }) {
            self.outposts.remove(at: opindex)
        }
        self.outposts.append(outpost)
        do {
            try LocalDatabase.shared.saveServerData(self)
        } catch {
            print("Error! Could not save new outpost data \(error.localizedDescription)")
        }
    }
    
    // Vehicles
    
    func fetchGuildVehicles() {
        
        // Seconds until next fetch
        let delay:TimeInterval = 60.0
        
        if let log = lastFetchedVehicles, Date().timeIntervalSince(log) < delay {
            return
        }
        
        print("Getting Arrived Vehicles")
        SKNS.arrivedVehiclesInGuildMap() { gVehicles, error in
            if let gVehicles:[SpaceVehicleTicket] = gVehicles {
                print("Guild garage vehicles: \(gVehicles.count)")
                
                self.guildVehicles = gVehicles
                for vehicle in gVehicles {
                    if vehicle.owner == LocalDatabase.shared.player.playerID {
                        print("Vehicle is mine: \(vehicle.engine)")
                    } else {
                        print("Vehicle belongs to: \(vehicle.owner)")
                    }
                }
            } else {
                print("⚠️ Error: Could not get arrived vehicles. error -> \(error?.localizedDescription ?? "n/a")")
            }
        }
    }
    
    // MARK: - Reports and Updates
    
    func energyCollectionForAccounting() -> Int {
        // LSS uses this to show how much its making
        
        var energyCollection:Int = 0
        
        let outposts = guildMap?.outposts ?? []
        // get power sources
        
        for op:DBOutpost in outposts {
            if op.type == .Energy {
                
                let totalEnergyProduce = op.type.productionForCollection(level: op.level)["Energy", default: 0]
                let pEnergy = totalEnergyProduce / max(1, cities.count)
                
                energyCollection += pEnergy
            }
        }
        
        
        return energyCollection
    }
    
    /// Prints Information about Server Data
    func reportStatus() {
        print("\n * SERVER DATABASE STATUS")
        
        // Login
//        if let lastLog = lastLogin {
//            let deltaLogin = Date().timeIntervalSince(lastLog)
//            print("Last Login: \(deltaLogin)s ago.")
//        } else {
//            print("Never logged in remotely")
//        }
        
        // Guild
        if let lastGuild = lastGuildFetch {
            let deltaLogin = Date().timeIntervalSince(lastGuild)
            print("Last Guild Fetch: \(deltaLogin)s ago.")
        } else {
            print("Never got Guild")
        }
        
        // Vehicles
        if let lastVehicle = lastFetchedVehicles {
            let deltaLogin = Date().timeIntervalSince(lastVehicle)
            print("Last Vehicle: \(deltaLogin)s ago.")
        } else {
            print("Never got Vehicles")
        }
    }
    
    // MARK: - Initializers
    
    init(player:SKNPlayer) {
        print("Server Data Initializing with player \(player.name)")
        self.player = player
    }
    
    /// Data exists locally (old data)
    init(localData:ServerData) {
        self.player = LocalDatabase.shared.player
//        self.lastGuildFetch = localData.lastGuildFetch
        
        // Deprecating (from old GuildFullContent)
        self.lastGuildFetch = nil
        
        self.lastFetchedVehicles = localData.lastFetchedVehicles
        self.lastMapFetch = localData.lastMapFetch
    }
    
    /**
     Decoding Initializer.
     
     Make Properties as lightly as possible.
     If values don't exist, just assign nil, or if it is an array, an empty array.
     */
    required init(from decoder: Decoder) throws {
        
        // Container
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        if let player = try? values.decodeIfPresent(SKNPlayer.self, forKey: .player) {
            print("Decoding remote player from local file")
            self.player = player
        } else {
            print("Decoding local player from local file")
            self.player = LocalDatabase.shared.player
        }
        
        if let dbGuild = try? values.decodeIfPresent(GuildSummary.self, forKey: .dbGuild) {
            self.dbGuild = dbGuild
        } else {
            self.dbGuild = nil
        }
        
        if let gfc = decoder.userInfo.keys.first(where: { $0.rawValue == "guildfc"}) {
            print("User info for `GuildFullContent` is still here... \(gfc.rawValue) -> Deprecate!")
        }
        if let oldGFC = values.allKeys.first(where: { $0 == CodingKeys.guildfc }) {
            print("Old guild Full Content is here. Key.: \(oldGFC.stringValue) -> Dreprecate it.")
        }
        self.guildfc = nil
        
        self.guildMap = try values.decodeIfPresent(GuildMap.self, forKey: .guildMap)
        self.otherGuilds = try values.decodeIfPresent([GuildMap].self, forKey: .otherGuilds)
        if let partners = try? values.decodeIfPresent([PlayerContent].self, forKey: .partners) {
            self.partners = partners
        } else {
            self.partners = []
        }
        if let cities = try? values.decodeIfPresent([DBCity].self, forKey: .cities) {
            self.cities = cities
        } else {
            self.cities = []
        }
        if let city = try? values.decodeIfPresent(CityData.self, forKey: .city) {
            self.city = city
        } else {
            self.city = nil
        }
        if let ops = try? values.decodeIfPresent([Outpost].self, forKey: .outposts) {
            self.outposts = ops
        } else {
            self.outposts = []
        }
        if let vehicles = try? values.decodeIfPresent([SpaceVehicle].self, forKey: .vehicles) {
            self.vehicles = vehicles
        } else {
            self.vehicles = []
        }
        // Vehicles
        if let iVehicles:[SpaceVehicle] = try? values.decodeIfPresent([SpaceVehicle].self, forKey: .vehicles) {
            self.vehicles = iVehicles
        } else {
            self.vehicles = []
        }
        if let gvs:[SpaceVehicleTicket] = try? values.decodeIfPresent([SpaceVehicleTicket].self, forKey: .guildVehicles) {
            self.guildVehicles = gvs
        } else {
            self.guildVehicles = []
        }
        
        if let election = try? values.decodeIfPresent(Election.self, forKey: .election) {
            self.election = election
        } else {
            self.election = nil
        }
        
        self.errorMessage = ""
        self.lastGuildFetch = nil // try values.decodeIfPresent(Date.self, forKey: .lastGuildFetch)
        self.lastMapFetch = try values.decodeIfPresent(Date.self, forKey: .lastMapFetch)
        self.lastOutpostFetch = nil
        self.lastFetchedVehicles = try values.decodeIfPresent(Date.self, forKey: .lastFetchedVehicles)
        
    }
    
    func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        // Deprecating GFC
        if let gfc = self.guildfc {
            print("Guild Full Content here. \(gfc.name) DO NOT ENCODE.")
            self.guildfc = nil
        }
        
        // Update Cities
        if let dbc = self.guildMap?.cities {
            if self.cities.isEmpty {
                self.cities = dbc
            }
        }
        // Update Guild Vehicles
        if let gv = self.guildMap?.vehicles {
            if self.guildVehicles.isEmpty {
                self.guildVehicles = gv
            }
        }
        
        // Player Required
        try container.encode(player, forKey: .player)
        
        // MARK: - Guild Objects
        
        // Guild Summary
        if let gs = self.dbGuild {
            try container.encode(gs, forKey: .dbGuild)
        }
        // Guild Map
        if let map = guildMap {
            try container.encode(map, forKey: .guildMap)
        }
        if let otherGuilds = otherGuilds {
            try container.encode(otherGuilds, forKey: .otherGuilds)
        }
        
        // Cities + OP
        try container.encode(cities, forKey: .cities)
        if let city = city {
            try container.encode(city, forKey: .city)
        }
        try container.encode(outposts, forKey: .outposts)
        
        // Players
        try container.encode(partners, forKey: .partners)
        if let otherPlayers = otherPlayers {
            try container.encode(otherPlayers, forKey: .otherPartners)
        }
        
        // Vehicles
        try container.encode(vehicles, forKey: .vehicles)
        try container.encode(guildVehicles, forKey: .guildVehicles)
        
        if let election = election {
            try container.encode(election, forKey: .election)
        }
        
        // MARK: - Others
        
        // Error
        if !errorMessage.isEmpty {
            print("Previous error message.: \n\t \(errorMessage) |-| ServerData doesn't save errors")
        } else {
            try container.encode(errorMessage, forKey: .errorMessage)
        }
        
        // Dates
        var lgf:Date?
        if let lastMapFetch = lastMapFetch {
            lgf = lastMapFetch
        } else {
            if let lastGuildFetch = lastGuildFetch {
                lgf = lastGuildFetch
            }
        }
        if let lgf = lgf {
            try container.encode(lgf, forKey: .lastMapFetch)
        }
    }
    
    /// Coding Keys for this class
    private enum CodingKeys:String, CodingKey {
        case player
        case dbGuild
        case guildfc // Keep here for now. Remove next version?
        case guildMap
        case otherGuilds
        case partners
        case otherPartners
        case cities
        case city
        case outposts
        case vehicles
        case guildVehicles
        case election
        case errorMessage
        case lastGuildFetch
        case lastMapFetch
        case lastFetchedVehicles
    }
}

// MARK: - Decoding

//extension ServerData {
//    
//    // MARK: - Codable
//    
//}
