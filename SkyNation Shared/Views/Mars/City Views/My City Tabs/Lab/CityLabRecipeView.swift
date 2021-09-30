//
//  CityLabRecipeView.swift
//  SkyNation
//
//  Created by Carlos Farini on 8/17/21.
//

import SwiftUI

struct CityLabRecipeView: View {
    
    @ObservedObject var controller:LocalCityController
    var recipe:Recipe
    var action:((LabActivity) -> ()) // = {}
    
//    init(controller:LocalCityController, recipe:Recipe) {
//        self.controller = controller
//        self.recipe = recipe
//    }
    
    var body: some View {
        VStack {
            Group {
                Text("Recipe \(recipe.rawValue)")
                    .foregroundColor(.orange)
                    .font(.largeTitle)
                
                HStack {
                    recipe.image
                        .font(.largeTitle)
                    Text("⏱ \(TimeInterval(recipe.getDuration()).stringFromTimeInterval())")
                        .font(.title)
                        .padding()
                }
                
                Text("\(recipe.elaborate)")
                    .foregroundColor(.gray)
                
            }
            
            Divider()
            
            // Ingredients
            Group {
                Text("Ingredients")
                    .font(.headline)
                
                HStack {
                    ForEach(recipe.ingredients().sorted(by: { $0.key.rawValue < $1.key.rawValue }), id:\.key) { key, value in
                        IngredientSufficiencyView(ingredient: Ingredient(rawValue: key.rawValue)!, required: value, available: controller.availabilityOf(ingredient: Ingredient(rawValue: key.rawValue)!))
                            .padding([.leading, .trailing], 8)
                    }
                }
                Divider()
            }
            
            // Skills
            Group {
                
                Text("Skills")
                    .font(.headline)
                
                HStack {
                    let keyArray = recipe.skillSet().compactMap({ $0.key })
                    
                    ForEach(keyArray, id:\.self) { aKey in
                        
                        let sset = recipe.skillSet()[aKey]
                        
                        GameImages.imageForSkill(skill: aKey)
                            .resizable()
                            .aspectRatio(contentMode:.fit)
                            .frame(width:34, height:34)
                        
                        Text("x \(sset ?? 0)")
                            .font(.caption)
                            .padding([.trailing], 6)
                    }
                }
                
                // Skills and People
                ActivityStaffView(staff: controller.availableStaff, selected: [], requiredSkills: recipe.skillSet(), chooseWithReturn: { (selectedPeople) in
                    controller.selectedStaff = selectedPeople
                }, title: "\(recipe) Skills Required", issue: "", message: "")
                
                // Empty Staff
                if controller.availableStaff.isEmpty {
                    VStack {
                        HStack {
                            Spacer()
                            Text("< No one is available >").foregroundColor(.red)
                            Spacer()
                        }
                    }
                    .background(Color.black)
                }
                
                // Warnings
                if !controller.warnings.isEmpty {
                    VStack {
                        ForEach(controller.warnings, id:\.self) { warning in
                            HStack {
                                Spacer()
                                Text(warning).foregroundColor(.orange)
                                Spacer()
                            }
                        }
                    }
                    .background(Color.black)
                }
                
                Divider()
            }
            
            // Buttons
            HStack {
                
                Button(action: {
                    controller.cancelSelectionOn(tab: .lab)
                }) {
                    HStack {
                        Image(systemName: "backward.frame")
                        Text("Back")
                    }
                }
                .buttonStyle(NeumorphicButtonStyle(bgColor: .blue))
                .help("Go back")
                
                
                Button("🛠 Make Recipe") {
                    let res = controller.makeRecipe(recipe: recipe)
                    if let activity = controller.labActivity, res == true {
                        print("Activity in, and result true")
                        self.action(activity)
                    } else {
                        
                    }
                }
                .buttonStyle(GameButtonStyle())
                // .disabled(controller.recipeDisabled(recipe: recipe))
                
            }
        }
    }
}

struct CityLabRecipeView_Previews: PreviewProvider {
    static let recipe = Recipe.marsCases.randomElement()!
    static var previews: some View {
        CityLabRecipeView(controller: LocalCityController(), recipe:CityLabRecipeView_Previews.recipe, action: {_ in})
            .frame(height:550)
    }
}
