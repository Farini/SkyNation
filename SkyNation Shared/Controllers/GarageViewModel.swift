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
    
    // DECPRECATE
//    case Satellite  // Selecting Satellite
    
    case Inventory  // Adding Tanks, Batteries, etc
    case Payload    // Adding Payload (RSS, robot, etc.)
    case Passengers // Selecting Passengers
    case Hiring     // Selecting Staff to work on it
    case Paying     // Paying
    case Confirm    // Confirming
}
/*
enum GarageProgressType {
    case none           // Looking at other vehicles, or main screen
    case engine         // Building V - Deciding what engine
    case satellite      // Building V - Deciding satellite
    case inventory1     // Building V - Adding peripherals
    // ------------
    case payload
    case heatshield
    // -----------
    case ready
    // Build up the costs (engine, satellite, antenna)
    // choose persons involved
    // Person to build Engine
    // Person to build Antenna
    // Person to build Solar Panel (if any)
    // Person to build LSS (if any)
    // show costs + charge
    case viewMission
}
*/

class GarageViewModel:ObservableObject {
    
    // Status
//    @Published var progress:GarageProgressType = .none
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
        
        // Removing (was added)
        if vehicle.tanks.contains(where: { $0.id == tank.id }) {
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
        
//        if vehicle.contains(where: { $0.id == battery.id }) {
//        }
        switch peripheral.peripheral {
        case .Antenna:
            print("Antenna!")
        default:
            print("Not implemented - Edit code here")
        }
    }
    
    /// Sets the Vehicle to start building
    func startBuilding(vehicle:SpaceVehicle) {
        
        station.garage.startBuildingVehicle(vehicle: vehicle)
        self.buildingVehicles.append(vehicle)
        selectedVehicle = vehicle
        garageStatus = .idle
        
    }
    
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
    func didSetupEngine(vehicle:SpaceVehicle) {
        
        selectedVehicle = vehicle
        station.garage.xp += 1
        
//        switch vehicle.engine {
//            case .Hex6: // Skip payload
//                self.garageStatus = .planning(stage:.Inventory)
//            default:
//                self.garageStatus = .planning(stage: .Payload)
//        }
        
        print("Finished setting up engine.")
        
        // Update UI
        self.buildingVehicles.append(vehicle)
        self.didSelectBuilding(vehicle: vehicle)
        
        // Update and save Model
        station.garage.startBuildingVehicle(vehicle: vehicle)
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
        
        let vehicleStatus = vehicle.status
        print("Vehicle Status (Data): \(vehicleStatus)")
        
        self.cancelSelection()
    }
    
    /// Launches a SpaceVehicle to travel to Mars
    func launch(vehicle:SpaceVehicle) {
        
        print("🚀 Launching Vehicle!")
        
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
        self.cancelSelection()
    }
}
