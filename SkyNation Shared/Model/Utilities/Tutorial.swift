//
//  Tutorial.swift
//  SkyTestSceneKit
//
//  Created by Carlos Farini on 12/17/20.
//  Copyright © 2020 Farini. All rights reserved.
//

import Foundation

enum TutorialPage:String, CaseIterable {
    case Welcome
    case HabModules
    case LabModules
    case TechTree
    case Recipes
    
}

struct TutorialItem {
    var id:UUID
    var order:Int
    
    var words:String?
    var imageSource:String?
}

struct GameTutorial {
    
    // Home
    let part1:[String] = ["Welcome to SkyNation. The objective of the game is to build your Space Station all the way to the garage.",
                          "First, you have to build a Habitation Module 🏠 that will be the home for new astronauts."]
    // Lab
    let part2:[String] = ["Now that you have your Hab Module built, its time to build a Lab Module 🔬",
                          "The Lab Module allows you to work on your tech tree, to further develop your Space Station",
                          "You may also make recipes that may generate resources or parts of the Station"]
    
    // Orders
    let part3:[String] = ["Tap the earth 🌎 to order new products",
                          "You may order Ingredients, Tanks, and hire people to come work at the Station.",
                          "You will need mostly Aluminium in the beginning to start building the Station.",
                          "Water, Oxygen and food are items that you will constantly need to supply to the Station."]
    
    
    
}
