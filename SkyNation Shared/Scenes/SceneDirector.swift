//
//  SceneDirector.swift
//  SkyTestSceneKit
//
//  Created by Farini on 8/18/20.
//  Copyright © 2020 Farini. All rights reserved.
//

import Foundation
import SceneKit

/**
 A Singleton that helps control the main scene.
 Use this class to send notifications to the `SCNScene`
 This class sends a message to the `GameController` class to update scenes.
 */
class SceneDirector {
    
    static let shared = SceneDirector()
    
    var gameController:GameController?
    
    private init() {
        
    }
    
    func controllerDidLoadScene(controller:GameController) {
        self.gameController = controller
    }
    
    /// Tells the Scene that the delivery os over. Rid of Ship, and Load the Earth
    func didFinishDeliveryOrder(order:PayloadOrder?) {
        
        if let order = order {
            if order.delivered == false {
                print("Order is delivered.")
                print("1 - Make the ship go away")
                print("2 - Put the earth back in the scene, and start animating")
                gameController?.deliveryIsOver()
                
                
            } else {
                print("Order NOT delivered.")
                print("Deliver it now?")
                gameController?.deliveryIsArriving()
            }
        } else {
            print("No order was passed....")
        }
    }
    
    /// Tells the scene that the order is done. Rid of the Earth, and load the Ship
    func didFinishPlacingOrder() {
        print("Order is placed.")
        gameController?.deliveryIsArriving()
    }
    
    /// Updates the Scene when a new tech is collected
    func didCollectTech(tech:TechItems, model:SCNNode?) {
        
        print("[Scene Director] Did collect tech: \(tech.shortName). Updating Scene.")
        guard let controller = gameController else { return }
        
        let moduleTechs:[TechItems] = [.module4, .module5, .module6, .module7, .module8, .module9, .module10]
        if moduleTechs.contains(tech) {
            gameController?.loadLastBuildItem()
            controller.gameOverlay.generateNews(string: "Module Built: \(tech.shortName)")
            return
        }
        
        controller.gameOverlay.generateNews(string: "New Tech Collected: \(tech.shortName)")
        if let model = model {
            switch tech {
                case .Roboarm:
                    controller.scene.rootNode.childNode(withName: "Truss", recursively: true)?.addChildNode(model)
                default: controller.scene.rootNode.addChildNode(model)
            }
        }
    }
    
    func didChangeTrussLayout() {
        gameController?.updateTrussLayout()
    }
    
    /// Updates the `PlayerCardNode` overlay. Use this when `Player` spends money, or tokens.
    func updatePlayerCard() {
        gameController?.gameOverlay.updatePlayerCard()
    }
    
}

extension GameController {
    
    
    /// Converts the position of a node in scene to the coordinates of the `GameOverlay`
    func convertSceneToOverlay(node:SCNNode) -> CGPoint {
        
        // Get position of object
        var objCenter:SCNVector3 = node.position
        
        // If has geometry, get the center. Otherwise just use the location
        if let geometry = node.geometry {
            let bbox = geometry.boundingBox
            let mx = ((bbox.max.x - bbox.min.x) / 2) + node.position.x
            let my = ((bbox.max.y - bbox.min.y) / 2) + node.position.y
            let mz = ((bbox.max.z - bbox.min.z) / 2) + node.position.z
            objCenter = SCNVector3(x: mx, y: my, z: mz)
        }
        let spriteLocation = self.sceneRenderer.projectPoint(objCenter)
//        print("Sprite Location: \(spriteLocation)")
        
#if os(macOS)
        let sprite2dPoint = CGPoint(x: spriteLocation.x, y: spriteLocation.y - 64.0)
        let p = self.gameOverlay.scene.convertPoint(fromView: sprite2dPoint)
        return p
#else
        let sprite2dPoint = CGPoint(x: Double(spriteLocation.x), y: Double(spriteLocation.y - 64.0))
        let p = self.gameOverlay.scene.convertPoint(fromView: sprite2dPoint)
        return p
#endif
        
    }
}

