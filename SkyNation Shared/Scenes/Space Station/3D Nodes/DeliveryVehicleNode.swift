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
    
    func beginExitAnimation() {
        
        print("Delivery over. Animating it out.")
        
        let move = SCNAction.move(by: SCNVector3(0, -10, -3), duration: 6.0)
        let move2 = SCNAction.move(by: SCNVector3(0, -50, -20), duration: 2.0)
        let moveSequence = SCNAction.sequence([move, move2])
        
        let rotate1 = SCNAction.wait(duration: 0.7)
        let rotate2 = SCNAction.rotateBy(x: 90.0 * (.pi/180.0), y: 0, z: 0, duration: 5.0)
        let rotateSequence = SCNAction.sequence([rotate1, rotate2])
        
        // Close Lid
        closeLid(after: 1.2)
        
        ship.runAction(SCNAction.group([moveSequence, rotateSequence])) {
            self.removeFromParentNode()
        }
        
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
    
    func closeLid(after:Double) {
        if let lid = ship.childNode(withName: "Lid", recursively: false) {
            let waiter = SCNAction.wait(duration: after)
            let close = SCNAction.rotateBy(x: -.pi, y: 0, z: 0, duration: 5)
            let sequence = SCNAction.sequence([waiter, close])
            lid.runAction(sequence)
        }
    }
    
    override init() {
        
        guard let theNode = SCNScene(named: "Art.scnassets/Vehicles/DeliveryVehicle.scn")?.rootNode.childNode(withName: "Ship", recursively: true)?.clone() else { fatalError() }
        self.ship = theNode
        
        super.init()
        
        // Post init
        self.name = "Ship"
        self.addChildNode(ship)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

