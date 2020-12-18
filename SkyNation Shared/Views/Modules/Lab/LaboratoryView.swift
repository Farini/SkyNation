//
//  LaboratoryView.swift
//  SkyTestSceneKit
//
//  Created by Farini on 9/11/20.
//  Copyright © 2020 Farini. All rights reserved.
//

import SwiftUI

struct LaboratoryView: View {
    
    @ObservedObject var controller:LabViewModel // = LabViewModel()
    
    @State var popoverLab:Bool = false
    @State var errorMessage:String = ""
    
    var labModule:LabModule
    
    init(module:LabModule) {
        labModule = module
        if let mod = module.activity {
            print("Lab Activity: \(mod.activityName)")
        }else{
            print("No Activity")
        }
        self.controller = LabViewModel(lab: module) //.labModule = module
    }
    
    var body: some View {
        
        VStack {
            
            // Header
            VStack(alignment: .leading, spacing: 4) {
                
                HStack(alignment: VerticalAlignment.lastTextBaseline, spacing: nil) {
                    
                    // Menu
                    Button("⚙️") {
                        print("action")
                        popoverLab.toggle()
                    }
                    .popover(isPresented: $popoverLab, content: {
                        VStack {
                            Button("Rename Module") {
                                print("action")
                                popoverLab.toggle()
                            }
                            Button("Empty Module") {
                                print("action")
                                popoverLab.toggle()
                            }
                        }
                    })
                    .padding(.leading, /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
                    
                    // Head
                    Text("🔬 Laboratory Module")
                        .font(.largeTitle)
                        .padding(6)
                        .foregroundColor(.blue)
                    
                    Spacer()
                    
                    // Name
                    Text(labModule.name)
                        .font(.headline)
                        .padding(.trailing, 10)
                }
                
                HStack {
                    Text("ID: \(labModule.id)")
                        .foregroundColor(.gray)
                        .font(.caption)
                        .padding(.leading, 10)
                    Spacer()
                    if !errorMessage.isEmpty {
                        Text("* \(errorMessage)")
                            .foregroundColor(.red)
                            .font(.callout)
                            .padding(.trailing, 10)
                    }
                }
                
                Divider()
            }
            .padding(.top)
            
            // Main Body
            HStack(alignment: .top, spacing: 0) {
                
                // Left View (Table)
                List {
                    // Selection
                    Section(header: Text("Selection")) {
                        switch controller.selection {
                        case .NoSelection:
                            Text("No Selection")
                        case .recipe(let name):
                            Text("Recipe \(name.rawValue)")
                        case .techTree(let name):
                            Text("Tech \(name.rawValue)")
                        case .activity:
                            Text("Activity")
                        }
                    }
                    
                    // Recipes
                    Section(header: Text("Recipes")) {
                        ForEach(controller.unlockedRecipes, id:\.self) { recipe in
                            Text(recipe.rawValue)
                                .foregroundColor(.green)
                                .onTapGesture {
                                    // print("Did tap")
                                    
                                    switch controller.selection {
                                        case .activity:
                                            print("Activity going on. Can't choose")
                                            errorMessage = "Wait for activity to be over"
                                        default:
                                            controller.selection = LabSelectState.recipe(name: recipe)
                                    }
                                }
                        }
                    }
                    
                    // Tech
                    Section(header: Text("Tech Tree Items")) {
                        
                        ForEach(0..<TechItems.allCases.count) { idx in
                            
                            VStack(alignment: .leading, spacing: nil) {
                                Text(TechItems.allCases[idx].shortName)
                                    //                            Text("Tech. \(TechItems.allCases[idx].rawValue)")
                                    .foregroundColor(self.controller.unlockedItems.contains(TechItems.allCases[idx]) ? .orange:.gray)
                                    
                                Text(TechItems.allCases[idx].rawValue)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .onTapGesture {
                                switch controller.selection {
                                    case .activity:
                                        print("Activity going on. Can't choose")
                                    default:
                                        controller.selection = LabSelectState.techTree(name: TechItems.allCases[idx])
                                }
                            }
                            
                        }
                    }
                }
                .frame(width: 180, alignment: .leading)
                
                switch controller.selection {
                case .NoSelection:
                    // Show Tech Tree
                    ScrollView([.vertical, .horizontal], showsIndicators: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/) {
                        VStack {
                            Spacer()
                            Text("Tech Tree").font(.largeTitle)
                            Divider()
                            DiagramContent()
                            Divider()
                        }
                        .padding()
                    }
                    
                case .recipe(let name):
                    ScrollView {
                        RecipeDetailView(recipe: name, model: self.controller)
                    }
                    
                case .techTree(let name):
                    ScrollView {
                        TechnologyDetailView(tech: name, model: self.controller)
                    }
                    
                case .activity:
                    LabActivityView(activity: self.labModule.activity!, controller:self.controller, module: self.labModule)
                }
            }
        }
        .frame(minWidth: 800, minHeight: 600, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
    }
}

// MARK: - Previews

struct LaboratoryView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LaboratoryView(module: LabModule.example())
        }
    }
}
