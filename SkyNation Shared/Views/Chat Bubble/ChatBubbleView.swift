//
//  ChatBubbleView.swift
//  SkyNation
//
//  Created by Carlos Farini on 10/1/21.
//

import SwiftUI


struct ChatBubbleView: View {
    
    @ObservedObject var controller:ChatBubbleController
    @State private var hasReadChat:Bool = false
    
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
                    if mType == .Chat {
                        self.hasReadChat = true
                    }
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
                            
                            HStack {
                                if string == "money" {
                                    
                                    // Currency
                                    self.makeImage(GameImages.currencyImage)

                                    Text("Sky Coins: 1,000").foregroundColor(.green)
                                    
                                    
                                } else if string == "token" {
                                    
                                    // Token
                                    self.makeImage(GameImages.tokenImage)
                                    
                                    Text("Token: 1").foregroundColor(.green)
                                    
                                } else if let _ = TankType(rawValue: string) {
                                    GameImages.imageForTank()
                                    Text(string).foregroundColor(.green)
                                }
                            }
                            .padding()
                            .background(Color.black)
                            .cornerRadius(8)
                        }
                        
                        if controller.freebiesAvailable == true {
                            // Available
                            Button("Get it!") {
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
                        
                        Divider()
                        
                        if controller.giftedTokenMessage.isEmpty {
                            Text("Gifts ?").font(.title2)
                            Button(" 🎁 ") {
                                controller.searchGiftedToken()
                            }
                            .buttonStyle(GameButtonStyle())
                        } else {
                            Text(controller.giftedTokenMessage)
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
                        let entryTokens:Int = controller.player.wallet.tokens.filter({ $0.origin == .Entry && $0.usedDate != nil }).count
                        
                        Text("Search")
                        HStack {
                            Text("Search")
                            TextField("Search", text: $controller.searchText)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(width:250)
                            Button("Search") {
                                print("Searching")
                                controller.searchPlayerByName()
                            }
                            .buttonStyle(GameButtonStyle())
                        }
                        .padding(.horizontal)
                        
                        let guildHasPresident:Bool = controller.guild?.president != nil
                        let inviteEnabled:Bool = guildHasPresident ? controller.iAmPresident():true
                        
                        List(controller.searchPlayerResult) { sPlayer in
                            VStack {
                                PlayerCardView(pCard: PlayerCard(playerContent: sPlayer))
                                HStack {
                                    Button("🎁 Token") {
                                        controller.giftToken(to: sPlayer)
                                    }
                                    .buttonStyle(GameButtonStyle())
                                    .disabled(entryTokens < 1)
                                    
                                    Button("Invite to Guild") {
                                        print("Invite")
                                        controller.inviteToGuild(playerContent: sPlayer)
                                    }
                                    .buttonStyle(GameButtonStyle())
                                    .disabled(!inviteEnabled)
                                }
                            }
                        }
                        if controller.searchPlayerResult.isEmpty {
                            Text("No Players been found").foregroundColor(.gray)
                        }
                        
                        
                        Text("You have \(entryTokens) Entry tokens. You may gift it to someone else.")
                        
                        Text(controller.tokenMessage)
                            .font(.headline)
                            .foregroundColor(controller.tokenMessage.contains("Error") ? .red:.white)
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
        switch type {
            case .Achievement:
                let current = controller.gameMessages.filter({ $0.type == .Achievement }).count
                return Text("\(current)").foregroundColor(current == 0 ? Color.gray:Color.red)
            case .Freebie:
                if controller.player.wallet.timeToGenerateNextFreebie() < 1 {
                    return Text("!").foregroundColor(.red)
                } else {
                    return Text("")
                }
            case .Chat:
                return hasReadChat ? Text(""):Text("\(controller.guildChat.count)")
                // return
            case .Guild:
                switch controller.electionState {
                    case .noElection: return Text("")
                    case .voting(let election):
                        return Text("!\(election.voted.count)").foregroundColor(.red)
                    case .waiting(_):
                        return Text("!").foregroundColor(.red)
                        
                }
//                if let deltaTime = controller.guild?.election.timeIntervalSinceNow {
//                    if abs(deltaTime) > 5.0 * 60.0 * 60.0 * 24.0 {
//                        return Text("!").foregroundColor(.red)
//                    } else
//                    if abs(deltaTime) < 60.0 * 60.0 * 24.0 {
//                        return Text("!").foregroundColor(.red)
//                    }
//                }
//                return Text("")
                
            case .Tutorial:
                return Text("")
            case .Search:
                return Text("")
        }
        
    }
    
#if os(macOS)
    func makeImage(_ nsImage:NSImage) -> Image {
        return Image(nsImage: nsImage)
    }
#elseif os(iOS)
    func makeImage(_ uiImage:NSImage) -> Image {
        return Image(uiImage: uiImage)
    }
#endif
}

struct ChatBubbleView_Previews: PreviewProvider {
    static var previews: some View {
        ChatBubbleView()
    }
}

