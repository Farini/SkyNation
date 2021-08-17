//
//  GameSettingsView.swift
//  SkyNation
//  Created by Carlos Farini on 12/21/20.

import SwiftUI
import CoreImage

struct GameSettingsView: View {
    
    @ObservedObject var guildController:GuildController
    @ObservedObject var controller = GameSettingsController()
    
    /// When turned on, this shows the "close" button
    private var inGame:Bool = false
    
    init(inGame:Bool? = false) {
        self.inGame = inGame!
        self.guildController = GuildController(autologin: true)
    }
    
    /// Header (only shows when `inGame` is on
    var header: some View {
        
        Group {
            HStack() {
                VStack(alignment:.leading) {
                    Text("⚙️ Settings").font(.largeTitle)
                    Text("Details")
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // Tutorial
                Button(action: {
                    print("Question ?")
                }, label: {
                    Image(systemName: "questionmark.circle")
                        .font(.title2)
                })
                .buttonStyle(SmallCircleButtonStyle(backColor: .orange))
                
                // Close
                Button(action: {
                    NotificationCenter.default.post(name: .closeView, object: self)
                }) {
                    Image(systemName: "xmark.circle")
                        .font(.title2)
                }.buttonStyle(SmallCircleButtonStyle(backColor: .pink))
                
            }
            .padding([.leading, .trailing, .top], 8)
            
            Divider()
                .offset(x: 0, y: -5)
        }
        
    }
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: nil) {
            
            if (inGame) {
                header
            }
            
            // Segment Control (Tab)
            Picker("", selection: $controller.viewState) {
                let options = inGame ? [GameSettingsTab.EditingPlayer, GameSettingsTab.Server, GameSettingsTab.Settings]:GameSettingsTab.allCases
                ForEach(options, id:\.self) { tabName in
                    Text(tabName.tabString)
                }
            }.pickerStyle(SegmentedPickerStyle())
            .onChange(of: controller.viewState, perform: { value in
                controller.didSelectTab(newTab: value)
            })
            
            
            Divider()
            
            switch controller.viewState {
                
                case .Loading:
                    GameLoadingTab(controller: controller)
                    
                case .EditingPlayer:
                    PlayerEditView(controller: controller)
                    
                case .Server:
                    SettingsServerTab(controller:controller)
                    
                case .Settings:
                    GameSettingsTabView()
            }
            
            Divider()
            
            // Buttons Bar
            HStack {
                if (!inGame) {
                    Button("Start Game") {
                        let note = Notification(name: .startGame)
                        NotificationCenter.default.post(note)
                    }
                    .buttonStyle(NeumorphicButtonStyle(bgColor:.blue))
                    .disabled(controller.startGameDisabled())
                } else {
                    Button("Save") {
                        controller.savePlayer()
                    }
                    .buttonStyle(NeumorphicButtonStyle(bgColor:.blue))
                    .disabled(!controller.hasChanges)
                }
            }
        }
        .padding()
        .onAppear() {
            viewDidAppear()
        }
    }
    
    func viewDidAppear() {
        if inGame {
            controller.viewState = .EditingPlayer
        } else {
            controller.loadGameData()
        }
    }
    
    func generateBarcode(from uuid: UUID) -> Image? {
        let data = uuid.uuidString.prefix(8).data(using: String.Encoding.ascii)
        
        if let filter = CIFilter(name: "CICode128BarcodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            
            if let output:CIImage = filter.outputImage {
                
                if let inverter = CIFilter(name:"CIColorInvert") {
                    
                    inverter.setValue(output, forKey:"inputImage")
                    
                    if let invertedOutput = inverter.outputImage {
                        #if os(macOS)
                        let rep = NSCIImageRep(ciImage: invertedOutput)
                        let nsImage = NSImage(size: rep.size)
                        nsImage.addRepresentation(rep)
                        return Image(nsImage:nsImage)
                        #else
                        let uiImage = UIImage(ciImage: invertedOutput)
                        return Image(uiImage: uiImage)
                        #endif
                    }
                    
                } else {
                    #if os(macOS)
                    let rep = NSCIImageRep(ciImage: output)
                    let nsImage = NSImage(size: rep.size)
                    nsImage.addRepresentation(rep)
                    return Image(nsImage:nsImage)
                    #else
                    let uiimage = UIImage(ciImage: output)
                    return Image(uiImage: uiimage)
                    #endif
                }
            }
        }
        
        return nil
    }
    
}

// MARK: - Previews

struct GameSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        GameSettingsView()
    }
}

struct GameTabs_Previews: PreviewProvider {
    static var previews:some View {
        
        TabView {
            
            // Server
            SettingsServerTab(controller:GameSettingsController())
                .tabItem {
                    Text("Server")
                }
            
            // Settings
            GameSettingsTabView()
                .tabItem {
                    Text("Settings")
                }

            // Game
            GameLoadingTab(controller: GameSettingsController())
            
            // Player
            PlayerEditView(controller:GameSettingsController())
                .tabItem {
                    Text("Player")
                }
        }
    }
}


// MARK: - Avatar

class AvatarCard: Identifiable, Equatable {
    
    var id:UUID = UUID()
    var name:String
    var selected:Bool
    
    init(name:String) {
        self.id = UUID()
        self.selected = false
        self.name = name
    }
    
    static func == (lhs: AvatarCard, rhs: AvatarCard) -> Bool {
        return lhs.id == rhs.id
    }
}


