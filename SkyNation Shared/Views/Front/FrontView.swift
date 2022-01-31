//
//  FrontView.swift
//  SkyNation
//
//  Created by Carlos Farini on 1/26/22.
//

import SwiftUI

struct FrontView: View {
    
    @ObservedObject var controller:FrontController
    
    @State var selectedAvatar:AvatarCard?
    
    enum ViewMode {
        case loading
        case playerEdit
        case settings
    }
    @State var viewMode:ViewMode = .loading
    
    @State var saturated:Double = 1.0
    
    var body: some View {
        ZStack {
            
            Image("FrontImage1")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .saturation(0.5)
                .brightness(0.01)
                //  .hueRotation(Angle.init(degrees: 90))
                //  .contrast(0.0)
                .frame(minWidth:900)
            
            // EntryShaderTest()
            
            VStack {
                switch viewMode {
                    case .loading:
                        // loading
                        
                            Image("EntranceLogo")
                            
                            // Player Status
                            HStack(alignment:.top, spacing:12) {
                                
                                // Player Avatar + Edit
                                VStack {
                                    Image(controller.player.avatar)
                                        .resizable()
                                        .frame(width: 96, height: 96, alignment: .center)
                                }
                                
                                // Player Name, info, online
                                VStack(alignment:.leading) {
                                    
                                    HStack {
                                        VStack(alignment:.leading) {
                                            Text(controller.player.name).font(GameFont.section.makeFont())
                                            Text("XP: \(controller.player.experience)").font(GameFont.mono.makeFont())
                                        }
                                    }
                                    
                                    HStack(alignment:.center) {
                                        Image(GameImages.currencyImageName)
                                            .resizable()
                                            .frame(width:28, height:28)
                                        Text("x\(controller.player.countTokens().count)") //timeTokens.count)")
                                        Divider()
                                        Image(GameImages.tokenImageName)
                                            .resizable()
                                            .frame(width: 28, height: 28)
                                        Text("\(controller.player.money)")
                                    }
                                    .frame(height:32)
                                    
                                    Text("Online: \(GameFormatters.dateFormatter.string(from:controller.player.lastSeen))")
                                        .font(.footnote)
                                        .foregroundColor(.green)
                                }
                            }
                            .frame(maxWidth:350)
                            
                            // Messages & Warnings
                            VStack(alignment:.leading) {
                                ForEach(controller.loadedList, id:\.self) { lString in
                                    Text(lString).foregroundColor(.gray)
                                        .transition(.slide)
                                }
                                ForEach(controller.warningList, id:\.self) { lString in
                                    Text(lString).foregroundColor(.red)
                                        .transition(.slide)
                                }
                                Divider()
                                    .frame(maxWidth:350)
                            }
                            
                            // Buttons
                            HStack {
                                // Edit button
                                Button {
                                    // print("Click me")
                                    withAnimation() {
                                        self.viewMode = .settings
                                    }
                                } label: {
                                    HStack {
                                        Image(systemName: "gear")
                                        Text("Settings")
                                    }
                                }
                                .buttonStyle(GameButtonStyle())
                                .transition(.slide.combined(with: .opacity))
                                
                                Divider().frame(height:20)
                                
                                // Start
                                Button(action: {
                                    print("Start game")
                                    // controller.star
                                    guard let scene = controller.stationScene else {
                                        print("Controller didn't load the scene.")
                                        return
                                    }
                                    controller.startGame(scene: scene)
                                    
                                }, label: {
                                    HStack {
                                        Image(systemName: "play.circle")
                                        Text("Start")
                                    }
                                })
                                .buttonStyle(GameButtonStyle())
                                .disabled($controller.stationScene.wrappedValue == nil)
                                .transition(.slide.combined(with: .opacity))
                            }
                            
                    case .playerEdit:
                        
                        ScrollView {
                            VStack {
                                // Header
                                HStack {
                                    Text("Edit Player").font(GameFont.title.makeFont())
                                    Divider().frame(height:20)
                                    Button {
                                        withAnimation() {
                                            self.viewMode = .settings
                                        }
                                    } label: {
                                        HStack {
                                            Image(systemName: "gear")
                                            Text("Game Settings")
                                        }
                                    }
                                    .buttonStyle(GameButtonStyle())
                                    if controller.playerName != controller.player.name {
                                        Button("💾 Save") {
                                            // print("save \(selectedAvatar.name)")
                                            // make sure the player name is valid
                                            if validatePlayername() == true {
                                                controller.didEditPlayer(new: controller.playerName, avatar: selectedAvatar?.name ?? controller.player.avatar) { playerUpdate, error in
                                                    // ----------------
                                                    // Deal with error?
                                                    // ----------------
                                                }
                                            }
                                        }
                                        .buttonStyle(GameButtonStyle())
                                        .transition(.slide.combined(with: .opacity))
                                    } else if let selectedAvatar = $selectedAvatar.wrappedValue {
                                        Button("💾 Save") {
                                            print("save \(selectedAvatar.name)")
                                            // no modifications in name
                                            controller.didEditPlayer(new: controller.playerName, avatar: selectedAvatar.name) { playerUpdate, error in
                                                // ----------------
                                                // Deal with error?
                                                // ----------------
                                            }
                                        }
                                        .buttonStyle(GameButtonStyle())
                                        .transition(.slide.combined(with: .opacity))
                                    } else {
                                        if let scene = controller.stationScene {
                                            Button(action: {
                                                controller.startGame(scene: scene)
                                            }, label: {
                                                HStack {
                                                    Image(systemName: "play.circle")
                                                    Text("Start")
                                                }
                                            })
                                            .buttonStyle(GameButtonStyle())
                                            .transition(.slide.combined(with: .opacity))
                                        }
                                       
                                    }
                                }
                                Divider()
                                
                                // Warnings
                                if !controller.warningList.isEmpty {
                                    Text("\(controller.warningList.joined(separator: ", "))").foregroundColor(.red)
                                }
                                
                                // Name Group
                                Group {
                                    Text("Player name").font(GameFont.section.makeFont())
                                        .padding(.top, 4)
                                    
                                    HStack {
                                        TextField("Name", text:$controller.playerName)
                                            .frame(width:150)
                                            .textFieldStyle(.roundedBorder)
                                        Image(systemName: "xmark.circle")
                                            .onTapGesture {
                                                controller.playerName = ""
                                            }
                                    }
                                    let ct = controller.playerName.count
                                    if ct < 3 {
                                        Text("needs at least 3 characters").foregroundColor(.red)
                                    } else {
                                        Text("\(controller.playerName.count) of max 12 characters")
                                            .foregroundColor(controller.playerName.count == 12 ? .red:.gray)
                                    }
                                    
                                }
                                
                                // Avatar Group
                                Group {
                                    
                                    Text("Avatar").font(GameFont.section.makeFont())
                                        .padding(.top)
                                    // Avatar
                                    LazyVGrid(columns: [GridItem(.fixed(96)), GridItem(.fixed(96)), GridItem(.fixed(96)), GridItem(.fixed(96)), GridItem(.fixed(96))], alignment: .center, spacing: 8, pinnedViews: [], content: {
                                        
                                        ForEach(PlayerEditorView.getAllCards()) { avtCard in
                                            ZStack(alignment: .bottom) {
                                                Image(avtCard.name)
                                                    .resizable()
                                                    .frame(width: 82, height: 82, alignment: .center)
                                            }
                                            .padding(.vertical)
                                            .background(controller.player.avatar == avtCard.name ? Color.red:Color.white.opacity(0.05))
                                            .cornerRadius(8)
                                            .onTapGesture {
                                                self.selectedAvatar = avtCard
                                                controller.player.avatar = avtCard.name
                                            }
                                        }
                                    })
                                        .frame(minHeight:140)
                                }
                                Spacer()
                            }
                        }
                        .frame(minWidth: 600, maxWidth: 900, minHeight: 450, maxHeight: 600)
                        
                    case .settings:
                        
                        HStack {
                            Text("Game Settings").font(GameFont.title.makeFont())
                            Divider().frame(height:20)
                            
                            // Player Edit
                            Button {
                                withAnimation() {
                                    self.viewMode = .playerEdit
                                }
                            } label: {
                                HStack {
                                    Image(systemName: "gear")
                                    Text("Edit Player")
                                }
                            }
                            .buttonStyle(GameButtonStyle())
                            
                            // Start
                            if let scene = controller.stationScene {
                                Button(action: {
                                    controller.startGame(scene: scene)
                                }, label: {
                                    HStack {
                                        Image(systemName: "play.circle")
                                        Text("Start")
                                    }
                                })
                                .buttonStyle(GameButtonStyle())
                                .transition(.slide.combined(with: .opacity))
                            }
                        }
                        .padding(.horizontal)
                        
                        Divider().frame(width:600)
                        
                        ScrollView {
                            VStack {
                                GameSettingsTabView()
                            }
                        }
                        .frame(minWidth: 600, maxWidth: 900, minHeight: 450, maxHeight: 600)
                }
            }
            .padding()
            .background(Color.black.opacity(0.75))
            .cornerRadius(10)
        }
        .frame(minWidth: 900, maxWidth: .infinity, minHeight: 500, maxHeight: .infinity, alignment: .center)
        
        .onAppear{
            effect()
            // Check if new player
            if controller.isNewPlayer == true {
                // Change the view mode
                self.viewMode = .playerEdit
                controller.playerName = GameCenterManager.shared.gcPlayer?.alias ?? "Test Player"
            }
        }
    }
    
    func validatePlayername() -> Bool {
        return NSRange(location: 3, length: 9).contains(controller.playerName.count)
    }
    
    func effect() {
        withAnimation(.easeIn(duration: 3)) {
            self.saturated = 0.5
        }
    }
}

struct FrontView_Previews: PreviewProvider {
    static var previews: some View {
        FrontView(controller: FrontController(simulating: false, newPlayer: false))
    }
}
