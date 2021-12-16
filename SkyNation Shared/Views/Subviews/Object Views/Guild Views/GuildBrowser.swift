//
//  GuildBrowser.swift
//  SkyNation
//
//  Created by Carlos Farini on 12/15/21.
//

import SwiftUI

struct GuildBrowser: View {
    
    @State var guild:Guild = GuildBrowser.makeGuild()
    @State var guildMap:GuildMap?
    
    var guildList:[GuildSummary]
    var gMaps:[GuildMap]
    
    init() {
        let maps = GuildBrowser.makeGMArray()
        self.gMaps = maps
        let summaries = GuildBrowser.makeGSArray(gMaps: maps)
        self.guildList = summaries
    }
    
    var body: some View {
        VStack {
            
            HStack {
                Text("Guild Browser").font(GameFont.section.makeFont())
                Spacer()
                Button("Leave") {
                    print("Leave Guild. Player must have a valid guildID")
                }
                .buttonStyle(GameButtonStyle())
                
                Button("Join") {
                    print("Join Guild. Player must have a nil guildID")
                }
                .buttonStyle(GameButtonStyle())
            }
            .padding(.top, 6)
            .padding(.horizontal)
            
            Divider()
            
            HStack {
                List {
                    ForEach(guildList, id:\.id) { gList in
                        HStack {
                            Image(systemName: GuildIcon(rawValue: gList.icon)!.imageName)
                                .font(.largeTitle)
                                .foregroundColor(GuildColor(rawValue: gList.color)!.color)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 6)
                                .background(Color.black)
                                .cornerRadius(6)
                            
                            VStack(alignment:.leading) {
                                Text("\(gList.name)").foregroundColor(GuildColor(rawValue: gList.color)!.color)
                                    .font(GameFont.section.makeFont())
                                HStack {
                                    Text("👤 \(gList.citizens.count)")//.padding(2)
                                    Text("🌆 \(gList.cities.count)")//.padding(2)
                                    Text("⚙️ \(gList.outposts.count)")//.padding(2)
                                    Spacer()
                                }
                                .font(GameFont.mono.makeFont())
                            }
                        }
                        .background(self.guildMap?.id == gList.id ? Color.black:Color.clear)
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

struct GuildBrowser_Previews: PreviewProvider {
    static var previews: some View {
        GuildBrowser()
    }
}
