//
//  GameCamera.swift
//  SkyNation
//
//  Created by Carlos Farini on 2/10/21.
//

import Foundation
import SceneKit
//import SpriteKit

class GameCamera:SCNNode {
    
    var camNode:SCNNode
    var points:[SCNVector3] = []
    
    func smoothLook(at target:SCNNode) {
        // --- SMOOTH LOOK AT TARGET
        // https://stackoverflow.com/questions/47973953/animating-scnconstraint-lookat-for-scnnode-in-scenekit-game-to-make-the-transi
        // influenceFactor and animationDuration work somehow together
//        let centralNode = SCNNode()
//        centralNode.position = SCNVector3(x: 0, y: -5, z: 0)
        
        // If the constraint’s influence factor is 1.0, SceneKit adjusts the spotlight node
        // to point directly at the game character each time it renders a frame.
        // If you reduce the influence factor to 0.5, each time SceneKit renders a frame
        // it moves the spotlight halfway from its current orientation to the target orientation.
        
        let constraint = SCNLookAtConstraint(target:target)
        constraint.isGimbalLockEnabled = true
        constraint.influenceFactor = 0.1
        
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 3.0
        camNode.constraints = [constraint]
        SCNTransaction.commit()
    }
    
    func panCamera(to z:Double, x:Double? = nil) {
        
        if let minZ = parent?.boundingBox.min.z, let maxZ = parent?.boundingBox.max.z {
            
            let lenghtZ = maxZ - minZ
            
            let camZ = self.position.z - minZ
            
            let partial = lenghtZ / 3
            let partial2 = partial * 2
            
            position.z = CGFloat(z)
            
            let targetNode:SCNNode = SCNNode()
            
            if camZ < partial + minZ {
                // Look at last
                print("Should look @ 3")
                targetNode.position.z = -50
            } else if camZ < partial2 + minZ {
                // Look at middle
                print("Should look @ 2")
                targetNode.position.z = -25
            } else {
                // Look at first
                print("Should look @ 1")
                targetNode.position.z = 0
            }
            
            smoothLook(at: targetNode)
        }
        
    }
    
    override init() {
        
        self.camNode = SCNNode()
        
        let camera = SCNCamera()
        camera.usesOrthographicProjection = false
        camera.focalLength = 150
        camera.fieldOfView = 9.148
        camera.sensorHeight = 24
        camera.zNear = 0.1
        camera.zFar = 500
        
        let cameraNode = SCNNode()
        cameraNode.name = "CameraHandle"
        cameraNode.position = SCNVector3(x: 105, y: 75, z: 135)
        cameraNode.camera = camera
        self.camNode = cameraNode
        
        super.init()
        
        self.addChildNode(cameraNode)
        
        self.camera = camera
        self.name = "Camera"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
