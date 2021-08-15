//
//  GuildChatView.swift
//  SkyNation
//
//  Created by Carlos Farini on 8/15/21.
//

import SwiftUI

struct GuildChatView: View {
    
    @ObservedObject var controller:GuildChatController = GuildChatController()
    
    var body: some View {
        VStack {
            Text("Guild Chat")
            Divider()
            
            List {
                ForEach(controller.messages, id:\.id) { message in
                    HStack {
                        Text("\(message.name):")
                        Text(message.message)
                    }
                }
            }
            .frame(minHeight:280, maxHeight:290)
            
            Spacer()
            Divider()
            HStack {
                SmallPlayerCardView(pCard: LocalDatabase.shared.player!.getPlayerContent().makePlayerCard())
                    .onTapGesture {
                        controller.updateMessages()
                    }
                TextField("Text", text: $controller.currentText)
                    .padding(.bottom, 6)
                Text("\(controller.textCount()) / 150").foregroundColor(controller.textCount() <= 150 ? Color.green:Color.red)
                Button("Send") {
                    controller.postMessage(text: controller.currentText)
                }
                .buttonStyle(NeumorphicButtonStyle(bgColor: .white))
            }
            .padding(.horizontal)
        }
    }
}

class GuildChatController:ObservableObject {
    
    @Published var messages:[ChatMessage] = []
    @Published var currentText:String = ""
    
    init() {
        #if DEBUG
        self.messages = GuildChatView_Previews.exampleMessages()
        #else
        if GameSettings.onlineStatus == true {
            self.updateMessages()
        } else {
            self.messages = GuildChatView_Previews.exampleMessages()
        }
        #endif
    }
    
    /// Posts a message on the Guild Chat
    func postMessage(text:String) {
        
        guard let player = LocalDatabase.shared.player,
              let pid = player.playerID,
              let gid = player.guildID else {
            fatalError()
        }
        
        guard text.count < 150 else {
            print("Text is too large !!!")
            return
        }
        
        let post = ChatPost(guildID: gid, playerID: pid, name: player.name, date: Date(), message: text)
        
        SKNS.postChat(message: post) { newMessages, error in
            
            DispatchQueue.main.async {
                if !newMessages.isEmpty {
                    self.currentText = ""
                }
                self.messages = newMessages.sorted(by: { $0.date.compare($1.date) == .orderedAscending })
            }
        }
    }
    
    /// Reads Messages from Guild Chat
    func updateMessages() {
        guard let player = LocalDatabase.shared.player,
              let pid = player.playerID,
              let gid = player.guildID else {
            fatalError()
        }
        print("Fetching Guild Chat PID:\(pid)")
        
        SKNS.readChat(guildID: gid) { newMessages, error in
            if newMessages.isEmpty {
                print("Empty Messages")
            } else {
                print("Got Messages: \(newMessages.count)")
                DispatchQueue.main.async {
                    print("Updating \(newMessages.count) messages on screen")
                    self.messages = newMessages.sorted(by: { $0.date.compare($1.date) == .orderedAscending }).suffix(20)
                }
            }
        }
    }
    
    func textCount() -> Int {
        return currentText.count
    }
}

struct GuildChatView_Previews: PreviewProvider {
    static var previews: some View {
        GuildChatView() //messages: GuildChatView_Previews.exampleMessages())
    }
    static func exampleMessages() -> [ChatMessage] {
        
        let gid = UUID()
        
        let p1 = UUID()
        let p1Name = "Carlos"
        
        let p2 = UUID()
        let p2Name = "Henry"
        
        let m1 = ChatMessage(id: UUID(), guild: ["id":gid], pid: p1, name: p1Name, message: "Hello :)", date: Date().addingTimeInterval(-300))
        
        let m2 = ChatMessage(id: UUID(), guild: ["id":gid], pid: p2, name: p2Name, message: "Hey how is it going?", date: Date().addingTimeInterval(-280))
        
        let m3 = ChatMessage(id: UUID(), guild: ["id":gid], pid: p1, name: p1Name, message: "Good. How about you?", date: Date().addingTimeInterval(-200))
        
        let m4 = ChatMessage(id: UUID(), guild: ["id":gid], pid: p2, name: p2Name, message: "I'm well. Thank you.", date: Date().addingTimeInterval(-150))
        
        return [m1, m2, m3, m4]
    }
}
