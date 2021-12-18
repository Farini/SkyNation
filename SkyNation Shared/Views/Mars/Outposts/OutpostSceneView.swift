//
//  OutpostSceneView.swift
//  SkyNation
//
//  Created by Carlos Farini on 12/7/21.
//

import SwiftUI
import SceneKit

struct OutpostSceneView: View {
    
    var posdex:Posdex
    var outpostScene:OutpostScene?
    
    init(dbOutpost:DBOutpost?) {
        if let dbOutpost = dbOutpost {
            self.posdex = Posdex(rawValue:dbOutpost.posdex)!
            self.outpostScene = OutpostSceneView.loadInfo(dbOutpost: dbOutpost)
        } else {
            let outpost = DBOutpost(busy: false, type: .Antenna, level: 0, posdex: .antenna)
            
            self.posdex = .antenna
            self.outpostScene = OutpostSceneView.loadInfo(dbOutpost: outpost)
        }
    }
    
    var body: some View {
//        VStack {
            if let opScene = outpostScene {
            
#if os(macOS)
                let aMode:SCNAntialiasingMode = .multisampling8X
#else
                let aMode:SCNAntialiasingMode = .multisampling4X
#endif
                SceneView(scene: opScene.scene, pointOfView: opScene.camera, options: .allowsCameraControl, preferredFramesPerSecond: 45, antialiasingMode: aMode, delegate: nil, technique: nil)
                    .frame(minWidth: 400, maxWidth: 1200, minHeight: 300, maxHeight: 1200)
                
            } else {
                VStack {
                    Spacer()
                    Text("This outpost doesn't have a scene.").font(.title)
                    Spacer()
                }
            }
//        }
    }
    
    static func loadInfo(dbOutpost:DBOutpost) -> OutpostScene? {
        
        var sceneName:String?
        var model:SCNNode?
        var camNode:SCNNode?
        
        switch dbOutpost.type {
                
            case .Water:
                sceneName = MiningNode.originScene
                let water = MiningNode(posdex: Posdex(rawValue: dbOutpost.posdex)!, outpost: dbOutpost)
                camNode = water.cameraNodes.first
                model = water
                
            case .Energy:
                sceneName = PowerPlantNode.originScene
                let powerPlant = PowerPlantNode(posdex: Posdex(rawValue: dbOutpost.posdex)!, outpost: dbOutpost)
                camNode = powerPlant.cameraNodes.first
                model = powerPlant
                
            case .Biosphere:
                sceneName = BiosphereNode.originScene
                let biosphere = BiosphereNode(posdex: Posdex(rawValue: dbOutpost.posdex)!, outpost: dbOutpost)
                camNode = biosphere.cameraNodes.first
                model = biosphere
                
            case .Observatory:
                sceneName = ObservatoryNode.originScene
                let obs = ObservatoryNode(posdex: Posdex(rawValue: dbOutpost.posdex)!, outpost: dbOutpost)
                model = obs
                camNode = obs.cameraNodes.first
                
            case .Antenna:
                sceneName = MarsAntennaNode.originScene
                let antenna = MarsAntennaNode(posdex: Posdex(rawValue: dbOutpost.posdex)!, outpost: dbOutpost)
                model = antenna
                camNode = antenna.cameraNodes.first
                
            case .Launchpad:
                sceneName = LandingPadNode.originScene
                let pad = LandingPadNode(posdex: Posdex(rawValue: dbOutpost.posdex)!, outpost: dbOutpost)
                model = pad
                camNode = pad.cameraNodes.first
                
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
        OutpostSceneView(dbOutpost: nil)
    }
}
