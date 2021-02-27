//
//  Generators.swift
//  SkyNation
//
//  Created by Carlos Farini on 2/27/21.
//

import Foundation

/// To load automatically the People offered and more Freebies - Well Encoded
class GameGenerators:Codable {
    
    // People
    var datePeople:Date
    var people:[Person]
    var spentOnPeople:Int = 0 // Spent tokens on people (how many)
    
    // Freebies
    var dateFreebies:Date
    var boxes:[StorageBox]
    var tokens:[UUID]
    var tanks:[Tank]
    var money:Int
    var spentOnFreebies:Int = 1 // Spent tokens on people (how many)
    
    init() {
        // Generate
        
        // People
        var ppl:[Person] = []
        for _ in 0...15 {
            let newPerson = Person(random: true)
            ppl.append(newPerson)
        }
        self.people = ppl
        self.datePeople = Date()
        
        // Freebies
        dateFreebies = Date()
        var ingredients:[StorageBox] = []
        var newTokens:[UUID] = []
        var newTanks:[Tank] = []
        var newMoney:Int = 0
        
        if Bool.random() { newMoney += 100 }
        
        if Bool.random() {
            // 50 %
            if Bool.random() && Bool.random() {
                // 12 %
                if Bool.random() { newMoney += 500 }
                if Bool.random() && Bool.random() {
                    // 3 % TOKENS
                    let newToken = UUID()
                    newTokens.append(newToken)
                    if Bool.random() { newTokens.append(UUID()) }
                } else {
                    let newIngredient = Ingredient.allCases.randomElement()!
                    var shouldBeEmpty:Bool = false
                    if newIngredient == .wasteLiquid || newIngredient == .wasteSolid {
                        shouldBeEmpty = true
                    }
                    let newBox = StorageBox(ingType: newIngredient, current: shouldBeEmpty ? 0:newIngredient.boxCapacity())
                    ingredients.append(newBox)
                    if Bool.random() {
                        let otherBox = StorageBox(ingType: newIngredient, current: shouldBeEmpty ? 0:newIngredient.boxCapacity())
                        ingredients.append(otherBox)
                    }
                }
                
            } else {
                // Tanks
                let ttype = TankType.allCases.randomElement()!
                let tankEmpty:Bool = [TankType.co2].contains(ttype)
                let newTank = Tank(type: ttype, full: !tankEmpty)
                newTanks.append(newTank)
                
                if Bool.random() {
                    let t2 = Tank(type: ttype, full: !tankEmpty)
                    newTanks.append(t2)
                } else {
                    if Bool.random() { newMoney += 100 }
                }
            }
        } else {
            // 50 %
            newMoney += 1000
        }
        
        self.money = newMoney
        self.boxes = ingredients
        self.tokens = newTokens
        self.tanks = newTanks
        
    }
    
    /// Updates to generate data
    func update() {
        if canGenerateFreebies() {
            // Generate Freebies
            generateFreebies()
            self.spentOnFreebies = 1
            self.spentOnPeople = 1
        }
        if canGenerateNewPeople() {
            // Generate PPL
            generatePeople()
        }
    }
    
    /// Removes the person from the available array
    func didHirePerson(person:Person) {
        people.removeAll(where: {$0.id == person.id})
    }
    
    /// Force updates with Tokens
    func spentTokenToUpdate(amt:Int) {
        generatePeople()
        generateFreebies()
        
        spentOnPeople += amt
        spentOnFreebies += amt
    }
    
    func canGenerateNewPeople() -> Bool {
        return datePeople.addingTimeInterval(60 * 60 * 1).compare(Date()) == .orderedAscending // 1hr
    }
    
    func canGenerateFreebies() -> Bool {
        return dateFreebies.addingTimeInterval(60 * 60 * 24).compare(Date()) == .orderedAscending // 24hr
    }
    
    private func generatePeople() {
        
        // People
        var ppl:[Person] = []
        for _ in 0...15 {
            let newPerson = Person(random: true)
            ppl.append(newPerson)
        }
        self.people = ppl
        self.datePeople = Date()
    }
    
    private func generateFreebies() {
        // Freebies
        dateFreebies = Date()
        var ingredients:[StorageBox] = []
        var newTokens:[UUID] = []
        var newTanks:[Tank] = []
        var newMoney:Int = 0
        
        if Bool.random() { newMoney += 100 }
        
        if Bool.random() {
            // 50 %
            if Bool.random() && Bool.random() {
                // 12 %
                if Bool.random() { newMoney += 500 }
                if Bool.random() && Bool.random() {
                    // 3 % TOKENS
                    let newToken = UUID()
                    newTokens.append(newToken)
                    if Bool.random() { newTokens.append(UUID()) }
                } else {
                    let newIngredient = Ingredient.allCases.randomElement()!
                    var shouldBeEmpty:Bool = false
                    if newIngredient == .wasteLiquid || newIngredient == .wasteSolid {
                        shouldBeEmpty = true
                    }
                    let newBox = StorageBox(ingType: newIngredient, current: shouldBeEmpty ? 0:newIngredient.boxCapacity())
                    ingredients.append(newBox)
                    if Bool.random() {
                        let otherBox = StorageBox(ingType: newIngredient, current: shouldBeEmpty ? 0:newIngredient.boxCapacity())
                        ingredients.append(otherBox)
                    }
                }
                
            } else {
                // 38 %
                // Tanks
                let ttype = TankType.allCases.randomElement()!
                let tankEmpty:Bool = [TankType.co2].contains(ttype)
                let newTank = Tank(type: ttype, full: !tankEmpty)
                newTanks.append(newTank)
                
                if Bool.random() {
                    let t2 = Tank(type: ttype, full: !tankEmpty)
                    newTanks.append(t2)
                } else {
                    if Bool.random() { newMoney += 100 }
                }
            }
        } else {
            // 50 %
            newMoney += 1000
        }
        
        self.money = newMoney
        self.boxes = ingredients
        self.tokens = newTokens
        self.tanks = newTanks
    }
    
}
