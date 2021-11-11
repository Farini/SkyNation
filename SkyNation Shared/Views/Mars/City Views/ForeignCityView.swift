//
//  ForeignCityView.swift
//  SkyNation
//
//  Created by Carlos Farini on 7/13/21.
//

import SwiftUI

struct ForeignCityView: View {
    
    @ObservedObject var controller:CityController
    
    /// Position of city
    var posdex:Posdex
    
    /// Player that owns the city
    var player:PlayerContent?
    
    var body: some View {
        VStack {
            
            Text("Guild City").font(GameFont.title.makeFont())
            Divider()
            
            if let city = MarsBuilder.shared.cities.filter({ $0.posdex == posdex.rawValue }).first {
                Group {
                    Text("City: \(city.name)")
                    Text("City index: \(posdex.sceneName)")
                    Text("XP: \(city.experience)")
                    Text("Gate: \(city.gateColor)")
                }.padding(8)
                Divider()
            }
            
            Text("This city has been claimed by another player.")
            
            if let player = player {
                PlayerCardView(pCard: player.makePlayerCard())
                
            } else {
                Image(systemName: "questionmark.diamond").font(.largeTitle)
                    .padding(6)
                    .background(RoundedRectangle(cornerRadius: 6)
                                    .stroke())
                Text("This player is not known yet.").foregroundColor(.red)
            }
                
            Group {
                Text("Occupied City").foregroundColor(.red).padding()
            }
            
            Spacer()
            
        }
        .padding(.vertical)
    }
}

struct ForeignCityView_Previews: PreviewProvider {
    
    
    static var previews: some View {
        let player = MarsBuilder.shared.players.first ?? PlayerContent(player: LocalDatabase.shared.player)
        ForeignCityView(controller: CityController(), posdex: .city1, player: player)
    }
}
