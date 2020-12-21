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
    case Satellite  // Selecting Satellite
    case Inventory  // Adding Tanks, Batteries, etc
    case Payload    // Adding Payload (RSS, robot, etc.)
    case Passengers // Selecting Passengers
    case Hiring     // Selecting Staff to work on it
    case Paying     // Paying
    case Confirm    // Confirming
}

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

class GarageViewModel:ObservableObject {
    
    // Status
//    @Published var progress:GarageProgressType = .none
    @Published var garageStatus:GarageStatus = .idle
    @Published var station:Station
    @Published var garage:Garage
    
    // Data
    @Published var unlockedRecipes:[Recipe]
    @Published var unlockedTech:[TechTree]
    @Published var selectedVehicle:SpaceVehicle?
    @Published var buildingVehicles:[SpaceVehicle] = []
    @Published var builtVehicles:[SpaceVehicle] = []
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
        buildingVehicles = station.garage.buildingVehicles
        travellingVehicles = LocalDatabase.shared.vehicles
        availablePeople = station.getPeople().filter { $0.isBusy() == false }
        
        // Afet init
        
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
    
    func build(vehicle:SpaceVehicle) {
        
        // + Antenna
        // + Solar
        // + Peripherals
        // + Shell
        // [X] Batteries
        // [X] Tanks (fuel)
        
        // Batteries
        let batteryOptions = station.truss.batteries
        print("Battery Options:")
        for b in batteryOptions {
            print("Battery cap \(b.capacity) current:\(b.current)")
        }
        
        // Tanks
        let tankOptions = station.truss.getTanks()
        print("Tank Options:")
        for t in tankOptions {
            print("Tank cap \(t.capacity) current:\(t.current)")
        }
        
        self.selectedVehicle = vehicle
//        self.progress = .inventory1
    }
    
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
    
    // MARK: - New
    func disabledEngine(type:EngineType) -> Bool {
        switch type {
        case .Hex6: return false
        default: return garage.xp < type.requiredXP
        }
    }
    
    /// Selected a vehicle that is building
    func didSelectBuilding(vehicle:SpaceVehicle) {
        selectedVehicle = vehicle
        garageStatus = .selectedBuilding(vehicle: vehicle)
    }
    
    func didSelectBuildEnd(vehicle:SpaceVehicle) {
        self.selectedVehicle = vehicle
        garageStatus = .selectedBuildEnd(vehicle: vehicle)
    }
    
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
    
    func startNewVehicle() {
        garageStatus = .planning(stage: .Engine)
    }
    
    // Vehicle Building
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
        self.cancelPlanning()
    }
    
    // Planning
    
    func newEngine(type:EngineType) {
        let newVehicle = SpaceVehicle(engine: type)
        self.selectedVehicle = newVehicle
        self.garageStatus = .planning(stage: .Satellite)
    }
    
    func planSatellite(isAdding:Bool) {
        
        // Add on/off to sat
        // Set the satellite here
        
        switch selectedVehicle!.engine {
        case .Hex6: // Skip payload
            self.garageStatus = .planning(stage:.Inventory)
        default:
            self.garageStatus = .planning(stage: .Payload)
        }
    }
    
    func didSetupEngine(vehicle:SpaceVehicle) {
        selectedVehicle = vehicle
        switch vehicle.engine {
            case .Hex6: // Skip payload
                self.garageStatus = .planning(stage:.Inventory)
            default:
                self.garageStatus = .planning(stage: .Payload)
        }
    }
    
    /// Resets the view to the beginning state
    func cancelPlanning() {
        self.selectedVehicle = nil
        self.garageStatus = .idle
    }
}
