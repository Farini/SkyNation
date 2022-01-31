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
    
    // Info
    @Published var infoString:String = ""
    
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
        
        // Get Vehicle node
        let node = SpaceVehicleNode(vehicle: vehicle, parentScene:scene)
        self.vehicleNode = node
        node.move()
        
        // Camera
        if let camera = scene.rootNode.childNode(withName: "Camera", recursively: false) {
            
            // Look At
            let constraint = SCNLookAtConstraint(target:vehicleNode)
            constraint.isGimbalLockEnabled = true
            constraint.influenceFactor = 0.1
            
            // Follow
            let follow = SCNDistanceConstraint(target: vehicleNode)
            follow.minimumDistance = 5
            follow.maximumDistance = 45
            
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 3.0
            camera.constraints = [constraint, follow]
            SCNTransaction.commit()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
                self.longShot(camNode: camera)
            }
            
        }
        
        // Add the Earth
        let earth = EarthNode()
        earth.position = scene.rootNode.childNode(withName: "Earth", recursively: true)?.position ?? SCNVector3(x: 20, y: 0, z: -50) //SCNVector3(x: 10, y: 0, z: -75)
        scene.rootNode.addChildNode(earth)
        
        let scaleAction = SCNAction.scale(to: 25.0, duration: 1.2)
        if let earthling = earth.childNode(withName: "Earth", recursively: false) {
            earthling.runAction(scaleAction)
            
#if os(macOS)
            earth.eulerAngles = SCNVector3(x: GameLogic.radiansFrom(-22.5), y: 0, z: 0)
#elseif os(iOS)
            earth.eulerAngles = SCNVector3(x: Float(GameLogic.radiansFrom(-22.5)), y: 0, z: 0)
#endif
        }
        

//        earth.runAction(scaleAction)
    }
    
    func dropThruster() {
        
        self.infoString = "Shutting off engine"
        
        let thruster = vehicleNode.rocketBooster
        
        let vRotate = SCNAction.rotate(by: GameLogic.radiansFrom(183), around:  SCNVector3(x: 1, y: 0, z: 0), duration: 5.5)
        let fullRotate = SCNAction.repeatForever(vRotate)
        fullRotate.timingMode = .easeIn
        
        let boosterMove = SCNAction.move(by: SCNVector3(x: -8, y: 0, z: 0), duration: 3.0)
        boosterMove.timingMode = .easeOut
        
        // Twist the booster, adieu
        let boosterTwist = SCNAction.rotateBy(x: GameLogic.radiansFrom(3.0), y: GameLogic.radiansFrom(12.0), z: GameLogic.radiansFrom(45.0), duration: 3.0)
        boosterTwist.timingMode = .easeIn
        let boosterGroup = SCNAction.group([boosterMove, boosterTwist])
        let boosterSequel = SCNAction.sequence([boosterGroup, boosterGroup])
        let waiter = SCNAction.wait(duration: 5.2)
        
        // Set the camera constraints back to vehicle
        self.constraintCameraTo(self.vehicleNode, zoom: 35, minDistance: 8, maxDistance: 25, time: 5.0)
        
        self.vehicleNode.runAction(fullRotate)
        
        thruster.runAction(waiter) {
            self.infoString = "Dropping thruster"
            
            // move the thruster
            self.vehicleNode.shutOffMiniEmitters()
            thruster.runAction(boosterSequel) {
                thruster.removeFromParentNode()
                self.infoString = "Beginning Journey"
            }
        }
    }
    
    func secondLongShot(camNode:SCNNode) {
        
        // See the Booster closer
        let theMove = driveCamera(node: camNode)
        self.infoString = "Approaching the vehicle."
        
        let oldFocus = camNode.camera?.focalLength ?? 35.0
        let tempFocus = 55
        
        camNode.runAction(theMove) {
            
            // Camera
            self.constraintCameraTo(self.vehicleNode.rocketBooster, zoom: tempFocus, minDistance: 5, maxDistance: 15, time: 3.0)
            
            // Set the focal length back to the original
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.1) {
                
                self.infoString = "Camera back"
                
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 1.5
                camNode.camera?.focalLength = oldFocus
                SCNTransaction.commit()
                
                self.dropThruster()
            }
        }
    }
    
    /// The long movement forward of the camera
    func longShot(camNode:SCNNode) {
        
        self.infoString = "Approaching the vehicle."
        
        // Move the camera forward
        let move = driveCamera(node: camNode) //SCNAction.move(by: SCNVector3(x: 25, y: 2, z: 30), duration: 5.5)
        camNode.runAction(move) {
            
            // Camera constraint
            self.constraintCameraTo(self.vehicleNode.rocketBooster, zoom: 35, minDistance: 15, maxDistance: 25, time: 2.5)
            self.infoString = "Camera finished moving"
            
            // rotate vehicle in x axis
            let rot = SCNAction.rotate(by: GameLogic.radiansFrom(65), around: SCNVector3(x: 1, y: 0, z: 0), duration: 5.5)
            self.vehicleNode.runAction(rot) {
                // Finished rotating vehicle.
                self.infoString = "Vehicle Finished Rotating in position."
                self.secondLongShot(camNode: camNode)
            }
        }
    }
    
    // MARK: - Frequently Used
    
    func driveCamera(node:SCNNode) -> SCNAction {
        
        // Check the distance to vehicle
        let camPosition = node.position
        let shipPosition = vehicleNode.position
        let distance = shipPosition.distance(to: camPosition)
        let dstring:String = String(format: "Distance: %.2f", distance)
        self.infoString = dstring
        
        // Pass through that point
        let fPosX = shipPosition.x * 1.75
        let fPosZ = 10.0
        let fPosY = 8.0
        
        // let theMove = SCNAction.move(to: SCNVector3(x: fPosX, y: fPosY, z: fPosZ), duration: 5.5)
#if os(macOS)
        let theMove = SCNAction.move(to: SCNVector3(x: fPosX, y: fPosY, z: fPosZ), duration: 5.5)
#elseif os(iOS)
        let theMove = SCNAction.move(to: SCNVector3(x: Float(fPosX), y: Float(fPosY), z: Float(fPosZ)), duration: 5.5)
#endif
        return theMove
    }
    
    func constraintCameraTo(_ node:SCNNode, zoom:Int, minDistance:Int, maxDistance:Int, time:Double) {
        
        // Camera
        guard let cameraNode:SCNNode = self.scene.rootNode.childNode(withName: "Camera", recursively: false) else {
            print("Couldn't find camera")
            return
        }
        
        // Look At
        let constraint = SCNLookAtConstraint(target:node)
        constraint.isGimbalLockEnabled = true
        constraint.influenceFactor = 0.1
        
        // Follow
        let follow = SCNDistanceConstraint(target: node)
        follow.minimumDistance = CGFloat(minDistance)
        follow.maximumDistance = CGFloat(maxDistance)
        
        SCNTransaction.begin()
        SCNTransaction.animationDuration = time
        cameraNode.constraints = [constraint, follow]
        cameraNode.camera?.focalLength = CGFloat(zoom)
        SCNTransaction.commit()
        
    }
}


extension SCNVector3 {
    func distance(to vector: SCNVector3) -> Float {
        return simd_distance(simd_float3(self), simd_float3(vector))
    }
}
