//
//  GuildCreatorView.swift
//  SkyNation
//
//  Created by Carlos Farini on 10/2/21.
//

import SwiftUI

struct GuildCreatorView: View {
    
    @State var guildName:String = ""
    @State var selGuildIcon:GuildIcon = .diamond
    @State var selGuildColor:GuildColor = .red
    @State var isOpen:Bool = true
    
    /// Pass the guild being created, or cancel
    var action:((GuildCreate?, Bool) -> ())
    
    // TODO: Use Step View
    /*
     Add lock image to option
     */
    
    private let shape = RoundedRectangle(cornerRadius: 8, style: .continuous)
    
    var body: some View {
        ScrollView {
            VStack {
                Text("New Guild").font(.title).foregroundColor(.blue)
                    .padding(.top)
                
                Divider()
                
                /*
                StepperView(stepCounts: 5, current: 1, stepDescription: "Fist step")
                */
                
                // Name
                Group {
                    HStack {
                        Text("Guild Name")
                        TextField("max 12 characters", text: $guildName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width:150)
                        
                    }
                    .padding(.horizontal)
                    Toggle("Open to other players", isOn: $isOpen)
                    Text("When not selected, the above option will only let in users that are in a whitelist, created by the Guild's president")
                        .lineLimit(3)
                        .frame(maxWidth:320, maxHeight: .infinity)
                        .font(.footnote)
                        .foregroundColor(.gray)
                    Divider()
                }
                
                // Icon
                Group {
                    Text("Select Guild Badge").font(.title2).foregroundColor(.orange)
                    LazyHGrid(rows: [GridItem(.fixed(64), spacing: 8, alignment: .center)], alignment: .top, spacing: 8, pinnedViews: []) {
                        ForEach(GuildIcon.allCases, id:\.self) { guildIcon in
                            Image(systemName: guildIcon.imageName)
                                .font(.title)
                                .padding(6)
                                .cornerRadius(8)
                                .background(Color.black)
                                .overlay(
                                    shape
                                        .inset(by: 0.5)
                                        .stroke(selGuildIcon == guildIcon ? Color.blue.opacity(0.9):Color.clear, lineWidth: 1)
                                )
                                .onTapGesture {
                                    self.selGuildIcon = guildIcon
                                }
                        }
                    }
                    Divider()
                }
                
                // Color
                Group {
                    Text("Select Guild Color").font(.title2).foregroundColor(.orange)
                    LazyHGrid(rows: [GridItem(.fixed(64), spacing: 8, alignment: .center)], alignment: .top, spacing: 8, pinnedViews: []) {
                        ForEach(GuildColor.allCases, id:\.self) { guildColor in
                            Rectangle()
                                .fill(guildColor.color)
                                .frame(width: 32, height: 32, alignment: .center)
                                .cornerRadius(12)
                                .background(Color.black)
                                .overlay(
                                    shape
                                        .inset(by: 0.5)
                                        .stroke(selGuildColor == guildColor ? Color.orange.opacity(0.9):Color.clear, lineWidth: 3)
                                )
                                .onTapGesture {
                                    self.selGuildColor = guildColor
                                }
                        }
                    }
                }
                
                // Buttons
                Divider()
                HStack {
                    Button("Create") {
                        if let guildCreate = try? self.makeGuildCreate() {
                            action(guildCreate, false)
                        }
                    }
                    .buttonStyle((GameButtonStyle(labelColor: .orange)))
                    
                    Button("Cancel") {
                        action(nil, true)
                    }
                    .buttonStyle(GameButtonStyle())
                }
                .padding(.top)
                
                Text("Creating a new Guild costs 1 token").foregroundColor(.gray).font(.footnote)
                
            }
            .frame(maxWidth:350)
        }
        
        .frame(maxWidth:355)
    }
    
    func makeGuildCreate() throws -> GuildCreate? {
        
        let player = LocalDatabase.shared.player
        guard let playerID = player.playerID else {
            print("Could not load Player ID")
            return nil
        }
        
        // Charge Player
        if let token = player.requestToken() {
            let res = player.spendToken(token: token, save: false)
            // IMPORTANT: leave save with false. If guild doesn't create, at least player doesn't lose a token.
            // it will be saved later when creating process is over
            if res == false {
                print("Could not charge")
                return nil
            }
        } else {
            print("You don't have a token to spend.")
            return nil
        }
        
        
        let president = playerID
        
        // max name count
        let maxCharacters:Int = 12
        if guildName.count > maxCharacters {
            let newName = String(guildName.prefix(12))
            self.guildName = newName
        }
        let guildName = self.guildName
  
        let gc = GuildCreate(name: guildName, icon: selGuildIcon, color: selGuildColor, president: president, isOpen: isOpen, invites: [])
        
        return gc
        
    }
}

struct GuildCreatorView_Previews: PreviewProvider {
    static var previews: some View {
        GuildCreatorView() { _, _ in }
    }
}
