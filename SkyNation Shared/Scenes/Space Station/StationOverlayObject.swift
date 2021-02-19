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
class StationOverlay:NSObject, SKSceneDelegate {
    
    var scene:SKScene
    var station:Station
    
    var playerName:String
    
    // Placeholders
    var playerCardHolder:SKNode
    var cameraPlaceholder:SKNode?
    var orbitListHolder:SKNode
    var newsPlaceholder:SKNode
    var sideMenuNode:SideMenuNode?
    
    // Cam
    var sceneCamera:GameCamera
    
    // Viewport
    var renderer:SCNSceneRenderer
    
    init(renderer:SCNSceneRenderer, station:Station, camNode:GameCamera) {
        
        let overlay:SKScene = SKScene(fileNamed: "StationOverlay")!
        overlay.size = renderer.currentViewport.size
        
        self.scene = overlay
        self.renderer = renderer
        self.sceneCamera = camNode
        
        print("_-_-:: Camera position: \(camNode.position)")
        print("_-_-:: ViewPort: \(renderer.currentViewport)")
        
        self.playerCardHolder = overlay.childNode(withName: "PlayerCardHolder")!
        self.orbitListHolder = overlay.childNode(withName: "VehiclesHolder")!
        self.newsPlaceholder = overlay.childNode(withName: "NewsPlaceholder")!
        
        playerName = "Playername"
        self.station = station
        
        super.init()
        
        self.buildPlayerCard()
        self.scene.delegate = self
    }
    
    /// Playercard has the name, virtual money, and tokens that belong to the player
    func buildPlayerCard() {
        
        if let player = LocalDatabase.shared.player {
            let playerCard = PlayerCardNode(player: player)
            playerCard.name = "playercard"
            scene.addChild(playerCard)
        } else {
            let newPlayer = SKNPlayer()
            let playerCard = PlayerCardNode(player: newPlayer)
            playerCard.name = "playercard"
            scene.addChild(playerCard)
        }
        
        buildMenu()
    }
    
    /// Updates the `Player Card` overlay node
    func updatePlayerCard() {
        
        
        if let player = LocalDatabase.shared.player {
        
            if let card:PlayerCardNode = scene.childNode(withName: "playercard") as? PlayerCardNode {
                card.nameLabel.text = player.name
                card.moneyLabel.text = GameFormatters.numberFormatter.string(from: NSNumber(value:player.money))
                card.tokenLabel.text = "\(player.timeTokens.count)"
                
            } else {
                print("⚠️ Error: Couldnt find PlayerCardNode in Overlay Scene")
            }
        } else {
            print("⚠️ Error: Couldn't find Local Database Player")
        }
    }
    
    /// Orbit list is the `Space Vehicle` objects that are on their way to Mars
    func buildMenu() {
        
        // Position
        var mPos = orbitListHolder.position
        mPos.y -= 32
        
        // Side menu
        let sideMenu = SideMenuNode()
        sideMenu.setupMenu()
        sideMenu.position = mPos
        scene.addChild(sideMenu)
        cameraPlaceholder = sideMenu.cameraPlaceholder?.copy() as? SKNode
        self.sideMenuNode = sideMenu
        
        mPos.y -= sideMenu.calculateAccumulatedFrame().size.height
        
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
        
        // Unpause the scene
        scene.isPaused = false
        
    }
    
    /// Makes Camera control appear/disappear
    func toggleCamControl() {
        print("Toggle cam ccontrol")
        if let camNode = scene.childNode(withName: "CamControl") as? CamControlNode {
            print("UP cam ccontrol")
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
            if let camPosition = sideMenuNode?.position {
                print("Camera Placeholder Position: \(camPosition)")
                var adjustedPos = camPosition
                adjustedPos.x += 120
                adjustedPos.y -= 120
                node.position = adjustedPos
                scene.addChild(node)
            }
            
            // Adjust Slider
            node.adjustSliderPosition(camera: sceneCamera)
        }
    }
    
    /// Moves the camera in the Scene to a point in the `x` axis
    func moveCamera(x:CGFloat?) {
        // Find a good spot to make the camera @lookAt
        // 0 = -300
        // 1 = 75
        if let x = x {
            print("Moving Camera to: \(x) | Position:\(sceneCamera.position.z)")
            #if os(macOS)
//            sceneCamera.position.z = -300 + x * 375 //75 - (375 * x) //-300 * x  // ((x - 0.5) * 84.0) + 84.0
            let destination = -300 + x * 375
            sceneCamera.panCamera(to: Double(destination))
            #else
            let destination = -300 + x * 375
            sceneCamera.panCamera(to: Double(destination))
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
//            self.scene.removeChildren(in: [self.newsPlaceholder])
            backNode.removeFromParent()
        }
    }
    
    func showTutorial() {
        
        // Center
        var positionX = scene.size.width / 2
        let label = SKLabelNode(text: "Tutorial example. This is a tutorial\n But what does a tutorial do?\n That is the question that only the game can answer :)")
        label.numberOfLines = 0
        
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
            backNode.removeFromParent()
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
