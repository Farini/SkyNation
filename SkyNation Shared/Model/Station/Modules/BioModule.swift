//
//  BioModule.swift
//  SkyTestSceneKit
//
//  Created by Farini on 9/9/20.
//  Copyright © 2020 Farini. All rights reserved.
//

import Foundation

/// The uses of a `BioBox`.
enum BioBoxMode:String, Codable, CaseIterable, Hashable {
    case grow       // Grows without any concerns for DNA quality
    case bloom      // Searching and evolving DNA
    case collect    // Make food
    case store      // Store food
}

/// What plants produces as Food, or Medicine
enum PerfectDNAOption:String, Codable, CaseIterable, Hashable {
    case banana = "BANANA"
    case starch = "STARCH"
    case strawberry = "STRAWBERRY"
}

class BioModule:Codable, Identifiable {
    
    static let foodLimit:Int = 100     // Limit Food Storage?
    
    var id:UUID                 // *** REFERENCE TO  BuildItem.id
    var moduleDex:ModuleIndex   // index of module
    var type:ModuleType         // .Bio, .Hab, .Lab...
    var name:String             // any name given
    var skin:String = "ModuleColor"
    
    var plants:[String]
    var boxes:[BioBox]
    var capacity:Int            // Compartments of boxes?
    
    init(module:Module) {
        self.id = module.id
        self.moduleDex = module.moduleDex
        self.type = .Bio
        self.name = ""
        self.plants = []
        self.boxes = []
        self.capacity = 4
    }
    
    static var example:BioModule {
        let m = Module(id: UUID(), modex: .mod0)
        let bio = m.convertToBio()
        bio.boxes = [BioBox(chosen: .banana, size: 40)]
        return bio
    }
}

class BioBox:Codable, Identifiable {
    
    var id = UUID()
    var dateAccount = Date()
    var mode:BioBoxMode = .grow
    
    var perfectDNA:String
    var population:[String]
    var populationLimit:Int
    
    var generations:Int = 20        // Number of loops in one round
    var currentGeneration:Int = 0
    var mutationChance:Int = 100    // Chances to mutate?
    
    //    var dnaSize:Int // can calculate
    //    var popCount:Int // can calculate
    
    init(chosen:PerfectDNAOption, size:Int) {
        
        perfectDNA = chosen.rawValue
        
        // Initial Population
        let populi = DNAMatcherModel.populate(dnaChoice: chosen, popSize: size)
        print("-- POPULI... ")
        for p in populi {
            print(p)
        }
        print("---P---")
        population = populi
        populationLimit = size
        
        generations = 20 // Initial Generations (More if level up)
    }
}

