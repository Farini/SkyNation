//
//  OutpostNode.swift
//  SkyNation
//
//  Created by Carlos Farini on 8/17/21.
//

import Foundation
import SceneKit

class OutpostNode:SCNNode {
    
    var posdex:Posdex
    
    /// Outposts are required
    var outpost:DBOutpost
    
    init(posdex:Posdex, outpost:DBOutpost) {
        self.posdex = posdex
        self.outpost = outpost
        
        // For position and euler, see Posdex
        // check which Type of outpost also from posdex
        
        super.init()
        
        switch posdex {
            case .hq:
                print("Headquarters")
                
            case .antenna:
                print("Antenna")
            case .launchPad:
                print("Launchpad - Landings")
                
            case .arena:
                print("Stadium")
            case .observatory:
                print("Observatory")
            
            // Production
            
            case .biosphere1, .biosphere2:
                print("Biospheres")
            
            case .mining1, .mining2, .mining3:
                print("Mining")
            
            case .power1, .power2, .power3, .power4:
                print("Power Plants")
            default:
                print("This posdex is not related to an Outpost")
        }
        
        // check if is collectible
        // load the city, check 'op_collected'
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class MarsAntennaNode:SCNNode {
    
    static let originScene:String = "Art.scnassets/Mars/Outposts/OPAntenna.scn"
    
    var posdex:Posdex
    var outpost:DBOutpost
    
    var cameraNodes:[SCNNode]
    var lightNodes:[SCNNode]
    
    // Antenna
    // Scene: /Mars/Outposts/OPAntenna
    // [Parts]
    // - Parabolic // Top Sattelite Dish
    // - Dish1 // Round top dish
    // - Pillar
    // - Wifi3, Wifi2, Wifi1
    // - Dish3, Dish2 // Lower Antennas
    // - Dish4 // Round top opposite side Dish1
    // - Scallera
    
    init(posdex:Posdex, outpost:DBOutpost) {
        
        self.posdex = posdex
        self.outpost = outpost
        
        self.cameraNodes = []
        self.lightNodes = []
        
        // This object should be equivalent to the first child node from the root.
        // Get first childnode, assign name, and other basic properties
        // add all the children from the first object to this node
        
        // Get Scene Root
        guard let sceneRoot:SCNNode = SCNScene(named:MarsAntennaNode.originScene)?.rootNode,
              let baseNode:SCNNode = sceneRoot.childNode(withName: "Antenna", recursively: false) else {
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
        
        
        self.scale = SCNVector3(0.5, 0.5, 0.5)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Level
    
    /// Prepares the Outpost Node for the level it is at.
    func prepareForLevel(lvl:Int) {
        switch lvl {
            case 0:
                self.childNode(withName: "Wifi3", recursively: false)?.removeFromParentNode()
                self.childNode(withName: "Dish2", recursively: false)?.removeFromParentNode()
                self.childNode(withName: "Dish4", recursively: false)?.removeFromParentNode()
                self.childNode(withName: "Scallera", recursively: false)?.removeFromParentNode()
            case 1:
                self.childNode(withName: "Wifi3", recursively: false)?.removeFromParentNode()
                self.childNode(withName: "Dish4", recursively: false)?.removeFromParentNode()
                self.childNode(withName: "Scallera", recursively: false)?.removeFromParentNode()
            case 2:
                self.childNode(withName: "Dish4", recursively: false)?.removeFromParentNode()
                self.childNode(withName: "Scallera", recursively: false)?.removeFromParentNode()
            default: break
        }
    }
    
    // MARK: - Animations
    
    /// Runs this Outpost's Animations
    func performAnimationLoop() {
        
        // FIXME - Origin Point
        // Needs to fix the Origin point of the Antenna (in Blender)
        
        if let parabolic = self.childNode(withName: "Parabolic", recursively: false) {
            
            let rotate1 = SCNAction.rotate(by: CGFloat(GameLogic.radiansFrom(-20)), around: SCNVector3(1, 0, 0), duration: 1.5)
            let rotate2 = SCNAction.rotate(by: CGFloat(GameLogic.radiansFrom(30)), around: SCNVector3(1, 0, 0), duration: 2.0)
            let rotate3 = SCNAction.rotate(by: CGFloat(GameLogic.radiansFrom(-10)), around: SCNVector3(1, 0, 0), duration: 1.2)
            let rotate4 = SCNAction.rotate(by: CGFloat(GameLogic.radiansFrom(20)), around: SCNVector3(1, 0, 0), duration: 0.75)
            let idle1 = SCNAction.wait(duration: 3)
            let idle2 = SCNAction.wait(duration: 1)
            // Alternatively, could make something blink
            
            let sequence = SCNAction.sequence([rotate1, rotate2, idle1, rotate3, rotate4, idle2])
            
            parabolic.runAction(sequence)
        }
    }
}

class LandingPadNode:SCNNode {
    
    static let originScene:String = "Art.scnassets/Mars/Outposts/LandingPad.scn"
    
    var posdex:Posdex
    var outpost:DBOutpost
    
    var cameraNodes:[SCNNode]
    var lightNodes:[SCNNode]
    
    // Landing Pad
    // Notes: 3 Landing pads + Sign + Launch Platform
    // Scene: Mars/Outposts/LandingPad.scn (LPad child)
    // [parts]
    // Launch Platform
    // LP2, LP3, LP1
    // Sign1, Sign2, Sign3
    // PreSign

    init(posdex:Posdex, outpost:DBOutpost) {
        
        self.posdex = posdex
        self.outpost = outpost
        
        self.cameraNodes = []
        self.lightNodes = []
        
        // This object should be equivalent to the first child node from the root.
        // Get first childnode, assign name, and other basic properties
        // add all the children from the first object to this node
        
        // Get Scene Root
        guard let sceneRoot:SCNNode = SCNScene(named:LandingPadNode.originScene)?.rootNode,
              let baseNode:SCNNode = sceneRoot.childNode(withName: "LPad", recursively: false) else {
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
        
        self.scale = SCNVector3(0.5, 0.5, 0.5)
        
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
        
        // Blink the signs
        let emittingColor = SCNColor.systemBlue
        let noColor = SCNColor.black
        
        if let sign3 = self.childNode(withName: "Sign3", recursively: true),
           let sign2 = self.childNode(withName: "Sign2", recursively: true),
           let sign1 = self.childNode(withName: "Sign1", recursively: true) {
            
            let array = [sign3, sign2, sign1]
            var delay = 1.5
            
            for item in array {
                let waiter = SCNAction.wait(duration: delay)
                item.runAction(waiter) {
                    // get its material
                    if let material = item.geometry?.firstMaterial {
                        // highlight it
                        SCNTransaction.begin()
                        SCNTransaction.animationDuration = 0.75
                        
                        // on completion - unhighlight
                        SCNTransaction.completionBlock = {
                            SCNTransaction.begin()
                            SCNTransaction.animationDuration = 0.75
                            material.emission.contents = noColor
                            SCNTransaction.commit()
                        }
                        
                        material.emission.contents = emittingColor
                    }
                    delay += 1.0
                }
            }
            SCNTransaction.commit()
        }
    }
}

class MiningNode:SCNNode {
    
    static let originScene:String = "Art.scnassets/Mars/Outposts/Mining.scn"
    
    var posdex:Posdex
    var outpost:DBOutpost
    
    var cameraNodes:[SCNNode]
    var lightNodes:[SCNNode]
    
    init(posdex:Posdex, outpost:DBOutpost) {
        
        self.posdex = posdex
        self.outpost = outpost
        
        self.cameraNodes = []
        self.lightNodes = []
        
        // This object should be equivalent to the first child node from the root.
        // Get first childnode, assign name, and other basic properties
        // add all the children from the first object to this node
        
        // Get Scene Root
        guard let sceneRoot:SCNNode = SCNScene(named:MiningNode.originScene)?.rootNode,
              let baseNode:SCNNode = sceneRoot.childNode(withName: "Excavator", recursively: false) else {
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
        
        // Blink the signs
        
        if let drill = self.childNode(withName: "Drill", recursively: true) {
            
            let goDown = SCNAction.move(by: SCNVector3(0.0, -0.7, 0.0), duration: 1.6)
            let goUp = SCNAction.move(by: SCNVector3(0.0, 0.7, 0.0), duration: 0.7)
            goDown.timingMode = .easeIn
            goUp.timingMode = .easeOut
            let waiter = SCNAction.wait(duration: 3.0)
            
            let sequence = SCNAction.sequence([goDown, waiter, goUp, waiter])
            let repeater = SCNAction.repeatForever(sequence)
            
            drill.runAction(repeater)
            
            SCNTransaction.commit()
        }
    }
    
}


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
}
