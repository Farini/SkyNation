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
    
    var body: some View {
        
        HStack {
            List() {
                Section(header: recipeHeader) {
                    ForEach(Recipe.marsCases, id:\.self) { recipe in
                        Text(recipe.rawValue).foregroundColor(.blue)
                            .onTapGesture {
//                                controller.didSelectLab(tech: nil, recipe: recipe)
                                self.labState = .recipe(name: recipe)
                            }
                    }
                }
                Section(header: techHeader) {
                    ForEach(CityTech.allCases, id:\.self) { tech in
                        Text(tech.rawValue).foregroundColor(.blue)
                            .onTapGesture {
//                                controller.didSelectLab(tech: tech, recipe: nil)
                                self.labState = .tech(name: tech)
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
