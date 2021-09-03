//
//  PlayerEditView.swift
//  SkyNation
//
//  Created by Carlos Farini on 2/21/21.
//

import SwiftUI

// MARK: - Tab1: Loading

struct GameLoadingTab: View {
    
    var controller:GameSettingsController
    
    var body: some View {
        VStack {
            HStack {
                Image("\(controller.player.avatar)")
                    .resizable()
                    .frame(width:82, height:82)
                VStack(alignment:.leading) {
                    Text(controller.player.name)
                    Text("XP: \(controller.player.experience)")
                    Text("Online: \(GameFormatters.dateFormatter.string(from:controller.player.lastSeen))")
                        .foregroundColor(.green)
                    HStack(alignment:.center) {
                        #if os(macOS)
                        Image(nsImage:GameImages.tokenImage)
                            .resizable()
                            .frame(width:32, height:32)
                        #else
                        Image(uiImage:GameImages.tokenImage)
                            .resizable()
                            .frame(width:32, height:32)
                        #endif
                        Text("x\(controller.player.countTokens().count)") //timeTokens.count)")
                        Divider()
                        #if os(macOS)
                        Image(nsImage:GameImages.currencyImage)
                            .resizable()
                            .frame(width:32, height:32)
                        #else
                        Image(uiImage: GameImages.currencyImage)
                            .resizable()
                            .frame(width:32, height:32)
                        #endif
                        Text("\(controller.player.money)")
                    }
                    .frame(height:36)
                }
                Spacer()
                Image("EntranceLogo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width:300)
            }
            
            if controller.isNewPlayer {
                Text("New Player")
                    .foregroundColor(.orange)
                    .font(.headline)
            }
            
            Group {
                
                ForEach(controller.loadedList, id:\.self) { litem in
                    Text(litem).foregroundColor(.gray)
                }
                ForEach(controller.warningList, id:\.self) { litem in
                    Text(litem).foregroundColor(.orange)
                }
                
                if let string = controller.fetchedString {
                    Text("Fetched:\n\(string)")
                }
                
//                if let loggedUser = controller.upPlayer {
//                    Text("Fetched User: \(loggedUser.name)")
//                }
                
                Spacer(minLength: 8)
            }
        }
        
    }
}

// MARK: - Tab2: Player

struct PlayerEditView: View {
    
    @ObservedObject var controller:GameSettingsController
    
    var allNames:[String]
    var cards:[AvatarCard]
    
    @State var selectedCard:AvatarCard?
    @State var about:String = ""
    
    init(controller:GameSettingsController) {
        
        self.allNames = HumanGenerator().female_avatar_names + HumanGenerator().male_avatar_names
        self.controller = controller
        
        // Build the image options (avatars)
        var newCards:[AvatarCard] = []
        for name in allNames {
            let card = AvatarCard(name: name)
            newCards.append(card)
            if controller.player.avatar == name {
            }
        }
        
        self.cards = newCards
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
                            Text("Tokens \(controller.player.countTokens().count)") //timeTokens.count)")
                            Text("Money: \(controller.player.money)")
                            Text("Experience: \(controller.player.experience)")
                        }
                        .padding([.trailing])
                    }
                    
                    Spacer()
                    
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
                    .frame(minHeight:140)
                    .background(LinearGradient(gradient: Gradient(colors: [Color.red.opacity(0.1), Color.blue.opacity(0.1)]), startPoint: .topLeading, endPoint: .bottomTrailing))
                    
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
    }
    
}


// MARK: - Tab3: Server


// MARK: - Tab4: Settings
struct GameSettingsTabView: View {
    
    var settings:GameSettings
    
    @State var showTutorial:Bool = GameSettings.shared.showTutorial
    @State var useCloudData:Bool = GameSettings.shared.useCloud
    @State var showLights:Bool = GameSettings.shared.showLights
    @State var clearTanks:Bool = GameSettings.shared.clearEmptyTanks
    @State var mergeTanks:Bool = GameSettings.shared.autoMergeTanks
    @State var startingScene:GameSceneType = GameSettings.shared.startingScene
    
    
    @State var musicOn:Bool = GameSettings.shared.musicOn
    @State var soundFXOn:Bool = GameSettings.shared.soundFXOn
    
    init() {
        self.settings = GameSettings.shared
    }
    
    var body:some View {
        ScrollView {
            VStack(alignment:.leading) {
                
                Text("Graphics").font(.title)
                Toggle("Show Lights", isOn:$showLights)
                
                Divider()
                
                HStack(alignment:.top) {
                    VStack(alignment: .leading) {
                        Text("Gameplay").font(.title)
                        Picker(selection: $startingScene, label: Text("Main Scene")) {
                            ForEach(GameSceneType.allCases, id:\.self) { sceneCase in
                                Text(sceneCase.rawValue)
                                    .onTapGesture {
                                        print("Set another scene")
                                    }
                            }
                        }
                        .frame(maxWidth: 200)
                        Toggle("Clear empty tanks", isOn:$clearTanks)
                        Toggle("Auto merge Tanks", isOn:$mergeTanks)
                        Toggle("Show Tutorial", isOn:$showTutorial)
                    }
                    Spacer()
                    VStack(alignment: .leading) {
                        Text("Sounds").font(.title)
                        Toggle("Music", isOn:$musicOn)
                        Toggle("Sound FX", isOn:$soundFXOn)
                        Toggle("Dialogue", isOn:$soundFXOn)
                    }
                    Spacer()
                }
                
                Divider()
                Group {
                    Text("Data").font(.title)
                    Toggle("Use iCloud", isOn:$useCloudData)
                }
                
                Divider()
                
                Button("Save") {
                    print("Save Settings")
                    
                    // Data
                    settings.useCloud = self.useCloudData
                    
                    // Graphics
                    settings.showLights = self.showLights
                    
                    // Logic preferences
                    settings.clearEmptyTanks = self.clearTanks
                    settings.showTutorial = self.showTutorial
                    
                    // Sounds
                    settings.musicOn = self.musicOn
                    settings.soundFXOn = self.soundFXOn
                    settings.dialogueOn = self.soundFXOn
                    
                    settings.save()
                }
                .buttonStyle(NeumorphicButtonStyle(bgColor:.blue))
            }
            .padding(.horizontal)
        }
        
    }
    
}

// MARK: - Previews

struct ServerViewView_Previews: PreviewProvider {
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
            GameLoadingTab(controller:GameSettingsController())
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


