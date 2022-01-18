//
//  SpriteTestView.swift
//  SkyNation
//
//  Created by Carlos Farini on 1/14/22.
//

import SwiftUI
import SpriteKit
import SceneKit

struct SpriteTestView: View {
    
    @State private var news:String?
    private var scene:SKScene
    let fakeNews:String = """
Greetings, commander `Player name`.
Your objective is to take over this space station
and expand its size and capabilities.
If you are so brave, send space vehicles to Mars
and colonize the red planet.
"""
    init() {
        
        let newScene = SKScene(size: CGSize(width: 750, height: 400))
        newScene.anchorPoint = CGPoint(x: 0.05, y: 0.8)
        
        self.scene = newScene
    }
    
    var body: some View {
        VStack {
            Text("SpriteKit Scene")
            if let news = news {
                Text("News: \(news)")
            }
            //SpriteView(scene: SKScene(fileNamed: "NewsObj")!)
            SpriteView(scene: scene, transition: .doorway(withDuration: 1), isPaused: false, preferredFramesPerSecond: 60)
        }
        .onAppear {
            describeScene()
        }
    }
    
    static func makeScene() -> SKScene {
        return SKScene()
    }
    
    func describeScene() {
        
//        let newNode = NewsNode(type: .Intro, text: "Here is the game introduction. \nClick here, click there, \n...and you good to go.")
//
//        newNode.position = CGPoint.zero
        
        let newNode = GameMessageNode(text:fakeNews)
        
        self.scene.addChild(newNode)
        
        
    }
}

struct SpriteTestView_Previews: PreviewProvider {
    static var previews: some View {
        SpriteTestView()
            .frame(width:750)
    }
}

class GameMessageNode:SKNode {
    
    init(text:String) {
        
        guard let scene = SKScene(fileNamed: "News2") else { fatalError() }
        var array:[SKNode] = []
        for chi in scene.children {
            chi.removeFromParent()
            array.append(chi)
        }
        
        super.init()
        
        guard let newsLabel = array.first(where: { $0.name == "newsText" }) as? SKLabelNode else {
            fatalError()
        }
        newsLabel.text = text
        newsLabel.position.y -= 5
        newsLabel.position.x += 10
        
        for chi in array {
            if chi.name == "BorderParent" {
                let path:CGMutablePath = CGMutablePath()
                if let p1 = chi.childNode(withName: "p1") {
                    path.move(to: p1.position)
                }
                if let p2 = chi.childNode(withName: "p2") {
                    path.addLine(to: p2.position)
                    
                    // calculate text
                    var textSpace = newsLabel.calculateAccumulatedFrame()
                    textSpace.size.width += 20
                    textSpace.size.height += 12
                    
                    let p3 = CGPoint(x:textSpace.size.width, y:p2.position.y)
                    let p4 = CGPoint(x:textSpace.size.width, y:p2.position.y - textSpace.size.height)
                    let p5 = CGPoint(x: 0, y: p2.position.y - textSpace.size.height)
                    let p6 = CGPoint(x: 0, y: 0)
                    path.addLine(to: p3)
                    path.addLine(to: p4)
                    path.addLine(to: p5)
                    path.addLine(to: p6)
                }
                
                path.closeSubpath()
                
                let shapeNode = SKShapeNode(path: path)
                shapeNode.lineWidth = 2.0
                shapeNode.fillColor = .black.withAlphaComponent(0.5)
                shapeNode.strokeShader = SKShader(fileNamed: "StrokeGrad")
                shapeNode.isPaused = false
                
                self.addChild(shapeNode)
                
            } else {
                self.addChild(chi)
            }
            
        }
        
        let moveRight = SKAction.move(by: CGVector(dx: 5, dy: 0), duration: 1.5)
        let moveLeft = SKAction.move(by: CGVector(dx: -5, dy: 0), duration: 1.5)
        let sequel = SKAction.sequence([moveRight, moveLeft])
        let repete = SKAction.repeatForever(sequel)
        self.run(repete)

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
