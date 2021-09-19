//
//  PlayerEditView.swift
//  SkyNation
//
//  Created by Carlos Farini on 2/21/21.
//

import SwiftUI

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


