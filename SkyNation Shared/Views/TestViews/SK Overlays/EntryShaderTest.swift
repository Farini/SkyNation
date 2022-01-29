//
//  EntryShaderTest.swift
//  SkyNation
//
//  Created by Carlos Farini on 1/28/22.
//

import SwiftUI
import SpriteKit

struct EntryShaderTest: View {
    
    var scene:SKScene
    let shader = SKShader(fileNamed: "StarNest.fsh")
    
    // Entry Shaders:
    // StarNest.fsh, BusyCircuitry.fsh
    // DNA shader: DNAHelix.fsh
    
    var body: some View {
        ZStack {
            SpriteView(scene: scene, transition: .doorway(withDuration: 1), isPaused: false, preferredFramesPerSecond: 60)
        }
        .onAppear {
            buildScene()
        }
    }
    
    init() {
        let newScene = SKScene(size: CGSize(width: 750, height: 400))
        newScene.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.scene = newScene
    }
    
    func buildScene() {
        
        let shapeNode = SKShapeNode(rectOf: CGSize(width: 730, height: 380))
        shapeNode.lineWidth = 0
        
        let uniforms = SKUniform(name: "u_resolution", vectorFloat2: vector_float2(730.0, 380.0)) // vector_float2(730.0, 380.0)
        
        shader.addUniform(uniforms)
        
        self.scene.addChild(shapeNode)
        
        shapeNode.fillShader = shader
//        shapeNode.run(SKAction.move(by: CGVector(dx: 0, dy: 1), duration: 10.0))
//        let entranceTexture = SKTexture(imageNamed: "EntranceLogo")
        // 397 x 70
//        let entrySprite = SKSpriteNode(texture: entranceTexture, size: CGSize(width: 397, height: 70))
//        entrySprite.alpha = 0.1
        
//        let entryAction1 = SKAction.fadeIn(withDuration: 3.0)
//        entrySprite.run(entryAction1)
        
//        self.scene.addChild(entrySprite)
        
    }
    
}

struct EntryShaderTest_Previews: PreviewProvider {
    static var previews: some View {
        EntryShaderTest()
    }
}
