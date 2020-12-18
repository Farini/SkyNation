//
//  TechnologyDetailViews.swift
//  SkyTestSceneKit
//
//  Created by Carlos Farini on 12/17/20.
//  Copyright © 2020 Farini. All rights reserved.
//

import SwiftUI

struct TechnologyDetailView: View {
    
    @ObservedObject var labModel:LabViewModel
    
    var tech:TechItems
    var ingredients:[String:Int]
    var skills:[SkillSet] = []
    
    init(tech:TechItems, model:LabViewModel) {
        self.labModel = model
        self.tech = tech
        
        self.ingredients = [:]
        for (k, v) in tech.ingredients() {
            self.ingredients[k.rawValue] = v
        }
        
        for (k, v) in tech.skillSet() {
            let newSet = SkillSet(skill: k, level: v)
            skills.append(newSet)
        }
    }
    
    var body: some View {
        VStack {
            
            // Head / Definitions
            Group {
                Text(tech.shortName)
                    .font(.largeTitle)
                    .foregroundColor(.orange)
                
                Text("Tech \(tech.rawValue)")
                    .foregroundColor(.gray)
                
                // Description text
                Text(tech.elaborate())
                    .padding()
                    .frame(maxWidth: 300, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                
                Text("⏱ \(tech.getDuration())")
                    .font(.largeTitle)
                
            }
            Divider()
            
            // Ingredients
            Text("Ingredients")
                .font(.headline)
                .foregroundColor(.orange)
                .padding()
            HStack {
                ForEach(ingredients.sorted(by: >), id:\.key) { key, value in
                    IngredientSufficiencyView(ingredient: Ingredient(rawValue: key)!, required: value, available: labModel.availabilityOf(ingredient: Ingredient(rawValue: key)!))
                        .padding([.leading, .trailing], 8)
                    //                    IngredientView(ingredient: Ingredient(rawValue: key)!, hasIngredient: nil, quantity: value).foregroundColor(.orange)
                }
            }
            Divider()
            
            // Skills and People
            Group {
                Text("Skills")
                    .font(.headline)
                    .foregroundColor(.orange)
                    .padding()
                
                HStack {
                    ForEach(0..<skills.count, id:\.self) { rSkill in
                        //                    SkillsetView(skillset: self.skills[rSkill])
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
            }
            
            Divider()
            
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
                
                Button("Research") {
                    print("Will make tech: \(self.tech)")
                    self.labModel.makeTech(item: self.tech)
                }
                .padding()
            }
            
            Spacer()
        }
        
    }
}

struct TechnologyDetail_Previews: PreviewProvider {
    
    static let tech:TechItems = TechItems.allCases.randomElement()!
    static let model:LabViewModel = LabViewModel(demo: tech)
    
    static var previews: some View {
        VStack {
            Text("Random tech - For Preview Only")
                .padding()
            
            TechnologyDetailView(tech: tech, model: model)
        }
        
    }
}

