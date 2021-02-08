//
//  BackendView.swift
//  SkyNation
//
//  Created by Carlos Farini on 2/6/21.
//

import SwiftUI

struct BackendView: View {
    
    @ObservedObject var controller:BackendController
    
    var body: some View {
        
        VStack {
            
            Text("Hello, Back End!").foregroundColor(.green).font(.largeTitle)
            Divider()
            Text("News")
            Text(controller.news).foregroundColor(.gray)
            
            // User Info
            Group {
                VStack(alignment:.leading) {
                    Text("User Info").font(.title).foregroundColor(.blue)
                    Text("GID: \(controller.user?.guildID?.uuidString ?? "n/a")")
                    Text("PID: \(controller.user?.id.uuidString ?? "n/a")")
                    Text("LID: \(controller.user?.localID.uuidString ?? "n/a")")
                    Text("CID: \(controller.user?.cityID?.uuidString ?? "n/a")")
                }
                .padding([.top, .bottom])
            }
            
            // Guild Info
            Group {
                if let guild = controller.joinedGuild {
                    VStack(alignment:.leading) {
                        Text("Guild Info").font(.title).foregroundColor(.red)
                        Text("GID: \(controller.joinedGuild!.id.uuidString)")
                        Text("Name: \(controller.joinedGuild!.name)")
                        Text("Citizens: \(controller.joinedGuild!.citizens.count)")
                        ForEach(controller.joinedGuild!.citizens, id:\.self) { citid in
                            Text(citid.uuidString).foregroundColor(.gray)
                        }
                    }
                    .padding([.top, .bottom])
                }
            }
            
            
            
            HStack {
                ForEach(controller.guilds, id:\.id) { guild in
                    VStack {
                        Text("Guild: \(guild.name)")
                            .foregroundColor(.yellow)
                        Text("Election: \(GameFormatters.dateFormatter.string(from: guild.election))")
                        Text("Citizens: \(guild.citizens.count)")
                        Text("Cities: \(guild.cities?.count ?? 0)")
                        if guild.members?.count ?? 0 <= 20 {
                            Button("Join") {
                                controller.requestJoinGuild(guild: guild)
                            }
                        }
                    }
                    .padding()
                    .background(Color.black)
                    .cornerRadius(12)
                    
                }
            }
            
            HStack {
                Button("Find Guild") {
                    controller.findMyGuild()
                }
                Button("Fetch Guilds") {
                    controller.fetchGuilds()
                }
                Button("New Login") {
                    controller.loginUser()
                }
            }
            .padding()
        }
        .padding()
        
    }
}

struct BackendView_Previews: PreviewProvider {
    static var previews: some View {
        BackendView(controller:BackendController())
    }
}

class BackendController:ObservableObject {
    
    @Published var news:String
    @Published var guilds:[Guild] = []
    @Published var player:SKNPlayer?
    @Published var user:SKNUser?
    @Published var joinedGuild:Guild?
    
    init() {
        news = "Do somthing first"
        
        if let player = LocalDatabase.shared.player {
//            isNewPlayer = false
            self.player = player
            self.user = SKNUser(player: player)
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
