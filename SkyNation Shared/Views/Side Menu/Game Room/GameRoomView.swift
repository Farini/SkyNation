//
//  GameRoomView.swift
//  SkyNation
//
//  Created by Carlos Farini on 11/7/21.
//

import SwiftUI

enum GameRoomTab:String, CaseIterable {
    case achievements
    case freebie
    case xchange
    case credits
    
    var imageName:String {
        switch self {
            case .achievements: return "flag"
            case .freebie:      return "gift"
            case .xchange:      return "arrow.triangle.2.circlepath"
            case .credits:      return "scroll"
        }
    }
    
    var tabName:String {
        switch self {
            case .achievements: return "Achievements"
            case .freebie:      return "Free Drop-Off"
            case .xchange:      return "Exchange"
            case .credits:      return "Credits"
        }
    }
}

struct GameRoomView: View {
    
    @ObservedObject var controller:GameRoomController = GameRoomController()
    
    @State private var popTutorial:Bool = false
    @State private var selection:GameRoomTab = .achievements
    
    // MARK: - Gradients
    private static let myGradient = Gradient(colors: [Color.red.opacity(0.6), Color.blue.opacity(0.7)])
    private static let unseGradient = Gradient(colors: [Color.red.opacity(0.3), Color.blue.opacity(0.3)])
    private let selLinear = LinearGradient(gradient: myGradient, startPoint: .topLeading, endPoint: .bottomTrailing)
    private let unselinear = LinearGradient(gradient: unseGradient, startPoint: .topLeading, endPoint: .bottomTrailing)
    
    var header: some View {
        Group {
            HStack {
                
                Label("Game Room", systemImage: "gamecontroller")
                    .font(GameFont.title.makeFont())
                
                Spacer()
                
                // Tutorial
                Button(action: {
                    print("Question ?")
                    popTutorial.toggle()
                }, label: {
                    Image(systemName: "questionmark.circle")
                        .font(.title2)
                })
                    .buttonStyle(SmallCircleButtonStyle(backColor: .orange))
                    .popover(isPresented: $popTutorial, arrowEdge: Edge.bottom, content: {
                        // Easy Tutorial View
                        TutorialView(tutType: .GameRoom)
                    })
                
                
                // Close
                Button(action: {
                    //                    controller.cancelSelection()
                    NotificationCenter.default.post(name: .closeView, object: self)
                }, label: {
                    Image(systemName: "xmark.circle")
                        .font(.title2)
                })
                    .buttonStyle(SmallCircleButtonStyle(backColor: .red))
                    .padding(.trailing, 6)
                
            }
            .padding([.top, .horizontal], 6)
            Divider()
                .offset(x: 0, y: -5)
            
        }
    }
    
    var body: some View {
        VStack {
            header
            
            HStack {
                ForEach(GameRoomTab.allCases, id:\.self) { tab in
                    Image(systemName: tab.imageName).font(.title)
                        .padding(8)
                        .background(selection == tab ? selLinear:unselinear)
                        .cornerRadius(4)
                        .clipped()
                        .overlay(
                            RoundedRectangle(cornerRadius: 4, style: .continuous)
                                .inset(by: 0.5)
                                .stroke(selection == tab ? Color.blue:Color.clear, lineWidth: 2)
                        )
                        .help("\(tab.rawValue)")
                        .onTapGesture {
                            print("Call me")
                            self.selection = tab
                        }
                }
                Spacer()
                Text(selection.tabName)
            }
            .padding(.horizontal, 8)
            
            Divider()
            
            
            switch selection {
                case .achievements:
                    
                    ScrollView(.vertical, showsIndicators: true) {
                        VStack(alignment: .leading) {
                            
                            ForEach(controller.achievements, id:\.id) { message in
                                
                                AchievementRowView(message: message) { rewardMessage in
                                    controller.collectRewardFrom(message: rewardMessage)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                case .freebie:
                    VStack {
                        Text("Freee Drop-off Supply")
                            .font(.title2)
                            .foregroundColor(.orange)
                        
                        HStack {
                            
                            ForEach(controller.freebiesArray, id:\.self) { string in
                                
                                if string == "money" {
                                    
                                    HStack {
                                        // Currency
                                        self.makeImage(GameImages.currencyImage)
                                            .resizable()
                                            .frame(width:22, height:22)
                                        Text("Sky Coins: 1,000").foregroundColor(.green)
                                    }
                                    .padding()
                                    .background(Color.black)
                                    .cornerRadius(8)
                                    
                                } else if string == "token" {
                                    
                                    // Token
                                    HStack {
                                        self.makeImage(GameImages.tokenImage)
                                            .resizable()
                                            .frame(width:22, height:22)
                                        
                                        Text("Token: 1").foregroundColor(.green)
                                    }
                                    .padding()
                                    .background(Color.black)
                                    .cornerRadius(8)
                                    
                                } else if let _ = TankType(rawValue: string) {
                                    
                                    HStack {
                                        GameImages.imageForTank()
                                            .resizable()
                                            .frame(width:22, height:22)
                                        
                                        Text(string).foregroundColor(.green)
                                    }
                                    .padding()
                                    .background(Color.black)
                                    .cornerRadius(8)
                                } else {
                                    EmptyView()
                                }
                            }
                        }
                        
                        Divider()
                        Spacer()
                        
                        if controller.freebiesAvailable == true {
                            
                            Text("Drop-offs can help you restock your Space Station, and give some perks to the Player. Get yours now!")
                                .frame(width:400)
                                .fixedSize(horizontal: true, vertical: true)
                                .foregroundColor(.gray)
                                .padding(6)
                            
                            // Available
                            Button("Get it!") {
                                controller.retrieveFreebies()
                            }
                            .buttonStyle(NeumorphicButtonStyle(bgColor: .orange))
                            .disabled(!controller.freebiesAvailable)
                            
                        } else {
                            
                            let delta = controller.player.wallet.timeToGenerateNextFreebie()
                            
                            VStack {
                                Text("⏰ Next Drop-off in: \(delta.stringFromTimeInterval())")
                                    .padding(6)
                                
                                Text("Tired of waiting for another drop-off? Use a token to get an immediate drop-off, by tapping the button below.")
                                    .frame(width:400)
                                    .fixedSize(horizontal: true, vertical: true)
                                    .foregroundColor(.gray)
                                    .padding(6)
                                
                                Divider()
                                
                                // Not available
                                Button {
                                    print("get")
                                    controller.retrieveFreebies(using: true)
                                } label: {
                                    HStack {
                                        Image("Helmet")
                                            .resizable()
                                            .frame(width:18, height:18)
                                        Text("Token")
                                    }
                                }
                                .buttonStyle(GameButtonStyle())
                                .padding(.bottom)
                            }
                        }
                    }
                case .xchange:
                    VStack {
                        Spacer()
                        Text("XChange")
                        Spacer()
                        
//                        if controller.giftedTokenMessage.isEmpty {
//                            Text("Gifts ?").font(.title2)
//                            Button(" 🎁 ") {
//                                controller.searchGiftedToken()
//                            }
//                            .buttonStyle(GameButtonStyle())
//                        } else {
//                            Text(controller.giftedTokenMessage)
//                        }
                        
                    }
                case .credits:
                    CreditsView()
            }
        }
        .frame(minWidth:700, maxWidth:1200, maxHeight:600)
        
    }
    
#if os(macOS)
    func makeImage(_ nsImage:NSImage) -> Image {
        return Image(nsImage: nsImage)
    }
#elseif os(iOS)
    func makeImage(_ uiImage:UIImage) -> Image {
        return Image(uiImage: uiImage)
    }
#endif
}

struct AchievementRowView:View {
    
    var message:GameMessage
    var collectAction:((GameMessage) -> ()) = { _ in }
    
    var body: some View {
        VStack(alignment:.leading) {
            HStack {
                
                // Message
                Text(GameFormatters.dateFormatter.string(from: message.date))
                    .foregroundColor(message.isCollected ? .gray:.blue)
                Spacer()
                // Reward
                if let cashReward = message.moneyRewards {
                    let cashString = message.isCollected ? "Collected \(cashReward).":"🏆 \(cashReward) SkyCoins"
                    Text(cashString)
                        .foregroundColor(message.isCollected ? Color.gray:Color.orange)
                }
            }
            
            HStack {
                Text(message.message)
                    .foregroundColor(.gray)
                    .fixedSize(horizontal: false, vertical: true)
                
                Spacer()
                
                if let money = message.moneyRewards {
                    if message.isCollected == false {
                        // collect button
                        Button {
                            self.collectAction(message)
                        } label: {
                            Label("Collect \(money)", systemImage: "flag")
                        }
                        .buttonStyle(GameButtonStyle(labelColor: .green))

                    } else {
                        // already collected
                    }
                } else {
                    // Empty View?
                }
            }
            
            
            Divider()
        }
    }
}

struct GameRoomView_Previews: PreviewProvider {
    static var previews: some View {
        GameRoomView()
//        if let m1 = LocalDatabase.shared.gameMessages.first {
//            AchievementRowView(message: m1)
//        }
    }
}
