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
                
                // Add Split Button -> Split the box in 2
                // Add Shrink Button -> Give away free slots back to the Lab capacity
            }
        }
    }
}
