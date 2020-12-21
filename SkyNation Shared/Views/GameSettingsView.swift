//
//  GameSettingsView.swift
//  SkyNation
//
//  Created by Carlos Farini on 12/21/20.
//

import SwiftUI

struct GameSettingsView: View {
    
    @State var player:SKNPlayer = SKNPlayer()
    
    var body: some View {
        VStack(alignment: .leading, spacing: nil) {
            Text("Name: \(player.name)")
                .font(.largeTitle)
            Divider()
            Text("Tokens: \(player.timeTokens.count)")
            Text("DT: \(player.deliveryTokens.count)")
            
            HStack {
                Button("Reset tutorial") {
                    print("Reset the tutorial")
                }
                Button("Stop tutorial") {
                    print("Stop the tutorial")
                }
            }
        }
        .padding()
    }
}

struct GameSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        GameSettingsView()
    }
}
