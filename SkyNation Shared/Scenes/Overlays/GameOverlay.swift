//
//  GameOverlay.swift
//  SkyNation
//
//  Created by Carlos Farini on 8/22/21.
//

import Foundation
import SpriteKit
import SceneKit

/// The Overlay of the `Station` Scene (Main Scene)
class GameOverlay:NSObject, SKSceneDelegate {
    
    var scene:SKScene
    var station:Station
    
    var playerName:String
    
    // Placeholders
    var playerCardHolder:SKNode
    var cameraPlaceholder:SKNode?
    var orbitListHolder:SKNode
    var newsPlaceholder:SKNode
    var sideMenuNode:SideMenuNode?
    
    // Camera
    var sceneCamera:GameCamera
    
    // Viewport
    var renderer:SCNSceneRenderer
    
    init(renderer:SCNSceneRenderer, station:Station, camNode:GameCamera) {
        
        let overlay:SKScene = SKScene(fileNamed: "GameOverlay")!
        overlay.size = renderer.currentViewport.size
        
        self.scene = overlay
        self.renderer = renderer
        self.sceneCamera = camNode
        
        // print("_-_-:: Camera position: \(camNode.position)")
        // print("_-_-:: ViewPort: \(renderer.currentViewport)")
        
        self.playerCardHolder = overlay.childNode(withName: "PlayerCardHolder")!
        self.orbitListHolder = overlay.childNode(withName: "VehiclesHolder")!
        self.newsPlaceholder = overlay.childNode(withName: "NewsPlaceholder")!
        
        playerName = "Playername"
        self.station = station
        
        super.init()
        
        self.scene.delegate = self
        self.scene.isPaused = false
        
        self.buildPlayerCard()
        
    }
    
    private var shouldUpdate:Bool = true
    func update(_ currentTime: TimeInterval, for scene: SKScene) {
        if Int(currentTime) % 10 == 0 {
            if shouldUpdate == true {
                if GameSettings.debugScene {
                    print("Overlay scene update")
                }
                self.updateTravellingVehiclesList()
                self.shouldUpdate = false
            }
        } else {
            shouldUpdate = true
        }
    }
    
    /// Updates the camera node for the new sccene
    func didChangeScene(camNode:GameCamera) {
        self.sceneCamera = camNode
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
                card.tokenLabel.text = "\(player.countTokens().count)" //"\(player.timeTokens.count)"
                
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
        self.updateTravellingVehiclesList()
        
        /*
        if LocalDatabase.shared.vehicles.isEmpty == false {
            for vehicle in LocalDatabase.shared.vehicles {
                
//                mPos.y -= 22
                
//                let label = self.makeTravellingVehicleLabel(vehicle: vehicle)
//                let deltaY = label.calculateAccumulatedFrame().size.height + 4
//                mPos.y -= deltaY
//                label.position = mPos
//                scene.addChild(label)
                
                let vehicleLabel = SKLabelNode(text: "🚀 \(vehicle.name) \(vehicle.engine.rawValue)")
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
        */
        
        // Unpause the scene
//        scene.isPaused = false
    }
    
    private func updateTravellingVehiclesList() {
        
        // Vehicles
        if LocalDatabase.shared.vehicles.isEmpty == false {
            
            var mPos = orbitListHolder.position
            mPos.y -= 32
            
            let sideMenu = self.sideMenuNode ?? SKNode()
            mPos.y -= sideMenu.calculateAccumulatedFrame().size.height
            
            // Clear Labels
            self.clearTravellingList()
            
            for vehicle in LocalDatabase.shared.vehicles {
                
                let label = self.makeTravellingVehicleLabel(vehicle: vehicle)
                let deltaY = label.calculateAccumulatedFrame().size.height + 4
                mPos.y -= deltaY
                label.position = mPos
                scene.addChild(label)
                
            }
        }
        
    }
    
    /// Removes all vehicle labels (before updating scene with vehicles list)
    private func clearTravellingList() {
        for child in scene.children {
            if child.name == "SpaceVehicleLabel" {
                child.removeFromParent()
            }
        }
    }
    
    /// Makes a Label with a Progress Bar for Vehicles
    private func makeTravellingVehicleLabel(vehicle:SpaceVehicle) -> SKNode {
        
        // Add Badge if vehicle is registered
        var preString:String = "🚀"
        if let _ = vehicle.registration {
            preString = "💠🚀"
        }
        
        let vehicleLabel = SKLabelNode(text: "\(preString) \(vehicle.name) \(vehicle.engine.rawValue)")
        vehicleLabel.name = "SpaceVehicleLabel"
        vehicleLabel.fontName = "Menlo"
        vehicleLabel.fontSize = 18
        vehicleLabel.fontColor = .white
        vehicleLabel.horizontalAlignmentMode = .left
        vehicleLabel.verticalAlignmentMode = .center
        vehicleLabel.isUserInteractionEnabled = true
        vehicleLabel.zPosition = 91
        
        // Empty Node (named after vehicle)
        let emptyNode = SKNode()
        emptyNode.name = vehicle.id.uuidString
        vehicleLabel.addChild(emptyNode)
        
        // Progress
        let progbarWidth = 80.0
        let barBackSize:CGSize = CGSize(width: progbarWidth, height: 8.0)
        let progOrigin:CGPoint = CGPoint(x: -(progbarWidth / 2.0), y: 0)
        // Progress back
        let progressBarBack = SKShapeNode(rect: CGRect(origin: progOrigin, size: barBackSize), cornerRadius: 4)
        progressBarBack.fillColor = .gray.withAlphaComponent(0.5)
        progressBarBack.zPosition = 92
        
        // Progress front
        if let travelProg = vehicle.calculateProgress() {
            let travelWidth = progbarWidth * travelProg
            let progressBarFront = SKShapeNode(rect: CGRect(origin: .zero, size: CGSize(width: travelWidth, height: 7.0)))
            progressBarFront.fillColor = .blue
            progressBarFront.zPosition = 93
            progressBarBack.addChild(progressBarFront)
        }
        
        vehicleLabel.addChild(progressBarBack)
        
        return vehicleLabel
        // scene.addChild(vehicleLabel)
    }
    
    /// Makes Camera control appear/disappear
    func toggleCamControl() {
        
        //        print("Toggle cam ccontrol")
        
        if let camNode:CamControlNode = scene.childNode(withName: "CamControl") as? CamControlNode {
            print("UP cam ccontrol")
            // Camera control is up. Remove
            let disappear = SKAction.fadeOut(withDuration: 0.25)
            let scaleDown = SKAction.scale(by: 0.2, duration: 0.5)
            let sequel = SKAction.sequence([scaleDown, disappear])
            let moveX = SKAction.moveBy(x: -camNode.position.x, y: 0, duration: 0.5)
            let group = SKAction.group([sequel, moveX])
            camNode.run(group, completion: camNode.removeFromParent)
            
        } else {
            
            // Create and show camera control
            let node = CamControlNode(overlay: self, gCamera: sceneCamera)
            
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
        
        let waiter = SKAction.wait(forDuration: 2.25)
        let runner = SKAction.fadeAlpha(to: 0, duration: 0.75)
        let sequel = SKAction.sequence([waiter, runner])
        label.run(sequel) {
            //            print("Finished generating news")
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
        //        print("Scene paused: \(scene.isPaused)")
        
        let waiter = SKAction.wait(forDuration: 2.25)
        let runner = SKAction.fadeAlpha(to: 0, duration: 0.75)
        let sequel = SKAction.sequence([waiter, runner])
        label.run(sequel) {
            print("Finished sequel")
            backNode.removeFromParent()
        }
        
    }
}


