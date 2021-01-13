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
        print("Robot Animation")
        self.debugAnime()
        
        // Arm
        let waiter = SCNAction.wait(duration: 3)
        let rotate = SCNAction.rotateBy(x: CGFloat(GameLogic.radiansFrom(-20)), y: 0, z: 0, duration: 3)
        let armSequence = SCNAction.sequence([waiter, rotate])
        arm.runAction(armSequence) {
            print("Arm Finished")
            self.debugAnime()
        }
        
        // Forearm
        
        // Third Arm
        let foreArmRotate = SCNAction.rotateBy(x: CGFloat(GameLogic.radiansFrom(-15)), y: 0, z: 0, duration: 3)
        let foreWaiter = SCNAction.wait(duration: 6)
        let forearmSequence = SCNAction.sequence([foreWaiter, foreArmRotate])
        thirdArm.runAction(forearmSequence) {
            print("Forearm Finished")
            self.debugAnime()
        }
        
        // Wrist
        let wristRotate = SCNAction.rotateTo(x: -1.5707963705062866, y: 0, z: 0, duration: 3)
        
        // Use a custom timing function
        wristRotate.timingFunction = { (p: Float) in
            return self.easeOutElastic(p)
        }
        
        let wristWaiter = SCNAction.wait(duration: 9)
        let wristSequence = SCNAction.sequence([wristWaiter, wristRotate])
        wrist.runAction(wristSequence) {
            print("Wrist Finished")
            self.debugAnime()
            self.wrist.look(at: SCNVector3(-100, 0, 0))
        }
        
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
