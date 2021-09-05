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

class PowerPlantNode:SCNNode {
//    static let originScene:String = "Art.scnassets/Mars/Outposts/PowerPlant.scn"
    static let originScene:String = "Art.scnassets/Mars/Outposts/PowerPlant2.scn"
    
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


// Missing:
// 3. Arena
// 4. HQ? - Not actually a Scene
