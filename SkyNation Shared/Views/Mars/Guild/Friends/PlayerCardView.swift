//
//  PlayerCardView.swift
//  SkyNation
//
//  Created by Carlos Farini on 8/13/21.
//

import SwiftUI

struct PlayerCardView: View {
    
    var pCard:PlayerCard
    
    var body: some View {
        HStack {
            Image(pCard.avatar)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 64, height: 64, alignment: .center)
            VStack(alignment:.leading) {
                Text(pCard.name).font(.title2)
                Text("XP: \(pCard.experience)")
                HStack {
                    Image(systemName: "wave.3.right.circle")
                    Text("\(self.activeString(date: pCard.lastSeen))").foregroundColor(self.colorActivity(date: pCard.lastSeen))
                }
            }
        }
        .frame(width: 180)
        .padding(6)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray, lineWidth: 3)
        )
        .padding(8)
        
    }
    
    func activeString(date:Date) -> String {
        let delta = Date().timeIntervalSince(date)
        switch delta {
            case 0..<60: return "Now"
            case 60..<900: return "Recently" // 15m
            case 900..<1800: return "Half Hour" // 30m
            case 900..<3600: return "One Hour" // 1h
            case 3600..<28800: return "Few Hours"
            case 28800..<86400: return "Today" // 24h
            case 86400...162000: return "Yesterday"
            default: return GameFormatters.dateFormatter.string(from: date)
        }
    }
    
    func colorActivity(date:Date) -> Color {
        let delta = Date().timeIntervalSince(date)
        if delta < (60.0 * 15.0) {
            return .green
        } else if delta < (60.0*60.0*24.0) {
            return .orange
        } else {
            return .gray
        }
    }
}

struct SmallPlayerCardView: View {
    var pCard:PlayerCard
    
    var body: some View {
        HStack {
            Image(pCard.avatar)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 32, height: 32, alignment: .center)
            VStack(alignment:.leading) {
                Text(pCard.name)//.font(.title2)
                Text("XP: \(pCard.experience)").font(.footnote)
            }
        }
        .padding(4)
        .frame(width:130)
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color.gray, lineWidth: 2)
                
        )
        .padding(4)
    }
}

struct PlayerScorePairView: View {
    
    var playerPair:PlayerNumKeyPair
    
    var body: some View {
        HStack {
            SmallPlayerCardView(pCard: playerPair.player)
            Text("x \(playerPair.votes)")
                .font(.title)
                .padding(4)
                .background(Color.blue.opacity(0.5))
                .cornerRadius(6.0)
        }
        .padding(4)
    }
}

struct PlayerCardView_Previews: PreviewProvider {
    
    static var previews: some View {
        PlayerCardView(pCard: PlayerCardView_Previews.players().first!)
        SmallPlayerCardView(pCard: PlayerCardView_Previews.players().first!)
        
        PlayerScorePairView(playerPair: PlayerNumKeyPair(players().first!, votes: 5))
        PlayerScorePairView(playerPair: PlayerNumKeyPair(players().last!, votes: 5))
        
        HStack {
            List() {
                ForEach(PlayerCardView_Previews.players()) { card in
                    PlayerCardView(pCard: card)
                }
            }
            
            List() {
                ForEach(PlayerCardView_Previews.players()) { card in
                    SmallPlayerCardView(pCard: card)
                }
            }
        }
        
    }
    
    static func players() -> [PlayerCard] {
//        let p1 = PlayerCard(id: UUID(), localID: UUID(), guildID: UUID(), name: "Twelve Chars", avatar: "people_02", experience: 202, lastSeen: Date().addingTimeInterval(-200))
//        let p2 = PlayerCard(id: UUID(), localID: UUID(), guildID: UUID(), name: "Ronald Dump", avatar: "people_05", experience: 1, lastSeen: Date().addingTimeInterval(-99999))
//        let p3 = PlayerCard(id: UUID(), localID: UUID(), guildID: UUID(), name: "Osiris", avatar: "people_03", experience: 1254, lastSeen: Date().addingTimeInterval(-50000))
//        let p4 = PlayerCard(id: UUID(), localID: UUID(), guildID: UUID(), name: "Marstronaut", avatar: "people_08", experience: 12, lastSeen: Date().addingTimeInterval(-50000))
//        let p5 = PlayerCard(id: UUID(), localID: UUID(), guildID: UUID(), name: "Space-X", avatar: "people_09", experience: 189, lastSeen: Date().addingTimeInterval(-50000))
        let p1 = PlayerCard(playerContent: PlayerContent.example())
        let p2 = PlayerCard(playerContent: PlayerContent.example())
        let p3 = PlayerCard(playerContent: PlayerContent.example())
        let p4 = PlayerCard(playerContent: PlayerContent.example())
        let p5 = PlayerCard(playerContent: PlayerContent.example())
        
        
        return [p1, p2, p3, p4, p5]
    }
}
