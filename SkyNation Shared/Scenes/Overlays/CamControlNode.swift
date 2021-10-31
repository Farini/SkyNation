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
    
    var overlay:GameOverlay
    
    var nodeSize:CGSize
    
//    var knob:SKNode
    var knobX:CGFloat = 0
    
    var gameCamera:GameCamera
    var povLabel:SKLabelNode?
    
    
    init(overlay:GameOverlay, gCamera:GameCamera) {

        self.overlay = overlay
        guard let scene = SKScene(fileNamed: "CamControl") else { fatalError() }
        self.nodeSize = scene.size

        // Knob
//        let knob = SKShapeNode(circleOfRadius: 12)
//        knob.name = "knob"
//        knob.fillColor = .white
//        self.knob = knob
        
        // Camera
        self.gameCamera = gCamera

        super.init()

        self.setup(scene: scene)
        self.isUserInteractionEnabled = true
        self.name = "CamControl"
    }
    
    func setup(scene:SKScene) {
        
        print("Setting up cam control node")
        
        // Background Shape
        let backShape = SKShapeNode(rect: CGRect(origin: CGPoint(x: 0, y: -(nodeSize.height / 2)), size: nodeSize), cornerRadius: 12)
        backShape.fillColor = SCNColor.black.withAlphaComponent(0.7)
        backShape.strokeColor = SCNColor.lightGray
        self.addChild(backShape)
        
        // Slider
        /*
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
        */
        
        // Camera Image
        let camSprite = makeSprite(name: "camera.viewfinder")
        camSprite.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        camSprite.position = CGPoint(x: nodeSize.width / 2, y: camSprite.calculateAccumulatedFrame().height / 2)
        camSprite.zPosition = 90
        self.addChild(camSprite)
        
        // Rotate Left
        let rotLSprite = makeSprite(name: "chevron.backward.square")
        rotLSprite.position = CGPoint(x: nodeSize.width * 0.05, y: 0) // nodeSize.width - 40
        rotLSprite.zPosition = 90
        self.addChild(rotLSprite)
        
        // Rotate Right
        let rotRSprite = makeSprite(name: "chevron.right.square") // chevron.backward.square
        rotRSprite.position = CGPoint(x: nodeSize.width - 40, y: 0)
        rotRSprite.zPosition = 90
        self.addChild(rotRSprite)
        
        // Title
        let label = SKLabelNode(text: "Camera Viewport")
        label.fontName = "Menlo Regular"
        label.fontSize = 20
        label.verticalAlignmentMode = .top
        label.horizontalAlignmentMode = .center
        label.position.y = nodeSize.height / 2 - 6
        label.position.x = nodeSize.width / 2
        self.addChild(label)
        
        // Current Camera POV Title
        guard let pov:GamePOV = gameCamera.currentPOV else {
            print("⚠️ Failed to get camera POV")
            return
        }
        
        // POV Label - indicates camera position
        let povLabel = SKLabelNode(text: pov.name)
        povLabel.verticalAlignmentMode = .top
        povLabel.horizontalAlignmentMode = .center
        povLabel.position = scene.childNode(withName: "POV")?.position ?? CGPoint.zero
        povLabel.fontColor = SKColor.blue
        povLabel.fontName = "Menlo Regular"
        povLabel.fontSize = 20
        
        povLabel.position.y = scene.childNode(withName: "POV")?.position.y ?? 6
        povLabel.position.x = nodeSize.width / 2
        self.povLabel = povLabel
        
        self.addChild(povLabel)
    }
    
    /// Updates the label showing POV
    func updatePOV() {
        let text = gameCamera.currentPOV?.name
        self.povLabel?.text = text
    }
    
    /// Puts the slider in the correct position in relation to where the camera is
//    func adjustSliderPosition(camera:SCNNode) {
//
//        let poz = camera.position.z
//
//        #if os(macOS)
//        knobX = ((poz - 75) / 375) //(1 - x1) * maxWidth //x1 * maxWidth + 1
//        #else
//        knobX = CGFloat(((poz - 75) / 375))
//        #endif
//        knob.position.x = knobX
//    }
    
    /// The position the camera needs to go to
    var camNormalizedPosition:CGFloat?
    
    
    #if os(macOS)
//    override func mouseDragged(with event: NSEvent) {
//
//        let deltaX = event.deltaX
//        let previous = knobX
//        let maxWidth = nodeSize.width * 0.9
//
//        if deltaX < 0 {
//            // move left
//            knobX = max(0, previous + deltaX)
//        }else if deltaX > 0 {
//            // move right
//
//            knobX = min(maxWidth, previous + deltaX)
//        }
//
//        knob.position.x = knobX
//
//        let normalizedPosition = 1 - knobX / maxWidth
//        self.camNormalizedPosition = normalizedPosition
//    }
    
//    override func mouseUp(with event: NSEvent) {
//        if let normalizedPosition = camNormalizedPosition {
//            overlay.moveCamera(x: normalizedPosition)
//            self.camNormalizedPosition = nil
//        }
//    }
    
    #endif
    
    
    /// Makes a Sprite from an image name
    func makeSprite(name:String) -> SKSpriteNode {
        
        guard let image = GameImages.commonSystemImage(name: name)?.image(with: .white) else { fatalError() }
        
        #if os(macOS)
        image.isTemplate = true
        let texture = SKTexture(cgImage: image.cgImage(forProposedRect: nil, context: nil, hints: [:])!)
        #else
        
        let texture = SKTexture(cgImage: image.cgImage!)
        
        #endif
        
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
