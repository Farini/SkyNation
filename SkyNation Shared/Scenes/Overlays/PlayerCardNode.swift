//
//  PlayerCardNode.swift
//  SkyNation
//
//  Created by Carlos Farini on 12/21/20.
//

import Foundation
import SpriteKit

class PlayerCardNode:SKNode {
    
    var avatar:SKSpriteNode
    
    var nameLabel:SKLabelNode
    
    var moneySprite:SKSpriteNode
    var moneyLabel:SKLabelNode
    
    var tokenLabel:SKLabelNode
    
    // Buttons
    var settingsButton:SKSpriteNode
    var tutorialButton:SKSpriteNode
    
    var player:SKNPlayer
    
    private let margin:Double = 6.0
    
    init(player:SKNPlayer) {
        
        print("\n\n Player Card...")
        let timeTokens = player.timeTokens
        let deliveryTokens = player.deliveryTokens
        let name = player.name
        let avatar = player.logo
        let money = player.money
        self.player = player
        
        
        // Player Avatar
        var avTex:SKTexture!
        if let logo = player.logo {
            avTex = SKTexture(imageNamed: logo)
        } else {
            let avimg = GameImages.commonSystemImage(name: "person.crop.square")!.image(with: .white)
            #if os(macOS)
            // image.isTemplate = true
            avTex = SKTexture(cgImage: avimg.cgImage(forProposedRect: nil, context: nil, hints: [:])!)
            // avTex = SKTexture(cgImage: avimg.cgim)
            #else
            avTex = SKTexture(image: avimg)
            #endif
        }
        let avWidth = max(avTex.size().width, 112)
        let avHeight = (avTex.size().height / avTex.size().width) * avWidth
        let avatarNode = SKSpriteNode(texture: avTex, size: CGSize(width: avWidth, height: avHeight))
        
        avatarNode.anchorPoint = CGPoint(x: 0.0, y: 1.0)
        avatarNode.position = CGPoint(x: margin, y: -margin)
        avatarNode.zPosition = 80
        self.avatar = avatarNode
        
        var posXY:CGPoint = CGPoint(x: Double(avatarNode.calculateAccumulatedFrame().width), y: -margin * 4)
        print("posXY begins: \(posXY)")
        
        // Name, Money and Token
        let nameLabel = PlayerCardNode.makeText(player.name)
        nameLabel.position = posXY
        nameLabel.fontColor = .white
        self.nameLabel = nameLabel
        posXY.y -= (nameLabel.calculateAccumulatedFrame().height + CGFloat(margin))
        print("posXY label: \(posXY)")
        
        // Currency image
        let currencyTexture = SKTexture(image: GameImages.currencyImage)
        let currencySprite = SKSpriteNode(texture: currencyTexture, color: .white, size: CGSize(width: 24, height: 24))
        currencySprite.anchorPoint = CGPoint(x: 0, y: 1)
        currencySprite.zPosition = 90
        currencySprite.position = posXY
        self.moneySprite = currencySprite
//        posXY.y -= currencySprite.calculateAccumulatedFrame().height + CGFloat(margin)
        print("posXY currency image: \(posXY)")
        
        // Currency Label
        let moneyString = GameFormatters.numberFormatter.string(from: NSNumber(value: player.money)) ?? "0"
        let moneyLbl = PlayerCardNode.makeText(moneyString)
        let moneyPosX = Double(currencySprite.position.x) + 20 + 6
        moneyLbl.position = CGPoint(x: moneyPosX, y: Double(posXY.y))
        moneyLbl.zPosition = 90
        print("\t money lbl: \(moneyPosX), \(posXY.y) > (x):\(posXY.x)")
        self.moneyLabel = moneyLbl
        posXY.y -= moneyLbl.calculateAccumulatedFrame().height + CGFloat(margin)
        
        // Tokens
        // TODO: - Make Images for Tokens
        let tokensLbl = PlayerCardNode.makeText("TT:\(timeTokens.count), DT:\(deliveryTokens.count)")
        tokensLbl.position = posXY
        tokensLbl.zPosition = 90
        
        self.tokenLabel = tokensLbl
        print("posXY tokens: \(posXY)")
        
        // Settings + tutorial buttons
        let settingsTexture = SKTexture(image: GameImages.commonSystemImage(name:"gearshape.fill")!.image(with: .white))
        let settingsSprite = SKSpriteNode(texture: settingsTexture, size: CGSize(width: 36, height: 36))
        settingsSprite.anchorPoint = CGPoint(x: 0.5, y: 0)
        settingsSprite.name = "settings"
        self.settingsButton = settingsSprite
        
        // Tutorial
        let tutImage = GameImages.commonSystemImage(name: "questionmark.diamond")!.image(with: .white)
        let tutTexture = SKTexture(image: tutImage)
        let tutSprite = SKSpriteNode(texture: tutTexture, size: CGSize(width: 36, height: 36))
        tutSprite.anchorPoint = CGPoint(x: 0.5, y: 0)
        tutSprite.name = "tutorial"
        self.tutorialButton = tutSprite
        
        // Assemble
        
        super.init()
        
        addChild(avatarNode)
        addChild(nameLabel)
        addChild(currencySprite)
        addChild(moneyLbl)
        addChild(tokensLbl)
        
        // Background
        var backgroundSize = calculateAccumulatedFrame().size
        backgroundSize.width += 12
//        backgroundSize.height += 6
        let backRect = CGRect(origin: CGPoint(x: 6, y: -6), size: backgroundSize)
        let backShape = SKShapeNode(rect: backRect, cornerRadius: 8)
        backShape.fillColor = SCNColor.black.withAlphaComponent(0.7)
        backShape.strokeColor = .gray
        backShape.lineWidth = 1.5
        backShape.position = CGPoint(x: 6, y: -backgroundSize.height)
        backShape.zPosition = 20
        
        
        addChild(backShape)
        print("Back Shape: \(backShape)\n \t Size:\(backgroundSize)")
        print("Back Rect: \(backRect)")
        print("Back Size: \(backShape.calculateAccumulatedFrame().size)")
        print("Back Position: \(backShape.position)")
        
        // Buttons positions
        var outsidePositionX = calculateAccumulatedFrame().size.width + 5 * CGFloat(margin)
        let outsidePositionY = -1 * (calculateAccumulatedFrame().size.height + CGFloat(margin))
        self.settingsButton.position = CGPoint(x: outsidePositionX, y: outsidePositionY)
        addChild(settingsButton)
        outsidePositionX += settingsButton.calculateAccumulatedFrame().width + CGFloat(margin)
        self.tutorialButton.position = CGPoint(x: outsidePositionX, y: outsidePositionY)
        addChild(tutorialButton)
        print("\t Outside position: \(outsidePositionX), \(outsidePositionY)\n\n")
        
        // Ruler
        let rulerWidth = Double(calculateAccumulatedFrame().size.width)
        let rulerHeight = 8.0
//        let shearValue = CGFloat(0.3) // You can change this to anything you want
//        let shearTransform = CGAffineTransform(a: 1, b: 0, c: shearValue, d: 1, tx: 0, ty: 0)
        let path = CGMutablePath() //CGPath(rect: CGRect(origin: .zero, size: CGSize(width: rulerWidth, height: rulerHeight)), transform: nil)
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: rulerWidth - 16, y: 0))
        path.addLine(to: CGPoint(x: rulerWidth - 24, y: -rulerHeight))
        path.addLine(to: CGPoint(x: 0, y: -rulerHeight))
        path.addLine(to: .zero)
        
        path.move(to: CGPoint(x: rulerWidth, y: 0))
        path.addLine(to: CGPoint(x:rulerWidth + 16, y:0))
        path.addLine(to: CGPoint(x: rulerWidth + 8, y: -rulerHeight))
        path.addLine(to: CGPoint(x:rulerWidth - 8, y:-rulerHeight))
        path.addLine(to: CGPoint(x:rulerWidth, y:0))
        
        let rulerShape = SKShapeNode(path: path)
        rulerShape.position = CGPoint(x: 0, y: Double(outsidePositionY) - (rulerHeight / 2))
        rulerShape.lineWidth = 0
//        rulerShape.strokeColor = .red
        rulerShape.fillColor = SCNColor.gray.withAlphaComponent(0.7)
        rulerShape.zPosition = 32
        addChild(rulerShape)
        
    }
    
    private class func makeText(_ string:String) -> SKLabelNode {
        
        let label = SKLabelNode()
        label.text = string
        label.fontName = "Menlo"
        label.fontSize = 22
        label.fontColor = .white
//        label.position = CGPoint(x: 42, y: 25)
        label.horizontalAlignmentMode = .left
        label.verticalAlignmentMode = .top
        label.isUserInteractionEnabled = false
        label.zPosition = 90
        print("Making label: \(label)")
        
        return label
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
