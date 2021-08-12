//
//  BackendView.swift
//  SkyNation
//
//  Created by Carlos Farini on 2/6/21.
//

import SwiftUI

struct BackendView: View {
    
    @ObservedObject var controller:GuildController
    
    var body: some View {
        
        VStack {
            
            Group {
                Text("Back End").foregroundColor(.green).font(.largeTitle)
                Divider()
                Text("News")
                Text(controller.news).foregroundColor(.gray)
            }
            
            
            // User Info
            Group {
                VStack(alignment:.leading) {
                    Text("User Info").font(.title).foregroundColor(.blue)
//                    Text("GID: \(controller.user?.guildID?.uuidString ?? "n/a")")
                    Text("PID: \(controller.upPlayer?.id.uuidString ?? "n/a")")
                    Text("LID: \(controller.upPlayer?.localID.uuidString ?? "n/a")")
//                    Text("CID: \(controller.user?.cityID?.uuidString ?? "n/a")")
                }
                .padding([.top, .bottom])
            }
            
            // Guild Info
            Group {
                if controller.joinedGuild != nil {
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
//                        Text("Election: \(GameFormatters.dateFormatter.string(from: guild.election))")
                        Text("Citizens: \(guild.citizens.count)")
                        Text("Cities: \(guild.cities.count)")
                        if guild.citizens.count <= 9 {
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
                    controller.guilds = []
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
        BackendView(controller:GuildController(autologin: false))
    }
}

