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
            
            // Main View
            switch selection {
                case .elections:
                    
                    // Same as ".president" -> Election View. Change this.
                    // Just show basic info
                    VStack(spacing:6) {
                        if let guildMap = controller.guildMap {
                            // General Info
                            
                            // Guild Icon
                            Image(systemName:GuildIcon(rawValue:"\(guildMap.icon)")!.imageName)
                                .font(.largeTitle)
                                .foregroundColor(GuildColor(rawValue:guildMap.color)!.color)
                            
                            
                            VStack {
                                // Main Info
                                Text(guildMap.name).font(GameFont.section.makeFont())
                                Text("XP: \(guildMap.experience)")
                                Text("MD: \(guildMap.markdown)")
//                                Text("Open: \(guildMap.isOpen)")
                                Image(systemName:guildMap.isOpen ? "lock.open":"lock")
                            }
                            .padding(.top, 6)
                            
                            Divider()
                            
                            VStack {
                                // People + Citizens
                                Text("Headcount: \(guildMap.citizens.count)")
                                Text("Invites: \(guildMap.invites.count)")
                                Text("Join list: \(guildMap.joinlist.count)")
                            }
                            .padding(.top, 6)
                            
                            Group {
                                if let election = controller.electionData {
                                    VStack {
                                        Text("Election: \(election.electionStage.rawValue)")
                                        Text("Election State: \(election.election.voted.count)")
                                    }
                                    .padding(.top, 6)
                                }
                                
                                
                                if let president = controller.president {
                                    HStack {
                                        Image(systemName:"crown.fill")
                                        Text("President:")
                                    }
                                    
                                    PlayerCardView(pCard: PlayerCard(playerContent: president))
                                }
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
                    // This is where the missions going to be?
                    ScrollView {
                        VStack {
                            /*
                            Text("Citizens")
                                .font(GameFont.section.makeFont())
                                .padding(.top, 8)
                            
                            Divider()
                            ForEach(controller.citizens) { citizen in
                                PlayerCardView(pCard: citizen.makePlayerCard())
                            }
                            Spacer()
                            */
                            
                            if let map = controller.guildMap {
                                Text("Guild Map")
                                Text(map.name)
                                Text("Color: \(map.color)")
                                Text("Icon: \(map.icon)")
                                if let mission = controller.mission {
                                    Text("map mission...").foregroundColor(.green)
                                    GuildMissionView(controller:controller, mission: mission, progress: 0.0)
                                } else {
                                    
                                    let mission = GuildMission()
                                    Text("made up mission...").foregroundColor(.red)
                                    GuildMissionView(controller:controller, mission: mission, progress: 0.0)
                                }
                                // Text(map.mission?.status)
                            } else {
                                Button("Fetch map") {
                                    // Fetch map
                                    controller.getGuildMap()
                                }
                                
                            }
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
                        
                        if controller.searchPlayerResult.isEmpty {
//                            List(controller.citizens) { citizen in
//                                Text("\(citizen.name) XP:\(citizen.experience)")
//                            }
                            List {
                                ForEach(controller.citizens.indices) { index in
                                    let citizen = controller.citizens[index]
                                    HStack {
                                        Image(citizen.avatar)
                                            .resizable()
                                            .frame(width:36, height:36)
                                        
                                        VStack {
                                            Text(citizen.name)
                                            Text("XP: \(citizen.experience)")
                                        }
                                        Spacer()
                                        Button("Gift") {
                                            print("Send gift to \(citizen.name)")
                                        }
                                        .buttonStyle(GameButtonStyle())
                                        .disabled(entryTokens < 1)
                                        
                                        if let president = controller.president {
                                            if controller.player.playerID == president.id {
                                                Button("Kick") {
                                                    print("Kickout \(citizen.name)")
                                                }
                                                .buttonStyle(GameButtonStyle())
                                            }
                                        } else {
                                            // no president
                                            Button("Kick") {
                                                print("Kickout \(citizen.name)")
                                            }
                                            .buttonStyle(GameButtonStyle())
                                        }
                                    }
                                    .listRowBackground((index  % 2 == 0) ? Color.black : GameColors.darkGray)
                                }
                            }
                            .padding(.horizontal)
                        } else {
                            List(controller.searchPlayerResult) { sPlayer in
                                VStack {
                                    PlayerCardView(pCard: PlayerCard(playerContent: sPlayer))
                                    HStack {
                                        Button("🎁 Token") {
                                            controller.giftToken(to: sPlayer)
                                        }
                                        .buttonStyle(GameButtonStyle())
                                        .disabled(entryTokens < 1)
                                        
                                        Button("Invite") {
                                            print("Invite")
                                            controller.inviteToGuild(playerContent: sPlayer)
                                        }
                                        .buttonStyle(GameButtonStyle())
                                        .disabled(!inviteEnabled)
                                    }
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
