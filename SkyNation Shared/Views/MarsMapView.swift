//
//  MarsMapView.swift
//  SkyTestSceneKit
//
//  Created by Carlos Farini on 11/4/20.
//  Copyright © 2020 Farini. All rights reserved.
//

import Foundation
import SpriteKit
import SwiftUI

struct MarsMapView: View {
    
    var body: some View {
        SpriteKitContainer(scene: self.scene)
            .frame(width: 600, height: 400)
    }
    
    var scene:SKScene {
        let scene = MarsMapScene(size: CGSize(width: 600, height: 400))
        return scene
    }
}

struct MarsMapView_Previews: PreviewProvider {
    static var previews: some View {
        MarsMapView()
    }
}
