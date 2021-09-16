//
//  TutorialNode.swift
//  SkyNation
//
//  Created by Carlos Farini on 12/20/20.
//

import Foundation
import SpriteKit
import GameKit

class TutorialNode:SKNode {
    
    /// The node with the text
    var label:SKLabelNode
    fileprivate var backgroundShape:SKShapeNode
    
    // Header
    // Buttons
    
    init(text:String) {
        // Label
        let lbl = TutorialNode.makeLabelNode(text: text)
        lbl.zPosition = 2
        
        // Background
        let back = TutorialNode.makeBackgroundNode(label: lbl)
        back.zPosition = 1
        
        self.label = lbl
        self.backgroundShape = back
        
        super.init()
        
        addChild(self.backgroundShape)
        addChild(self.label)
    }
    
    static private func makeLabelNode(text:String) -> SKLabelNode {
        
        // Menlo Regular 14.0
        let label = SKLabelNode(fontNamed: "Menlo Regular")
        label.fontSize = 20.0
        label.fontColor = SKColor.white
        label.numberOfLines = 0
        
        // Alignment
        label.horizontalAlignmentMode = .left
        label.verticalAlignmentMode = .top
        label.text = text
        
        return label
    }
    
    static private func makeBackgroundNode(label:SKLabelNode) -> SKShapeNode {
        
        var textBackSize = label.calculateAccumulatedFrame().size
        textBackSize.width += 20.0
        textBackSize.height += 20.0
        
        let backShape = SKShapeNode(rectOf: textBackSize, cornerRadius: 8.0)
        
        // Coordinates
        var tOrigin = label.calculateAccumulatedFrame().origin
        tOrigin.x += (label.calculateAccumulatedFrame().size.width) / 2
        tOrigin.y += (label.calculateAccumulatedFrame().size.height) / 2
        
        backShape.fillColor = SKColor.black.withAlphaComponent(0.75)
        backShape.strokeColor = SKColor.orange
        backShape.lineWidth = 3.5
        
        let bgSize = CGSize(width: textBackSize.width * 1.2, height: textBackSize.height * 1.2)
        
        // Noise
        let noise = SKTexture(noiseWithSmoothness: 0.8, size: bgSize, grayscale: true)
//        let backNoise = SKSpriteNode(texture: noise)
        let backNoise = SKShapeNode(circleOfRadius: noise.size().width / 4)
        backNoise.strokeColor = SKColor.clear
        backNoise.fillTexture = noise
        
        backNoise.fillColor = SKColor.init(calibratedRed: 0.3, green: 0.2, blue: 0.0, alpha: 0.35)
        //backNoise.colorBlendFactor = 1.0
        backNoise.blendMode = .alpha
        backNoise.zPosition = 0
        
        /*
        let sourcePositions: [SIMD2<Float>] = [
            SIMD2<Float>(0, 1),   SIMD2<Float>(0.5, 1.0),   SIMD2<Float>(1.0, 1.0),
            SIMD2<Float>(0, 0.5), SIMD2<Float>(0.5, 0.5), SIMD2<Float>(1.0, 0.5),
            SIMD2<Float>(0, 0),   SIMD2<Float>(0.5, 0.0),   SIMD2<Float>(1.0, 0.0)
        ]
        
        let destinationPositions: [SIMD2<Float>] = [
            SIMD2<Float>(0.2, 0.9), SIMD2<Float>(0.5, 1.0), SIMD2<Float>(0.8, 0.9),
            SIMD2<Float>(0.00, 0.5),   SIMD2<Float>(0.5, 0.5),   SIMD2<Float>(1.0, 0.5),
            SIMD2<Float>(0.2, 0.1),  SIMD2<Float>(0.5, 0.0),  SIMD2<Float>(0.8, 0.1)
        ]
        
        
        
        let warpGeometryGrid = SKWarpGeometryGrid(columns: 2,
                                                  rows: 2,
                                                  sourcePositions: sourcePositions,
                                                  destinationPositions: destinationPositions)
        
//        let sprite = SKSpriteNode()
        let warpGeometryGridNoWarp = SKWarpGeometryGrid(columns: 2, rows: 2)
//        backNoise.warpGeometry = warpGeometryGridNoWarp
        
//        let warpAction = SKAction.warp(to: warpGeometryGrid, duration: 2.5)
        let warpAction = SKAction.animate(withWarps:[warpGeometryGridNoWarp,
                                                     warpGeometryGrid,
                                                     warpGeometryGridNoWarp,
                                                     warpGeometryGrid,
                                                     warpGeometryGridNoWarp],
                                          times: [0.5, 2.0, 4.0, 6.0, 8.0])
        
        warpAction?.timingMode = .easeInEaseOut
        
        backNoise.run(warpAction!)
        */
        
        backShape.addChild(backNoise)
        backShape.position = tOrigin
        
        let deltaHeight = (backShape.calculateAccumulatedFrame().height / 2.0) + 8.0
        
        // Next
        let button = makeNextButtonNode()
        button.position.y -= deltaHeight
        backShape.addChild(button)
        
        // Close
        let closeButton = TutorialCloseNode()
        closeButton.position.y -= deltaHeight
        closeButton.position.x -= ((button.calculateAccumulatedFrame().width / 2.0) + closeButton.calculateAccumulatedFrame().width) + 8.0
        backShape.addChild(closeButton)
        
        return backShape
    }
    
    static private func makeNextButtonNode() -> SKNode {
        return TutorialButtonNode()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class TutorialCloseNode:SKNode {
    
    var label:SKLabelNode
    
    override init() {
        // Menlo Regular 14.0
        let label = SKLabelNode(fontNamed: "Menlo Regular")
        
        label.fontSize = 20.0
        label.fontColor = SKColor.white
        label.numberOfLines = 1
        
        // Alignment
        label.horizontalAlignmentMode = .left
        label.verticalAlignmentMode = .top
        
        label.text = "❌ Close"
        self.label = label
        
        var textBackSize = label.calculateAccumulatedFrame().size
        textBackSize.width += 18.0
        textBackSize.height += 8.0
        
        let backShape = SKShapeNode(rectOf: textBackSize, cornerRadius: 8.0)
        
        // Coordinates
        var tOrigin = CGPoint.zero
        tOrigin.x += (label.calculateAccumulatedFrame().size.width) / 2
        tOrigin.y -= (label.calculateAccumulatedFrame().size.height) / 2
        
        backShape.fillColor = SKColor.black.withAlphaComponent(0.5)
        backShape.strokeColor = SKColor.red
        backShape.lineWidth = 3.5
        backShape.position = tOrigin
        
        label.zPosition = 2
        backShape.zPosition = -1
        label.addChild(backShape)
        
        super.init()
        
        self.addChild(label)
        
        //        label.isUserInteractionEnabled = true
        //self.isUserInteractionEnabled = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func mouseUp(with event: NSEvent) {
        print("Mouse Up! Close, or Next ?!?")
    }
    
}

class TutorialButtonNode:SKNode {
    
    var label:SKLabelNode
    
    override init() {
        // Menlo Regular 14.0
        let label = SKLabelNode(fontNamed: "Menlo Regular")
        
        label.fontSize = 20.0
        label.fontColor = SKColor.white
        label.numberOfLines = 1
        
        // Alignment
        label.horizontalAlignmentMode = .left
        label.verticalAlignmentMode = .top
        
        label.text = "Next ➡️"
        self.label = label
        
        var textBackSize = label.calculateAccumulatedFrame().size
        textBackSize.width += 18.0
        textBackSize.height += 8.0
        
        let backShape = SKShapeNode(rectOf: textBackSize, cornerRadius: 8.0)
        
        // Coordinates
        var tOrigin = CGPoint.zero
        tOrigin.x += (label.calculateAccumulatedFrame().size.width) / 2
        tOrigin.y -= (label.calculateAccumulatedFrame().size.height) / 2
        
        backShape.fillColor = SKColor.black.withAlphaComponent(0.5)
        backShape.strokeColor = SKColor.orange
        backShape.lineWidth = 3.5
        backShape.position = tOrigin
        
        label.zPosition = 2
        backShape.zPosition = -1
        label.addChild(backShape)
        
        super.init()
        
        self.addChild(label)
        
//        label.isUserInteractionEnabled = true
        //self.isUserInteractionEnabled = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func mouseUp(with event: NSEvent) {
        print("Mouse Up! Close, or Next ?!?")
    }
}

