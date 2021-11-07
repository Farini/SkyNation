//
//  RadiatorNode.swift
//  SkyNation
//
//  Created by Carlos Farini on 1/13/21.
//

import Foundation
import SceneKit

class RadiatorNode:SCNNode {
    
    var radiator:SCNNode
    var foldAngles:Double = 15.0
    
    func setupAngles(new angle:Double?) {
        
        if let newAngle = angle {
            foldAngles = newAngle
        }
        
        var nextChild = radiator.childNodes.first
        var opposedFold:Bool = false
        
        while let current = nextChild?.childNodes.first {
            #if os(macOS)
            current.eulerAngles.x = CGFloat(GameLogic.radiansFrom(opposedFold ? foldAngles:-foldAngles))
            #elseif os(iOS)
            current.eulerAngles.x = Float(GameLogic.radiansFrom(opposedFold ? foldAngles:-foldAngles))
            #endif
            nextChild = current
            opposedFold.toggle()
        }
        
        //        self.isPaused = false
        self.foldAnimation(newAngle: 30)
    }
    
    private func foldAnimation(newAngle:Double) {
        
        var nextChild:SCNNode? = radiator.childNodes.first
        var opposedFold:Bool = false
        var waiterTime:Double = 5
        var childIndex:Int = 0
        self.eulerAngles.x = 0.326 //1.9154
        
        while let current:SCNNode = nextChild?.childNodes.first {
            
            let rotAngle = GameLogic.radiansFrom(opposedFold ? newAngle:childIndex == 1 ? -2*newAngle:-newAngle)
            // print("LOCROT: \(rotAngle)")
            
            let waiter = SCNAction.wait(duration: waiterTime)
            let fold = SCNAction.rotateBy(x: CGFloat(rotAngle), y: 0, z: 0, duration: 1.5)
            let sequence = SCNAction.sequence([waiter, fold])
            
            current.runAction(sequence) {
                // Debug logging
                if GameSettings.debugScene {
                    print("Radiator Angles: \(current.eulerAngles)")
                }
            }
            
            waiterTime += 1.5
            nextChild = current
            childIndex += 1
            opposedFold.toggle()
        }
    }
    
    override init() {
        
        guard let theNode = SCNScene(named: "Art.scnassets/SpaceStation/Accessories/Radiator.scn")?.rootNode.childNode(withName: "Radiator", recursively: true)?.clone() else { fatalError() }
        
        if GameSettings.debugScene {
            print("Initializing Radiator (Children): \(theNode.childNodes.count)")
        }
        
        theNode.isPaused = false
        self.radiator = theNode
        super.init()
        
        // Post Init
        self.name = "Radiator"
        self.addChildNode(radiator)
        self.isPaused = false
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
