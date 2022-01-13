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

/// The indexes where `Module` objects can be placed
enum ModuleIndex:String, Codable, CaseIterable {
    
    // mod0 is the one facing down, mod1 is the Front
    case mod0, mod1, mod2, mod3, mod4, mod5, mod6, mod7, mod8, mod9, mod10 //, modGarage
    
    func position() -> Vector3D {
        switch self {
            case .mod0: return Vector3D(x: 0, y: -2, z: 0)
            case .mod1: return Vector3D(x: 0, y: 0, z: 2)
            case .mod2: return Vector3D(x: 0, y: 0, z: -10)
            case .mod3: return Vector3D(x: 0, y: 0, z: -22)
            case .mod4: return Vector3D(x: 0, y: 0, z: -34)
            case .mod5: return Vector3D(x: 0, y: 0, z: -46)
            case .mod6: return Vector3D(x: 0, y: -2, z: -12)
            case .mod7: return Vector3D(x: 0, y: -2, z: 0) // Doesn't exist
            case .mod8: return Vector3D(x: 0, y: -2, z: -36)
            case .mod9: return Vector3D(x: 0, y: 2, z: -36)
            case .mod10: return Vector3D(x: 0, y: -2, z: -24)
                //            case .modGarage: return Vector3D(x: 0, y: 0, z: -46)
        }
    }
    
    func orientation() -> Orientation3D {
        switch self {
            case .mod0: return .Down
            case .mod6: return .Down
            case .mod8: return .Down
            case .mod9: return .Up
            case .mod10: return .Down
                
            default: return .Front
        }
    }
}

/// The Material (image) to go on the Module.
enum ModuleSkin:String, Codable, CaseIterable {
    
    case ModuleBake
    case diffuse1
    case BioModule
    case LabModule
    case HabModule
    
    // New Cases - 01/22
    
    case BatteryMod
    case Capsule
    case Drawing
    case Panels
    case SleekCables
    
    /*
     
     
     // New Vars
     var color:String
     var ao:String?
     var normal:String?
     var roughness:String?
     var metallic:String?
     */
    
    /// The name to display from the menu
    var displayName:String {
        switch self {
            case .BioModule: return "Biology"
            case .HabModule: return "Habitation"
            case .LabModule: return "Laboratory"
            case .ModuleBake: return "Do not touch"
            case .diffuse1: return "Default"
            // new
            case .BatteryMod: return "Battery"
            case .Capsule: return "Capsule"
            case .Drawing: return "Drawing"
            case .Panels: return "Panels"
            case .SleekCables: return "Sleek"
        }
    }
    
    /*
    /// The name (path) of the UV to load
    var uvMapName:String {
        switch self {
            case .BioModule: return "BioModule"
            case .HabModule: return "HabModule"
            case .LabModule: return "LabModule"
            case .ModuleBake: return "ModuleBake4"
            case .diffuse1: return "ModuleDif1"
        }
    }
    */
    
    // MARK: - Geometry
    
    // MARK: - Textures
    
    /// The Path to get the textures for this material
    var textureFolder:URL? {
        
        guard let artFolder = Bundle.main.url(forResource: "Art", withExtension: ".scnassets") else {
            print("Art folder not found. Seious error.")
            return nil
        }
        
        switch self {
            case .ModuleBake, .diffuse1, .BioModule, .LabModule, .HabModule:
                return artFolder.appendingPathComponent("/UV Images/ModuleSkins/")
            case .BatteryMod:
                return artFolder.appendingPathComponent("/UV Images/ModuleSkins/BatteryMod/")
            case .Capsule:
                return artFolder.appendingPathComponent("/UV Images/ModuleSkins/Capsule/")
            case .Drawing:
                return artFolder.appendingPathComponent("/UV Images/ModuleSkins/Drawing/")
            case .Panels:
                return artFolder.appendingPathComponent("/UV Images/ModuleSkins/Panels/")
            case .SleekCables:
                return artFolder.appendingPathComponent("/UV Images/ModuleSkins/SleekCables/")
        }
    }
    
    /// The `Color` UV texture
    var albedo:String? {
        switch self {
            case .BioModule: return "BioModule.png"
            case .HabModule: return "HabModule.png"
            case .LabModule: return "LabModule.png"
            case .ModuleBake: return "ModuleBake4.png"
            case .diffuse1: return "ModuleDif1.png"
            // new
            case .BatteryMod: return "BatteryMod_1K_color.jpeg"
            case .Capsule: return "Capsule_1K_albedo.png"
            case .Drawing: return "DrawingColor.png"
            case .Panels: return "Panels_1K_albedo.tif"
            case .SleekCables: return "SleekCables_1K_albedo.png"
        }
    }
    
    /// The `AmbientOcclusion` UV texture
    var occlusion:String? {
        switch self {
            // new
            case .BatteryMod: return "BatteryMod_1K_ao.tif"
            case .Capsule: return "Capsule_1K_ao.png"
            case .Drawing: return "DrawingAO.png"
            case .Panels: return "Panels_1K_ao.tif"
            case .SleekCables: return "SleekCables_1K_ao.png"
            default: return nil
        }
    }
    
    /// The `metalic` UV texture
    var metalic:String? {
        switch self {
            // new
            case .BatteryMod: return "BatteryMod_1K_metallic.tif"
            case .Capsule: return nil // "Capsule_1K_normal.png"
            case .Drawing: return "DrawingMetalic.png"
            case .Panels: return nil
            case .SleekCables: return "SleekCables_1K_metallic.jpeg"
            default: return nil
        }
    }
    
    /// The `roughness` UV texture
    var roughness:String? {
        switch self {
            case .BatteryMod: return "BatteryMod_1K_roughness.tif"
            case .Capsule: return "Capsule_1K_roughness.png"
            case .Drawing: return "ScuffsA_1K_overlay.tif"
            case .Panels: return "Panels_1K_roughness.tif"
            case .SleekCables: return "SleekCables_1K_roughness.png"
            default: return nil
        }
    }
    
    /// The `normal` UV texture
    var normal:String? {
        switch self {
            // new
            case .BatteryMod: return "BatteryMod_1K_normal.tif"
            case .Capsule: return "Capsule_1K_normal.png"
            case .Drawing: return "DrawingNormal.png"
            case .Panels: return "Panels_1K_normal.tif"
            case .SleekCables: return "SleekCables_1K_normal.jpeg"
            default: return nil
        }
    }
}
