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
        guard let sceneRoot:SCNNode = SCNScene(named: "Art.scnassets/Mars/CityGate.scn")?.rootNode, //"Art.scnassets/Mars/Gate5.scn"
              let baseNode:SCNNode = sceneRoot.childNode(withName: "Gate", recursively: false),
              let placeHolder:SCNNode = sceneRoot.childNode(withName: "GatePlaceholder", recursively: false) else {
            fatalError("Could not find base nodes to build Gate Node")
        }
        
        super.init()
        
        self.name = posdex.sceneName
        
        // There are 3 types of city
        // 1. My City
        // 2. Other's City
        // 3. Unclaimed City (city = nil) -> Diamond geometry + placeholder material
        if let city = city {
            
            print("Gate Node with City \(city.name)")
            
            for baseChild in baseNode.childNodes {
                
                let node = baseChild.clone()
                self.addChildNode(node)
                
                // Cameras
                if node.name == "POV", let camNode = node.childNodes.first, let _ = camNode.camera {
                    self.cameraNodes.append(camNode)
                }
                
                // Lights
                if let childLight = node.childNodes.filter({ $0.light != nil }).first {
                    // Attention! For now this node is hidden, but at night, we can turn the light on!
                    if GameSettings.debugScene {
                        print("Lights (C) On? \(!childLight.isHidden)")
                        self.lightNodes.append(childLight)
                    }
                }
            }
            
        } else {
            // use placeholer
            let node = placeHolder.clone()
            self.addChildNode(node)
        }
        
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
