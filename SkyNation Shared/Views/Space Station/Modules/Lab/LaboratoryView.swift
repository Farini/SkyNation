//
//  LaboratoryView.swift
//  SkyTestSceneKit
//
//  Created by Farini on 9/11/20.
//  Copyright © 2020 Farini. All rights reserved.
//

import SwiftUI

struct LaboratoryView: View {
    
    @ObservedObject var controller:LabViewModel
    
    @State var popTutorial:Bool = false
    @State var popoverLab:Bool = false
    @State var errorMessage:String = ""
    
    /// Whether `recipes` info is displaying
    @State private var infoRecipes:Bool = false
    
    /// Whether `tech` info is displaying
    @State private var infoTech:Bool = false
    
    /// Track  `recipe` selected for indicator
    @State private var selectedRecipe:Recipe? = nil
    
    /// Track `tech`  Selection for indicator
    @State private var selectedTech:TechItems? = nil
    
    var labModule:LabModule
    
    init(module:LabModule) {
        labModule = module
        if let mod = module.activity {
            print("Lab Activity: \(mod.activityName)")
        }else{
            print("No Activity")
        }
        self.controller = LabViewModel(lab: module) //.labModule = module
        
        if LocalDatabase.shared.player.experience < 3 {
            self.infoRecipes = true
            self.infoTech = true
        }
    }
    
    var header: some View {
        Group {
            HStack() {
                
                VStack(alignment:.leading) {
                    
                    if labModule.name == "untitled" || labModule.name == "Untitled" {
                        Text("🔬 Lab Module")
                            .font(GameFont.title.makeFont())
                    } else {
                        Text("🔬 \(labModule.name)")
                            .font(GameFont.title.makeFont())
                    }
                }
                
                Spacer()
                
                Group {
                    
                    // Tutorial
                    Button(action: {
                        popTutorial.toggle()
                    }, label: {
                        Image(systemName: "questionmark.circle")
                            .font(.title2)
                    })
                    .buttonStyle(SmallCircleButtonStyle(backColor: .blue))
                    .popover(isPresented: $popTutorial, attachmentAnchor: .point(.bottom),   // here !
                             arrowEdge: .bottom) {
                        TutorialView(tutType:.LabView)
                    }
                    
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
                        
                        ModulePopView(name: controller.labModule.name, module:controller.station.modules.filter({ $0.id == controller.labModule.id }).first!)
                    })
                    
                    // Close
                    Button(action: {
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
                                
                                Label {
                                    Text(recipe.rawValue)
                                        .padding(.leading, 2)
                                } icon: {
                                    recipe.image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 26, height: 26)
                                }
                                .padding(.leading, 6)
                                .padding(.vertical, 4)
                                //.font(GameFont.mono.makeFont())
                                Spacer()
                            }
                            .background(Color.black.opacity(0.3))
                            .overlay(RoundedRectangle(cornerSize: CGSize(width: 4, height: 4))
                                        .strokeBorder(style: StrokeStyle())
                                        .foregroundColor(recipe == selectedRecipe ? Color.blue:Color.clear)
                            )
                            
                            .onTapGesture {
                                
                                switch controller.selection {
                                    case .activity:
                                        print("Activity going on. Can't choose")
                                        errorMessage = "Wait for activity to be over"
                                        self.selectedRecipe = nil
                                        
                                    default:
                                        controller.selection = LabSelectState.recipe(name: recipe)
                                        self.selectedRecipe = recipe
                                        self.selectedTech = nil
                                }
                            }
                        }
                    }
                    
                    // Tech
                    Section(header: Text("Tech Tree").foregroundColor(.blue)) {
                        
                        ForEach(0..<TechItems.allCases.count) { idx in
                            
                            VStack(alignment: .leading, spacing: nil) {
                                HStack {
                                    Text(TechItems.allCases[idx].shortName)
                                        .foregroundColor(self.controller.unlockedItems.contains(TechItems.allCases[idx]) ? .orange:.gray)
                                    Spacer()
                                }
                                
                                
                                    
                                Text(TechItems.allCases[idx].rawValue)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .padding(.leading, 6)
                            .padding(.vertical, 4)
                            .background(Color.black.opacity(0.3))
                            .overlay(RoundedRectangle(cornerSize: CGSize(width: 4, height: 4))
                                        .strokeBorder(style: StrokeStyle())
                                        .foregroundColor(TechItems.allCases[idx] == selectedTech ? Color.blue:Color.clear)
                            )
                            
                            .onTapGesture {
                                switch controller.selection {
                                    case .activity:
                                        print("Activity going on. Can't choose")
                                    default:
                                        controller.selection = LabSelectState.techTree(name: TechItems.allCases[idx])
                                        self.selectedRecipe = nil
                                        self.selectedTech = TechItems.allCases[idx]
                                }
                            }
                            
                        }
                    }
                }
                .frame(width: 180, alignment: .leading)
                
                switch controller.selection {
                case .NoSelection:
                    // Show Tech Tree
                    ScrollView([.vertical, .horizontal], showsIndicators: true) {
                        VStack(spacing:6) {
                            
                            if infoRecipes == true {
                                Group {
                                    HStack(alignment:.bottom) {
                                        Label("Recipes", systemImage: "info.circle")
                                            .foregroundColor(.yellow)
                                            .padding(6)
                                            .background(Color.black.opacity(0.5))
                                            .cornerRadius(6)
                                            .onTapGesture {
                                                self.infoRecipes.toggle()
                                            }
                                        
                                        Text("transform").foregroundColor(.gray)
                                        Text("ingredients").foregroundColor(.blue)
                                        Text("into")
                                        Text("Peripherals").foregroundColor(.orange)
                                        
                                        Spacer()
                                    }
                                    
                                    HStack {
                                        Text("Peripherals").foregroundColor(.orange)
                                        Text("recycle the Space Station's resources").foregroundColor(.gray)
                                        Spacer()
                                    }
                                    
                                    HStack {
                                        Text("A well planned set of Peripherals can make a Space Station sustainable for a long time.")
                                        Spacer()
                                    }
                                }
                                .transition(.slide.combined(with:AnyTransition.opacity))
                                
                                Divider()
                                
                            } else {
                                HStack {
                                    Label("Recipes", systemImage: "info.circle")
                                        .foregroundColor(.yellow)
                                        .padding(6)
                                        .background(Color.black.opacity(0.5))
                                        .cornerRadius(6)
                                        .onTapGesture {
                                            self.infoRecipes.toggle()
                                        }
                                    
                                    Spacer()
                                }
                                .transition(.move(edge:.leading).combined(with:AnyTransition.opacity))
                            }
                            
                            if infoTech == true {
                                Group {
                                    HStack {
                                        
                                        Label("Tech Tree", systemImage: "info.circle")
                                            .foregroundColor(.blue)
                                            .padding(6)
                                            .background(Color.black.opacity(0.5))
                                            .cornerRadius(6)
                                            .onTapGesture {
                                                self.infoTech.toggle()
                                            }
                                        
                                        Spacer()
                                    }
                                    HStack {
                                        Text("Research on tech tree items lead to the expansion of the Space Station").foregroundColor(.gray)
                                        Spacer()
                                    }
                                    
                                    HStack {
                                        Text("The items with a").foregroundColor(.gray)
                                        Text("blue").foregroundColor(.blue)
                                        Text("blue background indicate that you have comlpeted researching that tech.").foregroundColor(.gray)
                                        Spacer()
                                    }
                                    
                                    HStack {
                                        Text("The items with a black background haven't been researched yet.").foregroundColor(.gray)
                                        Spacer()
                                    }
                                    
                                    HStack {
                                        Text("One may only research items immediately below another research item.")
                                        Spacer()
                                    }
                                }
                                .transition(.slide.combined(with:AnyTransition.opacity))
                                
                            } else {
                                HStack {
                                    
                                    Label("Tech Tree", systemImage: "info.circle")
                                        .foregroundColor(.blue)
                                        .padding(6)
                                        .background(Color.black.opacity(0.5))
                                        .cornerRadius(6)
                                        .onTapGesture {
                                            self.infoTech.toggle()
                                        }
                                    
                                    Spacer()
                                }
                                .transition(.slide.combined(with:AnyTransition.opacity))
                            }
                        
                            Divider()
                            
                            DiagramContent(controller:controller)
                            
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
        .frame(minWidth: 800, minHeight: 600, alignment: .center)
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
