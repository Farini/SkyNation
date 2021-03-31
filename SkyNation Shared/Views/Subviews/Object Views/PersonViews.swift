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
    
    
    
    @ObservedObject var controller:HabModuleController
    var person:Person
    
    @State var fireAlert:Bool = false
    
    
    
    var body: some View {
        
        VStack(alignment: .leading) {
            
            HStack {
                Spacer()
                Text("Profile")
                    .font(.title)
                Spacer()
            }
            .padding([.top], 8)
            
            // Picture, name and Skills
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
                        ForEach(person.skills, id:\.skill) { skillSet in
                            GameImages.imageForSkill(skill: skillSet.skill)
                                .resizable()
                                .aspectRatio(contentMode:.fit)
                                .frame(width:22, height:22)
                        }
                    }
                }
                .frame(minWidth: 200, idealWidth: 200, maxWidth: 200, idealHeight: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, maxHeight: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                
                Spacer()
            }
            
            Divider()
            
            // Activity
            Group {
                HStack {
                    Spacer()
                    Text("Activity").font(.title2)
                    Spacer()
                }
                .padding( 8)
                
                HStack {
                    Spacer()
                    Text("⏱").font(.title)
                        .padding([.leading], 6)
                    Text(person.busynessSubtitle())
                        .foregroundColor(person.isBusy() ? .red:.gray)
                    Spacer()
                }
                
                
                
                ForEach(controller.issues, id:\.self) { issue in
                    Text(issue)
                        .foregroundColor(.red)
                }
                ForEach(controller.messages, id:\.self) { message in
                    Text(message)
                }
            }
            
            Divider()
            
            // Work Skills
            VStack {
                
                Text("Work Skills").font(.title2)
                HStack(spacing:12) {
                    FixedLevelBar(min: 0, max: 100, current: Double(person.intelligence), title: "Intel", color: .blue)
                        .frame(minWidth: 100, idealWidth: 120, maxWidth: 150, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                    Divider()
                    FixedLevelBar(min: 0, max: 100, current: Double(person.happiness), title: "Adaptation", color: .blue)
                        .frame(minWidth: 100, idealWidth: 120, maxWidth: 150, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                }
                .padding(.bottom, 4)
                
                Divider()
                
                Text("Conditions").font(.title2).foregroundColor(.green)
                
                HStack(spacing:12) {
                    ProgressView("Life Expectancy: \(person.lifeExpectancy)", value: Float(person.age), total: Float(person.lifeExpectancy))
                        .frame(minWidth: 100, idealWidth: 120, maxWidth: 150, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                        .padding(.top, 4)
                    Divider()
                    VStack(alignment:.leading) {
                        Text("Recently eaten")
                        HStack {
                            ForEach(person.foodEaten, id:\.self) { rawFood in
                                if let dna = PerfectDNAOption(rawValue: rawFood) {
                                    Text(dna.emoji)
                                }
                            }
                        }
                        .padding(.top, 2)
                    }
                    
                }

                
                
                HStack(spacing:12) {
                    FixedLevelBar(min: 0, max: 100, current: Double(person.happiness), title: "Happiness", color: .green)
                        .frame(minWidth: 100, idealWidth: 120, maxWidth: 150, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                    Divider()
                    FixedLevelBar(min: 0, max: 100, current: Double(person.healthPhysical), title: "Physical", color: .green)
                        .frame(minWidth: 100, idealWidth: 120, maxWidth: 150, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                }
                .padding(.bottom, 12)
            }
            Divider()
            HStack {
                Spacer()
                Button("Study") {
                    print("\(person.name) Try Studying...")
                    
                    let randomSubject = Skills.allCases.randomElement() ?? Skills.Handy
                    controller.study(person: person, subject: randomSubject)
                }
                .disabled(person.isBusy())
                .buttonStyle(NeumorphicButtonStyle(bgColor: .orange))
                
                Button("Workout") {
                    print("Working out ??")
                    controller.workout(person: person)
                }
                .disabled(person.isBusy())
                .buttonStyle(NeumorphicButtonStyle(bgColor: .orange))
                
                Button("Fire") {
                    print("Fire Person")
                    fireAlert.toggle()
                }
                .disabled(person.isBusy())
                .buttonStyle(NeumorphicButtonStyle(bgColor: .orange))
                .alert(isPresented: $fireAlert, content: {
                    Alert(title: Text("Fire"), message: Text("Are you sure you want to fire \(person.name)"),
                          primaryButton: .cancel(),
                          secondaryButton: .destructive(Text("Yes"), action: {
                            print("Person fired. Needs to delete them.")
                            controller.fire(person: person)
                          }))
                })
                
                Button("Medicate") {
                    print("Needs a doctor for medication.")
                    controller.medicate(person: person)
                }
                .disabled(person.isBusy())
                .buttonStyle(NeumorphicButtonStyle(bgColor: .orange))
                
                Spacer()
            }.padding()
        }
        .frame(minHeight: 550, idealHeight: 600, maxHeight: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
    }
}

struct PersonOrderView:View {
    
    var person:Person
    
    var body: some View {
        ZStack(alignment: Alignment(horizontal: .trailing, vertical: .top)) {
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
            Text("$\(GameLogic.orderPersonPrice)")
                // .frame(maxWidth:40)
                .foregroundColor(.gray)
                .padding(4)
                .background(Color.black)
        }
        
        .padding(2)
        .background(Color.black)
        .cornerRadius(8)
        .frame(maxWidth:200)
    }
}


// MARK: - Previews

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
    
    struct PersonOrder_Preview: PreviewProvider {
        static var previews: some View {
            PersonOrderView(person: Person(random: true))
        }
    }

struct PersonDetail_Preview: PreviewProvider {
    
    static var previews: some View {
        let busyPerson = Person(random: true)
        
        // Uncomment the following for busy state
//        busyPerson.activity = LabActivity(time: 12, name: "Test Busy")
        if let habModule = LocalDatabase.shared.station?.habModules.first {
            let controller = HabModuleController(hab: habModule)
            controller.selectedPerson = habModule.inhabitants.first
            return PersonDetail(controller: controller, person:controller.selectedPerson!)
        } else {
            let habMod = HabModule.example
            let controller = HabModuleController(hab: habMod)
            controller.selectedPerson = busyPerson
            return PersonDetail(controller: controller, person: controller.selectedPerson!)
        }
        
        
    }
}
