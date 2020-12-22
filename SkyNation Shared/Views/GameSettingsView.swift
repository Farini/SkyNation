//
//  GameSettingsView.swift
//  SkyNation
//
//  Created by Carlos Farini on 12/21/20.
//

import SwiftUI

struct GameSettingsView: View {
    
    @ObservedObject var controller = GameSettingsController()
//    @State var playerName:String
    
    init() {
//        if let player = LocalDatabase.shared.player {
//            self.player
//        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: nil) {
            Text("Name: \(controller.playerName)")
                .font(.largeTitle)
            Divider()
            
            if controller.isNewPlayer {
                Text("New Player")
                    .foregroundColor(.green)
                    .font(.headline)
            } else {
                Text("Active Player. Last seen: \(GameFormatters.dateFormatter.string(from: controller.player.lastSeen))")
                    .foregroundColor(.green)
                    .font(.headline)
            }
            HStack {
                Text("Enter name: ")
                TextField("Name:", text: $controller.playerName)
                    .textFieldStyle(DefaultTextFieldStyle())
                    .padding(4)
                    .frame(width: 100)
                    .cornerRadius(8)
            }
            Text("ID: \(controller.playerID.uuidString)")
                .foregroundColor(.gray)
            
            Spacer(minLength: 8)
            
            // Player Info
            Group {
                Text("Player Info")
                    .foregroundColor(.gray)
                    .font(.headline)
                
                Text("S$ \(controller.player.money)")
                Text("Tokens: \(controller.player.timeTokens.count)")
                    .foregroundColor(.blue)
                Text("Delivery Tokens: \(controller.player.deliveryTokens.count)")
                    .foregroundColor(.orange)
                
                Divider()
            }
            
            
            HStack {
                if controller.isNewPlayer {
                    Button("Create Player") {
                        controller.createPlayer()
                    }
                } else {
                    if controller.hasChanges {
                        Button("Save Player") {
                            controller.savePlayer()
                        }
                        .disabled(!controller.hasChanges)
                    }
                    
                }
                
                Button("Reset tutorial") {
                    print("Reset the tutorial")
                }
                Button("Stop tutorial") {
                    print("Stop the tutorial")
                }
            }
        }
        .padding()
    }
    
}

struct GameSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        GameSettingsView()
    }
}

class GameSettingsController:ObservableObject {
    
    @Published var player:SKNPlayer
    @Published var playerName:String {
        didSet {
            if player.name != playerName {
                self.hasChanges = true
            }
        }
    }
    
    @Published var playerID:UUID
    @Published var isNewPlayer:Bool
    @Published var savedChanges:Bool
    @Published var hasChanges:Bool
    init() {
        if let player = LocalDatabase.shared.player {
            isNewPlayer = false
            self.player = player
            playerID = player.localID
            playerName = player.name
            hasChanges = false
            savedChanges = true
        } else {
            let newPlayer = SKNPlayer()
            self.player = newPlayer
            playerName = newPlayer.name
            playerID = newPlayer.localID
            isNewPlayer = true
            hasChanges = true
            savedChanges = false
        }
    }
    
    func createPlayer() {
        player.name = playerName
        if LocalDatabase.shared.savePlayer(player: player) {
            savedChanges = true
            hasChanges = false
        }
    }
    
    func savePlayer() {
        player.name = playerName
        if LocalDatabase.shared.savePlayer(player: player) {
            savedChanges = true
            hasChanges = false
        }
    }
}
