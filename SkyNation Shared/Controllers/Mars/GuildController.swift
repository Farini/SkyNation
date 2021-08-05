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
    
    @Published var fGuilds:[Guild] = []
    @Published var sGuild:Guild? = nil
    
    
    /// Autologin should be `true` for inGame, and `false` for previews (no server)
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
        } else {
            self.makeRandomData()
        }
    }
    
    func loginUser() {
        
        ServerManager.shared.inquireLogin { player, error in
            DispatchQueue.main.async {
                if let player = player {
                    print("Player login: ID:\(player.id.uuidString), LID: \(player.localID), SID: \(player.serverID?.uuidString ?? "< No server ID >")")
                    self.user = player
                } else {
                    print("Did not find user. \(error?.localizedDescription ?? "")")
                }
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
//        let summary = guild
        
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
    
    // MARK: - Random Data
    
    /// Make Some Random Guilds
    func makeRandomData() {
        
        var newGuilds:[Guild] = []
        for i in 0...5 {
            let newGuild = Guild.makeGuild(name: "Guild #\(i)", president: nil)
            newGuilds.append(newGuild)
        }
        
        self.fGuilds = newGuilds
        
        
    }
}
