//
//  SpaceVehicleNode.swift
//  SkyNation
//
//  Created by Carlos Farini on 3/2/21.
//

import Foundation
import SceneKit

/**
 A Scene node that represents the `SpaceVehicle` object.
 */
class SpaceVehicleNode:SCNNode {
    
    var rocketBooster:SCNNode
    var satellite:SCNNode
    var edlModule:SCNNode
    var crewBody:SCNNode
    var miniEmitters:[SCNNode]
    
    init(vehicle:SpaceVehicle, parentScene:SCNScene) {
        
        guard let booster = parentScene.rootNode.childNode(withName: "RocketBooster", recursively: false),
              let satellite = parentScene.rootNode.childNode(withName: "Satellite", recursively: false),
              let edlModule = parentScene.rootNode.childNode(withName: "EDLModule", recursively: false),
              let crewBody = parentScene.rootNode.childNode(withName: "CrewBody", recursively: false),
              let p1 = parentScene.rootNode.childNode(withName: "particles1", recursively: true),
              let p2 = parentScene.rootNode.childNode(withName: "particles2", recursively: true),
              let emitter = booster.childNode(withName: "Emitter", recursively: true) else {
            fatalError()
        }
    
        booster.isHidden = false
        self.rocketBooster = booster
        
        let currentBirthrate = emitter.particleSystems?.first?.birthRate
        
        emitter.isHidden = false
        emitter.particleSystems?.first?.birthRate = 0
        
        print("Paused: \(emitter.isPaused)")
        print("Emitter Children: \(emitter.particleSystems?.count ?? 0)")
        print("Emitter: \(emitter.debugDescription)")
        emitter.particleSystems?.first!.emissionDuration = 2
        
        switch vehicle.engine {
            case .Hex6:
                edlModule.isHidden = true
                crewBody.isHidden = true
            case .T12, .T18:
                edlModule.isHidden = false
                edlModule.position.x = 3.39
                crewBody.isHidden = true
            case .T22:
                edlModule.isHidden = false
                crewBody.isHidden = false
                
        }
        
        satellite.isHidden = false
        self.satellite = satellite
        
        self.edlModule = edlModule
        self.crewBody = crewBody
        
        self.miniEmitters = [p1, p2]
        
        super.init()
        // Post Init
        
        // Add the Children
        self.addChildNode(rocketBooster)
        self.addChildNode(satellite)
        self.addChildNode(edlModule)
        self.addChildNode(crewBody)
        
        parentScene.rootNode.addChildNode(self)
        
        let waitEmit = SCNAction.wait(duration: 2.9)
        emitter.runAction(waitEmit) {
            // ignite
            emitter.particleSystems?.first?.birthRate = currentBirthrate ?? 100.0
            self.openSolarPanels()
        }
        
        self.runMiniEmitters()
    }
    
    func runMiniEmitters() {
        if edlModule.isHidden {
            return
        }
        
        for emit in miniEmitters {
            
            guard let es = emit.particleSystems?.first else {
                fatalError()
            }
            
            emit.isHidden = false
            
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 1.5
            SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: .easeIn)
            es.birthRate = 50
            SCNTransaction.commit()
            
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.shutOffMiniEmitters()
        }
        
        let rotate = SCNAction.rotateBy(x: 0, y: .pi, z: 0, duration: 30)
        self.edlModule.runAction(rotate)
        
    }
    
    func shutOffMiniEmitters() {
        
        for emit in miniEmitters {
            
            guard let es = emit.particleSystems?.first else {
                fatalError()
            }
        
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.3
            SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: .easeIn)
            es.birthRate = 0
            SCNTransaction.commit()
        }
        
        if let mainEmitter = rocketBooster.childNode(withName: "Emitter", recursively: true) {
            if let particles = mainEmitter.particleSystems?.first {
                particles.birthRate = 0
            }
        }
    }
    
    func move() {
        
        let move = SCNAction.move(by: SCNVector3(75, 0, 0), duration: 30) // let move = SCNAction.move(by: SCNVector3(150, 0, 0), duration: 30)
        move.timingMode = .easeInEaseOut
        
        let wait = SCNAction.wait(duration: 2.9)
        let group = SCNAction.sequence([wait, move])
        self.runAction(group) {
            print("Finished anime")
            self.rocketBooster.isHidden = true
        }
    }
    
    /// Opens the solar panels of the Vehicle. Animation takes about 5 seconds.
    func openSolarPanels() {
        if let sp1 = satellite.childNode(withName: "SP1-003", recursively: false) {
            let turn = SCNAction.rotate(by: CGFloat(GameLogic.radiansFrom(-90)), around: SCNVector3(0, 0, 1), duration: 2.5)
            turn.timingMode = .easeIn
            sp1.runAction(turn)
            if let sp2 = sp1.childNodes.first {
                let turn2 = SCNAction.rotate(by: CGFloat(GameLogic.radiansFrom(-180)), around: SCNVector3(0, 0, 1), duration: 2.5)
                sp2.runAction(turn2)
            }
        }
        
        if let sp3 = satellite.childNode(withName: "SP1-001", recursively: false) {
            let turn = SCNAction.rotate(by: CGFloat(GameLogic.radiansFrom(90)), around: SCNVector3(0, 0, 1), duration: 2.5)
            turn.timingMode = .easeIn
            sp3.runAction(turn)
            if let sp4 = sp3.childNodes.first {
                let turn2 = SCNAction.rotate(by: CGFloat(GameLogic.radiansFrom(180)), around: SCNVector3(0, 0, 1), duration: 2.5)
                sp4.runAction(turn2)
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
