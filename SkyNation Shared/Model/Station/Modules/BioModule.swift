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
    /// Grows without any concerns for DNA quality
    case grow
    
    /// Evolving DNA
    case evolve      // Searching and evolving DNA
    
    /// DNA found. Multiplying
    case multiply
    
    /// Distributing to people?
    case serving
}

/// What plants produces as Food, or Medicine
enum DNAOption:String, Codable, CaseIterable, Hashable {
    
    case apple = "APPLE"        // 5
    case banana = "BANANA"      // 6
    case carrot = "CARROT"
    case tomato = "TOMATO"
    case orange = "ORANGE"
    
    case coconut = "COCONUT"    // 7
    case avocado = "AVOCADO"
    
    case broccoli = "BROCCOLI"  // 8
    case blueberry = "BLUEBERRY"    // 9
    case pineapple = "PINEAPPLE"    // 9
    case strawberry = "STRAWBERRY"  // 10
    case watermelon = "WATERMELON"  // 10
    
    // air
    case greenalgae = "GREENALGAE"  // 10
    
    // meds
    case addItAll = "ADD_IT@_ALL"   // 11
    case ibuprofen = "IBUPROFEN"    // 9
    case acetaminophen = "ACETAMINOPHEN"    //
    case aspirin = "ASPIRIN"
    case vitaminC = "VITAMIN_@C"
    
    // Animals
    case piggie = "PIGGIE"
    
    /// The equivalent emoji
    var emoji:String {
        switch self {
            case .apple: return "🍏"
            case .banana: return "🍌"
            case .carrot: return "🥕"
            case .tomato: return "🍅"
            case .orange: return "🍊"
            case .coconut: return "🥥"
            case .avocado: return "🥑"
            case .broccoli: return "🥦"
            case .blueberry: return "🫐"
            case .pineapple: return "🍍"
            case .strawberry: return "🍓"
            case .watermelon: return "🍉"
            case .greenalgae: return "🌾"
            case .addItAll: return "💊"
            case .ibuprofen: return "💊"
            case .acetaminophen: return "💊"
            case .aspirin: return "💊"
            case .vitaminC: return "💊"
            case .piggie: return "🐖"
        }
    }
    
    var isMedication:Bool {
        switch self {
            case .addItAll, .ibuprofen, .acetaminophen, .aspirin, .vitaminC:
                return true
            default:
                return false
        }
    }
    
    /// Animals (can only be made in mars)
    var isAnimal:Bool {
        switch self {
            case .piggie: return true
            default: return false
        }
    }
    
    /// Items that can be ordered
    var orderable:Bool {
        return !isMedication && !isAnimal
    }
    
}

class BioModule:Codable, Identifiable {
    
    static let foodLimit:Int = 100     // Limit Food Storage?
    
    var id:UUID                 // *** REFERENCE TO  BuildItem.id
    var moduleDex:ModuleIndex   // index of module
    var type:ModuleType         // .Bio, .Hab, .Lab...
    var name:String             // any name given
    var skin:ModuleSkin
    
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
        self.skin = ModuleSkin.BioModule
    }
    
    static var example:BioModule {
        let m = Module(id: UUID(), modex: .mod0)
        let bio = m.convertToBio()
        bio.boxes = [BioBox(chosen: .banana, size: 40)]
        return bio
    }
}

class BioBox:Codable, Identifiable {
    
    var id:UUID
    var dateAccount = Date()
    var mode:BioBoxMode = .grow
    
    var perfectDNA:String
    var population:[String]
    var populationLimit:Int
    
    var generations:Int = 20        // Number of loops in one round
    var currentGeneration:Int = 0
    var mutationChance:Int = 100    // Chances to mutate?
    
    init(chosen:DNAOption, size:Int) {
        self.id = UUID()
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
    
    /// Searches for the best fit in population
    func getBestFitDNA() -> String? {
        
        guard population.count > 0 else { return nil }
        
        let optimal = perfectDNA.asciiArray // The optimal Ascii array
        var bestFit:Int = Int.max // best fit is backwards. The more, the worse
        var bestFitString:String?
        
        for dna in population {
            let ascii = dna.asciiArray
            var fitness = 0
            for c in 0...ascii.count-1 {
                fitness += abs(Int(ascii[c]) - Int(optimal[c]))
            }
            if fitness < bestFit {
                bestFitString = dna
                bestFit = fitness
            }
        }
        
        return bestFitString
    }
    
    func convertToDNA() -> DNAOption {
        return DNAOption(rawValue: perfectDNA)!
    }
}

extension BioBox: Equatable {
    static func == (lhs: BioBox, rhs: BioBox) -> Bool {
        return lhs.id == rhs.id
    }
}

