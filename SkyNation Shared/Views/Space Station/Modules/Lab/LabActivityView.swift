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
    
    @State private var animatingCollection:Bool = false
    
    /// Shows the alert asking if wants to spend token
    @State private var tokenAlert:Bool = false
    
    /// Once token is spent, no need to ask again.
    @State private var hasSpent:Bool = false
    
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
                VStack {
                    Text("Start: \(GameFormatters.dateFormatter.string(from: activity.dateStarted))")
                        .font(GameFont.monospacedBodyFont)
                        .foregroundColor(.gray)
                    Text("Total: \(Int(viewModel.totalTime)) seconds")
                }
                VStack {
                    Text("⏱ Remaining: \(Int(viewModel.timeRemaining)) seconds")
                    Text("End: \(GameFormatters.dateFormatter.string(from:activity.dateEnds))")
                        .font(GameFont.monospacedBodyFont)
                        .foregroundColor(.gray)
                }
            }
            .padding(6)
            
            
            
            if animatingCollection {
                VStack {
                    Image(systemName: "square.and.arrow.down").font(.largeTitle)
                        
                    
                    Text("Congrats !")
                        .font(GameFont.mono.makeFont())
                        .foregroundColor(.gray)
                        .padding(.top)
                    
                    Text("Activity: \(activity.activityName) finished.")
                        .font(GameFont.mono.makeFont())
                        .foregroundColor(.green)
                }
                .padding()
                .background(Color.black.opacity(0.5))
                .cornerRadius(8)
                .transition(.slide.combined(with: .opacity).combined(with: .scale))
                
                
            } else {
                GameActivityView(activity: activity)
            }
            
            if viewModel.timeRemaining > 0 {
                HStack {
                    
                    // Token
                    Button(action: {
                        print("Token")

                        if hasSpent == false {
                            if GameSettings.shared.askB4Spend == true || GameSettings.shared.askB4Spend == nil {
                                tokenAlert.toggle()
                            } else {
                                confirmSpendToken()
                            }
                        } else {
                            confirmSpendToken()
                        }
                        
                    }, label:{
                        Text("Token")
                    })
                    .buttonStyle(GameButtonStyle())
                    
                    // Cancel
                    Button(action: {
                        print("Cancel activity")
                    }, label:{
                        Text("Cancel")
                    })
                    .buttonStyle(GameButtonStyle(labelColor: .red))
                }
                .alert(isPresented: $tokenAlert) {
                    Alert(title: Text("Spend Token"), message: Text("Do you want to spend a token to reduce one hour of this activity?"), primaryButton: .default(Text("Yes")) {
                        self.hasSpent = true
                        self.confirmSpendToken()
                    }, secondaryButton: .cancel())
                }
            } else {
                if !animatingCollection {
                    HStack {
                        
                        // Throw away
                        Button(action: {
                            print("Throw out")
                            controller.throwAwayTech()
                            
                        }, label:{
                            Label("Discard", systemImage: "arrow.uturn.backward.circle")//Text("Throw Away")
                        })
                            .buttonStyle(GameButtonStyle(labelColor: .red))
                        
                        // Collect
                        Button(action: {
                            
                            print("Collect activity")
                            withAnimation (Animation.easeInOut(duration:  1.5)) {
                                self.animatingCollection = true
                            }
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                
                                self.animatingCollection = false
                                
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
                            }
                            
                        }, label:{
                            Label("Collect", systemImage:"square.and.arrow.down")//Text("Collect")
                        })
                            .buttonStyle(GameButtonStyle(labelColor: .green))
                    }
                    .transition(.slide.combined(with: .opacity))
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
    
    func confirmSpendToken() {
        
        self.hasSpent = true
        
        let result = controller.boostActivity()
        if result {
            print("Boost Success!")
        } else {
            print("Boost Failed")
        }
    }
    
}

struct LabActivity_Previews: PreviewProvider {
    
    static let tech:TechItems = TechItems.allCases.randomElement()!
    static let model:LabViewModel = LabViewModel(demo: tech)
    static let act = LabActivity(time: 30, name: "Test Lab Act")
    
    static var previews: some View {
        VStack {
            
            LabActivityView(activity: act, controller: LabViewModel(demo: act), module: LabModule.example())
        }
        // Temporarily here to show a better interface. Remove, or comment this code once done
        .frame(width: 500, height: 800, alignment: .center)
    }
}
