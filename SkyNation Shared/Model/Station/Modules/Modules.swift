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

enum ModuleIndex:String, Codable, CaseIterable {
    
    case mod0, mod1, mod2, mod3, mod4, mod5, mod6, modGarage
    
    func position() -> Vector3D {
        switch self {
        case .mod0: return Vector3D(x: 0, y: -2, z: 0)
        case .mod1: return Vector3D(x: 0, y: 0, z: 2)
        case .mod2: return Vector3D(x: 0, y: 0, z: -10)
        case .mod3: return Vector3D(x: 0, y: 0, z: -22)
        case .mod4: return Vector3D(x: 0, y: 0, z: -34)
        case .mod5: return Vector3D(x: 0, y: 0, z: -46)
        case .mod6: return Vector3D(x: 0, y: -2, z: -32)
        case .modGarage: return Vector3D(x: 0, y: 0, z: -46)
        }
    }
    
    func orientation() -> Orientation3D {
        switch self {
        case .mod0: return .Down
        default: return .Front
        }
    }
}

class Module:Codable {
    
    var id:UUID                 // *** REFERENCE TO  BuildItem.id
    var moduleDex:ModuleIndex   // index of module
    var type:ModuleType         // .Bio, .Hab, .Lab...
    
    var name:String             // any name given
    
    // TODO: - Add Skin
    var skin:String
    
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
        self.skin = "ModuleColor"
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
