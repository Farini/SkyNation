//
//  CamControlNode.swift
//  SkyTestSceneKit
//
//  Created by Carlos Farini on 11/25/20.
//  Copyright © 2020 Farini. All rights reserved.
//

import Foundation
import SpriteKit
import SceneKit

class CamControlNode:SKNode {
    
    var overlay:StationOverlay
    
    var nodeSize:CGSize
    
    var knob:SKNode
    var knobX:CGFloat = 0
    
    init(overlay:StationOverlay) {
        
        self.overlay = overlay
        guard let scene = SKScene(fileNamed: "CamControl") else { fatalError() }
        self.nodeSize = scene.size
        
        // Knob
        let knob = SKShapeNode(circleOfRadius: 12)
        knob.name = "knob"
        knob.fillColor = .white
        self.knob = knob
        
        super.init()
        
        self.setup(scene: scene)
        self.isUserInteractionEnabled = true
        self.name = "CamControl"
    }
    
    func setup(scene:SKScene) {
        
        print("Setting up cam control node")
        
        let backShape = SKShapeNode(rect: CGRect(origin: CGPoint(x: 0, y: -(nodeSize.height / 2)), size: nodeSize), cornerRadius: 12)
        backShape.fillColor = SCNColor.black.withAlphaComponent(0.7)
        backShape.strokeColor = SCNColor.lightGray
        self.addChild(backShape)
        
        // Slider
        let sliderSize = CGSize(width: nodeSize.width * 0.9, height: 12)
        let sliderBackground = SKShapeNode(rect: CGRect(origin: CGPoint(x: 0, y :0), size: sliderSize), cornerRadius: 4)
        sliderBackground.position.x = nodeSize.width * 0.05
        sliderBackground.position.y = -(nodeSize.height / 2) + 20
        sliderBackground.fillColor = .darkGray
        self.addChild(sliderBackground)
        
        // Knob
        knob.position.y = sliderSize.height / 2
//        knob.position.x = 0
        sliderBackground.addChild(knob)
        
        // Camera Image
        let camSprite = makeSprite(name: "camera.viewfinder")
        camSprite.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        camSprite.position = CGPoint(x: nodeSize.width / 2, y: camSprite.calculateAccumulatedFrame().height / 2)
        camSprite.zPosition = 90
        self.addChild(camSprite)
        
        // Rotate Left
        let rotLSprite = makeSprite(name: "rotate.left")
        rotLSprite.position = CGPoint(x: nodeSize.width - 40, y: 0)
        rotLSprite.zPosition = 90
        self.addChild(rotLSprite)
        
        // Rotate Right
        let rotRSprite = makeSprite(name: "rotate.right")
        rotRSprite.position = CGPoint(x: nodeSize.width * 0.05, y: 0)
        rotRSprite.zPosition = 90
        self.addChild(rotRSprite)
        
        // Title
        let label = SKLabelNode(text: "Camera Viewport")
        label.verticalAlignmentMode = .top
        label.horizontalAlignmentMode = .center
        label.position.y = nodeSize.height / 2 - 6
        label.position.x = nodeSize.width / 2
        self.addChild(label)
    }
    
    /// Puts the slider in the correct position in relation to where the camera is
    func adjustSliderPosition(camera:SCNNode) {
        
        let poz = camera.position.z
        
        // EQUATION
        // 0 = 75, 1 = -300
//        sceneCamera.position.z = 75 - (150 * x) * 2.5
        // poz - 75 = 375 * x
        // x = (poz - 75) / 375
        
//        let x1 = ((poz - 42.0) / 84.0)
//        // x1 = 1 - knobX / maxWidth
//        let maxWidth = nodeSize.width * 0.9
        // 1 - knobX = x1 * maxWidth
        // knobX = x1 * maxWidth + 1
        #if os(macOS)
        knobX = ((poz - 75) / 375) //(1 - x1) * maxWidth //x1 * maxWidth + 1
        #else
        knobX = CGFloat(((poz - 75) / 375))
        #endif
        knob.position.x = knobX
    }
    
    #if os(macOS)
    override func mouseDragged(with event: NSEvent) {
        
        let deltaX = event.deltaX
        let previous = knobX
        let maxWidth = nodeSize.width * 0.9
        
        if deltaX < 0 {
            // move left
            knobX = max(0, previous + deltaX)
        }else if deltaX > 0 {
            // move right
            
            knobX = min(maxWidth, previous + deltaX)
        }
        
        knob.position.x = knobX
        
        let normalizedPosition = 1 - knobX / maxWidth
        overlay.moveCamera(x: normalizedPosition)
        
    }
    #endif
    
    // add #if macOS
    /// Makes a Sprite from an image name
    func makeSprite(name:String) -> SKSpriteNode {
        guard let image = GameImages.commonSystemImage(name: name)?.image(with: .white) else { fatalError() }
        //SKNImage(systemSymbolName: name, accessibilityDescription: name)?.image(with: .white) else { fatalError() }
        // knobX = (1 - x1) * maxWidth
//        guard let image = GameImages.commonSystemImage(name: "name").imag//SKNImage(systemSymbolName: name, accessibilityDescription: name)?.image(with: .white) else { fatalError() }
        // NSImage(systemSymbolName: name, accessibilityDescription: name)?.image(with: .white) else { fatalError() }
        #if os(macOS)
        image.isTemplate = true
        let texture = SKTexture(cgImage: image.cgImage(forProposedRect: nil, context: nil, hints: [:])!)
        #else
        
        let texture = SKTexture(cgImage: image.cgImage!)
        
        #endif
        
         //SKTexture(cgImage: image.cgImage(forProposedRect: nil, context: nil, hints: [:])!)
        let sprite = SKSpriteNode(texture: texture, size:CGSize(width: 36, height: 34))
        sprite.name = name
        sprite.color = .white
        sprite.colorBlendFactor = 1.0
        sprite.anchorPoint = CGPoint.zero
        return sprite
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
