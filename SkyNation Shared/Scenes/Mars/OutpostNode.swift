//
//  OutpostNode.swift
//  SkyNation
//
//  Created by Carlos Farini on 8/17/21.
//

import Foundation
import SceneKit

class OutpostNode:SCNNode {
    
    var posdex:Posdex
    var outpost:DBOutpost?
    
    init(posdex:Posdex, outpost:DBOutpost?) {
        self.posdex = posdex
        self.outpost = outpost
        
        // For position and euler, see Posdex
        // check which Type of outpost also from posdex
        
        super.init()
        
        switch posdex {
            case .hq:
                print("Headquarters")
                
            case .antenna:
                print("Antenna")
            case .launchPad:
                print("Launchpad - Landings")
                
            case .arena:
                print("Stadium")
            case .observatory:
                print("Observatory")
            
            // Production
            
            case .biosphere1, .biosphere2:
                print("Biospheres")
            
            case .mining1, .mining2, .mining3:
                print("Mining")
            
            case .power1, .power2, .power3, .power4:
                print("Power Plants")
            default:
                print("This posdex is not related to an Outpost")
        }
        
        // check if is collectible
        // load the city, check 'op_collected'
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
