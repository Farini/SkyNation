//
//  DeliveryVehicleNode.swift
//  SkyNation
//
//  Created by Carlos Farini on 1/13/21.
//

import Foundation
import SceneKit

class DeliveryVehicleNode:SCNNode {
    
    var ship:SCNNode
    
    let enrtyPosition:SCNVector3 = SCNVector3(0.0, -50.0, -50.0)
    let mainPosition:SCNVector3 = SCNVector3(0.0, -50.0, -50.0)
    
    func setupDeliveryAnimation() {
        
    }
    
    /// Start the Particle Emitters
    func startEngines() {
        
    }
    
    /// Stop Emitters
    func killEngines() {
        let shipChildren = ship.childNodes
        for child in shipChildren {
            if let emitter = child.particleSystems {
                emitter.first?.birthRate = 0
            }
        }
        // Open Lid
        self.openLid()
    }
    
    func openLid() {
        if let lid = ship.childNode(withName: "Lid", recursively: false) {
            let open = SCNAction.rotateBy(x: .pi, y: 0, z: 0, duration: 5)
            lid.runAction(open)
        }
    }
    
    override init() {
        
        guard let theNode = SCNScene(named: "Art.scnassets/Vehicles/DeliveryVehicle.scn")?.rootNode.childNode(withName: "Ship", recursively: true)?.clone() else { fatalError() }
        self.ship = theNode
        
        super.init()
        
        // Post init
        self.name = "Ship"
        self.addChildNode(ship)
        
        //        if let ship = SCNScene(named: "Art.scnassets/Vehicles/DeliveryVehicle.scn")?.rootNode.childNode(withName: "Ship", recursively: true)?.clone() {
        //
        //            ship.name = "Ship"
        //            ship.position.z = -50
        //            ship.position.y = -50 // -25
        //            ship.position.x = 0
        //            ship.eulerAngles = SCNVector3(x:90.0 * (.pi/180.0), y:0, z:0)
        //
        ////            scene.rootNode.addChildNode(ship)
        //
        //            // Move
        //            let move = SCNAction.move(by: SCNVector3(0, 32, 50), duration: 12.0)
        //            move.timingMode = .easeInEaseOut
        //
        //            // Kill Engines
        //            let killWaiter = SCNAction.wait(duration: 8)
        //            let killAction = SCNAction.run { shipNode in
        //                print("Kill Waiter")
        //                for child in shipNode.childNodes {
        //                    print("Child \(child.description)")
        //                    child.particleSystems?.first?.birthRate = 0
        //                }
        //            }
        //            let killSequence = SCNAction.sequence([killWaiter, killAction])
        //
        //            let rotate = SCNAction.rotateBy(x: -90.0 * (.pi/180.0), y: 0, z: 0, duration: 5.0)
        //            let group = SCNAction.group([move, rotate, killSequence])
        //
        //            ship.runAction(group, completionHandler: {
        //                print("f")
        //
        //            })
        //        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
