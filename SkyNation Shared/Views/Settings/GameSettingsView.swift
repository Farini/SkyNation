//
//  GameSettingsView.swift
//  SkyNation
//  Created by Carlos Farini on 12/21/20.

import SwiftUI
import CoreImage

struct GameSettingsView: View {
    
    @ObservedObject var controller = GameSettingsController()
    
    /// When turned on, this shows the "close" button
    private var inGame:Bool = false
    
    init(inGame:Bool? = false) {
        self.inGame = inGame!
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
            
            // Top header
            if (inGame) {
                header
            }
            
            let options = inGame ? [GameSettingsTab.EditingPlayer, GameSettingsTab.Server, GameSettingsTab.Settings]:GameSettingsTab.allCases
            
            GameSettingsViewTabs(selection: $controller.viewState, options: options) { selectedTab in
                controller.didSelectTab(newTab: selectedTab)
            }
            
            Divider()
            
            switch controller.viewState {
                
                case .Loading:
                    GameLoadingTab(controller: controller)
                    
                case .EditingPlayer:
                    
                    PlayerEditorView(controller: controller)
                    
                case .Server:
                    // SettingsServerTab(controller:controller)
                    GuildBrowser(controller: controller)
                    
                case .Settings:
                    GameSettingsTabView()
            }
            
            Divider()
            
            // Buttons Bar
            HStack {
                if (!inGame) {
                    Button(action: {
                        controller.startGame()
                    }) {
                        HStack {
                            Image(systemName: "play")
                            Text("Start")
                        }
                    }
                    .buttonStyle(GameButtonStyle())
                    .disabled(controller.startGameDisabled())
                    
                } else {
                    Button("Save") {
                        controller.savePlayer()
                    }
                    .buttonStyle(GameButtonStyle())
                    .disabled(!controller.hasChanges)
                }
            }
        }
        .padding()
        .frame(minWidth:600, idealWidth:800, maxWidth:.infinity, minHeight:450, maxHeight:.infinity)
        .background(GameColors.darkGray)
        .onAppear() {
            viewDidAppear()
        }
    }
    
    func viewDidAppear() {
        if inGame {
            controller.viewState = .EditingPlayer
        } else {
            controller.loadGameData()
            controller.checkLoginStatus()
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
#if os(macOS)
        GameSettingsView()
            .preferredColorScheme(.dark)
#elseif os(iOS)
        if #available(iOS 15.0, *) {
            GameSettingsView()
                .preferredColorScheme(.dark)
                .previewInterfaceOrientation(.landscapeLeft)
        } else {
            // Fallback on earlier versions
            GameSettingsView()
                .preferredColorScheme(.dark)
        }
#endif
        
    }
}

struct GameTabs_Previews: PreviewProvider {
    static var previews:some View {
        
        TabView {
            
            let controller = GameSettingsController()
            
            // Server
            
//            SettingsServerTab(controller:controller)
//                .tabItem {
//                    Text("Server")
//                }
            
            // Settings
            GameSettingsTabView()
                .tabItem {
                    Text("Settings")
                }

            // Game
            GameLoadingTab(controller: controller)
            
            // Player
            PlayerEditorView(controller: controller)
            
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


