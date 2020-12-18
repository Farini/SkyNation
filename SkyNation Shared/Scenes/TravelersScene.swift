//
//  TravelersScene.swift
//  SkyTestSceneKit
//
//  Created by Farini on 10/24/20.
//  Copyright © 2020 Farini. All rights reserved.
//

import Foundation
import SpriteKit

/// A simulation of travel from Earth to Mars
class TravelersScene:SKScene {
    
    var theSun:SKShapeNode!
    var earth:Planet!
    var mars:Planet!
    var vehicle:SKShapeNode!
    
    var earthAnglePos: CGFloat = 0
    var marsAnglePos: CGFloat = 3.14
    var vehicleAnglePos:CGFloat = 0
    
    var mRadius:CGFloat = 0.0
    
    override init(size: CGSize) {
        print("Custom init with size: \(size)")
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var nodesAdded:Bool = false
    override func didMove(to view: SKView) {
        
//        scene?.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
//        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        
        if nodesAdded { return }
        
        print("View did move")
        
        let vSize = (min(scene!.size.width, scene!.size.height)) - 8
        mRadius = vSize / 2
        scene!.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        
        // Sun
        theSun = SKShapeNode(circleOfRadius: 18)
        theSun.position = CGPoint(x: 0, y: 0)
        theSun.physicsBody = SKPhysicsBody(circleOfRadius: 10)
        theSun.fillColor = .yellow
        
        // Earth
        earth = Planet.create(type: .earth, position: CGPoint(x: size.width/4.0, y: size.height/4.0))
        
        // Mars
        mars = Planet.create(type: .mars, position: CGPoint(x: 0, y: mRadius))
        
        // Vehicle
        vehicle = SKShapeNode(circleOfRadius: 6)
        vehicle.name = "vehicle"
        vehicle.position = earth.node.position
        vehicle.position.x += PlanetType.earth.sizeRadius + 2
        vehicle.fillColor = .white
        vehicle.physicsBody = SKPhysicsBody(circleOfRadius: 20)
        vehicle.physicsBody!.collisionBitMask = 0
        
        // Start Scene
        self.addChild(theSun)
        self.addChild(earth.node)
        self.addChild(vehicle)
        self.addChild(mars.node)
        
        print("Moved...")
        self.nodesAdded = true
    }
    
    // MARK: - Calculus
    
    /// Velocity of the planet
    func calculateVelocity(normal:CGVector, node:SKNode, dt:CGFloat) -> CGVector {
        return CGVector(dx: (normal.dx - node.position.x)/dt, dy: (normal.dy-node.position.y)/dt)
    }
    
    func distance(p1:CGPoint, p2:CGPoint) -> CGFloat {
        return CGFloat(hypotf(Float(p1.x - p2.x), Float(p1.y - p2.y)))
    }
    
    var vehicleRadius:CGFloat = 0.0
    var fired:Bool = false
    
    func tapped(location:CGPoint) {
        fired = true
    }
    
    // MARK: - Scene Loop
    override func update(_ currentTime: TimeInterval) {
        
        // Time
        let dt:CGFloat = 1.0/60.0       // Delta Time = 1/60
        let period:CGFloat = 8          // Seconds it takes to complete 1 orbit.
        let period2:CGFloat = 25
        
        let orbitPosition = theSun.position             // Point to orbit around.
        let earthRadius:CGFloat = mRadius/2.0           // Distance Earth to sun
        let marsRadius:CGFloat = mRadius                // Distance Mars to sun
        
        self.earthAnglePos += (.pi*2.0)/period*dt
        self.marsAnglePos += (.pi*2.0)/period2*dt
        
        if (abs(self.earthAnglePos)>(.pi*2)) {
            self.earthAnglePos = 0
        }
        if (abs(self.marsAnglePos)>(.pi*2)) {
            self.marsAnglePos = 0
        }
        
        // Update Velocities
        let earthVector = CGVector(dx:orbitPosition.x + CGFloat(cos(self.earthAnglePos))*earthRadius ,dy:orbitPosition.y + CGFloat(sin(self.earthAnglePos))*earthRadius)
        
        let marsVector = CGVector(dx:orbitPosition.x + CGFloat(cos(self.marsAnglePos))*marsRadius ,dy:orbitPosition.y + CGFloat(sin(self.marsAnglePos))*marsRadius)
        
        // Earth
        earth.node.physicsBody!.velocity = calculateVelocity(normal: earthVector, node: earth.node, dt: dt)
        let trail = earth.updateWithTrail()
        self.addChild(trail)
        
        // (Mars)
        mars.node.physicsBody!.velocity = calculateVelocity(normal: marsVector, node: mars.node, dt: dt)
        let marsTrail = mars.updateWithTrail()
        self.addChild(marsTrail)
        
        // Log
        if fired == true {
            
            let d = distance(p1: earth.node.position, p2: mars.node.position)
            print("Fired. Distance:\(d), Angle(earth):\(earthAnglePos), Angle(mars):\(marsAnglePos)")
            
            vehicleRadius = earthRadius
            vehicleAnglePos = earthAnglePos
            
            fired = false
        }
        
        if vehicleRadius > 0 {
            if vehicleRadius <= mRadius {
                vehicleAnglePos += (.pi*2.0)/period*dt
                vehicleRadius += 1
                let vehicleNormal = CGVector(dx:orbitPosition.x + CGFloat(cos(self.vehicleAnglePos))*vehicleRadius ,dy:orbitPosition.y + CGFloat(sin(self.vehicleAnglePos))*vehicleRadius)
                print("Vehicle v: \(vehicleNormal)")
                vehicle.physicsBody!.velocity = calculateVelocity(normal: vehicleNormal, node: vehicle, dt: dt)
                
                if distance(p1: vehicle.position, p2: mars.node.position) < 10 {
                    print("ARRIVED")
                    let cameraNode = SKCameraNode()
                    cameraNode.position = vehicle.position
                    vehicle.isPaused = true
                    mars.node.isPaused = true
                    
                    scene!.addChild(cameraNode)
                    scene!.camera = cameraNode
//                    scene!.isPaused = true
                    
                    cameraNode.isPaused = false
                    let zoomAct = SKAction.scale(to: 0.25, duration: 0.5)
                    cameraNode.run(zoomAct) {
                        self.scene!.isPaused = true
                    }
                    
                }
            }
        }else{
            // Vehicle
            vehicle.position = CGPoint(x: earth.node.position.x + 15, y: earth.node.position.y)
        }
        
    }
    
    // MARK: - Control
    
    #if os(macOS)
    override func mouseDown(with event: NSEvent) {
        let location:CGPoint = event.location(in: self)
        tapped(location: location)
    }
    
    
    override func touchesBegan(with event: NSEvent) {
        
        let location:CGPoint = event.location(in: self)
        
        let box = SKSpriteNode(color: SCNColor.red, size: CGSize(width: 50, height: 50))
        box.position = location
        box.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 50, height: 50))
        addChild(box)
    }
    #endif
    
}

enum PlanetType:String {
    case earth
    case mars
    
    var sizeRadius:CGFloat {
        switch self {
        case .earth: return 12
        case .mars: return 8
        }
    }
    
    var color:SCNColor {
        switch self {
        case .earth: return SCNColor.green
        case .mars: return SCNColor.orange
        }
    }
}

class Planet {
    
    var color:SCNColor
    
    var node:SKNode
    
    /// Use to store the planet's last recorded position
    var lastPosition : CGPoint?
    
    class func create(type:PlanetType, position:CGPoint) -> Planet {
        let planet = Planet(type: type, position: position)
        planet.node.position = position
        return planet
    }
    
    init(type:PlanetType, position:CGPoint) {
        
        color = type.color
        
        let shape = SKShapeNode.init(circleOfRadius: type.sizeRadius)
        shape.fillColor = type.color
        shape.name = type.rawValue
        
        // Body
        let body = SKPhysicsBody(circleOfRadius: 10)
        body.collisionBitMask = 0
        
        shape.physicsBody = body
        
        self.node = shape
        
        let label = SKLabelNode(text: type.rawValue)
        label.fontSize = 40
        label.color = color
        label.position = CGPoint(x: 10, y: 0)
        shape.addChild(label)
        
        let scale = SKAction.scale(by: 1.5, duration: 1)
        let waiter = SKAction.wait(forDuration: 2)
        let fade = SKAction.fadeOut(withDuration: 2.5)
        let act = SKAction.sequence([scale, waiter, fade])
        act.timingMode = .easeOut
        
        shape.run(act) {
            label.removeFromParent()
        }
    }
    
    func updateWithTrail() -> SKShapeNode {
        
        if let lastPosition = lastPosition {
            
            let path = CGMutablePath()
            path.move(to: lastPosition)
            path.addLine(to: node.position)
            
            let lineSeg = SKShapeNode(path: path)
            lineSeg.strokeColor = color
            lineSeg.fillColor = color
            lineSeg.lineWidth = 3
//            node.addChild(lineSeg)
            
            lineSeg.run(SKAction.sequence([SKAction.fadeOut(withDuration: 3.5), SKAction.removeFromParent()]))
            self.lastPosition = node.position
            return lineSeg
        }
        
        lastPosition = node.position
        return SKShapeNode()
    }
}
