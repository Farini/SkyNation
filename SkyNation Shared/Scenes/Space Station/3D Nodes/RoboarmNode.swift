//
//  RoboarmNode.swift
//  SkyNation
//
//  Created by Carlos Farini on 1/13/21.
//

import Foundation
import SceneKit

class RoboArmNode:SCNNode {
    
    var robot:SCNNode
    var arm:SCNNode
    var forearm:SCNNode
    var thirdArm:SCNNode
    var wrist:SCNNode
    
    func animate() {
        
        // For Debugging, print angles
        if GameSettings.shared.debugScene {
            print("Animating Roboarm")
            self.debugAnime()
        }
        
        // Arm
        let waiter = SCNAction.wait(duration: 3)
        let rotate = SCNAction.rotateBy(x: CGFloat(GameLogic.radiansFrom(-20)), y: 0, z: 0, duration: 3)
        let armSequence = SCNAction.sequence([waiter, rotate])
        
        arm.runAction(armSequence) {
            if GameSettings.shared.debugScene {
                print("RoboArm Finished")
                self.debugAnime()
            }
        }
        
        // Forearm
        
        // Third Arm
        let foreArmRotate = SCNAction.rotateBy(x: CGFloat(GameLogic.radiansFrom(-15)), y: 0, z: 0, duration: 3)
        let foreWaiter = SCNAction.wait(duration: 6)
        let forearmSequence = SCNAction.sequence([foreWaiter, foreArmRotate])
        thirdArm.runAction(forearmSequence) {
            
//            self.debugAnime()
            if GameSettings.shared.debugScene {
                print("Forearm Finished Animating")
                self.debugAnime()
            }
        }
        
        // Wrist
        
        // --- SMOOTH LOOK AT TARGET
        // https://stackoverflow.com/questions/47973953/animating-scnconstraint-lookat-for-scnnode-in-scenekit-game-to-make-the-transi
        // influenceFactor and animationDuration work somehow together
        let centralNode = SCNNode()
        centralNode.position = wrist.worldPosition
        centralNode.position.x = -100
        self.parent?.addChildNode(centralNode)
        
        let constraint = SCNLookAtConstraint(target:centralNode) //SCNLookAtConstraint(target: scene.rootNode)
        constraint.isGimbalLockEnabled = true
        constraint.influenceFactor = 0.1
        
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 3.0
        self.wrist.constraints = [constraint]
        SCNTransaction.commit()
        
        // Great, now you can start the scene in the front view, go to camera 2 and the constraint will still be there.
        // we dont need a parent node for the camera anymore
        // just move it to any position in world cordinates, recalculate the constraints (depending on z axis, or camera number)
        
        // end smooth look
        
    }
    
    // Prints out the conditions
    func debugAnime() {
        print("\n Arm Animation....")
        print("Bot Angles   : \(robot.eulerAngles)")
        print("Arm Angles   : \(arm.eulerAngles)")
        print("Forearm ang  : \(forearm.eulerAngles)")
        print("Wrist angle  : \(forearm.eulerAngles)")
    }
    
    override init() {
        
        guard let roboNode = SCNScene(named: "Art.scnassets/SpaceStation/Accessories/Roboarm.scn")?.rootNode.childNode(withName: "Roboarm", recursively: true)?.clone() else { fatalError() }
        self.robot = roboNode
        let theArm = roboNode.childNodes.first!
        self.arm = theArm
        let theForearm = theArm.childNodes.first!
        self.forearm = theForearm
        let third = theForearm.childNodes.first!
        self.thirdArm = third
        let theWrist = third.childNodes.first!
        self.wrist = theWrist
        super.init()
        
        self.addChildNode(self.robot)
        self.isPaused = false
        animate()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Timing function that has a "bounce in" effect
    func easeOutElastic(_ t: Float) -> Float {
        let p: Float = 0.3
        let sinop = sin((t - p / 4.0) * (2.0 * Float.pi) / p)
        let result = pow(2.0, -10.0 * t) * sinop + 1.0
        return result
    }
    
    
}
