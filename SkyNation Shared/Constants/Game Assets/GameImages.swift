//
//  GameImages.swift
//  SkyNation
//
//  Created by Carlos Farini on 8/18/21.
//

import SwiftUI

#if os(macOS)
public typealias SKNImage = NSImage
public typealias SCNColor = NSColor
#else
public typealias SKNImage = UIImage
public typealias SCNColor = UIColor
#endif

#if os(iOS)
extension UIImage {
    public func maskWithColor(color: UIColor) -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        let context = UIGraphicsGetCurrentContext()!
        
        let rect = CGRect(origin: CGPoint.zero, size: size)
        
        color.setFill()
        self.draw(in: rect)
        
        context.setBlendMode(.sourceIn)
        context.fill(rect)
        
        let resultImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return resultImage
    }
}
#endif

/// The Colors the game uses
struct GameColors {
    static let greenBackground = Color.green
    static let lightBlue = Color.blue
    static let airBlue = Color("LightBlue")
    static let darkGray = Color("DarkGray")
    
    /// A Black Transluscent color
    static let transBlack = Color.black.opacity(0.7)
    
    /// The color options for the Guilds
    static let guildColors:[GuildColor] = GuildColor.allCases
    
    /// Conveniently get the color for SwiftUI
    static func colorOfGuild(guild:GuildSummary) -> Color {
        return GuildColor(rawValue: guild.color)!.color
    }
}


/// Images used by the game
struct GameImages {
    
    /// A SwiftUI Image for a given Skill
    static func imageForSkill(skill:Skills) -> Image {
        switch skill {
            case .Biologic: return Image("SkillBio")
            case .Datacomm: return Image("SkillData")
            case .Electric: return Image("SkillElectric")
            case .Material: return Image("SkillMaterial")
            case .Mechanic: return Image("SkillMechanic")
            case .Medic: return Image("SkillMedic")
            case .SystemOS: return Image("SkillSystems")
            case .Handy: return Image(systemName: "hand.wave.fill")
        }
    }
    
    /// A SwiftUI Image for a Tank
    static func imageForTank() -> Image {
        return Image("Tank")
    }
    
    /// A SwiftUI Image for a Box
    static var boxImage:Image {
        return Image(systemName: "archivebox")
    }
    
    /// Convenient Method to get an image from `SFFonts`
    static func commonSystemImage(name:String) -> SKNImage? {
        #if os(macOS)
        guard let im = NSImage(systemSymbolName: name, accessibilityDescription: name) else { return nil }
        im.isTemplate = true
        return im as SKNImage
        #else
        guard let image = UIImage(systemName: name)?.withTintColor(.white) else { fatalError() }
        return image.maskWithColor(color: .white)
        #endif
    }
    
    /// An image for the SkyCoins (money)
    static var currencyImage:SKNImage {
        return SKNImage(named: "Currency")!
    }
    
    /// An image for the Token
    static var tokenImage:SKNImage {
        return SKNImage(named:"Helmet")!
    }
    
    /// Generates a Barcode in SwiftUI
    static func generateBarcode(from uuid: UUID) -> Image? {
        let data = uuid.uuidString.prefix(8).data(using: String.Encoding.ascii)
        
        if let filter = CIFilter(name: "CICode128BarcodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            
            if let output:CIImage = filter.outputImage {
                
                if let inverter = CIFilter(name:"CIColorInvert") {
                    
                    inverter.setValue(output, forKey:"inputImage")
                    
                    if let invertedOutput = inverter.outputImage {
                        #if os(macOS)
                        let rep = NSCIImageRep(ciImage: invertedOutput)
                        let nsImage = NSImage(size: rep.size)
                        nsImage.addRepresentation(rep)
                        return Image(nsImage:nsImage)
                        #else
                        let uiImage = UIImage(ciImage: invertedOutput)
                        return Image(uiImage: uiImage)
                        #endif
                    }
                    
                } else {
                    #if os(macOS)
                    let rep = NSCIImageRep(ciImage: output)
                    let nsImage = NSImage(size: rep.size)
                    nsImage.addRepresentation(rep)
                    return Image(nsImage:nsImage)
                    #else
                    let uiimage = UIImage(ciImage: output)
                    return Image(uiImage: uiimage)
                    #endif
                }
            }
        }
        
        return nil
    }
}

extension SKNImage {
    
    /** Convenience method to turn a BW image into a Colored Image */
    func image(with tintColor: SCNColor) -> SKNImage {
        
        #if os(macOS)
        if self.isTemplate == false {
            return self
        }
        
        let image = self.copy() as! NSImage
        image.lockFocus()
        
        tintColor.set()
        
        let imageRect = NSRect(origin: .zero, size: image.size)
        imageRect.fill(using: .sourceIn)
        
        image.unlockFocus()
        image.isTemplate = false
        
        return image
        
        #else // iOS
        
        let image = self.copy() as! UIImage
        return image.withTintColor(tintColor, renderingMode: .alwaysTemplate)
        
        #endif
    }
}
