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
    var xp:Int? = 0
}

/// An activity associated with an event (i.e. Making Tech, or Recipe)
class LabActivity:Codable, Identifiable {
    
    var id:UUID
    var dateStarted:Date
    var dateEnds:Date
    
    // Recipe, or Tech name
    var activityName:String
    
    var labID:UUID?
    
    init(time:TimeInterval, name:String = "") {
        self.id = UUID()
        let dateNow = Date()
        self.dateStarted = dateNow
        self.dateEnds = dateNow.addingTimeInterval(time)
        self.activityName = name
    }
    
    func activityType() -> PersonActivityType? {
        if let _ = Skills(rawValue: activityName) {
            return .Study
        } else if let _ = TechItems(rawValue: activityName){
            return .LabWork
        } else if let _ = Recipe(rawValue: activityName){
            return .LabWork
        } else if activityName == "Workout" {
            return .Workout
        }
        return nil
    }
}

enum PersonActivityType:String {
    case Study      // Person is studying
    case Workout    // Working out
    case Medicated  // Medicated (Cool off)
    case Medicating // Medicating
    case LabWork    // Tech, or Recipes
}

/// An inhabitant of the `Station`
class Person:Codable, Identifiable, Equatable {
    
    var id:UUID = UUID()
    var name:String
    var gender:String
    var avatar:String
    var age:Int
    
    var intelligence:Int
    var healthPhysical:Int
    
    // + happiness
    var happiness:Int = 50
    var teamWork:Int = 50
    
    // + fix attempts
    var fixAttempts:Int = 0
    
    // + life expectancy
    var lifeExpectancy:Int = 75
    
    // + food eaten recently?
    var foodEaten:[String] = []
    
    var skills:[SkillSet]
    
    var activity:LabActivity?
    
    // MARK: - Lab Activity
    
    /// Checks if this Person is performing an Activity
    func isBusy() -> Bool {
        if let _ = activity { return activity!.dateEnds.compare(Date()) == .orderedDescending }
        else {
            return false
        }
    }
    
    /// Returns a String equivalent to the task being performed
    func busynessSubtitle() -> String {
        
        if isBusy() == true {
            let dead = activity!.dateEnds.timeIntervalSince(Date())
            return "\(activity?.activityName ?? "Busy") \(Int(dead)) s"
        }else{
            return "Idle"
        }
    }
    
    func clearActivity() {
        
        guard let activity = activity else { return }
        
        if Date().compare(activity.dateEnds) == .orderedDescending {
            
            // Finished Activity
            if activity.activityName == "Workout" {
                
                // Workout
                GameMessageBoard.shared.newAchievement(type: .experience, money:Int.random(in: 2...10), message: "\(name) finished a workout 💪")
                self.healthPhysical = min(100, healthPhysical + 3)
                
                /// Randomly get happy
                if Bool.random() {
                    let happyGain = Int.random(in:1...3)
                    let happy = min(100, happiness + happyGain)
                    self.happiness = happy
                }
                
                self.activity = nil
                
            } else if activity.activityName == "Medicating" {
                
                // Doctor Medicating
                GameMessageBoard.shared.newAchievement(type: .experience, money: 50, message: "\(name) cured someone!")
                self.activity = nil
                
            } else if activity.activityName == "Healing" {
                
                // Patient being medicated
                self.healthPhysical = min(100, healthPhysical + 10)
                self.activity = nil
                
            } else if let education = Skills(rawValue: activity.activityName) {
                
                // Learning Skill
                print("\(name) learned a new skill!")
                GameMessageBoard.shared.newAchievement(type: .learning(skill: education), money:1000, message: "\(name) learned a new skill!")
                
                self.learnNewSkill(type: education)
                self.activity = nil
                
            } else if let tech = TechItems(rawValue: activity.activityName) {
                
                // Tech
                print("\(name) finished Tech \(tech)")
                self.activity = nil
                
            } else if let recipe = Recipe(rawValue: activity.activityName) {
                
                // Recipe
                print("\(name) finished Recipe \(recipe)")
                self.activity = nil
            }
            
            self.activity = nil
        } else {
            print("⚠️ \(self.name) - Activity not finished. Cannot clear.")
        }
    }
    
    // MARK: - Accounting
    
    /// Sets a random mood
    /// [DEPRECATE]
    /*
    func randomMood(tech:[TechItems]) {
        
        var happyDeltas:[Int] = [-1, 0, 1]
        if tech.contains(.Cuppola) {
            happyDeltas.append(2)
        }
        if tech.contains(.Airlock) {
            happyDeltas.append(1)
        }
        
        // Happiness
        
        // Busy -> More unhappy
        if isBusy() == true {
            happyDeltas.append(-2)
            happyDeltas.append(-2)
        }
        
        // Random Mood
        if Bool.random() {
            if Bool.random() { happyDeltas.append(1) }
            if Bool.random() { happyDeltas.append(-1) }
        }
        
        var newHappy = min(100, happiness + happyDeltas.randomElement()!)
        if newHappy < 0 { newHappy = 0 }
        happiness = newHappy
        
        if happiness <= 50 {
            // Less life expectancy
            if Bool.random() && Bool.random() { lifeExpectancy -= 1 }
            
        }else if happiness >= 78 && healthPhysical > 95 && lifeExpectancy < 100 {
            // More life expectancy
            if Bool.random() && Bool.random() { lifeExpectancy += 1 }
        }
        
        if age > lifeExpectancy {
            print("This Person is about to die !")
            healthPhysical = max(0, healthPhysical - 10)
        }
        
    }
    
    /// For **ACCOUNTING** only! [DEPRECATE]
    func consumeAir(airComp:AirComposition) -> AirComposition {
        
        let air = airComp
        
        switch air.airQuality() {
            case .Great:
                if Bool.random() { happiness = min(100, happiness + 1) }
            case .Good:
                if Bool.random() {
                    happiness = min(happiness + 1, 100)
                } else {
                    happiness = max(happiness - 1, 0)
                }
            case .Medium:
                if Bool.random() { happiness -= 1 }
            case .Bad:
                let dHealth = max(0, healthPhysical - 3)
                healthPhysical = dHealth
                let dHappy = max(0, happiness - 2)
                happiness = dHappy
            case .Lethal:
                let dHealth = max(0, healthPhysical - 6)
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
    
    /// For **ACCOUNTING** only! [DEPRECATE]
    func consumedFood(_ new:String, bio:Bool = false) {
        
        var happyDelta:Int = 0
        
        // No food
        if new.isEmpty {
            self.healthPhysical = max(0, healthPhysical - 4)
            self.happiness = max(0, happiness - 2)
            return
        }
        
        if bio == true && Bool.random() == true { happyDelta += 1 }
        
        if let last = foodEaten.last {
            if new == last {
                // Eating same food as last
                happyDelta += [-2, -1, 0].randomElement()!
            } else {
                
                if foodEaten.contains(new) {
                    // Different food (lvl 1)
                    happyDelta += [-1, 0, 1].randomElement()!
                } else {
                    // Different food (lvl 2)
                    happyDelta += [0, 1, 2].randomElement()!
                }
            }
        }
        
        var newHappy = happiness + happyDelta
        if newHappy < 0 { newHappy = 0 } else if newHappy > 100 { newHappy = 100 }
        happiness = newHappy
        
        if healthPhysical < 30 {
            healthPhysical += 1
        }
        
        // Refresh array of eaten foods
        if foodEaten.count > 5 {
            self.foodEaten = [new]
        } else {
            self.foodEaten.append(new)
        }
    }
    
    /// Performs changes in health and happiness according to water consumption [DEPRECATE]
    func consumedWater(success:Bool) {
        if success {
            // Help the sick
            if healthPhysical < 45 {
                healthPhysical += 3
            }
        } else {
            // No success. Hit health
            if healthPhysical > 2 {
                healthPhysical -= 2
            }
            // hit happy
            if happiness > 50 {
                happiness -= 5
            }
        }
    }
    
    /// DEPRECATE
    func consumedEnergy(success:Bool) {
        if !success {
            if happiness > 20 {
                happiness -= 2
            }
        }
    }
    */
    
    // MARK: - Skills
    
    func sumOfSkills() -> Int {
        var counter:Int = 0
        for skset in skills {
            counter += skset.level
        }
        return counter
    }
    
    /// Returns chances (0...1) of Studying
    func willingnessToStudy() -> Double {
        
        // A Tenth of their age (Max Study Levels)
        var tenth = Int((Double(age) / 10.0).rounded()) - 1
        
        // Increase the tenth if intelligent
        // if intelligence > 80 { tenth += 1 }
        // else if intelligence > 60 && Bool.random() { tenth += 1 }
        
        // Increase the tenth if happy
        if happiness > 90 { tenth += 1 }
        // else if happiness > 50 && Bool.random() { tenth += 1 }
        
        // Decrease the tenth when health is bad
        if healthPhysical < 50 {
            // tenth -= 1
            return 0
        }
        
        let sksum = sumOfSkills()
        let balance = sksum - tenth
        if balance > 1 { return 0.0 }
        else if balance == 1 { return 0.25 }
        else if balance == 0 { return 0.5 }
        else if balance == -1 { return 0.75 }
        else if balance < -1 { return 1.0 }
        return 0.5
    }
    
    func attemptStudy() -> Skills? {
        
        if isBusy() == true {
            print("busy")
            return nil
        } else {
            if healthPhysical < 50 {
                return nil
            }
        }
        
        let maxSkills:Int = Int((Double(age) / 10.0).rounded()) - 1
        let curSkills:Int = sumOfSkills()
        let learnable:[Skills] = [.Biologic, .Datacomm, .Medic, .Electric, .Material]
        let learned:[Skills] = self.skills.compactMap({ $0.skill }).filter({ $0 != .Medic && $0 != .Handy })
        
        if curSkills < maxSkills {
            if curSkills > 2 {
                // repeat a skill
                if let l1 = learned.shuffled().first {
                    return l1
                } else {
                    return learnable.shuffled().first!
                }
            } else {
                return learnable.shuffled().first!
            }
        } else {
            return nil
        }
    }
    
    /// Learn new Skill (Called when clearActivity() is being called) - after the study is complete
    func learnNewSkill(type:Skills) {
        
        var newSkill:SkillSet?
        if let idx = skills.firstIndex(where: { $0.skill == type }) {
            newSkill = SkillSet(skill: type, level: skills[idx].level + 1)
            skills.remove(at: idx)
        } else {
            newSkill = SkillSet(skill: type, level: 1)
        }
        if let newSkill = newSkill {
            skills.append(newSkill)
        }
    }
    
    func levelFor(skill:Skills) -> Int {
        return self.skills.filter({ $0.skill == skill }).first?.level ?? 0
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
            
            var avSkills:[Skills] = [Skills.Mechanic, Skills.Electric, Skills.Material]
            if Bool.random() {
                avSkills.append(contentsOf:[.Datacomm, .Biologic])
                if Bool.random() {
                    avSkills.append(contentsOf:[.Medic, .SystemOS])
                }
            }
            
            let randSkill:Skills = avSkills.randomElement()!
            
            let skset = SkillSet(skill: randSkill, level: 1)
            self.skills.append(skset)
        } else {
            if Bool.random() == true {
                let handy = SkillSet(skill: .Handy, level: 1)
                self.skills.append(handy)
            }
        }
        
        self.name = newName
        self.gender = newGenderString
        self.avatar = newAvatar!
        self.age = newAge
        self.intelligence = newInteligence
        
        self.healthPhysical = 100
        
        // After init
        
        // More age, more intelligence
        if self.age > 30 {
            if Bool.random() == true {
                let rndSk1:Skills = Skills.allCases.randomElement()!
                var newSkill:SkillSet?
                if let idx = skills.firstIndex(where: { $0.skill == rndSk1 }) {
                    newSkill = SkillSet(skill: rndSk1, level: skills[idx].level + 1)
                    skills.remove(at: idx)
                } else {
                    newSkill = SkillSet(skill: rndSk1, level: 1)
                }
                if let newSkill = newSkill {
                    skills.append(newSkill)
                }
            }
        }
        
        // Happiness
        self.happiness = generator.randomHappiness()
        
        // Team / Adapt
        self.teamWork = generator.randomTeamWorkAdaptability()
    }
    
    static func == (lhs: Person, rhs: Person) -> Bool {
        return lhs.id == rhs.id
    }
}

class HumanGenerator:NSObject{
    
    func generateNameGenderPair() -> NameGenderPair {
        let allNameGenderPairs:[NameGenderPair] = [
            
            // Smaller
            NameGenderPair(name: "Kevin Burke", gender: .male),
            NameGenderPair(name: "Charly Ward", gender: .female),
            NameGenderPair(name: "Darren Soto", gender: .male),
            NameGenderPair(name: "Sadie Lopez", gender: .female),
            NameGenderPair(name: "Levi Rogers", gender: .male),
            
            // Little Bigger
            NameGenderPair(name: "Timothy Lyons", gender: .male),
            NameGenderPair(name: "Charlie Walsh", gender: .female),
            NameGenderPair(name: "Misty Swanson", gender: .female),
            NameGenderPair(name: "Giovanni Piza", gender: .male),
            NameGenderPair(name: "Yuri Levawski", gender: .male),
            NameGenderPair(name: "Janis Ramirez", gender: .female),
            
            // Below are all equal width.
            // Divide in
            /*
             Americans
             Russians
             Germans
             Italians
             Spanish
             Other
             */
            
            NameGenderPair(name: "Maura Pizani", gender: .female),
            NameGenderPair(name: "Jeff Johnson", gender: .male),
            NameGenderPair(name: "Carly Hikken", gender: .male),
            NameGenderPair(name: "Albert Fritz", gender: .male),
            NameGenderPair(name: "Candice Bril", gender: .female),
            NameGenderPair(name: "Bianca Green", gender: .female),
            NameGenderPair(name: "Gina Caprici", gender: .female),
            NameGenderPair(name: "Owen Walters", gender: .male),
            NameGenderPair(name: "Mark Sapporo", gender: .male),
            NameGenderPair(name: "Carl Collier", gender: .male),
            
            NameGenderPair(name: "Jena Thomson", gender: .female),
            NameGenderPair(name: "Roge Shimura", gender: .male),
            NameGenderPair(name: "Miranda Nile", gender: .female),
            NameGenderPair(name: "Elfie Shultz", gender: .female),
            NameGenderPair(name: "Dima Vasiliv", gender: .male),
            NameGenderPair(name: "Gene Rossini", gender: .male),
            NameGenderPair(name: "John Ferrari", gender: .male),
            NameGenderPair(name: "Angel Ballak", gender: .male),
            NameGenderPair(name: "David Mazzol", gender: .male),
            NameGenderPair(name: "Ricky Shultz", gender: .male),
            
            NameGenderPair(name: "Mark Trapuya", gender: .male),
            NameGenderPair(name: "Anna Johnson", gender: .female),
            NameGenderPair(name: "Julia Carson", gender: .female),
            NameGenderPair(name: "Sakura Saito", gender: .female),
            NameGenderPair(name: "Jeny Muligan", gender: .female),
            NameGenderPair(name: "Guta Ramirez", gender: .female),
            NameGenderPair(name: "Masha Ivanov", gender: .female),
            NameGenderPair(name: "Lauren Gucci", gender: .female),
            
            NameGenderPair(name: "Mary Morales", gender: .female),
            NameGenderPair(name: "Natty Carson", gender: .female),
            NameGenderPair(name: "Angel Wagner", gender: .male),
            NameGenderPair(name: "Amber Croser", gender: .female),
            NameGenderPair(name: "Rene Goodwin", gender: .female),
            NameGenderPair(name: "Shanon Cross", gender: .female),
            NameGenderPair(name: "Trevor Baker", gender: .male),
            
            NameGenderPair(name: "Nettie Miles", gender: .male),
            NameGenderPair(name: "Suzane Brady", gender: .female),
            NameGenderPair(name: "Noel Baldwin", gender: .male),
            NameGenderPair(name: "Renee Chavez", gender: .female),
            NameGenderPair(name: "Boyd Collier", gender: .male),
            NameGenderPair(name: "Rachel Wells", gender: .female),
            NameGenderPair(name: "William Park", gender: .male),
            
            NameGenderPair(name: "Tiffany Love", gender: .female),
            NameGenderPair(name: "Anita Norman", gender: .female),
            NameGenderPair(name: "Salvador Lee", gender: .male),
            NameGenderPair(name: "Cassy Howard", gender: .female),
            NameGenderPair(name: "Ramiro Nunez", gender: .male),
            NameGenderPair(name: "Edwin Greene", gender: .male),
            NameGenderPair(name: "Judith Parks", gender: .female),
            
        ]
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
        let lower = 21
        let upper = 40
        return lower + Int(arc4random_uniform(UInt32(upper - lower + 1)))
    }
    
    // Happiness
    func randomHappiness() -> Int {
        let lower = 45
        let upper = 95
        return lower + Int(arc4random_uniform(UInt32(upper - lower + 1)))
    }
    
    // Teamwork
    func randomTeamWorkAdaptability() -> Int {
        let lower = 35
        let upper = 99
        return lower + Int(arc4random_uniform(UInt32(upper - lower + 1)))
    }
    
    // Intelligence
    func randomStartingIntelligence() -> Int{
        let lower = 35
        let upper = 99
        return lower + Int(arc4random_uniform(UInt32(upper - lower + 1)))
    }
}


