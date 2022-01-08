//
//  GameController.swift
//  SkyNation Shared
//
//  Created by Carlos Farini on 12/18/20.
//

import SceneKit
import SpriteKit
import GameKit

protocol GameNavDelegate {
    
    func didChooseModule(name:String)
    func didSelectLab(module:LabModule)
    func didSelectHab(module:HabModule)
    func didSelectBio(module:BioModule)
    func didSelectTruss(station:Station)
    func didSelectGarage(station:Station)
    
//    func didSelectAir()
    func didSelectLSS(scene:GameSceneType)
    
    func didSelectEarth()
    
    // New
    func didSelectSettings()
    func didSelectMessages()
    func didSelectShopping()
    
    // Mars
    func openCityView(posdex:Posdex, city:DBCity?)
    func openOutpostView(posdex:Posdex, outpost:DBOutpost)
    
    func openGameRoom()
    
}

enum GameSceneType: String, Codable, CaseIterable {
    case SpaceStation
    case MarsColony
}

class GameController: NSObject, SCNSceneRendererDelegate {

    // Views
    var scene: SCNScene
    let sceneRenderer: SCNSceneRenderer
    
    /// The current Scene (Station, or Mars)
    var gameScene:GameSceneType = .SpaceStation
    
    /// An empty Node that controls the camera
    var cameraNode:GameCamera?
    
    /// Shows or hides the camera control node (Menu)
    var camToggle:Bool = false {
        didSet { oldValue == false ? showCameraMenu():hideCameraMenu() }
    }
    
    /// Scene's SpriteKit Overlay
    var gameOverlay:GameOverlay
    
    /// The news (if any) to display sometime during the render
    var newsLines:[String] = []
    
    // Data
    var gameNavDelegate:GameNavDelegate?
    var modules:[Module] = []
    var station:Station?
    var mars:MarsBuilder?
    
    // MARK: - Control
    
    func highlightNodes(atPoint point: CGPoint) {
        
        // Convert the point to the Overlay Scene
        let converted:CGPoint = sceneRenderer.overlaySKScene!.convertPoint(fromView: point)
        
        if GameSettings.debugScene {
            print("Touch Overlay: X:\(Int(converted.x)), Y:\(Int(converted.y)) \t Point: X:\(Int(point.x)), Y:\(Int(point.y))")
        }
        
        // Check Overlay First
        if let node = sceneRenderer.overlaySKScene?.nodes(at: converted).first {
            
            // Sound
            if GameSettings.shared.soundFXOn {
                let action = SKAction.playSoundFileNamed(SoundFX.Selected.soundName, waitForCompletion: false)
                node.run(action)
            }
            
            self.hitNode2D(node: node)
            return
        }
        
        // Check 3D Scene
        let hitResults = self.sceneRenderer.hitTest(point, options: [:])
        
        // MARS
        if self.gameScene == .MarsColony {
            for result in hitResults {
                // Get the name of the node
                if let modName = result.node.name {
                    print("Mod Name: \(modName)")
                    if let parent = result.node.parent {
                        print("Mars Parent: \(parent.name ?? "n/a")")
                        if parent.name == "Cities" || parent.parent?.name == "Cities" {
                            print("Go to city: \(modName)")
                            // get position
//                            let posScene = result.node.position
//                            let posvec = Vector3D(x: Double(posScene.x), y: Double(posScene.y), z: Double(posScene.z))
                            for posdex in Posdex.allCases {
                                if posdex.sceneName == modName || posdex.sceneName == parent.name {
                                    print("Found City! Posdex:\(posdex.rawValue) \(posdex.sceneName)")
                                    if let city = self.mars?.didTap(city: posdex) {
                                        // Open City View
                                        gameNavDelegate?.openCityView(posdex: posdex, city: city)
                                        return
                                    } else {
                                        gameNavDelegate?.openCityView(posdex: posdex, city: nil)
                                        return
                                    }
                                }
                            }
//                            if let city = self.mars?.didTap(city: posde)
//                            gameNavDelegate?.openCityView(position: posvec, name: modName)
//                            print("pos: \(posvec)")
                        } else if parent.name == "Outposts" || parent.parent?.name == "Outposts" || parent.parent?.parent?.name == "Outposts" {
                            print("Go to outpost: \(modName)")
                            for posdex in Posdex.allCases {
                                if posdex.sceneName == modName || posdex.sceneName == parent.name {
                                    print("Found Outpost! Posdex:\(posdex.rawValue) \(posdex.sceneName)")
                                    if let outpost = self.mars?.didTap(on: posdex) {
                                        gameNavDelegate?.openOutpostView(posdex: posdex, outpost: outpost)
                                        return
                                    }
                                    
                                }
                            }
                        }
                    }
                }
            }
            return
        }
        
        // Station Scene
        for result in hitResults {
            
            // Get the name of the node
            if let modName = result.node.name {
                print("Mod Name: \(modName)")
                
                if let mod = modules.filter({ $0.id.uuidString == modName }).first {
                    if let lab = station?.lookupModule(id: mod.id) as? LabModule {
                        gameNavDelegate?.didSelectLab(module: lab)
                        return
                    }else if let hab = station?.lookupModule(id: mod.id) as? HabModule {
                        gameNavDelegate?.didSelectHab(module: hab)
                        return
                    }else if let bio = station?.lookupModule(id: mod.id) as? BioModule {
                        gameNavDelegate?.didSelectBio(module: bio)
                        return
                    }else if let _ = station?.lookupModule(id: mod.id) as? Module {
                        gameNavDelegate?.didChooseModule(name: modName)
                        return
                    }
                }
                
                if modName == "Truss" || "Truss" == result.node.parent?.name {
                    gameNavDelegate?.didSelectTruss(station: self.station!)
                    break
                }
                
                if modName == "Earth" || result.node.parent?.name == "Earth" {
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
        
        let glow = SKAction.colorize(with: SCNColor.systemRed, colorBlendFactor: 0.75, duration: 0.5)
        let fade = SKAction.colorize(with: SCNColor.white, colorBlendFactor: 1.0, duration: 0.5)
        let sequence = SKAction.sequence([glow, fade])
        
        // Images
        if let sprite = node as? SKSpriteNode {
            
            // Glow red
            sprite.run(sequence)
            
            // Life support systems (Air Control)
            if sprite.name == "Air Control" {
                switch gameScene {
                    case .SpaceStation:
                        
                        // LSS
                        gameNavDelegate?.didSelectLSS(scene: self.gameScene)
                        // Clear Overlay Badge
                        gameOverlay.sideMenuNode?.clearLSSBadge()
                        
                    case .MarsColony:
                        if let city = mars?.didSelectAirButton() {
                            print("Show city status here. \(city.posdex)")
                            gameNavDelegate?.didSelectLSS(scene: self.gameScene)
                            
                        } else {
                            self.gameOverlay.generateNews(string: "You need to claim a city to view LSS report.")
                        }
                }
                
                return
            }
            
            // Camera Rotations
            if sprite.name == "chevron.right.square" {
                
                self.moveToNextCamera()
                
                if let camControl = sprite.parent as? CamControlNode {
                    
                    // Update the camcontrol.
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        camControl.updatePOV()
                    }
                }
                return
            }
            
            if sprite.name == "chevron.backward.square" {
                
                self.moveToPreviousCamera()
                if let camControl = sprite.parent as? CamControlNode {
                    
                    // Update the camcontrol.
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        camControl.updatePOV()
                    }
                }
                return
            }
            
            if sprite.name == "CameraIcon" {
                camToggle.toggle()
            }
            
            // Buttons Underneath Player
            // Tutorial button
            if sprite.name == "tutorial" {
                print("🎓 TUTORIAL NODE")
                self.gameOverlay.showTutorial()
                return
            }
            if sprite.name == "settings" {
                gameNavDelegate?.didSelectSettings()
                return
            }
            if sprite.name == "ShopButton" {
                gameNavDelegate?.didSelectShopping()
                return
            }
            
            // Side Menu Buttons
            if sprite.name == "GameRoomButton" {
                gameNavDelegate?.openGameRoom()
                gameOverlay.sideMenuNode?.clearGameRoomBadge()
                return
            }
            
            // Guild Room
            if sprite.name == "ChatButton" {
                gameNavDelegate?.didSelectMessages()
                gameOverlay.sideMenuNode?.clearGuildBadge()
                return
            }
            
            // Mars
            if sprite.name == "MarsButton" {
                self.switchScene()
                return
            }
            
            // Tutorial Hand
            if sprite.name == "TapHand" {
                
                // Tapped on hand. Open the first available module (not used)
                guard let station = station else {
                    return
                }
                let occupiedIDs:[UUID] = station.habModules.compactMap({ $0.id }) + station.labModules.compactMap({ $0.id }) + station.bioModules.compactMap({ $0.id })
                guard let moduleA = station.modules.first(where: { occupiedIDs.contains($0.id) == false }) else {
                    print("All modules are occupied")
                    newsLines.append("All modules are occupied")
                    return
                }
                if let _ = station.lookupModule(id: moduleA.id) as? Module {
                    gameNavDelegate?.didChooseModule(name: moduleA.id.uuidString)
                    sprite.isHidden = true
                    sprite.removeFromParent()
                    return
                } else {
                    newsLines.append("⚠️ Unable to locate a vacant module.")
                    sprite.isHidden = true
                    sprite.removeFromParent()
                    return
                }
            }
            
        } else {
            if let labelNode = node as? SKLabelNode {
                print("Label \(labelNode.text ?? "n/a")")
                if labelNode.text == "Next ➡️" {
                    gameOverlay.proceedTutorial()
                } else if labelNode.text == "❌ Close" {
                    gameOverlay.closeTutorial()
                }
            }
            if let shapeNode = node as? SKShapeNode {
                print("Shape Node: \(shapeNode)")
            }
        }
    }
    
    func hitNode3D(node:SCNNode) {
        
    }
    
    // MARK: - Camera
    
    func showCameraMenu() {
        gameOverlay.toggleCamControl()
    }
    
    func hideCameraMenu() {
        gameOverlay.toggleCamControl()
    }
    
    func moveToNextCamera() {
        
        switch gameScene {
            case .MarsColony:
                
                cameraNode?.moveToNextPOV()
                if let pov = cameraNode?.currentPOV {
                    print("Moved to POV: \(pov.name)")
                }
                
            case .SpaceStation:
                
                cameraNode?.moveToNextPOV()
                if let pov = cameraNode?.currentPOV {
                    print("Moved to POV: \(pov.name)")
                }
                
                // Save preferred camera on settings?
        }
    }
    
    func moveToPreviousCamera() {
        
        switch gameScene {
            case .MarsColony:
                
                cameraNode?.moveToPreviousPOV()
                if let pov = cameraNode?.currentPOV {
                    print("Moved to POV: \(pov.name)")
                }
                
            case .SpaceStation:
                
                // Get the builder
                cameraNode?.moveToPreviousPOV()
                if let pov = cameraNode?.currentPOV {
                    print("Moved to POV: \(pov.name)")
                }
                
            // Save preferred camera on settings?
        }
    }
    
    // Sounds
    /// Coordinates the music playing
    func playMusic() {
        // Music
        if GameSettings.shared.musicOn {
            // Play a random track
            let track = Soundtrack.allCases.randomElement() ?? .MainTheme
            if let source = SCNAudioSource(fileNamed: track.fileName) {
                source.volume = 0.5
                let action = SCNAction.playAudio(source, waitForCompletion: true)
                scene.rootNode.runAction(action) {
                    // music finished
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                        self.playMusic()
                    }
                }
            }
        }
    }
    
    // MARK: - Updates
    
    var shouldUpdateScene:Bool = false
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
        // Called before each frame is rendered
        let rounded = time.rounded()
        if time < 5 { return }
        
        if rounded.truncatingRemainder(dividingBy: 20) == 0 {
            
            // 97 is the largest prime before 100
            if shouldUpdateScene {
                shouldUpdateScene = false
                
                switch self.gameScene {
                    case .SpaceStation:
                        print("⏱ Station Update: \(rounded)")
                        
                        station?.accountingLoop(recursive: false) { (messages) in
                            
                            DispatchQueue.main.async {
//                                print("\(messages.first ?? "n/a")")
                                
                                // Update Player Card
                                self.gameOverlay.updatePlayerCard()
                                
                                // Tutorial hand
                                if LocalDatabase.shared.player.experience < 1 {
                                    self.checkBeginnersHandTutorial()
                                }
                                
                                if self.newsLines.isEmpty == false {
                                    print("*** NEWS ***  (\(self.newsLines.count))")
                                    if let currentNews = self.newsLines.first {
                                        self.gameOverlay.generateNews(string: currentNews)
                                        self.newsLines.removeFirst()
                                    }
                                }
                            }
                        }
                        
                    case .MarsColony:
                        
                        if let myCity:CityData = self.mars?.myCityData {
                            print("⏱ My City Update: \(rounded)")
                            
                            myCity.accountingLoop(recursive: false) { messages in
                                
//                                print("\(messages.first ?? "n/a")")
                                DispatchQueue.main.async {
                                    
                                    // Update Player Card
                                    self.gameOverlay.updatePlayerCard()
                                    
                                    // News
                                    if self.newsLines.isEmpty == false {
                                        print("*** NEWS ***  (\(self.newsLines.count))")
                                        if let currentNews = self.newsLines.first {
                                            self.gameOverlay.generateNews(string: currentNews)
                                            self.newsLines.removeFirst()
                                        }
                                    }
                                }
                            }
                        }
                        
                        return
                }
            }
        } else {
            shouldUpdateScene = true
        }
    }
    
    /// Brings the Earth, to order - Removes the Ship
    func deliveryIsOver() {
        
        guard gameScene == .SpaceStation else { return }
        
        print("Animating ship out of scene")
        
        // Animate the ship out of the scene
        if let ship = scene.rootNode.childNode(withName: "Ship", recursively: false) as? DeliveryVehicleNode {
            
            // Remove Delivery Vehicle
            ship.beginExitAnimation()
            
            // Load Earth
            let earth = EarthNode()
            scene.rootNode.addChildNode(earth)
            
            earth.beginEntryAnimation()
            
            
        } else {
            print("ERROR - Could not find Delivery Vehicle, A.K.A. Ship")
        }
    }
    
    /// Removes the earth, add the Ship
    func deliveryIsArriving() {
        
        guard gameScene == .SpaceStation else { return }
        gameOverlay.generateNews(string: "📦 Delivery arriving...")
        
        // Remove the earth
        if let earth = scene.rootNode.childNode(withName: "Earth", recursively: true) as? EarthNode {
            
            earth.beginExitAnimation()
            print("Earth going, Ship arriving")
            
            
            // Load Ship
            var ship:DeliveryVehicleNode? = DeliveryVehicleNode()
            ship?.position.z = -50
            ship?.position.y = -50 // -17.829
            scene.rootNode.addChildNode(ship!)
            
            #if os(macOS)
            ship?.eulerAngles = SCNVector3(x:90.0 * (.pi/180.0), y:0, z:0)
            #else
            ship?.eulerAngles = SCNVector3(x:90.0 * (Float.pi/180.0), y:0, z:0)
            #endif
            
            // Move
            let move = SCNAction.move(by: SCNVector3(0, 30, 50), duration: 12.0)
            move.timingMode = .easeInEaseOut
            
            // Kill Engines
            let killWaiter = SCNAction.wait(duration: 6)
            let killAction = SCNAction.run { shipNode in
                print("Kill Waiter")
                ship?.killEngines()
            }
            let killSequence = SCNAction.sequence([killWaiter, killAction])
            
            let rotate = SCNAction.rotateBy(x: -90.0 * (.pi/180.0), y: 0, z: 0, duration: 5.0)
            let group = SCNAction.group([move, rotate, killSequence])
            
            ship?.runAction(group, completionHandler: {
                print("Ship arrived at location")
                for child in ship?.childNodes ?? [] {
                    child.particleSystems?.first?.birthRate = 0
                }
            })
            
        } else {
            print("ERROR - Could not the earth !!!")
            
            
            
        }
    }
    
    /// Updates Which Solar Panels to show on the Truss, and Roboarm
    func updateTrussLayout() {
        
        // Truss (Solar Panels)
        print("Truss Layout Update:")
        let trussNode = scene.rootNode.childNode(withName: "Truss", recursively: true)!
        
        // Delete Previous Solar Panels
        for child in trussNode.childNodes {
            if child.name == "SolarPanel" {
                print("Removing old solar panel")
                child.removeFromParentNode()
            }
        }
        
        for item in station?.truss.tComponents ?? [] {
            print("Truss Component: \(item.posIndex)")
            guard let pos = item.getPosition() else { continue }
            guard let eul = item.getRotation() else { continue }
            switch item.allowedType {
                case .Solar:
                    if item.itemID != nil {
                        print("Solar Panel: \(item.posIndex) pos:\(pos), euler:\(eul)")
                        let solarScene = SCNScene(named: "Art.scnassets/SpaceStation/Accessories/SolarPanel2.scn")
                        if let solarPanel = solarScene?.rootNode.childNode(withName: "SolarPanel", recursively: true)?.clone() {
                            solarPanel.position = SCNVector3(pos.x, pos.y, pos.z)
                            solarPanel.eulerAngles = SCNVector3(eul.x, eul.y, eul.z)
                            solarPanel.scale = SCNVector3.init(x: 1.5, y: 2.4, z: 2.4)
                            trussNode.addChildNode(solarPanel)
                        }
                    }
                case .Radiator:
                    print("Radiator slot: \(item.posIndex) pos:\(pos), euler:\(eul)")
                    if item.itemID != nil {
                        print("Radiator: \(item.posIndex) pos:\(pos), euler:\(eul)")
                        let radiatorNode = RadiatorNode()
                        radiatorNode.position = SCNVector3(pos.x, pos.y, pos.z)
                        radiatorNode.eulerAngles = SCNVector3(eul.x, eul.y, eul.z)
                        radiatorNode.scale = SCNVector3.init(x: 1.5, y: 1.5, z: 1.5)
                        radiatorNode.setupAngles(new: nil)
                        trussNode.addChildNode(radiatorNode)
                    } else {
                        continue
                    }
                case .RoboArm: continue
                
            }
        }
    }
    
    // MARK: - Scene Transitions
    
    private func verifyMarsEntry(player:SKNPlayer) -> Bool {
        
        var enter:Bool = false
        print("Requesting Player entry...")
        let entryResult = player.marsEntryPass()
        if entryResult.result == false {
            if let entryToken = entryResult.token {
                if let r2 = player.requestEntryToken(token: entryToken) {
                    print("Found an Entry ticket \(r2.date)")
                    enter = true
                }
            }
        } else {
            print("Entry OK: \(entryResult.token?.id.uuidString ?? "n/a")")
            enter = true
        }
        return enter
    }
    
    /// Loads the scene that is not being displayed, and presents them
    func switchScene() {
        
        let player = LocalDatabase.shared.player
        
        switch gameScene {
            
            // Loading Mars from Space Station
            case .SpaceStation:
                
                // Verify Player has .Entry token
                let enter = self.verifyMarsEntry(player: player)
                guard enter == true else {
                    print("No Entry")
                    
                    let line1 = "⚠️ Player needs an entry ticket to Mars"
                    let line2 = "🛒 Head to the store and purchase any product."
                    let line3 = "---"
                    
                    let lines:[String] = [line1, line2, line3]
                    var newsDelay = 1.0
                    for line in lines {
                        let timeDelay = DispatchTime.now() + newsDelay
                        DispatchQueue.main.asyncAfter(deadline: timeDelay) {
                            self.gameOverlay.generateNews(string: line)
                        }
                        newsDelay += 5
                    }
                    
                    return
                }
                
                // Verify Player has Guild
                let mBuilder = MarsBuilder.shared
                guard mBuilder.hasNoGuild == false else {
                    print("No Entry")
                    
                    let line1 = "⚠️ Player has no Guild."
                    let line2 = "This could happen if you haven't joined a guild"
                    let line3 = "Or because you were booted 👢"
                    let lines:[String] = [line1, line2, line3]
                    var newsDelay = 1.0
                    for line in lines {
                        let timeDelay = DispatchTime.now() + newsDelay
                        DispatchQueue.main.asyncAfter(deadline: timeDelay) {
                            self.gameOverlay.generateNews(string: line)
                        }
                        newsDelay += 5
                    }
                    
                    return
                }
                
                // City Accounting
                if let myCity:CityData = LocalDatabase.shared.cityData {
                    DispatchQueue(label: "Accounting").async {
                        myCity.accountingLoop(recursive: true) { messages in
                            print("\(messages.first ?? "n/a")")
                        }
                    }
                }
                
                // Gather the nodes and build the scene
                let newScene:SCNScene = mBuilder.populateScene()
                
                // Camera Setup
                guard let cam:GameCamera = newScene.rootNode.childNode(withName: "Camera", recursively: false) as? GameCamera else {
                    fatalError()
                }
                
                // Update Overlay
                gameOverlay.didChangeScene(camNode: cam)
                
                // Present Scene
                self.sceneRenderer.present(newScene, with: .doorsCloseVertical(withDuration: 1.0), incomingPointOfView: cam.camNode) { // newGameCam.camNode
                    
                    self.scene = newScene
                    self.sceneRenderer.pointOfView = cam.camNode
                    
                    print("Mars Scene Loaded :)")
                    self.gameScene = .MarsColony
                    self.mars = mBuilder
                    
                    self.cameraNode = cam
                    
                    // Entry Animation
                    cam.position.y += 40
                    let waiter = SCNAction.wait(duration: 1.0)
                    let move1 = SCNAction.move(by: SCNVector3(0, -20, 0), duration: 0.75)
                    move1.timingMode = .easeIn
                    let move2 = SCNAction.move(by: SCNVector3(0, -20, 0), duration: 0.75)
                    move2.timingMode = .easeOut
                    let sequence = SCNAction.sequence([waiter, move1, move2])
                    
                    cam.runAction(sequence) {
                        print("CamChild LOOK @ \(cam.eulerAngles)")
                    }
                }
                
            // Loading Space Station from Mars
            case .MarsColony:
                print("We are in Mars. Load Space Station")
                guard let station = station else {
                    return
                }
                print("Station Reloaded.: \(station.accountingDate)")
                
                let newStation = LocalDatabase.shared.station
                let newBuilder = StationBuilder(station: newStation)
                
                newBuilder.prepareScene(station: newStation) { stationScene in
                    
                    if let camera = stationScene.rootNode.childNode(withName: "Camera", recursively: false) as? GameCamera {
                        self.gameOverlay.didChangeScene(camNode: camera)
                        self.sceneRenderer.present(stationScene, with: .doorsOpenVertical(withDuration: 1.0), incomingPointOfView: camera.camNode) {
                            self.scene = stationScene
                            self.gameScene = .SpaceStation
                            self.cameraNode = camera
                            // Tell SceneDirector that scene is loaded
                            SceneDirector.shared.controllerDidLoadScene(controller: self)
                        }
                    }
                }
        }
    }
    
    // MARK: - Initializer and Setup
    
    init(sceneRenderer renderer: SCNSceneRenderer) {
        
        sceneRenderer = renderer
        
        // Database
        let dBase = LocalDatabase.shared
        self.station = dBase.station
        
        // Debug options
        //    let dbOpt = SCNDebugOptions.showBoundingBoxes
        //    let dbo2 = SCNDebugOptions.showWireframe
        //    let dbo3 = SCNDebugOptions.showLightExtents
        //    let dbo4 = SCNDebugOptions.showLightInfluences
        //    sceneRenderer.debugOptions = [dbo2, dbo4]
        
        guard let builtScene = LocalDatabase.shared.stationBuilder.scene else { fatalError() }
        
        self.scene = builtScene
        
        // Camera
        if let camera = scene.rootNode.childNode(withName: "Camera", recursively: false) as? GameCamera {
            self.cameraNode = camera
            renderer.pointOfView = camera.camNode
            
            let centralNode = SCNNode()
            centralNode.position = SCNVector3(x: 0, y: -15, z: 0)
            camera.camNode.look(at: centralNode.position)
            
            camera.position.z += 40
            
            let waiter = SCNAction.wait(duration: 3.0)
            // let rotate = SCNAction.rotate(by: CGFloat(Double.pi / 8), around: SCNVector3(x: 0, y: 1, z: 0), duration: 2)
            // rotate.timingMode = .easeOut
            let move1 = SCNAction.move(by: SCNVector3(-1, 6, -20), duration: 0.75)
            move1.timingMode = .easeIn
            let move2 = SCNAction.move(by: SCNVector3(1, -6, -20), duration: 0.75)
            move2.timingMode = .easeOut
            
            let sequence = SCNAction.sequence([waiter, move1, move2])
            
            camera.runAction(sequence) {
                print("CamChild LOOK @ \(camera.eulerAngles)")
            }
        }
        
        // Overlay
        let stationOverlay = GameOverlay(renderer: renderer, station: station!, camNode: self.cameraNode!)
        sceneRenderer.overlaySKScene = stationOverlay.scene
        self.gameOverlay = stationOverlay
        
        super.init()
        // After INIT
        
        self.modules = station?.modules ?? []
        
        // News
        self.prepareNews()
        
        // Tell SceneDirector that scene is loaded
        SceneDirector.shared.controllerDidLoadScene(controller: self)
        
        sceneRenderer.delegate = self
        sceneRenderer.scene = scene
        
        playMusic()
        
        // Fetch Mars Data?
        _ = MarsBuilder.shared
        
    }
    
    /// Reloads the Station Scene with new tech items
    func loadLastBuildItem() {
        print("Loading last build item")
        let builder = LocalDatabase.shared.reloadBuilder(newStation: self.station)
        let lastTech = builder.buildList.last
        if let theNode = lastTech?.loadFromScene() {
            print("Found node to build last tech item: \(theNode.name ?? "n/a")")
            if lastTech?.type == .Module {
                if let lastModule = LocalDatabase.shared.station.modules.last {
                    self.modules.append(lastModule)
                    theNode.name = lastModule.id.uuidString
                }
            }
            scene.rootNode.addChildNode(theNode)
        }
    }
    
    /// Prepares Overlay's news and shows them one by one, every few seconds
    func prepareNews() {
        // NEWS
        var hasChanges:Bool = false
        
        // Check Scenes for News
        switch gameScene {
                
            case .SpaceStation:
                
                guard let station = station else { return }
                
                // Beginners Guide
                if station.habModules.count < 1 {
                    newsLines.append("Tap on a Module (see hand) and create your first Hab Module.")
                } else if station.labModules.count < 1 {
                    newsLines.append("Tap on a Module (see hand) and create your first Lab Module.")
                } else if station.getPeople().count < 1 {
                    newsLines.append("Tap on the Earth, to order items for your Space Station.")
                }
                
                // Lab activities
                let labs = station.labModules
                for lab in labs {
                    print("*** Found lab: \(lab.id)")
                    if let activity = lab.activity {
                        print("*** Found Activity: \(activity.activityName)")
                        if activity.dateEnds.compare(Date()) == .orderedAscending {
                            let descriptor = "🔬 Completed Lab activity - Check Lab Modules."
                            newsLines.append(descriptor)
                        } else {
                            let descriptor = "⏱ Lab: \(activity.activityName). \(Int(activity.dateEnds.timeIntervalSince(Date()))) s"
                            newsLines.append(descriptor)
                        }
                    }
                }
                
                
                // Hab Activities
                let habs = station.habModules
                let people = habs.flatMap({$0.inhabitants})
                for person in people {
                    if let activity = person.activity {
                        if activity.dateEnds.compare(Date()) == .orderedAscending {
                            let moji = person.gender == "male" ? "🙋‍♂️":"🙋‍♀️"
                            let descriptor = "\(moji) \(person.name) completed activity \(activity.activityName)."
                            newsLines.append(descriptor)
                            person.clearActivity()
                            hasChanges = true
                        }
                    }
                }
                
                // Other issues includes Water, Oxygen, Food, and Air Quality
                let otherIssues = station.reportLSSIssues()
                gameOverlay.sideMenuNode?.updateLSS(issues: otherIssues)
                newsLines.append(contentsOf: otherIssues)
                
            case .MarsColony:
                
                let builder = MarsBuilder.shared
                let gMap = builder.guildMap
                if let city = LocalDatabase.shared.cityData {
                    if gMap?.cities.contains(where: { $0.id == city.id }) == true {
                        // Lab activities
                        if let activity = city.labActivity {
                            print("*** Found Activity: \(activity.activityName)")
                            if activity.dateEnds.compare(Date()) == .orderedAscending {
                                let descriptor = "🔬 Completed Lab activity - Check Lab Modules."
                                newsLines.append(descriptor)
                            } else {
                                let descriptor = "⏱ Lab: \(activity.activityName). \(Int(activity.dateEnds.timeIntervalSince(Date()))) s"
                                newsLines.append(descriptor)
                            }
                        }
                        
                        // Hab Activities
                        for person in city.inhabitants {
                            if let activity = person.activity {
                                if activity.dateEnds.compare(Date()) == .orderedAscending {
                                    let moji = person.gender == "male" ? "🙋‍♂️":"🙋‍♀️"
                                    let descriptor = "\(moji) \(person.name) completed activity \(activity.activityName)."
                                    newsLines.append(descriptor)
                                    person.clearActivity()
                                }
                            }
                        }
                        
                        // Air Quality
                        let qt:[AirQuality] = [.Lethal, .Bad]
                        if qt.contains(city.air.airQuality()) {
                            newsLines.append("⚠️ Air quality is bad.")
                        }
                        
                        // Energy
                        let energy = city.batteries.compactMap({ $0.current }).reduce(0, +)
                        if energy < 10 {
                            newsLines.append("⚡️ City is low on energy: \(energy) kW")
                        }
                    }
                }
        }
        
        // GameKit's Badge
        
        GKAccessPoint.shared.location = .topTrailing
        GKAccessPoint.shared.showHighlights = true
        GKAccessPoint.shared.isActive = true
        
        
        // Save if needed
        if hasChanges {
            if let station = self.station {
                print("Will save station")
                // Save
                do {
                    try LocalDatabase.shared.saveStation(station)
                } catch {
                    print("‼️ Could not save station.: \(error.localizedDescription)")
                }
            }
        }
    }
    
    /// Hand, Finger Tutorial
    func checkBeginnersHandTutorial() {
        
        guard let station = station else {
            return
        }
        
        let occupiedIDs:[UUID] = station.habModules.compactMap({ $0.id }) + station.labModules.compactMap({ $0.id }) + station.bioModules.compactMap({ $0.id })
    
        guard let moduleA = station.modules.first(where: { occupiedIDs.contains($0.id) == false }) else {
            print("All modules are occupied")
            return
        }
        
        if LocalDatabase.shared.player.experience > 10 {
            if GameSettings.shared.showTutorial == false {
                return
            }
        }
        
        // Get the Hand Sprite
        var handSprite:SKSpriteNode?
        if let oldHand = gameOverlay.scene.childNode(withName: "TapHand") as? SKSpriteNode {
            handSprite = oldHand
            handSprite?.isHidden = false
        } else {
            let spriteTexture = SKTexture(imageNamed: "TapHand")
            let newHand = SKSpriteNode(texture: spriteTexture, color: .white, size: CGSize(width: 128, height: 128))
            newHand.anchorPoint = CGPoint(x: 0.3, y: 0.8)
            newHand.name = "TapHand"
            newHand.zPosition = 99
            gameOverlay.scene.addChild(newHand)
            handSprite = newHand
        }
        guard let handSprite = handSprite else {
            fatalError("Missing hand")
        }
        
        let habCount = station.habModules.count
        let labCount = station.labModules.count
        
        // Check 🏠 HAB Modules
        if habCount == 0 {
            // Hab Module Tutorial
            guard let node3 = scene.rootNode.childNode(withName: moduleA.id.uuidString, recursively: true) else {
                fatalError("No such name")
            }
            
            // GET THE POSITION
            let handPosition = convertSceneToOverlay(node: node3)
            handSprite.position = handPosition
            
            // Beginners Guide
            newsLines.append("Tap on a Module to create your first 🏠 Hab")
            
            
        } else if labCount == 0 {
            // Lab Module Tutorial
            guard let node3 = scene.rootNode.childNode(withName: moduleA.id.uuidString, recursively: true) else {
                fatalError("No such name")
            }
            
            // GET THE POSITION
            let handPosition = convertSceneToOverlay(node: node3)
            handSprite.position = handPosition
            
            newsLines.append("Tap on a Module to create your first 🔬 Lab")
            
        } else {
            
            let pplCount = station.habModules.flatMap({ $0.inhabitants }).count
            if pplCount == 0 {
                // Earth Order Tutorial
                let people = station.habModules.flatMap({ $0.inhabitants })
                if people.isEmpty {
                    if let earth = scene.rootNode.childNode(withName: "Earth", recursively: true) as? EarthNode {
                        
                        let earthPosition:CGPoint = convertSceneToOverlay(node: earth)
                        handSprite.position = earthPosition
                        
                        newsLines.append("Tap on the Globe 🌎 to order items for your Space Station.")
                    }
                }
            } else {
                // Remove Finger
                print("Removing Finger")
                if let oldHand = gameOverlay.scene.childNode(withName: "TapHand") as? SKSpriteNode {
                    oldHand.isHidden = true
                    oldHand.removeFromParent()
                    return
                }
            }
        }

        print("👆 Making beginners hand")
        
        let scale1 = SKAction.scale(by: 0.85, duration: 0.6)
        let scale2 = SKAction.scale(by: 1.15, duration: 0.6)
        let waiter = SKAction.wait(forDuration: 0.4)
        let sequence = SKAction.sequence([scale1, waiter, scale2, waiter, scale1, waiter, scale2])
        
        if !handSprite.hasActions() {
            handSprite.run(sequence)
        } else {
            print("Already animating")
        }
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
                    print("\t\t [-] GrandKid \(grandChild.name ?? "unnamed") Plus \(grandChild.childNodes.count) descendants.")
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
                let garageScene = SCNScene(named: "Art.scnassets/SpaceStation/Garage4.scn")!
                if let garageObj = garageScene.rootNode.childNode(withName:"Garage", recursively: true)?.clone() {
                    let pos = Vector3D(x: 0, y: 0, z: -42)
                    #if os(macOS)
                    garageObj.position = SCNVector3(x: CGFloat(pos.x), y: CGFloat(pos.y), z: CGFloat(pos.z))
                    #else
                    garageObj.position = SCNVector3(pos.x, pos.y, pos.z) //SCNVector3(x: pos.x, y: pos.y, z: pos.z)
                    #endif
                    return garageObj
                }
            case .Cuppola:
                guard let cuppolaScene = SCNScene(named: "Art.scnassets/SpaceStation/Accessories/Cuppola2.scn") else { return nil }
                if let cuppolaObject = cuppolaScene.rootNode.childNode(withName: "Cuppola", recursively: true)?.clone() {
                    let pos = Vector3D(x: 0, y: -2, z: -12)
                    cuppolaObject.position = SCNVector3(pos.x, pos.y, pos.z)
                    return cuppolaObject
                }
            case .Roboarm:
                
                let robNode = RoboArmNode()
                let pos = Vector3D(x: 0, y: 4.58, z: 0)
                robNode.position = SCNVector3(pos.x, pos.y, pos.z)
                
                return robNode
                
            case .Airlock:
                guard let airlockScene = SCNScene(named: "Art.scnassets/SpaceStation/Accessories/Airlock2.scn"),
                let airlockObject = airlockScene.rootNode.childNode(withName: "Airlock", recursively: true)?.clone() else { return nil }
                let pos = Vector3D(x: 0, y: 0, z: -12)
                airlockObject.position = SCNVector3(pos.x, pos.y, pos.z)
                
                if let child = airlockObject.childNodes.first {
                    let openDoor = SCNAction.rotate(by: GameLogic.radiansFrom(-90), around: SCNVector3(x: 0, y: 1, z: 0), duration: 2.5)
                    let waiter = SCNAction.wait(duration: 8.5)
                    let closeDoor = SCNAction.rotate(by: GameLogic.radiansFrom(90), around: SCNVector3(x: 0, y: 1, z: 0), duration: 2.5)
                    let sequence = SCNAction.sequence([waiter, openDoor, waiter, closeDoor, waiter, waiter])
                    let repeatable = SCNAction.repeatForever(sequence)
                    child.runAction(repeatable)
                }
                return airlockObject
            case .GarageArm: return nil
                
            default: return nil
        }
        
        return nil
    }
}

extension StationBuildItem {
    
    func loadFromScene() -> SCNNode? {
        var nodeCount:Int = 1
        switch type {
            case .Node:
//                print("Load a node")
                let nodeScene = SCNScene(named: "Art.scnassets/SpaceStation/Node.scn")!
                if let nodeObj = nodeScene.rootNode.childNode(withName: "Node2", recursively: false)?.clone() {
                    nodeObj.name = "Node\(nodeCount)"
                    nodeCount += 1
                    let pos = position
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

                let moduleScene = SCNScene(named: "Art.scnassets/SpaceStation/Module.scn")!
                if let nodeObj = moduleScene.rootNode.childNode(withName: "Module", recursively: false)?.clone() {
                    
                    let uvMapName = "\(skin?.uvMapName ?? ModuleSkin.allCases.randomElement()!.uvMapName).png"
                    
                    // MATERIAL | SKIN
                    
                    var skinImage:SKNImage?
                    if let bun = Bundle.main.url(forResource: "Art", withExtension: ".scnassets") {
                        let pp = bun.appendingPathComponent("/UV Images/ModuleSkins/\(uvMapName)")
                        if let image = SKNImage(contentsOfFile: pp.path) {
//                            print("Found Image")
                            skinImage = image
                        } else {
                            print("\n\t ⚠️ Error: Could not find Skin Image!")
                        }
                    } else {
                        print("\n\t ⚠️ Error: Bundle for Skin not found !")
                    }
                    for material in nodeObj.geometry?.materials ?? [] {
                        print("Material name:\(material.name ?? "n/a")")
                        if let image = skinImage {
                            material.diffuse.contents = image
                        }
                    }
                    if let image = SKNImage(named: uvMapName) {
                        nodeObj.geometry!.materials.first!.diffuse.contents = image
                    }
                    
                    // Position
                    let pos = position
                    #if os(macOS)
                    nodeObj.position = SCNVector3(x: CGFloat(pos.x), y: CGFloat(pos.y), z: CGFloat(pos.z))
                    #else
                    nodeObj.position = SCNVector3(pos.x, pos.y, pos.z)
                    #endif
                    // Change name to id
                    nodeObj.name = id.uuidString
                    
                    let vec = rotation
                    let sceneVec = SCNVector3(vec.x, vec.y, vec.z)
                    nodeObj.eulerAngles = sceneVec
                    
                    return nodeObj
                } else {
                    print("Module not found ID:\(id) \(self.type) ")
                    return nil
                }
            case .Peripheral, .Truss:
                print("Deprecate ?")
                return nil
        }
    }
}
