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
    @State var vehicleName:String = "Untitled"
    
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
                        LazyHGrid(rows: [GridItem(.flexible(minimum: 180, maximum: 250))], alignment: .top, spacing: /*@START_MENU_TOKEN@*/nil/*@END_MENU_TOKEN@*/, pinnedViews: /*@START_MENU_TOKEN@*/[]/*@END_MENU_TOKEN@*/) {
                            ForEach(EngineType.allCases, id:\.self) { engine in
                                VStack(spacing:8) {
                                    Text("Engine \(engine.rawValue)").font(.headline)
                                        .padding([.top])
                                    Text("Payload \(engine.payloadLimit)")
                                    Text(engine.about)
                                        .foregroundColor(.gray)
                                        .lineLimit(nil)
                                        .frame(maxWidth:130, maxHeight:.infinity)
                                        .padding(4)
                                    Button("Build") {
                                        print("Making some")
                                        builderController.newEngine(type: engine)
                                    }
                                    .disabled(builderController.disabledEngine(type: engine))
                                    .buttonStyle(NeumorphicButtonStyle(bgColor: .orange))
                                    .padding([.bottom])
                                }
                                
                                .background(Color.black)
                                .cornerRadius(12)
                            }
                        }
                    }
                    Spacer()
                case .pickEngineers(let engine):
                    
                    // Skills and People
//                    ScrollView {
                        ActivityStaffView(staff: builderController.availablePeople, selected: [], requiredSkills: engine.skills, chooseWithReturn: { (selectedPeople) in
                            builderController.workersArray = selectedPeople
                            builderController.updateStaffList()
                        }, title: "Engine Skills Required", issue: "", message: "")
//                    }
                    
                    
                    Divider()
                    
                    HStack {
                        Button(action: {
                            garageController.cancelSelection()
                        }) {
                            HStack {
                                Image(systemName: "backward.frame")
                                Text("Back")
                            }
                        }
                        .buttonStyle(NeumorphicButtonStyle(bgColor: .gray))
                        .help("Go back")
                        
                        Button("Build Engine") {
                            builderController.checkIngredients(engine: engine)
                        }
                        .disabled(!builderController.hasSkills)
                        .buttonStyle(NeumorphicButtonStyle(bgColor: .orange))
                    }
                    
                case .pickMaterials(let engine):
                    
                    // Ingredients
                    let dicSort = engine.ingredients.sorted(by: {$0.key.rawValue < $1.key.rawValue })
                    Text("Ingredients Required")
                    ForEach(dicSort, id:\.key) { (key, value) in
                        Text("K:\(key.rawValue):\(value)")
                            .foregroundColor(builderController.hasIngredients ? .green:.red)
                    }
                    HStack {
                        
                        Button("Cancel") {
                            garageController.cancelSelection()
                        }
                        .buttonStyle(NeumorphicButtonStyle(bgColor: .orange))
                        
                        Button("Charge Ingredients") {
                            builderController.chargeIngredients()
                        }
                        .disabled(!builderController.hasIngredients)
                        .buttonStyle(NeumorphicButtonStyle(bgColor: .orange))
                        
                    }
                    
                case .namingVehicle(let vehicle):
                    
                    NameVehicleCard(vehicle: vehicle, closeAction: {
                        garageController.didSetupEngine(vehicle: vehicle, workers:builderController.workersArray)
                    }, controller: builderController)
                    
                
                // DEPRECATE
//                case .timing(let vehicle):
//
//                    Text("Timing: \(vehicle.name)")
//                    Text("Timing started")
                    
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

struct NameVehicleCard: View {
    
    var vehicle:SpaceVehicle
    var closeAction:() -> Void = {}
    
    @ObservedObject var controller:VehicleBuilderViewModel
    
    @State var vehicleName:String = ""
    @State private var visibleSide = FlipViewSide.front
    
    var shape = RoundedRectangle(cornerRadius: 16, style: .continuous)
    
    var body: some View {
        
        FlipView(visibleSide: visibleSide) {

            VStack {
                Text("Name your vehicle")
                    .font(.title)
                    .foregroundColor(.gray)
                    .padding([.top, .bottom])
                
                Divider()
                
                TextField("Vehicle name", text: $vehicleName)
                    .frame(minWidth: 120, maxWidth: 180)
                
                Text("Max 10 Characters")
                    .foregroundColor(vehicleName.count > 10 ? .red:.gray)
                
                Button("Continue") {
                    vehicle.name = vehicleName
                    flipCard()
                }
                .buttonStyle(NeumorphicButtonStyle(bgColor: .orange))
                .disabled(vehicleName.count > 10)
                .padding()
            }
            
            .frame(width: 200, height: 300, alignment: .top)
            .background(Color.black)
            .clipShape(shape)
            .overlay(
                shape
                    .inset(by: 0.5)
                    .stroke(Color.primary.opacity(0.1), lineWidth: 1)
            )
            .contentShape(shape)
            .accessibilityElement(children: .contain)
            
        } back: {
            VStack {
                Text("Confirmation")
                    .font(.headline)
                    .foregroundColor(.gray)
                    .padding([.top], 6)
                
                Divider()
                
                Text("\(vehicle.name)")
                    .font(.title)
                    .foregroundColor(.orange)
                
                HStack(alignment:.center) {
                    Image(systemName: "gearshape.fill")
                        .font(.title)
                    VStack {
                        Text("Engine").foregroundColor(.gray)
                        Text("\(vehicle.engine.rawValue)")
                            .fontWeight(.bold)
                    }
                }
                .padding([.top, .bottom])
                .frame(width: 170)
                .background(Color("Prograd2"))
                .cornerRadius(4.0)
                .padding([.top])
                
                HStack(alignment:.center) {
                    Image(systemName: "scalemass")
                        .font(.title)
                    VStack {
                        Text("Payload limit").foregroundColor(.gray)
                        Text("\(vehicle.engine.payloadLimit * 100) Kg")
                            .fontWeight(.bold)
                    }
                }
                .padding([.top, .bottom])
                .frame(width: 170)
                .background(Color("Prograd1"))
                .cornerRadius(4.0)
                .padding([.top])
                
                Divider()
                
                // Buttons
                HStack {
                    Button("❌ Back") {
                        flipCard()
                    }
                    .buttonStyle(NeumorphicButtonStyle(bgColor: .orange))
                    
                    Button("✅ Done") {
                        closeAction()
                    }
                    .buttonStyle(NeumorphicButtonStyle(bgColor: .orange))
                    
                }
                .padding(6)
            }
            
            .frame(width: 200, height: 300, alignment: .top)
            .background(Color.black)
            .clipShape(shape)
            .overlay(
                shape
                    .inset(by: 0.5)
                    .stroke(Color.primary.opacity(0.1), lineWidth: 1)
            )
            .contentShape(shape)
            .accessibilityElement(children: .contain)
            
        }
        .contentShape(Rectangle())
        .animation(.flipCard, value: visibleSide)
    }
    
    func flipCard() {
        visibleSide.toggle()
    }
}

extension Animation {
    static let openCard = Animation.spring(response: 0.45, dampingFraction: 0.9)
    static let closeCard = Animation.spring(response: 0.35, dampingFraction: 1)
    static let flipCard = Animation.spring(response: 0.35, dampingFraction: 0.7)
}
