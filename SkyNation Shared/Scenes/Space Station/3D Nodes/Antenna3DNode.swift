//
//  Antenna3DNode.swift
//  SkyNation
//
//  Created by Carlos Farini on 1/11/21.
//

import Foundation
import SceneKit

class Antenna3DNode:SCNNode {
    
    var antenna:SCNNode
    
    override init() {
        guard let theNode = SCNScene(named: "Art.scnassets/SpaceStation/Accessories/Antenna.scn")?.rootNode.childNode(withName: "Antenna", recursively: true)?.clone() else { fatalError() }
        print("Initializing Antenna (Children): \(theNode.childNodes.count)")
        self.antenna = theNode
        super.init()
        
        // Post Init
        self.name = "Antenna"
        self.addChildNode(antenna)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

