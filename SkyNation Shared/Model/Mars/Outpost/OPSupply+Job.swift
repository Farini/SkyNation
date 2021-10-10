//
//  OPSupply+Job.swift
//  SkyNation
//
//  Created by Carlos Farini on 8/8/21.
//

import Foundation

/// Its calculated. Doesn't need to be `Codable` type
struct OutpostJob {
    // Ingredients
    var wantedIngredients:[Ingredient:Int]
    // Skills
    var wantedSkills:[Skills:Int]
    // Tanks
    var wantedTanks:[TankType:Int]?
    // Peripherals
    var wantedPeripherals:[PeripheralType:Int]?
    // Bioboxes
    var wantedBio:[DNAOption:Int]?
    
    /// Sum of all resources needed
    func maxScore() -> Int {
        let ing = wantedIngredients.values.reduce(0, +)
        let ski = wantedSkills.values.reduce(0, +)
        let tan = wantedTanks?.values.reduce(0, +) ?? 0
        let per = wantedPeripherals?.values.reduce(0, +) ?? 0
        let bio = wantedBio?.values.reduce(0, +) ?? 0
        
        return ing + ski + tan + per + bio
    }
}

/// The stuff being supplied to the outpost Job. Notice there are different objects
class OutpostSupply:Codable {
    
    var ingredients:[StorageBox]
    var tanks:[Tank]
    var skills:[Person]
    var peripherals:[PeripheralObject]
    var bioBoxes:[BioBox]
    
    /// Contribution PlayerID vs amount
    var players:[UUID:Int] // Player ID + Supplied points
    
    // MARK: - Initializers
    
    init() {
        self.ingredients = []
        self.tanks = []
        self.skills = []
        self.peripherals = []
        self.bioBoxes = []
        self.players = [:]
    }
    
    /// For Production use -> No players, no skills(People) are produced
    init(ingredients:[StorageBox], tanks: [Tank], peripherals: [PeripheralObject], bioBoxes: [BioBox]) {
        self.ingredients = ingredients
        self.tanks = tanks
        self.peripherals = peripherals
        self.bioBoxes = bioBoxes
        
        self.skills = []
        self.players = [:]
    }
    
    /// Initialize this object by merging two `OutpostSupply` objects.
    init(merging old:OutpostSupply, with new:OutpostSupply) {
        
        let allIngredients:[StorageBox] = old.ingredients + new.ingredients
        let allTanks:[Tank] = old.tanks + new.tanks
        let allPeople:[Person] = old.skills + new.skills
        let allPeripherals:[PeripheralObject] = old.peripherals + new.peripherals
        let allBio:[BioBox] = old.bioBoxes + new.bioBoxes
        
        var allPlayers = old.players
        let contPlayerID = new.players.first?.key ?? UUID()
        let contPlayerVal = new.players.first?.value ?? 0
        
        // Players vs Contrib.
        allPlayers[contPlayerID, default:0] += contPlayerVal
        self.players = allPlayers
        
        self.ingredients = allIngredients
        self.tanks = allTanks
        self.skills = allPeople
        self.peripherals = allPeripherals
        self.bioBoxes = allBio
        
    }
    
    // MARK: - Contributions
    /*
    func contribute(with box:StorageBox, player:SKNPlayer) {
        ingredients.append(box)
        guard let pid = player.serverID else { return }
        var pScore:Int = players[pid, default:0]
        pScore += 1
        players[pid] = pScore
    }
    
    func contribute(with person:Person, player:SKNPlayer) {
        skills.append(person)
        guard let pid = player.serverID else { return }
        var pScore:Int = players[pid, default:0]
        pScore += 1
        players[pid] = pScore
        
        // FIXME: - Make person busy and Save City (with person)
    }
    
    func mergeWith(supply:OutpostSupply) {
        self.ingredients.append(contentsOf: supply.ingredients)
        self.tanks.append(contentsOf: supply.tanks)
        self.skills.append(contentsOf: supply.skills)
        self.peripherals.append(contentsOf: supply.peripherals)
        self.bioBoxes.append(contentsOf: supply.bioBoxes)
    }
    */
    
    /// Returns the count of all resources
    func supplyScore() -> Int {
        let ing = ingredients.map({ $0.current }).reduce(0, +)
        let tnk = tanks.map({ $0.current }).reduce(0, +)
        let skls = skills.flatMap({ $0.skills })
        let sumskills = skls.map({ $0.level }).reduce(0, +)
        let per = peripherals.count
        let bio = bioBoxes.map({ $0.population.count }).reduce(0, +)
        
        return ing + tnk + sumskills + per + bio
        // ingredients.count + tanks.count + skills.count + peripherals.count + bioBoxes.count
    }
    
    /// Clears all materials contributed
    func clearContents() {
        self.ingredients = []
        self.tanks = []
        self.skills = []
        self.peripherals = []
        self.bioBoxes = []
    }
    
    /// Clears the contributors list
    func clearContributors() {
        self.players = [:]
    }
}


