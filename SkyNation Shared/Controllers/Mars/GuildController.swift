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
    @Published var user:SKNPlayer?
    
    @Published var guilds:[GuildSummary] = []
    @Published var highlightedGuild:GuildSummary? // The Guild to display (bigger)
    @Published var joinedGuild:GuildSummary?
    
    init() {
        news = "Do somthing first"
        
        if let player = LocalDatabase.shared.player {
            self.player = player
//            self.user = SKNUserPost(player: player)
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
//            self.user = SKNUserPost(player: player)
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
        
        SKNS.resolveLogin { (loggedUser, error) in
            
            if let loguser = loggedUser {
                
                print("** LOGIN     >> \(loguser.name)")
                print("** LOCAL     >> \(loguser.localID.uuidString)")
                print("** SERVER    >> \(loguser.serverID?.uuidString ?? "[]")")
//                print("** GUILD     >> \(loguser.guildID?.uuidString ?? "[]")")
//                print("** CITY      >> \(loguser.cityID?.uuidString ?? "[]")")
                
                self.user = loguser
            } else {
                print("Could not log in user. Reason: \(error?.localizedDescription ?? "n/a")")
            }
        }
        
    }
    
    func fetchGuilds() {
        news = "Fetching Guilds..."
        SKNS.browseGuilds { (guilds, error) in
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
//        SKNS.findMyGuild(user: user) { (guild, error) in
//            if let guild = guild {
//                print("Found your guild: \(guild.name)")
//                self.news = "Your guild is \(guild.name)"
////                self.user?.guildID = guild.id
//                LocalDatabase.shared.player?.guildID = guild.id
////                self.joinedGuild = guild
//                print("Should save user guild id ???")
//
//            } else {
//                self.news = "Cannot find guild"
//            }
//        }
    }
    
    func requestJoinGuild(guild:GuildSummary) {
        let summary = guild
        
        SKNS.joinGuildPetition(guildID: guild.id) { (guildSum, error) in
            if let guildSum = guildSum {
                if guildSum.citizens.contains(self.player?.playerID ?? UUID()) {
                    // accepted
                    print("Accepted")
                    self.joinedGuild = guildSum
                } else {
                    print("not accepted")
                }
            } else {
                print("⚠️ ERROR: \(error?.localizedDescription ?? "n/a")")
            }
        }
    }
}
