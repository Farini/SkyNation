//
//  BuildingBioBoxView.swift
//  SkyNation
//
//  Created by Carlos Farini on 7/27/21.
//

import SwiftUI

/// Building a new Bio Box
struct BuildingBioBoxView: View {
    
    @ObservedObject var controller:BioModController
    
    @State var chosenDNA:DNAOption = DNAOption.allCases.filter({ $0.isAnimal == false }).randomElement()!     // The DNA chosen
    @State var sliderValue:Double = 0.0                 // The population Size
    @State var productionCost:[Ingredient:Int] = [.Fertilizer:0]
    @State var productionEnergyCost:Int = 0
    @State var productionWaterCost:Int = 0
    @State var problems:[String] = []
    
    let dnaOptions:[DNAOption] = DNAOption.allCases.filter({ $0.isAnimal == false })
    
    let minimumLimit:Int = 5
    
    var body: some View {
        
        VStack {
            
            // Title
            Text("New Bio Box")
                .font(.title)
                .padding()
            Text("The longer the name, the harder it is to evolve to its DNA")
                .foregroundColor(.gray)
            
            Divider()
            
            // ---
            // Add a picker to select mode (if population hasn't grown yet, we cant move forward)
            // Allow the user to "trim" population
            
            // Add an outter HStack
            // To the right, insert Timer (So the population can grow, and user may "crop")
            // ---
            
            HStack(alignment:.top) {
                
                // Pickers
                VStack(alignment:.leading) {
                    
                    // Picker Perfect DNA
                    HStack {
                        Text("Box DNA").padding(.leading, 6)
                        Picker(selection: $chosenDNA, label: Text("")){
                            ForEach(self.dnaOptions, id:\.self) { dna in
                                Text("\(dna.emoji) | \(dna.rawValue)")
                            }
                        }
                        .frame(maxWidth: 200, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                    }
                    
                    // Box Size
                    HStack {
                        Text("Box Size").padding(.leading, 8)
                        
                        VStack(alignment: .leading) {
                            ZStack {
                                Slider(value: $sliderValue, in: 0.0...Double(controller.availableSlots)) { (changed) in
                                    print("Slider changed \(changed)")
                                    let boxSize = Int(sliderValue)
                                    productionCost[.Fertilizer] = boxSize
                                    productionWaterCost = boxSize * GameLogic.bioBoxWaterConsumption
                                    productionEnergyCost = 7 * GameLogic.bioBoxEnergyConsumption
                                }
                                .frame(maxWidth: 200, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                                .padding(4)
                                
                                Text("\(Int(sliderValue)) of \(controller.availableSlots)")
                                    .offset(x: 80, y: /*@START_MENU_TOKEN@*/10.0/*@END_MENU_TOKEN@*/)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    
                    HStack {
                        Spacer()
                        Image(systemName: "timer")
                        Text("Time: 1h")
                        Spacer()
                    }
                    .frame(minWidth: 200, maxWidth:280, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                    .font(.headline)
                    
                    HStack {
                        Spacer()
                        #if os(macOS)
                        Image(nsImage: GameImages.tokenImage)
                            .resizable()
                            .frame(width: 22, height: 22, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                            .aspectRatio(contentMode: .fill)
                        #else
                        Image(uiImage: GameImages.tokenImage)
                            .resizable()
                            .frame(width:22, height:22, alignment:.center)
                            .aspectRatio(contentMode: .fill)
                        #endif
                        Text("Tokens 2")
                        Spacer()
                    }
                    .frame(minWidth: 200, maxWidth:280, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                    .font(.headline)
                }
                .padding([.trailing], 10)
                Divider()
                
                // Costs
                VStack(alignment:.leading) {
                    
                    Text("Costs").foregroundColor(.gray) //.font(.title)
                    Divider().frame(width:150)
                    HStack {
                        
                        Ingredient.Fertilizer.image()!
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 22, height: 22, alignment: .center)
                        
                        Text("Fertilizer: \(productionCost[.Fertilizer] ?? 0) of \(controller.availableFertilizer)")
                    }
                    .foregroundColor(controller.availableFertilizer >= productionCost[.Fertilizer] ?? 0 ? .green:.red)
                    
                    HStack {
                        Ingredient.Water.image()!
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 22, height: 22, alignment: .center)
                        Text("Water: \(productionWaterCost) of \(controller.availableWater)")
                    }
                    .foregroundColor(controller.availableWater >= productionWaterCost ? .green:.red)
                    
                    HStack {
                        
                        Ingredient.Battery.image()!
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 22, height: 22, alignment: .center)
                        Text("Energy: \(productionEnergyCost) of \(controller.availableEnergy)")
                        
                    }
                    .foregroundColor(controller.availableEnergy >= productionEnergyCost ? .green:.red)
                    
                    //                    Text("Time: ?")
                }
                .padding()
                .background(Color.black)
                .cornerRadius(12)
                .padding(.horizontal)
                Spacer()
            }
            .padding()
            
            Divider().offset(x: 0, y: -3)
            
            // People Picker
            ActivityStaffView(staff: controller.availablePeople, requiredSkills: [.Biologic:1]) { selectedPeople in
                controller.selectedPeople = selectedPeople
            }
//            ActivityStaffView(staff: controller.availablePeople, selected: [], requiredSkills: [.Biologic:1], chooseWithReturn: { (selectedPeople) in
//                controller.selectedPeople = selectedPeople
//            }, title: "Select Biologist", issue: "", message: "")
            
            // Warnings
            Group {
                if !problems.isEmpty {
                    Text("Warnings")
                }
                ForEach(self.problems, id:\.self) { problemo in
                    Text("⚠️ \(problemo)")
                        .foregroundColor(.red)
                }
            }
            
            
            // Buttons (Confirm, Cancel)
            HStack {
                
                Button(action: {
                    print("Back Button Pressed")
                    controller.cancelBoxSelection()
                }) {
                    HStack {
                        Image(systemName: "backward.frame")
                        Text("Back")
                    }
                }
                .buttonStyle(NeumorphicButtonStyle(bgColor: .gray))
                .help("Go back")
                .frame(width:100)
                
                Button("Create") {
                    let possibleProblems = controller.validateResources(box: Int(sliderValue))
                    self.problems = possibleProblems
                    if possibleProblems.isEmpty {
                        print("Confirming...")
                        self.confirmBioBox()
                    }
                }
                .buttonStyle(NeumorphicButtonStyle(bgColor: .orange))
                .disabled(Int(sliderValue) < minimumLimit)
                
                Button("Use \(Int(sliderValue/10.0) + 1) Tokens ") {
                    print("Pay with tokens ??? ^^")
                    let problems = controller.validadeTokenPayment(box: Int(sliderValue), tokens: Int(sliderValue/10.0) + 1)
                    self.problems = problems
                    if problems.isEmpty {
                        self.confirmBioBox()
                    }
                }
                .buttonStyle(NeumorphicButtonStyle(bgColor: .orange))
                .disabled(Int(sliderValue) < minimumLimit)
                
            }
            .padding()
        }
    }
    
    func confirmBioBox() {
        
        // 1 - Pass the chosen DNA
        let choice = chosenDNA
        
        // 2 - Pass the slider value (population size)
        let size = Int(sliderValue)
        
        // 3 - Create New Box
        controller.createNewBox(dna: choice, size: size)
        
    }
    
}

struct BioBuilder2_Previews: PreviewProvider {
    static var previews: some View {
        if let bioModule = LocalDatabase.shared.station.bioModules.first {
            return BuildingBioBoxView(controller: BioModController(module: bioModule)) //BioView(bioMod: bioModule)
        }else{
            return BuildingBioBoxView(controller: BioModController(module: BioModule.example))
        }
    }
}
