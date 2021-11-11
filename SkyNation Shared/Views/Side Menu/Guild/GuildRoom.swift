//
//  GuildRoom.swift
//  SkyNation
//
//  Created by Carlos Farini on 11/7/21.
//

import SwiftUI

enum GuildRoomTab:String, CaseIterable {
    
    case elections
    case actions
    case president
    case search
    case chatDoc
    
    var imageName:String {
        switch self {
            case .elections:    return "exclamationmark.shield"
            case .actions:      return "wand.and.stars"
            case .president:    return "crown"
            case .search:       return "magnifyingglass.circle"
            case .chatDoc:      return "doc.text"
        }
    }
}

struct GuildRoom: View {
    
    @ObservedObject var controller = GuildRoomController()
    
    @State private var popTutorial:Bool = false
    @State private var selection:GuildRoomTab = .elections
    
    // MARK: - Gradients
    private static let myGradient = Gradient(colors: [Color.red.opacity(0.6), Color.blue.opacity(0.7)])
    private static let unseGradient = Gradient(colors: [Color.red.opacity(0.3), Color.blue.opacity(0.3)])
    private let selLinear = LinearGradient(gradient: myGradient, startPoint: .topLeading, endPoint: .bottomTrailing)
    private let unselinear = LinearGradient(gradient: unseGradient, startPoint: .topLeading, endPoint: .bottomTrailing)
    
    var header: some View {
        Group {
            HStack {
                
                Label("Guild Room", systemImage: "shield")
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
                        TutorialView(tutType: .GuildRoom)
                    })
                
                
                // Close
                Button(action: {
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
            
            // Tabs
            HStack {
                ForEach(GuildRoomTab.allCases, id:\.self) { tab in
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
            }
            .padding(.horizontal, 8)
            
            Divider()
            
            switch selection {
                case .elections:
                    
                    VStack {
                        
                        Text("My Guild")
                            .font(GameFont.section.makeFont())
                            .padding(.top, 8)
                        
                        Divider()
                        
                        if let guild = controller.guild {
                            
                            VStack(spacing: 8) {
                                // Guild Presentation
                                Text(guild.name).font(.title2)
                                
                                Image(systemName:GuildIcon(rawValue:"\(guild.icon)")!.imageName)
                                    .font(.largeTitle)
                                    .foregroundColor(GuildColor(rawValue:guild.color)!.color)
                                
                                // Text("Color: \(guild.color)")
                            }
                            .padding(8)
                            
                            Text("Election: \(GameFormatters.fullDateFormatter.string(from: guild.election))")
                            Text("Election State: \(controller.electionState.displayString)")
                            
                            
                            if let presidentID = guild.president {
                                Text("President: \(presidentID.uuidString)")
                            } else {
                                
                                // No President
                                Text("No President")
                                    .foregroundColor(.red)
                                    .padding(4)
                                    .background(Color.black.opacity(0.5))
                                    .cornerRadius(4)
                            }
                            
                            
                        } else {
                            Text("No Guild")
                                .font(.title2)
                                .foregroundColor(.red)
                                .padding(6)
                                .background(Color.black.opacity(0.5))
                                .cornerRadius(6)
                            
                            Text("Go to Settings, under player on top-left of the screen and join a guild from there.").foregroundColor(.gray)
                        }
                        
                        Spacer()
                    }
                    
                case .actions:
                    
                    // Show Players (Citizens) for now
                    ScrollView {
                        VStack {
                            Text("Citizens")
                                .font(GameFont.section.makeFont())
                                .padding(.top, 8)
                            
                            Divider()
                            ForEach(controller.citizens) { citizen in
                                PlayerCardView(pCard: citizen.makePlayerCard())
                            }
                            Spacer()
                        }
                    }
                    
                    
                case .president:
                    
                    GuildElectionView(controller: controller)
                    
                case .search:
                    
                    Group {
                        let entryTokens:Int = controller.player.wallet.tokens.filter({ $0.origin == .Entry && $0.usedDate != nil }).count
                        
                        Text("Search")
                            .font(GameFont.section.makeFont())
                            .padding(.top, 8)
                        
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
                    
                case .chatDoc:
                    
                    Spacer()
                    Text("Documentation")
                    Spacer()
                    
            }
            
        }
        .frame(minWidth:600, maxWidth:1000, minHeight:500, maxHeight:700)
        
    }
}

struct GuildRoom_Previews: PreviewProvider {
    static var previews: some View {
        GuildRoom()
    }
}
