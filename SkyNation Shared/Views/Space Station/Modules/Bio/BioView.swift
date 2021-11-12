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
                    if controller.module.name != "untitled" && controller.module.name != "Untitled" && !controller.module.name.isEmpty{
                        Text("🧬 \(controller.module.name)")
                            .font(GameFont.title.makeFont())
                    } else {
                        Text("🧬 Bio Module")
                            .font(GameFont.title.makeFont())
                    }
                    
//                    HStack(alignment: .lastTextBaseline) {
//                        Text("ID: \(controller.module.id)")
//                            .foregroundColor(.gray)
//                            .font(.caption)
//                            .padding(.leading, 6)
//                        Text("Name: \(controller.module.name)")
//                            .foregroundColor(.blue)
//                            .padding(.leading, /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
//                        Spacer()
//                    }
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
                        ModulePopView(name: controller.module.name, module:controller.station.modules.filter({ $0.id == controller.module.id }).first!)
                    })
                    
                    // Close
                    Button(action: {
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
                    List {
                        ForEach(module.boxes) { box in
                            
                            BioBoxRow(box: box)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                                        .inset(by: 0.5)
                                        .stroke((box == controller.selectedBioBox) == true ? Color.blue.opacity(0.9):Color.clear, lineWidth: 1)
                                )
                                .onTapGesture {
                                    self.controller.didSelect(box: box)
                                    if let dna = DNAOption(rawValue: box.perfectDNA) {
                                        self.dnaChoice = dna
                                    } else {
                                        self.dnaChoice = .banana
                                    }
                                }
                        }
                    }
                    .frame(minWidth: 80, maxWidth: 150, alignment: .leading)
                    
                    switch controller.selection {
                        case .notSelected:
                            // Default Detail
                            ScrollView([.vertical], showsIndicators: true) {
                                
                                VStack {
                                    
                                    Group {
                                        
                                        // No Selection Detail
                                        Text("Bio Boxes \(module.boxes.count)").foregroundColor(.gray)
                                        
                                        ProgressView("Slots Available: \(controller.availableSlots) of \(BioModule.foodLimit)", value: Double(controller.availableSlots)/Double(BioModule.foodLimit))
                                                .frame(width:200)
                                                .padding(.top, 8)
                                        
                                        Divider()
                                        
                                        Label("\(controller.availableEnergy) kW", systemImage:"bolt.circle").font(.title2)
                                            .foregroundColor(controller.availableEnergy > 100 ? .white:.red)
                                        
                                        VStack(alignment:.leading, spacing:6) {
                                            
                                            Text("Select a box to continue, or create a new one.")
                                            
                                            Text("Food is really important for your astronauts to survive. A BioBox can feed the astronauts, and helps the station to produce food, so you don't have to keep ordering.")
                                                .fixedSize(horizontal: false, vertical: true)
                                            
                                                .foregroundColor(.gray)
                                        }
                                        .padding(.vertical, 8)
                                        .padding(.horizontal)
                                        
                                        Spacer(minLength: 50)
                                        
                                        Divider()
                                        
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
                            }
                            
                        case .selected(let bioBox):
                            
                            // Selected BioBox
                            HStack {
                                
                                // Box Details
                                ScrollView([.vertical], showsIndicators: true) {
                                    BioBoxDetailView(controller:controller, bioBox:bioBox)
                                }
                                
                                // Population Display
                                List(controller.selectedPopulation, id:\.self) { dna in
                                    Text(dna)
                                        .foregroundColor(.gray)
                                        .font(GameFont.mono.makeFont())
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
        }
        .frame(minWidth: 600, idealWidth: 700, maxWidth: 800, minHeight:400, maxHeight:700, alignment: .top)
    }
}

struct BioBoxRow: View {
    
    var box:BioBox
    
    var body: some View {
        HStack {
            
            if box.population.first ?? "" == box.perfectDNA {
                Text(box.convertToDNA().emoji).font(.title)
            } else {
                Text("🌱")
            }
            
            VStack(alignment:.leading) {
                Group {
                    // DNA
                    Text(box.perfectDNA.isEmpty ? "Sprout":box.perfectDNA)
                        .font(.callout)
                        .foregroundColor(box.mode.color)
                    
                    HStack {
                        // Count
                        Text("\(box.population.count)/\(box.populationLimit)")
                            .font(GameFont.monoTiny.makeFont())
                            .foregroundColor(.gray)
                        
                        Spacer()
                        
                        // Mode
                        Text("\(box.mode.short)")
                            .font(GameFont.monoTiny.makeFont())
                    }
                }
            }
        }
    }
}

// MARK: - Previews

struct BioView_Previews: PreviewProvider {
    static var previews: some View {
        // Pass Controller
        if let bioModule = LocalDatabase.shared.station.bioModules.first {
            return BioView(bioMod: bioModule)
        }else{
            return BioView(bioMod: BioModule.example)
        }
    }
}



extension BioBoxMode {
    var color:Color {
        switch self {
            case .grow: return Color.orange
            case .evolve: return Color.blue
            case .multiply: return Color.white
            case .serving: return GameColors.airBlue
        }
    }
    
    var short:String {
        switch self {
            case .grow: return "⏫"
            case .evolve: return "🔡"
            case .multiply: return "🔀"
            case .serving: return "🍦" // GameColors.airBlue
        }
    }
}
