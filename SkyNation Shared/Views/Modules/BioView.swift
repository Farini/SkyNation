//
//  BioView.swift
//  SkyTestSceneKit
//
//  Created by Farini on 9/9/20.
//  Copyright © 2020 Farini. All rights reserved.
//

import SwiftUI
import SceneKit

// Left View: BioBoxes
// Right View - Manage

struct BioView: View {
    
    @ObservedObject var controller:BioModController
    @ObservedObject var model = DNAMatcherModel(fitString: "BANANA")
    
    // Popovers
    @State var menuPopover:Bool = false
    @State var popoverTutorial:Bool = false
    
    @State var started:Bool = false
    @State var dnaChoice:DNAOption = DNAOption.banana
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
    
    var header: some View {
        Group {
            HStack() {
                
                VStack(alignment:.leading) {
                    Text("🧬 Biology Module")
                        .font(.largeTitle)
                    
                    HStack(alignment: .lastTextBaseline) {
                        Text("ID: \(controller.module.id)")
                            .foregroundColor(.gray)
                            .font(.caption)
                            .padding(.leading, 6)
                        Text("Name: \(controller.module.name)")
                            .foregroundColor(.blue)
                            .padding(.leading, /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
                        Spacer()
                    }
                }
                
                Spacer()
                
                Group {
                    // Tutorial
                    Button(action: {
                        print("Question ?")
                        popoverTutorial.toggle()
                    }, label: {
                        Image(systemName: "questionmark.circle")
                            .font(.title2)
                    })
                    .buttonStyle(SmallCircleButtonStyle(backColor: .blue))
                    .popover(isPresented: $popoverTutorial, content: {
                        TutorialView(tutType: .BioView)
                    })
                    
                    // Settings
                    Button(action: {
                        print("Gear action")
                        menuPopover.toggle()
                    }, label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.title2)
                    })
                    .buttonStyle(SmallCircleButtonStyle(backColor: .orange))
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
                            .font(.title2)
                    })
                    .buttonStyle(SmallCircleButtonStyle(backColor: .pink))
                    .padding(.trailing, 6)
                }
            }
            .padding([.leading, .trailing, .top], 8)
            
            Divider()
                .offset(x: 0, y: -5)
        }
    }
    
    var body: some View {
        
        VStack {
            
            // Header
            header
            
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
                                        if let dna = DNAOption(rawValue: box.perfectDNA) {
                                            self.dnaChoice = dna
                                        }else{
                                            self.dnaChoice = .banana
                                        }
                                    }
                            }
                        }
                    }
                    .frame(minWidth: 80, maxWidth: 150, alignment: .leading)
                    
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
                                        Button(action: {
                                            controller.startAddingBox()
                                        }, label: {
                                            HStack {
                                                Image(systemName:"staroflife")
                                                Text("Create")
                                            }
                                        })
                                        .buttonStyle(NeumorphicButtonStyle(bgColor:.orange))
                                        .disabled(model.isRunning)
                                        
                                    }
                                    .padding()
                                }
                            }
                            
                        case .selected(let bioBox):
                            
                            // Selected BioBox
                            HStack {
                                
                                ScrollView([.vertical], showsIndicators: true) {
                                    
                                    // BioBox
                                    BioBoxDetailView(controller:controller, bioBox:bioBox)
                                    
                                }
                                
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
//            .frame(minWidth: 500, maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment:.topLeading)
            
        }
        .frame(minWidth: 600, idealWidth: 700, maxWidth: 800, alignment: .top)
    }
}



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
            ActivityStaffView(staff: controller.availablePeople, selected: [], requiredSkills: [.Biologic:1], chooseWithReturn: { (selectedPeople) in
                controller.selectedPeople = selectedPeople
            }, title: "Select Biologist", issue: "", message: "")
            
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

struct BioBoxDetailView:View {
    
    @ObservedObject var controller:BioModController
    var bioBox:BioBox
    var scene = SCNScene(named: "Art.scnassets/ParticleEmitters/DNAModel.scn")!
    
    var body: some View {
        
        VStack {
            
            HStack {
                SceneView(scene: scene, pointOfView: scene.rootNode.childNode(withName: "Camera", recursively: false)!, options: .allowsCameraControl, preferredFramesPerSecond: 45, antialiasingMode: .multisampling4X, delegate: nil, technique: nil)
                    .frame(maxWidth: 100, minHeight: 200, maxHeight: 500, alignment: .top)
                VStack {
                    Group {
                        Text("Bio Box")
                            .font(.title)
                            .padding()
                        
                        Text("\(bioBox.convertToDNA().emoji)").font(.largeTitle)
                        Text("\(bioBox.convertToDNA().rawValue)")
                        
                        Divider()
                        
                        Text("Mode  \(bioBox.mode.rawValue)")
                            .font(.headline)
                            .foregroundColor(.blue)
                        //                        .padding()
                        
                        Text("Energy: \(controller.availableEnergy)")
                            .foregroundColor(.green)
                        //                        .padding()
                    }
                    
                    Group {
                        
                        Text("Generations \(controller.geneticLoops)")
                        Text("Score: \(controller.geneticScore) %")
                        Text("Population: \(controller.selectedPopulation.count) / \(bioBox.populationLimit)")
                        
                        ProgressView("Growth", value: Float(bioBox.population.count), total: Float(bioBox.populationLimit))
                            .frame(width:200)
                        
                        Text("Date")
                        Text(GameFormatters.dateFormatter.string(from:bioBox.dateAccount))
                        
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
                    
                    Divider()
                }
                
            }
            
            
            // Buttons
            HStack {
                
                Button("Cancel") {
                    print("Cancelling Selection")
                    controller.cancelBoxSelection()
                }
                .buttonStyle(NeumorphicButtonStyle(bgColor:.orange))
                .disabled(controller.geneticRunning)
                
                Divider()
                
                Button("Grow") {
                    print("Grow population")
                    controller.growPopulation(box:bioBox)
                }
                .buttonStyle(NeumorphicButtonStyle(bgColor:.orange))
                .disabled(controller.growDisabledState(box: bioBox))
                
                Button("Crop") {
                    print("Crop population")
                }
                .buttonStyle(NeumorphicButtonStyle(bgColor:.orange))
                .disabled(controller.cropDisabledState(box: bioBox))
                
                Button("Evolve") {
                    controller.evolveBio(box:bioBox)
                }
                .buttonStyle(NeumorphicButtonStyle(bgColor:.orange))
                .disabled(controller.evolveDisabledState(box:bioBox))
                
                Button("Multiply") {
                    controller.multiply(box: bioBox)
                }
                .buttonStyle(NeumorphicButtonStyle(bgColor:.orange))
                .disabled(controller.multiplyDisabledState(box: bioBox))
                
                
            }
        }
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

//struct GameButtonStyle: ButtonStyle {
//    var foregroundColor: Color
//    var backgroundColor: Color
//    var pressedColor: Color
//
//    func makeBody(configuration: Self.Configuration) -> some View {
//        configuration.label
//            .font(.headline)
//            .padding(8)
//            .foregroundColor(foregroundColor)
//            .background(configuration.isPressed ? pressedColor : backgroundColor)
//            .cornerRadius(8)
//    }
//}
//
//extension View {
//    func gameButton(
//        foregroundColor: Color = .white,
//        backgroundColor: Color = Color(SCNColor.darkGray),
//        pressedColor: Color = .accentColor
//    ) -> some View {
//        self.buttonStyle(
//            GameButtonStyle(
//                foregroundColor: foregroundColor,
//                backgroundColor: backgroundColor,
//                pressedColor: pressedColor
//            )
//        )
//    }
//}
