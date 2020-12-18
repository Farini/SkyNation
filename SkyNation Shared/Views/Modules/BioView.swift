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
            Group {
                VStack(alignment: .leading, spacing: 2) {
                    
                    HStack(alignment: VerticalAlignment.lastTextBaseline) {
                        Button("⚙️") {
                            print("Menu")
                            menuPopover = true
                        }
                        .popover(isPresented: $menuPopover, content: {
                            VStack {
                                Button("Rename Module") {
                                    print("Menu")
                                    menuPopover.toggle()
                                }
                                Button("Change Skin") {
                                    print("Menu")
                                    menuPopover = false
                                }
                                Button("Destroy") {
                                    print("Menu")
                                    menuPopover = false
                                }
                            }
                            .padding()
                        })
                        .gameButton()
                        
                        Text("🧬  Biology Module")
                            .font(.largeTitle)
                            .padding(6)
                            .foregroundColor(.red)
                        HStack {
                            Text("ID \(module.id)")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .padding([.leading], 6)
                            Spacer()
                        }
                        Spacer()
                        Text(module.name.isEmpty ? "Unnamed":module.name)
                            .font(.subheadline)
                        
                    }
                    Divider()
                }
                .padding([.top, .leading, .trailing])
            }
            Divider()
            Group {
                HStack {
                    
                    // TABLE Bio Boxes
                    List(module.boxes) { box in
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
                    .frame(minWidth: 100, idealWidth: 180, maxWidth: 200, alignment: .leading)
                    
                    switch controller.selection {
                        case .notSelected:
                            // Default Detail
                            ScrollView([.vertical, .horizontal], showsIndicators: true) {
                                
                                VStack {
                                    
                                    Text("Bio Module").font(.headline).padding()
//                                    Image(systemName: "square.and.pencil")
                                    Text("Boxes \(module.boxes.count)").foregroundColor(.gray)
//                                    Text("Make your own food").foregroundColor(.gray)
                                    Text("Slots Available:\(controller.availableSlots) of \(BioModule.foodLimit)")
                                    
                                    Text("⚠️  Do not leave food out of the boxes.")
                                        .foregroundColor(.orange)
                                        .padding()
                                    
                                    Group {
                                        Text("Generations")
                                        Text("DNA Size")
                                        Text("-")
                                    }.padding(2)
                                    .foregroundColor(.gray)
                                    
                                    HStack {
                                        Button("New Bio Box") {
                                            controller.startAddingBox()
                                        }
                                        Button("Collect") {
                                            print("Collect food from Bio Boxes")
                                            print("Harvest ??")
                                        }
                                    }
                                    .padding()
                                    .disabled(model.isRunning)
                                    
                                }
                            }
                            
                        case .selected(let bioBox):
                            
                            // Selected BioBox
                            ScrollView([.vertical, .horizontal], showsIndicators: true) {
                                
                                HStack {
                                    // BioBox
                                    Group {
                                        // Control (Action)
                                        VStack {
                                            
                                            // Picker
                                            Group {
                                                Text("DNA Options (select one)").padding()
                                                Picker(selection: $controller.dnaOption, label: Text("DNA")){
                                                    ForEach(PerfectDNAOption.allCases, id:\.self) { dna in
                                                        Text(dna.rawValue)
                                                    }
                                                }
                                                #if os(macOS)
//                                                .pickerStyle(PopUpButtonPickerStyle())
                                                #endif
                                                Divider()
                                            }
                                            
                                            HStack {
                                                Text("DNA \(bioBox.perfectDNA)").font(.headline).padding()
                                                Text("Mode  \(bioBox.mode.rawValue)").font(.headline)
                                            }
                                            
                                            Group {
                                                Text("Generations \(controller.geneticLoops)")
                                                Text("Score: \(controller.geneticScore) %")
                                                Text("Population: \(controller.selectedPopulation.count)")
                                                Text("DNA Perfect: \(bioBox.perfectDNA)")
                                            }.padding(2)
                                            .foregroundColor(.gray)
                                            
                                            Text("Best fit").font(.callout).padding(Edge.Set(.top), 8)
                                            
                                            TextField("Example", text: $controller.geneticFitString)
                                                .frame(maxWidth: 150, alignment: .leading)
                                            
                                            
                                            Button(action: {
                                                controller.loadGeneticCode(box:bioBox)
//                                                self.start()
//                                                self.started = true
                                            }) {
                                                Text("Run Genetics")
                                            }
                                            .padding()
                                            .disabled(controller.geneticRunning)
                                            
                                            Text("Population")
                                            
                                        }
                                        .frame(minWidth: 250, alignment: .top)
                                        
                                        Divider()
                                        
                                        // Population Display
                                        List(controller.selectedPopulation, id:\.self) { dna in
                                            Text(dna)
                                                .foregroundColor(.gray)
                                        }
                                        .frame(maxWidth: 120, alignment: .bottom)
                                    }
                                    
                                }
                                
                            }
                            
                        case .building:
                            ScrollView() {
                                BuildingBioBoxView(controller:controller)
                            }
                    }
                    
                }
            }
            
        }
        .frame(minWidth: 500, idealWidth: 600, maxWidth: 800, alignment: .top)
    }
    
    func addBox() {
        print("Should be adding box. or trying to")
        // capacity is 4
        if module.capacity > module.boxes.count {
            // can add
        }else{
            // Can't add
        }
    }
    
    // DEPRECATE
    func start() {
        if let box = controller.selectedBioBox {
            print("Selected OK")
            let dna = controller.dnaOption
            box.perfectDNA = dna.rawValue
            print("Box has perfect dna: \(dna)")
            let population = box.population
            if population.count > 0 {
                print("Box has some \(population.count) folks here")
                model.convertTo(box: box)
                model.main()
            }
        }
    }
}

struct BuildingBioBoxView: View {
    
    @ObservedObject var controller:BioModController
    
    @State var chosenDNA:PerfectDNAOption = .banana     // The DNA chosen
    @State var sliderValue:Double = 0.0                 // The population Size
    
    let minimumLimit:Int = 5
    
    var body: some View {
        VStack {
            Text("Building new box")
            
            // Choose Perfect DNA
            // Picker
            Group {
                Text("DNA Options (select one)").padding()
                Picker(selection: $chosenDNA, label: Text("DNA")){
                    ForEach(PerfectDNAOption.allCases, id:\.self) { dna in
                        Text(dna.rawValue)
                    }
                }
//                .pickerStyle(PopUpButtonPickerStyle())
                
                Divider()
            }
            
            // Choose amount of slots (Slider)
            // slider max = controller.availableSlots
            // slider min = 5?
            
            Slider(value: $sliderValue, in: 0.0...Double(BioModule.foodLimit)) { (changed) in
                print("Slider changed?")
            }
            .frame(maxWidth: 250, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
            .padding(4)
            
            Text("Value \(Int(sliderValue)) of \(BioModule.foodLimit)")
            
            Divider()
            
            // Buttons (Confirm, Cancel)
            HStack {
                Button("Confirm") {
                    confirmBioBox()
                    print("Confirm")
                }
                .disabled(Int(sliderValue) < minimumLimit)
                
                Button("Cancel") {
                    print("Cancel")
                    controller.selection = .notSelected
                }
            }
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
