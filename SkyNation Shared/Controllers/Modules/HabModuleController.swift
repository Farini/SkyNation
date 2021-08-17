//
//  HabModuleController.swift
//  SkyNation
//
//  Created by Carlos Farini on 1/26/21.
//

import Foundation

enum HabModuleViewState {
    case noSelection
    case selected(person:Person)
}

class HabModuleController: ObservableObject {
    
    var station:Station
    
    @Published var habModule:HabModule
    @Published var selectedPerson:Person?
    @Published var inhabitants:[Person]
    @Published var viewState:HabModuleViewState = .noSelection
    
    /// Anything wrong
    @Published var issues:[String]
    
    /// Actions
    @Published var messages:[String]
    
    init(hab:HabModule) {
        guard let station = LocalDatabase.shared.station else { fatalError() }
        self.station = station
        self.habModule = hab
        self.inhabitants = hab.inhabitants
        self.issues = []
        self.messages = []
        
        // Notification Observer
        NotificationCenter.default.addObserver(self, selector: #selector(changeModuleNotification(_:)), name: .changeModule, object: nil)
    }
    
    func didSelect(person:Person) {
        self.selectedPerson = person
        if person != selectedPerson {
            self.issues = []
            self.messages = []
        }
        self.viewState = .selected(person: person)
        self.updateUI()
    }
    
    func clearSelection() {
        self.issues = []
        self.messages = []
        self.selectedPerson = nil
        self.viewState = .noSelection
    }
    
    private var updates:Int = 0
    private func updateUI() {
        
        guard let person = selectedPerson, let activity = person.activity, person.isBusy() == true else { return }
   
        switch viewState {
            case .noSelection: return
            default:
                person.clearActivity()
                if person.activity == nil { return }
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) { [weak self] in
            
            if self?.selectedPerson != person {
                print("Changed person")
                return
            }
            
            if self != nil {
                
                // Count Updates
                var newUpdates = self?.updates ?? 0
                newUpdates += 1
                
                self?.updates = newUpdates
                print("Updating person for \(newUpdates) time. Activity: \(activity.activityName)")
                
                
                self?.didSelect(person: person)
            }
        }
    }
    
    // MARK: - Person Actions
    
    func study(person:Person, subject:Skills) {
        
        guard let selected = selectedPerson, selected == person else { fatalError() }
        
        // Charge a fee for studying
        // if pass the chances, do it!
        let willingness = selected.willingnessToStudy()
        print("Willingness: \(willingness)")
        let result = GameLogic.chances(hit: willingness, total: 1.0)
        print("Will Study? \(result)")
        if result == true {
            // Add activity to Person
            let studyActivity = LabActivity(time: GameLogic.personStudyTime, name: subject.rawValue)
            selected.activity = studyActivity
            messages.append("Studying \(subject.rawValue)")
            save()
        } else {
            issues.append("\(person.name) doesn't want to study")
        }
    }
    
    func workout(person:Person) {
        guard let selected = selectedPerson, selected == person else { fatalError() }
        let workoutActivity = LabActivity(time: 60, name: "Workout")
        selected.activity = workoutActivity
        print("Person working out")
        if person.healthPhysical < 80 {
            person.healthPhysical += 2
            if Bool.random() { person.healthPhysical += 1 }
        } else if person.healthPhysical > 95 {
            person.happiness += 1
        }
        
        // Needs to save
        save()
        didSelect(person: person)
    }
    
    func fire(person:Person) {
        
        guard let selected = selectedPerson, selected == person else {
            self.issues.append("Error: Bad selection")
            return
        }
        guard let idx = habModule.inhabitants.firstIndex(of: person) else {
            self.issues.append("Error: Person doesn't belong here")
            return
        }
        
        habModule.inhabitants.remove(at: idx)
        self.inhabitants = habModule.inhabitants
        
        // Update UI
        clearSelection()
        
        // Needs to save
        save()
    }
    
    func medicate(person:Person) {
        
        // Person Selected
        guard let selected = selectedPerson, selected == person else { fatalError() }
        
        // Check if there is medication
        var medicine:[DNAOption] = []
        for food in station.food {
            if let dna = DNAOption(rawValue: food) {
                if dna.isMedication == true {
                    medicine.append(dna)
                }
            }
        }
        
        if medicine.count < 5 {
            issues.append("Not enough medicine.")
            return
        } else {
            // Remove Medicine from Station (foods)
            for med in medicine {
                if let firstIndex = station.food.firstIndex(of: med.rawValue) {
                    station.food.remove(at: firstIndex)
                }
            }
        }
        
        // Medic
        if let medic = station.getPeople().filter({$0.skills.contains(where: { $0.skill == .Medic }) && $0.isBusy() == false }).first {
            
            // Add activity to medic
            medic.activity = LabActivity(time: 600, name: "Medicating")
            
            // Add activity to Person
            person.activity = LabActivity(time: 600, name: "Healing")
            
            messages.append("Medication in progress")
            
            didSelect(person: person)
            
        } else {
            // No Medic
            issues.append("No medics were found.")
        }
    }
    
    // Module
    @objc func changeModuleNotification(_ notification:Notification) {
        
        guard let object = notification.object as? [String:Any] else {
            print("no object passed in this notification")
            return
        }
        
        print("Change Module Notification. Object:\n\(object.description)")
        
        if let moduleID = object["id"] as? UUID {
            if moduleID == habModule.id {
                
                // id checked
                if let name = object["name"] as? String {
                    self.habModule.name = name
                    station.habModules.first(where: { $0.id == moduleID })!.name = name
                } else
                if let skin = object["skin"] as? String {
                    // Skin
                    if let modSkin = ModuleSkin(rawValue: skin) {
                        print("Change skin to: \(modSkin.displayName)")
                        self.habModule.skin = modSkin
                        let rawModule = station.lookupRawModule(id: self.habModule.id)
                        rawModule.skin = modSkin// .rawValue
                        station.habModules.first(where: { $0.id == moduleID })!.skin = modSkin
                    }
                } else
                if let unbuild = object["unbuild"] as? Bool, unbuild == true {
                    
                    // Unbuild Module.
                    print("Danger! Wants to unbuild module")
                    let idx = station.habModules.firstIndex(where: { $0.id == moduleID })!
                    station.habModules.remove(at: idx)
                    
                    save()
                    
                    // Close the view
                    let closeNotification = Notification(name: .closeView)
                    NotificationCenter.default.post(closeNotification)
                    return
                }
            }
        } else {
            print("Error: ID doesnt check")
            return
        }
        
        self.clearSelection()
        save()
    }
    
    // MARK: - Saving Game
    
    func save() {
        LocalDatabase.shared.saveStation(station: station)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
