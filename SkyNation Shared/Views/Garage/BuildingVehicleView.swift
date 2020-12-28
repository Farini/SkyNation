//
//  BuildingVehicleView.swift
//  SkyTestSceneKit
//
//  Created by Carlos Farini on 12/4/20.
//  Copyright © 2020 Farini. All rights reserved.
//

import SwiftUI

struct BuildingVehicleView: View {
    
    @ObservedObject var builderController:VehicleBuilderViewModel = VehicleBuilderViewModel()
    @ObservedObject var garageController:GarageViewModel
    
    var body: some View {
        
        VStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: 12) {
            
            Text("Building Vehicle")
                .font(.title)
                .foregroundColor(.orange)
                .padding()
            
            switch builderController.buildStage {
                case .engineType:
                    Spacer()
                    Text("Choose Engine Type").font(.title)
                    HStack {
                        ForEach(EngineType.allCases, id:\.self) { engine in
                            VStack {
                                Text("Engine \(engine.rawValue)").font(.headline)
                                Text("Payload \(engine.payloadLimit)")
                                
                                Button("Make this") {
                                    print("Making some")
                                    builderController.newEngine(type: engine)
                                }
                                .disabled(builderController.disabledEngine(type: engine))
                            }
                        }
                    }.padding()
                    Spacer()
                case .pickEngineers(let engine):
                    
                    let dicSort = engine.skills.sorted(by: {$0.key.rawValue < $1.key.rawValue })
                    Text("PE")
                    Text("\(engine.rawValue)")
                    
                    Text("Required Skills:")
                
                    ForEach(dicSort, id:\.key) { (key, value) in
                        Text("K:\(key.rawValue):\(value)")
                            .foregroundColor(builderController.hasSkills ? .green:.red)
                    }
                    
                    
                    ScrollView([Axis.Set.horizontal], showsIndicators: true) {
                        HStack {
                            ForEach(builderController.availablePeople) { person in
                                PersonSmallView(person: person)
                                    .onTapGesture {
                                        print("Adooorunrun")
                                        builderController.addEngineerToBuild(person: person)
                                    }
                            }
                        }
                    }
                    
                        Button("Build Engine") {
                            builderController.checkIngredients(engine: engine)
                        }
                        .disabled(!builderController.hasSkills)
                    
                case .pickMaterials(let engine):
                    let dicSort = engine.ingredients.sorted(by: {$0.key.rawValue < $1.key.rawValue })
                    Text("Ingredients Required")
                    ForEach(dicSort, id:\.key) { (key, value) in
                        Text("K:\(key.rawValue):\(value)")
                            .foregroundColor(builderController.hasIngredients ? .green:.red)
                    }
                    HStack {
                        Button("Charge Ingredients") {
                            print("Charge?")
                            builderController.chargeIngredients()
                        }
                        .disabled(!builderController.hasIngredients)
                        Button("Cancel") {
                            garageController.cancelSelection()
                        }
                    }
                    
                    
                case .timing(let vehicle):
                    
                    Text("Timing")
                    Text("Timing started")
                    
                    HStack {
                        Button("Done") {
                            garageController.didSetupEngine(vehicle: vehicle)
                        }
                        Button("Cancel") {
                            garageController.cancelSelection()
                        }
                    }
            }
        }
        .frame(minWidth: 600, minHeight: 500, maxHeight: 600, alignment: .center)
    }
}

struct BuildingVehicleView_Previews: PreviewProvider {
    static var previews: some View {
        BuildingVehicleView(garageController: GarageViewModel())
    }
}

