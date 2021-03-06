//
//  HabModule.swift
//  SkyTestSceneKit
//
//  Created by Farini on 9/23/20.
//  Copyright © 2020 Farini. All rights reserved.
//

import Foundation

class HabModule:Codable {
    
    var id:UUID                 // *** REFERENCE TO  BuildItem.id
    var moduleDex:ModuleIndex   // index of module
    var type:ModuleType         // .Bio, .Hab, .Lab...
    
    var name:String             // any name given
    var skin:ModuleSkin //String
    
    var inhabitants:[Person]
    var capacity:Int
    
    init(module:Module, cap2:Bool? = false) {
        self.id = module.id
        self.moduleDex = module.moduleDex
        self.name = module.name
        self.type = .Hab
        
        if cap2 == true {
            self.capacity = 2
        }else{
            self.capacity = 4
        }
        
        self.inhabitants = []
        self.skin = .HabModule //"ModuleColor"
    }
    
    /// An example for the SwiftUI
    static var example:HabModule {
        return HabModule(module: Module(id: UUID(), modex: .mod6))
    }
}
