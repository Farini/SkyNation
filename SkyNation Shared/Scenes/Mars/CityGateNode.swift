//
//  CityGateNode.swift
//  SkyNation
//
//  Created by Carlos Farini on 8/17/21.
//

import Foundation
import SceneKit

class CityGateNode:SCNNode {
    
    var posdex:Posdex
    var city:DBCity?
    
    var cameraNodes:[SCNNode]
    var lightNodes:[SCNNode]
    
    init(posdex:Posdex, city:DBCity?) {
        
        self.posdex = posdex
        self.city = city
        
        self.cameraNodes = []
        self.lightNodes = []
        
        // This object should be equivalent to the first child node from the root.
        // Get first childnode, assign name, and other basuc properties
        // add all the children from the first object to this node
        
        // Get Scene Root
        guard let sceneRoot:SCNNode = SCNScene(named: "Art.scnassets/Mars/Gate5.scn")?.rootNode,
              let baseNode:SCNNode = sceneRoot.childNode(withName: "Gate", recursively: false) else {
            fatalError("Could not find base nodes to build Gate Node")
        }
        
        super.init()
        
        self.name = posdex.sceneName
        
        for baseChild in baseNode.childNodes {
            
            let node = baseChild.clone()
            self.addChildNode(node)
            
            // Cameras
            if node.name == "POV", let camNode = node.childNodes.first, let _ = camNode.camera {
                self.cameraNodes.append(camNode)
            }
            
//            if let cam = node.camera {
//                print("Camera: \(cam.description)")
//                self.cameraNodes.append(node)
//            } else if let cam = node.childNodes.first?.camera {
//                print("Camera: \(cam.description)")
//                self.cameraNodes.append(node.childNodes.first ?? SCNNode())
//            }
            
            // Lights
            if let childLight = node.childNodes.filter({ $0.light != nil }).first {
                // Attention! For now this node is hidden, but at night, we can turn the light on!
                if GameSettings.debugScene {
                    print("Lights (C) On? \(!childLight.isHidden)")
                    self.lightNodes.append(childLight)
                }
            }
        }
        
        // There are 3 types of city
        // 1. My City
        // 2. Other's City
        // 3. Unclaimed City (city = nil) -> Needs to add "Diamond" Geometry
        
        // When city is nil, add the diamond, as an indicator, and to claim city
        
        if city == nil {
            guard let diamond = baseNode.childNode(withName: "Diamond", recursively: false)?.clone() else {
                print("Could not load diamond")
                return
            }
            self.addChildNode(diamond)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Tries to get the first camera it can find.
    func getMyCamera() -> SCNNode? {
        return cameraNodes.first
    }
    
    /// At night, you may turn the lights on
    func turnLightsOn() {
        for lightNode in lightNodes {
            lightNode.isHidden = false
            print("Turning light on. \(lightNode.name ?? "n/a")")
        }
    }
}