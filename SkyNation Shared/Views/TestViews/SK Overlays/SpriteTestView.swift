//
//  SpriteTestView.swift
//  SkyNation
//
//  Created by Carlos Farini on 1/14/22.
//

import SwiftUI
import SpriteKit
import SceneKit

struct SpriteTestView: View {
    
    @State private var news:String?
    private var scene:SKScene
    
    init() {
        let newScene = SKScene(size: CGSize(width: 500, height: 400))
        newScene.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.scene = newScene
    }
    
    var body: some View {
        VStack {
            Text("SpriteKit Scene")
            if let news = news {
                Text("News: \(news)")
            }
            //SpriteView(scene: SKScene(fileNamed: "NewsObj")!)
            SpriteView(scene: scene, transition: .doorway(withDuration: 1), isPaused: false, preferredFramesPerSecond: 60)
        }
        .onAppear {
            describeScene()
        }
    }
    
    static func makeScene() -> SKScene {
        return SKScene()
    }
    
    func describeScene() {
        
        let newNode = NewsNode(type: .Intro, text: "Here is the game introduction. \nClick here, click there, \n...and you good to go.")
        
        newNode.position = CGPoint.zero
        self.scene.addChild(newNode)
        
        
    }
}

struct SpriteTestView_Previews: PreviewProvider {
    static var previews: some View {
        SpriteTestView()
    }
}

