//
//  SettingsServerTab.swift
//  SkyNation
//
//  Created by Carlos Farini on 8/12/21.
//

import SwiftUI

/// The `Server` tab of the App's Settings View
struct SettingsServerTab:View {
 
    @ObservedObject var controller:GameSettingsController
 
    var body: some View {
        
        ScrollView {
            
            VStack {
                
                HStack(alignment:.top) {
                    
                    /// General Info
                    Group {
                        VStack(alignment:.leading, spacing:24) {
                            
                            Text("Server").font(.title)
                            Text("Server version: 1.0").foregroundColor(.gray)
                            
                            Text("Guild")
                            Text(controller.guildJoinState.message)
                            
                            if let guild = controller.myGuild {
                                Text("\(guild.name)")
                                Text("\(guild.id.uuidString)")
                                Text("Cities: \(guild.cities.count)")
                            } else {
                                Text("No guild").foregroundColor(.gray)
                            }
                        }
                        
                        Spacer()
                    }
                    
                    switch controller.guildJoinState {
                        case .loading:
                            VStack {
                                ProgressView()
                                Text("Loading info...")
                            }
                        case .noGuild:
                            VStack {
                                Text("You have no Guild")
                                Text("Select one.")
                            }
                        case .joined(let jGuild):
                            VStack {
                                Text("Joined \(jGuild.name)")
                                GuildView(controller:controller, guild:jGuild, style:.largeSummary)
                            }
                            
                        case .choosing:
                            VStack {
                                if let guild = controller.selectedGuildObj {
                                    GuildView(controller: controller, guild:guild, style:.largeSummary)
                                } else {
                                    Text("Select a Guild from the list below to join")
                                }
                            }
                            
                        case .kickedOut:
                            VStack {
                                Text("Kicked out").foregroundColor(.red)
                                Button("Choose Guild") {
                                    print("Choose")
                                }
                                // .buttonStyle(NeumorphicButtonStyle())
                            }
                            
                            
                        case .noEntry:
                            VStack {
                                Text("No Entry")
                                Text("Purchase something to get Mars Entry")
                            }
                        case .leaving:
                            VStack {
                                Text("Leaving Guild")
                            }
                            
                        case .error(_):
                            VStack {
                                Text("Error")
                                Text(controller.guildJoinState.message)
                            }
                    }
                }
                .padding(.horizontal)
                
                Divider()
                
                switch controller.guildJoinState {
                    case .choosing:
                        // Exploring
                        Text("Select a Guild to see details")
                        
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 130), spacing: 16, alignment: .top)], alignment: .center, spacing: 16) {
                            
                            ForEach(controller.joinableGuilds, id:\.id) { guild in
                                GuildSummaryView(guildSum: guild)
                                    .onTapGesture {
                                        controller.fetchGuildDetails(guildSum: guild)
                                    }
                            }
                        }
                        
                    default:EmptyView()
                }
                
                // Buttons
                HStack {
                    
                    // User
//                    if guildController.upPlayer != nil {
//                        Button("Fetch User") {
//                            controller.fetchUser()
//                        }
//                        .buttonStyle(NeumorphicButtonStyle(bgColor:.blue))
//                    }
                    
                    // Create
//                    if controller.myGuild == nil {
//                        Button("Create Guild") {
//                            controller.createGuild()
//                        }
//                        .foregroundColor(.red)
//                        .buttonStyle(NeumorphicButtonStyle(bgColor:.blue))
//
//                        Button("Fetch Guilds") {
//                            //                            controller.fetchGuilds()
//                            guildController.fetchGuilds()
//                        }
//                        .buttonStyle(NeumorphicButtonStyle(bgColor:.blue))
//                    } else {
//                        // Fetch My guild
//                    }
                    
                    // Join
                    if controller.myGuild == nil {
                        Button("Join Guild") {
                            print("Join")
                            //                        controller.createGuild()
                        }
                        .buttonStyle(NeumorphicButtonStyle(bgColor:.blue))
                    }
                    
                    // Guild
                    if controller.myGuild != nil {
                        Button("Leave Guild") {
                            print("Leaving Guild")
                            
                            //                        controller.createGuild()
                        }
                        .buttonStyle(NeumorphicButtonStyle(bgColor:.blue))
                    }
                }
                
//                if !guildController.news.isEmpty {
//                    Text(guildController.news)
//                }
            }
        }
    }
    
//    func select(guild: GuildSummary) {
////        withAnimation(.openCard) {
////            controller.selectedGuildSum = guild
////        }
//    }
    
    func closeviewaction() {
//        print("Join Guild Action")
//        controller.joinGuild(sum: controller.selectedGuildSum!)
        
    }
 }
 

struct SettingsServerTab_Previews: PreviewProvider {
    static var previews: some View {
        // Server
        SettingsServerTab(controller:GameSettingsController())
//            .tabItem {
//                Label("Server", systemImage:"gamecontroller")
//            }
    }
}
