//
//  CityBioboxDetailView.swift
//  SkyNation
//
//  Created by Carlos Farini on 9/25/21.
//

import SwiftUI
import SceneKit

struct CityBioboxDetailView: View {
    
    @ObservedObject var controller:LocalCityController
    @Binding var cityData:CityData
    @Binding var bioBox:BioBox
    var onCancelSelection:(() -> (Void))  = {}
    
    @State private var geneticLoops:Int = 0
    let scene = SCNScene(named: "Art.scnassets/ParticleEmitters/DNAModel.scn")!
    
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
                        
                        Text("Energy: \(cityData.availableEnergy())")
                            .foregroundColor(.green)
                    }
                    
                    Group {
                        
                        Text("Generations \(geneticLoops)")
                        Text("Score: \(controller.bioboxModel?.score ?? 0) %")
                        Text("Population: \(controller.bioboxModel?.population.count ?? 0) / \(bioBox.populationLimit)")
                        
                        ProgressView("Growth", value: Float(bioBox.population.count), total: Float(bioBox.populationLimit))
                            .frame(width:200)
                        
                        Text("Date")
                        Text(GameFormatters.dateFormatter.string(from:bioBox.dateAccount))
                        
                        Text("🏆 Best fit")
                            .font(.title)
                            .padding(.top, 8)
                        
                        Text(controller.bioboxModel?.fittestString ?? "")
                            .foregroundColor(.orange)
                        
//                        if let error = controller.errorMessage {
//                            Text(error)
//                                .foregroundColor(.red)
//                        }
//                        if let positive = controller.positiveMessage {
//                            Text(positive)
//                                .foregroundColor(.green)
//                        }
                    }
                    
                    Divider()
                }
                
            }
            
            
            // Buttons
            HStack {
                
                Button("Cancel") {
                    print("Cancelling Selection")
//                    controller.cancelBoxSelection()
                    self.onCancelSelection()
                }
                .buttonStyle(NeumorphicButtonStyle(bgColor:.orange))
                .disabled(controller.bioboxModel?.generatorRunning ?? false)
                
                Divider()
                
                Button("Grow") {
                    print("Grow population")
                    self.growPopulation(box:bioBox)
                }
                .buttonStyle(NeumorphicButtonStyle(bgColor:.orange))
//                .disabled(controller.growDisabledState(box: bioBox))
                
                Button("Evolve") {
                    controller.evolveBio(box:bioBox)
                }
                .buttonStyle(NeumorphicButtonStyle(bgColor:.orange))
//                .disabled(controller.evolveDisabledState(box:bioBox))
                
                Button("Multiply") {
                    self.multiplyPopulation(box: bioBox)
                }
                .buttonStyle(NeumorphicButtonStyle(bgColor:.orange))
//                .disabled(controller.multiplyDisabledState(box: bioBox))
                
            }
        }
    }
    
    func multiplyPopulation(box:BioBox) {
        
        let multiplyEnergyCost:Int = 10
        
        let consume = cityData.consumeEnergyFromBatteries(amount: multiplyEnergyCost)
        if consume {
            // multiply box
            // Check if perfect DNA already found
            let populi = box.population
            let perfect = box.perfectDNA
            if populi.contains(perfect) {
                // Already contains. No need to generate genetic code
                let countBegins = box.population.filter({ $0 == perfect })
                // Each perfect dna multiplies by 2
                let nextCount = min(countBegins.count * 2, box.populationLimit)
                let newPopulation = Array(repeating: perfect, count: nextCount)
                box.population = newPopulation
                box.mode = .multiply
                
                // Update and Save
//                self.availableEnergy = station.truss.getAvailableEnergy()
//                self.didSelect(box: box)
//                self.saveStation()
//                positiveMessage = "Perfect DNA multiplied."
                print("Perfect DNA Found! Updating box.")
                return
            } else {
//                errorMessage = "BioBox does not contain perfect DNA"
            }
        }
    }
    
    func growPopulation(box:BioBox) {
        
        // Check if population is over limit
        let boxLimit = box.populationLimit
        if box.population.count >= boxLimit {
            print("Error: Population bigger than limit. Can't grow.")
            return
        }
        
        // Population shouldn't be empty
        if box.population.count == 0 {
            let newPopulation = DNAGenerator.populate(dnaChoice: DNAOption(rawValue:box.perfectDNA)!, popSize: 1)
            box.population = newPopulation
            return
        }
        
        var newBorns:Int = 0
        let pct = Double(box.population.count) / Double(box.populationLimit)
        if pct < 0.25 {
            // double population
            newBorns = box.population.count * 2
        } else if pct < 0.5 {
            // 30%
            newBorns = Int(Double(box.population.count) * 0.33)
        } else if pct < 1.0 {
            // add 2
            newBorns = 2
        }
        
        if cityData.consumeEnergyFromBatteries(amount: newBorns * 10) {
            let newPopulation = DNAGenerator.populate(dnaChoice: DNAOption(rawValue:box.perfectDNA)!, popSize: newBorns)
            box.population.append(contentsOf: newPopulation)
        } else {
            // error
        }
        
//        if station.truss.consumeEnergy(amount: newBorns * 10) {
//            let newPopulation = DNAGenerator.populate(dnaChoice: self.dnaOption, popSize: newBorns)
//            box.population.append(contentsOf: newPopulation)
//        } else {
//            errorMessage = "Did not have enough energy. Requires 10KW"
//        }
        
        // Update and Save
//        self.availableEnergy = station.truss.getAvailableEnergy()
//        self.saveStation()
//        positiveMessage = "Populattion grew ."
        
//        self.selectedPopulation = box.population
        
    }
}
/*
struct CityBioboxDetailView_Previews: PreviewProvider {
    static var previews: some View {
        CityBioboxDetailView()
    }
}
*/
