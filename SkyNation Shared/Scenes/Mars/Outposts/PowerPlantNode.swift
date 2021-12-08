//
//  PowerPlantNode.swift
//  SkyNation
//
//  Created by Carlos Farini on 9/19/21.
//

import Foundation
import SceneKit

/**
 A Scene Node that represents a `PowerPlant` Outpost.
 */
class PowerPlantNode:SCNNode {
    //    static let originScene:String = "Art.scnassets/Mars/Outposts/PowerPlant.scn"
    static let originScene:String = "Art.scnassets/Mars/Outposts/PowerPlant3.scn"
    
    var posdex:Posdex
    var outpost:DBOutpost
    
    var cameraNodes:[SCNNode]
    var lightNodes:[SCNNode]
    
    // PowerPlant
    // Notes: Plenty of opportunity for levels here. Start with the side ones, then the outside Panels, then inside Reflectors, Then Outside reflectors
    // Scene: /Mars/Outposts/PowerPlant.scn
    // [Parts]
    // [Side Solar Panels]: Panel1,2,3,4
    // [Outter Panels]: Panel8,7,6,5
    // [Largest reflector]: MainReflector
    // [Outside Reflectors] Reflector4,5,2,7,6
    // [Inside Reflectors]: Reflector1,2,3
    // [cables] Cable1...Cable19
    
    init(posdex:Posdex, outpost:DBOutpost) {
        
        self.posdex = posdex
        self.outpost = outpost
        
        self.cameraNodes = []
        self.lightNodes = []
        
        // This object should be equivalent to the first child node from the root.
        // Get first childnode, assign name, and other basic properties
        // add all the children from the first object to this node
        
        // Get Scene Root
        guard let sceneRoot:SCNNode = SCNScene(named:PowerPlantNode.originScene)?.rootNode,
              let baseNode:SCNNode = sceneRoot.childNode(withName: "PowerPlant", recursively: false) else {
            fatalError("Could not find base nodes to build Antenna Node")
        }
        
        super.init()
        
        // FIXME: - Position and Euler
        // Position: see Posdex
        //        self.position = posdex.position.sceneKitVector()
        //        self.eulerAngles = posdex.eulerAngles.sceneKitVector()
        // Euler: see Posdex
        
        self.name = posdex.sceneName
        
        // MARK: - Children
        
        for baseChild in baseNode.childNodes {
            
            // Clone node
            let node = baseChild.clone()
            self.addChildNode(node)
            
            // Look for cameras
            if let cam = node.camera {
                print("Camera: \(cam.description)")
                self.cameraNodes.append(node)
            }
            
            // Look for lights
            if let childLight = node.childNodes.filter({ $0.light != nil }).first {
                // Attention! For now this node is hidden, but at night, we can turn the light on!
                if GameSettings.debugScene {
                    print("Lights (C) On? \(!childLight.isHidden)")
                    self.lightNodes.append(childLight)
                }
            }
        }
        
        if let cam = self.childNode(withName: "Camera", recursively: true) {
            self.cameraNodes.append(cam)
        }
        
        self.prepareForLevel(lvl: outpost.level)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Level
    
    /// Prepares the Outpost Node for the level it is at.
    func prepareForLevel(lvl:Int) {
        
        var unvisited:[SCNNode] = self.childNodes
        var stack:[SCNNode] = []
        
        while !unvisited.isEmpty {
            let next = unvisited.first!
            stack.append(next)
            unvisited.append(contentsOf: next.childNodes)
            unvisited.removeFirst()
        }
        
        switch lvl {
            case 0:
                // Powerplant - Only this child will stay
                for child in childNodes {
                    if child.name != "Floor" {
                        child.removeFromParentNode()
                    }
                }
                
                if let centerPL1 = childNode(withName: "CenterPL1", recursively: true) {
                    centerPL1.removeFromParentNode()
                }
                if let centerPL3 = childNode(withName: "CenterPL3", recursively: true) {
                    centerPL3.removeFromParentNode()
                }
                
            case 1:
                
                if let centerPL3 = childNode(withName: "CenterPL3", recursively: true) {
                    centerPL3.removeFromParentNode()
                }
                
                let stays = ["Panel1", "Panel2", "Panel3", "Panel4", "Cable12", "Cable11", "Cable9", "Cable14", "PowerPlant", "Cable12", "Cable11", "Cable9", "Cable14", "Floor", "Panels"]
                for cNode in stack {
                    if !stays.contains(cNode.name ?? "zzz") {
                        cNode.removeFromParentNode()
                    }
                }
                
                
                
            case 2:
                
                if let centerPL3 = childNode(withName: "CenterPL3", recursively: true) {
                    centerPL3.removeFromParentNode()
                }
                
                let stays = ["Panel1", "Panel2", "Panel3", "Panel5", "Panel6", "Panel7", "Panel8", "Panel4", "Powerplant", "Cable12", "Cable11", "Cable9", "Cable14", "Cable4", "Cable5", "Cable19", "Cable18", "Floor", "Panels"]
                
                //                let stayingPanels:[String] = ["Panel1", "Panel2", "Panel3", "Panel5", "Panel6", "Panel7", "Panel8", "Panel4", "Powerplant"]
                //                let stayingCables:[String] = ["Cable12", "Cable11", "Cable9", "Cable14", "Cable4", "Cable5", "Cable19", "Cable18"]
                
                for cNode in stack {
                    if !stays.contains(cNode.name ?? "zzz") {
                        cNode.removeFromParentNode()
                    }
                }
                
            //                if let panels = childNode(withName: "Panels", recursively: false) {
            //                    for child in panels.childNodes {
            //                        if !stayingPanels.contains(child.name ?? "") {
            //                            child.removeFromParentNode()
            //                        }
            //                    }
            //                }
            //                if let cables = childNode(withName: "Wires", recursively: false) {
            //                    for child in cables.childNodes {
            //                        if !stayingCables.contains(child.name ?? "") {
            //                            child.removeFromParentNode()
            //                        }
            //                    }
            //                }
            
            case 3:
                
                if let centerPL1 = childNode(withName: "CenterPL1", recursively: true) {
                    centerPL1.removeFromParentNode()
                }
                
                let deleting:[String] = ["MainReflector", "Reflector2", "Reflector3", "Reflector4"]
                
                
                for cNode in stack {
                    if deleting.contains(cNode.name ?? "zzz") {
                        cNode.removeFromParentNode()
                    }
                }
            //                for childName in deleting {
            //                    if let del = self.childNode(withName: childName, recursively: true) {
            //                        del.removeFromParentNode()
            //                    }
            //                }
            case 4:
                
                let deleting:[String] = ["MainReflector"]
                
                if let centerPL1 = childNode(withName: "CenterPL1", recursively: true) {
                    centerPL1.removeFromParentNode()
                }
                
                for cNode in stack {
                    if deleting.contains(cNode.name ?? "zzz") {
                        cNode.removeFromParentNode()
                    }
                }
                
            //                for childName in deleting {
            //                    if let del = self.childNode(withName: childName, recursively: true) {
            //                        del.removeFromParentNode()
            //                    }
            //                }
            
            case 5:
                
                if let centerPL1 = childNode(withName: "CenterPL1", recursively: true) {
                    centerPL1.removeFromParentNode()
                }
                
                print("Max Level")
                
            default: break
        }
    }
    
    // MARK: - Animations
    
    /// Runs this Outpost's Animations
    func performAnimationLoop() {
        
        // FIXME - Add More animations
        
        // HeatZone
        if let base = self.childNode(withName: "Powerplant", recursively: true) {
            if let heatZone = base.geometry?.material(named: "Heatzone") {
                if self.outpost.level <= 2 {
                    heatZone.emission.contents = SCNColor.darkGray
                }
            }
        }
        
        // Particle Emitter
        if let emitter = self.childNode(withName: "Emitter", recursively: true){
            
            if let particleSys = emitter.particleSystems?.first {
                if outpost.level < 2 {
                    emitter.isHidden = true
                } else {
                    if outpost.level == 2 {
                        particleSys.speedFactor = 0.5
                    } else if outpost.level >= 3 {
                        particleSys.speedFactor = 0.75
                    }
                }
            }
        }
    }
}
