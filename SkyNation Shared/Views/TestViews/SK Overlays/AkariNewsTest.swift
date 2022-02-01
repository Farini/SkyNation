//
//  AkariNewsTest.swift
//  SkyNation
//
//  Created by Carlos Farini on 1/31/22.
//

import SwiftUI
import SpriteKit

struct AkariNewsTest: View {
    
    @State private var news:String?
    private var scene:SKScene
    let fakeNews:String = """
Greetings, commander `Player name`.
Your objective is to take over this space station
and expand its size and capabilities.
If you are so brave, send space vehicles to Mars
and colonize the red planet.
"""
    init() {
        
        let newScene = SKScene(size: CGSize(width: 485, height: 230))
        
        newScene.backgroundColor = .clear
        newScene.anchorPoint = CGPoint(x: 0, y: 1)
        self.scene = newScene
    }
    
    var body: some View {
        ZStack {
            
            Image("FrontImage1")
                //.resizable()
                //.aspectRatio(contentMode: .fill)
                // .saturation(0.5)
                // .brightness(0.01)
            
            //SpriteView(scene: SKScene(fileNamed: "NewsObj")!)
            SpriteView(scene: scene, transition: .doorway(withDuration: 1), isPaused: false, preferredFramesPerSecond: 60)
                .frame(width: 485, height: 230, alignment: .center)
            
            // Text("SpriteKit Scene")
            if let news = news {
                Text("News: \(news)")
            }
        }
        .onAppear {
            prepareScene()
        }
    }
    
    static func makeScene() -> SKScene {
        return SKScene()
    }
    
    func prepareScene() {
        
        let n = AkariNewsNode(type: .News, string: fakeNews)
        self.scene.addChild(n)
        
    }
}

struct AkariNewsTest_Previews: PreviewProvider {
    static var previews: some View {
        AkariNewsTest()
            .frame(width: 900, height: 450, alignment: .center)
    }
}

