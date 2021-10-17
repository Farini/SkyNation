//
//  EDLSceneView.swift
//  SkyNation
//
//  Created by Carlos Farini on 10/16/21.
//

import SwiftUI
import SceneKit

struct EDLSceneView: View {
    
    @ObservedObject var edlController:EDLSceneController
    
    var body: some View {
        ZStack(alignment: Alignment(horizontal: .trailing, vertical: .bottom)) {
            SceneView(scene: edlController.scene, pointOfView: nil, options: .allowsCameraControl, preferredFramesPerSecond: 30, antialiasingMode: .none, delegate: nil, technique: nil)
            
            VStack {
                Text("V: \(edlController.vehicle.name)")
                
                Button("Close") {
                    print("Close view")
                }
                .buttonStyle(GameButtonStyle())
                
                Text(edlController.actNames.joined(separator: " ,"))
                
            }
            .padding(20)
            .background(Color.black.luminanceToAlpha())
            .cornerRadius(12)
        }
    }
}

struct EDLSceneView_Previews: PreviewProvider {
    static var previews: some View {
        EDLSceneView(edlController: EDLSceneController(vehicle: SpaceVehicle(engine: .T12)))
    }
}
