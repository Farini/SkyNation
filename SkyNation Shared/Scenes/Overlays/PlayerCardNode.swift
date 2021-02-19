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
    
    var tokenSprite:SKSpriteNode
    var tokenLabel:SKLabelNode
    
    // Buttons
    var settingsButton:SKSpriteNode
    var tutorialButton:SKSpriteNode
    
    var player:SKNPlayer
    
    private let margin:Double = 6.0
    
    init(player:SKNPlayer) {
        
        let timeTokens = player.timeTokens
        let deliveryTokens = player.deliveryTokens
        let name = player.name
//        let avatar = player.logo
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
        let nameLabel = PlayerCardNode.makeText(name)
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
        print("posXY currency image: \(posXY)")
        
        // Currency Label
        let moneyString = GameFormatters.numberFormatter.string(from: NSNumber(value: money)) ?? "0"
        let moneyLbl = PlayerCardNode.makeText(moneyString)
        let moneyPosX = Double(currencySprite.position.x) + 20 + 6
        moneyLbl.position = CGPoint(x: moneyPosX, y: Double(posXY.y))
        moneyLbl.zPosition = 90
        print("\t money lbl: \(moneyPosX), \(posXY.y) > (x):\(posXY.x)")
        self.moneyLabel = moneyLbl
        posXY.y -= moneyLbl.calculateAccumulatedFrame().height + CGFloat(margin)
        
        // Tokens
        // TODO: - Make Images for Tokens
        // Icon
        let tokenTexture = SKTexture(image: GameImages.tokenImage)
        let tokenSprite = SKSpriteNode(texture: tokenTexture, color: .white, size: CGSize(width: 24, height: 24))
        tokenSprite.anchorPoint = CGPoint(x: 0, y: 1)
        tokenSprite.zPosition = 90
        tokenSprite.position = posXY
        self.tokenSprite = tokenSprite
        
        // Tokens Label
        let tokensLbl = PlayerCardNode.makeText("\(timeTokens.count)")
        tokensLbl.position = CGPoint(x: moneyPosX, y: Double(posXY.y))
        tokensLbl.zPosition = 90
        
        self.tokenLabel = tokensLbl
        print("posXY tokens: \(posXY)")
        
        // Settings
        let settingsSprite = PlayerCardNode.makeButton("gearshape.fill")!
        settingsSprite.anchorPoint = CGPoint.zero
        settingsSprite.name = "settings"
        self.settingsButton = settingsSprite
        
        // Tutorial
        let tutSprite = PlayerCardNode.makeButton("questionmark.diamond")!
        tutSprite.anchorPoint = CGPoint.zero
        tutSprite.name = "tutorial"
        self.tutorialButton = tutSprite
        
        // Assemble
        
        super.init()
        
        addChild(avatarNode)
        addChild(nameLabel)
        addChild(currencySprite)
        addChild(moneyLbl)
        addChild(tokenSprite)
        addChild(tokensLbl)
        
        // Background
        var backgroundSize = calculateAccumulatedFrame().size
        backgroundSize.width += 12
        let backRect = CGRect(origin: CGPoint(x: 6, y: -6), size: backgroundSize)
        let backShape = SKShapeNode(rect: backRect, cornerRadius: 8)
        backShape.fillColor = SCNColor.black.withAlphaComponent(0.7)
        backShape.strokeColor = .gray
        backShape.lineWidth = 1.5
        backShape.position = CGPoint(x: 6, y: -backgroundSize.height)
        backShape.zPosition = 20
        addChild(backShape)
        
        if GameSettings.shared.debugScene {
            print("Player Card Overlay Node:")
            print("Back Shape: \(backShape)\n \t Size:\(backgroundSize)")
            print("Back Rect: \(backRect)")
            print("Back Size: \(backShape.calculateAccumulatedFrame().size)")
            print("Back Position: \(backShape.position)")
            print("")
        }
        
        // Buttons positions
        let underpY = -(calculateAccumulatedFrame().size.height + 8)
        var underneathPosition:CGPoint = CGPoint(x: CGFloat(margin * 4), y: underpY)
        underneathPosition.y -= self.settingsButton.calculateAccumulatedFrame().height - 4
        
        self.settingsButton.position = underneathPosition //CGPoint(x: outsidePositionX, y: outsidePositionY)
        addChild(settingsButton)
        
        underneathPosition.x += settingsButton.calculateAccumulatedFrame().width + 6
        
        self.tutorialButton.position = underneathPosition //CGPoint(x: outsidePositionX, y: outsidePositionY)
        addChild(tutorialButton)
        
        underneathPosition.x += tutorialButton.calculateAccumulatedFrame().width + 6
        
        
        
        // Shopping - ShopButton
        if let cartSprite:SKSpriteNode = PlayerCardNode.makeButton("cart") {
            cartSprite.name = "ShopButton"
            cartSprite.color = .white
            cartSprite.colorBlendFactor = 1.0
            cartSprite.anchorPoint = CGPoint.zero
            cartSprite.position = underneathPosition
            cartSprite.zPosition = 80
            addChild(cartSprite)
        }
    }
    
    /// Makes a Sprite Node from an image name
    class func makeButton(_ imageName:String) -> SKSpriteNode? {
        guard let image = GameImages.commonSystemImage(name: imageName)?.image(with: .white) else {
            return nil
        }
        #if os(macOS)
        image.isTemplate = true
        let texture = SKTexture(cgImage: image.cgImage(forProposedRect: nil, context: nil, hints: [:])!)
        #else
        let texture = SKTexture(image: image.maskWithColor(color: .white))
        #endif
        let sprite:SKSpriteNode = SKSpriteNode(texture: texture, color: .white, size: CGSize(width: 36, height: 36))
        return sprite
    }
    
    private class func makeText(_ string:String) -> SKLabelNode {
        
        let label = SKLabelNode()
        label.text = string
        label.fontName = "Menlo"
        label.fontSize = 22
        label.fontColor = .white
        label.horizontalAlignmentMode = .left
        label.verticalAlignmentMode = .top
        label.isUserInteractionEnabled = false
        label.zPosition = 90
        
        return label
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
