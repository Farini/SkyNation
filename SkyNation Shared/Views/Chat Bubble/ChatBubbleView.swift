//
//  ChatBubbleView.swift
//  SkyNation
//
//  Created by Carlos Farini on 10/1/21.
//

import SwiftUI


struct ChatBubbleView: View {
    
    @ObservedObject var controller:ChatBubbleController
    
    init() {
        self.controller = ChatBubbleController(simulating: false, simElection: false)
    }
    
    // MARK: - Header
    
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
                }
                .buttonStyle(SmallCircleButtonStyle(backColor: .pink))
                
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
            ForEach(ChatBubbleTab.allCases, id:\.self) { mType in
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
            
            switch controller.selectedTab {
                case .Freebie:
                    Group {
                        Text("Freebie of the day")
                            .font(.title2)
                            .foregroundColor(.orange)
                        
                        ForEach(controller.seeFreebies(), id:\.self) { string in
                            if string == "money" {
                                Text("Sky Coins: 1,000").foregroundColor(.green)
                            } else {
                                Text(string).foregroundColor(.green)
                            }
                        }
                        
                        if controller.freebiesAvailable == true {
                            // Available
                            Button("Get it!") {
                                print("Get Freebie")
                                controller.retrieveFreebies()
                            }
                            .buttonStyle(NeumorphicButtonStyle(bgColor: .orange))
                            .disabled(!controller.freebiesAvailable)
                            
                        } else {
                            Text("⏰ \(TimeInterval(controller.player.wallet.timeToGenerateNextFreebie()).stringFromTimeInterval())")
                            // Not available
                            Button("Tokens") {
                                print("Get Freebie via Tokens (force)")
                                controller.retrieveFreebies(using: true)
                            }
                            .buttonStyle(NeumorphicButtonStyle(bgColor: .orange))
                        }
                    }
                    
                case .Achievement:
                    
                    Text("Achievements").font(.title3).foregroundColor(.orange)
                    Divider()
                    
                    ScrollView(.vertical, showsIndicators: true) {
                        VStack(alignment: .leading) {
                            
                            Text("")
                                .fixedSize(horizontal: false, vertical: true)
                            
                            ForEach(controller.gameMessages.filter({$0.type == .Achievement }).sorted(by: { $0.date.compare($1.date) == .orderedDescending}), id:\.self.id) { message in
                                
                                HStack {
                                    
                                    // Message
                                    Text(GameFormatters.dateFormatter.string(from: message.date))
                                        .foregroundColor(message.isCollected ? .gray:.blue)
                                    
                                    // Reward
                                    Text("Reward: \(message.moneyRewards ?? 0)")
                                }
                                
                                Text(message.message)
                                    .foregroundColor(message.isRead ? .gray:.orange)
                                    .fixedSize(horizontal: false, vertical: true)
                                
                                Divider()
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                case .Chat:
                    
                    GuildChatView(controller:controller)
                    
                case .Guild:
                    if let guild = controller.guild {
//                        MessagesGuildView(controller: controller, guild: guild)
                        ChatBubbleGuildTab(controller: controller, guild: guild)
                        Text("Messages Guild View")
                    } else {
                        VStack {
                            Spacer()
                            Text("⚠️ You must be in a Guild to see related content").foregroundColor(.gray)
                            Spacer()
                        }
                    }
                    
                case .Search:
                    Group {
                        Text("Search")
                        HStack {
                            Text("Search")
                            TextField("Search", text: $controller.searchText)
                            Button("Search") {
                                print("Searching")
                                controller.searchPlayerByName()
                            }
                        }
                        List(controller.searchPlayerResult) { sPlayer in
                            PlayerCardView(pCard: PlayerCard(playerContent: sPlayer))
                        }
                        if controller.searchPlayerResult.isEmpty {
                            Text("No Players been found").foregroundColor(.gray)
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
        .frame(minWidth: 500, idealWidth: 600, maxWidth: 900, minHeight:300, idealHeight:500, maxHeight:600, alignment: .topLeading)
    }
    
    /// The callout displaying how many messages in that tab
    func makeTabCallout(type:ChatBubbleTab) -> Text {
        let current = controller.gameMessages.filter({ $0.type == .Achievement }).count
        return Text("\(current)").foregroundColor(current == 0 ? Color.gray:Color.red)
    }
}

struct ChatBubbleView_Previews: PreviewProvider {
    static var previews: some View {
        ChatBubbleView()
    }
}

