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

// MARK: - New People Picker

struct ActivityPersonCell:View {
    
    var person:Person
    var selected:Bool
    
    var body: some View {
        
        HStack {
            
            // Avatar
            ZStack(alignment: .leading) {
                Image(person.avatar)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 56, height: 56)
                    .foregroundColor(person.isBusy() ? .blue:.orange)
            }
            
            // Name, Skills, Intelligence
            VStack(alignment: .leading, spacing: 2) {
                
                HStack {
                    Text(person.name)
                        .font(.subheadline)
                        .foregroundColor(person.isBusy() ? .red:.white)
                    Spacer()
                }
                
                ProgressView(value: Float(person.intelligence), total:100.0) {
                    if person.skills.isEmpty {
                        Text("No skills").foregroundColor(.gray)
                    }
                    HStack {
                        ForEach(0..<person.skills.count) { idx in
                            GameImages.imageForSkill(skill: person.skills[idx].skill)
                                .resizable()
                                .aspectRatio(contentMode:.fill)
                                .frame(width:22, height:22)
                        }
                    }
                }
                .foregroundColor(.blue)
                .accentColor(.orange)
                
            }
            .padding([.trailing], 4)
            
            // Selection Detail
            Text(person.isBusy() ? "-":selected ? "●":"○")
                .foregroundColor(selected ? .green:.gray)
                .offset(x:-6, y:-20)
            
        }
        .frame(width: 185, height: 60, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
        .background(self.selected ? Color.green.opacity(0.25):Color.black.opacity(0.1))
        .cornerRadius(8)
        .padding([.top, .bottom], 4)
    }
}

struct ActivityParentView:View {
    
    var staff:[Person]
    @State var message:String = ""
    
    var body: some View {
        VStack {
//            Text("Activity Parent").font(.largeTitle)
//            Text("Message: \(message)")
            
            ActivityStaffView(staff: staff, requiredSkills: [Skills.Electric: 1, Skills.Mechanic:2]) { (people) in
                
                // Callback
                // Change this to controller.didSelectPeople?
                self.message = "People: \(people.count)"
            }
        }
    }
}

/** A `View` to pick Staff `Person` and select them for an activity. */
struct ActivityStaffView:View {
    
    /// The people available to pick (everyone)
    @State var staff:[Person]
    
    /// The ones that have been selected
    @State var selected:[Person] = []
    
    /// Skills required for this Activity
    var requiredSkills:[Skills:Int]
    
    /// A Closure for this view to respond to its parent
    var chooseWithReturn:(_ people:[Person]) -> ()
    
    var title:String = "Title"
    
    @State var issue:String = ""
    @State var message:String = ""
    
    var body: some View {
        
        VStack {
            if let title = title {
                Text(title).font(.title2)
            }
            if issue.isEmpty {
                if message.isEmpty {
                    Text("Select staff")
                        .foregroundColor(.gray)
//                    CautionStripeShape()
//                        .frame(width:250, height:12)
//                        .clipped()
                }else{
                    Text(message)
                        .foregroundColor(.gray)
                }
            } else {
                Text(issue).foregroundColor(.red)
            }
            
            LazyVGrid(columns: [GridItem(.fixed(200)), GridItem(.fixed(200)), GridItem(.fixed(200))], alignment: .center, spacing: 4, pinnedViews: [], content: {
                Section(header:
                            self.preHeader
                            .padding([.leading], 6)
                ) {
                    ForEach(staff) { person in
                        ActivityPersonCell(person: person, selected: selected.contains(person))
                            .onTapGesture {
                                print("Tapped: \(person.name)")
                                if person.isBusy() {
                                    print("Cannot use busy people")
                                    issue = "\(person.name) is busy"
                                } else {
                                    self.didSelect(person: person)
                                }
                            }
                    }
                }
            })
            .frame(maxWidth: 800, alignment: .top)
            .background(LinearGradient(gradient: .init(colors: [.init(white: 0.15), .init(white: 0.1), .init(white: 0.15)]), startPoint: .topLeading, endPoint: .bottomTrailing))
        }
    }
    
    var preHeader: some View {
        
        var trios:[SkillTrio] = []
        
        for (key, value) in requiredSkills {
            let trio = SkillTrio(skill: key, level: value)
            trios.append(trio)
        }
        
        trios.sort(by: { $0.name.rawValue.compare($1.name.rawValue) == .orderedAscending })
        
        return HStack(alignment:.center, spacing:0) {
            if requiredSkills.isEmpty == true {
                Text("People")
            } else {
                Text("Skills: ")
                ForEach(trios) { sktrio in
                    sktrio.image
                        .resizable()
                        .aspectRatio(contentMode:.fit)
                        .frame(width:22, height:22)
                    Text("x \(sktrio.value)")
                        .offset(x: -1, y: 0)
                        .padding([.trailing], 3)
                }
            }
            Spacer()
            
        }
    }
    
    func didSelect(person:Person) {
        
        if selected.contains(person) {
            selected.removeAll(where: { $0.id == person.id })
        } else {
            selected.append(person)
        }
        
        var missingSkills:[Skills:Int] = [:]
        
        for (skill, level) in requiredSkills {
            var passCount:Int = level
            for person in selected {
                let pskill = person.skills.filter({ $0.skill == skill }).first?.level ?? 0
                passCount -= pskill
            }
            if passCount > 0 {
                // didn't pass
                missingSkills[skill] = passCount
            }
        }
        
        if missingSkills.isEmpty {
            print("Passed !!")
        } else {
            let skdetails = missingSkills.map({ $0.key.rawValue }).joined(separator: ", ")
            issue = "Mising \(missingSkills.map({ $0.value }).reduce(0, +)) points. \(skdetails)"
        }
        
        chooseWithReturn(selected)
        
    }
    
    /// Object that represents the skill (image) and the level
    struct SkillTrio: Identifiable {
        
        var id:UUID = UUID()
        var image:Image
        var name:Skills
        var value:Int
        init(skill:Skills, level:Int) {
            self.name = skill
            self.value = level
            self.image = GameImages.imageForSkill(skill: skill)
        }
    }
    
}

// MARK: - Previews

struct ActivityStaff_Previews: PreviewProvider {
    
    static var previews: some View {
        ActivityParentView(staff: randomizePeople())
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
