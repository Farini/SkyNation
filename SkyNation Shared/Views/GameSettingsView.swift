//
//  GameSettingsView.swift
//  SkyNation
//
//  Created by Carlos Farini on 12/21/20.
//

import SwiftUI

struct GameSettingsView: View {
    
    @ObservedObject var controller = GameSettingsController()
    
    init() {
        print("Initializing Game Settings View")
        
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
            
            if let string = controller.fetchedString {
                Text("Fetched:\n\(string)")
            }
            
            if let loggedUser = controller.user {
                Text("Fetched User: \(loggedUser.name)")
            }
            
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
                
//                Button("Fetch Data") {
//                    print("Fetching Data...")
//                    controller.requestInfo()
//                }
                
                // Guild
                if controller.guild == nil {
                    Button("Create Guild") {
                        controller.createGuild()
                    }
                }
                
                // User
                if controller.user != nil {
                    Button("Fetch User") {
                        controller.fetchUser()
                    }
                }
                
                Button("Load Scene") {
                    let builder = LocalDatabase.shared.stationBuilder
                    if let station = LocalDatabase.shared.station {
                        builder.build(station:station)
                    }
                }
                
                Button("Start Game") {
                    let note = Notification(name: .startGame)
                    NotificationCenter.default.post(note)
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
    @Published var user:SKNUser?
    @Published var guild:Guild?
    
    @Published var playerID:UUID
    @Published var isNewPlayer:Bool
    @Published var savedChanges:Bool
    @Published var hasChanges:Bool
    
    @Published var fetchedString:String?
    
    init() {
        if let player = LocalDatabase.shared.player {
            isNewPlayer = false
            self.player = player
            playerID = player.localID
            playerName = player.name
            hasChanges = false
            savedChanges = true
            user = SKNUser(player: player)
            
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
    
    /// Creates a player **Locally**
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
    
    func requestInfo() {
        SKNS.getSimpleData { (data, error) in
            if let data = data {
                print("We got data: \(data.count)")
                if let string = String(data: data, encoding: .utf8) {
                    self.fetchedString = string
                    return
                }
                let decoder = JSONDecoder()
                if let a = try? decoder.decode([SKNUser].self, from: data) {
                    self.fetchedString = "Users CT: \(a.count)"
                } else {
                    self.fetchedString = "Somthing else happened"
                }
            } else {
                print("Could not get data. Reason: \(error?.localizedDescription ?? "n/a")")
            }
        }
    }
    
    func fetchUser() {
        
        guard let user = user else {
            print("No user")
            return
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        
        SKNS.fetchPlayer(id: self.player.id) { (sknUser, error) in
            if let user = sknUser {
                print("Found user: \(user.id)")
                self.user = user
            } else {
                // Create
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                    return
                } else {
                    print("No User. Creating...")
                    SKNS.createPlayer(localPlayer: user) { (data, error) in
                        if let data = data, let newUser = try? decoder.decode(SKNUser.self, from: data) {
                            print("We got a new user !!!")
                            self.user = newUser
                        }
                    }
                }
            }
        }
    }
    
    func createGuild() {
        guard let user = user else {
            print("No user")
            return
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        
        SKNS.createGuild(localPlayer: user, guildName: "Test Guild") { (data, error) in
            if let data = data, let guild = try? decoder.decode(Guild.self, from: data) {
                print("We got a Guild: \(guild.name)")
                self.guild = guild
            } else {
                print("Failed creating guild. Reason: \(error?.localizedDescription ?? "n/a")")
            }
        }
    }
    
    
}
