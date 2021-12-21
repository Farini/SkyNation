//
//  GuildBrowser.swift
//  SkyNation
//
//  Created by Carlos Farini on 12/15/21.
//

import SwiftUI

/*
 Simulated States:
 
 1. playerNoEntry
 2. playerNoGuild
 3. playerWithGuild - Displaying (my guild)
 4. playerWithGuild - Browsing
 
 Modes:
 
 -. Search mode (Searching Guild by name)
 -. Browse mode (Browsing whatever Guilds there are)
 -. Display mode (Showing my Guild)
 -. Create mode (Creating new)
 */

struct GuildBrowser: View {
    
    /// Selected Guild?
    @State var guildMap:GuildMap?
    
    /// All Guilds Fetched
    var guildList:[GuildSummary]
    
    // used for previews only
    var gMaps:[GuildMap]
    
    @State private var displaySearchField:Bool = false
    @State private var searchString:String = ""
    
    init() {
        let maps = GuildBrowser.makeGMArray()
        self.gMaps = maps
        let summaries = GuildBrowser.makeGSArray(gMaps: maps)
        self.guildList = summaries
        
        // Get the player.
        let player = LocalDatabase.shared.player
        let entry = player.marsEntryPass()
        if entry.result == true {
            // has entry
            if player.guildID == nil {
                // no guild
            } else {
                // Check if player is in the citizens
                // YES -> myGuild
                // NO -> Kicked?
            }
        } else {
            // no entry
        }
        // 1. Check if has entry
        // 2. Check if has Guild
        // 3. Make `GuildBrowserConditions`
        
        // Buttons      Leave       Join        Create      Search
        // ---
        // noEntry      disabled    disabled    disabled    disabled
        // noguild      disabled    enabled     enabled     enabled
        // guild        enabled     disabled    disabled    enabled
    }
    
    var body: some View {
        VStack {
            
            HStack {
                Text("Guild Browser").font(GameFont.section.makeFont())
                Spacer()
                
                if displaySearchField == true {
                    TextField("Search", text: $searchString)
                        .textFieldStyle(.roundedBorder)
                        .frame(maxWidth:200)
                }
                
                Button("Leave") {
                    print("Leave Guild. Player must have a valid guildID")
                }
                .buttonStyle(GameButtonStyle())
                
                Button("Join") {
                    print("Join Guild. Player must have a nil guildID")
                }
                .buttonStyle(GameButtonStyle())
                
                Button("Create") {
                    print("Join Guild. Player must have a nil guildID")
                }
                .buttonStyle(GameButtonStyle())
                
                Button("Search") {
                    print("Join Guild. Player must have a nil guildID")
                    if displaySearchField == true && searchString.isEmpty == false {
                        // controller.search...
                        
                    } else {
                        // Show the search bar
                        displaySearchField.toggle()
                    }
                }
                .buttonStyle(GameButtonStyle())
                
                
            }
            .padding(.top, 6)
            .padding(.horizontal)
            
            Divider()
            
            HStack {
                List {
                    
                    VStack {
                        PlayerGuildIndicator(guildConditions: .noGuild)
                        Divider()
                    }
                    
                    ForEach(guildList, id:\.id) { gList in
                        GuildRow(guild: gList, selected: guildMap?.id == gList.id)
                        .onTapGesture {
                            self.guildMap = gMaps.first(where: { $0.id == gList.id })
                        }
                    }
                }
                .frame(maxWidth:220)
                
                Divider()
                
                VStack {
                    if let map = self.guildMap {
                        HStack {
                            Spacer()
                            GuildCardView(guildMap: map)
                            Spacer()
                        }
                        
                    } else {
                        HStack {
                            Spacer()
                            EmptyGuildView()
                            Spacer()
                        }
                    }
                }
            }
        }
        .frame(minHeight:480)
    }
    
    static func makeGuild() -> Guild {
        let guild = Guild(id: UUID(), name: "Test Guild", icon: GuildIcon.allCases.randomElement()!.rawValue, color: GuildColor.allCases.randomElement()!.rawValue, president: nil, members: [:], citizens: [], isOpen: false, election: Date().addingTimeInterval(3600), terrain: nil, cities: [], outposts: [])
        return guild
    }
    
    /// GM = Guild Map
    static func makeGMArray(qtty:Int = 8) -> [GuildMap] {
        var array:[GuildMap] = []
        let randomGuildNames = ["The Arc", "Moonshine", "Marstopia"]
        for _ in 0..<qtty {
            let name = randomGuildNames.randomElement()!
            let new = GuildMap(name: name, population: max(1, (qtty / 2)), makePresident: true)
            array.append(new)
        }
        
        return array
    }
    
    /// GS = GuildSummary
    static func makeGSArray(gMaps:[GuildMap]) -> [GuildSummary] {
        var array:[GuildSummary] = []
        for idx in 0..<gMaps.count {
            let gMap:GuildMap = gMaps[idx]
            let summ:GuildSummary = gMap.makeSummary()
            array.append(summ)
        }
        return array
    }
}

enum GuildBrowserConditions {
    case noEntry
    case noGuild
    case citizenOf(guild:GuildMap)
}

struct GuildRow:View {
    
    var guild:GuildSummary
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
        .background(selected ? Color.black:Color.clear)
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
                        Text("Joined \(guild.name)")
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
    
    static var previews: some View {
        GuildBrowser()
        
        PlayerGuildIndicator()
    }
}
