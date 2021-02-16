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
    
    var header: some View {
        Group {
            HStack() {
                
                VStack(alignment:.leading) {
                    Text("🔬 Laboratory Module")
                        .font(.largeTitle)
                    
                    HStack(alignment: .lastTextBaseline) {
                        Text("ID: \(labModule.id)")
                            .foregroundColor(.gray)
                            .font(.caption)
                            .padding(.leading, 6)
                        Text("Name: \(labModule.name)")
                            .foregroundColor(.blue)
                            .padding(.leading, /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
                        Spacer()
                    }
                }
                
                Spacer()
                
                Group {
                    // Tutorial
                    Button(action: {
                        print("Question ?")
                    }, label: {
                        Image(systemName: "questionmark.circle")
                            .font(.title2)
                    })
                    .buttonStyle(SmallCircleButtonStyle(backColor: .blue))
                    
                    // Settings
                    Button(action: {
                        print("Gear action")
                        popoverLab.toggle()
                    }, label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.title2)
                    })
                    .buttonStyle(SmallCircleButtonStyle(backColor: .orange))
                    .popover(isPresented: $popoverLab, content: {
                        VStack {
                            HStack {
                                Text("Rename")
                                Spacer()
                                Image(systemName: "textformat")
                                    .fixedSize()
                                    .scaledToFit()
                            }
                            
                            .onTapGesture {
                                print("Rename Action")
                                popoverLab.toggle()
                            }
                            Divider()
                            HStack {
                                // Text
                                Text("Change Skin")
                                // Spacer
                                Spacer()
                                // Image
                                Image(systemName: "circle.circle")
                                    .fixedSize()
                                    .scaledToFit()
                            }
                            .onTapGesture {
                                print("Reskin Action")
                                popoverLab.toggle()
                            }
                            
                            HStack {
                                Text("Tutorial")
                                Spacer()
                                Image(systemName: "questionmark.diamond")
                                    .fixedSize()
                                    .scaledToFit()
                            }
                            
                            .onTapGesture {
                                print("Reskin Action")
                                popoverLab.toggle()
                            }
                        }
                        .frame(width: 150)
                        .font(.headline)
                        .foregroundColor(.gray)
                        .padding(.leading, 6)
                    })
                    
                    // Close
                    Button(action: {
                        print("Close action")
                        NotificationCenter.default.post(name: .closeView, object: self)
                    }, label: {
                        Image(systemName: "xmark.circle")
                            .font(.title2)
                    })
                    .buttonStyle(SmallCircleButtonStyle(backColor: .pink))
                    .padding(.trailing, 6)
                }
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
            
            // Main Body
            HStack(alignment: .top, spacing: 0) {
                
                // Left View (Table)
                List {
                    
                    // Recipes
                    Section(header: Text("Recipes").foregroundColor(.yellow)) {
                        ForEach(controller.unlockedRecipes, id:\.self) { recipe in
                            HStack(alignment:.bottom) {
                                
                                recipe.image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 26, height: 26)
                                Text(recipe.rawValue)
                                    //.foregroundColor(.yellow)
                            }
                            
                            .onTapGesture {
                                
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
                    Section(header: Text("Tech Tree").foregroundColor(.blue)) {
                        
                        ForEach(0..<TechItems.allCases.count) { idx in
                            
                            VStack(alignment: .leading, spacing: nil) {
                                Text(TechItems.allCases[idx].shortName)
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
