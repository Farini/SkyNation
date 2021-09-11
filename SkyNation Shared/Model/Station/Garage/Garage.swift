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
    var botTech:Int
    var simulator:Int
    var simulationXP:Int
    
    /// The garage Skin, in case we ever create one.
    var skin:String?
    
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
        
        vehicle.status = .Creating
        vehicle.dateTravelStarts = Date()
        vehicle.travelTime = Double(time)
        
        self.buildingVehicles.append(vehicle)
    }
    
    
}
