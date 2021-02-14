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
        guard let _ = LocalDatabase.shared.station else { fatalError() }
        
        // Update Truss
//        controller.updateTrussLayout()
        
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
//            // 3 seconds in
//            self.gameController?.debugScene()
//        }
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
        print("1 - Remove the earth")
        print("2 - Bring the ship in the scene, and start animating")
        gameController?.deliveryIsArriving()
    }
    
    /// Updates the Scene when a new tech is collected
    func didCollectTech(tech:TechItems, model:SCNNode?) {
        
        print("Did collect tech: \(tech.shortName). Updating Scene.")
        guard let controller = gameController else { return }
        
        let moduleTechs:[TechItems] = [.module4, .module5, .module6, .module7, .module8, .module9, .module10]
        if moduleTechs.contains(tech) {
            gameController?.loadLastBuildItem()
            controller.stationOverlay.generateNews(string: "Module Built: \(tech.shortName)")
            return
        }
        
        
        controller.stationOverlay.generateNews(string: "New Tech Collected: \(tech.shortName)")
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
    
}

class MarsBuilder {
    
    init() {
        print("Initting Mars Director")
    }
    // Load Scene
    // Art.scnassets/Mars/MarsTerrain5 copy.scn
    func loadScene() -> SCNScene? {
        let nextScene = SCNScene(named: "Art.scnassets/Mars/MarsTerrain5 copy.scn")
        return nextScene
    }
}
