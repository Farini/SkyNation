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
            
//            CirclePercentIndicator(percentage: CGFloat(viewModel.percentage))
            GameActivityView(activity: activity)
            
            if viewModel.timeRemaining > 0 {
                HStack {
                    Button(action: {
                        print("Boost")
                        let result = controller.boostActivity()
                        if result {
                            print("Boost Success!")
                        } else {
                            print("Boost Failed")
                        }
                    }, label:{
                        Text("Boost")
                    }).padding()
                    Button(action: {
                        print("Cancel activity")
                    }, label:{
                        Text("Cancel")
                    }).padding()
                }
            }else{
                HStack {
                    Button(action: {
                        print("Throw out")
                        controller.throwAwayTech()
                        
                    }, label:{
                        Text("Throw Away")
                    }).padding()
                    
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
                    }).padding()
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
            Text("Random activity - For Preview Only")
                .padding()
            
            LabActivityView(activity: act, controller: LabViewModel(demo: act), module: LabModule.example())
        }
        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, maxHeight: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
    }
}
