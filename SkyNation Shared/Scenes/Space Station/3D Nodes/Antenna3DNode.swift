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
    var radar:SCNNode?
    
    private func animate() {
        
        let waitTimes:[Double] = [5, 10, 20, 40]
        if let radar = radar {
            let waiter = SCNAction.wait(duration: waitTimes.randomElement()!)
            let rotate1 = SCNAction.rotateBy(x: CGFloat(GameLogic.radiansFrom(-60)), y: 0, z: 0, duration: 2)
            let rotate2 = SCNAction.rotateBy(x: CGFloat(GameLogic.radiansFrom(122)), y: 0, z: 0, duration: 2)
            let rotate3 = SCNAction.rotateBy(x: CGFloat(GameLogic.radiansFrom(-62)), y: 0, z: 0, duration: 2)
            let sequel = SCNAction.sequence([waiter, rotate1, rotate2, rotate3])
            radar.runAction(sequel) {
//                print("Finished antenna animation")
                DispatchQueue.init(label: "AntennaWaiter").asyncAfter(deadline: DispatchTime.now() + waitTimes.randomElement()!) {
                    DispatchQueue.main.async {
                        self.animate()
                    }
                }
                
            }
            
        }
    }
    
    init(peripheral:PeripheralObject) {
        
        self.peripheral = peripheral
        
        guard let theNode = SCNScene(named: "Art.scnassets/SpaceStation/Accessories/Antenna.scn")?.rootNode.childNode(withName: "Antenna", recursively: true)?.clone() else { fatalError() }
        
        if GameSettings.shared.debugScene {
            print("Space Station Antenna (Children): \(theNode.childNodes.count)")
            print("Space Station Antenna (Level): \(peripheral.level)")
        }
        
        let structure = theNode.childNode(withName: "Structure", recursively: false)
//        let dish = structure?.childNode(withName: "Dish", recursively: false)   // dish is always there
        
        
        let midrangeLens = structure?.childNode(withName: "MidRangeLens", recursively: false)
        let longRangeLens = structure?.childNode(withName: "LongRangeLens", recursively: false)
        
        // Rotate X
        let radarWire = structure?.childNode(withName: "RadarWire", recursively: false)
        let mirror = structure?.childNode(withName: "Miror", recursively: false)
        
        
        if peripheral.level < 5 {
            mirror?.isHidden = true
            radar = radarWire
        } else if peripheral.level < 4 {
            longRangeLens?.isHidden = true
            radar = radarWire
        } else if peripheral.level < 3 {
            radarWire?.isHidden = true
        } else if peripheral.level < 2 {
            midrangeLens?.isHidden = true
        }
        
        self.antenna = theNode
        super.init()
        
        // Post Init
        self.name = "Antenna"
        self.addChildNode(antenna)
        
        self.animate()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

