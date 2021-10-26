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
                        ModulePopView(name: controller.module.name, module:controller.station.modules.filter({ $0.id == controller.module.id }).first!)
                    })
                    
                    // Close
                    Button(action: {
//                        print("Close action")
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
            
        }
        .frame(minWidth: 600, idealWidth: 700, maxWidth: 800, minHeight:400, maxHeight:700, alignment: .top)
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

struct BioBuilder_Previews: PreviewProvider {
    static var previews: some View {
        if let bioModule = LocalDatabase.shared.station.bioModules.first {
            return BuildingBioBoxView(controller: BioModController(module: bioModule)) //BioView(bioMod: bioModule)
        }else{
            return BuildingBioBoxView(controller: BioModController(module: BioModule.example))
        }
    }
}
