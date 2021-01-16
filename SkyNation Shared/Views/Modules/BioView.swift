//
//  BioView.swift
//  SkyTestSceneKit
//
//  Created by Farini on 9/9/20.
//  Copyright © 2020 Farini. All rights reserved.
//

import SwiftUI

// Left View: BioBoxes
// Right View - Manage

struct BioView: View {
    
    @ObservedObject var controller:BioModController
    @ObservedObject var model = DNAMatcherModel(fitString: "BANANA")
    
    @State var started:Bool = false
    @State var menuPopover:Bool = false
    @State var dnaChoice:PerfectDNAOption = PerfectDNAOption.banana
    @State var trimSelection:[String] = []
    
    var module:BioModule
    
    init(bioMod:BioModule) {
        let mod = DNAMatcherModel(fitString: "BANANA")
        self.model = mod
        self.module = bioMod
        self.controller = BioModController(module: bioMod)
        // After init
        // *** This is for debugging only ***
//        if let bioBox = bioMod.boxes.first {
//            controller.didSelect(box: bioBox)
//        }
    }
    
    var body: some View {
        
        VStack {
            
            // Header
            HStack (alignment: .center, spacing: nil) {
                
                BioModuleHeaderView(module: module)
                
                Spacer()
                
                // Settings
                Button(action: {
                    print("Gear action")
                    menuPopover.toggle()
                }, label: {
                    Image(systemName: "ellipsis.circle")
                        .resizable()
                        .aspectRatio(contentMode:.fit)
                        .frame(width:34, height:34)
                })
                .buttonStyle(GameButtonStyle(foregroundColor: .white, backgroundColor: .black, pressedColor: .orange))
                .popover(isPresented: $menuPopover, content: {
                    VStack {
                        HStack {
                            Text("Rename")
                            Spacer()
                            Image(systemName: "textformat")
                                .fixedSize()
                                .scaledToFit()
                        }
                        
                        .onTapGesture {
                            print("Rename Action")
                            menuPopover.toggle()
                        }
                        Divider()
                        HStack {
                            // Text
                            Text("Change Skin")
                            // Spacer
                            Spacer()
                            // Image
                            Image(systemName: "circle.circle")
                                .fixedSize()
                                .scaledToFit()
                        }
                        .onTapGesture {
                            print("Reskin Action")
                            menuPopover.toggle()
                        }
                        
                        HStack {
                            Text("Tutorial")
                            Spacer()
                            Image(systemName: "questionmark.diamond")
                                .fixedSize()
                                .scaledToFit()
                        }
                        
                        .onTapGesture {
                            print("Reskin Action")
                            menuPopover.toggle()
                        }
                    }
                    .frame(width: 150)
                    .font(.headline)
                    .foregroundColor(.gray)
                    .padding(.leading, 6)
                })
                
                // Close
                Button(action: {
                    print("Close action")
                    NotificationCenter.default.post(name: .closeView, object: self)
                }, label: {
                    Image(systemName: "xmark.circle")
                        .resizable()
                        .aspectRatio(contentMode:.fit)
                        .frame(width:34, height:34)
                })
                .buttonStyle(GameButtonStyle(foregroundColor: .white, backgroundColor: .black, pressedColor: .orange))
                .padding(.trailing, 6)
            }
            Divider()

            // Main Body
            Group {
                
                HStack {
                    
                    // TABLE Bio Boxes
                    List() {
                        Section(header: Text("Bio Boxes")) {
                            ForEach(module.boxes) { box in
                                Text(box.perfectDNA.isEmpty ? "Sprout":box.perfectDNA)
                                    .font(.callout)
                                    .foregroundColor(controller.selectedBioBox?.id ?? UUID() == box.id ? Color.orange:Color.white)
                                    .onTapGesture {
                                        controller.didSelect(box: box)
                                        if let dna = PerfectDNAOption(rawValue: box.perfectDNA) {
                                            self.dnaChoice = dna
                                        }else{
                                            self.dnaChoice = .banana
                                        }
                                    }
                            }
                        }
                    }
                    .frame(minWidth: 100, idealWidth: 180, maxWidth: 200, alignment: .leading)
                    
                    switch controller.selection {
                        case .notSelected:
                            // Default Detail
                            ScrollView([.vertical, .horizontal], showsIndicators: true) {
                                
                                VStack {
                                    
                                    Group {
                                        
                                        Text("Bio Module").font(.headline).padding()
                                        Text("Boxes \(module.boxes.count)").foregroundColor(.gray)
                                        Text("Slots Available:\(controller.availableSlots) of \(BioModule.foodLimit)")
                                        Text("Energy: \(controller.availableEnergy)")
                                            .foregroundColor(controller.availableEnergy > 100 ? .green:.red)
                                        
                                        Text("⚠️  Do not leave food out of the boxes.")
                                            .foregroundColor(.orange)
                                            .padding()
                                        
                                        Text("Select a box to continue, or build a new one")
                                    }
                                    
                                    HStack {
                                        Button("New Bio Box") {
                                            controller.startAddingBox()
                                        }
                                        .disabled(model.isRunning)
                                        
                                        Button("Destroy") {
                                            print("Destroy everything?")
                                        }
                                    }
                                    .padding()
                                }
                            }
                            
                        case .selected(let bioBox):
                            
                            // Selected BioBox
                            HStack {
                                
                                ScrollView([.vertical], showsIndicators: true) {
                                
                                    // BioBox
                                    Group {
                                        
                                        // Control (Action)
                                        VStack {
                                            
                                            Text("DNA \(bioBox.perfectDNA)")
                                                .font(.title)
                                                .padding()
                                            
                                            Divider()
                                            
                                            Group {
                                                
                                                Text("Mode  \(bioBox.mode.rawValue)")
                                                    .font(.headline)
                                                    .foregroundColor(.blue)
                                                    .padding()
                                                
                                                Text("Energy: \(controller.availableEnergy)")
                                                    .foregroundColor(.green)
                                                    .padding()
                                                Text("Generations \(controller.geneticLoops)")
                                                Text("Score: \(controller.geneticScore) %")
                                                Text("Population: \(controller.selectedPopulation.count) / \(bioBox.populationLimit)")
                                                
                                                Text("🏆 Best fit")
                                                    .font(.title)
                                                    .padding(.top, 8)
                                                
                                                Text(controller.geneticFitString)
                                                    .foregroundColor(.orange)
                                                
                                                if let error = controller.errorMessage {
                                                    Text(error)
                                                        .foregroundColor(.red)
                                                }
                                                if let positive = controller.positiveMessage {
                                                    Text(positive)
                                                        .foregroundColor(.green)
                                                }
                                            }
                                            
                                            
                                            
                                            // Buttons
                                            HStack {
                                                
                                                Button("Grow") {
                                                    print("Grow population")
                                                    controller.growPopulation(box:bioBox)
                                                }
                                                .disabled(controller.geneticRunning)
                                                
                                                Button("Evolve") {
                                                    controller.loadGeneticCode(box:bioBox)
                                                }
                                                .disabled(controller.geneticRunning)
                                                
//                                                Button("Trim") {
//                                                    print("Trim Population")
//                                                    // ------------
//                                                    // Continue from here:
//                                                    // Add @State and array of items selected from the list
//                                                    // Trim those items of the array
//                                                    // Also, change the strings to the enum (Data Model)
//                                                    // Charge Electricity
//                                                    // ============
//                                                }
//                                                .disabled(bioBox.population.count < 2 || controller.geneticRunning)
                                                
                                                Button("Cancel") {
                                                    print("Cancelling Selection")
                                                    controller.cancelBoxSelection()
                                                }
                                                .disabled(controller.geneticRunning)
                                            }
                                            .padding()
                                        }
                                        .frame(minWidth: 250, alignment: .top)
                                    }
                                }
                                
                                Divider()
                                
                                // Population Display
                                List(controller.selectedPopulation, id:\.self) { dna in
                                    Text(dna)
                                        .foregroundColor(.gray)
                                        .onTapGesture {
                                            controller.trimItem(string: dna)
                                        }
                                }
                                .frame(maxWidth: 140)
                                
                            }
                            
                        case .building:
                            ScrollView() {
                                BuildingBioBoxView(controller:controller)
                            }
                    }
                    
                }
            }
            .frame(minWidth: 500, maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, minHeight: 250, maxHeight: .infinity, alignment:.topLeading)
            
        }
        .frame(minWidth: 500, idealWidth: 600, maxWidth: 800, alignment: .top)
    }
}

struct BioModuleHeaderView: View {
    
    var module:BioModule
    
    var body: some View {
        VStack(alignment:.leading) {
            Group {
                HStack {
                    Text("🧬 Biology Module")
                        .font(.largeTitle)
                        .padding([.leading], 6)
                        .foregroundColor(.red)
                }
                
                HStack(alignment: .lastTextBaseline) {
                    Text("ID: \(module.id)")
                        .foregroundColor(.gray)
                        .font(.caption)
                        .padding(.leading, 6)
                    Text("Name: \(module.name)")
                        .foregroundColor(.red)
                        .padding(.leading, /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
                }
            }
        }
    }
}

/// Building a new Bio Box
struct BuildingBioBoxView: View {
    
    @ObservedObject var controller:BioModController
    
    @State var chosenDNA:PerfectDNAOption = .banana     // The DNA chosen
    @State var sliderValue:Double = 0.0                 // The population Size
    @State var productionCost:[Ingredient:Int] = [.Fertilizer:0]
    @State var productionEnergyCost:Int = 0
    @State var productionWaterCost:Int = 0
    @State var problems:[String] = []
    
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
            
            VStack {
                // Picker Perfect DNA
                HStack {
                    Text("Pick DNA").padding(.leading, 6)
                    Picker(selection: $chosenDNA, label: Text("")){
                        ForEach(PerfectDNAOption.allCases, id:\.self) { dna in
                            Text("\(dna.emoji) | \(dna.rawValue)")
                        }
                    }
                    .frame(maxWidth: 250, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                    Spacer()
                }
                
                // Box Size
                HStack {
                    Text("Pick Size").padding(.leading, 8)
                    
                    VStack(alignment: .leading) {
                        // Choose amount of slots (Slider)
                        // --------
                        // Change food limit to the limit of the BioModule minus the amount being used
                        // --------
                        ZStack {
                            Slider(value: $sliderValue, in: 0.0...Double(controller.availableSlots)) { (changed) in
                                print("Slider changed \(changed)")
                                let boxSize = Int(sliderValue)
                                productionCost[.Fertilizer] = boxSize
                                productionWaterCost = boxSize * GameLogic.bioBoxWaterConsumption
                                productionEnergyCost = 7 * GameLogic.bioBoxEnergyConsumption
                            }
                            .frame(maxWidth: 250, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                            .padding(4)
                            
                            Text("\(Int(sliderValue)) of \(controller.availableSlots)")
                                .offset(x: 100, y: /*@START_MENU_TOKEN@*/10.0/*@END_MENU_TOKEN@*/)
                                .foregroundColor(.gray)
                        }
                    }
                    Spacer()
                }
            }
            .padding()
            
            Divider()
            
            // Costs
            Group {
                Text("Costs").font(.title)
                
                Text("Fertilizer: \(productionCost[.Fertilizer] ?? 0) of \(controller.availableFertilizer)")
                Text("Water: \(productionWaterCost) of \(controller.availableWater)")
                Text("Energy: \(productionEnergyCost) of \(controller.availableEnergy)")
                
                Text("Time: ?")
            }
            
            Divider()
            
            // People Picker
            Group {
                Text("Staff").font(.title)
                LazyVGrid (columns: [GridItem(.fixed(220)), GridItem(.fixed(220))], alignment: .center, spacing: 4, pinnedViews: /*@START_MENU_TOKEN@*/[]/*@END_MENU_TOKEN@*/) {
                    ForEach(controller.availablePeople) { person in
                        PersonSelectorView(person: person, selected: controller.selectedPeople.contains(person) ? false:true)
                            .onTapGesture {
                                controller.didTapPerson(person: person)
                            }
                    }
                }
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
                Button("Confirm") {
//                    confirmBioBox()
                    let possibleProblems = controller.validateResources(box: Int(sliderValue))
                    self.problems = possibleProblems
                    print("Confirm")
                }
                .disabled(Int(sliderValue) < minimumLimit)
                
                Button("Cancel") {
                    print("Cancel")
//                    controller.selection = .notSelected
                    controller.cancelBoxSelection()
                }
                
                Button("Trim") {
                    print("Trim")
                }
            }
            .padding()
        }
    }
    
    func confirmBioBox() {
        
        // 1 - Pass the chosen DNA
        let choice = chosenDNA
        
        // 2 - Pass the slider value (population size)
        let size = Int(sliderValue)
        
        // Check if there are enough resources
        
        // 3 - Create New Box
        controller.createNewBox(dna: choice, size: size)
        
    }
    
}

// MARK: - Previews

struct BioView_Previews: PreviewProvider {
    static var previews: some View {
        // Pass Controller
        if let bioModule = LocalDatabase.shared.station?.bioModules.first {
            return BioView(bioMod: bioModule)
        }else{
            return BioView(bioMod: BioModule.example)
        }
    }
}

struct BioBuilder_Previews: PreviewProvider {
    static var previews: some View {
        if let bioModule = LocalDatabase.shared.station?.bioModules.first {
            return BuildingBioBoxView(controller: BioModController(module: bioModule)) //BioView(bioMod: bioModule)
        }else{
            return BuildingBioBoxView(controller: BioModController(module: BioModule.example))
        }
    }
}

struct GameButtonStyle: ButtonStyle {
    var foregroundColor: Color
    var backgroundColor: Color
    var pressedColor: Color
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .font(.headline)
            .padding(8)
            .foregroundColor(foregroundColor)
            .background(configuration.isPressed ? pressedColor : backgroundColor)
            .cornerRadius(8)
    }
}

extension View {
    func gameButton(
        foregroundColor: Color = .white,
        backgroundColor: Color = Color(SCNColor.darkGray),
        pressedColor: Color = .accentColor
    ) -> some View {
        self.buttonStyle(
            GameButtonStyle(
                foregroundColor: foregroundColor,
                backgroundColor: backgroundColor,
                pressedColor: pressedColor
            )
        )
    }
}
