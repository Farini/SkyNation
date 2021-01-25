//
//  ModulesViewModel.swift
//  SkyTestSceneKit
//
//  Created by Farini on 8/31/20.
//  Copyright © 2020 Farini. All rights reserved.
//

import Foundation
//import SpriteKit
//import GameKit
import SwiftUI

enum ModuleBuilderState:Equatable {
    case Selecting
    case Selected(type:ModuleType)
    case Problematic
    case Confirmed
}

class ModulesViewModel: ObservableObject {
    
    var station:Station
    
    @Published var viewState:ModuleBuilderState = .Selecting
    
    /// Volume of air available in the `Station`
    @Published var airVolume:Int
    
    /// Total air required
    @Published var reqVolume:Int
    
    /// Additional air required
    @Published var reqAirFromTanks:Int
    
    /// Air available in Station Tanks
    @Published var availableAirInTanks:Int
    
    /// Total active modules in the station
    @Published var countOfModules:Int
    
    /// Allowed to build another module
    @Published var canBuild:Bool
    
    /// Problems (or solutions) generates
    @Published var problems:[String] = []
    
    init() {
        
        let db = LocalDatabase.shared
        let station = db.station!
        
        self.station = station
        
        // Count Modules
        let modCount = station.labModules.count + station.habModules.count + station.bioModules.count + 1 // Add 1 for proposed new module
        
        self.countOfModules = modCount
        
        // Air:
        
        // Required
        let requiredVolume = station.calculateNeededAir() + GameLogic.airPerModule
        self.reqVolume = requiredVolume
        
        // Available
        let currentAirVolume = station.air.getVolume()
        self.airVolume = currentAirVolume
        
        // Needed
        let additionalAirNeeded = requiredVolume - currentAirVolume
        self.reqAirFromTanks = additionalAirNeeded
        
        let airInTanks = station.truss.tanks.filter({ $0.type == .air }).map({$0.current}).reduce(0, +)
        self.availableAirInTanks = airInTanks
        
        // Can build
        self.canBuild = airInTanks >= additionalAirNeeded
        
    }
    
    /// Tries to balance air in station. Returns whether this is possible.
    func accountNewAir() -> Bool {
        
        // Check if there is enough air in the station
        // if there isn't, then try to release some air
        // if cant release the air, show the problem in interface
        
        print("Accounting for new air")
        
        // Required
        let requiredAirVolume = station.calculateNeededAir() + GameLogic.airPerModule
        print("Req Air: \(requiredAirVolume)")
        
        // Available
        let availableAirVolume = station.air.getVolume()
        print("Available: \(availableAirVolume)")
        
        let neededVolume:Int = requiredAirVolume - availableAirVolume
        print("Needed: \(neededVolume)")
        
        if neededVolume <= 0 {
            self.canBuild = true
            self.problems = ["Using \(neededVolume) of \(availableAirVolume) air"]
            return true
        } else if neededVolume > 0 {
            
            // try to get air from tanks
            let airTanks = station.truss.tanks.filter({ $0.type == .air })
            let totalAirInTanks:Int = airTanks.map({$0.current}).reduce(0, +)
            
            if totalAirInTanks >= neededVolume {
                
                // There is enough air. Charge the air from truss tanks
                var deltaAir = neededVolume
                while deltaAir > 0 {
                    for tank in airTanks {
                        if tank.current >= deltaAir {
                            tank.current -= deltaAir
                            deltaAir = 0
                        } else {
                            deltaAir -= tank.current
                            tank.current = 0
                        }
                    }
                }
                
                // Release the air in station
                station.addControlledAir(amount: neededVolume)
                self.problems = ["Added \(neededVolume) air"]
                self.canBuild = true
                
                return true
                
            } else {
                self.problems = ["Not enough air"]
                self.canBuild = false
                return false
            }
            
        } else {
//            if neededVolume < 0 {
                //            // put some air back in tanks (not needed in this case)
                //            let refill = abs(neededVolume)
                //
                //            if (station.truss.refillTanks(of: .air, amount: refill)) > 0 {
                //                // spill!
                //
                //            } else {
                //                // Success refilling
                //            }
                //        }
            return true
        }
        
        // Don't save
    }
    
    func selectModule(type:ModuleType, id:UUID) {
        
        if accountNewAir() == false {
            self.viewState = .Problematic
            return
        }
        
        let newBuilder = StationBuilder(station: station)
        for module in newBuilder.getModules() {
            print("[0] Other M: \(module.id)")
            if module.id == id {
                print("[=] Matched a module: \(type) ID:\(id)")
                switch type {
                    case .Lab:
                        let newLab:LabModule = module.convertToLab()
                        module.type = .Lab
                        station.labModules.append(newLab)
                        self.viewState = .Selected(type: .Lab)
                        
                    case .Hab:
                        let newHab:HabModule = module.convertToHab()
                        module.type = .Hab
                        station.habModules.append(newHab)
                        self.viewState = .Selected(type: .Hab)
                        
                    case .Bio:
                        let newBio:BioModule = module.convertToBio()
                        module.type = .Bio
                        station.bioModules.append(newBio)
                        self.viewState = .Selected(type: .Bio)
                        
                    default: return
                }
            }
        }
    }
    
    /// Sets the viewState back to `Selecting`
    func cancelBuildModule() {
        self.viewState = .Selecting
    }
    
    
    func confirmBuildingModule() {
        print("Confirm and save")
        self.viewState = .Confirmed
//        LocalDatabase.shared.saveSerialBuilder(builder: builder)
        LocalDatabase.shared.saveStation(station: station)
        
    }
    
    
}
