//
//  BioBoxDetailView.swift
//  SkyNation
//
//  Created by Carlos Farini on 7/27/21.
//

import SwiftUI
import SceneKit

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
                        
                        Text("Energy: \(controller.availableEnergy)")
                            .foregroundColor(.green)
                    }
                    
                    Group {
                        
//                        Text("Generations \(controller.geneticLoops)")
                        Text("Score: \(controller.geneticScore) %")
                        Text("Population: \(controller.selectedPopulation.count) / \(bioBox.populationLimit)")
                        
                        ProgressView("Growth", value: Float(bioBox.population.count), total: Float(bioBox.populationLimit))
                            .frame(width:180)
                        
//                        Text("Date")
//                        Text(GameFormatters.dateFormatter.string(from:bioBox.dateAccount))
                        
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
                    controller.cancelBoxSelection()
                }
                .buttonStyle(NeumorphicButtonStyle(bgColor:.orange))
                .disabled(controller.geneticRunning)
                
                Divider()
                
                switch bioBox.mode {
                    case .grow:
                        Button("Grow") {
                            print("Grow population")
                            controller.growPopulation(box:bioBox)
                        }
                        .buttonStyle(NeumorphicButtonStyle(bgColor:.orange))
                        .disabled(controller.growDisabledState(box: bioBox))
                    case .evolve:
                        Button("Grow") {
                            print("Grow population")
                            controller.growPopulation(box:bioBox)
                        }
                        .buttonStyle(NeumorphicButtonStyle(bgColor:.orange))
                        .disabled(controller.growDisabledState(box: bioBox))
                        
                        Button("Evolve") {
                            controller.evolveBio(box:bioBox)
                        }
                        .buttonStyle(NeumorphicButtonStyle(bgColor:.orange))
                        .disabled(controller.evolveDisabledState(box:bioBox))
                        
                    case .multiply:
                        Button("Multiply") {
                            controller.multiply(box: bioBox)
                        }
                        .buttonStyle(NeumorphicButtonStyle(bgColor:.orange))
                        .disabled(controller.multiplyDisabledState(box: bioBox))
                        
                        Button("Shrink") {
                            controller.shrink(box: bioBox)
                        }
                        .buttonStyle(NeumorphicButtonStyle(bgColor:.orange))
                        .disabled(bioBox.population.count >= bioBox.populationLimit)
                        
                    case .serving:
                        Button("Multiply") {
                            controller.multiply(box: bioBox)
                        }
                        .buttonStyle(NeumorphicButtonStyle(bgColor:.orange))
                        .disabled(controller.multiplyDisabledState(box: bioBox))
                }
            }
        }
    }
}
