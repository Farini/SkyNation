//
//  LabActivityView.swift
//  SkyTestSceneKit
//
//  Created by Carlos Farini on 12/17/20.
//  Copyright © 2020 Farini. All rights reserved.
//

import SwiftUI

struct LabActivityView:View {
    
    @ObservedObject var controller:LabViewModel
    @ObservedObject var viewModel:LabActivityViewModel
    @State var percentor:Double = 0.0
    
    var activity:LabActivity
    var labModule:LabModule
    
    init(activity:LabActivity, controller:LabViewModel, module:LabModule) {
        
        self.activity = activity
        self.viewModel = LabActivityViewModel(labActivity: activity)
        self.labModule = module
        self.controller = controller
        
    }
    
    var body: some View {
        
        VStack(spacing:4) {
            
            Text("🔬 Activity: \(activity.activityName)")
                .font(.largeTitle)
                .foregroundColor(.blue)
            Divider()
            
            Group {
                Text("Started: \(GameFormatters.dateFormatter.string(from: activity.dateStarted))")
                Text("Total: \(Int(viewModel.totalTime)) seconds")
                Text("⏱ Remaining: \(Int(viewModel.timeRemaining)) seconds")
                Text("Ends: \(GameFormatters.dateFormatter.string(from:activity.dateEnds))")
            }
            
            GameActivityView(activity: activity)
            
            if viewModel.timeRemaining > 0 {
                HStack {
                    
                    // Token
                    Button(action: {
                        print("Token")
                        let result = controller.boostActivity()
                        if result {
                            print("Boost Success!")
                        } else {
                            print("Boost Failed")
                        }
                    }, label:{
                        Text("Token")
                    })
                    .buttonStyle(NeumorphicButtonStyle(bgColor: .blue))
                    
                    // Cancel
                    Button(action: {
                        print("Cancel activity")
                    }, label:{
                        Text("Cancel")
                    })
                    .buttonStyle(NeumorphicButtonStyle(bgColor: .blue))
                }
            }else{
                HStack {
                    
                    // Throw away
                    Button(action: {
                        print("Throw out")
                        controller.throwAwayTech()
                        
                    }, label:{
                        Text("Throw Away")
                    })
                    .buttonStyle(NeumorphicButtonStyle(bgColor: .blue))
                    
                    // Collect
                    Button(action: {
                        
                        print("Collect activity")
                        
                        if let recipe = Recipe(rawValue: self.activity.activityName) {
                            
                            if controller.collectRecipe(recipe: recipe, from: self.labModule) == true {
                                print("Collected Recipe & Saved: \(recipe.rawValue)")
                                
                            }
                            
                        } else if let tech = TechItems(rawValue: self.activity.activityName) {
                            
                            // We have a tech value !!!
                            print("Should make tech: \(tech)")
                            print("Still needs implementation")
                            
                            self.viewModel.stop()
                            self.viewModel.timer.invalidate()
                            controller.collectTech(activity: activity, tech: tech)
                            
                        } else {
                            print("WARNING Couldn't find anything to do with it....")
                            self.viewModel.stop()
                            self.viewModel.timer.invalidate()
                        }
                        
                    }, label:{
                        Text("Collect")
                    })
                    .buttonStyle(NeumorphicButtonStyle(bgColor: .blue))
                }
            }
            
        }.padding()
        
        
        
        .onAppear() {
            self.percentor = Double(viewModel.timeRemaining)/viewModel.totalTime
        }
        
        .onDisappear() {
            self.viewModel.stop()
        }
    }
    
}

struct LabActivity_Previews: PreviewProvider {
    
    static let tech:TechItems = TechItems.allCases.randomElement()!
    static let model:LabViewModel = LabViewModel(demo: tech)
    static let act = LabActivity(time: 100, name: "Test Lab Act")
    
    static var previews: some View {
        VStack {
            
            LabActivityView(activity: act, controller: LabViewModel(demo: act), module: LabModule.example())
        }
        // Temporarily here to show a better interface. Remove, or comment this code once done
        .frame(width: 500, height: 800, alignment: .center)
    }
}
