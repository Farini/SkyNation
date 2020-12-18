//
//  LabModule.swift
//  SkyTestSceneKit
//
//  Created by Farini on 9/23/20.
//  Copyright © 2020 Farini. All rights reserved.
//

import Foundation

class LabModule:Codable {
    
    var id:UUID                 // *** REFERENCE TO  BuildItem.id
    var moduleDex:ModuleIndex   // index of module
    var type:ModuleType         // .Bio, .Hab, .Lab...
    
    var name:String             // any name given
    var skin:String
    var activity:LabActivity?
    var capacity:Int
    var usedRacks:[String]
    
    // FIXME: - Add Skin
    
    init(module:Module) {
        self.id = module.id
        self.moduleDex = module.moduleDex
        self.name = module.name
        self.activity = nil
        self.capacity = 12
        self.usedRacks = []
        self.type = .Lab
        self.skin = "ModuleColor"
    }
    
    static func example() -> LabModule {
        let labid = UUID()
        let dex = ModuleIndex.allCases.randomElement()!
        let type = ModuleType.Lab
        let name = "Test Lab"
        let cap = 12
        let mod = Module(id: labid, modex: dex)
        let labmod = LabModule(module: mod)
        labmod.type = type
        labmod.name = name
        labmod.capacity = cap
        labmod.usedRacks = []
        return labmod
    }
    
}
