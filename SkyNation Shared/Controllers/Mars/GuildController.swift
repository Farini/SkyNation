//
//  GuildController.swift
//  SkyNation
//
//  Created by Carlos Farini on 2/28/21.
//

import Foundation

class GuildController:ObservableObject {
    
    @Published var news:String
    
    @Published var player:SKNPlayer?
    @Published var user:SKNUser?
    
    @Published var guilds:[Guild] = []
    @Published var highlightedGuild:Guild? // The Guild to display (bigger)
    @Published var joinedGuild:Guild?
    
    init() {
        news = "Do somthing first"
        
        if let player = LocalDatabase.shared.player {
            self.player = player
            self.user = SKNUser(player: player)
            print("Backend Controller")
            print("User id:\(player.id)")
            print("Server: \n (P):\(player.serverID?.uuidString ?? "NO SERVER ID") \n (U):\(user?.id.uuidString ?? "NO SERVER ID")")
        }
    }
    
    // NEW
    init(autologin:Bool) {
        news = "Autologin"
        
        if let player = LocalDatabase.shared.player {
            self.player = player
            self.user = SKNUser(player: player)
            print("Backend Controller")
            print("User id:\(player.id)")
            print("Server: \n (P):\(player.serverID?.uuidString ?? "NO SERVER ID") \n (U):\(user?.id.uuidString ?? "NO SERVER ID")")
        }
        
        if autologin {
            self.loginUser()
            
            // Temporary
            self.fetchGuilds()
        }
    }
    
    func loginUser() {
        guard let user = user else {
            print("No user")
            return
        }
        
        SKNS.newLogin(user: user) { (loggedUser, error) in
            if let loguser = loggedUser {
                print("User logged in!")
                self.user = loguser
            } else {
                print("Could not log in user. Reason: \(error?.localizedDescription ?? "n/a")")
            }
            self.news = error?.localizedDescription ?? ""
        }
    }
    
    func fetchGuilds() {
        news = "Fetching Guilds..."
        SKNS.fetchGuilds(player: user) { (guilds, error) in
            if let array = guilds {
                print("Updating Guilds")
                self.guilds = array
                self.highlightedGuild = array.first
                self.news = "Here are the guilds"
            } else {
                if let error = error {
                    self.news = error.localizedDescription
                } else {
                    self.news = "Something else happened. Not an error, but no Guilds"
                    print("Something else happened. Not an error, but no Guilds")
                }
            }
            
        }
    }
    
    func findMyGuild() {
        news = "Searching your guild..."
        SKNS.findMyGuild(user: user!) { (guild, error) in
            if let guild = guild {
                print("Found your guild: \(guild.name)")
                self.news = "Your guild is \(guild.name)"
                self.user?.guildID = guild.id
                LocalDatabase.shared.player?.guildID = guild.id
                self.joinedGuild = guild
                print("Should save user guild id ???")
                
            } else {
                self.news = "Cannot find guild"
            }
        }
    }
    
    func requestJoinGuild(guild:Guild) {
        SKNS.requestJoinGuild(playerID: player!.id, guildID: guild.id) { (guild, error) in
            if let guild = guild {
                print("Joined a guild !!!! \(guild.name)")
                self.joinedGuild = guild
            } else {
                print("Did not join?")
                self.news = error?.localizedDescription ?? "n/a"
            }
        }
    }
}
