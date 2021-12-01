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
                // GameMessageBoard.shared.newAchievement(type: .vehicleLanding(vehicle: vehicle), money: 500, message: nil)
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
        
        didSelectBuildEnd(vehicle: vehicle)
    }
    
    func runPropulsionCheck(vehicle:SpaceVehicle) -> PropulsionCheckObject {
        
        let types:[TankType] = [TankType.ch4, TankType.n2]
        let propulsionTanks:[Tank] = station.truss.tanks.filter({ types.contains($0.type) && $0.current > 0 })
        
        let nitroAmount = vehicle.engine.propulsionNitro
        let ch4Amount = vehicle.engine.propulsionCH4
        
        // Check Nitro
        var nitroCheck:Bool = false
        let nitroNeeded:Int = vehicle.engine.propulsionNitro
        var nitroAvailable:Int = 0
        
        if nitroAmount > 0 {
            let result = propulsionTanks.filter({ $0.type == .n2 }).compactMap({ $0.current }).reduce(0, +)
            nitroAvailable = result
            
            if result > nitroAmount {
                // ok
                nitroCheck = true
            } else {
                // not enough
            }
        } else {
            // not needed
        }
        
        var chCheck:Bool = false
        let chNeeded:Int = vehicle.engine.propulsionCH4
        var chAvailable:Int = 0
        
        if ch4Amount > 0 {
            let result = propulsionTanks.filter({ $0.type == .ch4 }).compactMap({ $0.current }).reduce(0, +)
            chAvailable = result
            
            if result > nitroAmount {
                // ok
                chCheck = true
                
            } else {
                // not enough
            }
        } else {
            // not needed
        }
        
        let obj = PropulsionCheckObject(ch4Available: chAvailable, ch4Needed: chNeeded, ch4Check: chCheck, n2Available: nitroAvailable, n2Needed: nitroNeeded, n2Check: nitroCheck)
        return obj
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
        
        // Charge propulsion
        var chargeRes:Bool = false
        if vehicle.engine.propulsionNitro > 0 {
            let res = station.truss.chargeFrom(tank: .n2, amount: vehicle.engine.propulsionNitro)
            chargeRes = res > 0
        }
        if chargeRes == false {
            if vehicle.engine.propulsionCH4 > 0 {
                let res = station.truss.chargeFrom(tank: .ch4, amount: vehicle.engine.propulsionCH4)
                // if res > 0, we can't charge (not enough)
                chargeRes = res > 0
            }
        }
        print("Charging propulsion result: \(chargeRes)")
        
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
            
        // Update View
        self.garageStatus = .planning(stage: .Launching)
        
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
                            GameMessageBoard.shared.newAchievement(type: .experience, money: 200, message: "Space Vehicle Registered.")
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

//import SceneKit


/*
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
*/
struct PropulsionCheckObject {
    
    var ch4Available:Int
    var ch4Needed:Int
    var ch4Check:Bool
    
    var n2Available:Int
    var n2Needed:Int
    var n2Check:Bool
    
}
