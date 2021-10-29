//
//  LaunchSceneController.swift
//  SkyNation
//
//  Created by Carlos Farini on 10/28/21.
//

import Foundation
import SceneKit

/** Controls the **Space Vehicle Launching Scene** */
class LaunchSceneController:ObservableObject {
    
    @Published var scene:SCNScene
    @Published var vehicleNode:SpaceVehicleNode
    @Published var vehicle:SpaceVehicle
    
    init(vehicle:SpaceVehicle) {
        
        self.vehicle = vehicle
        
        // Load Scene with vehicle
        let scene = SCNScene(named: "Art.scnassets/Vehicles/SpaceVehicle3.scn")!
        for childnode in scene.rootNode.childNodes {
            if !["Camera", "Light"].contains(childnode.name ?? "") {
                childnode.isHidden = true
            }
        }
        
        self.scene = scene
        
        let node = SpaceVehicleNode(vehicle: vehicle, parentScene:scene)
        self.vehicleNode = node
        
        node.move()
        
        if let camera = scene.rootNode.childNode(withName: "Camera", recursively: false) {
            
            // Look At
            let constraint = SCNLookAtConstraint(target:vehicleNode)
            constraint.isGimbalLockEnabled = true
            constraint.influenceFactor = 0.1
            
            // Follow
            let follow = SCNDistanceConstraint(target: vehicleNode)
            follow.minimumDistance = 20
            follow.maximumDistance = 50
            
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 3.0
            camera.constraints = [constraint, follow]
            SCNTransaction.commit()
            
//            let waiter = SCNAction.wait(duration: 2.5)
//            let move = SCNAction.move(by: SCNVector3(100, 0, 0), duration: 10)
//
//            let group = SCNAction.sequence([waiter, move])
//            camera.runAction(group) {
//                print("Finished camera move")
//                // self.runSmallParticles()
//            }
        }
        
//        self.runSmallParticles()
        
        
    }
    
   
}
