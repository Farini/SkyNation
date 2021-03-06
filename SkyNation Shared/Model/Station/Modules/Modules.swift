//
//  Modules.swift
//  SkyTestSceneKit
//
//  Created by Farini on 8/29/20.
//  Copyright © 2020 Farini. All rights reserved.
//

import Foundation

// MAP OF ISS
// --------------------
//        *
//   /|   |/
// -*-*-*-*-<
// /|    /
//  *
//

//        *
//   /    |/
// -*-*-*-*-<
// /| |  /
//  *
// ====================

/// The Type of the module (Lab, Hab, Bio)
enum ModuleType:String, Codable, CaseIterable {
    
    case Lab    // blue
    case Hab    // green
    case Bio    // red

    case Unbuilt
    
    func objective() -> String {
        switch self {
            case .Lab: return "Build things, grow your tech tree and accomplish missions."
            case .Hab: return "Shelters more habitants in your station"
            case .Bio: return "Grow plants. Improve air quality, and produce food."
            case .Unbuilt: return "An unbuilt module doesn't really do anything."
        }
    }
}

class Module:Codable {
    
    var id:UUID                 // *** REFERENCE TO  BuildItem.id
    var moduleDex:ModuleIndex   // index of module
    var type:ModuleType         // .Bio, .Hab, .Lab...
    
    var name:String             // any name given
    
    var skin:ModuleSkin //String
    
    private enum CodingKeys:String, CodingKey {
        case id
        case moduleDex
        case name
        case type
        case skin
    }
    
    init(id:UUID, modex:ModuleIndex) {
        self.id = id
        self.name = "Untitled"
        self.type = .Unbuilt
        self.moduleDex = modex
        self.skin = [ModuleSkin.ModuleBake, ModuleSkin.diffuse1].randomElement()! //"ModuleColor"
    }
    
    func convertToLab() -> LabModule {
        return LabModule(module: self)
    }
    
    func convertToHab() -> HabModule {
        return HabModule(module: self)
    }
    
    func convertToBio() -> BioModule {
        return BioModule(module: self)
    }
    
}
