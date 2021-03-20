//
//  PlayerEditView.swift
//  SkyNation
//
//  Created by Carlos Farini on 2/21/21.
//

import SwiftUI

// MARK: - 4 Tabs

// MARK: - Tab1: Loading
// MARK: - Tab2: Player
// MARK: - Tab3: Server
// MARK: - Tab4: Settings

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
//        var selCard:AvatarCard?
        
        for name in allNames {
            let card = AvatarCard(name: name)
            newCards.append(card)
            if controller.player.avatar == name {
//                selCard = card
//                card.selected = true
            }
        }
        
        self.cards = newCards
//        self.selectedCard = selCard
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
                                .background(self.selectedCard?.name == avtCard.name ? Color.red:Color.black)
                                .cornerRadius(8)
                                .onTapGesture {
                                    // Set the new avatar
                                    self.selectedCard = avtCard
                                    controller.didSelectAvatar(card: avtCard)
                                    highlightCard()
                                }
                            }
                        })
                    }
                    .frame(minHeight:140, maxHeight:250)
                    .background(LinearGradient(gradient: Gradient(colors: [Color.red.opacity(0.1), Color.blue.opacity(0.1)]), startPoint: .topLeading, endPoint: .bottomTrailing))
                    
                    // About
//                    VStack(alignment:.leading) {
//                        TextField("About", text: $about)
//                            .padding(.horizontal)
//                            .lineLimit(3)
//                            .cornerRadius(8)
                    
//                    Spacer(minLength: 8)
//                }
            }
            .onAppear() {
                self.selectedCard = cards.first(where: { $0.name == controller.player.avatar })
                self.about = controller.player.about
            }
        }
        
        }
    }
    
    func highlightCard() {
        let cardName = controller.player.avatar
        for card in cards {
            if card.name == cardName {
                self.selectedCard = card
            }
        }
//        let newCards = cards.sorted(by: { $0.id.uuidString < $1.id.uuidString })
//        self.cards = newCards
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
                
                HStack(alignment:.top) {
                    VStack(alignment:.leading, spacing:24) {
                        //                    Text("Player").font(.title)
                        //                    Divider()
                        Text("Server").font(.title)
                        Text("Server version: 1.0").foregroundColor(.gray)
                        Text("Guild")
                        
                        if let guild = controller.guild {
                            Text("\(guild.name)")
                            Text("\(guild.id.uuidString)")
                            Text("Cities: \(guild.cities?.count ?? 0)")
                        } else {
                            Text("No guild").foregroundColor(.gray)
                        }
                    }
                    
                    Spacer()
                    
                    if let guild = controller.guild {
                        // Make a Guild view with the full object
                        Text("G: \(guild.name)")
                    } else if let guild = controller.selectedGuildSum {
                        
                        GuildView(guild: guild, style: .largeSummary, closeAction: closeviewaction, flipAction: closeviewaction)
                    } else if let guild = controller.selectedGuildObj {
                        // Make another view for full object
                        Text("G: \(guild.name)")
                    }
                    
                }
                .padding(.horizontal)
                
                
                
                
                
                // Exploring
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 130), spacing: 16, alignment: .top)], alignment: .center, spacing: 16) {
                    ForEach(controller.joinableGuilds, id:\.id) { guild in
                        
                        GuildView(guild: guild, style: .thumbnail, closeAction: closeviewaction)
                            .onTapGesture {
                                print("Selecting: \(guild.name)")
                                select(guild: guild)
                            }
                    }
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
                        
                        Button("Fetch Guilds") {
                            controller.fetchGuilds()
                        }
                        .buttonStyle(NeumorphicButtonStyle(bgColor:.blue))
                    } else {
                        // Fetch My guild
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
    
    func select(guild: GuildSummary) {
        withAnimation(.openCard) {
            controller.selectedGuildSum = guild
        }
    }
    
    func closeviewaction() {
        print("Join Guild Action")
        controller.joinGuild(sum: controller.selectedGuildSum!)
        
    }
}

struct GameSettingsTabView: View {
    
    var settings:GameSettings
    
    @State var showTutorial:Bool = GameSettings.shared.showTutorial
    @State var useCloudData:Bool = GameSettings.shared.useCloud
    @State var showLights:Bool = GameSettings.shared.showLights
    @State var clearTanks:Bool = GameSettings.shared.clearEmptyTanks
    
    init() {
        self.settings = GameSettings.shared
    }
    
    var body:some View {
        ScrollView{
            VStack(alignment:.leading) {
                
                Text("Graphics").font(.title)
                Toggle("Show Lights", isOn:$showLights)
                
                Divider()
                Group {
                    Text("Gameplay").font(.title)
                    Toggle("Clear empty tanks", isOn:$clearTanks)
                    Toggle("Show Tutorial", isOn:$showTutorial)
                    Toggle("Use iCloud", isOn:$useCloudData)
                }
                
                Divider()
                Group {
                    Text("Data").font(.title)
                    Toggle("Use iCloud", isOn:$useCloudData)
                }
                
                Divider()
                
                Button("Save") {
                    print("Save Settings")
                    settings.showTutorial = self.showTutorial
                    settings.useCloud = self.useCloudData
                    settings.showLights = self.showLights
                    settings.clearEmptyTanks = self.clearTanks
                    settings.save()
                }
                .buttonStyle(NeumorphicButtonStyle(bgColor:.blue))
            }
            .padding(.horizontal)
        }
        
    }
    
}

// MARK: - Previews

struct PlayerEditView_Previews: PreviewProvider {
    static var previews: some View {
//        PlayerEditView(controller: GameSettingsController())
        SettingsServerTab(controller:GameSettingsController())
    }
}

struct GameTabs_Previews2: PreviewProvider {
    static var previews:some View {
        TabView {
            // Settings
            GameSettingsTabView()
                .tabItem {
                    Label("Settings", systemImage:"gamecontroller")
                }
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
            
            
            // Player
            PlayerEditView(controller:GameSettingsController())
                .tabItem {
                    Label("Player", systemImage:"gamecontroller")
                }
        }
        
        
        
    }
}


