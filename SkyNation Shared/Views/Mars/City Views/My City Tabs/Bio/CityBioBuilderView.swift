//
//  CityBioBuilderView.swift
//  SkyNation
//
//  Created by Carlos Farini on 9/25/21.
//

import SwiftUI

struct CityBioBuilderView: View {
    
    @ObservedObject var controller:LocalCityController
    var onCancelSelection:(() -> (Void))  = {}
    
    @State var chosenDNA:DNAOption = DNAOption.allCases.filter({ $0.isAnimal == false }).randomElement()!     // The DNA chosen
    @State var sliderValue:Double = 0.0                 // The population Size
    @State var productionCost:[Ingredient:Int] = [.Fertilizer:0]
    @State var productionEnergyCost:Int = 0
    @State var productionWaterCost:Int = 0
    @State var problems:[String] = []
    @State var selectedPeople:[Person] = []
    
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
                                Slider(value: $sliderValue, in: 0.0...Double(controller.cityData.availableBioSlots())) { (changed) in
                                    print("Slider changed \(changed)")
                                    let boxSize = Int(sliderValue)
                                    productionCost[.Fertilizer] = boxSize
                                    productionWaterCost = boxSize * GameLogic.bioBoxWaterConsumption
                                    productionEnergyCost = 7 * GameLogic.bioBoxEnergyConsumption
                                }
                                .frame(maxWidth: 200, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                                .padding(4)
                                
                                Text("\(Int(sliderValue)) of \(controller.cityData.availableBioSlots())")
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
                        
                        Text("Fertilizer: \(productionCost[.Fertilizer] ?? 0) of \(self.availableFertilizer())")
                    }
                    .foregroundColor(self.availableFertilizer() >= productionCost[.Fertilizer] ?? 0 ? .green:.red)
                    
                    HStack {
                        Ingredient.Water.image()!
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 22, height: 22, alignment: .center)
                        Text("Water: \(productionWaterCost) of \(controller.cityData.availableWater())")
                    }
                    .foregroundColor(controller.cityData.availableWater() >= productionWaterCost ? .green:.red)
                    
                    HStack {
                        
                        Ingredient.Battery.image()!
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 22, height: 22, alignment: .center)
                        Text("Energy: \(productionEnergyCost) of \(controller.cityData.availableEnergy())")
                        
                    }
                    .foregroundColor(controller.cityData.availableEnergy() >= productionEnergyCost ? .green:.red)
                    
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
            ActivityStaffView(staff: controller.availableStaff, requiredSkills:[.Biologic:1], title: "Select Biologist(s)") { selectedPeople in
                controller.selectedStaff = selectedPeople
            }
            
            
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
                    self.onCancelSelection()
//                    controller.cancelBoxSelection()
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
//                    guard let citydata = controller.cityData else { return }
                    let possibleProblems = self.validateResourcesForBox(qtty: Int(sliderValue))
                    //citydata.validateResources(box: Int(sliderValue))
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
                    let newBioBox = BioBox(chosen: self.chosenDNA, size: Int(sliderValue))
                    
                    let result:Bool = controller.buildBio(box: newBioBox, usingTokens: true, boxSize: Int(sliderValue))
                    
//                    let problems = controller.validadeTokenPayment(box: Int(sliderValue), tokens: Int(sliderValue/10.0) + 1)
//                    self.problems = problems
                    if result == true {
                        self.confirmBioBox()
                    }
//                    if problems.isEmpty {
//                        self.confirmBioBox()
//                    }
                }
                .buttonStyle(NeumorphicButtonStyle(bgColor: .orange))
                .disabled(Int(sliderValue) < minimumLimit)
                
            }
            .padding()
        }
    }
    
    func availableFertilizer() -> Int {
        return controller.cityData.boxes.filter({$0.type == .Fertilizer}).compactMap({ $0.current }).reduce(0, +)
    }
    
    func validateResourcesForBox(qtty:Int) -> [String] {
        
        let fertilizer = qtty
        let water = qtty * GameLogic.bioBoxWaterConsumption
        let energy = qtty * GameLogic.bioBoxEnergyConsumption
        
        let cityData = controller.cityData
        
        // Problems Array
        var problems:[String] = []
        
        // Ingredients Consumption
        if controller.cityData.validateResources(ingredients: [.Fertilizer:fertilizer]).isEmpty == true {
            print("Fertilizer verified")
        } else {
            print("Not enough Fertilizer")
            problems.append("Not enough Fertilizer")
        }
        
        if controller.cityData.availableWater() >= water {
            print("Water Verified")
        } else {
            print("No enough Water")
            problems.append("Not enough Water")
        }
        
        if controller.cityData.availableEnergy() >= energy {
            print("Energy Verified")
        } else {
            print("Not enough Energy")
            problems.append("Not enough Energy")
        }
        
        // Workers & Skills
        var bioCount:Int = 0
        var medCount:Int = 0
        for person in controller.selectedStaff {
            for skill in person.skills {
                if skill.skill == .Biologic {
                    bioCount += skill.level
                }
                if skill.skill == .Medic {
                    medCount += 1
                }
            }
        }
        if bioCount + medCount < 1 {
            print("Not enough Skills")
            problems.append("Not enough Skills")
        } else {
            print("Skills Verified")
        }
        
        if !problems.isEmpty {
            
            print("Whats the problem?")
            
            return problems
        } else {
            // No Problem
            
            // 1. Make person busy
            let activity = LabActivity(time: 3600, name: "Planting life")
            for person in selectedPeople {
                person.activity = activity
            }
            
            // 2. set selecte people to none
            self.selectedPeople = []
            
            // 3. Charge Energy
            let consumption:Bool = cityData.consumeEnergyFromBatteries(amount: energy) //station.truss.consumeEnergy(amount: energy)
            
            // 4. Charge Fertilizers
            let payment = cityData.payForResources(ingredients: [.Fertilizer:fertilizer])
            //station.truss.payForResources(ingredients: [.Fertilizer:fertilizer])
            
            // Save
            do {
                try LocalDatabase.shared.saveCity(cityData)
            } catch {
                print("Error saving city: \(error.localizedDescription)")
            }
            
            print("Consumed Energy: \(consumption)")
            print("Paid for resources: \(payment)")
            
            //            LocalDatabase.shared.saveStation(station: self.station)
            return problems
        }
        
    }
    
    func confirmBioBox() {
        
        // 1 - Pass the chosen DNA
        let choice = chosenDNA
        
        // 2 - Pass the slider value (population size)
        let size = Int(sliderValue)
        
        // 3 - Create New Box
//        controller.createNewBox(dna: choice, size: size)
        let box = BioBox(chosen: choice, size: size)
        
        let result = controller.buildBio(box: box, usingTokens: false, boxSize: size)
        if result == true {
            // Deselect
            self.onCancelSelection()
        }
    }
}

struct CityBioBuilderView_Previews: PreviewProvider {
    static var previews: some View {
        CityBioBuilderView(controller: LocalCityController())
    }
}
