//
//  GameMessagesView.swift
//  SkyNation
//
//  Created by Carlos Farini on 2/17/21.
//

import SwiftUI

struct GameMessagesView: View {
    
    @ObservedObject var controller:SideChatController
    
    init() {
        self.controller = SideChatController()
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
                let selected:Bool = controller.selectedTab == mType
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
                    controller.didSelectTab(tab: mType)
//                    print("Did select tab \(mType.rawValue)")
//                    self.tab = mType
                }
            }
        }
        .padding(.leading, 8)
    }
    
    var body: some View {
        
            VStack {
                
                header
                
                ScrollView {
                    switch controller.selectedTab {
                        case .Freebie:
                            
                            Text("Freebie of the day").font(.title).foregroundColor(.orange)
                            
                            let delta:Double = LocalDatabase.shared.player?.wallet.timeToGenerateNextFreebie() ?? 1.0
                            if delta < 0.8 {
                                // Available
                                Button("Get it!") {
                                    print("Get Freebie")
                                }
                                .buttonStyle(NeumorphicButtonStyle(bgColor: .orange))
                            } else {
                                Text("⏰ \(TimeInterval(delta).stringFromTimeInterval())")
                                // Not available
                                Button("Tokens") {
//                                    print("Get Freebie via Tokens (force)")
//                                    print("Need to save generator")
                                }
                                .buttonStyle(NeumorphicButtonStyle(bgColor: .orange))
                            }
                            /*
                            let dateGenerated = Date().addingTimeInterval(LocalDatabase.shared.player?.wallet.timeToGenerateNextFreebie() ?? 1)
                            
                            
                            let nextGenerated:Date = dateGenerated.addingTimeInterval(60 * 60 * 12)
                            
                            
                            Text("Now \(GameFormatters.dateFormatter.string(from: Date()))").foregroundColor(.red)
                            Text("Delta: \(LocalDatabase.shared.player?.wallet.timeToGenerateNextFreebie() ?? 0)")
                            
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
                         */
                        
                        case .Achievement:
                            
                            ForEach(controller.gameMessages.filter({$0.type == controller.selectedTab }).sorted(by: { $0.date.compare($1.date) == .orderedDescending}), id:\.self.id) { message in
                                
                                
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
                            
                        case .Guild:
                            if let guild = controller.guild {
                                MessagesGuildView(controller: controller, guild: guild)
                            } else {
                                VStack {
                                    Spacer()
                                    Text("⚠️ You must be in a Guild to see related content").foregroundColor(.gray)
                                    Spacer()
                                }
                            }
                            
                            
                        default:
                            VStack {
                                Spacer()
                                Text("Not Implemented")
                                Spacer()
                            }
                            
                            
                    }
                }
            }
            .frame(minWidth: 500, idealWidth: 600, maxWidth: 900, minHeight:300, idealHeight:500, maxHeight:600, alignment: .topLeading)
    }
    
    /// The callout displaying how many messages in that tab
    func makeTabCallout(type:GameMessageType) -> Text {
        let current = controller.gameMessages.filter({ $0.type == type }).count
        return Text("\(current)").foregroundColor(current == 0 ? Color.gray:Color.red)
    }
}

struct MessagesGuildView:View {
    
    @ObservedObject var controller:SideChatController
    @State var guild:GuildFullContent
    
    var body: some View {
        VStack {
            Text("Guild Stuff")
            
            // President
            Text("President").font(.title3)
            if let presid = guild.president,
               let person = guild.citizens.filter({ $0.id == presid }).first {
                SmallPlayerCardView(pCard: person.makePlayerCard())
                
                if controller.iAmPresident() == true {
                    Text("I am president")
                    
                    // Add President Actions here
                    // Guild Modify
                    // Kickout
                }
                
            } else {
                Text("No President").foregroundColor(.gray)
            }
            
            Divider()
                .padding(.horizontal)
            
            // Election
            Text("Election").font(.title3)
            let electing = guild.election
            Text(GameFormatters.dateFormatter.string(from: electing))
            
            switch controller.electionState {
                case .noElection:
                    Text("No Election")
                case .waiting(let date):
                    Text("Next Election: \(GameFormatters.fullDateFormatter.string(from: date))")
                case .running(let deadline):
                    Text("Election ends: \(GameFormatters.fullDateFormatter.string(from: deadline))")
                case .finished:
                    Text("Finished")
                    Button("Restart") {
                        controller.restartElection()
                    }
                    .buttonStyle(GameButtonStyle())
                    
            }
            
            // Guild Modify (if president)
            // Guild Presidential Campaign
            // Guild Voting
            
        }
    }
}

struct GameMessagesView_Previews: PreviewProvider {
    static var previews: some View {
        GameMessagesView()
    }
}
