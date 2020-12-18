//
//  SceneHelpers.swift
//  SkyTestSceneKit
//
//  Created by Farini on 8/23/20.
//  Copyright © 2020 Farini. All rights reserved.
//

import Foundation

/// An object that defines `SCNNode`(name), Vector3D` (position), `Orientation3D` (EulerAngles)
struct Model3D:Codable {
    var name:String
    var orientation:Orientation3D
    var position:Vector3D
}

/// A guide to orient a `Node` object in the scene
enum Orientation3D:Int, Codable, CaseIterable {
    case Up;
    case Down;
    case East;
    case West;
    case Front;
    case Back;
    
    /// The Vector for rotation
    var vector:Vector3D {
        get {
            switch self {
            case .Up: return Vector3D(x: 0, y: 0, z: 90)
            case .Down: return Vector3D(x: -180, y: -0, z: 0)
            case .Front: return Vector3D(x: 0, y: -90, z: 0)
            case .Back: return Vector3D(x: 0, y: 90, z: 0)
            case .East: return Vector3D(x: -90, y: 0, z: 0)
            case .West: return Vector3D(x: 90, y: 0, z: 0)
            }
        }
    }
}

/// Position of a `Node` in the scene
struct Vector3D:Codable {
    
    var x:Double
    var y:Double
    var z:Double
    
    init(x:Double, y:Double, z:Double) {
        self.x = x
        self.y = y
        self.z = z
    }
    
    static var zero:Vector3D {
        return Vector3D(x: 0, y: 0, z: 0)
    }
}




