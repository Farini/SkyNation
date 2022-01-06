//
//  SideMenuNode.swift
//  SkyNation
//
//  Created by Carlos Farini on 12/24/20.
//

import Foundation
import SpriteKit

class SideMenuNode:SKNode {
    
    /// Size of the Sprite that makes the button (actual size of the button is bigger)
    let buttonSize:CGSize = CGSize(width: 36, height: 36)
    
    let verticalPadding:CGFloat = 2
    
    /// The `SKNode` where camera controls scales down to when dismissing.
    var cameraPlaceholder:SKNode?
    
    enum SideMenuOption {
        case lss
        case camera
        case home
        case guild
        case scene
    }
    
    // Flags
    // -----
    // LSS
    var flagLSS:Int = 0
    var flagLSSLabel:SKLabelNode?
    // GameRoom
    var flagGameRoom:Int = 0
    var flagGameRoomLabel:SKLabelNode?
    // GuildRoom
    var flagGuildRoom:Int = 0
    var flagGuildRoomLabel:SKLabelNode?
    
    override init() {
        super.init()
    }
    
    /// Updates the badges of `LSS`, `GameRoom` and `GuildRoom`
    ///
    /// The `GuildRoom` is not a full update, though.
    func updateLSS(issues:[String]) {
        
        // Update LSS Flags
        flagLSS = issues.count
        if issues.isEmpty {
            flagLSSLabel?.isHidden = true
            flagLSSLabel?.children.first?.isHidden = true
            flagLSSLabel?.text = "\(flagLSS)"
        } else {
            flagLSSLabel?.isHidden = false
            flagLSSLabel?.children.first?.isHidden = false
            flagLSSLabel?.text = "\(flagLSS)"
        }
        
        // Update Game Room Flags
        let player = LocalDatabase.shared.player
        if player.wallet.timeToGenerateNextFreebie() == 0.0 {
            flagGameRoom += 1
            // update label
        }
        if flagGameRoom > 0 {
            flagGameRoomLabel?.isHidden = false
            flagGameRoomLabel?.children.first?.isHidden = false
            flagGameRoomLabel?.text = "\(flagGameRoom)"
        } else {
            flagGameRoomLabel?.isHidden = true
            flagGameRoomLabel?.children.first?.isHidden = true
            flagGameRoomLabel?.text = "\(flagGameRoom)"
        }
        
        if let sd = ServerManager.shared.serverData {
            if sd.guildMap?.mission?.status == .running && sd.guildMap?.mission?.workers.contains(player.playerID ?? UUID()) == false {
                flagGuildRoom += 1
            }
            if sd.election?.getStage() == .running && sd.election?.casted.keys.contains(player.playerID ?? UUID()) == false {
                flagGuildRoom += 1
            }
        }
        if flagGuildRoom > 0 {
            flagGuildRoomLabel?.isHidden = false
            flagGuildRoomLabel?.children.first?.isHidden = false
            flagGuildRoomLabel?.text = "\(flagGuildRoom)"
        } else {
            flagGuildRoomLabel?.isHidden = true
            flagGuildRoomLabel?.children.first?.isHidden = true
            flagGuildRoomLabel?.text = "\(flagGuildRoom)"
        }
    }
    
    /// Dismisses the LSS badge
    func clearLSSBadge() {
        self.flagLSS = 0
        self.updateLSS(issues: [])
    }
    
    /// Dismisses the Guild badge
    func clearGuildBadge() {
        self.flagGuildRoom = 0
        flagGuildRoomLabel?.text = "\(flagGuildRoom)"
        flagGuildRoomLabel?.isHidden = true
        flagGuildRoomLabel?.children.first?.isHidden = true
    }
    
    func clearGameRoomBadge() {
        self.flagGameRoom = 0
        flagGameRoomLabel?.text = "\(flagGameRoom)"
        flagGameRoomLabel?.isHidden = true
        flagGameRoomLabel?.children.first?.isHidden = true
    }
    
    func setupMenu() {
        
        var pos:CGPoint = .zero
        // Side Warning pattern
        
        // adjust X
        pos.x = 20
        
        // Air Control
        if let lssSprite:SKSpriteNode = makeButton(option: .lss) {//makeButton("arrow.3.trianglepath") {
            lssSprite.name = "Air Control"
            lssSprite.color = .white
            lssSprite.colorBlendFactor = 1.0
            lssSprite.anchorPoint = CGPoint.zero
            pos.y -= lssSprite.calculateAccumulatedFrame().size.height
            lssSprite.position = pos
            lssSprite.zPosition = 80
            addChild(lssSprite)
        }
        pos.y -= verticalPadding // pos.y -= 6
        
        // Camera
        if let camSprite:SKSpriteNode = makeButton(option: .camera) {//makeButton("camera.viewfinder") {
            camSprite.name = "CameraIcon"
            camSprite.color = .white
            camSprite.colorBlendFactor = 1.0
            pos.y -= camSprite.calculateAccumulatedFrame().size.height
            camSprite.anchorPoint = CGPoint.zero
            camSprite.position = pos
            camSprite.zPosition = 80
            addChild(camSprite)
        }
        pos.y -= verticalPadding
        
        // Placeholder node
        let holder = SKNode()
        holder.name = "CameraPlaceholder"
        holder.position = pos
        self.cameraPlaceholder = holder
        addChild(holder)
        
        // Changes:
        // 1. Sub lights for Game Room
        // 2. Sub chat sprite for Guild Room
        
        // Lights
        if let lightsSprite:SKSpriteNode = makeButton(option: .home) { //makeButton("house") {
            lightsSprite.name = "GameRoomButton"
            lightsSprite.color = .white
            lightsSprite.colorBlendFactor = 1.0
            pos.y -= lightsSprite.calculateAccumulatedFrame().size.height
            lightsSprite.anchorPoint = CGPoint.zero
            lightsSprite.position = pos
            lightsSprite.zPosition = 80
            addChild(lightsSprite)
        }
        pos.y -= verticalPadding
        
        // Chat
        if let chatSprite:SKSpriteNode = makeButton(option: .guild) { //makeButton("shield") {
            chatSprite.name = "ChatButton"
            chatSprite.color = .white
            chatSprite.colorBlendFactor = 1.0
            pos.y -= chatSprite.calculateAccumulatedFrame().size.height
            chatSprite.anchorPoint = CGPoint.zero
            chatSprite.position = pos
            chatSprite.zPosition = 80
            addChild(chatSprite)
        }
        pos.y -= verticalPadding
        
        // Mars
        if let marsSprite:SKSpriteNode = makeButton(option: .scene) { //makeButton("circle.dashed.inset.fill") {
            marsSprite.name = "MarsButton"
            marsSprite.color = .white
            marsSprite.colorBlendFactor = 1.0
            pos.y -= marsSprite.calculateAccumulatedFrame().size.height
            marsSprite.anchorPoint = CGPoint.zero
            marsSprite.position = pos
            marsSprite.zPosition = 80
            addChild(marsSprite)
        }
        pos.y -= verticalPadding
        
        buildRuler()
    }
    
    func buildRuler() {
        
        // Ruler
        let rulerWidth:CGFloat = 8.0
        let rulerHeight = calculateAccumulatedFrame().size.height
        var pos = CGPoint.zero
        
        let path = CGMutablePath()
        path.move(to: .zero)
        
        // Rectangle
        path.addLine(to: CGPoint(x: rulerWidth, y: 0))
        path.addLine(to: CGPoint(x: rulerWidth, y: -rulerHeight))
        path.addLine(to: CGPoint(x: 0, y: -rulerHeight - rulerWidth))
        path.addLine(to: .zero)
        
        pos.y = -rulerHeight - rulerWidth
        pos.y -= 8
        
        for _ in 1...3 {
            path.move(to: pos)
            path.addLine(to: CGPoint(x:rulerWidth, y:pos.y + 8))
            path.addLine(to: CGPoint(x:rulerWidth, y: pos.y))
            path.addLine(to: CGPoint(x:0, y:pos.y - 8))
            path.addLine(to: CGPoint(x:0, y:pos.y))
            pos.y -= 16
        }
        
        
        let rulerShape = SKShapeNode(path: path)
        rulerShape.position = CGPoint(x: 0, y: 0)
        rulerShape.lineWidth = 0
        rulerShape.fillColor = SCNColor.gray.withAlphaComponent(0.7)
        rulerShape.zPosition = 32
        addChild(rulerShape)
    }
    
    /// Makes a button that is part of the `SideMenu`
    ///
    /// Helps to build the `GameOverlay`
    ///
    /// - parameters:
    ///     - option: the `SideMenuOption` enum that contains that button info.
    ///
    /// - returns:
    ///     The `SKSpriteNode` that represents the button.
    ///
    func makeButton(option:SideMenuOption) -> SKSpriteNode? {
        
        // Get the button image.
        guard let image = GameImages.commonSystemImage(name: option.imageName)?.image(with: SCNColor.white) else {
            return nil
        }
#if os(macOS)
        image.isTemplate = true
        let texture = SKTexture(cgImage: image.cgImage(forProposedRect: nil, context: nil, hints: [:])!)
#else
        let texture = SKTexture(image: image.maskWithColor(color: .white))
#endif
        // Sprite containing main image of the button
        let sprite:SKSpriteNode = SKSpriteNode(texture: texture, color: .white, size: buttonSize)
        
        // Additions
        /*
         Create a background, a label node (indicator), make the button larger, and add a badge. */
        
        var oldSize = sprite.calculateAccumulatedFrame().size
        oldSize.width += 8
        oldSize.height += 8
        
        // Background (Shape Node)
        let spriteBack = SKShapeNode(rect: CGRect(origin: CGPoint.zero, size: oldSize), cornerRadius: 4.0) //SKShapeNode(rectOf: oldSize)
        spriteBack.fillColor = .black.withAlphaComponent(0.5)
        spriteBack.zPosition = sprite.zPosition - 1
        
        sprite.addChild(spriteBack)
        spriteBack.position.x -= 4
        spriteBack.position.y -= 4
        
        // Label (indicator)
        if GameSettings.shared.showLabels == nil || GameSettings.shared.showLabels == true {
            
            let lblText:String = option.labelText
            let lbl = SKLabelNode(text: lblText)
            lbl.fontName = "Helvetica Neue Bold"
            lbl.fontSize = 12
            lbl.fontColor = .white
            lbl.position.x += 43
            lbl.position.y += 26
            lbl.horizontalAlignmentMode = .left
            
            sprite.addChild(lbl)
        }
        
        
        // Badge
        // [SKLabelNode, SKShapeNode]
        /*
         Go through the options.
         LSS, Home, and Guild are the only ones that may have notifications
         */
        var notes:Int = 0
        var shouldMake:Bool = false
        
        switch option {
            case .lss:
                // TODO: Get Data
                notes = flagLSS
                shouldMake = true
            case .camera:
                notes = 0
            case .home:
                // TODO: Get Data
                notes = flagGameRoom
                shouldMake = true
            case .guild:
                // TODO: Get Data
                notes = flagGuildRoom
                shouldMake = true
            case .scene:
                notes = 0
        }
        
        if shouldMake == true {
            
            let badgeLabel = self.makeBadgeLabel()
            badgeLabel.zPosition = 4
            badgeLabel.text = "\(notes)"
            
            let badgeBack = SKShapeNode(circleOfRadius: badgeLabel.calculateAccumulatedFrame().size.height)
            badgeBack.fillColor = .red.withAlphaComponent(0.75)
            badgeBack.strokeColor = .clear
            badgeBack.zPosition = -1
            //badgeBack.addChild(badgeLabel)
            badgeLabel.addChild(badgeBack)
            
            badgeLabel.position.x += 48
            badgeLabel.position.y += 8
            
            if option == .lss {
                self.flagLSSLabel = badgeLabel
            } else if option == .home {
                self.flagGameRoomLabel = badgeLabel
            } else if option == .guild {
                self.flagGuildRoomLabel = badgeLabel
            }
            
            sprite.addChild(badgeLabel)
        }
        
        return sprite
    }
    
    
    func makeBadgeLabel() -> SKLabelNode {
        let badgeLabel = SKLabelNode()
        badgeLabel.fontName = "Helvetica Neue Bold"
        badgeLabel.fontSize = 12
        badgeLabel.fontColor = .white
        badgeLabel.verticalAlignmentMode = .center
        badgeLabel.horizontalAlignmentMode = .center
        return badgeLabel
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


extension SideMenuNode.SideMenuOption {
    
    /// Name for the Image of the button
    var imageName:String {
        switch self {
            case .lss: return "arrow.3.trianglepath"
            case .camera: return "camera.viewfinder"
            case .home: return "house"
            case .guild: return "shield"
            case .scene: return "circle.dashed.inset.fill"
        }
    }
    
    /// The text that represents the button.
    /// Will show when GameSettings have `hudLabels`
    var labelText:String {
        switch self {
            case .lss: return "LSS"
            case .camera: return "Camera"
            case .home: return "Game room"
            case .guild: return "Guild room"
            case .scene: return "Switch scene"
        }
    }
}
