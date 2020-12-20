//
//  StationOverlayObject.swift
//  SkyTestSceneKit
//
//  Created by Farini on 10/26/20.
//  Copyright © 2020 Farini. All rights reserved.
//

import Foundation
import SpriteKit
import SceneKit

/// The Overlay of the `Station` Scene (Main Scene)
class StationOverlay {
    
    var playerName:String
    var scene:SKScene
    var station:Station
    
    // Placeholders
    var playerCardHolder:SKNode
    var cameraPlaceholder:SKNode?
    var orbitListHolder:SKNode
    var newsPlaceholder:SKNode
    
    // Cam
    var sceneCamera:SCNNode
    
    init(renderer:SCNSceneRenderer, station:Station, camNode:SCNNode) {
        
        let overlay:SKScene = SKScene(fileNamed: "StationOverlay")!
        overlay.size = renderer.currentViewport.size
        self.scene = overlay
        self.sceneCamera = camNode
        
        print("_-_-:: Camera position: \(camNode.position)")
        
        self.playerCardHolder = overlay.childNode(withName: "PlayerCardHolder")!
        self.orbitListHolder = overlay.childNode(withName: "VehiclesHolder")!
        self.newsPlaceholder = overlay.childNode(withName: "NewsPlaceholder")!
        
        playerName = "Playername"
        self.station = station
        buildPlayerCard()
    }
    
    /// Playercard has the name, virtual money, and tokens that belong to the player
    func buildPlayerCard() {
        
        let playerCard = SKNode()
        let nameLabel = SKLabelNode(text: "Playername")
        
        // Name
        nameLabel.fontName = "Menlo"
        nameLabel.fontSize = 22
        nameLabel.fontColor = .white
        nameLabel.position = CGPoint(x: 6, y: 25)
        nameLabel.horizontalAlignmentMode = .left
        nameLabel.verticalAlignmentMode = .center
        nameLabel.isUserInteractionEnabled = true
        nameLabel.zPosition = 90
        
        // Money
        let moneyLabel = SKLabelNode(text: "S$: \(station.money)")
        moneyLabel.fontName = "Menlo"
        moneyLabel.fontSize = 22
        moneyLabel.fontColor = .blue
        moneyLabel.position = CGPoint(x: 6, y: 0)
        moneyLabel.horizontalAlignmentMode = .left
        moneyLabel.verticalAlignmentMode = .center
        moneyLabel.isUserInteractionEnabled = true
        moneyLabel.zPosition = 90
        
        // Tokens
        let tokenLabel = SKLabelNode(text: "T: 80")
        tokenLabel.fontName = "Menlo"
        tokenLabel.fontSize = 22
        tokenLabel.fontColor = .orange
        tokenLabel.position = CGPoint(x: 6, y: -25)
        tokenLabel.horizontalAlignmentMode = .left
        tokenLabel.verticalAlignmentMode = .center
        tokenLabel.isUserInteractionEnabled = true
        tokenLabel.zPosition = 90
        
        // Assemble
        playerCard.addChild(nameLabel)
        playerCard.addChild(moneyLabel)
        playerCard.addChild(tokenLabel)
        var cardSize = playerCard.calculateAccumulatedFrame().size
        playerCard.position = CGPoint(x: 25, y: -(cardSize.height))
        
        // Background
        cardSize.height += 16
        cardSize.width += 32
        let cardRect = CGRect(origin: CGPoint.zero, size: cardSize)
        let cardBack = SKShapeNode(rect: cardRect, cornerRadius: 8)
        cardBack.fillColor = SCNColor.black.withAlphaComponent(0.7)
        cardBack.strokeColor = .red
        cardBack.zPosition = 81
        playerCard.addChild(cardBack)
        
        // Adjust
        cardBack.position.y -= cardRect.size.height / 2
        scene.addChild(playerCard)
        
        buildMenu()
    }
    
    /// Orbit list is the `Space Vehicle` objects that are on their way to Mars
    func buildMenu() {
        
        // Position
        var mPos = orbitListHolder.position
        mPos.y -= 44
        
        // Air Control
        if let lssImage = GameImages.commonSystemImage(name: "arrow.3.trianglepath")?.image(with: .white) {
            // SKNImage(systemSymbolName: "arrow.3.trianglepath", accessibilityDescription: "Life Support Systems")?.image(with: .white) {
            
            
            #if os(macOS)
            lssImage.isTemplate = true
            let lssTexture = SKTexture(cgImage: lssImage.cgImage(forProposedRect: nil, context: nil, hints: [:])!)
            #else
            let lssTexture = SKTexture(cgImage: lssImage.cgImage!)
            #endif
//            let lssTexture = SKTexture(cgImage: lssImage.cgImage(forProposedRect: nil, context: nil, hints: [:])!)
            let lssSprite = SKSpriteNode(texture: lssTexture, size: CGSize(width: 36, height: 36))
            lssSprite.name = "Air Control"
            lssSprite.color = .white
            lssSprite.colorBlendFactor = 1.0
            lssSprite.anchorPoint = CGPoint.zero
            lssSprite.position = mPos
            lssSprite.zPosition = 90
            scene.addChild(lssSprite)
        }
        
        // Camera
        var camSprite:SKSpriteNode?
        if let camImage = GameImages.commonSystemImage(name: "camera.viewfinder")?.image(with: .white) {
            // SKNImage(systemSymbolName: "camera.viewfinder", accessibilityDescription: "Camera control")?.image(with: .white) {
            #if os(macOS)
            camImage.isTemplate = true
            let camTexture = SKTexture(cgImage: camImage.cgImage(forProposedRect: nil, context: nil, hints: [:])!)//SKTexture(image: camImage)
            #else
            let camTexture = SKTexture(cgImage: camImage.cgImage!)//SKTexture(image: camImage)
            #endif
            
            
            print("___ Cam image exists !!! \(camImage.size)")
            let cam = SKSpriteNode(texture: camTexture, size:CGSize(width: 36, height: 34))
            cam.name = "CameraIcon"
            cam.color = .white
            cam.colorBlendFactor = 1.0

            cam.anchorPoint = CGPoint(x: 0, y: 0)
            mPos.y -= 44
            cam.position = mPos
            let camPlace = SKNode()
            camPlace.position = mPos
            self.cameraPlaceholder = camPlace
            cam.zPosition = 90
            camSprite = cam
        }else{
            print("___ No Cam image :( !!!")
        }
        
        // Mars
        let marsLabel = SKLabelNode(text: "Mars")
        marsLabel.fontName = "Menlo"
        marsLabel.fontSize = 22
        marsLabel.fontColor = .white
        
        mPos.y -= 22
        marsLabel.position = mPos  //orbitListHolder.position //CGPoint(x: 6, y: 25)
        marsLabel.horizontalAlignmentMode = .left
        marsLabel.verticalAlignmentMode = .center
        marsLabel.isUserInteractionEnabled = true
        marsLabel.zPosition = 90
        
        // Mars Map
        // Create Mars Map label
        // Mars
        let marsMap = SKLabelNode(text: "Map of Mars")
        marsMap.fontName = "Menlo"
        marsMap.fontSize = 22
        marsMap.fontColor = .white
        mPos.y -= 22
        marsMap.position = mPos  //orbitListHolder.position //CGPoint(x: 6, y: 25)
        marsMap.horizontalAlignmentMode = .left
        marsMap.verticalAlignmentMode = .center
        marsMap.isUserInteractionEnabled = true
        marsMap.zPosition = 90
        
        // Vehicles
        if LocalDatabase.shared.vehicles.isEmpty == false {
            for vehicle in LocalDatabase.shared.vehicles {
                let vehicleLabel = SKLabelNode(text: "🚀 Vehicle \(vehicle.engine.rawValue)")
                vehicleLabel.fontName = "Menlo"
                vehicleLabel.fontSize = 22
                vehicleLabel.fontColor = .white
                mPos.y -= 22
                vehicleLabel.position = mPos
                vehicleLabel.horizontalAlignmentMode = .left
                vehicleLabel.verticalAlignmentMode = .center
                vehicleLabel.isUserInteractionEnabled = true
                vehicleLabel.zPosition = 91
                scene.addChild(vehicleLabel)
            }
        }
        
        if let cam = camSprite { scene.addChild(cam)
            print("Did add cam")
        } else {
            print("Could not add cam")
        }
//        scene.addChild(lssControl)
        scene.addChild(marsLabel)
        scene.addChild(marsMap)
        scene.isPaused = false
    }
    
    /// Makes Camera control appear/disappear
    func toggleCamControl() {
        
        if let camNode = scene.childNode(withName: "CamControl") as? CamControlNode {
            
            // Camera control is up. Remove
            let disappear = SKAction.fadeOut(withDuration: 0.25)
            let scaleDown = SKAction.scale(by: 0.2, duration: 0.5)
            let sequel = SKAction.sequence([scaleDown, disappear])
            let moveX = SKAction.moveBy(x: -camNode.position.x, y: 0, duration: 0.5)
            let group = SKAction.group([sequel, moveX])
            camNode.run(group, completion: camNode.removeFromParent)
        }else{
            
            // Create and show camera control
            let node = CamControlNode(overlay: self)
            
            // Adjust Position
            if let camPosition = cameraPlaceholder?.position {
                var adjustedPos = camPosition
                adjustedPos.x += 120
                node.position = adjustedPos
                scene.addChild(node)
            }
            
            // Adjust Slider
            node.adjustSliderPosition(camera: sceneCamera)
        }
    }
    
    /// Moves the camera to a point in the `x` axis
    func moveCamera(x:CGFloat?) {
        // min = 0
        // max = 42
        if let x = x {
            print("Moving Camera to: \(x) | Position:\(sceneCamera.position.z)")
            #if os(macOS)
            sceneCamera.position.z = ((x - 0.5) * 84.0) + 84.0
            #else
            sceneCamera.position.z = ((Float(x) - 0.5) * 84.0) + 84.0
            #endif
        }
    }
    
    
    func generateNews(string:String, warning:Bool = false) {
        
        // Center
        var positionX = scene.size.width / 2
        
        
        let label = SKLabelNode(text: "\(warning ? "⚠️ ":"")\(string)")
        
        // Name
        label.fontName = "Menlo"
        label.fontSize = 22
        label.fontColor = .white
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center
        label.isUserInteractionEnabled = true
        label.zPosition = 90
        
        var backSize = label.calculateAccumulatedFrame().size
        backSize.width += 20
        backSize.height += 12
        
        // Background
        let backNode = SKShapeNode(rectOf: backSize, cornerRadius: 8)
        backNode.position = CGPoint(x: backSize.width / 2 + 6, y: 0)
        backNode.fillColor = SCNColor.black.withAlphaComponent(0.7)
        backNode.strokeColor = SCNColor.lightGray
        backNode.addChild(label)
        
        positionX -= backSize.width / 2
        newsPlaceholder.position.x = positionX
        
        newsPlaceholder.addChild(backNode)
        print("Scene paused: \(scene.isPaused)")
        
        let waiter = SKAction.wait(forDuration: 2.25)
        let runner = SKAction.fadeAlpha(to: 0, duration: 0.75)
        let sequel = SKAction.sequence([waiter, runner])
        label.run(sequel) {
            print("Finished sequel")
            self.scene.removeChildren(in: [self.newsPlaceholder])
        }
    }
}

extension SKNImage {
    
    #if os(macOS)
    func image(with tintColor: SCNColor) -> SKNImage {
        if self.isTemplate == false {
            return self
        }
        
        let image = self.copy() as! NSImage
        image.lockFocus()
        
        tintColor.set()
        
        let imageRect = NSRect(origin: .zero, size: image.size)
        imageRect.fill(using: .sourceIn)
        
        image.unlockFocus()
        image.isTemplate = false
        
        return image
    }
    #else
    func image(with tintColor: SCNColor) -> SKNImage {
//        if self.isTemplate == false {
//            return self
//        }
        
        let image = self.copy() as! UIImage
//        image.lockFocus()
        return image.withTintColor(tintColor, renderingMode: .alwaysTemplate)
//        tintColor.set()
//
//        let imageRect = CGRect(origin: .zero, size: image.size)
//        imageRect.fill(using: .sourceIn)
//
//        image.unlockFocus()
//        image.isTemplate = false
//
//        return image
    }
    #endif
}
