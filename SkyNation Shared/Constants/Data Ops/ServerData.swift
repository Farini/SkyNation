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

class ServerManager {
    
    static let shared = ServerManager()
    
    var serverData:ServerData?
    
    private init() {
        if let sd:ServerData = ServerManager.loadServerData() {
            self.serverData = sd
        } else {
            if let player = LocalDatabase.shared.player {
                self.serverData = ServerData(player: player)
            } else {
                print("ERROR (ServerManager): LocalDatabase doesn't have a player")
            }
        }
    }
    
    private static func loadServerData() -> ServerData? {
        return LocalDatabase.shared.loadServerData()
    }
    
    func saveServerData() {
        if let sdata = serverData {
            let result = LocalDatabase.shared.saveServerData(skn: sdata)
            if result == true {
                print("saved ServerData")
            } else {
                print("ERROR! saving ServerData")
            }
        } else {
            print("No data to save")
        }
    }
    
    /// Get the `SKNPlayer` object from here.
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
    
    /// Gets the Full Guild Content
    func inquireFullGuild(force:Bool, completion:@escaping(GuildFullContent?, Error?) -> ()) {
        
        guard let serverData:ServerData = serverData else {
            completion(nil, ServerDataError.noFile)
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
    
}

/** A class that holds all Server variables. Stores information, and manage connections. */
class ServerData:Codable {
    
    // User
//    var user:SKNUserPost
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
                    
//                    SKNS.updatePlayer { newUpdate, newError in
//
//                    }
                    
                }
            }
        }
    }
    
    func inquireLogin(completion:@escaping(PlayerUpdate?, Error?) -> ()) {
        
        SKNS.performLogin { playerUpdate, error in
            
            completion(playerUpdate, error)
        }
    }
    
    
//    func updatePlayer(completion:Player)
    
    /*
    func inquireLogin(completion:@escaping(SKNPlayer?, Error?) -> ()) {
        
        // Seconds until next fetch
        let delay:TimeInterval = 60.0
        
        if let log = lastLogin, Date().timeIntervalSince(log) < delay {
            completion(self.player, nil)
            return
        } else {
            SKNS.resolveLogin { (player, error) in
                if let player = player {
                    DispatchQueue.main.async {
                        self.player.keyPass = player.keyPass //= player
                        if self.player.guildID != player.guildID {
                            if player.guildID == nil {
                                self.player.guildID = nil
                            }
                        }
                        self.lastLogin = Date()
                        self.user = SKNUserPost(player: self.player)
                        self.status = .online
                        
                        // Save
                        if LocalDatabase.shared.saveServerData(skn: self) == false {
                            print("could not save")
                        }
                        
                        // fetch guild, if needed
                        //                        if let _ = player.guildID {
                        //                            self.fetchGuild()
                        //                        }
                        
                        // completion
                        completion(self.player, nil)
                    }
                    
                } else {
                    // Error
                    self.errorMessage = error?.localizedDescription ?? "Could not connect to server"
                    completion(nil, error)
                }
            }
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
    
    /*
     1. Request Outpost Data
    */
    
    
    /// Fetches MyGuild, Guild object
    /*
    func fetchGuild(completion:@escaping(Guild?, Error?) -> ()) {
        
        // Seconds until next fetch
        let delay:TimeInterval = 60.0

        if let log = lastGuildFetch, Date().timeIntervalSince(log) < delay {
            completion(self.guild, nil)
            return
        }

        SKNS.findMyGuild(user: self.user) { myGuild, error in

            completion(myGuild, error)

            if let myGuild = myGuild {
                self.guild = myGuild
                self.lastGuildFetch = Date()
                self.status = .online

                // Save
                if LocalDatabase.shared.saveServerData(skn: self) == false {
                    print("could not save")
                }
                
                self.fetchGuildVehicles()
            }
            return
        }
    }
    */
    
//    var lastFullGuildFetch:Date?
    
    /// My Guild (Full Content). Use force, if you want to fetch anyways
    /*
    func fetchFullGuild(force:Bool, completion:@escaping(GuildFullContent?, Error?) -> ()) {
        
        // Seconds until next fetch
        let delay:TimeInterval = 60.0
        
        if let log = lastFullGuildFetch,
           Date().timeIntervalSince(log) < delay,
           force == false {
            completion(self.guildfc, nil)
            return
        }
        
        SKNS.loadGuild { gfc, error in
            
            completion(gfc, error)
            
            if let gfc:GuildFullContent = gfc {
                let cities:[DBCity] = gfc.cities
                let citizens:[PlayerContent] = gfc.citizens
                self.guildfc = gfc
                self.cities = cities
                self.partners = citizens
                self.lastFullGuildFetch = Date()
                self.status = .online
                
                // Save
                if LocalDatabase.shared.saveServerData(skn: self) == false {
                    print("could not save")
                }
            }
        }
    }
    */
    
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
    
//    func runUpdates(force:Bool = false) {
//        login()
//    }
    
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
        
        if GameSettings.onlineStatus == false {
            print("Not Online. (Sandbox mode)")
        } else {
            print("Requesting Online Data...")
            self.performLogin()
        }
    }
    
//    /// When data doesn't exist. Create.
//    init(with player:SKNPlayer) {
//        print("Initting server data with player")
////        let user = SKNUserPost(player: player)
//        self.player = player
//        self.guildfc = LocalDatabase.shared.serverData?.guildfc
//    }
    
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

