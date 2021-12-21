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
                    
                    /// Left Side
                    Group {
                        VStack(alignment:.leading) {
                            
                            // Server Version
                            HStack(alignment:.lastTextBaseline) {
                                Text("Server").font(.title)
                                Text("version: 1.0").foregroundColor(.gray)
                                Spacer()
                            }
                            
                            Divider().padding(.trailing)
                            
                            Text(controller.guildJoinState.message)
                            
                            Spacer()
                            
                            switch controller.guildJoinState {
                                case .loading:
                                    ProgressView()
                                    Text("Loading info...")
                                    Text("Please be patient while we load your Guild info.")
                                        .foregroundColor(.gray)
                                case .noEntry:
                                    Text("No Entry").font(.title2).foregroundColor(.red)
                                    Text("You need an Entry ticker to go to mars.")
                                    Text("It can be acquired in the game's store")
                                    Text("With the purchase of any item.")
                                    Text("You may also get an extra one to give away.")
                                    
                                case .noGuild, .kickedOut, .choosing, .leaving:
                                    Text("You may browse guilds to find one that fits you")
                                    Text("Or create a new Guild - which costs one token.")
                                    
                                    HStack {
                                        Button("Browse") {
                                            controller.fetchGuilds()
                                        }
                                        .buttonStyle(GameButtonStyle())
                                        
                                        Button("Create") {
                                            controller.startCreatingGuild()
                                        }
                                        .buttonStyle(GameButtonStyle())
                                        
                                        if let selected = controller.selectedGuildObj {
                                            Button("Join \(selected.name)") {
                                                controller.requestJoin(selected)
                                            }
                                            .buttonStyle(GameButtonStyle())
                                        }
                                    }
                                    .padding()
                                    
                                case .joined(let guild):
                                    
                                    Text("You have joined this Guild.")
                                        .transition(.move(edge:.top).combined(with:AnyTransition.opacity))
                                        .animation(.spring(response: 0.5, dampingFraction: 0.75))
                                    
                                    Text("Although it may be sad, you can leave the Guild at anytime.").foregroundColor(.gray)
                                    
                                    if guild.president == LocalDatabase.shared.player.playerID ?? UUID() {
                                        Text("President !").font(.title)
                                        Text("You may have some extra functions as president.")
                                        Text("Look into the Chat Bubble.")
                                    } else {
                                        Text("Member ID: \(LocalDatabase.shared.player.playerID ?? UUID())")
                                    }
                                    // Leave
                                    Button("Leave") {
                                        controller.leaveGuild()
                                    }
                                    .buttonStyle(GameButtonStyle())
                                    .padding()
                                    
                                case .creating:
                                    Text("Creating new Guild")
                                    
                                case .error(let error):
                                    Text("⚠️ Uh-oh. Something's wrong!")
                                        .font(.title2)
                                        .foregroundColor(.red)
                                    Text(error.localizedDescription)
                                        .foregroundColor(.red)
                                
                            }
                        
                        }
                    }
                    
                    // Right Detail
                    switch controller.guildJoinState {
                        case .loading:
                            VStack {
                                EmptyGuildView()
                            }
                            
                        case .noEntry:
                            VStack {
                                EmptyGuildView()
                            }
                            
                        case .noGuild:
                            VStack {
                                Text("You have no Guild")
                                Text("Select one.")
                                if let guild = controller.selectedGuildObj {
                                    GuildView(controller: controller, guild:guild, style:.largeSummary)
                                } else {
                                    EmptyGuildView()
                                }
                            }
                            
                        case .joined(let jGuild):
                            VStack {
                                GuildView(controller:controller, guild:jGuild, style:.largeSummary)
                            }
                            
                        case .choosing:
                            VStack {
                                if let guild = controller.selectedGuildObj {
                                    GuildView(controller: controller, guild:guild, style:.largeSummary)
                                } else {
                                    EmptyGuildView()
                                }
                            }
                            
                        case .kickedOut:
                            
                            VStack {
                                Text("Kicked out").foregroundColor(.red)
                                Text("You've been kicked out of the Guild, ")
                                Text("or left the guild yourself.")
                                Text("Choose a Guild, or create one.")
                            }
                            
                        case .leaving:
                            VStack {
                                Text("Leaving Guild")
                                Text("You are noe leaving the Guild.")
                                Text("Give us a minute to save your city")
                                Text("So when you go to another Guild,")
                                Text("Your city will still be working.")
                                Text("You don't have to rebuild everything.")
                            }
                            
                        case .creating:
                            VStack {
                                GuildCreatorView { guildCreate, cancelled in
                                    if let guildCreate = guildCreate, cancelled == false {
                                        controller.didCreateGuild(guildCreate: guildCreate)
                                    } else {
                                        // Cancelled
                                        controller.guildJoinState = .choosing
                                    }
                                }
                            }
                            
                        case .error(let error):
                            VStack {
                                Text("Error \(error.localizedDescription)").foregroundColor(.red)
                                Text(controller.guildJoinState.message)
                            }
                    }
                }
                .padding(.horizontal)
                
                Divider()
                
                // Below (List of Guilds)
                switch controller.guildJoinState {
                    case .choosing, .noGuild, .kickedOut:
                        // Exploring
                        HStack {
                            Text("Select a Guild to join").font(.title2).foregroundColor(.blue)
                            Button("Refresh") {
                                controller.fetchGuilds()
                            }
                            .buttonStyle(GameButtonStyle())
                        }
                        
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
//                    if controller.myGuild == nil {
//                        Button("Join Guild") {
//                            print("Join")
//                            //                        controller.createGuild()
//                        }
//                        .buttonStyle(NeumorphicButtonStyle(bgColor:.blue))
//                    }
                    
                    // Guild
//                    if controller.myGuild != nil {
//                        Button("Leave Guild") {
//                            print("Leaving Guild")
//
//                            //                        controller.createGuild()
//                        }
//                        .buttonStyle(NeumorphicButtonStyle(bgColor:.blue))
//                    }
                }
            }
        }
    }
    
    
//    func closeviewaction() {
//
//    }
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

struct GameTabs_Previews2: PreviewProvider {
    static var previews:some View {
        TabView {
            
            let controller = GameSettingsController()
            // Settings
            GameSettingsTabView()
                .tabItem {
                    Label("Settings", systemImage:"gamecontroller")
                }
            // Game
            GameLoadingTab(controller:controller)
                .tabItem {
                    Label("Game", systemImage:"gamecontroller")
                }
            // Server
            SettingsServerTab(controller:controller)
                .tabItem {
                    Label("Server", systemImage:"gamecontroller")
                }
            
            // Player
            PlayerEditorView(controller:controller)
                .tabItem {
                    Label("Player", systemImage:"gamecontroller")
                }
        }
    }
}
