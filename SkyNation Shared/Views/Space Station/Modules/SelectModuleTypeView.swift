//
//  SelectModuleTypeView.swift
//  SkyTestSceneKit
//
//  Created by Farini on 9/14/20.
//  Copyright © 2020 Farini. All rights reserved.
//

import SwiftUI

struct SelectModuleTypeView: View {
    
//#if os(macOS)
//    @Environment(\.presentationMode) var presentationMode // To Dismiss
//#elseif os(iOS)
//#endif
    
    @ObservedObject var controller:ModulesViewModel
    let modOptions:[ModuleType] = [.Hab, .Lab, .Bio]
    
    /// The original UUID of the object
    var moduleID:UUID
    
    init(name:String?) {
        self.controller = ModulesViewModel()
        self.moduleID = UUID(uuidString: name ?? "") ?? UUID()
    }
    
    var header: some View {
        
        VStack {
            
            HStack {
                
                VStack(alignment: .leading) {
                    Text("Base Module")
                        .font(.largeTitle)
                        .foregroundColor(.orange)
                    Text("Choose a Module type to build")
                        .foregroundColor(.gray)
                }
                
                
                Spacer()
                
                // Tutorial
                Button(action: {
                    print("Question ?")
                }, label: {
                    Image(systemName: "questionmark.circle")
                        .font(.title2)
                })
                .buttonStyle(SmallCircleButtonStyle(backColor: .orange))
                
                // Close
                Button(action: {
                    NotificationCenter.default.post(name: .closeView, object: self)
                }) {
                    Image(systemName: "xmark.circle")
                        .font(.title2)
                }.buttonStyle(SmallCircleButtonStyle(backColor: .pink))
                
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
            
            // Air
            Group {
                
                HStack {
                    GameImages.imageForTank()
                    
                    VStack(alignment:.leading) {
                        HStack {
                            Text("Air volume: \(controller.airVolume)")
                            Text("+ \(controller.reqVolume - controller.airVolume)")
                        }
                        
                        Text("Adding air: \(controller.reqAirFromTanks)")
                        Text("Available air: \(controller.availableAirInTanks)")
                        Text("Active Modules: \(controller.countOfModules)")
                    }
                    .foregroundColor(controller.canBuild ? GameColors.airBlue:Color.red)
                }
                
                // Problems
                ForEach(controller.problems, id:\.self) { problem in
                    Text("\(problem)")
                        .foregroundColor(controller.canBuild ? .green:.red)
                }
            }
            
            Divider()
            
            switch controller.viewState {
                case .Selecting:
                    
                    Group {
                        // Select Type
                        HStack(alignment: .top, spacing: 6) {
                            
                            ForEach(modOptions, id:\.self) { mod in
                                VStack {
                                    Text("\(mod.rawValue) Module")
                                        .font(.headline)
                                        .padding(4)
                                    
                                    Divider()
                                    Group {
                                        if mod == ModuleType.Lab {
                                            Text("🔬").font(.largeTitle)
                                        }
                                        if mod == ModuleType.Hab {
                                            Text("🏠").font(.largeTitle)
                                        }
                                        if mod == ModuleType.Bio {
                                            Text("🧬").font(.largeTitle)
                                        }
                                        if mod == ModuleType.Unbuilt {
                                            Text("🛠").font(.largeTitle)
                                        }
                                        Text(mod.objective())
                                            .frame(minWidth: 180, maxWidth: 200, idealHeight: 75, maxHeight: 100, alignment: Alignment.center)
                                            .fixedSize(horizontal: false, vertical: true)
                                            .lineLimit(nil)
                                            .foregroundColor(.gray)
                                    }
                                    
                                    
                                    Button(action: {
                                        controller.selectModule(type: mod, id: moduleID)
                                    }, label: {
                                        Text("Build \(mod.rawValue)")
                                    })
                                    .disabled(controller.isDisabledModule(type: mod))
                                    .buttonStyle(GameButtonStyle())
                                    .padding([.bottom])
                                }
                                .padding(4)
                                .background(Color.black)
                                .cornerRadius(8.0)
                            }
                        }
                        .padding()
                    }
                    
                    
                case .Problematic:
                    VStack {
                        
                        Text("Problem Encountered")
                            .font(.headline)
                        
                        Text("Cannot Build")
                            .foregroundColor(Color.red)
                            .padding()
                        
                        ForEach(controller.problems, id:\.self) { reason in
                            Text(reason)
                                .foregroundColor(Color.red)
                            
                        }
                    }
                    
                case .Selected(type: let type):
                    VStack {
                        
                        Group {
                            Text("Please Confirm Module")
                                .foregroundColor(Color.red)
                                .padding()
                            
                            Text("Module ID: \(moduleID)").foregroundColor(.gray)
                            
                            Text("Module type: \(type.rawValue)")
                        }
                        
                        
                        ForEach(controller.problems, id:\.self) { reason in
                            Text(reason)
                                .foregroundColor(Color.green)
                        }
                        
                        HStack {
                            Button("Confirm") {
                                controller.confirmBuildingModule(id:self.moduleID)
                            }
                            .buttonStyle(NeumorphicButtonStyle(bgColor:.green))
                            
                            Button("Cancel") {
                                controller.cancelBuildModule()
                            }
                            .buttonStyle(NeumorphicButtonStyle(bgColor:.orange))
                        }
                    }
                 
                case .Confirmed:
                    VStack {
                        Text("Module Created")
                        
                        Button("OK") {
                            // Close the View
                            NotificationCenter.default.post(name: .closeView, object: self)
                        }
                        .buttonStyle(NeumorphicButtonStyle(bgColor:.green))
                    }
                }
        }
    }
}

struct SelectModuleTypeView_Previews: PreviewProvider {
    static var previews: some View {
        SelectModuleTypeView(name: UUID().uuidString)
    }
}
