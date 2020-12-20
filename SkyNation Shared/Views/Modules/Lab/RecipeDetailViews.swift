//
//  RecipeDetailViews.swift
//  SkyTestSceneKit
//
//  Created by Carlos Farini on 12/17/20.
//  Copyright © 2020 Farini. All rights reserved.
//

import SwiftUI

struct RecipeDetailView:View {
    
    @ObservedObject var labModel:LabViewModel
    
    var recipe:Recipe
    var ingredients:[String:Int]
    var skills:[SkillSet] = []
    
    init(recipe:Recipe, model:LabViewModel) {
        self.labModel = model
        self.recipe = recipe
        
        self.ingredients = [:]
        for (k, v) in recipe.ingredients() {
            self.ingredients[k.rawValue] = v
        }
        
        for (k, v) in recipe.skillSet() {
            let newSet = SkillSet(skill: k, level: v)
            skills.append(newSet)
        }
    }
    
    var body:some View {
        
        VStack {
                
            Group {
                Text("Recipe \(recipe.rawValue)")
                    .foregroundColor(.orange)
                    .font(.largeTitle)
                
                Text("\(recipe.elaborate)")
                    .foregroundColor(.gray)
                    .font(.caption)
                Text("⏱ \(recipe.getDuration())")
                    .font(.largeTitle)
                    .padding()
            }
            
            Divider()
            
            // Ingredients
            Group {
                Text("Ingredients")
                    .font(.headline)
                
                HStack {
                    ForEach(ingredients.sorted(by: >), id:\.key) { key, value in
                        IngredientSufficiencyView(ingredient: Ingredient(rawValue: key)!, required: value, available: labModel.availabilityOf(ingredient: Ingredient(rawValue: key)!))
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
                
                Text("Select workers")
                    .font(.headline)
                
                // People to Select
                ScrollView(.horizontal, showsIndicators: true) {
                    StaffSelectionView(controller: self.labModel, people: labModel.availableStaff, selection: [])
                }
                
                Divider()
            }
            
            if labModel.problems != nil {
                Text(labModel.problems!)
                    .foregroundColor(.red)
                    .padding()
            }
            
            // Buttons
            HStack {
                
                Button("Cancel") {
                    self.labModel.cancelSelection()
                }
                .padding()
                
                Button("Make Recipe") {
                    self.labModel.makeRecipe(recipe: recipe)
                }
                
                .padding()
                .disabled(labModel.recipeDisabled(recipe: recipe))
                
            }
        }
        
    }
    
}


 struct RecipeDetail_Previews: PreviewProvider {
    
    static let recipe:Recipe = Recipe.allCases.randomElement()!
    static let model:LabViewModel = LabViewModel(demo: recipe)
    
    static var previews: some View {
        VStack {
            Text("Random recipe - For Preview Only")
                .padding()
            
            RecipeDetailView(recipe: self.recipe, model: self.model)
        }
        
    }
 }
 
