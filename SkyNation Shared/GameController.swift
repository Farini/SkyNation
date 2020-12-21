//
//  GameController.swift
//  SkyNation Shared
//
//  Created by Carlos Farini on 12/18/20.
//

import SceneKit
import SpriteKit

protocol GameNavDelegate {
    func didChooseModule(name:String)
    func didSelectLab(module:LabModule)
    func didSelectHab(module:HabModule)
    func didSelectBio(module:BioModule)
    func didSelectTruss(station:Station)
    func didSelectGarage(station:Station)
    func didSelectAir()
    func didSelectEarth()
}


class GameController: NSObject, SCNSceneRendererDelegate {

    // Views
    var scene: SCNScene
    let sceneRenderer: SCNSceneRenderer
    var gameScene:GameSceneType = .SpaceStation
    
    /// An empty Node that controls the camera
    var cameraNode:SCNNode?
    var camToggle:Bool = false { // The toggle that shows/hides the camera menu
        didSet { oldValue == false ? showCameraMenu():hideCameraMenu() }
    }
    
    /// Scene's SpriteKit Overlay
    var stationOverlay:StationOverlay
    
    // Data
    var gameNavDelegate:GameNavDelegate?
    var builder:SerialBuilder
    var modules:[Module] = []
    var station:Station?
    
    // MARK: - Control
    
    func highlightNodes(atPoint point: CGPoint) {
        
        print("Touched: \(point)")
        
        // Convert the point to the Overlay Scene
        let converted:CGPoint = sceneRenderer.overlaySKScene!.convertPoint(fromView: point)
        print("Point In Overlay Scene: \(converted)")
        
        // Check Overlay First
        if let sceneResults = sceneRenderer.overlaySKScene?.nodes(at: converted).first {
            print("Scene Results !!!! \(sceneResults.description)")
            
            // Images
            if let sprite = sceneResults as? SKSpriteNode {
                
                // Life support systems (Air Control)
                if sprite.name == "Air Control" {
                    gameNavDelegate?.didSelectAir()
                    return
                }
                
                // Camera Rotations
                if sprite.name == "rotate.left" {
                    self.cameraNode?.eulerAngles.y += 15 * (.pi / 180)
                    return
                }
                
                if sprite.name == "rotate.right" {
                    self.cameraNode?.eulerAngles.y += -15 * (.pi / 180)
                    return
                }
                
                if sprite.name == "CameraIcon" {
                    print("Clicked on camera.")
                    print("Use this function to pull a camera menu")
                    print("In that menu, the user is supposed to control the camera")
                    print("it should have a slider (to control camera's Z position)")
                    print("it should also have 2 buttons for rotation (along the Y axis)")
                    print("and another button to see the garage (if scene == .station)")
                    print("[End of Camera menu]\n---- ")
                    camToggle.toggle()
                }
                
                // Tutorial button
                if sprite.name == "tutorial" {
                    print("🎓 HIT TUTORIAL NODE")
                    self.stationOverlay.showTutorial()
                    return
                }
                
                if sprite.name == "settings" {
                    print("⚙️ HIT SETTINGS NODE")
                    return
                }
                
            }
            
            // Texts
            if let lbl = sceneResults as? SKLabelNode {
                if lbl.text == "Air Control" {
                    gameNavDelegate?.didSelectAir()
                    return
                }else if lbl.text == "Mars" {
                    sceneRenderer.present(SCNScene(named: "Art.scnassets/MarsHab.scn")!, with: .doorsCloseVertical(withDuration: 0.75), incomingPointOfView: nil) {
                        print("Scene Loaded :)")
                        self.gameScene = .MarsColony
                        lbl.text = "Earth"
                    }
                    return
                }else if lbl.text == "Earth" {
                    let nextScene = SCNScene(named: "Art.scnassets/Modeling.scn")!
                    sceneRenderer.present(nextScene, with: .doorsCloseVertical(withDuration: 0.75), incomingPointOfView: nil) {
                        self.scene = nextScene
                        self.loadStationScene()
                        print("Scene Loaded :)")
                        self.gameScene = .SpaceStation
                        lbl.text = "Mars"
                    }
                    return
                }
            }
        }
        
        // Check 3D Scene
        let hitResults = self.sceneRenderer.hitTest(point, options: [:])
        
        for result in hitResults {
            
            // Get the name of the node
            if let modName = result.node.name {
                print("Mod Name: \(modName)")
                
                for mod in modules {
                    if mod.id.uuidString == modName {
                        if let lab = station?.lookupModule(id: mod.id) as? LabModule {
                            LocalDatabase.shared.saveStation(station: station!)
                            print("Lab: \(lab.name)")
                            gameNavDelegate?.didSelectLab(module: lab)
                        }else if let hab = station?.lookupModule(id: mod.id) as? HabModule {
                            gameNavDelegate?.didSelectHab(module: hab)
                        }else if let bio = station?.lookupModule(id: mod.id) as? BioModule {
                            gameNavDelegate?.didSelectBio(module: bio)
                        }else if let lab = station?.lookupModule(id: mod.id) as? Module {
                            print("It is indeed a crude module: [\(lab.type)]")
                            gameNavDelegate?.didChooseModule(name: modName)
                        }
                        
                    }else{
                        print("not a module")
                    }
                }
                
                if modName == "Truss" || "Truss" == result.node.parent?.name {
                    gameNavDelegate?.didSelectTruss(station: self.station!)
                    break
                }
                
                if modName == "Earth" {
                    gameNavDelegate?.didSelectEarth()
                    break
                }
                
                if modName == "Garage" {
                    gameNavDelegate?.didSelectGarage(station: self.station!)
                    break
                }
                
                if modName == "Ship" {
                    gameNavDelegate?.didSelectEarth()
                    break
                }
                
            }
            
            // get its material
            guard let material = result.node.geometry?.firstMaterial else {
                break
            }
            
            // highlight it
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.5
            
            // on completion - unhighlight
            SCNTransaction.completionBlock = {
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.5
                material.emission.contents = SCNColor.black
                SCNTransaction.commit()
            }
            
            material.emission.contents = SCNColor.blue
            
            SCNTransaction.commit()
        }
        
    }
    
    func hitNode2D(node:SKNode) {
        
    }
    
    func hitNode3D(node:SCNNode) {
        
    }
    
    // MARK: - Camera
    
    func didSetCamZ(value: Double) {
        let originalPosition = cameraNode!.position
        
        #if os(macOS)
        let destination = SCNVector3(x: originalPosition.x, y: originalPosition.y, z: CGFloat(value))
        #else
        let destination = SCNVector3(x: originalPosition.x, y: originalPosition.y, z: Float(value))
        #endif
        
//        let destination = SCNVector3(x: originalPosition.x, y: originalPosition.y, z: CGFloat(value))
        cameraNode?.position = destination
    }
    
    func showCameraMenu() {
        print("Should be showing camera menu")
        
        stationOverlay.toggleCamControl()
    }
    
    func hideCameraMenu() {
        print("Hide the camera menu")
        stationOverlay.toggleCamControl()
    }
    
    // MARK: - Updates
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        // Called before each frame is rendered
    }
    
    /// Brings the Earth, to order - Removes the Ship
    func deliveryIsOver() {
        
        guard gameScene == .SpaceStation else { return }
        
        print("Animating ship out of scene")
        
        // Animate the ship out of the scene
        if let ship = scene.rootNode.childNode(withName: "Ship", recursively: true) {
            
            let move = SCNAction.move(by: SCNVector3(0, -10, -3), duration: 5.0)
            let move2 = SCNAction.move(by: SCNVector3(0, -50, -20), duration: 2.0)
            let moveSequence = SCNAction.sequence([move, move2])
            
            let rotate1 = SCNAction.wait(duration: 0.7)
            let rotate2 = SCNAction.rotateBy(x: 180.0 * (.pi/180.0), y: 0, z: 0, duration: 5.0)
            let rotateSequence = SCNAction.sequence([rotate1, rotate2])
            
            ship.runAction(SCNAction.group([moveSequence, rotateSequence])) {
                ship.removeFromParentNode()
            }
            
            // Load Earth
            let earth = SCNScene(named: "Art.scnassets/Earth.scn")!.rootNode.childNode(withName: "Earth", recursively: true)!.clone()
            earth.position = SCNVector3(0, -18, 0)
            earth.opacity = 0
            let appear = SCNAction.fadeIn(duration: 5)
            self.scene.rootNode.addChildNode(earth)
            earth.runAction(appear)
            
        } else {
            print("ERROR - Could not find Delivery Vehicle, A.K.A. Ship")
        }
    }
    
    /// Removes the earth, add the Ship
    func deliveryIsArriving() {
        
        guard gameScene == .SpaceStation else { return }
        stationOverlay.generateNews(string: "📦 Delivery arriving...")
        
        // Remove the earth
        if let earth = scene.rootNode.childNode(withName: "Earth", recursively: true) {
            
            earth.removeFromParentNode()
            
            print("Do you see the earth ?")
            
            
            // Add the Ship
            if let ship = SCNScene(named: "Art.scnassets/Vehicles/DeliveryVehicle.scn")?.rootNode.childNode(withName: "Ship", recursively: true)?.clone() {
                
                ship.name = "Ship"
                ship.position.z = -50
                ship.position.y = -25 // -17.829
                ship.position.x = 0
                ship.eulerAngles = SCNVector3(x:90.0 * (.pi/180.0), y:0, z:0)
                
                scene.rootNode.addChildNode(ship)
                
                let move = SCNAction.move(by: SCNVector3(0, 7, 50), duration: 8.0)
                move.timingMode = .easeInEaseOut
                
                let rotate = SCNAction.rotateBy(x: -90.0 * (.pi/180.0), y: 0, z: 0, duration: 5.0)
                let group = SCNAction.group([move, rotate])
                
                ship.runAction(group, completionHandler: {
                    print("Ship arrived at location")
                    for child in ship.childNodes {
                        child.particleSystems?.first?.birthRate = 0
                    }
                })
            }
        } else {
            print("ERROR - Could not the earth !!!")
        }
    }
    
    /// Updates Which Solar Panels to show on the Truss, and Roboarm
    func updateTruss(station:Station) {
        print("Updating Truss in Scene...")
        //        guard let trussNode = scene.rootNode.childNode(withName: "Truss", recursively: false) else { return }
        
        
        /*
         let solarCount = station.truss.solarPanels.count
         for i in 0..<solarCount {
         let childName = "SolarPanel-00\(i)"
         let solarNode = trussNode.childNode(withName: childName, recursively: false)!
         solarNode.isHidden = false
         }
         */
        
        /*
         if station.unlockedTechItems.contains(.Roboarm) {
         
         print("\n\n\n--- --- --- Adding Roboarm")
         
         
         if let botArmScene = SCNScene(named: "Art.scnassets/SpaceStation/Accessories/Roboarm.scn") {
         print("--- --- --- Adding Roboarm child")
         let botNode = botArmScene.rootNode.childNode(withName: "Roboarm", recursively: false)!.clone()
         botNode.position = SCNVector3(0, 4.39, 0)
         let trussNode = scene.rootNode.childNode(withName: "Truss", recursively: false)!
         trussNode.addChildNode(botNode)
         }
         
         
         }
         */
        
    }
    
    // MARK: - Initializer and Setup
    
    init(sceneRenderer renderer: SCNSceneRenderer) {
        
        sceneRenderer = renderer
        scene = SCNScene(named: "Art.scnassets/SpaceStation/SpaceStation.scn")!
        
        // Database
        let dBase = LocalDatabase.shared
        self.builder = dBase.builder
        self.station = dBase.station
        
        // Debug options
        //    let dbOpt = SCNDebugOptions.showBoundingBoxes
        //    let dbo2 = SCNDebugOptions.showWireframe
        //    let dbo3 = SCNDebugOptions.showLightExtents
        //    let dbo4 = SCNDebugOptions.showLightInfluences
        //    sceneRenderer.debugOptions = [dbo2, dbo4]
        
        // Camera
        let cam = scene.rootNode.childNode(withName: "Camera", recursively: false)!
        self.cameraNode = cam
        
        // Overlay
        let stationOverlay = StationOverlay(renderer: renderer, station: station!, camNode: cam)
        sceneRenderer.overlaySKScene = stationOverlay.scene
        self.stationOverlay = stationOverlay
        
        super.init()
        
        // Load the scene
        self.loadStationScene()
        
        sceneRenderer.delegate = self
        sceneRenderer.scene = scene
        
    }
    
    /// Loads the **Station** Scene
    func loadStationScene() {
        
        self.modules = builder.modules
        
        // FIXME: - ⚠️ Tech Modifications
        // ⚠️ Needs to add:
        
        // Load TechItem scene node, if any
        for tech in station?.unlockedTechItems ?? [] {
            if let node = tech.loadToScene() {
                scene.rootNode.addChildNode(node)
            }
        }
        
        // Deprecate below after implementing above
        // Search Tech Tree for items unlocked, to add to scene
        for tech in station?.unlockedTechItems ?? [] {
            print("Has Tech: \(tech.rawValue)")
            builder.upgradeTech(item: tech)
            
            // Look for items that aren't in the builder...
            switch tech {
                case .Cuppola, .Roboarm, .garage, .module7:
                    print("⚠️ Attention! Needs to add Technology that isn't in the builder...")
                default: continue
            }
        }
        
        // Truss (Solar Panels)
        let trussNode = scene.rootNode.childNode(withName: "Truss", recursively: true)!
        for item in station?.truss.tComponents ?? [] {
            guard let pos = item.getPosition() else { continue }
            guard let eul = item.getRotation() else { continue }
            switch item.allowedType {
                case .Solar:
                    if item.itemID != nil {
                        let solarScene = SCNScene(named: "Art.scnassets/SpaceStation/Accessories/SolarPanel.scn")
                        if let solarPanel = solarScene?.rootNode.childNode(withName: "SolarPanel", recursively: true)?.clone() {
                            solarPanel.position = SCNVector3(pos.x, pos.y, pos.z)
                            solarPanel.eulerAngles = SCNVector3(eul.x, eul.y, eul.z)
                            solarPanel.scale = SCNVector3.init(x: 1.5, y: 2.4, z: 2.4)
                            trussNode.addChildNode(solarPanel)
                        }
                    }
                case .RoboArm: continue
                case .Radiator: continue
            }
        }
        
        // Adds the stuff to the scene (builder unlocked items)
        for node:BuildItem in builder.nodes {
            
            if node.unlocked {
                // Load node
                if let nodeObj = node.loadFromScene() {
                    scene.rootNode.addChildNode(nodeObj)
                    for module in node.children {
                        if module.type == .Module {
                            print("[+] Module \(module.id)")
                        }
                        if let moduleObj = module.loadFromScene() {
                            scene.rootNode.addChildNode(moduleObj)
                        }
                        for peripheral in module.children {
                            print("[-] Peripheral \(module.type), N:\(module.modelInfo.name)")
                            if let periObj = peripheral.loadFromScene() {
                                let obPos = module.modelInfo.position
                                periObj.position = SCNVector3(obPos.x, obPos.y, obPos.z)
                                scene.rootNode.addChildNode(periObj)
                            }
                        }
                    }
                }else{
                    print("Could not load node.")
                }
            } else {
                
                print("--- Node is locked Type:\(node.type), \(node.modelInfo.name), \(node.describe())")
            }
        }
        
        // Earth or ship
        if let order = station?.earthOrder {
            // Load Ship
            print("We have an order! Delivered: \(order.delivered)")
            let ship = scene.rootNode.childNode(withName: "Ship", recursively: false)
            ship?.position.z = -50
            ship?.position.y = -25 // -17.829
            
            #if os(macOS)
            ship?.eulerAngles = SCNVector3(x:90.0 * (.pi/180.0), y:0, z:0)
            #else
            ship?.eulerAngles = SCNVector3(x:90.0 * (Float.pi/180.0), y:0, z:0)
            #endif
            
            let move = SCNAction.move(by: SCNVector3(0, 7, 50), duration: 8.0)
            move.timingMode = .easeInEaseOut
            
            let rotate = SCNAction.rotateBy(x: -90.0 * (.pi/180.0), y: 0, z: 0, duration: 5.0)
            let group = SCNAction.group([move, rotate])
            
            ship?.runAction(group, completionHandler: {
                print("Ship arrived at location")
                for child in ship?.childNodes ?? [] {
                    child.particleSystems?.first?.birthRate = 0
                }
            })
        }else{
            if let ship = scene.rootNode.childNode(withName: "Ship", recursively: false) {
                ship.removeFromParentNode()
            }
            
            // Load Earth
            let earth = SCNScene(named: "Art.scnassets/Earth.scn")!.rootNode.childNode(withName: "Earth", recursively: true)!.clone()
            earth.position = SCNVector3(0, -18, 0)
            
            scene.rootNode.addChildNode(earth)
        }
        
        // NEWS
        // Check Activities
        var newsLines:[String] = []
        if gameScene == .SpaceStation {
            if let labs = station?.labModules {
                for lab in labs {
                    print("*** Found lab: \(lab.id)")
                    if let activity = lab.activity {
                        print("*** Found Activity: \(activity.activityName)")
                        if activity.dateEnds.compare(Date()) == .orderedAscending {
                            let descriptor = "🔬 Completed Lab activities. Check Lab Modules."
                            newsLines.append(descriptor)
                        } else {
                            let descriptor = "⏱ In progress... Lab activity \(activity.activityName). \(activity.dateEnds.timeIntervalSince(Date()))"
                            newsLines.append(descriptor)
                        }
                    }
                }
            }
        }
        
        var newsDelay = 3.0
        if !newsLines.isEmpty {
            for line in newsLines {
                print("*** NEWS ***  (\(newsLines.count)")
                let timeDelay = DispatchTime.now() + newsDelay
                DispatchQueue.main.asyncAfter(deadline: timeDelay) {
                    self.stationOverlay.generateNews(string: line)
                }
                newsDelay += 3.0
            }
        }
        
        // Tell SceneDirector that scene is loaded
        SceneDirector.shared.controllerDidLoadScene(controller: self)
    }
    
    /// Debugs - Prints information about the scene
    func debugScene() {
        print("------")
        print("Scene Debug...\n")
        for node in scene.rootNode.childNodes {
            print("[ ] Node \(node.name ?? "unnamed")")
            for child in node.childNodes {
                print("\t [+] Child \(child.name ?? "unnamed")")
                for grandChild in child.childNodes {
                    print("\t\t [-] GrandKid \(grandChild.name ?? "unnamed")")
                }
            }
        }
        print("End Scene Debug ------\n")
    }

}

// MARK: - Extensions & Helpers

extension TechItems {
    
    /// Loads the Node for Tech Item
    func loadToScene() -> SCNNode? {
        
        switch self {
            // Need to get the models
            case .garage:
                let garageScene = SCNScene(named: "Art.scnassets/Garage.scn")!
                if let garageObj = garageScene.rootNode.childNode(withName:"Garage", recursively: false)?.clone() {
                    let pos = Vector3D(x: 0, y: 0, z: -46)
                    #if os(macOS)
                    garageObj.position = SCNVector3(x: CGFloat(pos.x), y: CGFloat(pos.y), z: CGFloat(pos.z))
                    #else
                    garageObj.position = SCNVector3(pos.x, pos.y, pos.z) //SCNVector3(x: pos.x, y: pos.y, z: pos.z)
                    #endif
                    return garageObj
                }
            case .Cuppola:
                guard let cuppolaScene = SCNScene(named: "Art.scnassets/SpaceStation/Accessories/Cuppola.scn") else { return nil }
                if let cuppolaObject = cuppolaScene.rootNode.childNode(withName: "Cuppola", recursively: true)?.clone() {
                    let pos = Vector3D(x: 0, y: -2, z: -12)
                    cuppolaObject.position = SCNVector3(pos.x, pos.y, pos.z)
                    return cuppolaObject
                }
            case .Roboarm:
                print("\n\n\n Looking for ROBOARM SCENE")
                guard let roboScene = SCNScene(named: "Art.scnassets/SpaceStation/Accessories/Roboarm.scn") else { return nil }
                print("\n\n\n Looking for ROBOARM CHILD")
                if let robot = roboScene.rootNode.childNode(withName: "Roboarm", recursively: true)?.clone() {
                    print("\n\n\n FOUND ROBOARM")
                    let pos = Vector3D(x: 0, y: 4.58, z: 0)
                    robot.position = SCNVector3(pos.x, pos.y, pos.z)
                    return robot
                }
            case .Airlock:
                guard let airlockScene = SCNScene(named: "Art.scnassets/SpaceStation/Accessories/Airlock.scn") else { return nil }
                if let airlockObject = airlockScene.rootNode.childNode(withName: "Airlock", recursively: true)?.clone() {
                    let pos = Vector3D(x: 0, y: 0, z: -12)
                    airlockObject.position = SCNVector3(pos.x, pos.y, pos.z)
                    return airlockObject
                }
            case .GarageArm: return nil
                
            case .module7:
                let moduleScene = SCNScene(named: "Art.scnassets/Module.scn")
                guard let scene = moduleScene else { return nil }
                if let module = scene.rootNode.childNode(withName: "Module", recursively: true)?.clone() {
                    let pos = Vector3D(x: 0, y: -2, z: -12)
                    let angles = Vector3D(x: -180, y: -0, z: 0)
                    module.position = SCNVector3(pos.x, pos.y, pos.z)
                    module.eulerAngles = SCNVector3(CGFloat(GameLogic.radiansFrom(angles.x)), -0, 0)
                    return module
                }
            case .module8:
                let moduleScene = SCNScene(named: "Art.scnassets/Module.scn")
                guard let scene = moduleScene else { return nil }
                if let module = scene.rootNode.childNode(withName: "Module", recursively: true)?.clone() {
                    let pos = Vector3D(x: 0, y: 10, z: -36)
                    let angles = Vector3D(x: -180, y: -0, z: 0)
                    module.position = SCNVector3(pos.x, pos.y, pos.z)
                    module.eulerAngles = SCNVector3(CGFloat(GameLogic.radiansFrom(angles.x)), -0, 0)
                    return module
                }
            case .module9:
                let moduleScene = SCNScene(named: "Art.scnassets/Module.scn")
                guard let scene = moduleScene else { return nil }
                if let module = scene.rootNode.childNode(withName: "Module", recursively: true)?.clone() {
                    let pos = Vector3D(x: 0, y: 0, z: -36)
                    //                    let angles = Vector3D(x: -180, y: -0, z: 0)
                    module.position = SCNVector3(pos.x, pos.y, pos.z)
                    module.eulerAngles = SCNVector3(0, -0, 0)
                    return module
                }
            case .module10: return nil
                
            default: return nil
        }
        
        return nil
    }
}

//extension SCNVector3 {
//    /// Helper to load this object with CGFloat values
//    init(x:CGFloat, y:CGFloat, z:CGFloat) {
//        self.init(x:Float(x), y:Float(y), z:Float(z))
//    }
//}

extension BuildItem {
    
    /// Loads a Node for the `Station` Scene
    func loadFromScene() -> SCNNode? {
        
        switch type {
            case .Node:
                let nodeScene = SCNScene(named: "Art.scnassets/Node.scn")!
                if let nodeObj = nodeScene.rootNode.childNode(withName: "Node2", recursively: false)?.clone() {
                    let pos = self.modelInfo.position
                    #if os(macOS)
                    nodeObj.position = SCNVector3(x: CGFloat(pos.x), y: CGFloat(pos.y), z: CGFloat(pos.z))
                    #else
                    nodeObj.position = SCNVector3(pos.x, pos.y, pos.z) // (x:pos.x, y:pos.y, z:pos.z)
                    #endif
                    
                    return nodeObj
                }else{
                    print("404 not found")
                    return nil
                }
            case .Module:
                let nodeScene = SCNScene(named: "Art.scnassets/Module.scn")!
                if let nodeObj = nodeScene.rootNode.childNode(withName: "Module", recursively: false)?.clone() {
                    
                    let pos = self.modelInfo.position
                    #if os(macOS)
                    nodeObj.position = SCNVector3(x: CGFloat(pos.x), y: CGFloat(pos.y), z: CGFloat(pos.z))
                    #else
                    nodeObj.position = SCNVector3(pos.x, pos.y, pos.z)
                    #endif
                    // Change name to id
                    nodeObj.name = id.uuidString
                    
                    if self.modelInfo.orientation == .Down {
                        print("_+_+_+_+_+ is down vec \(modelInfo.orientation.vector)")
                        let vec = modelInfo.orientation.vector
                        // WARNING - ANGLE NEEDS TO BE IN RADIANS
                        #if os(macOS)
                        nodeObj.eulerAngles = SCNVector3(x: CGFloat(-3.14159), y: CGFloat(vec.y), z: CGFloat(vec.z))
                        #else
                        nodeObj.eulerAngles = SCNVector3(-3.14159, vec.y, vec.z)//SCNVector3(x: -3.14159, y:vec.y, z:vec.z)
                        #endif
                    }
                    
                    return nodeObj
                }else{
                    print("404 not found")
                    return nil
                }
            case .Peripheral:
                print("Loading Peripheral")
                //            if let pType:PeripheralType = PeripheralType(rawValue: self.modelInfo.name) {
                //                print("Peripheral type: \(pType)")
                //                switch pType {
                //                    case .Garage:
                //                    print("Loading garage...")
                //                    let nodeScene = SCNScene(named: "Art.scnassets/Garage.scn")!
                //                    if let nodeObj = nodeScene.rootNode.childNode(withName:"Garage", recursively: false)?.clone() {
                //                        let pos = self.modelInfo.position
                //                        nodeObj.position = SCNVector3(x: CGFloat(pos.x), y: CGFloat(pos.y), z: CGFloat(pos.z))
                //                        return nodeObj
                //                    }
                //                    return nil
                //                    default:
                //                    return nil
                //                }
                //            }
                
                return nil
            //            let nodeScene = SCNScene(named: "Art.scnassets/Peripherals.scn")!
            //                    if let nodeObj = nodeScene.rootNode.childNode(withName: self.modelInfo.name, recursively: false)?.clone() {
            //                        let pos = self.modelInfo.position
            //                        nodeObj.position = SCNVector3(x: CGFloat(pos.x), y: CGFloat(pos.y), z: CGFloat(pos.z))
            //                        return nodeObj
            //                    }else{
            //                        print("404 not found")
            //                        return nil
            //                    }
            default:
                return nil
        }
        
    }
}
