//
//  GameSettingsView.swift
//  SkyNation
//  Created by Carlos Farini on 12/21/20.

import SwiftUI
import CoreImage

enum GameSettingsTab: String, CaseIterable {
    
    case Loading            // Loading the scene (can be interrupted)
    case EditingPlayer      // Editing Player Attributes
    case Server             // Checking Server Info
    case Settings           // Going through GameSettings
    
    var tabString:String {
        switch self {
            case .Loading, .Server, .Settings: return self.rawValue
            case .EditingPlayer: return "Player"
        }
    }
}

struct GameSettingsView: View {
    
    @ObservedObject var controller = GameSettingsController()
    
    /// When turned on, this shows the "close" button
    private var inGame:Bool = false
    
    init() {
        print("Initializing Game Settings View")
    }
    
    init(inGame:Bool? = true) {
        self.inGame = true
    }
    
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
            
            // Segment Control
            Picker("", selection: $controller.viewState) {
                let options = inGame ? [GameSettingsTab.EditingPlayer, GameSettingsTab.Server, GameSettingsTab.Settings]:GameSettingsTab.allCases
                ForEach(options, id:\.self) { tabName in
                    Text(tabName.tabString)
                }
            }.pickerStyle(SegmentedPickerStyle())
            
            
            Divider()
            
            switch controller.viewState {
                
                case .Loading:
                    
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
                                Text("x\(controller.player.timeTokens.count)")
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
                        generateBarcode(from:controller.player.id)
                    }
                    
                    if controller.isNewPlayer {
                        Text("New Player")
                            .foregroundColor(.orange)
                            .font(.headline)
                    }
                    
                    Group {
//                        HStack {
//                            Text("Enter name: ")
//                            TextField("Name:", text: $controller.playerName)
//                                .textFieldStyle(DefaultTextFieldStyle())
//                                .padding(4)
//                                .frame(width: 100)
//                                .cornerRadius(8)
//                        }
                        
                        ForEach(controller.loadedList, id:\.self) { litem in
                            Text(litem).foregroundColor(.gray)
                        }
                        
                        if let string = controller.fetchedString {
                            Text("Fetched:\n\(string)")
                        }
                        
                        if let loggedUser = controller.user {
                            Text("Fetched User: \(loggedUser.name)")
                        }
                        
                        Spacer(minLength: 8)
                    }
                    
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
                if controller.isNewPlayer {
                    Button("Create Player") {
//                        controller.createPlayer()
                        print("command deprecated")
                    }
                    .buttonStyle(NeumorphicButtonStyle(bgColor:.blue))
                } else {
//                    if controller.hasChanges {
                        Button("Save Player") {
                            controller.savePlayer()
                        }
                        .buttonStyle(NeumorphicButtonStyle(bgColor:.blue))
                        .disabled(!controller.hasChanges)
//                    }
                    
                }
                
                
                if (!inGame) {
                    Button("Start Game") {
                        let note = Notification(name: .startGame)
                        NotificationCenter.default.post(note)
                    }
                    .buttonStyle(NeumorphicButtonStyle(bgColor:.blue))
                    .disabled(controller.startGameDisabled())
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
    
//    func generateBarcode(from uuid: UUID) -> Image? {
//        let data = uuid.uuidString.prefix(8).data(using: String.Encoding.ascii)
//
//        if let filter = CIFilter(name: "CICode128BarcodeGenerator") {
//            filter.setValue(data, forKey: "inputMessage")
//
//            if let output:CIImage = filter.outputImage {
//
//                if let inverter = CIFilter(name:"CIColorInvert") {
//
//                    inverter.setValue(output, forKey:"inputImage")
//
//                    if let invertedOutput = inverter.outputImage {
//                        let rep = NSCIImageRep(ciImage: invertedOutput)
//                        let nsImage = NSImage(size: rep.size)
//                        nsImage.addRepresentation(rep)
//                        return Image(nsImage:nsImage)
//                    }
//
//                } else {
//                    let rep = NSCIImageRep(ciImage: output)
//                    let nsImage = NSImage(size: rep.size)
//                    nsImage.addRepresentation(rep)
//
//                    return Image(nsImage:nsImage)
//                }
//
//
//            }
//
//
////            return NSImage(ciImage: filter.outputImage)
////            let transform = CGAffineTransform(scaleX: 3, y: 3)
////            let out = filter.outputImage?.transformed(by:transform)
////
////            if let output = filter.outputImage?.transformed(by: transform) {
////                let image = NSImage(ciImage:output)
////                return image
////            }
//        }
//
//        return nil
//    }
    
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
            LoadingGameTab()
                .tabItem {
                    Text("Game")
                }
            
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


