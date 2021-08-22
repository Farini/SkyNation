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
    
    var povs:[GamePOV] = []
    var currentPOV:GamePOV?
    
    /// Animates the camera to look at a node
    func smoothLook(at target:SCNNode) {
        // --- SMOOTH LOOK AT TARGET
        // https://stackoverflow.com/questions/47973953/animating-scnconstraint-lookat-for-scnnode-in-scenekit-game-to-make-the-transi
        // influenceFactor and animationDuration work somehow together
        
        // If the constraint’s influence factor is 1.0, SceneKit adjusts the spotlight node
        // to point directly at the game character each time it renders a frame.
        // If you reduce the influence factor to 0.5, each time SceneKit renders a frame
        // it moves the spotlight halfway from its current orientation to the target orientation.
        
        print(" 00 Smooth Looking - \(camNode.eulerAngles)")
        
        let constraint = SCNLookAtConstraint(target:target)
        constraint.isGimbalLockEnabled = true
        constraint.influenceFactor = 0.1
        
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 1.5
        camNode.constraints = [constraint]
        SCNTransaction.commit()
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            print(" 11 Smooth Looking - \(self.camNode.eulerAngles)")
        }
    }
    
    /// Makes the camera look at a node right away
    func simpleLookAt(targetPoint:SCNVector3) {
        self.camNode.look(at: targetPoint)
    }
    
    func panCamera(to z:Double, x:Double? = nil) {
        
        if let minZ = parent?.boundingBox.min.z, let maxZ = parent?.boundingBox.max.z {
            
            let lenghtZ = maxZ - minZ
            
            
            
            let camZ = self.position.z - minZ
            
            let partial = lenghtZ / 3
            let partial2 = partial * 2
            
            #if os(iOS)
//            position.z = Float(CGFloat(z))
            let move = SCNAction.move(to: SCNVector3(position.x, position.y, Float(CGFloat(z))), duration: 1)
            #else
            // position.z = CGFloat(z)
            let move = SCNAction.move(to: SCNVector3(position.x, position.y, CGFloat(z)), duration: 1)
            #endif
            self.runAction(move)
            
            
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
    
    /// Moves the camera to the next Point Of View
    func moveToNextPOV() {
        
        // Clear previous constraints & angles
        self.camNode.constraints = []
        self.camNode.eulerAngles = SCNVector3()
        self.eulerAngles = SCNVector3()
        
        // Get destination
        var nextPOV:GamePOV!
        if let pov = currentPOV {
            if pov == povs.last {
                nextPOV = povs.first!
            } else {
                let nextIndex = povs.firstIndex(where: { $0.id == pov.id })! + 1
                nextPOV = povs[nextIndex]
            }
        } else {
            nextPOV = povs.first
        }
        self.currentPOV = nextPOV
        
        // Move Camera
        let move = SCNAction.move(to: nextPOV.position, duration: 1.2)
        self.camNode.runAction(move) {
            
            if let targetNode = nextPOV.targetNode {
                self.smoothLook(at: targetNode)
            } else {
                let newNode = SCNNode()
                newNode.position = nextPOV.targetPosition ?? SCNVector3()
                self.smoothLook(at: newNode)
//                self.simpleLookAt(targetPoint: nextPOV.targetPosition ?? SCNVector3())
            }
            
            self.camNode.camera?.fieldOfView = CGFloat(nextPOV.fieldOfView)
        }
    }
    
    /// Moves the camera to the previous Point of View
    func moveToPreviousPOV() {
        
        // Clear previous constraints & angles
        self.camNode.constraints = []
        self.camNode.eulerAngles = SCNVector3()
        self.eulerAngles = SCNVector3()
        
        
        // Get destination
        var previousPOV:GamePOV!
        if let pov = currentPOV {
            if pov == povs.first {
                previousPOV = povs.last!
            } else {
                let prevIndex = povs.firstIndex(where: { $0.id == pov.id })! - 1
                previousPOV = povs[prevIndex]
            }
        } else {
            previousPOV = povs.last
        }
        self.currentPOV = previousPOV
        
        // Move Camera
        let move = SCNAction.move(to: previousPOV.position, duration: 1.2)
        self.camNode.runAction(move) {
            
            // Point Camera
            if let targetNode = previousPOV.targetNode {
                self.smoothLook(at: targetNode)
            } else {
                let newNode = SCNNode()
                newNode.position = previousPOV.targetPosition ?? SCNVector3()
                self.smoothLook(at: newNode)
//                self.simpleLookAt(targetPoint: previousPOV.targetPosition ?? SCNVector3())
            }
            // Field of view
            self.camNode.camera?.fieldOfView = CGFloat(previousPOV.fieldOfView)
        }
    }
    
    // MARK: - Init & Cycle

    init(pov:GamePOV, array:[GamePOV]) {
        
        // Position, Constraints & Setup
        self.currentPOV = pov
        self.povs = array
        
        // Camera
        let camera = SCNCamera()
        camera.usesOrthographicProjection = false
        camera.focalLength = 100
        camera.fieldOfView =  CGFloat(pov.fieldOfView)
        camera.sensorHeight = 24
        camera.zNear = 0.1
        camera.zFar = 500
        
        // Camera Node (Handle)
        let cameraNode = SCNNode()
        cameraNode.name = "CameraHandle"
        cameraNode.position = pov.position
        cameraNode.eulerAngles = SCNVector3.init(x: 0, y: 0, z: 0)
        cameraNode.camera = camera
        self.camNode = cameraNode
        
        super.init()
        
        self.addChildNode(cameraNode)
        self.name = "Camera"
        
        self.camNode.eulerAngles = SCNVector3()
        self.eulerAngles = SCNVector3()
        
        print("\n\n Camera Initialized")
        
        let move = SCNAction.move(to: pov.position, duration: 1.2)
        self.camNode.runAction(move) {
            if let targetNode = pov.targetNode {
                self.smoothLook(at: targetNode)
            } else {
                let newNode = SCNNode()
                newNode.position = pov.targetPosition ?? SCNVector3()
                self.smoothLook(at: newNode)
            }
                
            self.camNode.camera?.fieldOfView = CGFloat(pov.fieldOfView)
                
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

/**
    Points of Interesting View - POV
    
        How To Use:
    
 0. Remove camera constraints
 1. Move the camera to position
 2. Add constraint @LookAt
 3. yRange rotates the camera
 4. zoomRange changes the camera zoom (size?)
 
 YRANGE:
 The amount of degrees it can rotate
 
 ZOOM Range:
 maximumFOV:(25) Determines the farthest point you can zoom in to
 minimumFOV:(90) Determines the farthest point you can zoom out to
 
 node!.camera!.fieldOfView = node!.camera!.fieldOfView - CGFloat(scale) */
struct GamePOV:Identifiable, Equatable {
    
    var id:UUID = UUID()
    
    /// Position of the camera
    var position:SCNVector3
    
    /// The node the camera is looking at - also the anchor at wich the camera revolves around with yRange.
    var targetNode:SCNNode?
    
    var targetPosition:SCNVector3?
    
    /// The name to Display (select) - if nil, get the targetNode name, or vector
    var name:String
    
    /// Camera rotation - range of which the camera can tilt, in the (y) axis
    var yRange:ClosedRange<Double> = GameLogic.radiansFrom(0)...GameLogic.radiansFrom(120)  // Default 120 degrees?
    
    /// Camera zoom - The angle that the camera can see
    var zoomRange:ClosedRange<Double>?                                        // Default -> 60 degrees. (from 15.0 to 80.0)
    // "The default field of view is 54 degrees, corresponding to a focal length of 50mm and a vertical sensor aperture of 24mm."
    
    /// The current `Field of view`
    var fieldOfView:Double = 54.0
    
    /// Initialize for a target node
    init(position:SCNVector3, target:SCNNode, name:String, yRange:ClosedRange<Double>?, zRange:ClosedRange<Double>?, zoom:Double?) {
        self.position = position
        self.targetNode = target
        self.name = name
        if let yr = yRange { self.yRange = yr }
        if let zr = zRange { self.zoomRange = zr }
        if let zoom = zoom { self.fieldOfView = zoom }
    }
    
    /// Initialize for a target position
    init(position:SCNVector3, targetPos:SCNVector3, name:String, yRange:ClosedRange<Double>?, zRange:ClosedRange<Double>?, zoom:Double?) {
        
        self.position = position
        self.targetPosition = targetPos
        self.name = name
        if let yr = yRange { self.yRange = yr }
        if let zr = zRange { self.zoomRange = zr }
        if let zoom = zoom { self.fieldOfView = zoom }
    }
    
    static func == (lhs: GamePOV, rhs: GamePOV) -> Bool {
        return lhs.id == rhs.id
    }
}
