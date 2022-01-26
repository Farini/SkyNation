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
                
                Text("Research")
                    .font(GameFont.title.makeFont())
                    .padding()
                
                Text(tech.shortName)
                    .font(.largeTitle)
                    .foregroundColor(.orange)
                
//                Text("Tech \(tech.shortName)")
//                    .foregroundColor(.gray)
                if let imName:String = tech.detailImageName {
                    Image(imName)
                        .resizable()
                        .frame(width:128, height:128)
                }
                
                // Description text
                Text(tech.elaborate())
                    .frame(width:400, height: 50)
                    .fixedSize(horizontal: true, vertical: false)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.gray)
                    
                Text("⏱ \(TimeInterval(tech.getDuration()).stringFromTimeInterval())")
                    .font(.title)
                    .padding(.top)
                Text("* Time to complete this research.").foregroundColor(.gray)
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
                }
            }
            Divider()
            
            // Skills and People
            ActivityStaffView(staff: labModel.availableStaff, requiredSkills: tech.skillSet()) { (selectedPeople) in
                labModel.selectedStaff = selectedPeople
            }
            
            Divider()
            
            if labModel.problems != nil {
                Text(labModel.problems!)
                    .foregroundColor(.red)
                    .padding()
            }
            
            // Buttons
            HStack {
                
                Button(action: {
                    self.labModel.cancelSelection()
                }) {
                    HStack {
                        Image(systemName: "backward.frame")
                        Text("Back")
                    }
                }
                .buttonStyle(NeumorphicButtonStyle(bgColor: .gray))
                .help("Go back")
                
                if labModel.unlockedItems.contains(self.tech) {
                    
                    // Can research
                    Button("🔬 Research") {
                        print("Will make tech: \(self.tech)")
                        self.labModel.makeTech(item: self.tech)
                    }
                    .buttonStyle(NeumorphicButtonStyle(bgColor: .orange))
                    
                } else {
                    
                    if labModel.station.unlockedTechItems.contains(self.tech) {
                        // already researched
                        Text("Already researched this item").foregroundColor(.orange)
                    } else {
                        // cant research yet
                        Text("Cannot research this item yet").foregroundColor(.orange)
                    }
                    
                }
            }
            .padding(.bottom, 8)
            
        }
        .frame(minHeight:700)
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

