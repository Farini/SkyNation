//
//  CityLabView.swift
//  SkyNation
//
//  Created by Carlos Farini on 7/24/21.
//

import SwiftUI

struct CityLabView: View {
    
    @ObservedObject var controller:CityController
    
    var body: some View {
            
            HStack {
                List() {
                    Section(header: recipeHeader) {
                        ForEach(Recipe.marsCases, id:\.self) { recipe in
                            Text(recipe.rawValue).foregroundColor(.blue)
                                .onTapGesture {
                                    controller.labSelect(recipe: recipe)
                                }
                        }
                    }
                    Section(header: techHeader) {
                        ForEach(CityTech.allCases, id:\.self) { tech in
                            Text(tech.rawValue).foregroundColor(.blue)
                                .onTapGesture {
                                    controller.labSelect(tech: tech)
                                }
                        }
                    }
                }
                .frame(minWidth: 120, idealWidth: 150, maxWidth: 180, minHeight: 300, idealHeight: 500, maxHeight: .infinity, alignment: .center)
                
                ScrollView([.vertical, .horizontal], showsIndicators: true) {
                    VStack {
                        switch controller.labSelection {
                            case .NoSelection:
                                HStack {
                                    Text("City Tech").font(.title).foregroundColor(.blue)
                                    Spacer()
                                }
                                CityTechDiagram()
                                
                            case .recipe(let recipe):
                                
                                CityLabRecipeView(controller: controller, recipe: recipe)
                                
                            case .tech(let tech):
                                
                                CityLabTechView(controller: controller, tech: tech)
                                
                            case .activity(let activity):
                                // CityLabActivityView(activity: activity, city: .constant(controller.cityData!)) {
                                
//                                CityLabActivityView(activity: activity, city: controller.cityData!) {
                                let model = LabActivityViewModel(labActivity: activity)
                                
                                CityLabActivityView(activityModel: model, labActivity: activity) { dismState in
                                    
                                    switch dismState {
                                        case .cancelled:
                                            print("Cancelled")
                                        case .finishedRecipe(let recipe):
                                            print("Finished recipe: \(recipe.rawValue)")
                                        case .finishedTech(let tech):
                                            print("Finished Tech: \(tech.rawValue)")
                                        case .useToken(let token):
                                            print("Use token. \(token.id)")
                                            
                                    }
                                
                                    // Dismiss Activity
                                    print("CityLab view wants to dismiss.... ")
                                    
                                    controller.labSelection = .NoSelection
                                }
//                                Spacer()
//                                Text("Activity: \(activity.activityName)")
//                                Spacer()
                                
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
        CityLabView(controller: CityController())
    }
}
