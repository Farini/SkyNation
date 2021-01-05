//
//  ModulesViewModel.swift
//  SkyTestSceneKit
//
//  Created by Farini on 8/31/20.
//  Copyright © 2020 Farini. All rights reserved.
//

import Foundation

enum ModuleBuilderState:Equatable {
    case Selecting
    case Selected(type:ModuleType)
    case Problematic
    case Confirmed
}

class ModulesViewModel: ObservableObject {
    
    var builder:SerialBuilder
    var station:Station
    
    @Published var viewState:ModuleBuilderState = .Selecting
    
    /// Volume of air available in the `Station`
    @Published var airVolume:Int
    
    /// Required air to build another modukle
    @Published var reqVolume:Int
    
    /// Total active modules in the station
    @Published var countOfModules:Int
    
    /// Allowed to build another module
    @Published var canBuild:Bool
    
    /// Problems (or solutions) generates
    @Published var problems:[String] = []
    
    
    init() {
        
        let db = LocalDatabase.shared
        builder = db.builder
        let station = db.station!
        
        self.station = station
        
        // Count Modules
        let modCount = station.labModules.count + station.habModules.count + station.bioModules.count + 1 // Add 1 for proposed new module
        
        self.countOfModules = modCount
        
        // Air:
        
        // Required
        let requiredVolume = GameLogic.airPerModule * modCount
        self.reqVolume = requiredVolume
        
        // Available
        self.airVolume = station.air.getVolume()
        
        // Can build
        self.canBuild = true // requiredVolume <= airVolume ? true:false
    }
    
    /// Tries to balance air in station. Returns whether this is possible.
    func accountNewAir() -> Bool {
        
        // Check if there is enough air in the station
        // if there isn't, then try to release some air
        // if cant release the air, show the problem in interface
        
        print("Accounting for new air")
        
        let modulesCount = station.labModules.count + station.habModules.count + station.bioModules.count + 1 // Add 1 for proposed new module
        
        print("Modules: \(modulesCount)")
        
        // Required
        let requiredAirVolume = GameLogic.airPerModule * modulesCount // * 0.85 // 85% is required
        print("Req Air: \(requiredAirVolume)")
        
        // Available
        let availableAirVolume = station.air.getVolume()
        print("Available: \(availableAirVolume)")
        
        let neededVolume:Int = availableAirVolume - requiredAirVolume
        print("Needed: \(neededVolume)")
        
        if availableAirVolume > neededVolume {
            self.canBuild = true
            self.problems = ["Using \(neededVolume) of \(availableAirVolume) air"]
            return true
        }
        
        if neededVolume > 0 {
            // try to get air from tanks
            let airTanks = station.truss.tanks.filter({ $0.type == .air })
            let totalAirInTanks:Int = airTanks.map({$0.current}).reduce(0, +)
            
            if totalAirInTanks >= neededVolume {
                // OK.
                
                // Charge the air from truss tanks
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
        
        for module in builder.modules {
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
        LocalDatabase.shared.saveSerialBuilder(builder: builder)
        LocalDatabase.shared.saveStation(station: station)
        
    }
    
    
}
