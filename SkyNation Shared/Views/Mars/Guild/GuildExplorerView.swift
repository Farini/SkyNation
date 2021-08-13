//
//  GuildExplorerView.swift
//  SkyNation
//
//  Created by Carlos Farini on 2/28/21.
//

import SwiftUI

/**
 A View to Explore and Create Guilds
 A Guild should be created such as when the user chooses to be public, or private. A private one should cost 10 tokens, and a public one should cost 5 tokens.
 Exploring: If a player has a guild, it must leave guild first. If not, the player can choose between create, or join guild.
 */
struct GuildExplorerView: View {
    
    @ObservedObject var controller:GameSettingsController
//    @ObservedObject var controller:GuildController
    
    var body: some View {
        ScrollView {
            
            VStack {
                Text("Guild Explorer").font(.title)
                    .padding([.top])
                Divider()
                
                HStack(alignment:.top) {
                    
                    VStack(alignment:.leading) {
                        // User Info
                        Group {
                            Text("User Info").font(.title).foregroundColor(.blue)
                            Divider()
//                            Text("GID: \(controller.user?.guildID?.uuidString ?? "n/a")")
//                                .font(.footnote)
//                            Text("PID: \(controller.upPlayer?.id.uuidString ?? "n/a")")
//                                .font(.footnote)
//                            Text("LID: \(controller.upPlayer?.localID.uuidString ?? "n/a")")
//                                .font(.footnote)
//                            Text("CID: \(controller.user?.cityID?.uuidString ?? "n/a")")
//                                .font(.footnote)
                            
                        }
                        .padding(.horizontal)
                        
                        // Guild Info
//                        Group {
//                            if let _ = controller.joinedGuild {
//                                Text("Guild Info").font(.title).foregroundColor(.red)
//                                    .padding(.top)
//                                Divider()
//                                Text("GID: \(controller.joinedGuild!.id.uuidString)")
//                                Text("Name: \(controller.joinedGuild!.name)")
//                                Text("Citizens: \(controller.joinedGuild!.citizens.count)")
//                                ForEach(controller.joinedGuild!.citizens, id:\.self) { citid in
//                                    Text(citid.uuidString).foregroundColor(.gray)
//                                }
//                            }
//                        }
//                        .padding(.horizontal)
                    }
                    /*
                    if let sGuild = controller.sGuild {
//                        GuildView(controller: controller, guild: sGuild.makeSummary(), style: .largeSummary)
                        Text(sGuild.name)
                    }
                    */
                }
                
                Divider()
        
                // Exploring
                HStack {
                    Text("Guild List").foregroundColor(.orange).font(.title2)
                    Spacer()
                }
                .padding(.horizontal)
                
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 130), spacing: 16, alignment: .top)], alignment: .center, spacing: 16) {
                    ForEach(controller.joinableGuilds, id:\.id) { guild in
                        Text("Guild \(guild.name)")
//                        GuildView(controller: controller, guild: guild, style: .thumbnail)
//                            .onTapGesture {
//                                self.didSelect(guild: guild)
//                            }
                    }
                }
                
                
                // Buttons
                HStack {
                    Button("Find Guild") {
                        print("Find")
//                        controller.findMyGuild()
                    }
                    .buttonStyle(NeumorphicButtonStyle(bgColor: .orange))
                    Button("Fetch Guilds") {
                        print("Fetch")
//                        controller.fetchGuilds()
                    }
                    .buttonStyle(NeumorphicButtonStyle(bgColor: .orange))
                    Button("New Login") {
                        print("login")
//                        controller.loginUser()
                    }
                    .buttonStyle(NeumorphicButtonStyle(bgColor: .orange))
                }
                .padding()
            }
            
            
        }
        .frame(minWidth: 700, idealWidth: 700, maxWidth: 900, minHeight: 500, idealHeight: 500, maxHeight: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
    }
    
    func select(guild: GuildSummary) {
        print("select")
//        withAnimation(.openCard) {
//            controller.highlightedGuild = guild
//        }
    }
    
    func didSelect(guild:Guild) {
        print("select")
//        withAnimation(.openCard) {
//            controller.sGuild = guild
//        }
    }
    
    func closeviewaction() {
        print("closeviewaction")
    }
}

struct GuildExplorerView_Previews: PreviewProvider {
    static var previews: some View {
        
        GuildExplorerView(controller: GameSettingsController())
            .previewLayout(.sizeThatFits)
            .frame(height: 700)
        
//        GuildExplorerView(controller: GuildController(autologin: false))
//            .previewLayout(.sizeThatFits)
//            .frame(height: 700)
    }
}
