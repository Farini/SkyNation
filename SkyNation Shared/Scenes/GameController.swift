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
    var introStage:Station.IntroTutorialStage = .intro
    
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
        
        switch gameScene {
            case .SpaceStation:
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
                        
                        let r = result.worldCoordinates
                        cameraNode?.stareAt(node: result.node, located: r)
                        gameOverlay.addNews(data: NewsData(type: .Info, message: "Object: \(modName)", date: nil))
                    }
                    
                    // get its material
                    guard let material = result.node.geometry?.firstMaterial else {
                        break
                    }
                    
                    /*
                     // this isnt working well
                    let outlineProgram = SCNProgram()
                    outlineProgram.vertexFunctionName = "outline_vertex"
                    outlineProgram.fragmentFunctionName = "outline_fragment"
                    material.program = outlineProgram
                    // material.cullMode = .front
                    */
                    
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
            case .MarsColony:
                // Mars
                for result in hitResults {
                    // Get the name of the node
                    if let modName = result.node.name {
                        print("Mod Name: \(modName)")
                        if let parent = result.node.parent {
                            print("Mars Parent: \(parent.name ?? "n/a")")
                            
                            if parent.name == "Cities" || parent.parent?.name == "Cities" {
                                print("Go to city: \(modName)")
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
                            // self.gameOverlay.generateNews(string: "You need to claim a city to view LSS report.")
                            self.gameOverlay.addNews(data: NewsData(type: .Info, message: "You need to claim a city to view LSS report.\nClick on a gate of an occupied city.\nThese gates have a darker color.\nThen click 'claim city'. You should be done.", date: nil))
                        }
                }
                
                return
            }
            
            // Camera + Control
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
//                    newsLines.append("All modules are occupied")
                    self.gameOverlay.addNews(data: NewsData(type: .Info, message: "all modules are occupied", date: nil))
                    return
                }
                if let _ = station.lookupModule(id: moduleA.id) as? Module {
                    gameNavDelegate?.didChooseModule(name: moduleA.id.uuidString)
                    sprite.isHidden = true
                    sprite.removeFromParent()
                    return
                } else {
//                    newsLines.append("⚠️ Unable to locate a vacant module.")
                    self.gameOverlay.addNews(data: NewsData(type: .Info, message: "⚠️ Unable to locate a vacant module.", date: nil))
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
        
        // sceneRenderer.prepare(<#T##objects: [Any]##[Any]#>, completionHandler: <#T##((Bool) -> Void)?##((Bool) -> Void)?##(Bool) -> Void#>)
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
        if time < 9 { return }
        
        if rounded.truncatingRemainder(dividingBy: 15) == 0 {
            
            if shouldUpdateScene {
                shouldUpdateScene = false
                
                switch self.gameScene {
                    case .SpaceStation:
                        print("⏱ Station Update: \(rounded)")
                        
                        station?.accountingLoop(recursive: false) { (messages) in
                            
                            DispatchQueue.main.async {
                                
                                // Update Player Card
                                self.gameOverlay.updatePlayerCard()
                                
                                // Tutorial hand
                                self.checkBeginnersHandTutorial()
                                
                                // News (Now on Overlay)
//                                if self.newsLines.isEmpty == false {
//                                    print("*** NEWS ***  (\(self.newsLines.count))")
//                                    if let currentNews = self.newsLines.first {
//                                        self.gameOverlay.generateNews(string: currentNews)
//                                        self.newsLines.removeFirst()
//                                    }
//                                }
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
//                                    if self.newsLines.isEmpty == false {
//                                        print("*** NEWS ***  (\(self.newsLines.count))")
//                                        if let currentNews = self.newsLines.first {
//                                            self.gameOverlay.generateNews(string: currentNews)
//                                            self.newsLines.removeFirst()
//                                        }
//                                    }
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
                    
                    let line1 = "⚠️ Player needs an entry ticket to Mars\n🛒 Head to the store and purchase any product."
                    
                    let timeDelay = DispatchTime.now() + 0.75
                    DispatchQueue.main.asyncAfter(deadline: timeDelay) {
                        self.gameOverlay.addNews(data: NewsData(type: .Info, message: line1, date: nil))
                    }
                    
                    return
                }
                
                // Verify Player has Guild
                let mBuilder = MarsBuilder.shared
                guard mBuilder.hasNoGuild == false else {
                    print("No Entry")
                    
                    let line1 = "⚠️ Player has no Guild.\nThis could happen if you haven't joined a guild.\nOr because you were booted 👢."
                    
                    let timeDelay = DispatchTime.now() + 1.0
                    DispatchQueue.main.asyncAfter(deadline: timeDelay) {
                        self.gameOverlay.addNews(data: NewsData(type: .Info, message: line1, date: nil))
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
        builtScene.isPaused = false
        
        self.scene = builtScene
        
        // Camera
        guard let camera = scene.rootNode.childNode(withName: "Camera", recursively: false) as? GameCamera else {
            fatalError()
        }
        self.cameraNode = camera
        renderer.pointOfView = camera.camNode
        
        let centralNode = SCNNode()
        centralNode.position = SCNVector3(x: 0, y: -15, z: 0)
        camera.position.z += 40
        camera.camNode.look(at: centralNode.position)
        
        // Overlay
        let stationOverlay = GameOverlay(renderer: renderer, station: station!, camNode: self.cameraNode!)
        sceneRenderer.overlaySKScene = stationOverlay.scene
        self.gameOverlay = stationOverlay
        
        // end init
        super.init()
        // post init details
        
        // Intro Tutorial
        let tutStage:Station.IntroTutorialStage = dBase.station.shouldShowTutorial()
        if tutStage == .habModules {
            // set to start from beginning
            self.introStage = .prologue
        } else {
            // set to start whatever this function returns
            self.introStage = tutStage
            
            // uncomment below to view intro tutorial
            // self.introStage = .prologue
        }
        
        // Animate camera
        let waiter = SCNAction.wait(duration: 3.0)
        let move1 = SCNAction.move(by: SCNVector3(-1, 6, -20), duration: 0.75)
        move1.timingMode = .easeIn
        let move2 = SCNAction.move(by: SCNVector3(1, -6, -20), duration: 0.75)
        move2.timingMode = .easeOut
        let sequence = SCNAction.sequence([waiter, move1, move2])
        camera.runAction(sequence)
        
        self.modules = station?.modules ?? []
        
        // Tell SceneDirector that scene is loaded
        SceneDirector.shared.controllerDidLoadScene(controller: self)
        
        sceneRenderer.delegate = self
        sceneRenderer.scene = scene
        
        playMusic()
        
        // Fetch Mars Data?
        _ = MarsBuilder.shared
        
        DispatchQueue.init(label: "NewsDelay").asyncAfter(deadline: .now() + 5.0) {
            DispatchQueue.main.async {
                // News
                self.prepareNews()
            }
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
                
                // Prioritize Beginners Guide
                if station.habModules.count < 1  {
                    hasChanges = true
                    break
                }
                
                // Lab activities
                let labs = station.labModules
                for lab in labs {
                    print("*** Found lab: \(lab.id)")
                    if let activity = lab.activity {
                        print("*** Found Activity: \(activity.activityName)")
                        if activity.dateEnds.compare(Date()) == .orderedAscending {
                            let descriptor = "🔬 Completed Lab activity - Check Lab Modules."
                            self.gameOverlay.addNews(data: NewsData(type: .Info, message: descriptor, date: nil))
//                            newsLines.append(descriptor)
                        } else {
                            let descriptor = "⏱ Lab: \(activity.activityName). \(Int(activity.dateEnds.timeIntervalSince(Date()))) s"
                            self.gameOverlay.addNews(data: NewsData(type: .Info, message: descriptor, date: nil))
//                            newsLines.append(descriptor)
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
                            self.gameOverlay.addNews(data: NewsData(type: .Info, message: descriptor, date: nil))
//                            newsLines.append(descriptor)
                            person.clearActivity()
                            hasChanges = true
                        }
                    }
                }
                
                // Other issues includes Water, Oxygen, Food, and Air Quality
                let otherIssues = station.reportLSSIssues()
                gameOverlay.sideMenuNode?.updateLSS(issues: otherIssues)
//                newsLines.append(contentsOf: otherIssues)
                if !otherIssues.isEmpty {
                    for oneshoe in otherIssues {
                        self.gameOverlay.addNews(data: NewsData(type: .Info, message: oneshoe, date: nil))
                    }
                }
                
                
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
//                                newsLines.append(descriptor)
                                self.gameOverlay.addNews(data: NewsData(type: .Info, message: descriptor, date: nil))
                            } else {
                                let descriptor = "⏱ Lab: \(activity.activityName). \(Int(activity.dateEnds.timeIntervalSince(Date()))) s"
                                self.gameOverlay.addNews(data: NewsData(type: .Info, message: descriptor, date: nil))
//                                newsLines.append(descriptor)
                            }
                        }
                        
                        // Hab Activities
                        for person in city.inhabitants {
                            if let activity = person.activity {
                                if activity.dateEnds.compare(Date()) == .orderedAscending {
                                    let moji = person.gender == "male" ? "🙋‍♂️":"🙋‍♀️"
                                    let descriptor = "\(moji) \(person.name) completed activity \(activity.activityName)."
                                    self.gameOverlay.addNews(data: NewsData(type: .Info, message: descriptor, date: nil))
//                                    newsLines.append(descriptor)
                                    person.clearActivity()
                                }
                            }
                        }
                        
                        // Air Quality
                        let qt:[AirQuality] = [.Lethal, .Bad]
                        if qt.contains(city.air.airQuality()) {
//                            newsLines.append("⚠️ Air quality is bad.")
                            self.gameOverlay.addNews(data: NewsData(type: .Intro, message: "⚠️ Air quality is bad.", date: nil))
                        }
                        
                        // Energy
                        let energy = city.batteries.compactMap({ $0.current }).reduce(0, +)
                        if energy < 10 {
//                            newsLines.append("⚡️ City is low on energy: \(energy) kW")
                            self.gameOverlay.addNews(data: NewsData(type: .Intro, message: "⚡️ City is low on energy: \(energy) kW", date: nil))
                        }
                    }
                }
        }
        
        // GameKit's Badge
        
        GKAccessPoint.shared.location = .topTrailing
        GKAccessPoint.shared.showHighlights = true
        GKAccessPoint.shared.isActive = true
        
        
        // Save if needed
        if hasChanges == true {
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
        
        // New Intro Stage Check
        // first switch (without the Hand Sprite)
         
        switch introStage {
            case .prologue:
                print("prologue - first one")
                // show news
                let prologueString:String = """
                Greetings, commander \(LocalDatabase.shared.player.name).
                Your objective is to take over this space station
                and expand its size and capabilities.
                """
                self.gameOverlay.addNews(data: NewsData(type: .Info, message: prologueString, date: nil))
                self.introStage = .intro
                return
                
            case .intro:
                print("Show Intro")
                // show news
                let introString:String = """
                If you are so brave, send space vehicles to Mars
                and colonize the red planet. I just started on the job,
                so I will try to help, but remember I am also a rookie.
                """
                self.gameOverlay.addNews(data: NewsData(type: .Info, message: introString, date: nil))
                DispatchQueue.main.asyncAfter(deadline: .now() + 12) {
                    self.introStage = station.shouldShowTutorial()
                }
                return
            case .finished:
                print("You finihed the tutorial!")
                return
                
            default: break
            
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
            return
        }
        
        // Find a vacant module
        let vacantModule:Module? = station.modules.first(where: { occupiedIDs.contains($0.id) == false })
        let vacantNode:SCNNode? = scene.rootNode.childNode(withName: vacantModule?.id.uuidString ?? "na", recursively: true)
        
        // switch again for the Hand Sprite
        switch introStage {
            case .habModules:
                
                print("Hab modules")
                guard let vacantNode = vacantNode else {
                    return
                }
                // get position
                let handPosition = convertSceneToOverlay(node: vacantNode)
                handSprite.position = handPosition
                self.gameOverlay.addNews(data: NewsData(type: .Info, message: "Tap on a Module to create your first 🏠 Hab", date: nil))
                // let the code through to animate hand
                // print("👆 Making beginners hand")
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    self.introStage = station.shouldShowTutorial()
                }
                
            case .labModules:
                print("Lab modules")
                guard let vacantNode = vacantNode else {
                    return
                }
                // get position
                let handPosition = convertSceneToOverlay(node: vacantNode)
                handSprite.position = handPosition
                self.gameOverlay.addNews(data: NewsData(type: .Info, message: "Tap on a Module to create your first 🔬 Lab", date: nil))
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    self.introStage = station.shouldShowTutorial()
                }
            case .hiring:
                print("Hiring")
                self.gameOverlay.addNews(data: NewsData(type: .Info, message: "Tap on the Globe 🌎 to order items for your Space Station.", date: nil))
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    self.introStage = station.shouldShowTutorial()
                }
            default:
                print("Other \(introStage) shouldn't happen.")
                break
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

