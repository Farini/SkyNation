//
//  SideMenuNode.swift
//  SkyNation
//
//  Created by Carlos Farini on 12/24/20.
//

import Foundation
import SpriteKit

class SideMenuNode:SKNode {
    
    // Side Warning Pattern
    // LSS - Life Support Systems
    // Camera - Cam control
    // Lights - Light Control
    // Chat &| Messages
    // Mars - Mars
    // Vehicles - Vehicles List
    
    let buttonSize:CGSize = CGSize(width: 36, height: 36)
    
    // The node where camera controls scales down to
    var cameraPlaceholder:SKNode?
    
    override init() {
        super.init()
    }
    
    func setupMenu() {
        
        print("Seting up side menu node")
        
        var pos:CGPoint = .zero
        // Side Warning pattern
        
        // adjust X
        pos.x = 20
        
        // Air Control
        if let lssSprite:SKSpriteNode = makeButton("arrow.3.trianglepath") {
            lssSprite.name = "Air Control"
            lssSprite.color = .white
            lssSprite.colorBlendFactor = 1.0
            lssSprite.anchorPoint = CGPoint.zero
            pos.y -= lssSprite.calculateAccumulatedFrame().size.height
            lssSprite.position = pos
            lssSprite.zPosition = 80
            addChild(lssSprite)
        }
        pos.y -= 6
        
        // Camera
        if let camSprite:SKSpriteNode = makeButton("camera.viewfinder") {
            camSprite.name = "CameraIcon"
            camSprite.color = .white
            camSprite.colorBlendFactor = 1.0
            pos.y -= camSprite.calculateAccumulatedFrame().size.height
            camSprite.anchorPoint = CGPoint.zero
            camSprite.position = pos
            camSprite.zPosition = 80
            addChild(camSprite)
        }
        pos.y -= 6
        // Placeholder node
        let holder = SKNode()
        holder.name = "CameraPlaceholder"
        holder.position = pos
        self.cameraPlaceholder = holder
        addChild(holder)
        
        // Lights
        if let lightsSprite:SKSpriteNode = makeButton("lightbulb") {
            lightsSprite.name = "LightsButton"
            lightsSprite.color = .white
            lightsSprite.colorBlendFactor = 1.0
            pos.y -= lightsSprite.calculateAccumulatedFrame().size.height
            lightsSprite.anchorPoint = CGPoint.zero
            lightsSprite.position = pos
            lightsSprite.zPosition = 80
            addChild(lightsSprite)
        }
        pos.y -= 6
        
        // Tutorial
//        let tutImage = GameImages.commonSystemImage(name: "questionmark.diamond")!.image(with: .white)
//        let tutTexture = SKTexture(image: tutImage)
//        let tutSprite = SKSpriteNode(texture: tutTexture, size: CGSize(width: 36, height: 36))
//        tutSprite.anchorPoint = CGPoint(x: 0.5, y: 0)
//        tutSprite.name = "tutorial"
//        self.tutorialButton = tutSprite
        
        if let tutorialSprite:SKSpriteNode = makeButton("questionmark.diamond") {
            tutorialSprite.name = "tutorial"
            tutorialSprite.color = .white
            tutorialSprite.colorBlendFactor = 1.0
            pos.y -= tutorialSprite.calculateAccumulatedFrame().size.height
            tutorialSprite.anchorPoint = CGPoint.zero
            tutorialSprite.position = pos
            tutorialSprite.zPosition = 80
            addChild(tutorialSprite)
        }
        pos.y -= 6
        
        // Chat
        if let chatSprite:SKSpriteNode = makeButton("bubble.left") {
            chatSprite.name = "ChatButton"
            chatSprite.color = .white
            chatSprite.colorBlendFactor = 1.0
            pos.y -= chatSprite.calculateAccumulatedFrame().size.height
            chatSprite.anchorPoint = CGPoint.zero
            chatSprite.position = pos
            chatSprite.zPosition = 80
            addChild(chatSprite)
        }
        pos.y -= 6
        
        // Mars
        if let marsSprite:SKSpriteNode = makeButton("circle.dashed.inset.fill") {
            marsSprite.name = "MarsButton"
            marsSprite.color = .white
            marsSprite.colorBlendFactor = 1.0
            pos.y -= marsSprite.calculateAccumulatedFrame().size.height
            marsSprite.anchorPoint = CGPoint.zero
            marsSprite.position = pos
            marsSprite.zPosition = 80
            addChild(marsSprite)
        }
        pos.y -= 6
        
        buildRuler()
    }
    
    func buildRuler() {
        
        // Ruler
        let rulerWidth:CGFloat = 8.0
        let rulerHeight = calculateAccumulatedFrame().size.height
        var pos = CGPoint.zero
        
        let path = CGMutablePath()
        path.move(to: .zero)
        
        // Rectangle
        path.addLine(to: CGPoint(x: rulerWidth, y: 0))
        path.addLine(to: CGPoint(x: rulerWidth, y: -rulerHeight))
        path.addLine(to: CGPoint(x: 0, y: -rulerHeight - rulerWidth))
        path.addLine(to: .zero)
        
        pos.y = -rulerHeight - rulerWidth
        pos.y -= 8
        
        for _ in 1...3 {
            path.move(to: pos)
            path.addLine(to: CGPoint(x:rulerWidth, y:pos.y + 8))
            path.addLine(to: CGPoint(x:rulerWidth, y: pos.y))
            path.addLine(to: CGPoint(x:0, y:pos.y - 8))
            path.addLine(to: CGPoint(x:0, y:pos.y))
            pos.y -= 16
        }
        
        
        let rulerShape = SKShapeNode(path: path)
        rulerShape.position = CGPoint(x: 0, y: 0)
        rulerShape.lineWidth = 0
        rulerShape.fillColor = SCNColor.gray.withAlphaComponent(0.7)
        rulerShape.zPosition = 32
        addChild(rulerShape)
    }
    
    /// Makes a Sprite Node from an image name
    func makeButton(_ imageName:String) -> SKSpriteNode? {
        guard let image = GameImages.commonSystemImage(name: imageName)?.image(with: .white) else {
            return nil
        }
        #if os(macOS)
        image.isTemplate = true
        let texture = SKTexture(cgImage: image.cgImage(forProposedRect: nil, context: nil, hints: [:])!)
        #else
        let texture = SKTexture(cgImage: image.withTintColor(.white, renderingMode: .alwaysTemplate).cgImage!) //SKTexture(image: camImage)
        #endif
        let sprite:SKSpriteNode = SKSpriteNode(texture: texture, color: .white, size: buttonSize)
        return sprite
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
