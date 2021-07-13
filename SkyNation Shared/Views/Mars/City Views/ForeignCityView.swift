//
//  ForeignCityView.swift
//  SkyNation
//
//  Created by Carlos Farini on 7/13/21.
//

import SwiftUI

struct ForeignCityView: View {
    
    @ObservedObject var controller:CityController
    
    var posdex:Posdex
    var player:PlayerContent?
    
//    var dbCity:DBCity
    
    // FIXME: - Buttons
    // Button to message player
    // Button to Evict Player
    
    var body: some View {
        VStack {
            
            Text("Guild City").font(.title)
            
            if let city = MarsBuilder.shared.cities.filter({ $0.posdex == posdex.rawValue }).first {
                Group {
                    Text("City: \(city.name)")
                    Text("City index: \(posdex.sceneName)")
                }.padding(8)
                Divider()
            }
            
            Text("Owner").font(.title)
            
            if let player = player {
                Group {
                    Text(player.name)
                    Image(player.avatar)
                        .resizable()
                        .frame(width:64, height:64)
                    Text(player.activity())
                    Text("XP: \(player.experience)")
                    
                    // Button to message player
                    // Button to Evict Player
                    
                }
            }
                
            Group {
                Text("Occupied City").foregroundColor(.red).padding()
            }
            
        }
        .padding(.vertical)
    }
}

struct ForeignCityView_Previews: PreviewProvider {
    
    
    static var previews: some View {
        let player = MarsBuilder.shared.players.first!
        ForeignCityView(controller: CityController(), posdex: .city1, player: player)
    }
}
