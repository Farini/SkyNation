//
//  GuildController.swift
//  SkyNation
//
//  Created by Carlos Farini on 2/28/21.
//

import Foundation

/*
class GuildController:ObservableObject {
    
    @Published var news:String
    
    @Published var player:SKNPlayer?
    
    @Published var upPlayer:PlayerUpdate?
    
    @Published var guilds:[GuildSummary] = []
    @Published var highlightedGuild:GuildSummary? // The Guild to display (bigger)
    @Published var joinedGuild:GuildSummary?
    
    /// Autologin should be `true` for inGame, and `false` for previews (no server)
    init(autologin:Bool) {
        
        news = "Autologin"
        
//        if let player = LocalDatabase.shared.player {
//            self.player = player
//            print("Guild Controller. AutoLogin:\(autologin.description)")
//            print("Local id:\(player.id) Player id: \(player.playerID?.uuidString ?? "[none]")")
//        }
//
//        if autologin && GameSettings.onlineStatus {
//
//            let _ = ServerManager.shared
//            self.loginUser()
//
//        } else {
//            self.makeRandomData()
//        }
    }
    
    func loginUser() {
        
//        ServerManager.shared.inquireLogin { player, error in
//            DispatchQueue.main.async {
//                if let player:PlayerUpdate = player {
//                    print("Player login: ID:\(player.id.uuidString), LID: \(player.localID)")
//                    self.upPlayer = player
//                } else {
//                    print("Did not find user. \(error?.localizedDescription ?? "")")
//                }
//            }
//        }
    }
    
    /// Fetches the Guild the player is in, or other guilds
    func fetchGuilds() {
        
//        guard let player = self.player else {
//            return
//        }
//
//        if let gid = player.guildID {
//            print("Fetching Player's Guild \(gid)")
//            self.findMyGuild()
//
//        } else {
//            news = "Fetching Guilds..."
//            SKNS.browseGuilds { (guilds, error) in
//                if let array = guilds {
//                    print("Updating Guilds")
//                    self.guilds = array
//                    self.highlightedGuild = array.first
//                    self.news = "Here are the guilds"
//                } else {
//                    if let error = error {
//                        self.news = error.localizedDescription
//                    } else {
//                        self.news = "Something else happened. Not an error, but no Guilds"
//                        print("Something else happened. Not an error, but no Guilds")
//                    }
//                }
//            }
//        }
    }
    
    func findMyGuild() {
        news = "Searching your guild..."
        
        if let serverData = ServerManager.shared.serverData,
           let guild = serverData.guildfc {
            
            // Display information about my Guild
            self.joinedGuild = guild.makeSummary()
            
        } else {
            print("⚠️ No Guild was found in ServerManager.ServerData")
            ServerManager.shared.inquireFullGuild(force:false) { fullGuild, error in
                if let fullGuild = fullGuild {
                    DispatchQueue.main.async {
                        let gs = fullGuild.makeSummary()
                        self.joinedGuild = gs
                    }
                } else {
                    print("⚠️ Full Guild Inquire wasn't found")
                    DispatchQueue.main.async {
                        self.news = "Error. Player has Guild,  but data wasn't found."
                    }
                }
            }
        }
    }
    
    func requestJoinGuild(guild:GuildSummary) {
        
        guard let player = self.player else {
            return
        }
        
        if let gid = player.guildID {
            print("Player has a Guild ID! \(gid)")
            if joinedGuild?.id == gid {
                print("The joined Guild is this!")
                print("ERROR! Player must leave guild first")
                print("But check if they were kicked out as well.")
                return
            }
        }
        
        SKNS.joinGuildPetition(guildID: guild.id) { (guildSum, error) in
            if let guildSum = guildSum {
                if guildSum.citizens.contains(player.playerID ?? UUID()) {
                    // accepted
                    print("Accepted")
                    self.joinedGuild = guildSum
                    
                    player.guildID = guildSum.id
                    let res = LocalDatabase.shared.savePlayer(player: player)
                    print("Saved Player after Guild Join \(res.description)")
                    
                    ServerManager.shared.notifyJoinedGuild(guildSum: guildSum)
                    
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
    }
}
*/

