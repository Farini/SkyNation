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
    case timing(vehicle:SpaceVehicle)
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
    
    init() {
        // Load Station
        let station = LocalDatabase.shared.station!
        self.station = station
        self.garage = station.garage
        
        self.buildStage = .engineType
        availablePeople = station.getPeople().filter { $0.isBusy() == false }
    }
    
    func newEngine(type:EngineType) {
        let newVehicle = SpaceVehicle(engine: type)
        self.vehicle = newVehicle
        self.selectedEngine = type
        self.buildStage = .pickEngineers(type: type)
    }
    
    func buildEngine() {
        print("Building Engine")
    }
    
    func addEngineerToBuild(person:Person) {
        workersArray.append(person)
        updateStaffList()
        if self.hasSkills == true {
            print("Bingo")
        }else{
            print("Still needs more skills")
        }
    }
    
    private func updateStaffList() {
        
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
    
    func checkIngredients(engine:EngineType) {
        
        self.buildStage = .pickMaterials(type: engine)
        let required = engine.ingredients
        
        let lacking = station.truss.validateResources(ingredients:required)
        if lacking.isEmpty {
            self.hasIngredients = true
        } else {
            self.hasIngredients = false
        }
        
        //        if station.truss.canCharge(ingredients: required) {
        //            hasIngredients = true
        //        }else{
        //            hasIngredients = false
        //        }
        //
        //        var missingIngredients:[Ingredient] = []
        //        for (key, value) in required {
        //            var valueCount:Int = value
        //            for box in station.truss.extraBoxes.filter({ $0.type == key }) {
        //                valueCount -= box.current
        //            }
        //            if valueCount > 0 {
        //                missingIngredients.append(key)
        //            }
        //        }
        //        if missingIngredients.isEmpty {
        //            hasIngredients = true
        //        }else{
        //            hasIngredients = false
        //        }
    }
    
    func chargeIngredients() {
        print("Charge ingredients...")
        print("Pending the making of the function in station.truss")
        buildStage = .timing(vehicle:vehicle!)
    }
    
    func disabledEngine(type:EngineType) -> Bool {
        switch type {
            case .Hex6: return false
            default: return garage.xp < type.requiredXP
        }
    }
}
