//
//  CityBioView.swift
//  SkyNation
//
//  Created by Carlos Farini on 9/24/21.
//

import SwiftUI

struct CityBioView: View {
    
    @ObservedObject var controller:LocalCityController
    
    @State private var selectedBiobox:BioBox? = nil
    @State private var selection:BioModSelection = .notSelected
    @State private var dnaChoice:DNAOption = .banana
    
    // Available slots
    // available energy
    
    var body: some View {
        VStack {
            
            // Main Body
            Group {
                
                HStack {
                    
                    // TABLE Bio Boxes
                    List() {
                        Section(header: Text("Bio Boxes")) {
                            ForEach(controller.cityData.bioBoxes) { biobox in
                                Text(biobox.perfectDNA.isEmpty ? "Sprout":biobox.perfectDNA)
                                    .font(.callout)
                                    .foregroundColor(selectedBiobox?.id ?? UUID() == biobox.id ? Color.orange:Color.white)
                                    .onTapGesture {
//                                        controller.didSelect(box: box)
                                        self.selectedBiobox = biobox
                                        self.selection = .selected(box: biobox)
                                        if let dna = DNAOption(rawValue: biobox.perfectDNA) {
                                            self.dnaChoice = dna
                                        }else{
                                            self.dnaChoice = .banana
                                        }
                                    }
                            }
                        }
                    }
                    .frame(minWidth: 80, maxWidth: 150, alignment: .leading)
                    
                    switch selection {
                        case .notSelected:
                            // Default Detail
                            ScrollView([.vertical, .horizontal], showsIndicators: true) {
                                
                                VStack {
                                    
                                    Group {
                                        
                                        Text("City BioLab").font(.headline).padding()
                                        Text("Boxes \(controller.cityData.bioBoxes.count)").foregroundColor(.gray)
                                        Text("Slots Available:\(controller.cityData.availableBioSlots())")
                                        Text("Energy: \(controller.cityData.availableEnergy())")
                                            .foregroundColor(controller.cityData.availableEnergy() > 100 ? .green:.red)
                                        
                                        Text("⚠️  Do not leave food out of the boxes.")
                                            .foregroundColor(.orange)
                                            .padding()
                                        
                                        Text("Select a box to continue, or build a new one")
                                    }
                                    
                                    HStack {
                                        Button(action: {
//                                            controller.startAddingBox()
                                            self.selection = .building
                                        }, label: {
                                            HStack {
                                                Image(systemName:"staroflife")
                                                Text("Create")
                                            }
                                        })
                                            .buttonStyle(NeumorphicButtonStyle(bgColor:.orange))
                                            // .disabled(model.isRunning)
                                        
                                    }
                                    .padding()
                                }
                            }
                            
                        case .selected(let bioBox):
                            
                            // Selected BioBox
                            HStack {
                                
                                ScrollView([.vertical], showsIndicators: true) {
                                    
                                    // BioBox
//                                    VStack {
//                                        Text("---")
//                                        Text("Biobox detail view goes here")
//                                        Text("---")
//                                    }
//                                    .padding()
                                    
                                    CityBioboxDetailView(controller: controller, cityData: .constant(controller.cityData), bioBox: .constant(bioBox)) {
                                        self.selection = .notSelected
                                    }
                                    
                                    /*
                                    BioBoxDetailView(controller:controller, bioBox:bioBox)
                                    */
                                }
                                
                                // Population Display
                                List(bioBox.population, id:\.self) { dna in
                                    Text(dna)
                                        .foregroundColor(.gray)
                                        .onTapGesture {
                                            print("trim")
//                                            controller.trimItem(string: dna)
                                        }
                                }
                                .frame(maxWidth: 140)
                                
                            }
                            
                        case .building:
                            ScrollView() {
//                                VStack {
//                                    Text("---")
//                                    Text("Building Biobox View")
//                                    Text("---")
//                                }
//                                .padding()
                                
                                CityBioBuilderView(controller:controller, onCancelSelection: {
                                    self.selection = .notSelected
                                })
                                
//                                BuildingBioBoxView(controller:controller)
                            }
                    }
                    
                }
            }
            
        }
        .frame(minWidth: 600, idealWidth: 700, maxWidth: 800, alignment: .top)
    }
}

struct CityBioView_Previews: PreviewProvider {
    static var previews: some View {
        CityBioView(controller: LocalCityController())
    }
}
