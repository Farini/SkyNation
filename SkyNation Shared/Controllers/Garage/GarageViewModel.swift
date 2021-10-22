//
//  GarageViewModel.swift
//  SkyTestSceneKit
//
//  Created by Farini on 10/29/20.
//  Copyright © 2020 Farini. All rights reserved.
//

import Foundation

enum GarageStatus {
    case idle
    case selectedBuilding(vehicle:SpaceVehicle) // Vehicles that are building
    case selectedBuildEnd(vehicle:SpaceVehicle) // Vehicles Finished Building
    case selectedTravel(vehicle:SpaceVehicle)   // Vehicles travelling
    case planning(stage:VehicleBuildingStage)
    case simulating
}

enum VehicleBuildingStage {
    case Engine     // Selecting Engine
    case Inventory  // Adding Tanks, Batteries, and Solar array
    case Descent    // Adding Ingredients, Peripherals, and BotTech
    case Crew       // Selecting Passengers
    case PrepLaunch // Preparing for launch
    case Launching  // Launching
    
}

class GarageViewModel:ObservableObject {
    
    // Status
    @Published var garageStatus:GarageStatus = .idle
    @Published var station:Station
    @Published var garage:Garage
    
    // Data
    @Published var unlockedRecipes:[Recipe]
    @Published var unlockedTech:[TechTree]
    
    @Published var vehicleProgress:Double?
    
    @Published var selectedVehicle:SpaceVehicle?
    @Published var buildingVehicles:[SpaceVehicle] // = []
    @Published var builtVehicles:[SpaceVehicle] // = []
    @Published var travellingVehicles:[SpaceVehicle] = []
    
    // Available Resources
    @Published var tanks:[Tank] = []
    @Published var batteries:[Battery] = []
    @Published var peripherals:[PeripheralObject] = []
    @Published var ingredients:[StorageBox]
    @Published var availablePeople:[Person]
    @Published var bioBoxes:[BioBox]
    
    
    init() {
        // Load Station
        let station = LocalDatabase.shared.station
        self.station = station
        self.garage = station.garage
        
        self.unlockedRecipes = station.unlockedRecipes
        
        // Good to load file from here
        let tree = TechTree()
        tree.accountForItems(items: station.unlockedTechItems)
        self.unlockedTech = tree.showUnlocked() ?? []
        
        // Arrays
        tanks = station.truss.getTanks()
        batteries = station.truss.batteries
        peripherals = station.peripherals
        ingredients = station.truss.extraBoxes
        
        // Lists of Built and Building vehicles
        var tempBuilding:[SpaceVehicle] = []
        var tempBuilt:[SpaceVehicle] = []
        for vehicle in station.garage.buildingVehicles {
            if let vehicleProg = vehicle.calculateProgress() {
                if vehicleProg < 1.0 {
                    tempBuilding.append(vehicle)
                } else {
                    tempBuilt.append(vehicle)
                }
            }
        }
        
        buildingVehicles = tempBuilding
        builtVehicles = tempBuilt
        
        travellingVehicles = LocalDatabase.shared.vehicles
        availablePeople = station.getPeople().filter { $0.isBusy() == false }

        // Bio boxes
        let bboxes = station.bioModules.flatMap({ $0.boxes })
        self.bioBoxes = bboxes
        
        // After init
        
        // Loop through Vehicles to see if any one arrived
        var transferringVehicles:[SpaceVehicle] = []
        for vehicle in travellingVehicles {
            if let arrivalDate = vehicle.dateTravelStarts?.addingTimeInterval(vehicle.travelTime ?? 604800) {
                if Date().compare(arrivalDate) == .orderedDescending {
                    // Arrived
                    // Change vehicle destination to either [MarsOrbit, or Exploring, or Settled]
                    // If already at those destinations, see SpaceVehicle object to continue
                    // Will need to transform SpaceVehicle into other objects
                    transferringVehicles.append(vehicle)
                }
            }
        }
        for vehicle in transferringVehicles {
            if let city = LocalDatabase.shared.cityData {
                travellingVehicles.removeAll(where: { $0.id == vehicle.id })
                city.garage.vehicles.append(vehicle)
                // Achievement
                GameMessageBoard.shared.newAchievement(type: .vehicleLanding(vehicle: vehicle), message: nil)
            }
        }
    }
    
    // ------------------
    // Need to make sure to take from station and return to station
    // Add option of Solar power (for its cost)
    // ==================
    
    func addTank(tank:Tank) -> Bool {
        
        guard let vehicle = selectedVehicle else { fatalError() }
        
        if vehicle.tanks.contains(where: { $0.id == tank.id }) {
            // Removing (was added)
            vehicle.tanks.removeAll(where: { $0.id == tank.id })
            return false
        }else{
            vehicle.tanks.append(tank)
            return true
        }
    }
    
    func addBattery(battery:Battery) -> Bool {
        guard let vehicle = selectedVehicle else { fatalError() }
        
        if vehicle.batteries.contains(where: { $0.id == battery.id }) {
            vehicle.batteries.removeAll(where: { $0.id == battery.id })
            return false
        }else{
            vehicle.batteries.append(battery)
            return true
        }
    }
    
    func addPeripheral(peripheral:PeripheralObject) {
        
        guard let vehicle = selectedVehicle else { fatalError() }
        
        print("Trying to add Peripheral to Vehicle named \(vehicle.name)")
        
        switch peripheral.peripheral {
        case .Antenna:
            print("Antenna!")
        default:
            print("Not implemented - Edit code here")
        }
    }
    
    /// Returns whether its (not) possible to build a certain Engine Type
    func disabledEngine(type:EngineType) -> Bool {
        switch type {
        case .Hex6: return false
        default: return garage.xp < type.requiredXP
        }
    }
    
    /// Improves Experience (with token)
    func improveExperience() {
        self.garage.xp += 1
    }
    
    // MARK: - Vehicle Selection
    
    /// Selected a vehicle that is building
    func didSelectBuilding(vehicle:SpaceVehicle) {
        
        selectedVehicle = vehicle
        garageStatus = .selectedBuilding(vehicle: vehicle)
        
        // Progress
        if let progress = vehicle.calculateProgress() {
            if progress < 1 {
                self.checkProgressLoop(vehicle: vehicle)
            } else {
                self.vehicleProgress = 1.0
                if let deleteIndex = buildingVehicles.firstIndex(where: { $0.id == vehicle.id }) {
                    self.buildingVehicles.remove(at: deleteIndex)
                    self.builtVehicles.append(vehicle)
                    self.garageStatus = .selectedBuildEnd(vehicle: vehicle)
                    self.station.garage.xp += 1
                    
                }
            }
        }
    }
    
    /// Selected a vehicle that has finished building
    func didSelectBuildEnd(vehicle:SpaceVehicle) {
        
        selectedVehicle = vehicle
        garageStatus = .selectedBuildEnd(vehicle: vehicle)
        
        // Progress
        if let progress = vehicle.calculateProgress() {
            if progress < 1 {
                self.checkProgressLoop(vehicle: vehicle)
            } else {
                self.vehicleProgress = 1.0
                if let deleteIndex = buildingVehicles.firstIndex(where: { $0.id == vehicle.id }) {
                    self.buildingVehicles.remove(at: deleteIndex)
                    self.builtVehicles.append(vehicle)
                    self.garageStatus = .selectedBuildEnd(vehicle: vehicle)
                    self.station.garage.xp += 1
                    
                }
            }
        }
    }
    
    /// Selected a Vehicle that is currently travelling to Mars
    func didSelectTravelling(vehicle:SpaceVehicle) {
        
        // Check if going to Mars
        if vehicle.status == .Mars {
            // Check if arrived
            if Date().compare(vehicle.arriveDate()) == .orderedDescending {
                vehicle.status = .MarsOrbit
//                vehicle.simulation += 1
                self.station.garage.simulationXP += 1
                self.station.garage.xp += 1
                
                // Save
                do {
                    // Save Station
                    try LocalDatabase.shared.saveStation(station)
                    do {
                        // Save Vehicle
                        try LocalDatabase.shared.saveVehicles(travellingVehicles)
                        
                    } catch {
                        print("‼️ Could not save vehicles.: \(error.localizedDescription)")
                    }
                } catch {
                    print("‼️ Could not save station.: \(error.localizedDescription)")
                }
            }
        }
        
        self.selectedVehicle = vehicle
        
        garageStatus = .selectedTravel(vehicle: vehicle)
    }
    
    /// Starts a loop to update the vehicle's travel progress
    private func checkProgressLoop(vehicle:SpaceVehicle) {
        
        if selectedVehicle?.id != vehicle.id { return }
        
        if let vProgress = vehicle.calculateProgress() {
            
            if vProgress < 1 {
                // keep updating
                self.vehicleProgress = vProgress
                print("Updating vehicle progress... \(vProgress)")
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                    self.checkProgressLoop(vehicle: vehicle)
                }
            } else {
                // Finished. Stop updating
                self.vehicleProgress = vProgress
                print("Stop Updating vehicle progress...")
            }
        } else {
            print("There was no vehicle progress")
        }
    }
    
    /// Resets the view to the beginning state
    func cancelSelection() {
        self.selectedVehicle = nil
        self.garageStatus = .idle
    }
    
    // MARK: - Building Space Vehicle
    
    /// Sets the UI to start planning new Vehicle
    func startNewVehicle() {
        garageStatus = .planning(stage: .Engine)
    }
    
    /// Called when Vehicle Engine Setup is Finished
    func didSetupEngine(vehicle:SpaceVehicle, workers:[Person]) {
        
        // Tech Time Discount
        var engineDefaultTime = vehicle.engine.time
        print("⏱ Engine Default Time: \(engineDefaultTime)")
        
        if station.unlockedTechItems.contains(.GarageArm) {
            let third = engineDefaultTime / 3.0
            engineDefaultTime -= third
        }
        print("⏱ Engine After Tech:   \(engineDefaultTime)")
        
        // Intelligence Discount
        var bonus:Double = 0.1
        for person in workers {
            let lacking = Double(min(100, person.intelligence) + min(100, person.happiness) + min(100, person.teamWork)) / 3.0
            // lacking will be 100 (best), 0 (worst)
            bonus += lacking / Double(workers.count)
        }
        let timeDiscount = (bonus / 100) * 0.5 * Double(vehicle.engine.time) // up to 50% discount on time
        print("⏱ Engine Time Discount: \(timeDiscount)")
        
        // Create Activity
        let duration = engineDefaultTime - timeDiscount
        print("⏱ Engine After Intel:   \(duration)")
        
        // Update Person's Activity
        for person in workers {
            let activity = LabActivity(time: duration, name: "Space Vehicle Engine")
            person.activity = activity
        }
        
        selectedVehicle = vehicle
        station.garage.xp += 1
        
        // Update UI
        self.buildingVehicles.append(vehicle)
        self.didSelectBuilding(vehicle: vehicle)
        
        // Update and save Model
        station.garage.startBuildingVehicle(vehicle: vehicle, time:duration)
        
        // Save
        do {
            // Save Station
            try LocalDatabase.shared.saveStation(station)
            print("Finished setting up engine. Game Saved.")
        } catch {
            print("‼️ Could not save station.: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Inventory + Launch
    
    /// Updates the UI to setup the Inventory
    func setupInventory(vehicle:SpaceVehicle) {
        // Make sure this is selected vehicle
        guard selectedVehicle != nil && selectedVehicle == vehicle else { fatalError() }
        // Update View Status
        self.garageStatus = .planning(stage: .Inventory)
    }
    
    func didFinishInventory(vehicle:SpaceVehicle) {
        
        // Make sure this is selected vehicle
        guard selectedVehicle != nil && selectedVehicle == vehicle else { fatalError() }
        
        // Inventory
        let limit = vehicle.engine.payloadLimit
        let weight = vehicle.calculateWeight()
        print("Vehicle Weight: \(weight)")
        if weight > limit {
            print("⚠️ Vehicle Overweight !!!")
            return
        }
        
        // Status
        let vehicleStatus = vehicle.status
        print("Vehicle Status (Data): \(vehicleStatus)")
        
        
        // Prepare for Launch
        
        // 1. Go through Inventory
        var inventoryBool:Bool = true
        
        // 2. Charge tanks, batteries, and move peripherals
        // 2.a Tanks
        for tank in vehicle.tanks {
            if station.truss.removeTank(tank: tank) == true {
                print("Tank removed from Station -> Vehicle")
            } else {
                inventoryBool = false
            }
        }
        // 2.b. Batteries
        for battery in vehicle.batteries {
            if station.truss.removeBattery(battery: battery) == true {
                print("Removing Battery from Station -> Vehicle")
            } else {
                inventoryBool = false
            }
        }
        // 2.c. Peripherals
        for peripheral in vehicle.peripherals {
            if station.removePeripheral(peripheral: peripheral) == true {
                print("Removing Peripheral from Station -> Vehicle")
            } else {
                inventoryBool = false
            }
        }
        
        // FIXME: - To Add
        // 2. Boxes (Ingredients)
        // 3. Passengers (Person)
        // 4. Bioboxes
        
        
        // Check if inventory was successful
        if inventoryBool {
            // Success
        } else {
            // Add Problem
        }
        
        // 3. Set the UI to "Preparing for launch" (if vehicle is ready), or cancelSelection if not
        if builtVehicles.contains(vehicle) {
            // Prepare for launch
            self.garageStatus = .planning(stage: .PrepLaunch)
            
        } else if buildingVehicles.contains(vehicle) {
            // not ready. Cancel selection
            self.cancelSelection()
        } else {
            print("Something wrong. Vehicle should be building, or built.")
            
        }
        // 4. Save station
        
        
    }
    
    /// Brings the user back to Inventory
    func goBackToInventory() {
        if let vehicle = self.selectedVehicle {
            print("Back to inventory. Vehicle: \(vehicle.name)")
            self.garageStatus = .planning(stage: .Inventory)
        }
    }
    
    /// `EDL` inventory
    func setupDescentInventory() {
        self.garageStatus = .planning(stage: .Descent)
    }
    
    func finishedDescentInventory(vehicle:SpaceVehicle, cargo:[StorageBox], tanks:[Tank], batteries:[Battery], devices:[PeripheralObject], people:[Person], bioBoxes:[BioBox]) {
        
        // Transfer stuff from station to vehicle
        
        // Boxes
        station.truss.extraBoxes.removeAll(where: { cargo.map({ $0.id }).contains($0.id) })
        vehicle.boxes.append(contentsOf: cargo)
        
        // Tanks
        station.truss.tanks.removeAll(where: { tanks.map({ $0.id }).contains($0.id) })
        vehicle.tanks.append(contentsOf: tanks)
        
        // Batteries
        station.truss.batteries.removeAll(where: { batteries.map({ $0.id }).contains($0.id)})
        vehicle.batteries.append(contentsOf: batteries)
        
        // Peripherals
        station.peripherals.removeAll(where: { devices.map({ $0.id }).contains($0.id)})
        vehicle.peripherals.append(contentsOf: devices)
        
        // People
        for person in people {
            if station.removePerson(person: person) == true {
                vehicle.passengers.append(person)
            }
        }
        
        // BioBoxes
        for bb in bioBoxes {
            for bioMod in station.bioModules {
                if bioMod.boxes.contains(bb) {
                    bioMod.boxes.removeAll(where: { $0.id == bb.id })
                    vehicle.bioBoxes.append(bb)
                }
            }
        }
        
        // Check if over limit?
        
        // Save
        
        didSelectBuildEnd(vehicle: vehicle)
//        cancelSelection()
    }
    
    /// Launches a SpaceVehicle to travel to Mars
    func launch(vehicle:SpaceVehicle) {
        
        print("🚀 Launching Vehicle!")
        self.garageStatus = .planning(stage: .Launching)
                
        // Set Vehicle to start travelling
        vehicle.startTravelling()
            
        // Remove from Garage
        self.garage.buildingVehicles.removeAll(where: { $0.id == vehicle.id })
            
        // Add to Array of travelling vehicles
        var newVehicleArray = LocalDatabase.shared.vehicles
        newVehicleArray.append(vehicle)
        self.travellingVehicles.append(vehicle)
            
        // XP
        self.garage.xp += 1
            
        // Save
        // Save
        do {
            // Save Station
            try LocalDatabase.shared.saveStation(station)
            do {
                // Save Vehicle
                try LocalDatabase.shared.saveVehicles(newVehicleArray)
                
            } catch {
                print("‼️ Could not save vehicles.: \(error.localizedDescription)")
            }
        } catch {
            print("‼️ Could not save station.: \(error.localizedDescription)")
        }
//        LocalDatabase.shared.saveVehicles()
//        LocalDatabase.shared.saveStation(station: self.station)
            
        // Update View
        self.garageStatus = .planning(stage: .Launching)
        // self.cancelSelection()
        
        // Update Scene
        
        self.registerVehicle(vehicle: vehicle, completion: nil)
        
    }
    
    // MARK: - Server
    func isRegistered(vehicle:SpaceVehicle) -> Bool {
        if let dbVehicle = LocalDatabase.shared.vehicles.first(where: { $0.id == vehicle.id }) {
            return dbVehicle.registration != nil
        }
        return false
    }
    
    func registerVehicle(vehicle:SpaceVehicle, completion:((SpaceVehicleTicket?, Error?) -> ())?) {
        print("Registering Vehicle in Server")
        
//        let user = SKNUserPost(player: player)
//        var allVehicles = LocalDatabase.shared.vehicles
        SKNS.registerSpace(vehicle: vehicle) { (ticket, error) in
            
            if let ticket = ticket {
                DispatchQueue.main.async {
                    print("Vehicle Registration Approved! ")
                    vehicle.registration = ticket.id
                    if let dbVehicle = LocalDatabase.shared.vehicles.first(where: { $0.id == vehicle.id }) {
                        dbVehicle.registration = ticket.id
                        print("Saving Database Travelling Vehicles")
                        // Save
                        do {
                            // Save Vehicles
                            try LocalDatabase.shared.saveVehicles(LocalDatabase.shared.vehicles)
                            // Achievement
                            GameMessageBoard.shared.newAchievement(type: .experience, message: "Space Vehicle Registered.")
                        } catch {
                            print("‼️ Could not save station.: \(error.localizedDescription)")
                        }
                    }
                }
                
//                LocalDatabase.shared.saveStation(station: self.station)
            } else {
                print("⚠️ Did not get a ticket from Vehicle Registration! \(error?.localizedDescription ?? "")")
            }
        }
    }
    
    // MARK: - Token Use
    
    /// Uses a Token from Player to reduce 1hr in building time
    func useToken(vehicle:SpaceVehicle) {
        
        guard let travelStarted = vehicle.dateTravelStarts else { return }
        let dateOffset = travelStarted.addingTimeInterval(-60*60)
        self.selectedVehicle?.dateTravelStarts = dateOffset
        
        // Progress
        if let progress = vehicle.calculateProgress() {
            if progress < 1 {
                self.checkProgressLoop(vehicle: vehicle)
            } else {
                self.vehicleProgress = 1.0
                if let deleteIndex = buildingVehicles.firstIndex(where: { $0.id == vehicle.id }) {
                    self.buildingVehicles.remove(at: deleteIndex)
                    self.builtVehicles.append(vehicle)
                    self.garageStatus = .selectedBuildEnd(vehicle: vehicle)
                    self.station.garage.xp += 1
                    
                }
            }
        }
    }
}

import SceneKit

class LaunchSceneController:ObservableObject {
    
    @Published var scene:SCNScene
    @Published var vehicleNode:SpaceVehicleNode
    @Published var vehicle:SpaceVehicle
    
    init(vehicle:SpaceVehicle) {
        
        self.vehicle = vehicle
        
        let scene = SCNScene(named: "Art.scnassets/Vehicles/SpaceVehicle3.scn")!
        for childnode in scene.rootNode.childNodes {
            if !["Camera", "Light"].contains(childnode.name ?? "") {
                childnode.isHidden = true
            }
        }
        
        self.scene = scene
        
        let node = SpaceVehicleNode(vehicle: vehicle, parentScene:scene)
        self.vehicleNode = node
        
        node.move()
        
        if let camera = scene.rootNode.childNode(withName: "Camera", recursively: false) {
            
            // Look At
            let constraint = SCNLookAtConstraint(target:vehicleNode)
            constraint.isGimbalLockEnabled = true
            constraint.influenceFactor = 0.1
            
            // Follow
            let follow = SCNDistanceConstraint(target: vehicleNode)
            follow.minimumDistance = 20
            follow.maximumDistance = 50
            
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 3.0
            camera.constraints = [constraint, follow]
            SCNTransaction.commit()
            
            let waiter = SCNAction.wait(duration: 5)
            let move = SCNAction.move(by: SCNVector3(100, 0, 0), duration: 10)
            // let wait = SCNAction.wait(duration: 5)
            let group = SCNAction.sequence([waiter, move])
            camera.runAction(group) {
                print("Finished camera move")
            }
        }
        
        
    }
}

class LaunchSceneRendererMan:NSObject, SCNSceneRendererDelegate {
    
    var checkup:TimeInterval = 10
    var addedBox:Bool = false
    
    func renderer(_ renderer: SCNSceneRenderer, didRenderScene scene: SCNScene, atTime time: TimeInterval) {
//        renderer.debugOptions = .showBoundingBoxes
        if time > checkup {
//            print("Checkup")
//            checkup += 10
//            if !addedBox {
//                let box = SCNBox(width: 3, height: 3, length: 3, chamferRadius: 1)
//                let bnode = SCNNode(geometry: box)
//                scene.rootNode.addChildNode(bnode)
//                addedBox = true
//            }
        }
    }
}

import SwiftUI

/**
 The Controller for the EDL Scene
 */
class EDLSceneController:ObservableObject {
    
    @Published var scene:SCNScene
//    @Published var edlNode:SCNNode
    @Published var vehicle:SpaceVehicle
    @Published var actNames:[String] = []
    
    private var burnMaterial:SCNMaterial
    private var emitter:SCNParticleSystem
    
    private var camera:SCNCamera
    private var cameraNode:SCNNode
    private var floor:SCNNode
    private var mars:SCNNode
    
    // New
    // edlModule
    var edlModule:SCNNode
    
    // shootBase (whole shoot)
    var shootBase:SCNNode
    
    // shock
    var smallShock:SCNNode
    var engines:[SCNNode] = []
    
    init(vehicle:SpaceVehicle) {
        
        self.vehicle = vehicle
        
        let scene = SCNScene(named: "Art.scnassets/Vehicles/EDL2.scn")!
        
        self.scene = scene
        
        // Ground
        guard let floor = scene.rootNode.childNode(withName: "floor", recursively: false),
              let mars = scene.rootNode.childNode(withName: "Mars", recursively: false) else {
            fatalError("no floor")
        }
        self.floor = floor
        self.mars = mars
        
        // Module
        guard let module = scene.rootNode.childNode(withName: "EDLModule", recursively: false),
              let mainGeometry = module.geometry,
              let burnMaterial = mainGeometry.materials.first(where: { $0.name == "Burn"})
            else {
            fatalError("no Module")
        }
        
        self.edlModule = module
        self.burnMaterial = burnMaterial

        // Hide Engines
        var allEngines:[SCNNode] = []
        for eng in module.childNodes {
            let nodeName = eng.name ?? "na"
            if nodeName.contains("Engine") {
                eng.isHidden = true
                allEngines.append(eng)
            }else{
                if nodeName == "ShootBase" {
                    eng.isHidden = true
                }
            }
        }
        
        guard let cameraNode:SCNNode = scene.rootNode.childNode(withName: "Camera", recursively: false),
              let camera = cameraNode.camera else {
            fatalError()
        }
        self.cameraNode = cameraNode
        self.camera = camera
        
        // Load Secondary Nodes
        guard let shock2 = module.childNode(withName: "Shock2", recursively: false),
              let particles:SCNParticleSystem = shock2.particleSystems?.first,
                let shoot = module.childNode(withName: "ShootBase", recursively: false) else {
            fatalError("No Shock")
        }
        shock2.isHidden = true
        shoot.isHidden = true
        
        self.emitter = particles
        self.smallShock = shock2
        self.shootBase = shoot
        
        // Post Init
        self.engines = allEngines
        self.burnMaterial.emission.intensity = 0
        self.emitter.birthRate = 0
        
        self.setupCamera()
        
    }
    
    func setupCamera() {
        // Camera moves
        
        // Look At
        let constraint = SCNLookAtConstraint(target:edlModule)
        constraint.isGimbalLockEnabled = true
        constraint.influenceFactor = 0.1
        
        // Follow
        let follow = SCNDistanceConstraint(target: edlModule)
        follow.minimumDistance = 5
        follow.maximumDistance = 50
        
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 2.0
        cameraNode.constraints = [constraint, follow]

        
        SCNTransaction.commit()
        
        let waiter = SCNAction.wait(duration: 5)
        let move = SCNAction.move(by: SCNVector3(0, -5, 0), duration: 3)
        let group = SCNAction.sequence([waiter, move])
        cameraNode.runAction(group) {
            self.actNames.removeAll(where: { $0 == "Camera Move" })
            print("Finished camera move")
            self.atmoImpactAnimation()
            
        }
        
        camera.focalLength = 30
        
        // Rotate Mars
        let marsRot = SCNAction.rotate(by: GameLogic.radiansFrom(10), around: SCNVector3(0, 0, 1), duration: 60.0)
        self.mars.runAction(marsRot)
        
        // Rotate Ship
        let shipRotation = SCNAction.rotate(by: GameLogic.radiansFrom(-12), around: SCNVector3(0, 0, 1), duration: 2.0)
        edlModule.runAction(shipRotation)
    }
    
    func atmoImpactAnimation() {
        
        self.smallShock.isHidden = false
        self.smallShock.geometry?.materials.first?.emission.intensity = 0.1
        self.emitter.birthRate = 15
        
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 5.0
        SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: .easeIn)
        self.smallShock.geometry?.materials.first?.emission.intensity = 4.0
        self.emitter.birthRate = 500
        self.burnMaterial.emission.intensity = 4.0
        
        SCNTransaction.commit()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.2) {
            self.impactFadeAnimation()
        }
    }
    
    func impactFadeAnimation() {
        
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 5.0
        self.smallShock.geometry?.materials.first?.emission.intensity = 0.0
        self.smallShock.isHidden = true
        self.emitter.birthRate = 0
        self.burnMaterial.emission.intensity = 0.0
        SCNTransaction.commit()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) {
            self.launchShoot()
        }
    }
    
    func launchShoot() {
        
        self.shootBase.isHidden = false
        camera.focalLength = 20
        
        // The Shoot should wobble more
        let waiter = SCNAction.wait(duration: 0.5)
        
        let shootLift = SCNAction.rotate(by: GameLogic.radiansFrom(-12), around: SCNVector3(0.1, 0, 1), duration: 2.5)
        let shootWobble = SCNAction.rotate(by: GameLogic.radiansFrom(10), around: SCNVector3(0, 1, 0), duration: 1.0)
        let shootUnwobble = SCNAction.rotate(by: GameLogic.radiansFrom(-10), around: SCNVector3(0, 1, 0), duration: 1.0)
        let liftSequence = SCNAction.sequence([waiter, shootLift])
        let wobbleSequence = SCNAction.sequence([shootWobble, shootUnwobble])
        let shootGroup = SCNAction.group([liftSequence, wobbleSequence])
        
        self.shootBase.runAction(shootGroup) {
            
//            let modTurn = SCNAction.rotate(by: GameLogic.radiansFrom(-45), around: SCNVector3(0, 0, 1), duration: 0.8)
//            let modTurn2 = SCNAction.rotate(by: GameLogic.radiansFrom(15), around: SCNVector3(0, 0, 1), duration: 1.5)
//            modTurn2.timingMode = .easeIn
            let modTurn3 = SCNAction.rotate(by: GameLogic.radiansFrom(-45), around: SCNVector3(0, 0, 1), duration: 3.2)
            modTurn3.timingMode = .easeInEaseOut
//            let seq = SCNAction.sequence([modTurn, modTurn2, modTurn3])
            self.edlModule.runAction(modTurn3)
            
            self.shootBase.runAction(waiter) {
                self.cameraNode.runAction(SCNAction.moveBy(x: 0, y: -5, z: 0, duration: 2.8))
                self.dropFromShoot()
            }
        }
        
    }
    
    func dropFromShoot() {
        
        let pos = self.shootBase.worldPosition
        let eul = self.shootBase.eulerAngles
        self.shootBase.removeFromParentNode()
        self.shootBase.position = pos
        self.shootBase.eulerAngles = eul
        self.scene.rootNode.addChildNode(self.shootBase)
        
        let fall = SCNAction.moveBy(x: 0, y: -48, z: 0, duration: 5.2)
        fall.timingMode = .easeOut
        
        let angleAdjust = SCNAction.rotate(by: GameLogic.radiansFrom(-33), around: SCNVector3(0, 0, 1), duration: 3.2)
        let group = SCNAction.group([fall, angleAdjust])
        
        self.edlModule.runAction(group) {
            
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.igniteThrusters()
        }
        
        // animate camera?
        camera.focalLength = 45
        
        // remove mars
        // add floor
        mars.isHidden = true
        floor.isHidden = false
        
    }
    
    func igniteThrusters() {
        // self.actNames = ["POS: \(self.edlModule.worldPosition)"]
        for engine in self.engines {
            engine.isHidden = false
            
        }
        
        let finalRot = SCNAction.rotateBy(x: GameLogic.radiansFrom(15), y: 0, z: 0, duration: 1.2)
        let finalRot2 = SCNAction.rotateBy(x: GameLogic.radiansFrom(-15), y: 0, z: 0, duration: 2.2)
        let finalRot3 = SCNAction.rotateBy(x: 0, y: GameLogic.radiansFrom(30), z: 0, duration: 1.2)
        let finalRot4 = SCNAction.rotateBy(x: 0, y: GameLogic.radiansFrom(-30), z: 0, duration: 2.2)
        
        let wobble1 = SCNAction.sequence([finalRot, finalRot2])
        let wobble2 = SCNAction.sequence([finalRot3, finalRot4])
        
        self.edlModule.runAction(SCNAction.group([wobble1, wobble2]))
        
    }
    
    // FIXME: - Continue
    /*
     Before start burning, needs to show particle emitter
     Animate the burn stopping
     Dim down particle Emitter
     
     Approach with camera and throw something in that direction
     
     Attempt # 2
     
     - Contact
        * unhide shock
        * start particle emitter
        * start burning color
     - burning
        * animate shock (scale, rotate, etc.)
        * unwind particle emitter
        * reverse burning color
        * dim shock until 0
     - deploy shoot
        * throw object blob
        * scale parashoot
        * rotate parashoot
        * rotate ship
        * slow down
     - drop
        * unhide engines
        * run particle emitters (thrusters)
        * slow down the drop
     - land
        
     -------------------------------
     
     5 Stages - 2 sec each.
     
     - Touch Atmo
        * start particle emitter
        * start burning color (after 1s)
     - Burn
        * dim burn first
        * dim emitter (reduce birthRate)
     - Stabilize
        * rotate ship
        * load parashoot geometry
        * move camera?
     - Gliding (Parashoot)
        * throw blob
        * scale shoot?
        * show parashoot
        * release parashoot
     - Landing (Engines)
        * unhide engines
        * engines emitters
        * land on ground.
     
     */
    
    /*
    func touchAtmosphere() {
        
        self.emitter.birthRate = 50
        let emitterDuration = 2.5
        
        let emitAnimation = CABasicAnimation(keyPath: "birthRate")
        emitAnimation.toValue = 300
        emitAnimation.duration = emitterDuration
        emitAnimation.autoreverses = false
        
        self.emitter.addAnimation(emitAnimation, forKey: "birthRate")
        
        let waiter = SCNAction.wait(duration: emitterDuration)
        self.edlNode.runAction(waiter) {
            self.emitter.birthRate = 300
            self.move()
            
            self.burnMaterial.emission.contents = NSColor.red
            self.burnMaterial.emission.intensity = 0.0
            self.burnIntensity()
        }
    }
    
    func move() {
        camera.focalLength = 30
        
        self.actNames.append("Ship Move")

        let action = SCNAction.move(by: SCNVector3(40, 0, 0), duration: 12.0)
        self.edlNode.runAction(action) {
            print("Finished moving")
            self.actNames.removeAll(where: { $0 == "Ship Move" })

            self.parashoot()
        }
    }
    
    /// Increases the Burn Intensity
    func burnIntensity() {
        
        let burnAnime = CABasicAnimation(keyPath: "intensity")
        burnAnime.toValue = 1.0
        burnAnime.duration = 3
        burnAnime.autoreverses = true
        self.burnMaterial.emission.addAnimation(burnAnime, forKey: "intensity")
        
        let emitAnimation = CABasicAnimation(keyPath: "birthRate")
        emitAnimation.toValue = 0
        emitAnimation.duration = 6
        emitAnimation.autoreverses = false
        self.emitter.addAnimation(emitAnimation, forKey: "birthRate")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
            self.emitter.birthRate = 0
            self.burnMaterial.emission.intensity = 0
        }
    }
    
    // MARK: - Shoot
    
    /// Launch Parashoot
    func parashoot() {
        
        var pShoot:SCNNode!
        
        for eng in edlNode.childNodes {
            let nodeName = eng.name ?? "na"
            if nodeName == "Parashoot" {
                eng.runAction(SCNAction.wait(duration: 0.25)) {
                    eng.isHidden = false
                    pShoot = eng
                    
                }
            }
            else if nodeName.contains("Engine") {
                eng.runAction(SCNAction.wait(duration: 0.75)) {
                    
                    // unhide Engine
                    eng.isHidden = false
                    
                    // hide mars
                    self.mars.isHidden = true
                    
                    // unhide floor
                    self.floor.isHidden = false
                }
            }
        }
        
        // Point Camera to Parashoot
        // Look At
        let constraint = SCNLookAtConstraint(target:pShoot)
        constraint.isGimbalLockEnabled = true
        constraint.influenceFactor = 0.3
        
        // -------------------
        
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 1.0
        cameraNode.constraints = [constraint]
        SCNTransaction.commit()
        
        
        
        let waiter = SCNAction.wait(duration: 1)
        self.scene.rootNode.runAction(waiter) {
            
            // Turn on engines
            self.throttleThrust()
            
            // Release Shoot
            let posin = pShoot.worldPosition
            pShoot.removeFromParentNode()
            pShoot.position = posin
            self.scene.rootNode.addChildNode(pShoot)
            
            let moveUp = SCNAction.moveBy(x: 0, y: 30, z: 0, duration: 0.5)
            pShoot.runAction(moveUp) {
                pShoot.removeFromParentNode()
            }
        }
    }
    
    
    func throttleThrust() {
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            let newConstraint = SCNLookAtConstraint(target:self.edlNode)
            newConstraint.isGimbalLockEnabled = true
            newConstraint.influenceFactor = 0.1
            
            // Follow
            let follow = SCNDistanceConstraint(target: self.edlNode)
            follow.minimumDistance = 5
            follow.maximumDistance = 20
            
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 1.0
            self.cameraNode.constraints = [newConstraint]
            SCNTransaction.commit()
//        }
        
        let rotation = SCNAction.rotate(by: GameLogic.radiansFrom(-45), around: SCNVector3(0, 0, 1), duration: 3.0)
        self.edlNode.runAction(rotation) {
            print("Finished rotating")
            
            
            
            
            self.camera.focalLength = 15
            
            let fall = SCNAction.moveBy(x: 0, y: -25, z: 0, duration: 5)
            let keepTurning = SCNAction.rotate(by: GameLogic.radiansFrom(-45), around: SCNVector3(0, 0, 1), duration: 3.0)
            let group = SCNAction.group([fall, keepTurning])
            
            self.edlNode.runAction(group) {
                self.camera.focalLength = 30
                self.edlNode.runAction(fall)
            }
        }
    }
    */
    
}
