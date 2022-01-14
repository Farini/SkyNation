//
//  PlayerEditView.swift
//  SkyNation
//
//  Created by Carlos Farini on 2/21/21.
//

import SwiftUI

// MARK: - Tab2: Player

struct PlayerEditorView: View {
    
    @ObservedObject var controller:GameSettingsController
    
    enum EditorStep {
        case Displaying
        case TypingName
        case ChoosingAvatar
        case Confirming
    }
    
    @State private var editorStep:EditorStep = .TypingName
    
    /// Look into game center to set the player's name
    var gameCenterManager:GameCenterManager = GameCenterManager.shared
    
    var body: some View {
        ScrollView {
            
            VStack(alignment:.leading) {
                
                // Header
                Text("Player")
                    .font(GameFont.title.makeFont())
                    .padding(.vertical)
                
                Divider()
                
                switch editorStep {
                        
                    case .Displaying:
                        
                        HStack {
                            Image("\(controller.player.avatar)")
                                .resizable()
                                .frame(width:82, height:82)
                            VStack(alignment:.leading) {
                                Text(controller.player.name)
                                Text("XP: \(controller.player.experience)")
                                Text("Online: \(GameFormatters.dateFormatter.string(from:controller.player.lastSeen))")
                                    // .foregroundColor(.green)
                            }
                        }
                        .transition(.slide.combined(with:AnyTransition.opacity))
                        
                        Divider()
                        
                        HStack {
                            Button("Edit Player") {
                                self.editorStep = .TypingName
                            }
                            .buttonStyle(GameButtonStyle())
                        }
                        .padding(6)
                        
                        
                    case .TypingName:
                        // Name
                        Text("Please type your name")
                            .foregroundColor(.gray)
                            .padding(6)
                        
                        
                        TextField("name", text: $controller.playerName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(width: 150)
                                .cornerRadius(8)
                                .padding(.bottom, 6)
                                .transition(.slide.combined(with:AnyTransition.opacity))
                            
                        Text("\(controller.playerName.count) of max 12 characters")
                                .foregroundColor(controller.playerName.count == 12 ? .red:.gray)
                        
                        Divider()
                        
                        Text("This will be your nickname, as it will appear on your Player Card, and shared with other Guild members.")
                            .foregroundColor(.gray)
                            .font(.footnote)
                            .padding(.horizontal, 30)
                        
                        HStack {
                            
                            Button("Cancel") {
                                self.editorStep = .Displaying
                            }
                            .buttonStyle(GameButtonStyle())
                            
                            Button("Continue") {
                                print("ok")
                                self.editorStep = .ChoosingAvatar
                            }
                            .buttonStyle(GameButtonStyle())
                        }
                        .padding(.vertical, 6)
                        .transition(.move(edge:.leading).combined(with:AnyTransition.opacity))
                        .animation(.spring(response: 0.5, dampingFraction: 0.75))
                        
                        
                    case .ChoosingAvatar:
                        
                        Text("Select an Avatar")
                            .foregroundColor(.gray)
                            .padding(6)
                        
                        // Avatar
                        LazyVGrid(columns: [GridItem(.fixed(96)), GridItem(.fixed(96)), GridItem(.fixed(96)), GridItem(.fixed(96)), GridItem(.fixed(96))], alignment: .center, spacing: 8, pinnedViews: [], content: {
                            
                            ForEach(PlayerEditorView.getAllCards()) { avtCard in
                                ZStack(alignment: .bottom) {
                                    Image(avtCard.name)
                                        .resizable()
                                        .frame(width: 82, height: 82, alignment: .center)
                                }
                                .padding(.vertical)
                                .background(controller.player.avatar == avtCard.name ? Color.red:Color.black)
                                .cornerRadius(8)
                                .onTapGesture {
                                    self.highlightCard(avtCard)
                                }
                            }
                        })
                        .frame(minHeight:140)
                        .background(LinearGradient(gradient: Gradient(colors: [Color.red.opacity(0.1), Color.blue.opacity(0.1)]), startPoint: .topLeading, endPoint: .bottomTrailing))
                        
                        Divider()
                        
                        HStack {
                            
                            Button("Back") {
                                self.editorStep = .TypingName
                            }
                            .buttonStyle(GameButtonStyle())
                            
                            Button("Update Player") {
                                controller.updateServerWith(player: controller.player)
                            }
                            .buttonStyle(GameButtonStyle())
                            .onChange(of: controller.updatedPlayer) { newUpdatedPlayer in
                                self.editorStep = .Confirming
                            }
                        }
                        .padding(.vertical, 6)
                        .transition(.move(edge:.leading).combined(with:AnyTransition.opacity))
                        .animation(.spring(response: 0.5, dampingFraction: 0.75))
                        
                        
                    case .Confirming:
                        
                        Text("Confirmation")
                            .foregroundColor(.gray)
                            .padding(6)
                        
                        Divider()
                        
                        if let updated = controller.updatedPlayer {
                            Text("\(updated.name) updated.")
                                .foregroundColor(.green)
                                .padding()
                        } else if let warning = controller.warningList.first {
                            Text(warning)
                                .foregroundColor(.red)
                                .padding()
                        } else {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                            Text("Please wait a moment for SkyNation to compute new changes.")
                        }
                        
                        HStack {
                            Button("Start Over") {
                                self.editorStep = .TypingName
                            }
                            .buttonStyle(GameButtonStyle())
                            
                            Button("View Player") {
                                self.editorStep = .Displaying
                            }
                            .buttonStyle(GameButtonStyle())
                        }
                        .transition(.move(edge:.leading).combined(with:AnyTransition.opacity))
                        .animation(.spring(response: 0.5, dampingFraction: 0.75))
                }
            }
            .padding(.horizontal)
        }
        .onAppear {
            // Set the player name to their Game Center name, if possible
            if controller.player.experience == 0 && controller.playerName == "Test Player" {
                var pName = gameCenterManager.gcPlayer?.alias ?? "Test Player"
                if pName.count > 12 {
                    pName = String(pName.prefix(12))
                }
                controller.playerName = pName
                
            }
        }
    }
    
    func highlightCard(_ card:AvatarCard) {
        controller.didSelectAvatar(card: card)
    }
    
    static func getAllCards() -> [AvatarCard] {
        let avatarNames:[String] =  HumanGenerator().female_avatar_names + HumanGenerator().male_avatar_names
        // Build the image options (avatars)
        var newCards:[AvatarCard] = []
        for name in avatarNames {
            let card = AvatarCard(name: name)
            newCards.append(card)
        }
        return newCards
    }
    
}

// MARK: - Previews

struct PlayerEditorPreview: PreviewProvider {
    static var previews:some View {
        PlayerEditorView(controller: GameSettingsController())
    }
}
