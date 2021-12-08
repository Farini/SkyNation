//
//  OutpostSceneView.swift
//  SkyNation
//
//  Created by Carlos Farini on 12/7/21.
//

import SwiftUI
import SceneKit

struct OutpostSceneView: View {
    
    var posdex:Posdex = Posdex.biosphere1
    var outpostScene:OutpostScene?
    
    init(dbOutpost:DBOutpost? = nil) {
        if let dbOutpost = dbOutpost {
            self.outpostScene = OutpostSceneView.loadInfo(dbOutpost: dbOutpost)
        } else {
            let outpost = DBOutpost(gid: UUID(), type: .Biosphere, posdex: posdex)
            self.outpostScene = OutpostSceneView.loadInfo(dbOutpost: outpost)
        }
    }
    
    var body: some View {
        if let opScene = outpostScene {
            SceneView(scene: opScene.scene, pointOfView: opScene.camera, options: .allowsCameraControl, preferredFramesPerSecond: 45, antialiasingMode: SCNAntialiasingMode.multisampling8X, delegate: nil, technique: nil)
        } else {
            VStack {
                Spacer()
                Text("No Scene for this outpost").font(.title)
                Spacer()
            }
        }
    }
    
    static func loadInfo(dbOutpost:DBOutpost) -> OutpostScene? {
        
        var sceneName:String?
        var model:SCNNode?
        var camNode:SCNNode?
        
        switch dbOutpost.type {
                
            
            case .Water:
                sceneName = MiningNode.originScene
                model = MiningNode(posdex: Posdex(rawValue: dbOutpost.posdex)!, outpost: dbOutpost)
            
            case .Energy:
                sceneName = PowerPlantNode.originScene
                let powerPlant = PowerPlantNode(posdex: Posdex(rawValue: dbOutpost.posdex)!, outpost: dbOutpost)
                camNode = powerPlant.cameraNodes.first
                model = powerPlant
                
            case .Biosphere:
                sceneName = BiosphereNode.originScene
                model = BiosphereNode(posdex: Posdex(rawValue: dbOutpost.posdex)!, outpost: dbOutpost)
                
            
            case .Observatory:
                sceneName = ObservatoryNode.originScene
                model = ObservatoryNode(posdex: Posdex(rawValue: dbOutpost.posdex)!, outpost: dbOutpost)
                
            case .Antenna:
//                sceneName = Antenna3DNode.originScene
//                model = Antenna3DNode(posdex: Posdex(rawValue: dbOutpost.posdex)!, outpost: dbOutpost)
                return nil
            case .Launchpad:
                sceneName = LandingPadNode.originScene
                model = LandingPadNode(posdex: Posdex(rawValue: dbOutpost.posdex)!, outpost: dbOutpost)
                
            case .Arena:
                return nil
            case .ETEC:
                return nil
            case .HQ:
                return nil
            case .Silica:
                return nil
                
            case .Titanium:
                return nil
                
            
        }
        
        if let sceneName = sceneName,
           let model = model {
            let scene = SCNScene(named: sceneName)!
            for child in scene.rootNode.childNodes {
                child.removeFromParentNode()
                child.isHidden = true
            }
            
            scene.rootNode.addChildNode(model)
            
            let reqCam = camNode ?? model.childNode(withName: "Camera", recursively: true) ?? SCNNode()
            return OutpostScene(scene: scene, camera: reqCam)
        }
        
        return nil
        
    }
}

struct OutpostScene {
    var scene:SCNScene
    var camera:SCNNode
}

struct OutpostSceneView_Previews: PreviewProvider {
    static var previews: some View {
        OutpostSceneView()
    }
}
