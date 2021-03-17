//
//  OutpostView.swift
//  SkyNation
//
//  Created by Carlos Farini on 3/12/21.
//

import SwiftUI

struct OutpostView: View {
    
    @State var posdex:Posdex
    @State var outpost:DBOutpost
    
    var body: some View {
        VStack {
            Text("Outpost").font(.title)
            
            Divider()
            
            Group {
                Text("Scene: \(posdex.sceneName)").foregroundColor(.orange)
                Text("Outpost description")
                Text("Position: \(Int(posdex.position.x)), \(Int(posdex.position.y)), \(Int(posdex.position.z))")
                
                Text("Outpost data").foregroundColor(.blue).padding(.top)
                Text("Level: \(outpost.level)")
                
                Text("Model: \(outpost.model)")
                Text("Posdex: \(outpost.posdex)")
                Text("Date: \(GameFormatters.dateFormatter.string(from:outpost.accounting))")
            }
            
            
            if let nextJob = outpost.getNextJob() {
                VStack {
                    Text("Next Job - Upgrade to \(outpost.level + 1)").font(.title2)
                    Text("Skills: \(nextJob.wantedSkills.count) QTTY: \(nextJob.wantedSkills.compactMap({$0.value}).reduce(0, +))")
                    Text("Ingredients: \(nextJob.wantedIngredients.count) QTTY: \(nextJob.wantedIngredients.compactMap({$0.value}).reduce(0, +))")
                }
                .foregroundColor(.green)
                .padding()
            }
            
            Divider()
            
            HStack{
                Button("Close") {
                    NotificationCenter.default.post(name: .closeView, object: nil)
                }
                .buttonStyle(NeumorphicButtonStyle(bgColor: .orange))
                
                Button("Help") {
                    print("Insert help action here")
                }
                .buttonStyle(NeumorphicButtonStyle(bgColor: .orange))
            }
            
            
        }
        
    }
}

struct OutpostView_Previews: PreviewProvider {
    static var previews: some View {
        OutpostView(posdex: .antenna, outpost: DBOutpost.example())
    }
}
