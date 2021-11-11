//
//  CityLabView.swift
//  SkyNation
//
//  Created by Carlos Farini on 7/24/21.
//

import SwiftUI

struct CityLabView: View {
    
    @ObservedObject var controller:LocalCityController
    @State var labState:CityLabState = .NoSelection
    
    @State private var selectedRecipe:Recipe?
    
    var body: some View {
        
        HStack {
            List() {
                Section(header: recipeHeader) {
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
                            
                            switch labState {
                                case .activity(let object):
                                    print("Activity going on:\(object.activityName). Can't choose ")
//                                    errorMessage = "Wait for activity to be over"
                                    self.selectedRecipe = nil
                                    self.labState = .activity(object: object)
                                    
                                default:
                                    self.selectedRecipe = recipe
                                    self.labState = .recipe(name: recipe)
                                    
                            }
                        }
                    }
                }
                Section(header: techHeader) {
                    ForEach(controller.unlockedTech, id:\.self) { tech in
                        Text(tech.rawValue).foregroundColor(.blue)
                            .onTapGesture {
                                switch labState {
                                    case .activity(let object):
                                        print("Activity going on:\(object.activityName). Can't choose ")
                                        self.selectedRecipe = nil
                                        self.labState = .activity(object: object)
                                    default:
                                        self.labState = .tech(name: tech)
                                }
                            }
                    }
                }
            }
            .frame(minWidth: 120, idealWidth: 150, maxWidth: 180, minHeight: 300, idealHeight: 500, maxHeight: .infinity, alignment: .center)
            
            ScrollView([.vertical, .horizontal], showsIndicators: true) {
                VStack {
                    switch labState {
                        case .NoSelection:
                            HStack {
                                Text("City Tech").font(.title).foregroundColor(.blue)
                                Spacer()
                            }
                            
                            CityTechDiagram(city: controller.cityData) { chosenTech in
                                self.labState = .tech(name: chosenTech)
                            }
                            
                            
                        case .recipe(let name):
                            CityLabRecipeView(controller: controller, recipe: name) { activity in
                                // When making a recipe, we get an activity
                                self.labState = .activity(object: activity)
                            }
                            
                        case .tech(let name):
                            CityLabTechView(controller: controller, tech: name)
                        case .activity(let object):
                            
                            let cActivity = controller.labActivity ?? object
                            CityLabActivityView(activity: cActivity) { activity, cancelled in
                                print("\n [LAB] Collecting Activity: \(activity.activityName)")
                                print("Start: \(GameFormatters.fullDateFormatter.string(from: activity.dateStarted))")
                                print("Finish: \(GameFormatters.fullDateFormatter.string(from: activity.dateEnds))")
                                if cancelled == true {
                                    // Cancelling
                                    self.labState = .NoSelection
                                    controller.labActivity = nil
                                    controller.cityData.labActivity = nil
                                } else {
                                    controller.collectActivity(activity: activity)
                                    self.labState = .NoSelection
                                }
                            }
                    }
                }
            }
        }
        .onAppear() {
            
            if let activity = controller.labActivity {
                self.labState = .activity(object: activity)
            }
        }
    }
    
    var recipeHeader: some View {
        HStack {
            Image(systemName: "list.bullet.rectangle")
            Text("Recipes")
        }
    }
    
    var techHeader: some View {
        HStack {
            Image(systemName: "list.bullet.indent")
            Text("Tech Tree")
        }
    }
}

struct CityLabView_Previews: PreviewProvider {
    static var previews: some View {
        CityLabView(controller: LocalCityController(), labState: .NoSelection)
    }
}
