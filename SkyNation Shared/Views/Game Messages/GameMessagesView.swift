//
//  GameMessagesView.swift
//  SkyNation
//
//  Created by Carlos Farini on 2/17/21.
//

import SwiftUI

struct GameMessagesView: View {
    
    var messages:[GameMessage]
    
    @State var tab:GameMessageType = .Achievement
    
    // Message Types
    // achievement   > all messages seem to be achievement
    // chatmessage
    // free delivery
    // other
    // systemerror
    // systemwarning
    // tutorial
    
    init() {
        let messages = LocalDatabase.shared.gameMessages
        self.messages = messages
    }
    
    var header: some View {
        
        Group {
            HStack() {
                VStack(alignment:.leading) {
                    Text("💬 Messages").font(.largeTitle)
                    Text("Keep up with the news")
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
            
            HStack {
                tabPicker
                Spacer()
            }
            
            Divider()
                .offset(x: 0, y: -5)
        }
        
    }
    
    var tabPicker: some View {
        HStack(spacing:0) {
            ForEach(GameMessageType.allCases, id:\.self) { mType in
                let selected:Bool = self.tab == mType
                let myGradient = selected ? Gradient(colors: [Color.red.opacity(0.6), Color.blue.opacity(0.7)]):Gradient(colors: [Color.red.opacity(0.3), Color.blue.opacity(0.3)])
                ZStack (alignment:.bottomTrailing) {
                    Text(mType.emoji)
                        .font(.largeTitle)
                        .padding(8)
                        .background(LinearGradient(gradient: myGradient, startPoint: .top, endPoint: .bottom))
                        .border(selected ? Color.blue:Color.clear, width: 2)
                        .cornerRadius(8)
                        .clipped()
                        .padding(.horizontal, 4)
                        
                    self.makeTabCallout(type: mType)
                        .font(.callout)
                        .foregroundColor(.red)
                        .padding(2)
                        .background(GameColors.transBlack)
                        .cornerRadius(4)
                    
                }
                .help("\(mType.rawValue)")
                .onTapGesture {
                    print("Did select tab \(mType.rawValue)")
                    self.tab = mType
                }
            }
        }
        .padding(.leading, 8)
    }
    
    var body: some View {
        
            VStack {
                
                header
                
                ScrollView {
                    switch tab {
                        case .Freebie:
                            let dateGenerated = Date().addingTimeInterval(LocalDatabase.shared.player?.wallet.timeToGenerateNextFreebie() ?? 0) //generator.dateFreebies
                            let nextGenerated = dateGenerated.addingTimeInterval(60 * 60 * 12)
                            
                            Text("Freebie of the day").font(.title).foregroundColor(.orange)
                            Text("Now \(GameFormatters.dateFormatter.string(from: Date()))").foregroundColor(.red)
                            
                            if nextGenerated.compare(Date()) == .orderedAscending {
                                Button("Get it!") {
                                    print("Get Freebie")
                                }
                                .buttonStyle(NeumorphicButtonStyle(bgColor: .orange))
                            } else {
                                Text("⏰ \(nextGenerated.timeIntervalSince(Date()))")
                                Button("Tokens") {
                                    print("Get Freebie via Tokens (force)")
                                    print("Need to save generator")
                                }
                                .buttonStyle(NeumorphicButtonStyle(bgColor: .orange))
                            }
                        case .Achievement:
                            ForEach(messages.filter({$0.type == tab}).sorted(by: { $0.date.compare($1.date) == .orderedDescending}), id:\.self.id) { message in
                                
                                
                                VStack {
                                    Text(GameFormatters.dateFormatter.string(from: message.date))
                                        .foregroundColor(message.isCollected ? .gray:.blue)
                                    Text(message.message)
                                        .foregroundColor(message.isRead ? .gray:.orange)
                                    HStack {
                                        Text("Reward: \(message.moneyRewards ?? 0)")
                                        Text("Type: \(message.type.rawValue)")
                                    }
                                    
                                    Divider()
                                }
                            }
                        case .Chat:
                            GuildChatView()
                            
                        default:
                            VStack {
                                Spacer()
                                Text("Not Implemented")
                                Spacer()
                            }
                            
                            
                    }
                    
                    // Freebies
                    if self.tab == GameMessageType.Freebie {
                        
                    }
                    
                    
                }
            }
            .frame(minWidth: 500, idealWidth: 600, maxWidth: 900, minHeight:300, idealHeight:500, maxHeight:600, alignment: .topLeading)
    }
    
    /// The callout displaying how many messages in that tab
    func makeTabCallout(type:GameMessageType) -> Text {
        let current = messages.filter({ $0.type == type }).count
        return Text("\(current)").foregroundColor(current == 0 ? Color.gray:Color.red)
    }
    
    
}

struct GameMessagesView_Previews: PreviewProvider {
    static var previews: some View {
        GameMessagesView()
    }
}
