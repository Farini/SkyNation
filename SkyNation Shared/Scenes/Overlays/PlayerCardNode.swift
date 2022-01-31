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
    
    private let margin:Double = 6.0 //6.0
    
    init(player:SKNPlayer) {
        
        print("initting with player name: \(player.name)")
        
        let money = player.money
        self.player = player
        
        // Player Avatar
        let avatarTexture = SKTexture(imageNamed: player.avatar)
        
        // ---------------
        // LinePath
        
//        print("-- layout")
        let lineScene = SKScene(fileNamed: "PlayerCardLayout")!
//        print("++ layout")
        let hud = lineScene.childNode(withName: "HUDLine")!
        let path = CGMutablePath()
        path.move(to: hud.children.first!.position)
//        print("+++ layout")
        for hChild in hud.children {
            path.addLine(to: hChild.position)
        }
        path.closeSubpath()
        
        let pathNode = SKShapeNode(path: path, centered: false)
        pathNode.strokeColor = .gray
        pathNode.lineWidth = 3
        pathNode.glowWidth = 3
        pathNode.fillColor = SKColor.black.withAlphaComponent(0.8)
        
        // Avatar
        if let pAvatar = lineScene.childNode(withName: "SpritePlayer") {
            let avt = SKSpriteNode(texture: avatarTexture)
            avt.position = pAvatar.position
            avt.size = pAvatar.frame.size
            pathNode.addChild(avt)
            self.avatar = avt
        } else {
            self.avatar = SKSpriteNode()
        }
        
        
        // name label
        if let pnamelbl = lineScene.childNode(withName: "lblName") as? SKLabelNode {
            pnamelbl.text = player.name
            pnamelbl.removeFromParent()
            pathNode.addChild(pnamelbl)
            self.nameLabel = pnamelbl
        } else {
            self.nameLabel = SKLabelNode()
        }
        
        // money sprite
        if let moneySprite = lineScene.childNode(withName: "SKCoinsprite") as? SKSpriteNode {
            moneySprite.size = CGSize(width: 20, height: 20)
            moneySprite.removeFromParent()
            pathNode.addChild(moneySprite)
            self.moneySprite = moneySprite
        } else {
            self.moneySprite = SKSpriteNode()
        }
        
        // money label
        if let moneylbl = lineScene.childNode(withName: "lblMoney") as? SKLabelNode {
            moneylbl.text = "\(GameFormatters.numberFormatter.string(from: NSNumber(value: money)) ?? "0")"
            moneylbl.removeFromParent()
            pathNode.addChild(moneylbl)
            self.moneyLabel = moneylbl
        } else {
            self.moneyLabel = SKLabelNode()
        }
        
        // token sprite
        if let tSprite = lineScene.childNode(withName: "SKTokenSprite") as? SKSpriteNode {
            tSprite.size = CGSize(width: 20, height: 20)
            tSprite.removeFromParent()
            pathNode.addChild(tSprite)
            self.tokenSprite = tSprite
        } else {
            self.tokenSprite = SKSpriteNode()
        }
        
        // token label
        if let tLabel = lineScene.childNode(withName: "lblToken") as? SKLabelNode {
            tLabel.text = "x\(player.countTokens().count)"
            tLabel.removeFromParent()
            pathNode.addChild(tLabel)
            self.tokenLabel = tLabel
        } else {
            self.tokenLabel = SKLabelNode()
        }
        
        // xp sprite
        if let xpSprite = lineScene.childNode(withName: "SKXPSprite") as? SKSpriteNode {
            xpSprite.size = CGSize(width: 20, height: 20)
            xpSprite.removeFromParent()
            pathNode.addChild(xpSprite)
            // tokenSprite.isHidden = true
        }
        // xp label
        if let xpLabel = lineScene.childNode(withName: "lblXP") as? SKLabelNode {
            xpLabel.text = "\(player.experience)"
            xpLabel.removeFromParent()
            pathNode.addChild(xpLabel)
        }
        pathNode.position.x += 8
        pathNode.position.y -= 8
        
        // guild logo
        if let guild = LocalDatabase.shared.serverData?.guildfc {
            let gci = GuildIcon(rawValue: guild.icon)!
            let gimg = PlayerCardNode.makeButton(gci.imageName)?.texture //SKNImage(systemSymbolName: "\(gci.imageName)", accessibilityDescription: nil)!
            if let guildImageSpot = lineScene.childNode(withName: "Guildimage") as? SKSpriteNode {
                guildImageSpot.removeFromParent()
                guildImageSpot.texture = gimg
                pathNode.addChild(guildImageSpot)
            }
        }
        
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
        
        
        super.init()
        
        addChild(pathNode)
        
        // Buttons positions
        let underpY = -(calculateAccumulatedFrame().size.height - 4)
        var underneathPosition:CGPoint = CGPoint(x: CGFloat(margin * 2), y: underpY)
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
    
    /// Updates the PlayerCard UI
    func updatePlayer() {
        let newPlayer = LocalDatabase.shared.player
        nameLabel.text = newPlayer.name
        avatar.texture = SKTexture(imageNamed: newPlayer.avatar)
        moneyLabel.text = "\(GameFormatters.numberFormatter.string(from: NSNumber(value:newPlayer.money)) ?? "---")"
        tokenLabel.text = "\(newPlayer.countTokens().count)"
        
    }
    
    /// Makes a Sprite Node from an image name
    class func makeButton(_ imageName:String) -> SKSpriteNode? {
        guard let image = GameImages.commonSystemImage(name: imageName)?.image(with: SCNColor.white) else {
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
    
    /// Makes a `Default` Label node
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
