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
    case Launching  //
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
    
    init() {
        // Load Station
        let station = LocalDatabase.shared.station!
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
        
        // After init
        
        // Loop through Vehicles to see if any one arrived
        for vehicle in travellingVehicles {
            if let arrivalDate = vehicle.dateTravelStarts?.addingTimeInterval(vehicle.travelTime ?? 604800) {
                if Date().compare(arrivalDate) == .orderedDescending {
                    // Arrived
                    // Change vehicle destination to either [MarsOrbit, or Exploring, or Settled]
                    // If already at those destinations, see SpaceVehicle object to continue
                    // Will need to transform SpaceVehicle into other objects
                }
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
    
    /// Sets the Vehicle to start building
//    func startBuilding(vehicle:SpaceVehicle) {
//
//        station.garage.startBuildingVehicle(vehicle: vehicle)
//        self.buildingVehicles.append(vehicle)
//        selectedVehicle = vehicle
//        garageStatus = .idle
//
//    }
    
    /// Returns whether its (not) possible to build a certain Engine Type
    func disabledEngine(type:EngineType) -> Bool {
        switch type {
        case .Hex6: return false
        default: return garage.xp < type.requiredXP
        }
    }
    
    /// Improves Experience (⚠️ Remove when Launching the game)
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
                vehicle.simulation += 1
                self.station.garage.simulationXP += 1
                self.station.garage.xp += 1
                // Save Station
                LocalDatabase.shared.saveStation(station: station)
                // Save Vehicle
                LocalDatabase.shared.vehicles = travellingVehicles
                LocalDatabase.shared.saveVehicles()
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
    
    // MARK: - Cancelling
    
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
        
        // Update Person's Activity
        
        // Activity and Time
        var bonus:Double = 0.1
        for person in workers {
            let lacking = Double(max(100, person.intelligence) + max(100, person.happiness) + max(100, person.teamWork)) / 3.0
            // lacking will be 100 (best), 0 (worst)
            bonus += lacking / Double(workers.count)
        }
        let timeDiscount = (bonus / 100) * 0.6 * Double(vehicle.engine.time) // up to 60% discount on time
        
        // Create Activity
        let duration = vehicle.engine.time - timeDiscount
        for person in workers {
            let activity = LabActivity(time: duration, name: "Space Vehicle Engine")
            person.activity = activity
        }
        
        
        selectedVehicle = vehicle
        station.garage.xp += 1
        
        print("Finished setting up engine.")
        
        // Update UI
        self.buildingVehicles.append(vehicle)
        self.didSelectBuilding(vehicle: vehicle)
        
        // Update and save Model
        station.garage.startBuildingVehicle(vehicle: vehicle, time:duration)
        LocalDatabase.shared.saveStation(station: station)
    }
    
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
        
        // Status
        let vehicleStatus = vehicle.status
        print("Vehicle Status (Data): \(vehicleStatus)")
        
        // Inventory
        let weight = vehicle.calculateWeight()
        print("Vehicle Weight: \(weight)")
        
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
        // 2.d Boxes
        // FIXME: - Add Boxes to Space Vehicle
        
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
    
    /// `Descent` inventory
    func setupDescentInventory() {
        self.garageStatus = .planning(stage: .Descent)
    }
    
    
    
    func finishedDescentInventory(vehicle:SpaceVehicle, cargo:[StorageBox], devices:[PeripheralObject]) {
        // Needs to implement...
        // Transfer stuff from station to vehicle
        station.truss.extraBoxes.removeAll(where: { cargo.map({ $0.id }).contains($0.id) })
        station.peripherals.removeAll(where: { devices.map({ $0.id }).contains($0.id)})
        
//        vehicle.boxes = vehicle.boxes ?? []
        vehicle.boxes.append(contentsOf: cargo)
        vehicle.peripherals.append(contentsOf: devices)
        
        didSelectBuildEnd(vehicle: vehicle)
//        cancelSelection()
    }
    
    /// Launches a SpaceVehicle to travel to Mars
    func launch(vehicle:SpaceVehicle) {
        
        print("🚀 Launching Vehicle!")
        self.garageStatus = .planning(stage: .Launching)
        
        // Register Vehicle in Server
        
        guard let player = LocalDatabase.shared.player else {
            fatalError()
        }
        let user = SKNUserPost(player: player)
        SKNS.registerSpace(vehicle: vehicle, player: user) { (data, error) in
            if let data = data {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .secondsSince1970
                if let vehicleModel = try? decoder.decode(SpaceVehicleModel.self, from: data) {
                    print("We got a Vehicle ! \(vehicleModel.engine)")
                } else {
                    print("No vehicle model")
                }
            } else {
                print("No data. Error: \(error?.localizedDescription ?? "n/a")")
            }
        }
        
        // Set Vehicle to start travelling
        vehicle.startTravelling()
        
        // Remove from Garage
        garage.buildingVehicles.removeAll(where: { $0.id == vehicle.id })
        
        // Add to Array of travelling vehicles
        LocalDatabase.shared.vehicles.append(vehicle)
        self.travellingVehicles.append(vehicle)
        
        // XP
        garage.xp += 1
        
        // Save
        LocalDatabase.shared.saveVehicles()
        LocalDatabase.shared.saveStation(station: self.station)
        
        // Update View
        self.garageStatus = .planning(stage: .Launching)
        // self.cancelSelection()
 
    }
    
    // FIXME: - Token Use
    
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
            let constraint = SCNLookAtConstraint(target:vehicleNode)
            constraint.isGimbalLockEnabled = true
            constraint.influenceFactor = 0.1
            
            let follow = SCNDistanceConstraint(target: vehicleNode)
            follow.minimumDistance = 20
            follow.maximumDistance = 50
            
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 3.0
            camera.constraints = [constraint, follow]
            SCNTransaction.commit()
        }
        
        
    }
    
//    func move
    
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
