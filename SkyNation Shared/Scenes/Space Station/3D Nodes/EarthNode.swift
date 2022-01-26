//
//  EarthNode.swift
//  SkyNation
//
//  Created by Carlos Farini on 2/8/21.
//

import Foundation
import SpriteKit
import SceneKit

class EarthNode:SCNNode {
    
    var earth:SCNNode
    var atmosphere:SCNNode
    var material:SCNMaterial
    
    func beginEntryAnimation() {
        
        // REVEALAGE
        // hide the atmosphere
        atmosphere.isHidden = true
        
        let revealDuration = 8.0
        let texture = SKTexture.init(noiseWithSmoothness: 0.85, size: CGSize(width: 512, height: 512), grayscale: true)
        material.setValue(SCNMaterialProperty(contents: texture), forKey: "noiseTexture")
        
        let modifierURL = Bundle.main.url(forResource: "dissolve.fragment", withExtension: "txt")!
        let modifierString = try! String(contentsOf: modifierURL)
        material.shaderModifiers = [
            SCNShaderModifierEntryPoint.fragment : modifierString
        ]
        
        let revealAnimation = CABasicAnimation(keyPath: "revealage")
        revealAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        revealAnimation.duration = revealDuration
        revealAnimation.fromValue = 0.1
        revealAnimation.toValue = 1.0
        revealAnimation.isRemovedOnCompletion = true
        revealAnimation.autoreverses = false
        let scnRevealAnimation = SCNAnimation(caAnimation: revealAnimation)
        
        material.addAnimation(scnRevealAnimation, forKey: "Reveal")
        
        let waiter = SCNAction.wait(duration: revealDuration)
        earth.runAction(waiter) {
            self.atmosphere.isHidden = false
            self.material.shaderModifiers = nil
        }
    }
    
    func beginExitAnimation() {
        
        // REVEALAGE
        let revealDuration = 4.0
        let texture = SKTexture.init(noiseWithSmoothness: 0.85, size: CGSize(width: 512, height: 512), grayscale: true)
        material.setValue(SCNMaterialProperty(contents: texture), forKey: "noiseTexture")
        
        let modifierURL = Bundle.main.url(forResource: "dissolve.fragment", withExtension: "txt")!
        let modifierString = try! String(contentsOf: modifierURL)
        material.shaderModifiers = [
            SCNShaderModifierEntryPoint.fragment : modifierString
        ]
        
        let revealAnimation = CABasicAnimation(keyPath: "revealage")
        revealAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        revealAnimation.duration = revealDuration
        revealAnimation.fromValue = 0.1
        revealAnimation.toValue = 1.0
        revealAnimation.isRemovedOnCompletion = false
        revealAnimation.autoreverses = false
        let scnRevealAnimation = SCNAnimation(caAnimation: revealAnimation)
        
        material.addAnimation(scnRevealAnimation, forKey: "Reveal")
        
        let waiter = SCNAction.wait(duration: revealDuration)
        earth.runAction(waiter) {
            self.removeFromParentNode()
        }
    }
    
    override init() {
        
        // Load Earth
        guard let earth = SCNScene(named: "Art.scnassets/Earth.scn")!.rootNode.childNode(withName: "Earth", recursively: false)?.clone(),
              let atmosphere = earth.childNodes.first,
              let material = earth.geometry?.material(named: "Earth")
        else { fatalError() }
        
        earth.position = SCNVector3(0, -18, 0)
        
        self.earth = earth
        self.atmosphere = atmosphere
        
        // Get the material to animate
        self.material = material
        
        super.init()
        
        // Post init
        self.name = "Earth"
        self.addChildNode(earth)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
