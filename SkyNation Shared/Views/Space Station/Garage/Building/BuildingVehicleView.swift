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
    
    @State private var selectedType:EngineType? = nil
    @State private var currentStep:Int = 1
    
    var body: some View {
        
        VStack(spacing: 12) {
            
            Label("Building Space Vehicle", systemImage: "wrench.and.screwdriver")
                .font(GameFont.title.makeFont())
                .padding(.top, 8)
            
            StepperView(stepCounts: 4, current: self.currentStep, stepDescription: self.descriptionFor(step: currentStep))
            
            switch builderController.buildStage {
                case .engineType:
                    
                    LazyVGrid(columns: columns, alignment: HorizontalAlignment.leading, spacing: 20) {
                        ForEach(EngineType.allCases, id:\.self) { eType in
                            EngineCardHolder(eType: eType) { tappedEngine in
                                print("Tapped Engine: \(tappedEngine)")
                                self.selectedType = tappedEngine
                                // builderController.newEngine(type: tappedEngine)
                            }
                        }
                    }
                    .padding(8)
                    
                    Divider()
                    
                    // Buttons
                    HStack {
                        Button("Cancel") {
                            print("Cancel")
                        }
                        .buttonStyle(GameButtonStyle())
                        
                        if let selected = selectedType {
                            Button {
                                print("Continue with selected \(selected.rawValue)")
                                builderController.newEngine(type: selected)
                                self.currentStep = 2
                            } label: {
                                Label("Build \(selected.rawValue)", systemImage: "play.circle")
                            }
                            .buttonStyle(GameButtonStyle())
                            .disabled(!isUnlocked(type: selected))
                        }
                    }
                    .padding(.bottom)
                    
                case .pickEngineers(let engine):
                    
                    // Skills and People
                    ActivityStaffView(staff: builderController.availablePeople, requiredSkills: engine.skills) { selectedPeople in
                        
                        builderController.workersArray = selectedPeople
                        builderController.updateStaffList()
                    }
                    
                    Divider()
                    
                    // Buttons
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
                            self.currentStep = 3
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
                            self.currentStep = 4
                        }
                        .disabled(!builderController.hasIngredients)
                        .buttonStyle(GameButtonStyle(labelColor: .red))
                        
                    }
                    .transition(.slide.combined(with: .opacity))
                    
                case .namingVehicle(let vehicle):
                    
                    NameVehicleCard(vehicle: vehicle, closeAction: {
                        garageController.didSetupEngine(vehicle: vehicle, workers:builderController.workersArray)
                        self.currentStep = 5
                    }, controller: builderController)
                    
                    
            }
            Spacer()
        }
        .frame(minWidth: 620, maxWidth:900, minHeight: 500, maxHeight: 600, alignment: .center)
        .background(GameColors.darkGray)
    }
    
    func isUnlocked(type:EngineType) -> Bool {
        let xp = LocalDatabase.shared.station.garage.xp
        if type.requiredXP <= xp {
            return true
        } else {
            return false
        }
    }
    
    func descriptionFor(step:Int) -> String {
        switch step {
            case 1: return "Choose an engine"
            case 2: return "Select staff"
            case 3: return "Charge Ingredients"
            case 4: return "Name it"
            case 5: return "You're all set"
            default: return ""
        }
    }
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
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
