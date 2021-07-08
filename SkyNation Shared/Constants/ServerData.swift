//
//  ServerDatabase.swift
//  SkyNation
//
//  Created by Carlos Farini on 3/14/21.
//

import Foundation

enum ServerDatabaseStatus:String, Codable, CaseIterable {
    case offline
    case online
    case errata // error message should have a valid string
}

enum ServerDataError:Error {
    case noFile // = "No file"
}

class ServerManager {
    
    static let shared = ServerManager()
    
    var serverData:ServerData?
    
    private init() {
        if let sd:ServerData = ServerManager.loadServerData() {
            self.serverData = sd
        } else {
            if let player = LocalDatabase.shared.player {
                self.serverData = ServerData(with: player)
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
    func inquireLogin(completion:@escaping(SKNPlayer?, Error?) -> ()) {
        
        guard let serverData:ServerData = serverData else {
            completion(nil, ServerDataError.noFile)
            return
        }
        
        serverData.inquireLogin { sknPlayer, error in
            completion(sknPlayer, error)
        }
    }
    
    
}

/** A class that holds all Server variables. Stores information, and manage connections. */
class ServerData:Codable {
    
    // User
    var user:SKNUserPost
    var player:SKNPlayer
    
    var partners:[PlayerContent] = []
    
    // Guild
    var guild:Guild?
    var guildfc:GuildFullContent?
    
    // cities
    var cities:[DBCity] = []
    // outposts
    var outposts:[Outpost] = []
    
    /// City that belongs to this user
    var city:CityData?
    
    // Vehicles
    var vehicles:[SpaceVehicle] = []
    
    // Status
    var status:ServerDatabaseStatus = .offline
    var errorMessage:String = ""
    
    // MARK: - Methods
    
    // User
    var lastLogin:Date?
    
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
                        self.player = player
                        self.lastLogin = Date()
                        self.user = SKNUserPost(player: player)
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
                        completion(player, nil)
                    }
                    
                } else {
                    // Error
                    self.errorMessage = error?.localizedDescription ?? "Could not connect to serer"
                    completion(nil, error)
                }
            }
        }
    }
    
    // Guild
    var lastGuildFetch:Date?
    
    /// Fetches MyGuild, Guild object
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
            }
            return
        }
    }
    
    var lastCitiesFetched:Date?
    
    // ====================
    // *** CONTINUE
    // This will fetch the cities, partners and guild full content
    // change this to return the data we want
    // be specific
    // ---------------------
    func fetchCities(completion:@escaping([DBCity], Error?) -> ()) {
        
        // Seconds until next fetch
        let delay:TimeInterval = 60.0
        
        if let log = lastCitiesFetched, Date().timeIntervalSince(log) < delay {
            completion(self.cities, nil)
            return
        }
        
        SKNS.loadGuild { gfc, error in
            
            completion(gfc?.cities ?? [], error)
            
            if let gfc:GuildFullContent = gfc {
                let cities:[DBCity] = gfc.cities
                let citizens:[PlayerContent] = gfc.citizens
                self.guildfc = gfc
                self.cities = cities
                self.partners = citizens
                self.lastCitiesFetched = Date()
                self.status = .online
                
                // Save
                if LocalDatabase.shared.saveServerData(skn: self) == false {
                    print("could not save")
                }
            }
        }
    }
    
    // My City
    var lastCityFetch:Date?
    func fetchCity() {
        
    }
    
    // Vehicles
    var lastFetchedVehicles:Date?
    func fetchVehicles() {
        
    }
    
    // MARK: - Reports and Updates
    
    func runUpdates(force:Bool = false) {
        login()
    }
    
    private func login() {
        // Check last login. Avoid redundant updates
        if let log = lastLogin, Date().timeIntervalSince(log) < 60 {
            return
        }
        SKNS.resolveLogin { (player, error) in
            if let player = player {
                DispatchQueue.main.async {
                    self.player = player
                    self.lastLogin = Date()
                    self.user = SKNUserPost(player: player)
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
    
    func reportStatus() {
        print("\n * SERVER DATABASE STATUS")
        if let lastLog = lastLogin {
            let deltaLogin = Date().timeIntervalSince(lastLog)
            print("Last Login: \(deltaLogin)s ago.")
        } else {
            print("Never logged in remotely")
        }
    }
    
    // MARK: - Initting methods
    
    /// When data doesn't exist. Create.
    init(with player:SKNPlayer) {
        let user = SKNUserPost(player: player)
        self.player = player
        self.user = user
    }
    
    /// Data exists locally (old data)
    init(localData:ServerData) {
        self.player = localData.player
        self.user = SKNUserPost(player: localData.player)
        self.lastLogin = localData.lastLogin
        
        // when this is working, and removed other methods (right now server data is being loaded elsewhere)
        // self.runUpdates()
    }
    
}

