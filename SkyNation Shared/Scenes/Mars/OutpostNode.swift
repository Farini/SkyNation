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
    
    /// Outposts are required
    var outpost:DBOutpost
    
    init(posdex:Posdex, outpost:DBOutpost) {
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

// Antenna
// Scene: /Mars/Outposts/OPAntenna
// [Parts]
// - Parabolic // Top Sattelite Dish
// - Dish1 // Round top dish
// - Pillar
// - Wifi3, Wifi2, Wifi1
// - Dish3, Dish2 // Lower Antennas
// - Dish4 // Round top opposite side Dish1
// - Scallera

// PowerPlant
// Notes: Plenty of opportunity forr levels here. Start with the side ones, then the outside Panels, then inside Reflectors, Then Outside reflectors
// Scene: /Mars/Outposts/PowerPlant.scn
// [Parts]
// [Side Solar Panels]: Panel1,2,3,4
// [Outter Panels]: Panel8,7,6,5
// [Largest reflector]: MainReflector
// [Outside Reflectors] Reflector4,5,2,7,6
// [Inside Reflectors]: Reflector1,2,3
// [cables] Cable1...Cable19

// Landing Pad
// Notes: 3 Landing pads + Sign + Launch Platform
// Scene: Mars/Outposts/LandingPad.scn (LPad child)
// [parts]
// Launch Platform
// LP2, LP3, LP1
// Sign1, Sign2, Sign3
// PreSign

// Biosphere
// Scene: /Mars/Outposts/Biosphere2.scn
// [Parts]
// - Dome
// - Building
// SolarPanels x 9
// WallLVL x 5
// Tanks x 5
// Animals

// Observatory
// (Needs Blender quick Rebuild)
// Rearrange children

// Mining


// Missing:
// 1. Mining
// 2. Observatory
// 3. Arena
// 4. HQ? - Not actually a Scene



//class OPAntenna:OutpostNode {
//    override init(posdex: Posdex, outpost: DBOutpost) {
//        <#code#>
//    }
//}
