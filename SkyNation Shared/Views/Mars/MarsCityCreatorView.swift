//
//  MarsCityCreatorView.swift
//  SkyNation
//
//  Created by Carlos Farini on 2/27/21.
//

import SwiftUI

struct MarsCityCreatorView: View {
    
    @State var name:String = ""
    @State var position:Vector3D = .zero
    
    var body: some View {
        
        VStack {
            
            Text("City View").font(.title)
            Divider()
            Text("Claim this city")
            
            Text("City name: \(name)")
            Text("Position: \(Int(position.x)), \(Int(position.y)), \(Int(position.z))")
            
            Button("Create") {
                print("Create city here")
            }
            .padding()
        }
        
    }
}

struct MarsCityCreatorView_Previews: PreviewProvider {
    static var previews: some View {
        MarsCityCreatorView()
    }
}
