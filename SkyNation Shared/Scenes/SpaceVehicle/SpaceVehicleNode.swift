//
//  SpaceVehicleNode.swift
//  SkyNation
//
//  Created by Carlos Farini on 3/2/21.
//

import Foundation
import SceneKit

class SpaceVehicleNode:SCNNode {
    
    // :: Children
    // Satellite
    // EDLModule
    // CrewBody
    // RocketBooster
    
    var rocketBooster:SCNNode
    var satellite:SCNNode
    var edlModule:SCNNode
    var crewBody:SCNNode
    
    init(vehicle:SpaceVehicle, parentScene:SCNScene) {
        
//        guard let vehicleScene = SCNScene(named: "Art.scnassets/Vehicles/SpaceVehicle3.scn") else { fatalError() }
        guard let booster = parentScene.rootNode.childNode(withName: "RocketBooster", recursively: false) else { fatalError() }
        guard let satellite = parentScene.rootNode.childNode(withName: "Satellite", recursively: false),
              let edlModule = parentScene.rootNode.childNode(withName: "EDLModule", recursively: false),
              let crewBody = parentScene.rootNode.childNode(withName: "CrewBody", recursively: false) else {
            fatalError()
        }
        
        booster.isHidden = false
        self.rocketBooster = booster
        
        if let emitter = booster.childNode(withName: "Emitter", recursively: true) {
            emitter.isHidden = false
            print("Emitter is here _+_+_+_+_+_+_+_+_+_+_+_+_+")
            print("Paused: \(emitter.isPaused)")
            print("Emitter Children: \(emitter.particleSystems?.count ?? 0)")
            print("Emitter: \(emitter.debugDescription)")
            emitter.particleSystems?.first!.emissionDuration = 2
        }
        
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
        
//        edlModule.isHidden = vehicle.engine == .Hex6
//        edlModule.isHidden = false
        self.edlModule = edlModule
        
//        crewBody.isHidden = ![EngineType.T22, EngineType.T18].contains(vehicle.engine)
//        crewBody.isHidden = false
        self.crewBody = crewBody
        
        
        
        
        super.init()
        
        parentScene.rootNode.addChildNode(self)
        
        
        self.addChildNode(rocketBooster)
        self.addChildNode(satellite)
        self.addChildNode(edlModule)
        self.addChildNode(crewBody)
        
//        self.move()
    }
    
    func move() {
        let move = SCNAction.move(by: SCNVector3(150, 0, 0), duration: 30)
        let wait = SCNAction.wait(duration: 5)
        let group = SCNAction.sequence([wait, move])
        self.runAction(group) {
            print("Finished anime")
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
