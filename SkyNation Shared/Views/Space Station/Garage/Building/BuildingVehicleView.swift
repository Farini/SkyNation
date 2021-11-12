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
        
        VStack(spacing: 12) {
            
            Label("Building Vehicle", systemImage: "wrench.and.screwdriver")
                .font(GameFont.title.makeFont())
                .padding(.top, 8)
            
            switch builderController.buildStage {
                case .engineType:
                    
                    Text("Choose Engine Type")
                        .font(GameFont.section.makeFont())
                        .foregroundColor(.orange)
                        //.padding()
                    
                    Divider()
                    
                    HStack {
                        Spacer()
                        LazyHGrid(rows: [GridItem(.flexible(minimum: 200, maximum: 250))], alignment: .top, spacing: /*@START_MENU_TOKEN@*/nil/*@END_MENU_TOKEN@*/, pinnedViews: /*@START_MENU_TOKEN@*/[]/*@END_MENU_TOKEN@*/) {
                            ForEach(EngineType.allCases, id:\.self) { engine in
                                VStack(spacing:8) {
                                    Text("Engine \(engine.rawValue)").font(.headline)
                                        .padding([.top], 6)
                                    Text("Max \(engine.payloadLimit)00 Kg")
                                    Image(systemName: engine.imageSName).font(.title)
                                    Text(engine.about)
                                        .font(.footnote)
                                        .foregroundColor(.gray)
                                        .lineLimit(6)
                                        .frame(maxWidth:130, maxHeight:.infinity)
                                        .padding(4)
                                        .fixedSize(horizontal: false, vertical: true)
                                    
                                    Text("XP > \(engine.requiredXP)")
                                        .foregroundColor(.gray)
                                        .lineLimit(nil)
                                        .frame(maxWidth:130, maxHeight:20)
                                        // .padding(4)
                                    Text("⏱ \(engine.time.stringFromTimeInterval())")
                                    Button("Build") {
                                        print("Making some")
                                        builderController.newEngine(type: engine)
                                    }
                                    .disabled(builderController.disabledEngine(type: engine))
                                    .buttonStyle(NeumorphicButtonStyle(bgColor: .orange))
                                    .padding([.bottom])
                                }
                                .padding(.vertical, 8)
                                .background(Color.black)
                                .cornerRadius(12)
                                .frame(height: 250, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                            }
                        }
                        Spacer()
                    }
                    
                case .pickEngineers(let engine):
                    
                    // Skills and People
                    ActivityStaffView(staff: builderController.availablePeople, requiredSkills: engine.skills) { selectedPeople in
                        
                        builderController.workersArray = selectedPeople
                        builderController.updateStaffList()
                    }
                    
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
                    .transition(.slide.combined(with: .opacity))
                    
                case .pickMaterials(let engine):
                    
                    // Ingredients
                    let dicSort = builderController.ingredients.sorted(by: {$0.key.rawValue < $1.key.rawValue })
                    Text("Engine \(engine.rawValue)")
                    
                    Text("Ingredients Required")
                    LazyVGrid(columns: [GridItem(.fixed(100)), GridItem(.fixed(100)), GridItem(.fixed(100)), GridItem(.fixed(100)), GridItem(.fixed(100))], alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: 8, pinnedViews: /*@START_MENU_TOKEN@*/[]/*@END_MENU_TOKEN@*/, content: {
                        ForEach(dicSort, id:\.key) { (key, value) in
                            let lacker:Bool = builderController.lackIngredients.contains(key)
                            IngredientSufficiencyView(ingredient: key, required: value, available: lacker ? 0:value)
                        }
                    })
                    
                    
                    HStack {
                        
                        Button("Cancel") {
                            garageController.cancelSelection()
                        }
                        .buttonStyle(NeumorphicButtonStyle(bgColor: .orange))
                        
                        Button("Charge") {
                            builderController.chargeIngredients()
                        }
                        .disabled(!builderController.hasIngredients)
                        .buttonStyle(GameButtonStyle(labelColor: .red))
                        
                    }
                    .transition(.slide.combined(with: .opacity))
                    
                case .namingVehicle(let vehicle):
                    
                    NameVehicleCard(vehicle: vehicle, closeAction: {
                        garageController.didSetupEngine(vehicle: vehicle, workers:builderController.workersArray)
                    }, controller: builderController)
                    
                    
            }
            Spacer()
        }
        .frame(minWidth: 600, minHeight: 500, maxHeight: 600, alignment: .center)
        .background(GameColors.darkGray)
    }
}


struct BuildingVehicleView_Previews: PreviewProvider {
    static var previews: some View {
        BuildingVehicleView(garageController: GarageViewModel())
            .preferredColorScheme(.dark)
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
                    // .font(.title)
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
                .padding([.top, .bottom], 8)
                .frame(width: 170)
                .background(Color("Prograd2"))
                .cornerRadius(4.0)
                .padding([.top], 8)
                
                HStack(alignment:.center) {
                    Image(systemName: "scalemass")
                        .font(.title)
                    VStack {
                        Text("Payload limit").foregroundColor(.gray)
                        Text("\(vehicle.engine.payloadLimit * 100) Kg")
                            .fontWeight(.bold)
                    }
                }
                .padding([.top, .bottom], 8)
                .frame(width: 170)
                .background(Color("Prograd1"))
                .cornerRadius(4.0)
                .padding([.top], 8)
                
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
