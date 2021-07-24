//
//  TechTreeDisplay.swift
//  SkyTestSceneKit
//
//  Created by Carlos Farini on 12/12/20.
//  Copyright © 2020 Farini. All rights reserved.
//

import Foundation

// MARK: - TECH TREE 2 ( Tree A )

struct TechnologyTree {
    
    var uniqueTree:Tree<Unique<TechItems>>
    
    init() {
        // Build the Tree here
        // Children - From the bottom to the top
        
        // Module 6 + Garage
        let garageArm = Tree(TechItems.GarageArm)
        let garage = Tree(TechItems.garage, children:[garageArm])
        var mod6 = Tree(TechItems.module6)
        mod6.children.append(garage)
        
        // Node 4
        let mod9 = Tree(TechItems.module9, children:[Tree(TechItems.module10)])
        var node4 = Tree(TechItems.node4)
        node4.children.append(mod6)
        node4.children.append(mod9)
        let methanizer = Tree(TechItems.recipeMethane)
        
        // Module 5
        var mod5 = Tree(TechItems.module5)
        mod5.children.append(node4)
        mod5.children.append(methanizer)
        
        let bioSolid = Tree(TechItems.recipeBioSolidifier)
        let au1 = Tree(TechItems.AU1, children:[bioSolid])
        let airlock = Tree(TechItems.Airlock, children:[au1])
        
        let au3 = Tree(TechItems.AU3)
        let waterFilter = Tree(TechItems.recipeWaterFilter, children:[au3])
        
        let cuppola = Tree(TechItems.Cuppola, children:[waterFilter])
        var mod7 = Tree(TechItems.module7)
        mod7.children.append(cuppola)
        mod7.children.append(airlock)
        
        // Node 3
        let mod8 = Tree(TechItems.module8)
        let au2 = Tree(TechItems.AU2, children:[mod8])
        let scrubber = Tree(TechItems.recipeScrubber, children:[au2])
        var nod3 = Tree(TechItems.node3)
        nod3.children.append(mod5)
        //        nod3.children.append(mod7) //  add(child: mod7)
        nod3.children.append(scrubber)
        let au4 = Tree(TechItems.AU4)
        let roboArm = Tree(TechItems.Roboarm, children:[au4])
        
        // Module 4
        var mod4 = Tree(TechItems.module4)
        mod4.children.append(nod3)//  (child: nod3)
        mod4.children.append(roboArm) //(child: roboArm)
        
        
        // Node 2
        var nod2 = Tree(TechItems.node2)
        nod2.children.append(mod4) // (child: mod4)
        nod2.children.append(mod7)
        
        // Finalize
        let binaryTree = Tree<TechItems>(TechItems.rootItem, children: [nod2])
        
        let uniqueTree: Tree<Unique<TechItems>> = binaryTree.map(Unique.init)
        self.uniqueTree = uniqueTree
    }
}

struct Tree<A> {
    var value: A
    var children: [Tree<A>] = []
    var researchable:Bool
    
    init(_ value: A, parentDone:Bool = false, children: [Tree<A>] = []) {
        self.value = value
        self.children = children
        self.researchable = parentDone
    }
}

class Unique<A>: Identifiable {
    let value: A
    init(_ value: A) { self.value = value }
    
    func isUnlocked(station:Station) -> Bool {
//        print("ID: \(id)")  // The id of this object
        if let tech = value as? TechItems {
            if station.unlockedTechItems.contains(tech) {
                return true
            }
        }
        return false
    }
}

extension Tree {
    
    func map<B>(_ transform: (A) -> B) -> Tree<B> {
        Tree<B>(transform(value), children: children.map { $0.map(transform) })
    }
    
}
