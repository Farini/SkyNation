//
//  Tutorial.swift
//  SkyTestSceneKit
//
//  Created by Carlos Farini on 12/17/20.
//  Copyright © 2020 Farini. All rights reserved.
//

import Foundation

enum TutorialSection:String, CaseIterable {
    case Welcome
    case HabModules
    case LabModules
    case TechTree
    case Recipes
    
}

struct TutorialPageItem {
    var id:UUID
    var order:Int
    
    var words:String?
    var imageSource:String?
    
}

struct GameTutorial {
    
}
