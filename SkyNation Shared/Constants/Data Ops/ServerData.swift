//
//  ServerDatabase.swift
//  SkyNation
//
//  Created by Carlos Farini on 3/14/21.
//

import Foundation

//enum ServerDatabaseStatus:String, Codable, CaseIterable {
//    case offline
//    case online
//    case errata
//}

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
    
    /// Indicates if AuthorizedLogin happened and was successful
    var playerLogged:Bool // Initializes to false. Turns true when login success only.
    
    var loginStatus:LoginStatus
    
    private init() {
        
        self.playerLogged = false
        self.loginStatus = .notStarted
        
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
            if let player = LocalDatabase.shared.player {
//                self.serverData = ServerData(player: player)
                self.loginFirstPlayer(player: player)
                
            } else {
                print("ERROR (ServerManager): LocalDatabase doesn't have a player")
            }
        }
    }
    
    private static func loadServerData() -> ServerData? {
        return LocalDatabase.shared.loadServerData()
    }
    
    /// Performs Login with Authorization
    private func loginWithData(sd:ServerData) {
        
        if playerLogged == true {
            print("Player already logged in")
            return
        }
        
        // Player is the main holder of password. It is the first that gets updated when a password is set.
        guard let player = LocalDatabase.shared.player else {
            fatalError("‼️ Local Player doesn't exist")
        }
        
        guard let pass = player.keyPass,
              let pid = player.playerID else {
            fatalError("‼️ Local Player doesn't have a pass, or pid. (See below)\n Pass:\(player.keyPass ?? "none"), PID:\(player.playerID?.uuidString ?? "none")")
        }
        
        SKNS.authorizeLogin(localPlayer: player, pid: pid, pass: pass) { playerUpdate, error in
            
            if let playerUpdate = playerUpdate {
                // success
                print("Player authorized. Name:\(playerUpdate.name), \(playerUpdate.pass)")
                
                DispatchQueue.main.async {
                    player.lastSeen = Date()
                    self.playerLogged = true
                    
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
            // attempt login
            // if fails, need a method to reset password
            
            SKNS.authorizeLogin(localPlayer: player, pid: pid, pass: pass) { playerUpdate, error in
                
                if let playerUpdate = playerUpdate {
                    // success
                    print("Player authorized. Name:\(playerUpdate.name), \(playerUpdate.pass)")
                    
                    DispatchQueue.main.async {
                        player.lastSeen = Date()
                        self.playerLogged = true
                        self.loginStatus = .playerAuthorized(playerUpdate: playerUpdate)
                        
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
                        let saveResult = LocalDatabase.shared.savePlayer(player: player)
                        guard saveResult == true else {
                            fatalError("Failed to save new player")
                        }
                        print("New Player Created, and saved.")
                        
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
    
    func saveServerData() {
        if let sdata = serverData {
            let result = LocalDatabase.shared.saveServerData(skn: sdata)
            if result == true {
                print("saved ServerData locally")
            } else {
                print("‼️ ERROR! saving ServerData ‼️")
            }
        } else {
            print("‼️ No Server Data to save ‼️")
        }
    }
    
    /// Get the `SKNPlayer` object from here.
    /*
    func inquireLogin(completion:@escaping(PlayerUpdate?, Error?) -> ()) {
        
        if let sd = serverData {
            print("Previous Server Data. LastLogin: \(sd.lastLogin?.description ?? "---")")
        } else {
            
            guard let player = LocalDatabase.shared.player else {
                print("Server Data Crashing. Player doesn't exist")
                return
            }
            
            self.serverData = ServerData(player: player)
        }
        
        serverData?.inquireLogin { pUpdate, error in
            completion(pUpdate, error)
        }
        
    }
    */
    
    /// Gets the Full Guild Content
    func inquireFullGuild(force:Bool, completion:@escaping(GuildFullContent?, Error?) -> ()) {
        
        guard let serverData:ServerData = serverData else {
            completion(nil, ServerDataError.noServerDataFile)
            return
        }
        
        serverData.requestPlayerGuild(force: force) { fullGuild, error in
            completion(fullGuild, error)
        }
        
    }
    
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
            }
        }
    }
    
    /*
     Get Outpost Data (this may take a while) but it is necessary.
        if outpostData does not exist, needs to create it.
        
     */
    
}

/** A class that holds all Server variables. Stores information, and manage connections. */
class ServerData:Codable {
    
    // Player
    var player:SKNPlayer
    
    // Guild
    var dbGuild:GuildSummary?
    var guildfc:GuildFullContent?
    
    /// Other Players
    var partners:[PlayerContent] = []
    
    /// Guild's `DBCity` array
    var cities:[DBCity] = []
    
    /// City that belongs to this user
    var city:CityData?
    
    /// Guild's outposts
    var outposts:[Outpost] = []
    
    // Vehicles
    var vehicles:[SpaceVehicle] = []
    var guildVehicles:[SpaceVehicleTicket] = []
    
    // Status
//    var status:ServerDatabaseStatus = .offline
    var errorMessage:String = ""
    
    // MARK: - Methods: Login
    
    // Sequential...
    /*
     1. SKNS.performLogin
            Possible Errors:
                a. Has no login,
                b. PlayerLogin.LogFail
                c. Abort(.badRequest, reason: "Wrong Pass")
                d. Abort(.badRequest, reason: "Decoding Player Login")
     
     [Login Succeed] -> SKNS.updatePlayer -> SKNS.requestPlayersGuild -> SKNS.arrivedVehiclesInGuildMap
     [Login Fail] -> SKNS.newLogin
     
     */
    
    /// Date last login was made
    var lastLogin:Date?
    
    /*
    fileprivate func performLogin() {
        
        print("Server Data Performing Login")
        
        SKNS.performLogin { playerUpdate, error in
            
            if let fail = error as? PlayerLogin.LogFail {
                switch fail {
                    case .noID:
                        print("Player has No ID. Create one")
                        // SKNS.newLogin
                    case .noPass:
                        print("Player has no pass. (SKNS.requestNewPass)")
                        // SKNS.requestNewPass
                }
            } else if let error = error {
                print(error.localizedDescription)
                if error.localizedDescription.contains("Pass") {
                    print("Wrong Pass")
                    // SKNS.requestNewPass
                } else if error.localizedDescription.contains("Decoding") {
                    print("Error Decoding PlayerLogin. Make sure Models are identical")
                } else {
                    print("‼️ Another (unknown) type error performing Login: \(error.localizedDescription)")
                }
            } else {
                if let update = playerUpdate {
                    
                    print("\(update.name) logged in. Pass:\(update.pass). Updating Player...")
                    self.lastLogin = Date()
                    
//                    SKNS.updatePlayer { newUpdate, newError in
//
//                    }
                    
                }
            }
        }
    }
    
    func inquireLogin(completion:@escaping(PlayerUpdate?, Error?) -> ()) {
        
        if let lastLogin = lastLogin {
            if Date().timeIntervalSince(lastLogin) < 5 {
                completion(nil, nil)
                return
            }
        }
        
        SKNS.performLogin { playerUpdate, error in
            
            completion(playerUpdate, error)
        }
    }
    */
    
    // MARK: - Player's Guild
    
    /// Date Guild was last Fetched
    var lastGuildFetch:Date?
    
    func requestPlayerGuild(force:Bool, completion:@escaping(GuildFullContent?, Error?) -> ()) {
        
        print("Requesting Player Guild from ServerData.")
        
        // Check if needs update
        let delay:TimeInterval = 60.0
        if let log = lastGuildFetch,
           Date().timeIntervalSince(log) < delay,
           force == false {
            completion(self.guildfc, nil)
            return
        }
        
        SKNS.requestPlayersGuild { fullGuild, error in
            
            if let fullGuild:GuildFullContent = fullGuild {
                
                self.guildfc = fullGuild
                
                let cities:[DBCity] = fullGuild.cities
                self.cities = cities
                
                let citizens:[PlayerContent] = fullGuild.citizens
                self.partners = citizens
                
                self.lastGuildFetch = Date()
//                self.status = .online
                
                // Save
                if LocalDatabase.shared.saveServerData(skn: self) == false {
                    print("‼️ could not save ServerData")
                }
                
            } else if let error = error {
                print("ERROR Requesting Guild: \(error.localizedDescription)")
            }
            
            completion(fullGuild, error)
        }
    }
    
    // MARK: - Outpost Data
    var lastOutpostFetch:Date?
    func requestOutpostData(dbOutpost:DBOutpost, force:Bool, completion:@escaping(Outpost?, Error?) -> ()) {
        
        // Check if needs update
        let delay:TimeInterval = 60.0
        if let log = lastOutpostFetch,
           let object:Outpost = self.outposts.first(where: { $0.id == dbOutpost.id }),
           Date().timeIntervalSince(log) < delay,
           force == false {
            completion(object, nil)
            return
        }
        
        // Check server
        SKNS.requestOutpostData(dbOutpost: dbOutpost) { outpost, error in
            if let outpost:Outpost = outpost {
                print("Outpost Fetched: \(outpost.type)")
                completion(outpost, nil)
                // Update the fetched date
                self.lastOutpostFetch = Date()
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
    
    // Vehicles
    var lastFetchedVehicles:Date?
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
                    if vehicle.owner == LocalDatabase.shared.player?.playerID {
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
    
    /*
    private func login() {
        // Check last login. Avoid redundant updates
        if let log = lastLogin, Date().timeIntervalSince(log) < 60 {
            return
        }
        SKNS.resolveLogin { (player, error) in
            if let player = player {
                DispatchQueue.main.async {

                    self.lastLogin = Date()
                    
                    let updatePlayer = self.player
                    updatePlayer.keyPass = player.keyPass
                    updatePlayer.lastSeen = Date()
                    
                    if player.playerID != updatePlayer.playerID {
                        print("‼️ Player Getting new 'playerID'")
                    }
                    if player.serverID != updatePlayer.serverID {
                        print("‼️ Player Getting new 'serverID'")
                    }
                    if player.guildID != updatePlayer.guildID {
                        print("‼️ Player Getting new 'guildID'")
                    }
                    
                    self.user = SKNUserPost(player: updatePlayer)
                    self.status = .online
                    
                    // Save
                    if LocalDatabase.shared.saveServerData(skn: self) == false {
                        print("could not save")
                    }
                    
                    self.user = SKNUserPost(player: updatePlayer)
//                    if let _ = player.guildID {
//                        self.fetchGuild()
//                    }
                }
                
            } else {
                // Error
                self.errorMessage = error?.localizedDescription ?? "Could not connect to serer"
            }
        }
    }
    */
    
    func reportStatus() {
        print("\n * SERVER DATABASE STATUS")
        
        // Login
        if let lastLog = lastLogin {
            let deltaLogin = Date().timeIntervalSince(lastLog)
            print("Last Login: \(deltaLogin)s ago.")
        } else {
            print("Never logged in remotely")
        }
        
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
    
    // MARK: - Initting methods
    
    init(player:SKNPlayer) {
        
        print("Server Data Initializing")
        self.player = player
        
//        if GameSettings.onlineStatus == false {
//            print("Not Online. (Sandbox mode)")
//        } else {
//            print("Requesting Online Data...")
//            self.performLogin()
//        }
    }
    
    /// Data exists locally (old data)
    init(localData:ServerData) {
        
        self.player = LocalDatabase.shared.player!
        
        self.lastLogin = localData.lastLogin
        self.lastGuildFetch = localData.lastGuildFetch
        self.lastFetchedVehicles = localData.lastFetchedVehicles
        
        
        // when this is working, and removed other methods (right now server data is being loaded elsewhere)
        // self.runUpdates()
    }
    
}
