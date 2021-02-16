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
    var peripheral:PeripheralObject
    
    init(peripheral:PeripheralObject) {
        
        self.peripheral = peripheral
        
        guard let theNode = SCNScene(named: "Art.scnassets/SpaceStation/Accessories/Antenna.scn")?.rootNode.childNode(withName: "Antenna", recursively: true)?.clone() else { fatalError() }
        
        if GameSettings.shared.debugScene {
            print("Space Station Antenna (Children): \(theNode.childNodes.count)")
            print("Space Station Antenna (Level): \(peripheral.level)")
        }
        
        
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

