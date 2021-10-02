//
//  GuildChatView.swift
//  SkyNation
//
//  Created by Carlos Farini on 8/15/21.
//

import SwiftUI

struct GuildChatView: View {
    
    @ObservedObject var controller:ChatBubbleController
    
    var body: some View {
        VStack {
            
            ScrollViewReader { scroller in
                
                ScrollView([.vertical], showsIndicators: true) {
                    
                    VStack(alignment: .leading) {
                        
                        Group {
                            HStack {
                                Spacer()
                                Text("Guild Chat")
                                    .font(.title3)
                                    .foregroundColor(.orange)
                                Spacer()
                            }
                            Divider()
                            
                        }
                        
                        Text("")
                            .fixedSize(horizontal: false, vertical: true)
                        
                        ForEach(controller.guildChat, id:\.id) { message in
                            
                            HStack(alignment:.top) {
                                Text("\(message.name)")
                                    .bold()
                                    .foregroundColor(.green)
                                
                                Text("\(GameFormatters.flexibleDateFormatterString(date: message.date)):")
                                    .foregroundColor(.blue)
                                
                                Text(message.message)
                                    .font(.system(.body, design: .monospaced))
                                    .fixedSize(horizontal: false, vertical: true)
                                
                                // Multiline text
                                // https://stackoverflow.com/questions/56593120/how-do-you-create-a-multi-line-text-inside-a-scrollview-in-swiftui/56604599#56604599
                            }
                            .padding(.vertical, 4)
                            
                            Divider()
                        }
                        
                        if controller.guildChat.isEmpty {
                            Text("< No Messages >").foregroundColor(.gray)
                        }
                    }
                }
                .frame(minHeight:280)
                .padding(.horizontal)
                .onChange(of: controller.guildChat) { newChat in
                    scroller.scrollTo(newChat.last?.id, anchor: .bottom)
                }
            }
            
            // Sending
            HStack {
                
                // Player Card
                SmallPlayerCardView(pCard: LocalDatabase.shared.player.getPlayerContent().makePlayerCard())
                    .onTapGesture {
                        controller.requestChat()
                    }
                
                // Text
                TextField("Text", text: $controller.currentText)
                    .padding(.bottom, 6)
                
                Text("\(controller.textCount()) / 150").foregroundColor(controller.textCount() <= 150 ? Color.green:Color.red)
                
                Button("Send") {
                    controller.postMessage(text: controller.currentText)
                }
                .buttonStyle(NeumorphicButtonStyle(bgColor: .white))
                .disabled(controller.currentText.isEmpty)
                
            }
            .padding(.horizontal)
        }
    }
}

struct GuildChatView_Previews: PreviewProvider {
    
    static var previews: some View {
        GuildChatView(controller: ChatBubbleController(simulating: true, simElection: true))
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
