//
//  EDLSceneController.swift
//  SkyNation
//
//  Created by Carlos Farini on 10/28/21.
//

import Foundation
import SwiftUI
import SceneKit


/**
 The Controller for the EDL Scene
 */
class EDLSceneController:ObservableObject {
    
    @Published var scene:SCNScene
    @Published var vehicle:SpaceVehicle
    @Published var actNames:[String] = []
    
    private var burnMaterial:SCNMaterial
    private var emitter:SCNParticleSystem
    
    private var camera:SCNCamera
    private var cameraNode:SCNNode
    
    /// Camera positions stored in array
    private var otherCams:[SCNNode]
    private var floor:SCNNode
    private var mars:SCNNode
    
    // New
    // edlModule
    var edlModule:SCNNode
    
    // shootBase (whole shoot)
    var shootBase:SCNNode
    
    // shock
    var bigShock:SCNNode
    var miniShock:SCNNode
    
    var engines:[SCNNode] = []
    
    // MARK: - Animation v 1.3
    
    /*
     Emitters:
     - Shock Emitter (impact)
     - Engine Emitters
     - Landpad
     */
    
    /*
     Other subdivided actions
     - Wobbles
     - shock emitter [rotation, intensity]
     - try more transparent shock emitter
     - camera changes
     - move vehicle 33 in X
     - camera-002 to show parashooting (shooting)
     - engine emitters
     
     */
    
    // Shock Nodes
    /*
     - Shock node
     - Correct node scale
     - material rotation
     - material emission intensity
     
     - transluscent emitter
     
     - control emitter birth rate
     -
     */
    
    /*
     Before start burning, needs to show particle emitter
     Animate the burn stopping
     Dim down particle Emitter
     
     Approach with camera and throw something in that direction
     
     Attempt # 2
     
     - Contact
     * unhide shock
     * start particle emitter
     * start burning color
     - burning
     * animate shock (scale, rotate, etc.)
     * unwind particle emitter
     * reverse burning color
     * dim shock until 0
     - deploy shoot
     * throw object blob
     * scale parashoot
     * rotate parashoot
     * rotate ship
     * slow down
     - drop
     * unhide engines
     * run particle emitters (thrusters)
     * slow down the drop
     - land
     
     
     
     */
    
    init(vehicle:SpaceVehicle) {
        
        self.vehicle = vehicle
        
        let scene = SCNScene(named: "Art.scnassets/Vehicles/EDL.scn")!
        
        self.scene = scene
        
        // Ground
        guard let floor = scene.rootNode.childNode(withName: "floor", recursively: false),
              let mars = scene.rootNode.childNode(withName: "Mars", recursively: false) else {
                  fatalError("no floor")
              }
        
        self.floor = floor
        self.mars = mars
        
        // Module
        guard let module = scene.rootNode.childNode(withName: "EDLModule", recursively: false),
              let mainGeometry = module.geometry,
              let burnMaterial = mainGeometry.materials.first(where: { $0.name == "Burn"})
        else {
            fatalError("no Module")
        }
        
        self.edlModule = module
        self.burnMaterial = burnMaterial
        
        // Hide Engines
        var allEngines:[SCNNode] = []
        for eng in module.childNodes {
            let nodeName = eng.name ?? "na"
            if nodeName.contains("Engine") {
                eng.isHidden = true
                allEngines.append(eng)
            }else{
                if nodeName == "ShootBase" {
                    eng.isHidden = true
                }
            }
        }
        
        // Camera
        guard let cameraNode:SCNNode = scene.rootNode.childNode(withName: "Camera", recursively: false),
              let camera = cameraNode.camera,
              let cam2 = scene.rootNode.childNode(withName: "Campos", recursively: false) else {
                  fatalError()
              }
        self.cameraNode = cameraNode
        self.camera = camera
        self.otherCams = [cam2]
        
        // Load Secondary Nodes
        guard let shockBig = module.childNode(withName: "Shock", recursively: false),
              let shockSmall = module.childNode(withName: "Shock-Mini", recursively: false),
              let particles:SCNParticleSystem = shockBig.particleSystems?.first,
              let shoot = module.childNode(withName: "ShootBase", recursively: false) else {
                  fatalError("No Shock")
              }
        shockBig.isHidden = true
        shoot.isHidden = true
        
        self.emitter = particles
        self.bigShock = shockBig
        self.miniShock = shockSmall
        self.shootBase = shoot
        
        // Post Init
        self.engines = allEngines
        self.burnMaterial.emission.intensity = 0
        self.emitter.birthRate = 0
        
        self.setupCamera()
        
    }
    
    func setupCamera() {
        // Camera moves
        
        // Look At
        let constraint = SCNLookAtConstraint(target:edlModule)
        constraint.isGimbalLockEnabled = true
        constraint.influenceFactor = 0.1
        
        // Follow
        let follow = SCNDistanceConstraint(target: edlModule)
        follow.minimumDistance = 5
        follow.maximumDistance = 50
        
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 2.0
        cameraNode.constraints = [constraint, follow]
        SCNTransaction.commit()
        
        let waiter = SCNAction.wait(duration: 5)
        let move = SCNAction.move(by: SCNVector3(0, -5, 0), duration: 3)
        let group = SCNAction.sequence([waiter, move])
        cameraNode.runAction(group) {
            self.actNames.removeAll(where: { $0 == "Camera Move" })
            print("Finished camera move")
            self.atmoImpactAnimation()
            
        }
        
        camera.focalLength = 30
        
        // Rotate Mars
        let marsRot = SCNAction.rotate(by: GameLogic.radiansFrom(10), around: SCNVector3(0, 0, 1), duration: 60.0)
        self.mars.runAction(marsRot)
        
        // Rotate Ship
        let shipRotation = SCNAction.rotate(by: GameLogic.radiansFrom(-12), around: SCNVector3(0, 0, 1), duration: 2.0)
        edlModule.runAction(shipRotation)
    }
    
    // Easy move of camera
    func cameraSmoothLookAt(node:SCNNode) {
        
        // Look At
        let constraint = SCNLookAtConstraint(target:node)
        constraint.isGimbalLockEnabled = true
        constraint.influenceFactor = 0.1
        
        // Follow (always follow EDL Module)
        let follow = SCNDistanceConstraint(target: edlModule)
        follow.minimumDistance = 15
        follow.maximumDistance = 50
        
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 2.0
        cameraNode.constraints = [constraint, follow]
        SCNTransaction.commit()
    }
    
    // MARK: - Impact + Friction
    
    func atmoImpactAnimation() {
        
        self.shockNodeHeatingAnimation()
        
        self.emitter.birthRate = 15
        
        // Increase Emitter power, move module
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 5.0
        SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: .easeIn)
        self.bigShock.geometry?.materials.first?.emission.intensity = 2.5
        self.emitter.birthRate = 500
        self.burnMaterial.emission.intensity = 4.0
        self.edlModule.position.x = -15
        SCNTransaction.commit()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.2) {
            self.impactFadeAnimation()
        }
    }
    
    func shockNodeHeatingAnimation() {
        
        // Scales of the Shock Node
        let miniScale = SCNVector3(0.45, 0.2, 0.45)
        // let bigScale = SCNVector3(x: 1, y: 1, z: 1)
        
        self.bigShock.scale = miniScale
        self.bigShock.isHidden = false
        self.bigShock.geometry?.materials.first?.emission.intensity = 0.1
        
        let shockScale = SCNAction.scale(to: 1, duration: 5.50)
        shockScale.timingMode = .easeInEaseOut
        
        self.bigShock.runAction(shockScale) {
            let shrink = SCNAction.scale(by: 0.4, duration: 4.5)
            self.bigShock.runAction(shrink)
        }
        
    }
    
    func impactFadeAnimation() {
        
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 5.0
        self.bigShock.geometry?.materials.first?.emission.intensity = 0.0
        self.bigShock.isHidden = true
        self.emitter.birthRate = 0
        self.burnMaterial.emission.intensity = 0.0
        SCNTransaction.commit()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) {
            self.launchShoot()
        }
    }
    
    // MARK: - Parashoot
    
    func launchShoot() {
        
        // Get Shoot's geometries
        guard let cord = shootBase.childNode(withName: "ShootCord", recursively: false),
              let shoot = shootBase.childNode(withName: "Shoot", recursively: false) else {
                  fatalError("no cord, no shoot")
              }
        shoot.isHidden = true
        cord.isHidden = false
        
        // Change Camera
        guard let nextCam = otherCams.first!.childNode(withName: "Cam2", recursively: false) else {
            fatalError("no such camera")
        }
        self.cameraNode.position = nextCam.position
        self.cameraNode.eulerAngles = nextCam.eulerAngles
        self.cameraSmoothLookAt(node: shoot)
        // Adjust focus
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 1.0
        camera.focalLength = 20
        SCNTransaction.commit()
        
        // Shoot Particle System
        self.shootBase.particleSystems?.first?.birthRate = 1
        self.shootBase.isHidden = false
        // Shoot expansion animation
        let shrinkCord = SCNAction.scale(to: 0.2, duration: 0.1)
        let expandCord = SCNAction.scale(to: 4.0, duration: 1.2)
        let throwingSequel = SCNAction.sequence([shrinkCord, expandCord])
        
        let expandShoot = SCNAction.scale(to: 4.0, duration: 0.85)
        
        
        shoot.runAction(shrinkCord)
        cord.runAction(throwingSequel) {
            self.shootBase.particleSystems?.first?.birthRate = 0
            shoot.isHidden = false
            shoot.runAction(expandShoot) {
                self.glideShoot()
            }
        }
    }
    
    func glideShoot() {
        
        // Point camera back at the Module
        self.cameraSmoothLookAt(node: edlModule)
        
        // Rotating parashoot
        let waiter = SCNAction.wait(duration: 1.9)
        let shootLift = SCNAction.rotate(by: GameLogic.radiansFrom(-12), around: SCNVector3(0.1, 0, 1), duration: 0.6)
        let shootLift2 = SCNAction.rotate(by: GameLogic.radiansFrom(-8), around: SCNVector3(0.1, 0, 1), duration: 0.8)
        // Another rotate
        let shootWobble = SCNAction.rotate(by: GameLogic.radiansFrom(10), around: SCNVector3(0, 1, 0), duration: 1.1)
        let shootUnwobble = SCNAction.rotate(by: GameLogic.radiansFrom(-10), around: SCNVector3(0, 1, 0), duration: 1.5)
        // Parashoot actions
        let liftSequence = SCNAction.sequence([waiter, shootLift, shootLift2])
        let wobbleSequence = SCNAction.sequence([shootWobble, shootUnwobble])
        let shootGroup = SCNAction.group([liftSequence, wobbleSequence])
        
        // Moving EDL
        let edlMove = SCNAction.move(to: SCNVector3(0, self.edlModule.position.y, self.edlModule.position.z), duration: 4.3)
        let edlRotate = SCNAction.rotate(by: GameLogic.radiansFrom(-20), around: SCNVector3(0, 0, 1), duration: 2.1)
        let edlRotate2 = SCNAction.rotate(by: GameLogic.radiansFrom(5), around: SCNVector3(0, 0, 1), duration: 1.0)
        let edlRotSeq = SCNAction.sequence([edlRotate2, edlRotate])
        let mvGroup = SCNAction.group([edlMove, edlRotSeq])
        
        
        self.edlModule.runAction(mvGroup) {
            // Rotate Module
            let modTurn3 = SCNAction.rotate(by: GameLogic.radiansFrom(-30), around: SCNVector3(0, 0, 1), duration: 2.2)
            modTurn3.timingMode = .easeInEaseOut
            self.edlModule.runAction(modTurn3) {
                self.dropFromShoot()
                self.cameraNode.runAction(SCNAction.moveBy(x: 0, y: -15, z: 0, duration: 2.8))
            }
        }
        
        // shoot
        self.shootBase.runAction(shootGroup) {
            let shootRotBack = SCNAction.rotate(by: GameLogic.radiansFrom(15), around: SCNVector3(0.1, 0, 1), duration: 2.1)
            // Wobble some more
            self.shootBase.runAction(shootRotBack) {
                // finished shooting anime
            }
        }
    }
    
    func dropFromShoot() {
        
        let pos = self.shootBase.worldPosition
        let eul = self.shootBase.eulerAngles
        self.shootBase.removeFromParentNode()
        self.shootBase.position = pos
        self.shootBase.eulerAngles = eul
        self.scene.rootNode.addChildNode(self.shootBase)
        
        // Shoot goes up
        let goUp = SCNAction.moveBy(x: 0, y: 30, z: 0, duration: 1.0)
        self.shootBase.runAction(goUp) {
            self.shootBase.removeFromParentNode()
        }
        
        // Falling move anime
        let fall = SCNAction.moveBy(x: 0, y: -47.5, z: 0, duration: 5.2)
        fall.timingMode = .easeOut
        
        // Adjust angles of ship
        let straight = SCNAction.rotateTo(x: 0, y: 0, z: 0, duration: 3.2)
        let group = SCNAction.group([fall, straight])
        
        // Module action fall
        self.edlModule.runAction(group) {
            
            // Kill the Engines
            var allEngines = Array(self.engines.compactMap({ $0.childNodes }).joined())
            while !allEngines.isEmpty {
                let first = allEngines.first
                allEngines.append(contentsOf: first?.childNodes ?? [])
                first?.particleSystems?.first?.birthRate = 0
                allEngines.removeFirst()
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.igniteThrusters()
            self.spreadEngines()
        }
        
        // animate camera?
        camera.focalLength = 50
        
        // remove mars, add floor
        mars.isHidden = true
        floor.isHidden = false
        
    }
    
    // MARK: - Thrusters
    
    func igniteThrusters() {
        // self.actNames = ["POS: \(self.edlModule.worldPosition)"]
        for engine in self.engines {
            engine.isHidden = false
        }
    }
    
    func spreadEngines() {
        
        let waiter = SCNAction.wait(duration: 1.2)
        //        let rotX = SCNAction.rotateBy(x: 0, y: 0, z: GameLogic.radiansFrom(35), duration: 1.0)
        //        let sequel = SCNAction.sequence([waiter, rotX])
        
        for engine in self.engines {
            if engine.name == "EngineHolder-001" {
                let rot = SCNAction.rotateBy(x: 0, y: GameLogic.radiansFrom(-20), z: 0, duration: 1.0)
                let seq = SCNAction.sequence([waiter, rot])
                engine.runAction(seq) {
                    engine.particleSystems?.first?.birthRate = 0
                }
                
            }
            if engine.name == "EngineHolder-002" {
                let rot = SCNAction.rotateBy(x: 0, y: 0, z: GameLogic.radiansFrom(20), duration: 1.0)
                let seq = SCNAction.sequence([waiter, rot])
                engine.runAction(seq){
                    engine.particleSystems?.first?.birthRate = 0
                }
            }
            if engine.name == "EngineHolder-003" {
                let rot = SCNAction.rotateBy(x: 0, y: 0, z: GameLogic.radiansFrom(-20), duration: 1.0)
                let seq = SCNAction.sequence([waiter, rot])
                engine.runAction(seq){
                    engine.particleSystems?.first?.birthRate = 0
                }
            }
            if engine.name == "EngineHolder-004" {
                let rot = SCNAction.rotateBy(x: 0, y: GameLogic.radiansFrom(20), z: 0, duration: 1.0)
                let seq = SCNAction.sequence([waiter, rot])
                engine.runAction(seq){
                    engine.particleSystems?.first?.birthRate = 0
                }
            }
            
            
        }
    }
    
}
