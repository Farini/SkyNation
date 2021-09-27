//
//  CityLabView.swift
//  SkyNation
//
//  Created by Carlos Farini on 7/24/21.
//

import SwiftUI

struct CityLabView: View {
    
    @ObservedObject var controller:LocalCityController
    @State var labState:CityLabState
    
    var body: some View {
        
        HStack {
            List() {
                Section(header: recipeHeader) {
                    ForEach(Recipe.marsCases, id:\.self) { recipe in
                        Text(recipe.rawValue).foregroundColor(.blue)
                            .onTapGesture {
                                controller.didSelectLab(tech: nil, recipe: recipe)
                            }
                    }
                }
                Section(header: techHeader) {
                    ForEach(CityTech.allCases, id:\.self) { tech in
                        Text(tech.rawValue).foregroundColor(.blue)
                            .onTapGesture {
                                controller.didSelectLab(tech: tech, recipe: nil)
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
                            CityTechDiagram()
                            
                        case .recipe(let name):
                            CityLabRecipeView(controller: controller, recipe: name)
                        case .tech(let name):
                            CityLabTechView(controller: controller, tech: name)
                        case .activity(let object):
                            
                            let model = LabActivityViewModel(labActivity: object)
                            CityLabActivityView(activityModel: model, labActivity: object) { dismState in
                                
                                switch dismState {
                                    case .cancelled:
                                        print("Cancelled")
                                        controller.cityData.labActivity = nil
                                        controller.labActivity = nil
                                        controller.cancelSelectionOn(tab: .lab)
                                        
                                    case .finishedRecipe(let recipe):
                                        print("Finished recipe: \(recipe.rawValue)")
                                    case .finishedTech(let tech):
                                        print("Finished Tech: \(tech.rawValue)")
                                    case .useToken(let token):
                                        print("Use token. \(token.id)")
                                        
                                }
                                
                                // Dismiss Activity
                                print("CityLab view wants to dismiss.... ")
                                controller.cancelSelectionOn(tab: .lab)
//                                controller.labSelection = .NoSelection
                            }
                    }
                }
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
