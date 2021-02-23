//
//  PlayerEditView.swift
//  SkyNation
//
//  Created by Carlos Farini on 2/21/21.
//

import SwiftUI

struct PlayerEditView: View {
    
    @ObservedObject var controller:GameSettingsController
    
    var allNames:[String]
    var cards:[AvatarCard]
    
    @State var selectedCard:AvatarCard?
    @State var about:String = ""
    
    init(controller:GameSettingsController) {
        self.allNames = HumanGenerator().female_avatar_names + HumanGenerator().male_avatar_names
        self.controller = controller
        var newCards:[AvatarCard] = []
//        var newViews:[AvatarCardView] = []
        for name in allNames {
            let card = AvatarCard(name: name)
            newCards.append(card)
        }
//        for card in newCards {
//            let avt = AvatarCardView(card: card)
//            newViews.append(avt)
//        }
        
        self.cards = newCards
//        self.avtViews = newViews
    }
    
    var body: some View {
        ScrollView {
            
            VStack {
                
                
                
                Group {
                    HStack {
                        
                        // Left
                        VStack(alignment:.leading) {
                            TextField("Name:", text: $controller.playerName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(width: 150)
                                .cornerRadius(8)
                            
                            Text("ID: \(controller.playerID.uuidString)")
                                .foregroundColor(.gray)
                                .font(.caption2)
                        }
                        .padding([.leading])
                        Spacer()
                        
                        // Right
                        VStack(alignment:.trailing) {
                            Text("Tokens \(controller.player.timeTokens.count)")
                            Text("Money: \(controller.player.money)")
                            Text("Experience: \(controller.player.experience)")
                        }
                        .padding([.trailing])
                    }
                    
                    Spacer()
                    
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.fixed(96)), GridItem(.fixed(96)), GridItem(.fixed(96)), GridItem(.fixed(96)), GridItem(.fixed(96))], alignment: .center, spacing: 8, pinnedViews: [], content: {
                            ForEach(cards) { avtCard in
                                ZStack(alignment: .bottom) {
                                    Image(avtCard.name)
                                        .resizable()
                                        .frame(width: 82, height: 82, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                                }
                                .padding(.vertical)
                                .background(selectedCard == avtCard ? Color.red:Color.black)
                                .cornerRadius(8)
                            }
                        })
                    }
                    .frame(minHeight:140, maxHeight:250)
                    
                    // About
                    VStack(alignment:.leading) {
                        TextField("About:", text: $about)
//                            .textFieldStyle(RoundedBorderTextFieldStyle())
//                            .frame(width: .m)
                            .padding(.horizontal)
                            .lineLimit(3)
                            .cornerRadius(8)
                    
                    Spacer(minLength: 8)
                }
            }
            .onAppear() {
                self.selectedCard = cards.first(where: { $0.name == controller.player.avatar })
                self.about = controller.player.about
            }
        }
        
        }
    }
    
}

// MARK: - Other Tabs


struct LoadingGameTab: View {
    var body: some View {
        VStack {
            Text("Loading game")
            Text("Game, blah...")
            Spacer()
            Divider()
            Button("Start Game") {
//                controller.createGuild()
            }
            .foregroundColor(.red)
            .buttonStyle(NeumorphicButtonStyle(bgColor:.blue))
        }
    }
}

struct SettingsServerTab:View {
    
    @ObservedObject var controller:GameSettingsController
    
    var body: some View {
        
        ScrollView {
            
            VStack {
                Text("Player").font(.title)
                Text("Fetch player pending...").foregroundColor(.gray)
                Divider()
                Text("Server").font(.title)
                Text("Server version: 1.0").foregroundColor(.gray)
                Text("Guild")
                if let guild = controller.guild {
                    Text("\(guild.name)")
                    Text("\(guild.id.uuidString)")
                    Text("Cities: \(guild.cities?.count ?? 0)")
                }else {
                    Text("No guild").foregroundColor(.gray)
                }
                Divider()
                // Buttons
                HStack {
                    // User
                    if controller.user != nil {
                        Button("Fetch User") {
                            controller.fetchUser()
                        }
                        .buttonStyle(NeumorphicButtonStyle(bgColor:.blue))
                    }
                    
                    // Create
                    if controller.guild == nil {
                        Button("Create Guild") {
                            controller.createGuild()
                        }
                        .foregroundColor(.red)
                        .buttonStyle(NeumorphicButtonStyle(bgColor:.blue))
                        
                    }
                    // Join
                    if controller.guild == nil {
                        Button("Join Guild") {
                            print("Join")
                            //                        controller.createGuild()
                        }
                        .buttonStyle(NeumorphicButtonStyle(bgColor:.blue))
                    }
                    // Guild
                    if controller.guild != nil {
                        Button("Leave Guild") {
                            print("Leaving Guild")
                            
                            //                        controller.createGuild()
                        }
                        .buttonStyle(NeumorphicButtonStyle(bgColor:.blue))
                        
                    }
                }
            }
        }
    }
}

struct PlayerEditView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerEditView(controller: GameSettingsController())
    }
}


struct GameTabs_Previews2: PreviewProvider {
    static var previews:some View {
        TabView {
            // Game
            LoadingGameTab()
                .tabItem {
                    Label("Game", systemImage:"gamecontroller")
                }
            // Server
            SettingsServerTab(controller:GameSettingsController())
                .tabItem {
                    Label("Server", systemImage:"gamecontroller")
                }
            // Settings
            GameSettingsTabView()
                .tabItem {
                    Label("Settings", systemImage:"gamecontroller")
                }
            
            // Player
            PlayerEditView(controller:GameSettingsController())
                .tabItem {
                    Label("Player", systemImage:"gamecontroller")
                }
        }
        
        
        
    }
}

struct GameSettingsTabView: View {
    
    @State var settings:GameSettings = GameSettings.shared
    
    var body:some View {
        VStack {
            
            // Settings
            Group {
                Text("Settings").font(.title)
                Toggle("Show Tutorial", isOn:$settings.showTutorial)
                Toggle("Use iCloud", isOn:$settings.useCloud)
            }
            
            
            Text("Graphics").font(.title)
            Toggle("Show Lights", isOn:$settings.showLights)
            
            Group {
                Text("Display Settings")
                Text("Graphic Settings")
                Text("Player Preferences")
                Text("Data Saving")
            }
            
            
            Divider()
            
            Button("Save") {
                print("Save Settings")
            }
            .buttonStyle(NeumorphicButtonStyle(bgColor:.blue))
        }
    }
}
