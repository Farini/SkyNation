//
//  BiosphereNode.swift
//  SkyNation
//
//  Created by Carlos Farini on 9/19/21.
//

import Foundation
import SceneKit

/**
 A Scene Node that represents a `Biosphere` Outpost
 */
class BiosphereNode:SCNNode {
    
    static let originScene:String = "Art.scnassets/Mars/Outposts/Biosphere.scn"
    
    var posdex:Posdex
    var outpost:DBOutpost
    
    var cameraNodes:[SCNNode]
    var lightNodes:[SCNNode]
    
    // Biosphere
    // Scene: /Mars/Outposts/Biosphere2.scn
    // [Parts]
    // - Dome
    // - Building
    // SolarPanels x 9
    // WallLVL x 5
    // Tanks x 5
    // Animals
    
    init(posdex:Posdex, outpost:DBOutpost) {
        
        self.posdex = posdex
        self.outpost = outpost
        
        self.cameraNodes = []
        self.lightNodes = []
        
        // This object should be equivalent to the first child node from the root.
        // Get first childnode, assign name, and other basic properties
        // add all the children from the first object to this node
        
        // Get Scene Root
        guard let sceneRoot:SCNNode = SCNScene(named:BiosphereNode.originScene)?.rootNode,
              let baseNode:SCNNode = sceneRoot.childNode(withName: "Biosphere", recursively: false) else {
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
        
        self.prepareForLevel(lvl: outpost.level)
        self.performAnimationLoop()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Level
    
    /// Prepares the Outpost Node for the level it is at.
    func prepareForLevel(lvl:Int) {
        
        guard let walls = self.childNode(withName: "Walls", recursively: false),
              let buildings = self.childNode(withName: "Buildings", recursively: false),
              let panels = self.childNode(withName: "SolarPanels", recursively: false),
              let tanks = self.childNode(withName: "Tanks", recursively: false) else {
            return
        }
        
        // Walls
        for child in walls.childNodes {
            if child.name == "WallL0" {
                if lvl > 0 { child.removeFromParentNode() }
            }
            if child.name == "WallL1" {
                if lvl == 0 || lvl > 3 {
                    child.removeFromParentNode()
                }
            }
            if child.name == "WallL3" {
                if lvl < 3 {
                    child.removeFromParentNode()
                }
            }
        }
        
        // Buildings
        for child in buildings.childNodes {
            // Inside dome
            if child.name == "BuildingL1" {
                if lvl > 1 { child.removeFromParentNode() }
            }
            // Inside dome
            if child.name == "BuildingL2" {
                if lvl != 2 {
                    child.removeFromParentNode()
                }
            }
            // Dome
            if child.name == "BuildingL3D" {
                if lvl < 3 {
                    child.removeFromParentNode()
                }
            }
            // Side building
            if child.name == "BuildingL4" {
                if lvl < 4 {
                    child.removeFromParentNode()
                }
            }
        }
        
        // Panels
        for child in panels.childNodes {
            var series:[String] = ["L1", "L2", "L3", "L4", "L5"]
            guard let cName = child.name else { continue }
            
            if lvl == 0 {
                child.removeFromParentNode()
            } else if lvl == 1 {
                series.removeFirst()
                for sName in series {
                    if cName.contains(sName) {
                        child.removeFromParentNode()
                    }
                }
            } else if lvl == 2 {
                series.removeFirst(2)
                for sName in series {
                    if cName.contains(sName) {
                        child.removeFromParentNode()
                    }
                }
            } else if lvl == 3 {
                series.removeFirst(3)
                for sName in series {
                    if cName.contains(sName) {
                        child.removeFromParentNode()
                    }
                }
            } else if lvl == 4 {
                series.removeFirst(4)
                for sName in series {
                    if cName.contains(sName) {
                        child.removeFromParentNode()
                    }
                }
            }
        }
        
        
        // Tanks
        for child in tanks.childNodes {
            var series:[String] = ["L1", "L2", "L3", "L4", "L5"]
            guard let cName = child.name else { continue }
            
            if lvl == 0 {
                child.removeFromParentNode()
            } else if lvl == 1 {
                series.removeFirst()
                for sName in series {
                    if cName.contains(sName) {
                        child.removeFromParentNode()
                    }
                }
            } else if lvl == 2 {
                series.removeFirst(2)
                for sName in series {
                    if cName.contains(sName) {
                        child.removeFromParentNode()
                    }
                }
            } else if lvl == 3 {
                series.removeFirst(3)
                for sName in series {
                    if cName.contains(sName) {
                        child.removeFromParentNode()
                    }
                }
            } else if lvl == 4 {
                series.removeFirst(4)
                for sName in series {
                    if cName.contains(sName) {
                        child.removeFromParentNode()
                    }
                }
            }
        }
        
        
    }
    
    // MARK: - Animations
    
    /// Runs this Outpost's Animations
    func performAnimationLoop() {
        
        // Blink the signs
        
        //        if let drill = self.childNode(withName: "Drill", recursively: true) {
        //
        //            let goDown = SCNAction.move(by: SCNVector3(0.0, -0.7, 0.0), duration: 1.6)
        //            let goUp = SCNAction.move(by: SCNVector3(0.0, 0.7, 0.0), duration: 0.7)
        //            goDown.timingMode = .easeIn
        //            goUp.timingMode = .easeOut
        //            let waiter = SCNAction.wait(duration: 1.0)
        //
        //            let sequence = SCNAction.sequence([goDown, waiter, goUp, waiter])
        //
        //            drill.runAction(sequence)
        //
        //            SCNTransaction.commit()
        //        }
    }
}

