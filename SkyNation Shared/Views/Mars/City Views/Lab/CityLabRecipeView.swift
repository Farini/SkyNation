//
//  CityLabRecipeView.swift
//  SkyNation
//
//  Created by Carlos Farini on 8/17/21.
//

import SwiftUI

struct CityLabRecipeView: View {
    
    @ObservedObject var controller:CityController
    
    var recipe:Recipe
    var skills:[SkillSet] = []
    
    init(controller:CityController, recipe:Recipe) {
        self.controller = controller
        self.recipe = recipe
        for (k, v) in recipe.skillSet() {
            let newSet = SkillSet(skill: k, level: v)
            skills.append(newSet)
        }
    }
    
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
                    ForEach(0..<skills.count, id:\.self) { rSkill in
                        let sset = self.skills[rSkill]
                        
                        GameImages.imageForSkill(skill: sset.skill)
                            .resizable()
                            .aspectRatio(contentMode:.fit)
                            .frame(width:34, height:34)
                        
                        Text("x \(sset.level)")
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
                    controller.cancelSelection()
                }) {
                    HStack {
                        Image(systemName: "backward.frame")
                        Text("Back")
                    }
                }
                .buttonStyle(NeumorphicButtonStyle(bgColor: .blue))
                .help("Go back")
                
                
                Button("🛠 Make Recipe") {
                    controller.makeRecipe(recipe: recipe)
                }
                .buttonStyle(NeumorphicButtonStyle(bgColor: .orange))
                .disabled(controller.recipeDisabled(recipe: recipe))
                
            }
        }
    }
}

struct CityLabRecipeView_Previews: PreviewProvider {
    static let recipe = Recipe.marsCases.randomElement()!
    static var previews: some View {
        CityLabRecipeView(controller: CityController(), recipe:CityLabRecipeView_Previews.recipe)
            .frame(height:550)
    }
}
