//
//  PersonViews.swift
//  SkyTestSceneKit
//
//  Created by Farini on 9/22/20.
//  Copyright © 2020 Farini. All rights reserved.
//

import SwiftUI

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


/*
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
*/

/**
 The old Person Detail.
 This works in the SpaceStation
 */
struct PersonDetail:View {
    
    @ObservedObject var controller:HabModuleController
    var person:Person
    
    @State var fireAlert:Bool = false
    
    @State private var warning:String?
    
    var body: some View {
        
        VStack(alignment: .leading) {
            
            HStack {
                Spacer()
                Text("Profile")
                    .font(.title)
                Spacer()
            }
            .padding([.top], 8)
            
            // Picture, name and Skills (Top)
            HStack {
                
                Image(person.avatar)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 64, height: 64)
                    .padding(.leading, 6)
                
                VStack(alignment: .leading, spacing: 4) {
                    
                    HStack {
                        Text(person.name).font(.headline)
                        Text("Age:")
                        Text("\(person.age)")
                    }
                    
                    // Intelligence
                    ProgressView(value: Float(person.intelligence), total:100.0) {}
                    .foregroundColor(.blue)
                    .accentColor(.orange)
                    
                    // Skills
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
                .padding(.top, 8)
                
                HStack {
                    Spacer()
                    if let activity = person.activity {
                        PersonActivityView(activity: activity)
                    } else {
                        Text("⏱").font(.title)
                            .padding([.leading], 6)
                        Text(person.busynessSubtitle())
                            .foregroundColor(person.isBusy() ? .red:.gray)
                    }
                    Spacer()
                }
                
                if let activity = person.activity, person.isBusy() {
                    HStack {
                        Spacer()
                        Button("Boost (-1 Token/hr)") {
                            let player = LocalDatabase.shared.player
                            if let token = player.requestToken() {
                                let result = player.spendToken(token: token, save: true)
                                if result == true {
                                    let theDate = activity.dateEnds.addingTimeInterval(-3600)
                                    activity.dateEnds = theDate
                                    person.clearActivity()
                                    controller.save()
                                    controller.didSelect(person: person)
                                }
                            }
                        }
                        .buttonStyle(NeumorphicButtonStyle(bgColor: .white))
                        Spacer()
                    }
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
                
                Text("Work Skills").font(.title2).foregroundColor(.blue)
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
                                if let dna = DNAOption(rawValue: rawFood) {
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
            
            // Warnings
            if let warning = warning {
                Text(warning).foregroundColor(.red)
                    .transition(.slide)
            }
            
            // Buttons
            HStack {
                Spacer()
                Button("Study") {
                    
                    if let subject:Skills = person.attemptStudy() {
                        controller.study(person: person, subject: subject)
                    } else {
                        self.warning = "\(person.name) can't study right now."
                    }
                    
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
        .frame(minHeight: 700, idealHeight: 800, maxHeight: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
    }
}


/**
 Person Detail View that works without any controller. It passes back the action.
 */
struct PersonDetailView:View {
    
    var person:Person
    
    /// Callback function
    var action:((PersonActionCall) -> ()) = {_ in }
    
    @State private var fireAlert:Bool = false
    
    var body: some View {
        
        VStack(alignment: .leading) {
            
            HStack {
                Spacer()
                Text("Profile")
                    .font(.title)
                Spacer()
            }
            .padding([.top], 8)
            
            // Picture, name and Skills (Top)
            HStack {
                
                Image(person.avatar)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 64, height: 64)
                    .padding(.leading, 6)
                
                VStack(alignment: .leading, spacing: 4) {
                    
                    HStack {
                        Text(person.name).font(.headline)
                        Text("Age:")
                        Text("\(person.age)")
                    }
                    
                    // Intelligence
                    ProgressView(value: Float(person.intelligence), total:100.0) {}
                    .foregroundColor(.blue)
                    .accentColor(.orange)
                    
                    // Skills
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
                .padding(.top, 8)
                
                HStack {
                    Spacer()
                    Text("⏱").font(.title)
                        .padding([.leading], 6)
                    Text(person.busynessSubtitle())
                        .foregroundColor(person.isBusy() ? .red:.gray)
                    Spacer()
                }
                
                if let activity = person.activity, person.isBusy() {
                    HStack {
                        Spacer()
                        Button("Boost (-1 Token/hr)") {
                            let player = LocalDatabase.shared.player
                            if let token = player.requestToken() {
                                let result = player.spendToken(token: token, save: true)
                                if result == true {
                                    let theDate = activity.dateEnds.addingTimeInterval(-3600)
                                    activity.dateEnds = theDate
                                    if !person.isBusy() {
                                        person.activity = nil
                                    }
                                    //                                    controller.save()
                                    //                                    controller.didSelect(person: person)
                                }
                            }
                            
                        }
                        .buttonStyle(NeumorphicButtonStyle(bgColor: .white))
                        Spacer()
                    }
                }
                
                //                ForEach(controller.issues, id:\.self) { issue in
                //                    Text(issue)
                //                        .foregroundColor(.red)
                //                }
                //                ForEach(controller.messages, id:\.self) { message in
                //                    Text(message)
                //                }
            }
            
            Divider()
            
            // Work Skills
            VStack {
                
                Text("Work Skills").font(.title2).foregroundColor(.blue)
                
                // Skill Table
                HStack(spacing:10) {
                    ForEach(person.skills, id:\.skill) { skillSet in
                        HStack {
                            GameImages.imageForSkill(skill: skillSet.skill)
                                .resizable()
                                .aspectRatio(contentMode:.fit)
                                .frame(width:22, height:22)
                            Text("x\(skillSet.level)")
                        }
                        Divider().frame(height:10)
                    }
                }
                
                // Intel + Adaptation
                HStack(spacing:12) {
                    FixedLevelBar(min: 0, max: 100, current: Double(person.intelligence), title: "Intel", color: .blue)
                        .frame(minWidth: 100, idealWidth: 120, maxWidth: 150, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                    Divider()
                    FixedLevelBar(min: 0, max: 100, current: Double(person.happiness), title: "Adaptation", color: .blue)
                        .frame(minWidth: 100, idealWidth: 120, maxWidth: 150, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                }
                .padding(.bottom, 4)
                
                Divider()
                
                Text("Living Conditions").font(.title2).foregroundColor(.green)
                
                HStack(spacing:12) {
                    
                    ProgressView("Life Expectancy: \(person.lifeExpectancy)", value: Float(person.age), total: Float(person.lifeExpectancy))
                        .frame(minWidth: 100, idealWidth: 120, maxWidth: 150, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                        .padding(.top, 4)
                    
                    Divider()
                    
                    VStack(alignment:.leading) {
                        Text("Recently eaten")
                        HStack {
                            ForEach(person.foodEaten, id:\.self) { rawFood in
                                if let dna = DNAOption(rawValue: rawFood) {
                                    Text(dna.emoji)
                                }
                            }
                            if person.foodEaten.isEmpty {
                                Text("🤢 Empty tummy").foregroundColor(.gray)
                            }
                        }
                    }
                    .frame(minWidth: 100, idealWidth: 120, maxWidth: 150, alignment: .leading)
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
            
            // Buttons
            HStack {
                Spacer()
                Button("Study") {
                    print("\(person.name) Try Studying...")
                    
                    let pskills = person.skills.filter({ $0.skill != .Handy && $0.skill != .Medic }).compactMap({ $0.skill })
                    let randSkill = Skills.allCases.filter({ $0 != .Handy }).randomElement()!
                    
                    var chosenSubject:Skills = randSkill
                    
                    if pskills.count > 2 {
                        chosenSubject = pskills.randomElement()!
                    } else {
                        if Bool.random() == true {
                            // RepeatSkill
                            if let first = pskills.shuffled().first, first != .Handy, first != .Medic {
                                chosenSubject = first
                            }
                        }
                    }
                    
                    self.action(.study(skill: chosenSubject))
                }
                .disabled(person.isBusy())
                .buttonStyle(NeumorphicButtonStyle(bgColor: .orange))
                
                Button("Workout") {
                    print("Working out ??")
                    //                    controller.workout(person: person)
                    self.action(.workout)
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
                        //                        controller.fire(person: person)
                    }))
                })
                
                Button("Medicate") {
                    print("Needs a doctor for medication.")
                    //                    controller.medicate(person: person)
                    self.action(.medicate)
                }
                .disabled(person.isBusy())
                .buttonStyle(NeumorphicButtonStyle(bgColor: .orange))
                
                Spacer()
            }.padding()
        }
        .frame(minHeight: 550, idealHeight: 600, maxHeight: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
    }
}


// MARK: - Previews

//struct PersonRow_Preview: PreviewProvider {
//    static var previews: some View {
//        PersonRow(person: makePerson())
//    }
//    /// Makes a person with more than 1 skill
//    static func makePerson() -> Person {
//        let p = Person(random: true)
//        p.skills.append(.init(skill: .Biologic, level: 1))
//        p.skills.append(.init(skill: .Medic, level: 2))
//        return p
//    }
//}


//struct PersonDetail_Preview: PreviewProvider {
//
//    static var previews: some View {
//        let busyPerson = Person(random: true)
//
//        // Uncomment the following for busy state
//        //        busyPerson.activity = LabActivity(time: 12, name: "Test Busy")
//        if let habModule = LocalDatabase.shared.station.habModules.first {
//            let controller = HabModuleController(hab: habModule)
//            controller.selectedPerson = habModule.inhabitants.first
//            return PersonDetail(controller: controller, person:controller.selectedPerson!)
//        } else {
//            let habMod = HabModule.example
//            let controller = HabModuleController(hab: habMod)
//            controller.selectedPerson = busyPerson
//            return PersonDetail(controller: controller, person: controller.selectedPerson!)
//        }
//    }
//}

struct PersonDetail2_Preview: PreviewProvider {
    
    static var previews: some View {
        PersonDetailView(person: Person(random: true))
        PersonDetailView(person: makePerson())
    }
    
    static func makePerson() -> Person {
        let p = Person(random: true)
        p.skills.append(.init(skill: .Biologic, level: 1))
        p.skills.append(.init(skill: .Medic, level: 2))
        return p
    }
}
