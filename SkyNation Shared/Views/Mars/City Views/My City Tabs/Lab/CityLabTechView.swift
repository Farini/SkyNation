//
//  CityLabTechView.swift
//  SkyNation
//
//  Created by Carlos Farini on 8/17/21.
//

import SwiftUI

struct CityLabTechView: View {
    
    @ObservedObject var controller:LocalCityController
    
    var tech:CityTech
    var ingredients:[String:Int]
    var skills:[SkillSet] = []
    
    init(controller:LocalCityController, tech:CityTech) {
        self.controller = controller
        self.tech = tech
        
        self.ingredients = [:]
        for (k, v) in tech.ingredients {
            self.ingredients[k.rawValue] = v
        }
        
        for (k, v) in tech.skillSet {
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
                Text(tech.elaborated)
                    .frame(width:300, height: 50)
                    .lineLimit(3)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gray)
                
                Text("⏱ \(TimeInterval(tech.duration).stringFromTimeInterval())")
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
                    IngredientSufficiencyView(ingredient: Ingredient(rawValue: key)!, required: value, available: controller.availabilityOf(ingredient: Ingredient(rawValue: key)!))
                        .padding([.leading, .trailing], 8)
                }
            }
            Divider()
            
            // Skills and People
            ActivityStaffView(staff: controller.availableStaff, requiredSkills: tech.skillSet) { selectedPeople in
                controller.selectedStaff = selectedPeople
            }
            
            Group {
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
                .buttonStyle(NeumorphicButtonStyle(bgColor: .gray))
                .help("Go back")
                
                if controller.unlockedTech.contains(self.tech) && ((controller.cityData.tech).contains(self.tech) == false) {
                    
                    // Can research
                    Button("🔬 Research") {
                        print("Will make tech: \(self.tech)")
                        controller.makeTech(tech: self.tech)
                    }
                    .buttonStyle(NeumorphicButtonStyle(bgColor: .orange))
                    
                } else {
                    
                    if (controller.cityData.tech).contains(self.tech) {
                        // already researched
                        Text("Already researched this item").foregroundColor(.orange)
                    } else {
                        // cant research yet
                        Text("Cannot research this item yet").foregroundColor(.orange)
                    }
                }
            }
            
            Spacer()
        }
    }
}

struct CityLabTechView_Previews: PreviewProvider {
    static var previews: some View {
        CityLabTechView(controller: LocalCityController(), tech: CityTech.allCases.randomElement()!)
    }
}
