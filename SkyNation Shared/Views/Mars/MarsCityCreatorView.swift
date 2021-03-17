//
//  MarsCityCreatorView.swift
//  SkyNation
//
//  Created by Carlos Farini on 2/27/21.
//

import SwiftUI

struct MarsCityCreatorView: View {
    
//    @State var name:String = ""
//    @State var position:Vector3D = .zero
    
    @State var posdex:Posdex
    @State var city:DBCity?
    
    var body: some View {
        
        VStack {
            
            Text("City View").font(.title)
            Divider()
            
            
            if let city = city {
                Text("Occupied City").foregroundColor(.red).padding()
                Text("City name: \(city.name)")
                Text("A: \(city.name)")
                
            } else {
                
                Text("Unclaimed City").foregroundColor(.gray)
                Text("DEX: \(posdex.rawValue) \(posdex.sceneName)")
                
            }
            
            Divider()
            
            HStack {
                Text("Claim this city")
                Button("Claim city") {
                    print("Should claim it")
                    SKNS.claimCity(user: SKNUserPost(player: LocalDatabase.shared.player!), posdex: posdex) { (city, error) in
                        if let city = city {
                            print("We have a city !!!!")
                            print("CID: \(city.id)")
                            
                        } else {
                            print("No City. Error: \(error?.localizedDescription ?? "n/a")")
                        }
                    }
                }
                .buttonStyle(NeumorphicButtonStyle(bgColor: .orange))
                .disabled(city != nil && LocalDatabase.shared.player?.cityID == nil)
                
                Button("Close") {
                    print("Close dialogue")
                    NotificationCenter.default.post(name: .closeView, object: nil)
                    
                }
                .buttonStyle(NeumorphicButtonStyle(bgColor: .orange))
            }
            .padding()
        }
        
    }
}

struct MarsCityCreatorView_Previews: PreviewProvider {
    static var previews: some View {
        MarsCityCreatorView(posdex: .city1, city: nil)
    }
}
