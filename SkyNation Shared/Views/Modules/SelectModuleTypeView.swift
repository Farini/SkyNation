//
//  SelectModuleTypeView.swift
//  SkyTestSceneKit
//
//  Created by Farini on 9/14/20.
//  Copyright © 2020 Farini. All rights reserved.
//

import SwiftUI

struct SelectModuleTypeView: View {
    
    @Environment(\.presentationMode) var presentationMode // To Dismiss
    @ObservedObject var controller:ModulesViewModel
    let modOptions:[ModuleType] = ModuleType.allCases
    
    /// The original UUID of the object
    var moduleID:UUID
    
    init(name:String?) {
        self.controller = ModulesViewModel()
        self.moduleID = UUID(uuidString: name ?? "") ?? UUID()
    }
    
    var body: some View {
        
        VStack {
            
            Group {
                
                Text("Choose Module Type")
                    .font(.largeTitle)
                    .foregroundColor(.orange)
                
                Group {
                    Text("Air volume: \(controller.airVolume)")
                    Text("Required Air: \(controller.reqVolume)")
                    Text("Active Modules: \(controller.countOfModules)")
                    
                    // Problems
                    ForEach(controller.problems, id:\.self) { problem in
                        Text("\(problem)")
                            .foregroundColor(controller.canBuild ? .green:.red)
                    }
                }
                
                Divider()
            }
            
            switch controller.viewState {
                case .Selecting:
                    
                    
                    // Select Type
                    HStack(alignment: .top, spacing: 6) {
                        
                        ForEach(modOptions, id:\.self) { mod in
                            VStack {
                                Text("\(mod.rawValue) Module")
                                    .font(.headline)
                                    .padding(4)
                                
                                Divider()
                                
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
                                
                                Button(action: {
                                    controller.selectModule(type: mod, id: moduleID)
                                }, label: {
                                    Text("Build \(mod.rawValue)")
                                })
                                .disabled(!controller.canBuild)
                                .padding(4)
                            }
                            .padding(4)
                            .background(Color.black)
                            .cornerRadius(8.0)
                            
                        }
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
                        
                        Text("Please Confirm Module")
                            .foregroundColor(Color.red)
                            .padding()
                        
                        Text("Module ID: \(moduleID)").foregroundColor(.gray)
                        
                        Text("Module type: \(type.rawValue)")
                        
                        ForEach(controller.problems, id:\.self) { reason in
                            Text(reason)
                                .foregroundColor(Color.green)
                        }
                        
                        HStack {
                            Button("Confirm") {
                                controller.confirmBuildingModule()
                            }
                            Button("Cancel") {
                                controller.cancelBuildModule()
                            }
                        }
                    }
                 
                case .Confirmed:
                    Text("Module Created")
                    
                }
        }
        .padding()
    }
    
    /// Dismisses the SwiftUI View
    func dismissView() {
        self.presentationMode.wrappedValue.dismiss()
    }
}

struct SelectModuleTypeView_Previews: PreviewProvider {
    static var previews: some View {
        SelectModuleTypeView(name: UUID().uuidString)
    }
}
