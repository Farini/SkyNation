//
//  GuildBrowser.swift
//  SkyNation
//
//  Created by Carlos Farini on 12/15/21.
//

import SwiftUI

/*
 
 Modes:
 
 -. Search mode (Searching Guild by name)
 -. Browse mode (Browsing whatever Guilds there are)
 -. Display mode (Showing my Guild)
 -. Create mode (Creating new)
 
 View States:
 
 - loading
 - loaded(state) | browsing?
 - creating + created
 - busy? (updating, fetching...)
 - error & success messages
 
 The real Guild join state - PlayerGuildState
 
 - noEntry
 - noGuild
 - joined(guild)
 
 ------
 make sure guild.inviteList < 4
 */



struct GuildBrowser: View {
    
    @ObservedObject var controller:GameSettingsController
    
    /// View State { .loading, .creating, .browsing)
    @State private var viewState:GuildNavViewState = .loading
    
    // Search
    @State private var displaySearchField:Bool = false
    @State private var searchString:String = ""
    
    // Alert
    /// Alert to show player before leaves the Guild
    @State private var leavingAlert:Bool = false
    
    var body: some View {
        VStack {
            
            switch viewState {
                case .loading:
                    VStack {
                        Spacer()
                        ProgressView("Loading")
                        Divider()
                        Text("Loading data").foregroundColor(.gray)
                        Spacer()
                    }
                case .browsing:
                    // Top Bar
                    HStack {
                        
                        Text("Guild Browser").font(GameFont.section.makeFont())
                        Spacer()
                        
                        // Search Field
                        if displaySearchField {
                            TextField("Search", text: $searchString)
                                .textFieldStyle(.roundedBorder)
                                .frame(maxWidth:200)
                                .transition(.move(edge: .trailing))
                        }
                        
                        // Buttons
                        switch controller.playerGuildState {
                            case .noEntry:
                                Text("No Entry").foregroundColor(.gray)
                            case .noGuild:
                                Button("Create") {
                                    print("Join Guild. Player must have a nil guildID")
                                    self.viewState = .creating
                                }
                                .buttonStyle(GameButtonStyle())
                                
                                Button("Join") {
                                    print("Join Guild. Player must have a nil guildID")
                                    
                                    if let guild = controller.selectedGuildMap {
                                        controller.requestCitizenship(guild)
                                    }
                                }
                                .buttonStyle(GameButtonStyle())
                                
                                Button("Search") {
                                    print("Join Guild. Player must have a nil guildID")
                                    if displaySearchField == true && searchString.isEmpty == false {
                                        // controller.search...
                                        print("Controller search hasn't been implemented yet.")
//                                        controller.fetchGuilds()
                                        controller.searchGuilds(string: self.searchString)
                                    } else {
                                        // Show the search bar
                                        withAnimation() {
                                            self.displaySearchField.toggle()
                                        }
                                    }
                                }
                                .buttonStyle(GameButtonStyle())
                            case .joined(let guild):
                                Text("Joined \(guild.name)")
                                Button("Leave") {
                                    print("Leave Guild. Player must have a valid guildID")
                                    leavingAlert.toggle()
                                }
                                .buttonStyle(GameButtonStyle())
                                
                                Button("Search") {
                                    print("Join Guild. Player must have a nil guildID")
                                    if displaySearchField == true && searchString.isEmpty == false {
                                        // controller.search...
                                        controller.fetchGuilds()
                                    } else {
                                        // Show the search bar
                                        withAnimation() {
                                            self.displaySearchField.toggle()
                                        }
                                        
                                    }
                                }
                                .buttonStyle(GameButtonStyle())
                        }
                    }
                    .padding(.top, 6)
                    .padding(.horizontal)
                    
                    .alert(isPresented: $leavingAlert) {
                        
                        Alert(title: Text("Leaving Guild"), message: Text("Are you sure you want to leave this guild?"), primaryButton: .destructive(Text("Yes")) {
                            controller.leaveGuild()
                            
                        }, secondaryButton: .cancel())
                    }

                    
                    Divider()
                    
                    HStack {
                        
                        // List
                        List {
                            
                            // Player Guild Indicator
                            VStack {
                                
                                if let myGuild = controller.guildMap {
                                    PlayerGuildIndicator(guildConditions: .citizenOf(guild: myGuild))
                                        .modifier(GameSelectionModifier(isSelected: controller.selectedGuildMap?.id == myGuild.id))
                                } else if controller.player.marsEntryPass().result == true {
                                    // no guild
                                    PlayerGuildIndicator(guildConditions: .noGuild)
                                } else {
                                    // no entry
                                    PlayerGuildIndicator(guildConditions: .noEntry)
                                }
                                
                                
                            }
                            
                            
                            Divider()
                            
                            // Fetched Guild Rows
                            ForEach(controller.joinableGuilds, id:\.id) { gList in
                                GuildRow(guild: gList, selected: controller.selectedGuildMap?.id == gList.id)
                                    .modifier(GameSelectionModifier(isSelected: controller.selectedGuildMap?.id == gList.id))
                                    .onTapGesture {
                                        controller.fetchGuildMapDetails(from: gList)
                                    }
                            }
                            
                            // Empty Guildlist
                            if controller.joinableGuilds.isEmpty && controller.player.marsEntryPass().result == true {
                                Button("Fetch list") {
                                    controller.fetchGuilds()
                                }
                                .buttonStyle(GameButtonStyle())
                            }
                        }
                        .frame(maxWidth:220)
                        
                        Divider()
                        
                        // Detail View
                        ScrollView {
                            VStack {
                                
                                Text(controller.guildNavError).foregroundColor(.red)
                                    .padding(.horizontal, 8)
                                
                                HStack {
                                    Spacer()
                                    if let map = controller.selectedGuildMap {
                                        GuildCardView(guildMap: map)
                                    } else {
                                        if let map = controller.guildMap {
                                            GuildCardView(guildMap: map)
                                        } else {
                                            EmptyGuildView()
                                        }
                                    }
                                    Spacer()
                                }
                                
                                Spacer()
                            }
                        }
                    }
                case .creating:
                    GuildMakerForm() { guildCreate in
                        if let guildCreate = guildCreate {
                            // creating guild
                            controller.didCreateGuild(guildCreate: guildCreate)
                        } else {
                            // cancelling
                            self.viewState = .browsing
                        }
                    }
            }
        }
        .frame(minHeight:480, idealHeight:550, maxHeight: .infinity)
        .onAppear() {
            viewDidAppear()
        }
    }
    
    func viewDidAppear() {
        self.viewState = .browsing
    }
}

enum GuildBrowserConditions {
    case noEntry
    case noGuild
    case citizenOf(guild:GuildMap)
}

struct GuildRow:View {
    
    var guild:GuildSummary
    
    // Deprecate this.
    var selected:Bool
    
    var body: some View {
        HStack {
            Image(systemName: GuildIcon(rawValue: guild.icon)!.imageName)
                .font(.largeTitle)
                .foregroundColor(GuildColor(rawValue: guild.color)!.color)
                .padding(.vertical, 8)
                .padding(.horizontal, 6)
                .background(Color.black)
                .cornerRadius(6)
            
            VStack(alignment:.leading) {
                Text("\(guild.name)").foregroundColor(GuildColor(rawValue: guild.color)!.color)
                    .font(GameFont.section.makeFont())
                HStack {
                    Text("👤 \(guild.citizens.count)")
                    Text("🌆 \(guild.cities.count)")
                    Text("⚙️ \(guild.outposts.count)")
                    Spacer()
                }
                .font(GameFont.mono.makeFont())
            }
        }
        //.background(selected ? Color.black:Color.clear)
    }
}

struct PlayerGuildIndicator: View {
    
    var guildConditions:GuildBrowserConditions = .noGuild
    
    var body: some View {
        VStack(alignment:.leading) {
            
            Text("My Guild").font(GameFont.section.makeFont())
            HStack {
                // Image
                switch guildConditions {
                    case .noEntry:
                        Image(systemName: "lock.circle")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                        Text("No Entry").foregroundColor(.red)
                        
                    case .noGuild:
                        Image(systemName: "shield")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                        Text("No Guild").foregroundColor(.gray)
                        
                    case .citizenOf(let guild):
                        Image(systemName: GuildIcon(rawValue: guild.icon)!.imageName)
                            .font(.largeTitle)
                            .foregroundColor(GuildColor(rawValue: guild.color)!.color)
                        Text("\(guild.name)")
                }
                Spacer()
            }
            
            switch guildConditions {
                case .noEntry:
                    Text("Head to the store 🛍").foregroundColor(.orange)
                case .noGuild:
                    Text("Join a guild!").foregroundColor(.orange)
                case .citizenOf(let guild):
                    Text("Joined \(guild.name)")
            }
        }
        .padding(.horizontal, 8)
    }
}


struct GuildBrowser_Previews: PreviewProvider {
    
    static let controller = GameSettingsController(previewing: true)
    
    static var previews: some View {
        GuildBrowser(controller: controller)
        
//        PlayerGuildIndicator()
        PlayerGuildIndicator(guildConditions: .noEntry)
    }
}
