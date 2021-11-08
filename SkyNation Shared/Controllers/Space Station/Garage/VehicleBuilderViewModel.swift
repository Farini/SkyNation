//
//  VehicleBuilderViewModel.swift
//  SkyTestSceneKit
//
//  Created by Carlos Farini on 12/18/20.
//  Copyright © 2020 Farini. All rights reserved.
//

import Foundation

enum SVBuildStage {
    case engineType
    case pickEngineers(type:EngineType)
    case pickMaterials(type:EngineType)
    case namingVehicle(vehicle:SpaceVehicle)
}


class VehicleBuilderViewModel:ObservableObject {
    
    var station:Station
    @Published var garage:Garage
    @Published var availablePeople:[Person]
    
    @Published var vehicle:SpaceVehicle?
    @Published var buildStage:SVBuildStage
    @Published var selectedEngine:EngineType?
    
    @Published var workersArray:[Person] = []
    @Published var hasSkills:Bool = false
    @Published var hasIngredients:Bool = false
    
    @Published var ingredients:[Ingredient:Int] = [:]
    @Published var lackIngredients:[Ingredient] = []
    
    init() {
        // Load Station
        let station = LocalDatabase.shared.station
        self.station = station
        self.garage = station.garage
        
        self.buildStage = .engineType
        availablePeople = station.getPeople().filter { $0.isBusy() == false }
    }
    
    /// When user selected an Engine
    func newEngine(type:EngineType) {
        let newVehicle = SpaceVehicle(engine: type)
        self.vehicle = newVehicle
        self.selectedEngine = type
        self.ingredients = type.ingredients
        self.buildStage = .pickEngineers(type: type) //.pickEngineers(type: type)
    }
    
    /// Checks whether the staff has the skills to build
    func updateStaffList() {
        
        if let skillsRequired = selectedEngine?.skills {
            
            let peopleArray = workersArray
            var missingSkills:[Skills] = []
            
            for (key, value) in skillsRequired {
                
                var valueCount:Int = value // The sum of ppl skills
                for p in peopleArray {
                    let skset:[SkillSet] = p.skills.filter({ $0.skill == key })
                    for sdk in skset {
                        if sdk.skill == key {
                            valueCount -= sdk.level
                        }
                    }
                }
                
                if valueCount > 0 {
                    missingSkills.append(key)
                }
            }
            
            if missingSkills.isEmpty {
                self.hasSkills = true
            } else {
                self.hasSkills = false
            }
            
        } else {
            self.hasSkills = false
        }
    }
    
    /// Checks that the user has the necessary ingredients to build the engine
    func checkIngredients(engine:EngineType) {
        
        self.buildStage = .pickMaterials(type: engine)
        
        let required = self.ingredients
        
        let lacking = station.truss.validateResources(ingredients:required)
        if lacking.isEmpty {
            self.hasIngredients = true
            self.lackIngredients = []
        } else {
            self.hasIngredients = false
            self.lackIngredients = lacking
        }
    }
    
    /// Charge the ingredients of the station
    func chargeIngredients() {
        
        guard let vehicle = vehicle else { fatalError() }
        print("Charge ingredients...")
        
        // Charge Ingredients
        let result = station.truss.payForResources(ingredients: self.ingredients)
        if result == false {
            print("ERROR: Could not pay for resources")
        }
        
        buildStage = .namingVehicle(vehicle: vehicle)
    }
    
    /// User gave the Vehicle a name
    func didNameVehicle(_ name:String) {
        guard let vehicle = vehicle else { fatalError() }
        vehicle.name = name
    }
    
    /// The state of each `Create engine` Button
    func disabledEngine(type:EngineType) -> Bool {
        switch type {
            case .Hex6: return false
            default: return garage.xp < type.requiredXP
        }
    }
}
