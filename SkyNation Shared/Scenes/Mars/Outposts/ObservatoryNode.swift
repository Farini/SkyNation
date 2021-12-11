//
//  ObservatoryNode.swift
//  SkyNation
//
//  Created by Carlos Farini on 10/12/21.
//

import Foundation
import SceneKit

class ObservatoryNode:SCNNode {
    
    static let originScene:String = "Art.scnassets/Mars/Outposts/Observatory.scn"
    
    var posdex:Posdex
    var outpost:DBOutpost
    
    var cameraNodes:[SCNNode]
    var lightNodes:[SCNNode]
    
    // Observatory
    // Scene: /Mars/Outposts/Biosphere2.scn
    // [Parts]
    // MainPillar
    // Dome
    //  -> TelescopeCyl
    
    // Note: Animation is working very well.
    
    init(posdex:Posdex, outpost:DBOutpost) {
        
        self.posdex = posdex
        self.outpost = outpost
        
        self.cameraNodes = []
        self.lightNodes = []
        
        // This object should be equivalent to the first child node from the root.
        // Get first childnode, assign name, and other basic properties
        // add all the children from the first object to this node
        
        // Get Scene Root
        guard let sceneRoot:SCNNode = SCNScene(named:ObservatoryNode.originScene)?.rootNode,
              let baseNode:SCNNode = sceneRoot.childNode(withName: "Observatory", recursively: false) else {
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
            let node = baseChild.clone()
            self.addChildNode(node)
            
            
            
            // Look for cameras
            if let cam = node.camera {
                print("Camera: \(cam.description)")
                self.cameraNodes.append(node)
            } else {
                if node.name == "CamPov" {
                    if let camNode = node.childNodes.first {
                        self.cameraNodes.append(camNode)
                    }
                }
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
        
        self.performAnimationLoop()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Level
    
    /// Prepares the Outpost Node for the level it is at.
    func prepareForLevel(lvl:Int) {
        print("Not Setup yet")
    }
    
    // MARK: - Animations
    
    /// Runs this Outpost's Animations
    func performAnimationLoop() {
        
        guard let dome = childNode(withName: "Dome", recursively: true) else { return }
        
        if let telescope = dome.childNode(withName: "TelescopeCyl", recursively: false) {
            self.lowerTelescopeLens(dome: dome, telescope: telescope, repeatAnime: true)
        }
        
        self.rotateMechTelescope()
        
    }
    
    private func lowerTelescopeLens(dome:SCNNode, telescope:SCNNode, repeatAnime:Bool) {
        
#if os(macOS)
        let lowerDeg = CGFloat(GameLogic.radiansFrom(-45))
#else
        let lowerDeg = GameLogic.radiansFrom(-45)
#endif
        
        // Lower Telescope
        let teleLower = SCNAction.rotateBy(x: lowerDeg, y: 0, z: 0, duration: 2.2)
        let waiter = SCNAction.wait(duration: 2)
        
        // Sequences
        // 1. Lower telescope
        let lowerAction = SCNAction.sequence([teleLower, waiter])
        
        telescope.runAction(lowerAction) {
            self.rotateDome(dome: dome, telescope: telescope, repeatAnime: repeatAnime)
        }
        
    }
    
    private func rotateDome(dome:SCNNode, telescope:SCNNode, repeatAnime:Bool) {
        
        // Rotate Dome
        
        let domeRot = SCNAction.rotateBy(x: 0.0, y: 0.75, z: 0, duration: 2.5)
        let domeWait = SCNAction.wait(duration: 3.0)
        let domeBack = SCNAction.rotateBy(x: 0.0, y: -0.75, z: 0, duration: 2.5)
        
        let domeAction = SCNAction.sequence([domeRot, domeWait, domeBack])
        
        dome.runAction(domeAction) {
            self.liftTelescope(dome: dome, telescope: telescope, repeatAnime: repeatAnime)
        }
    }
    
    private func liftTelescope(dome:SCNNode, telescope:SCNNode, repeatAnime:Bool) {
        
#if os(macOS)
        let lowerDeg = CGFloat(GameLogic.radiansFrom(-45))
#else
        let lowerDeg = GameLogic.radiansFrom(-45)
#endif
        
        // Lift telescope
        let teleLift = SCNAction.rotateBy(x: -lowerDeg, y: 0, z: 0, duration: 1.5)
        let coolDown = SCNAction.wait(duration: 3.5)
        
        let liftAction = SCNAction.sequence([teleLift, coolDown])
        telescope.runAction(liftAction) {
            if repeatAnime == true {
                self.lowerTelescopeLens(dome: dome, telescope: telescope, repeatAnime: repeatAnime)
            }
        }
    }
    
    
    
    private func rotateMechTelescope() {
        if let arm = self.childNode(withName: "MechArm", recursively: false) {
            if let triTelescope = arm.childNodes.first {
                
#if os(macOS)
                let lowerDeg = CGFloat(GameLogic.radiansFrom(-60))
#else
                let lowerDeg = GameLogic.radiansFrom(-60)
#endif
                
                // Lift telescope
                let lift = SCNAction.rotateBy(x: 0, y:lowerDeg, z: 0, duration: 0.75)
                let coolDown1 = SCNAction.wait(duration: 5.5)
                let back = SCNAction.rotateBy(x: 0, y:-lowerDeg, z: 0, duration: 1.25)
                let coolDown2 = SCNAction.wait(duration: 5.5)
                
                let liftAction = SCNAction.sequence([coolDown1, lift, coolDown2, back])
                triTelescope.runAction(liftAction) {
                    
                    self.rotateMechTelescope()
                    
                }
                
            }
        }
    }
}
