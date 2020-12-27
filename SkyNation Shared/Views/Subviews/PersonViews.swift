//
//  PersonViews.swift
//  SkyTestSceneKit
//
//  Created by Farini on 9/22/20.
//  Copyright © 2020 Farini. All rights reserved.
//

import SwiftUI

struct LivingControl: View {
    
    @State var selected:Skills?
    
    var body: some View {
        List(selection: $selected) {
            ForEach(0..<Skills.allCases.count) { idx in
                SkillView(skill: Skills.allCases[idx])
            }
            
            IngredientView(ingredient: .Aluminium, hasIngredient: true, quantity: nil)
            IngredientView(ingredient: .Copper, hasIngredient: false, quantity: nil)
            IngredientView(ingredient: .Battery, hasIngredient: nil, quantity: nil)
        }
    }
}

struct SkillView: View {
    
    @State var skill:Skills
    
    var body: some View {
        Text(skill.short())
            .foregroundColor(self.getColor())
            .padding(4)
            .background(Color.black)
            .cornerRadius(8)
    }
    
    func getColor() -> Color {
        switch self.skill {
        case .Biologic, .Medic:
            return .red
        case .Electric, .Datacomm:
            return .blue
        default:
            return .gray
        }
    }
    
}

struct PersonRow: View {
    
    var person:Person
    var selected:Bool = false
    
    var body: some View {
        VStack {
            HStack {
                Text(selected ? "●":"○")
                Image(person.avatar)
                .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 32, height: 32)
                    
                VStack(alignment: .leading, spacing: 2) {
                    
                    HStack {
                        Text(person.name)
                        Text("- \(person.age)")
                    }
                    
                    HStack {
                        Text("Intel:")
                        Text("\(person.intelligence)")
                        if !person.skills.isEmpty {
                            Text("★ \(person.skills.first!.skill.rawValue)")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
        }
    }
}

struct PersonSmallView:View {
    
    var person:Person
    
    var body: some View {
        
            HStack {
                Image(person.avatar)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 56, height: 56)
                    .padding([.leading], 6)
                
                VStack(alignment: .leading, spacing: 2) {
                    
                    HStack {
                        Text(person.name)
                            .font(.headline)
                        Text(" (\(person.age))")
                    }
                    
                    ProgressView(value: Float(person.intelligence), total:100.0) {
                        HStack {
                            ForEach(0..<person.skills.count) { idx in
                                GameImages.imageForSkill(skill: person.skills[idx].skill)
                                    .resizable()
                                    .aspectRatio(contentMode:.fit)
                                    .frame(width:22, height:22)
                                // Text("x\(person.skills[idx].level) ")
                            }
                        }
                    }
                    .foregroundColor(.blue)
                    .accentColor(.orange)
                    
                }
                .padding([.trailing])
        }
        .frame(minWidth: 80, maxWidth: 250, minHeight: 56, maxHeight: 72, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
    }
}

struct SkillsetView:View {
    
    var skillset:SkillSet
    
    var body: some View {
        
        HStack {
            GameImages.imageForSkill(skill: skillset.skill)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 32, height: 32)
            
            Text("Skill: \(skillset.skill.rawValue)")
            Text("x \(skillset.level)")
        }
        
    }
}


struct PersonDetail:View {
    
    var person:Person
    var workoutAction:() -> Void
    
    var body: some View {
        
        VStack(alignment: .leading) {
            
            HStack {
                
                Image(person.avatar)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 64, height: 64)
                
                VStack(alignment: .leading, spacing: 4) {
                    
                    HStack {
                        Text(person.name).font(.headline)
                        Text("Age:")
                        Text("\(person.age)")
                    }
                    
                    ProgressView(value: Float(person.intelligence), total:100.0) {
                        
                    }
                    .foregroundColor(.blue)
                    .accentColor(.orange)
                    
                    HStack {
                        ForEach(0..<person.skills.count) { idx in
                            GameImages.imageForSkill(skill: person.skills[idx].skill)
                                .resizable()
                                .aspectRatio(contentMode:.fit)
                                .frame(width:22, height:22)
                        }
                    }
                    
                }
                Spacer(minLength: 50)
            }// .padding(.leading, /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
            
            Divider()
            
            HStack {
                if person.isBusy() == false {
                    Text("⏱").font(.title)
                    Text(person.busynessSubtitle())
                        .foregroundColor(.blue)
                    
                    Button(action: {
                        print("Button action")
                        self.person.addActivity()
                    }) {
                        Text("Work")
                    }
                    
                    Button("Workout") {
                        print("Working out ??")
                        self.workoutAction()
                    }
                    
                }else{
                    Text("⏱").font(.title)
                    Text(person.busynessSubtitle())
                        .foregroundColor(.red)
                }
            }.padding(.leading, /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
            
            VStack {
                
                Text("Skills")
                HStack {
                    FixedLevelBar(min: 0, max: 100, current: Double(person.intelligence), title: "Intel", color: .blue)
                    FixedLevelBar(min: 0, max: 100, current: Double(person.happiness), title: "Adaptation", color: .blue)
                }
                .padding()
                
                Divider()
                
                Text("Conditions")
                Text("Life Expectancy: \(person.lifeExpectancy)")
                
                HStack {
                    FixedLevelBar(min: 0, max: 100, current: Double(person.happiness), title: "Happiness", color: .green)
                    FixedLevelBar(min: 0, max: 100, current: Double(person.healthPhysical), title: "Physical", color: .green)
                }
                .padding()
                
                
//                FixedLevelBar(min: 0, max: 100, current: Double(person.healthInfection), title: "Infection", color: .red)
            }
        }
    }
}


// MARK: - Previews

//struct LivingControl_Previews: PreviewProvider {
//    static var previews: some View {
//        LivingControl(selected: Skills.Biologic)
//    }
//}

struct PersonRow_Preview: PreviewProvider {
    static var previews: some View {
        PersonRow(person: makePerson())
    }
    /// Makes a person with more than 1 skill
    static func makePerson() -> Person {
        let p = Person(random: true)
        p.skills.append(.init(skill: .Biologic, level: 1))
        p.skills.append(.init(skill: .Medic, level: 2))
        return p
    }
}

struct PersonSmall_Preview: PreviewProvider {
    static var previews: some View {
        PersonSmallView(person: makePerson())
    }
    /// Makes a person with more than 1 skill
    static func makePerson() -> Person {
        let p = Person(random: true)
        p.skills.append(.init(skill: .Biologic, level: 1))
        p.skills.append(.init(skill: .Medic, level: 2))
        return p
    }
}

struct PersonDetail_Preview: PreviewProvider {
    static var previews: some View {
        let busyPerson = Person(random: true)
        busyPerson.activity = LabActivity(time: 12, name: "Test Busy")
        
        return PersonDetail(person: busyPerson, workoutAction: { print("Fake Workout")})
    }
}
