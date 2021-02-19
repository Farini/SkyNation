//
//  Garage.swift
//  SkyNation
//
//  Created by Carlos Farini on 1/31/21.
//

import Foundation

class Garage:Codable {
    
    var xp:Int
    var vehicles:[SpaceVehicle]
    var buildingVehicles:[SpaceVehicle]
    var destination:String?
    var botTech:Int
    var simulator:Int
    var simulationXP:Int
    
    init() {
        self.xp = 0
        vehicles = []
        botTech = 0
        simulator = 0
        simulationXP = 0
        buildingVehicles = []
    }
    
    /// Adds to the array **buildingVehicles**
    func startBuildingVehicle(vehicle:SpaceVehicle, time:Double) {
        
        vehicle.simulation = 0
        vehicle.status = .Creating
        vehicle.dateTravelStarts = Date()
        vehicle.travelTime = Double(time)
        vehicle.antenna = PeripheralObject(peripheral: .Antenna)
        
        self.buildingVehicles.append(vehicle)
    }
    
    
}
