//  Person.swift
//  SKN3: Created by Farini on 4/12/18.
//  Copyright © 2018 Farini. All rights reserved.

import CloudKit

/// Skills a person may have
enum Skills:String, Codable, CaseIterable, Hashable {
    case Mechanic
    case Electric
    case Datacomm
    case Material
    case SystemOS
    
    case Biologic
    case Medic
    
    case Handy
    
    func short() -> String {
        switch self {
        case .Mechanic: return "⚙️ Mechanic"
        case .Electric: return "⚡️ Electric"
        case .Datacomm: return "📡 Sensorial"
        case .Material: return "🛡 Material"
        case .SystemOS: return "🖥 Systems"
        case .Biologic: return "☣ Bio"
        case .Medic: return "✚ Medic"
        case .Handy: return "✋ handy"
        }
    }
}

/// A Combination of Skills and Levels
struct SkillSet:Codable {
    var skill:Skills
    var level:Int
}

/// An activity associated with an event (i.e. Making Tech, or Recipe)
class LabActivity:Codable, Identifiable {
    
    var id:UUID
    var dateStarted:Date
    var dateEnds:Date
    
    // Recipe, or Tech name
    var activityName:String
    
//    var workers:[Person]?
    var labID:UUID?
    
    init(time:TimeInterval, name:String = "") {
        self.id = UUID()
        self.dateStarted = Date()
        self.dateEnds = Date().addingTimeInterval(time)
        self.activityName = name
    }
    
    /// Prepares an output for this event (Adds to Station)
    func getOutput(station:Station) {
        
        // output can be...
        
        // 1 - Recipe unlock (Recipe.rawValue)
        if let recipe = Recipe(rawValue: activityName) {
            station.unlockedRecipes.append(recipe)
        }
        
        // 2 - Tech unlock
//        if let techItem = TechItems(rawValue: activityName) {
//            // let mid = LocalDatabase.shared.builder.
//        }
        
        // 3 - BuildItem
        
        // Save
    }
}

/// An inhabitant of the `Station`
class Person:Codable, Identifiable, Equatable {
    
    static func == (lhs: Person, rhs: Person) -> Bool {
        return lhs.id == rhs.id
    }
    
    var id:UUID = UUID()
    var name:String
    var gender:String
    var avatar:String
    var age:Int
    
    var intelligence:Int
    
    var healthPhysical:Int
    var healthInfection:Int
    
    // New (2020)
    // + happiness
    var happiness:Int = 50
    // + teamwork
    var teamWork:Int = 50
    // + fix attempts
    var fixAttempts:Int = 0
    // + life expectancy
    var lifeExpectancy:Int = 75
    // + food eaten recently?
    var foodEaten:[String] = []
    
    var skills:[SkillSet]
    
    var activity:LabActivity?
    
    // MARK: - Busy Status
    
    /// Checks if this Person is performing an Activity
    func isBusy() -> Bool {
        if let _ = activity { return activity!.dateEnds.compare(Date()) == .orderedDescending }
        else {
            return false
        }
    }
    
    func busynessSubtitle() -> String {
        if isBusy() == true {
            let dead = activity!.dateEnds.timeIntervalSince(Date())
            return "Busy for \(Int(dead)) seconds"
        }else{
            return "Idle"
        }
    }
    
    func addActivity() {
        self.activity = LabActivity(time: 60)
    }
    
    /// Sets a random mood
    func randomMood() {
        
        // Happiness
        if isBusy() == true {
            if Bool.random() == false {
                happiness -= 1
                if Bool.random() == false {
                    happiness -= 1
                }
            }
        } else {
            if Bool.random() == true { happiness += 1 }
        }
        
        let mood = Bool.random()
        if mood == true {
            happiness += 1
        }else{
            happiness -= 1
        }
        if happiness <= 50 {
            lifeExpectancy -= 1
            if happiness <= 30 {
                healthPhysical -= 1
            }
        }else if happiness >= 72 && healthPhysical > 95 {
            lifeExpectancy += 1
        }
        
        let lifeDelta = lifeExpectancy - age
        if lifeDelta > age {
            happiness += 1
        }else{
            happiness += Bool.random() == true ? 1:-1
            // Health is more random
            healthPhysical += Bool.random() == true ? 2:-2
        }
    }
    
    /// For **ACCOUNTING** only!
    func consumeAir(airComp:AirComposition) -> AirComposition {
        
        let air = airComp
        
        switch air.airQuality() {
            case .Great:
                if Bool.random() { happiness += 1 }
            case .Good:
                print("air was good. boring")
            case .Medium:
                if Bool.random() { happiness -= 1 }
            case .Bad:
                let dHealth = max(0, healthPhysical - 3)
                healthPhysical = dHealth
                let dHappy = max(0, happiness - 2)
                happiness = dHappy
            case .Lethal:
                let dHealth = max(0, healthPhysical - 8)
                healthPhysical = dHealth
        }
        
        // Oxygen
        if air.o2 >= 2 {
            air.o2 -= 2
        }

        air.co2 += 1    // co2
        air.h2o += 1    // Generate Water Vapor
        
        return air
    }
    
    // MARK: - Creating a person
    
    init(random:Bool) {
        
        let generator = HumanGenerator()
        let pair = generator.generateNameGenderPair()
        let newName = pair.name                                         // Name
        let newGenderString = pair.gender.rawValue

        var newAvatar:String?
        
        if pair.gender == .female{
            newAvatar = generator.female_avatar_names.randomElement()!
        }else if pair.gender == .male{
            newAvatar = generator.male_avatar_names.randomElement()!
        }
        
        let newAge = generator.randomStartingAge()                      // Age
        let newInteligence = generator.randomStartingIntelligence()     // Intelligence
        
        // Skills
        self.skills = []
        if Bool.random() == true && Bool.random() == true {
            let randSkill:Skills = Skills.allCases.randomElement()!
            let skset = SkillSet(skill: randSkill, level: 1)
            self.skills.append(skset)
        }
        
        self.name = newName
        self.gender = newGenderString
        self.avatar = newAvatar!
        self.age = newAge
        self.intelligence = newInteligence
        
        self.healthPhysical = 100
        self.healthInfection = 0
        
        // After init
        
        // More age, more intelligence
        if self.age > 30 {
            if Bool.random() == true {
                let rndSk1:Skills = Skills.allCases.randomElement()!
                self.skills.append(SkillSet(skill: rndSk1, level: 1))
            }
        }
        
        // Happiness
        self.happiness = generator.randomHappiness()
        
        // Team / Adapt
        self.teamWork = generator.randomTeamWorkAdaptability()
    }
}

class PersonGenerator {
    
    static var shared = PersonGenerator()
    
    var generated:[Person]
    var dateGenerated:Date
    
    private init() {
        
        var generation:[Person] = []
        for idx in 0...12 {
            let newPerson = Person(random:true)
            generation.append(newPerson)
            print("Person \(idx): \(newPerson.name) generated.")
        }
        self.generated = generation
        self.dateGenerated = Date()
    }
    
    // Every hour, generate 12 new people?
    func requestPeople(_ amount:Int) -> [Person] {
        let timee = Date().timeIntervalSince(dateGenerated)
        if timee > 3600 {
            // Generate new
            let newArray:[Person] = generateNew()
            generated = newArray
        }
        guard amount > 0 else { return [] }
        
        var generation:[Person] = []
        for idx in 1...amount {
            print("Person # \(idx): requested.")
            if !generated.isEmpty {
                let newPerson = generated.last!
                generation.append(newPerson)
                generated.removeLast()
            } else {
                print("Generating New Person (not from array)")
                let newPerson = Person(random: true)
                generation.append(newPerson)
            }
            
        }
        return generation
    }
    
    private func generateNew() -> [Person] {
        var generation:[Person] = []
        for idx in 0...12 {
            let newPerson = Person(random:true)
            generation.append(newPerson)
            print("Person \(idx): \(newPerson.name) generated.")
        }
        self.generated = generation
        self.dateGenerated = Date()
        return generation
    }
}

class HumanGenerator:NSObject{
    
    func generateNameGenderPair() -> NameGenderPair {
        let allNameGenderPairs:[NameGenderPair] = [NameGenderPair(name: "Darren Soto", gender: .male),
                                                   NameGenderPair(name: "Tiffany Love", gender: .female),
                                                   NameGenderPair(name: "Anita Norman", gender: .female),
                                                   NameGenderPair(name: "Salvador Lee", gender: .male),
                                                   NameGenderPair(name: "Charlene Ward", gender: .female),
                                                   NameGenderPair(name: "Cassy Howard", gender: .female),
                                                   NameGenderPair(name: "Ramiro Nunez", gender: .male),
                                                   NameGenderPair(name: "Kevin Burke", gender: .male),
                                                   NameGenderPair(name: "Edwin Greene", gender: .male),
                                                   NameGenderPair(name: "Judith Parks", gender: .female),
                                                   NameGenderPair(name: "Nettie Miles", gender: .male),
                                                   NameGenderPair(name: "Janis Ramirez", gender: .female),
                                                   NameGenderPair(name: "Suzanne Brady", gender: .female),
                                                   NameGenderPair(name: "Noel Baldwin", gender: .male),
                                                   NameGenderPair(name: "Renee Chavez", gender: .female),
                                                   NameGenderPair(name: "Sadie Lopez", gender: .female),
                                                   NameGenderPair(name: "Boyd Collier", gender: .male),
                                                   NameGenderPair(name: "Levi Rogers", gender: .male),
                                                   NameGenderPair(name: "Rachael Wells", gender: .female),
                                                   NameGenderPair(name: "William Parks", gender: .male),
                                                   NameGenderPair(name: "Timothy Lyons", gender: .male),
                                                   NameGenderPair(name: "Charlie Walsh", gender: .female),
                                                   NameGenderPair(name: "Misty Swanson", gender: .female),
                                                   NameGenderPair(name: "Mable Morales", gender: .female),
                                                   NameGenderPair(name: "Nadine Carson", gender: .female),
                                                   NameGenderPair(name: "Angelo Wagner", gender: .male),
                                                   NameGenderPair(name: "Amber Cross", gender: .female),
                                                   NameGenderPair(name: "Rene Goodwin", gender: .female),
                                                   NameGenderPair(name: "Shannon Cross", gender: .female),
                                                   NameGenderPair(name: "Trevor Baker", gender: .male),
                                                   NameGenderPair(name: "Giovanni Piza", gender: .male),
                                                   NameGenderPair(name: "Yuri Bobov", gender: .male),
                                                   NameGenderPair(name: "Marcus Trapuya", gender: .male),
                                                   NameGenderPair(name: "Anna Johnson", gender: .female),
                                                   NameGenderPair(name: "Julia Carson", gender: .female),
                                                   NameGenderPair(name: "Sakura Saito", gender: .female)]
        return allNameGenderPairs.randomElement()!
    }
    
    enum Gender:String{
        case male;
        case female;
    }
    struct NameGenderPair{
        var name:String
        var gender:Gender
    }
    
    // Names For Avatars
    var male_avatar_names:[String]{
        return ["people_02", "people_04", "people_05", "people_07", "people_09", "people_10", "people_13", "people_14", "people_15", "people_16"]
    }
    
    var female_avatar_names:[String]{
        return ["people_01", "people_03", "people_06", "people_08", "people_11", "people_12"]
    }
    
    // Age
    func randomStartingAge() -> Int{
        let lower = 18
        let upper = 40
        return lower + Int(arc4random_uniform(UInt32(upper - lower + 1)))
    }
    
    // + happiness
    func randomHappiness() -> Int {
        let lower = 35
        let upper = 80
        return lower + Int(arc4random_uniform(UInt32(upper - lower + 1)))
    }
    
    func randomTeamWorkAdaptability() -> Int {
        let lower = 25
        let upper = 95
        return lower + Int(arc4random_uniform(UInt32(upper - lower + 1)))
    }
    
//    // + teamwork
//    var teamWork:Int = 50
//    // + fix attempts
//    var fixAttempts:Int = 0
//    // + life expectancy
//    var lifeExpectancy:Int = 75
//    // + food eaten recently?
//    var foodEaten:[String] = []
    
    // Intelligence
    func randomStartingIntelligence() -> Int{
        let lower = 25
        let upper = 99
        return lower + Int(arc4random_uniform(UInt32(upper - lower + 1)))
    }
}
