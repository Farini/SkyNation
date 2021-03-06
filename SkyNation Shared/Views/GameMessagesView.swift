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
    @State var generator:GameGenerators? = LocalDatabase.shared.gameGenerators
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
                let selected = self.tab == mType
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
                    // Sections?
                    
                    // Freebies
                    if self.tab == GameMessageType.Freebie, let generator = self.generator {
                        
//                        let generator = LocalDatabase.shared.gameGenerators!
                        let dateGenerated = generator.dateFreebies
                        let nextGenerated = dateGenerated.addingTimeInterval(60 * 60 * 12)
                        
                        Text("Freebie of the day").font(.title).foregroundColor(.orange)
                        Text("Freebie \(GameFormatters.dateFormatter.string(from: generator.dateFreebies))").foregroundColor(.red)
                        Text("Now \(GameFormatters.dateFormatter.string(from: Date()))").foregroundColor(.red)
                        
                        if nextGenerated.compare(Date()) == .orderedAscending {
                            Button("Get it!") {
                                print("Get Freebie")
                                getMyFreebies()
                            }
                            .buttonStyle(NeumorphicButtonStyle(bgColor: .orange))
                        } else {
                            let lastSpent = max(2, self.generator?.spentOnFreebies ?? 1)
                            let nextSpent = GameLogic.fibonnaci(index: lastSpent + 1)
                            
                            Text("⏰ \(nextGenerated.timeIntervalSince(Date()))")
                            Button("\(nextSpent) Tokens") {
                                
                                print("Get Freebie via Tokens (force)")
                                print("Last Spent: \(lastSpent)")
                                print("Next Spent (value): \(nextSpent)")
                                
                                self.generator?.spentOnFreebies += 1
                                print("Need to save generator")
                                
                                getMyFreebies(payTokens: nextSpent)
                            }
                            .buttonStyle(NeumorphicButtonStyle(bgColor: .orange))
                        }
                    }
                    
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
                    
                }
            }
            .frame(minWidth: 500, idealWidth: 600, maxWidth: 900, minHeight:300, idealHeight:500, maxHeight:600, alignment: .topLeading)
    }
    
    /// The callout displaying how many messages in that tab
    func makeTabCallout(type:GameMessageType) -> Text {
        let current = messages.filter({ $0.type == type }).count
        return Text("\(current)").foregroundColor(current == 0 ? Color.gray:Color.red)
    }
    
    func getMyFreebies(payTokens:Int = 0) {
        
        guard let generator = generator, let player = LocalDatabase.shared.player else { return }
        
        // Paying Tokens
        if payTokens > 0 {
            if player.timeTokens.count < payTokens {
                print("Not enough tokens")
            } else {
                player.timeTokens.removeFirst(payTokens)
                let saveResult = LocalDatabase.shared.savePlayer(player: player)
                print("Saved Player: \(saveResult)")
            }
        }
        
//        let generator = LocalDatabase.shared.gameGenerators!
        let dateGenerated = generator.dateFreebies
        let nextGenerated = dateGenerated.addingTimeInterval(60 * 60 * 12)
        
        if nextGenerated.compare(Date()) == .orderedAscending {
            
            print("\n\nFreebies !!!")
            
            let money = generator.money
            let tokens = generator.tokens
            
            let boxes = generator.boxes
            let tanks = generator.tanks
            let ppl = generator.people
            
            print("You receive...")
            print("Money: \(money)")
            print("Tokens: \(tokens.count)")
            print("---")
            print("Boxes: \(boxes.count)")
            print("Tanks: \(tanks.count)")
            print("People: \(ppl.count)")
            
            
            // add to player
//            LocalDatabase.shared.player?.receiveFreebiesAndSave(currency: money, newTokens: tokens)
            
            // add to station
//            let station = LocalDatabase.shared.station!
//            station.truss.extraBoxes.append(contentsOf: boxes)
//            station.truss.tanks.append(contentsOf: tanks)
            
            // Not adding people
//            for person in ppl {
//                print("Attention! Could not add person \(person.name). Lack of room.")
//            }
            
            generator.dateFreebies = Date()
            generator.spentOnFreebies += 1
            generator.update()
            self.generator = generator
            
            self.tab = .Freebie
            LocalDatabase.saveGenerators(gameGen: generator)
            
            
        }
    }
}

struct GameMessagesView_Previews: PreviewProvider {
    static var previews: some View {
        GameMessagesView()
    }
}
