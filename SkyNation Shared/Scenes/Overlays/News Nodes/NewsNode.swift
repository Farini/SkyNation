//
//  NewsNode.swift
//  SkyNation
//
//  Created by Carlos Farini on 1/15/22.
//

import SpriteKit

/// The type of news to show
public enum NewsType:String, CaseIterable {
    case News
    case Info
    case Empty
    case Alarm
    case Intro
    case System
}

public struct NewsData {
    var type:NewsType
    var message:String
    var date:Date?
}

/** A node that shows the news to the player.
 This is part of the `GameOverlay` */
public class NewsNode:SKNode {
    
    /// The Header Sprite
    public var header:SKNode
    
    /// The Label with the `newsText`, displaying the news.
    public var label:SKLabelNode
    
    /// The String to display as news
    public var newsText:String
    
    /// The type of news that defines which header node should be used.
    public var newsType:NewsType
    
    var headShader = SKShader(fileNamed: "StrokeGrad")
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("not it")
    }
    
    public init(news:String) {
        
        // Scene
        guard let scene = SKScene(fileNamed: "NewsObj") else { fatalError() }
        // Get the Header (News, Info, etc.)
        print("Scene with \(scene.children.count) children")
        
        self.newsText = news
        self.newsType = .News
        
        guard let header = scene.childNode(withName: "News") else { fatalError() }
        // has a label, and Stripes as children.
        header.removeFromParent()
        self.header = header
        
        // Shape surrounding the header
        let highlight = header.calculateAccumulatedFrame()
        let highShape = SKShapeNode(rect: highlight, cornerRadius: 6.0)
        highShape.position.y -= highlight.size.height - 1
        highShape.lineWidth = 3.0
        
        let dashedShader = SKShader(fileNamed: "DashedBorder")
        
        highShape.strokeShader = dashedShader
        // highShape.strokeShader = SKShader(fileNamed: "StrokeGrad")
        header.addChild(highShape)
        
        guard let text = scene.childNode(withName: "NewsText") as? SKLabelNode else { fatalError() }
        // Setup the news here
        text.horizontalAlignmentMode = .center
        text.removeFromParent()
        text.text = news
        
        var textRect = text.calculateAccumulatedFrame()
        textRect.size.height += 12
        textRect.size.width += 20
        textRect.origin.y -= 6
        textRect.origin.x -= 10
        
        // Shape surrounding the text
        let textHShape = SKShapeNode(rect: textRect, cornerRadius: 8)
        textHShape.strokeColor = .gray
        textHShape.lineWidth = 2.5
        text.addChild(textHShape)
        
        self.label = text
        
        super.init()
        
        self.name = "News Node"
        
        self.addChild(header)
        self.addChild(text)
        
        let waiter = SKAction.wait(forDuration: 0.5)
        self.run(waiter) {
            self.label.typeNext(dex: 0, complete: news, time: 0.2)
        }
        
    }
    
    public init(type:NewsType, text:String) {
        
        /*
         0. Get the Scene
         1. Get the Header
         2. Set the Header
         3. Prepare Header Shaders
         4. add the children (header, label)
         */
        
        self.newsText = text
        self.newsType = type
        
        // Scene
        guard let scene = SKScene(fileNamed: "NewsObj") else { fatalError() }
        print("Scene with \(scene.children.count) children")
        
        // Header (News, Info, etc.)
        let headerName:String = type.rawValue
        guard let header:SKNode = scene.childNode(withName: headerName) else { fatalError() }
        let headRecto:CGRect = header.calculateAccumulatedFrame()
        
        header.removeFromParent()
        header.position = CGPoint(x: 0.0, y: headRecto.size.height - 3)
        self.header = header
        
        // Add Shape surrounding the News Label
        let headShape = SKShapeNode(rect: header.calculateAccumulatedFrame(), cornerRadius: 6.0)
        headShape.position.y -= headRecto.size.height - 1
        headShape.lineWidth = 2.5
        headShape.strokeShader = headShader
        header.addChild(headShape)
        
        // Text
        guard let label = scene.childNode(withName: "NewsText") as? SKLabelNode else { fatalError() }
        label.horizontalAlignmentMode = .center
        label.removeFromParent()
        label.text = newsText
        
        // Text Padding
        var textRect = label.calculateAccumulatedFrame()
        textRect.size.height += 12
        textRect.size.width += 20
        textRect.origin.y -= 6
        textRect.origin.x -= 10
        
        // Shape surrounding the text
        let textHShape = SKShapeNode(rect: textRect, cornerRadius: 8)
        textHShape.strokeColor = .gray
        textHShape.lineWidth = 2.5
        label.addChild(textHShape)
        
        self.label = label
        
        super.init()
        
        self.name = "News Node"
        
        self.addChild(header)
        self.addChild(label)
        self.label.isHidden = true
        
        self.enterTheScene()
        
    }
    
    /// Animates the Entrance of this node.
    public func enterTheScene() {
        
        let waiter = SKAction.wait(forDuration: 0.5)
        
        self.run(waiter) {
            
            self.label.isHidden = false
            self.label.typeNext(dex: 0, complete: self.newsText, time: 0.2)
            
            /*
            // Shape surrounding the News Label
            let highlight = self.header.calculateAccumulatedFrame()
            let highShape = SKShapeNode(rect: highlight, cornerRadius: 6.0)
            highShape.position.y -= highlight.size.height - 1
            highShape.lineWidth = 2.5
            highShape.strokeShader = SKShader(fileNamed: "StrokeGrad")
            self.header.addChild(highShape)
            */
            
            let exitDelay = Double(self.newsText.count) * 0.15 + 3.0
            
            let halfTime = SKAction.wait(forDuration: exitDelay)
            
            self.run(halfTime) {
                self.animateExit()
            }
        }
    }
    
    /// Animates itself out of the scene, and removes itself from parent.
    func animateExit() {
        
        let moveDown = SKAction.move(by: CGVector(dx: 0, dy: -15), duration: 0.85)
        moveDown.timingMode = .easeIn
        let stayDown = SKAction.wait(forDuration: 0.25)
        
        let moveUp = SKAction.move(by: CGVector(dx: 0, dy: 120), duration: 0.5)
        moveUp.timingMode = .easeOut
        let fadeOut = SKAction.fadeOut(withDuration: 0.35)
        fadeOut.timingMode = .easeOut
        let release = SKAction.group([moveUp, fadeOut])
        
        let sequence = SKAction.sequence([moveDown, stayDown, release])
        self.run(sequence) {
            self.removeFromParent()
        }
        
    }
}

public extension SKLabelNode {
    
    /**
     Animates this node with a typing effect.
     - Parameters:
        - dex: the current index of the string being typed
        - complete: the complete string to type
        - time: the time allocated to type the whole string
     */
    func typeNext(dex:Int, complete:String, time:Double) {
        
        if dex <= complete.count {
            
            if dex == complete.count {
                self.text = complete
                return
            }
            
            let nextString = String(complete.prefix(dex))
            self.text = nextString
            var delay = 0.0 // Bool.random() ? 0:time
            
            let character = String(Array(complete)[dex])
            if (character != " ") {
                if Bool.random() == true {
                    if Bool.random() == true {
                        delay = 0.1
                    } else {
                        delay = time
                    }
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                self.typeNext(dex: dex + 1, complete: complete, time: time)
            }
        }
    }
}

