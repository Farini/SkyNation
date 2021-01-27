//
//  PersonControl.swift
//  SkyTestSceneKit
//
//  Created by Farini on 8/30/20.
//  Copyright © 2020 Farini. All rights reserved.
//

import SwiftUI

struct PersonControl: View {
    
    var people:[Person]
    @State var selectedPerson:Person?
    
    init() {
        var people:[Person] = []
        for _ in 1...7 {
            let p = Person(random: true)
            people.append(p)
        }
        self.people = people
        self.selectedPerson = people.first!
    }
    
    var body: some View {
        HStack {
            List(people) { person in
                PersonRow(person: person)
                    .onTapGesture {
                        self.selectedPerson = person
                }
            }
            VStack {
                if selectedPerson != nil {
//                    PersonDetail(person: selectedPerson!, workoutAction: workoutAction)
                    Text("PersonDetail")
                }else{
                    Text("Select one")
                }
            }
        }
    }
    
    func workoutAction() {
        guard let person = selectedPerson else {
            return
        }
        let workoutActivity = LabActivity(time: 60, name: "Working out")
        person.activity = workoutActivity
        print("Person working out")
    }
}

struct PersonSelectorView: View {
    
    var person:Person
    var selected:Bool
    
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
        .background(self.selected ? Color.black.opacity(0.75):Color.orange.opacity(0.75))
        .cornerRadius(8)
        .padding([.top, .bottom])
    }
}

struct StaffSelectionView:View {
    
    @ObservedObject var controller:LabViewModel
    
    var people:[Person]
    @State var selection:[Person] = []
    
    var body: some View {
        HStack {
            ForEach(people) { person in
                PersonSelectorView(person: person, selected: controller.selectedStaff.contains(person) ? false:true)
                    .onTapGesture {
                        controller.togglePersonSelection(person: person)
                    }
            }
        }
    }
}

struct ActivityPersonCell:View {
    
    var person:Person
    var selected:Bool
    
    var body: some View {
        HStack {
            Text(person.isBusy() ? "🚫":selected ? "●":"○")
                .padding([.leading], 6)
            
            Image(person.avatar)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 56, height: 56)
//                .padding([.leading], -6)
                .foregroundColor(person.isBusy() ? .blue:.orange)
            
            VStack(alignment: .leading, spacing: 2) {
                
                HStack {
                    Text(person.name)
                        .font(.headline)
                        .foregroundColor(person.isBusy() ? .red:.white)
                    Text("(\(person.age))")
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
        .background(self.selected ? Color.orange.opacity(0.75):Color.black.opacity(0.75))
        .cornerRadius(8)
        .padding([.top, .bottom], 4)
    }
}

/** A `View` to pick Staff `Person` and select them for an activity. */
struct ActivityStaffView:View {
    
    @State var staff:[Person]
    @State var selected:[Person] = []
    var requiredSkills:[Skills:Int]?
    
    var body: some View {
        
        LazyVGrid(columns: [GridItem(.fixed(200)), GridItem(.fixed(200)), GridItem(.fixed(200))], alignment: .center, spacing: 4, pinnedViews: [], content: {
            Section(header:
                        self.preHeader
                        .padding([.leading], 6)
            ) {
                ForEach(staff) { person in
                    ActivityPersonCell(person: person, selected: selected.contains(person))
                }
            }
            
        })
        .frame(maxWidth: 900, maxHeight: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
        .background(LinearGradient(gradient: .init(colors: [.init(white: 0.15), .init(white: 0.1)]), startPoint: .topLeading, endPoint: .bottomTrailing))
    }
    
    var preHeader: some View {
        
        var theImages:[Image] = []
        if let reqSkills = requiredSkills {
            //            let kk = Array(reqSkills.keys.enumerated())
            for (key, _) in reqSkills {
                theImages.append(GameImages.imageForSkill(skill: key))
                //                theString.append(key.rawValue)
            }
        }
        
        return HStack {
            if requiredSkills == nil || requiredSkills?.isEmpty == true {
                Text("People")
            } else {
                Text("Skills: ")
                ForEach(0..<theImages.count) { idx in
                    theImages[idx]
                        .resizable()
                        .aspectRatio(contentMode:.fit)
                        .frame(width:22, height:22)
                }
            }
            Spacer()
        }
        
        
    }
}

struct StaffSelection_Previews: PreviewProvider {
    
    static let p1 = Person(random: true)
//    let p2 = Person(random: true)
//    let p3 = Person(random: true)
    
    static let people = LocalDatabase.shared.station?.getPeople() ?? []
    static let lab = LocalDatabase.shared.station?.labModules.first
    
    static var previews: some View {
        
        PersonSelectorView(person: p1, selected: false)
        
    }
}

struct PersonControl_Previews: PreviewProvider {
    static var previews: some View {
        PersonControl()
    }
}

struct ActivityStaff_Previews: PreviewProvider {
    
    static var previews: some View {
        ActivityStaffView(staff: randomizePeople(), requiredSkills: [Skills.Biologic:3, Skills.Medic:4])
        
    }
    
    static func randomizePeople() -> [Person] {
        let qtty = 8
        var people:[Person] = []
        for _ in 0..<qtty {
            let newPerson = Person(random: true)
            if Bool.random() {
                let activity = LabActivity(time: 50, name: "Tester")
                newPerson.activity = activity
            }
            people.append(newPerson)
        }
        return people
    }
}
