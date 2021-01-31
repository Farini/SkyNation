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
    func startBuildingVehicle(vehicle:SpaceVehicle) {
        
        var time:Double = 0
        time += vehicle.engine.time
        
        //        for panel in solar {
        //            time += panel.size
        //        }
        //        if shell != nil {
        //            time += 20
        //        }
        //        if let heat = vehicle.heatshield {
        //            switch heat {
        //            case .twelve: time += 40
        //            case .eighteen: time += 200
        //            }
        //        }
        //        if let load = payload {
        //            time += load.people.count * 20
        //            time += load.ingredients.count * 10
        //            time += load.tanks.count * 10
        //        }
        
        vehicle.simulation = 0
        vehicle.status = .Creating
        vehicle.dateTravelStarts = Date()
        vehicle.travelTime = Double(time)
        vehicle.antenna = PeripheralObject(peripheral: .Antenna)
        
        self.buildingVehicles.append(vehicle)
    }
    
    
}
