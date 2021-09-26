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
        self.controller = SideChatController(simulating: false, simElection: false)
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
            
            switch controller.selectedTab {
                case .Freebie:
                    
                    Text("Freebie of the day")
                        .font(.title2)
                        .foregroundColor(.orange)
                    
                    ForEach(controller.seeFreebies(), id:\.self) { string in
                        Text(string).foregroundColor(.green)
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
                        }
                        .buttonStyle(NeumorphicButtonStyle(bgColor: .orange))
                    }
                    
                case .Achievement:
                    
                    Text("Achievements").font(.title3).foregroundColor(.orange)
                    Divider()
                    
                    ScrollView(.vertical, showsIndicators: true) {
                        VStack(alignment: .leading) {
                            
                            Text("")
                                .fixedSize(horizontal: false, vertical: true)
                            
                            ForEach(controller.gameMessages.filter({$0.type == controller.selectedTab }).sorted(by: { $0.date.compare($1.date) == .orderedDescending}), id:\.self.id) { message in
                                
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
            
            Group {
                HStack {
                    Image(systemName: guild.icon)
                    Text("\(guild.name)").foregroundColor(.orange)
                }
                .font(.title3)
                Divider()
            }
            
            
            // President
            Text("President")
                .font(.title3)
                .foregroundColor(.orange)
            
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
            Text("Election")
                .font(.title3)
                .foregroundColor(.orange)
            
            let electing = guild.election
            Text(GameFormatters.dateFormatter.string(from: electing))
            
            switch controller.electionState {
                case .noElection:
                    Text("It is not time for election.").foregroundColor(.gray)
                case .waiting(let date):
                    Text("Waiting for election")
                    Text("Next Election: \(GameFormatters.fullDateFormatter.string(from: date))")
                    let delta:TimeInterval = date.timeIntervalSince(Date())
                    Text("in \(delta.stringFromTimeInterval())")
                    
                case .voting(let election):
                    GuildElectionsView(controller: controller, election: election)
            }
            
        }
    }
}

struct GuildElectionsView:View {
    
    @ObservedObject var controller:SideChatController
    // @State var election:Election
    var playerVotePairs:[PlayerNumKeyPair] = []
    private var castedVotes:Int
    
    init(controller:SideChatController, election:Election) {
        self.controller = controller
        
        var votePairs:[PlayerNumKeyPair] = []
        for(pid, score) in election.voted {
            if let newPair = PlayerNumKeyPair.makeFrom(id: pid, votes: score) {
                votePairs.append(newPair)
            }
        }
        self.playerVotePairs = votePairs.sorted(by: { $0.votes > $1.votes })
        
        let myPid = LocalDatabase.shared.player?.playerID ?? UUID()
        let vtCount = election.casted[myPid, default:0]
        self.castedVotes = vtCount
        
        
    }
    
    var body: some View {
        VStack {
            
            let voteLimit:Int = 3
            let remainingVotes = voteLimit - castedVotes
            
            // Votes
            Text("Votes").font(.title3).foregroundColor(.orange)
            ForEach(playerVotePairs, id:\.player.id) { votePair in
                let pCard = votePair.player
                HStack {
                    SmallPlayerCardView(pCard: pCard)
                    Text("\(votePair.votes)")
                        .font(.title2)
                        .padding(4)
                        .background(Color.black.opacity(0.5))
                }
                .onTapGesture {
                    if remainingVotes > 0 {
                        controller.voteForPresident(citizen: votePair.player)
                    } else {
                        
                    }
                }
            }
            
            Divider()
            
            // Candidates
            Text("All Candidates").font(.title3).foregroundColor(.orange)
            ForEach(controller.citizens, id:\.id) { citizen in
                let pCard = PlayerCard(playerContent: citizen)
                SmallPlayerCardView(pCard: pCard)
                    .onTapGesture {
                        if remainingVotes > 0 {
                            controller.voteForPresident(citizen: pCard)
                        } else {
                            
                        }
                    }
            }
            
            Divider()
            
            Text("You've voted \(castedVotes) times. Remaining votes \(remainingVotes)")
            
            // Casts
            // Creation
            // Date Ends (timer)
        }
    }
    
    //    struct PlayerVoteKeyPair {
    //        var player:PlayerContent
    //        var votes:Int
    //    }
}

struct GameMessagesView_Previews: PreviewProvider {
    static var previews: some View {
        GameMessagesView()
    }
}
