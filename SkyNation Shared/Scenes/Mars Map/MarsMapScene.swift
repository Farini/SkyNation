//
//  MarsMapScene.swift
//  SkyTestSceneKit
//
//  Created by Carlos Farini on 11/4/20.
//  Copyright © 2020 Farini. All rights reserved.
//

/*
 

import Foundation
import SpriteKit

class MarsMapScene:SKScene {
    
    // Camera
    var camLabelPosition:SKLabelNode?
    
    // MARK: - MAPS - Same Size
    
    // Empty (Placeholder) to hold different maps
    var mapHolder:SKNode
    
    // Map (Elevation)
    var mapElevation:SKSpriteNode
    
    // Map (Color)
    // Map (Infrared)
    // Landmarks
    
    // MARK: - Setup
    override init(size: CGSize) {
        print("Custom init with size: \(size)")
        
        // Map holder
        let holder = SKNode()
        holder.name = "holder"
        holder.position = CGPoint.zero
        self.mapHolder = holder
        
        // Color map
        let colorMap = SKSpriteNode(texture: SKTexture(imageNamed: "Mars_12k_color"))
        colorMap.name = "colorMap"
        colorMap.zPosition = 1
        self.mapElevation = colorMap
        holder.addChild(self.mapElevation)
        
        super.init(size: size)
        
        
        self.isUserInteractionEnabled = true
        

        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var didAddNodes:Bool = false
    
    override func didMove(to view: SKView) {
        
        print("Did move. Size:\(view.bounds.size)")
        
        if didAddNodes || view.bounds.size.width < 10 {
            return
            
        }else{
            self.addChild(mapHolder)
            self.didAddNodes = true
        }

        for child in self.children {
            print("C: \(child.description)")
        }
        
        // Landmark Labels
        
        // Labels From Scene
        if let mapScene = SKScene(fileNamed: "MarsMapScene") {
            if let holder = mapScene.childNode(withName: "LabelsHolder") {
                for label in holder.children {
                    label.removeFromParent()
                    label.zPosition = 11
                    self.mapHolder.addChild(label)
                }
            }
        }
        
        // Extra Labels
        let lbl1 = SKLabelNode(text: "Test Landmark")
        lbl1.position = CGPoint(x: -100, y: -200)
        lbl1.zPosition = 11
        self.mapHolder.addChild(lbl1)
        
        // Camera
        let cam1 = SKCameraNode()
        cam1.position = CGPoint.zero
        let camPosLabel = SKLabelNode(text: "Cam pos \(cam1.position)")
        camPosLabel.name = "CameraPositionLabel"
        let halfWidth = -(view.frame.size.width / 2) + 8
        let halfHeigh = view.frame.size.height / 2 - 28
        
        let camLabelPos = CGPoint(x: halfWidth, y: halfHeigh)
        print("camlabelpos \(camLabelPos)")
        camPosLabel.position = camLabelPos
        camPosLabel.zPosition = 90
        camPosLabel.color = .yellow
        camPosLabel.horizontalAlignmentMode = .left
        cam1.addChild(camPosLabel)
        
        let zoomLabel = SKLabelNode(text: "Zoom")
        zoomLabel.name = "zoom"
        let zoomY = camLabelPos.y - 100
        zoomLabel.position = CGPoint(x: camLabelPos.x, y: zoomY)
        zoomLabel.zPosition = 91
        zoomLabel.horizontalAlignmentMode = .left
        cam1.addChild(zoomLabel)
        self.camLabelPosition = camPosLabel
        
        self.camera = cam1
        addChild(camera!)
        
        print("View did move")
    }
    
    // MARK: - Scene Loop
    override func update(_ currentTime: TimeInterval) {
    }
    
    // MARK: - Control
    
    var touchPos:CGPoint?
    
    // Mouse
    #if os(macOS)
    override func mouseDown(with event: NSEvent) {
        
        let location:CGPoint = event.location(in: self)
        print("Mouse down at \(location)")
        /*
         let box = SKSpriteNode(color: SCNColor.red, size: CGSize(width: 50, height: 50))
         box.position = location
         box.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 50, height: 50))
         addChild(box)
         */
        touchPos = location
    }
    
    override func mouseUp(with event: NSEvent) {
        let location:CGPoint = event.location(in: self)
        print("Mouse up at \(location)")
        
        for node in nodes(at: location) {
            print("Node \(node.name ?? "n/a") at: \(location)")
            if let label = node as? SKLabelNode {
                print("Label Clicked (Tapped) \(label.description)")
                if label.name == "zoom" {
                    print("Zoom button")
                    self.mapElevation.setScale(0.2)
                }
            }
        }
    }
    
    override func mouseDragged(with event: NSEvent) {
        print("Mouse dragged: \(event.location(in: self))")
        let current = event.location(in: self)
        if let pos0 = touchPos {
            let deltaX = pos0.x - current.x
            let deltaY = pos0.y - current.y
            
            camera?.position.x += deltaX
            camera?.position.y += deltaY
            
            touchPos = current
            camLabelPosition?.text = "X: \(Int(camera?.position.x ?? 0)) | Y:\(Int(camera?.position.y ?? 0))"
        }
    }
    
    // Touches
    
    override func touchesBegan(with event: NSEvent) {
        print("Touch Began")
        touchPos = event.location(in: self)
    }
    
    override func touchesMoved(with event: NSEvent) {
        print("Moved")
        let current = event.location(in: self)
        camera!.position = current
    }
    
    override func touchesEnded(with event: NSEvent) {
        
    }
    #endif
}
 */
