//  GameConstants.swift
//  SkyNation
//  Created by Carlos Farini on 12/18/20.

import SwiftUI

/**
 General Settings with vars stored in UserDefauls
 */
class GameSettings:Codable {
    
    static let shared = GameSettings.load()
    
    // MARK: - App Modes - Helpers to debug, or run the app with properties
    
    /// Whether to debug Scene objects
    static let debugScene:Bool = false
    static let debugAccounting:Bool = false
    
    /// Whether game should connect to the server, or not
    static let onlineStatus:Bool = true
    
    // MARK: - Data
    
    /// To save in Cloud
    var useCloud:Bool = false
    
    // MARK: - Gameplay Options
    
    /// The scene that starts the game
    var startingScene:GameSceneType
    
    /// Bring up tutorial when game starts
    var showTutorial:Bool
    
    /// Wether the game should automatically clear empty tanks
    var clearEmptyTanks:Bool
    
    /// in auto-merge Tanks get automatically merged in accounting
    var autoMergeTanks:Bool
    
    /// Whether to render more expensive lights
    var showLights:Bool
    
    /// Serves food in biobox to astronauts.. Careful.: This could make you run out of DNA's
    var serveBioBox:Bool
    
    // MARK: - Sounds
    
    var musicOn:Bool
    var soundFXOn:Bool
    var dialogueOn:Bool
    
    // MARK: - Debugging
    
    
    
    private init () {
        
        // Gameplay
        self.showTutorial = true
        self.startingScene = .SpaceStation
        self.showLights = true
        self.clearEmptyTanks = false
        self.autoMergeTanks = true
        self.serveBioBox = false
        
        // Sounds
        self.musicOn = true
        self.soundFXOn = true
        self.dialogueOn = true
        
    }
    static private func load() -> GameSettings {
        return LocalDatabase.loadSettings()
    }
    
    static func create() -> GameSettings {
        return GameSettings()
    }
    
    /// Saves the User `Settings`, or Preferences
    func save() {
        LocalDatabase.shared.saveSettings(newSettings: self)
    }
}


/**
 Main Logic items for the game.
 Use this class to set limits, boundaries, and constraints */
struct GameLogic {
    
    /// The maximum amount of items in a new order (EarthOrder)
    static let earthOrderLimit:Int = 6
    static let orderTankPrice:Int = 10
    static let orderPersonPrice:Int = 150
    
    /// The default `capacity` of a battery
    static let batteryCapacity:Int = 100
    
    /// Amount of air a module requires
    static let airPerModule:Int = 225
    static let energyPerModule:Int = 4
    
    /// Water consumption per `Person`
    static let waterConsumption:Int = 2
    
    /// The default time a `Person` spends studying
    static let personStudyTime:Double = 60.0 * 60.0 * 24.0 * 3.0
    
    /// Cost of building a `BioBox` (Water)
    static let bioBoxWaterConsumption:Int = 3
    
    /// Cost of building a `BioBox` (Energy)
    static let bioBoxEnergyConsumption:Int = 7
    
    /// The time that takes to a `SpaceVehicle` can reach Mars.
    static let vehicleTravelTime:Double = 60.0 * 60.0 * 24 * 3
    
    // MARK: - Functions
    
    static func radiansFrom(_ degrees:Double) -> Double {
        return degrees * .pi/180
    }
    
    static func fibonnaci(index:Int) -> Int {
        guard index > 1 else { return 1 }
        return fibonnaci(index: index - 1) + fibonnaci(index:index-2)
    }
    
    /**
     Calculates chances of an event happening - 100 default total
     - Parameter hit: The chance (divided by total)
     - Parameter total: The amount of trials (100 by default)
     - Returns: Whether the event happens, or not
     */
    static func chances(hit:Double, total:Double? = 100) -> Bool {
        guard let tot = total else { fatalError() }
        let result = Double.random(in: 0.0...tot)
        return result <= hit
    }
    
    // MARK: - Encrypting
    
    static func encrypt(string:String) -> String {
        guard !string.isEmpty else { return "" }
        let data = string.data(using: .utf8)
        if let encodedString = data?.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0)) {
            return encodedString
        }
        return ""
    }
    
    static func decrypt(string:String) -> String {
        guard !string.isEmpty else { return "" }
        if let decoded = Data(base64Encoded: string, options: Data.Base64DecodingOptions(rawValue: 0)).map({ String(data: $0, encoding: .utf8) }) {
            // Convert back to a string
            print("Decoded: \(decoded ?? "")")
            return decoded ?? ""
        }
        return ""
    }
}

/// Date and Number Formatters
struct GameFormatters {
    
    /// A Default Date Formatter
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
    
    /// Longer date formatter
    static let fullDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .long
        return formatter
    }()
    
    /// Default Number Formatter
    static let numberFormatter:NumberFormatter = {
        let format = NumberFormatter()
        format.minimumFractionDigits = 1
        format.maximumFractionDigits = 2
        format.numberStyle = NumberFormatter.Style.decimal
        #if os(macOS)
        format.hasThousandSeparators = true
        #else
        format.usesGroupingSeparator = true
        #endif
        
        return format
    }()
}

// MARK: - File System
/*
class GameFiles {
    
    static let shared = GameFiles()
    
    private init() {
        
    }
    
    static var documentsFolder:URL {
        guard let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else{
            fatalError("Default folder for ap not found")
        }
        return documents
    }
    
    static var appFolder:URL {
        guard let appSupportFolder = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else{
            fatalError("Default folder for ap not found")
        }
        return appSupportFolder
    }
}
*/

// MARK: - Graphics

/// The Colors the game uses
struct GameColors {
    static let greenBackground = Color.green
    static let lightBlue = Color.blue
    static let airBlue = Color("LightBlue")
    static let darkGray = Color("DarkGray")
    
    /// A Black Transluscent color
    static let transBlack = Color.black.opacity(0.7)
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
    
    static func imageForTank() -> Image {
        return Image("Tank")
    }
    
    static var boxImage:Image {
        return Image(systemName: "archivebox")
    }
    
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
    
    static var currencyImage:SKNImage {
        return SKNImage(named: "Currency")!
    }
    
    static var tokenImage:SKNImage {
        return SKNImage(named:"Helmet")!
    }
    
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

// SOUNDS
enum Soundtrack:String, CaseIterable {
    case SKN_T1
    case SKN_T2
    case SKN_T3
}

// MARK: - Notifications

extension Notification.Name {
    
    static let URLRequestFailed  = Notification.Name("URLRequestFailed")        // Any URL Request that fails sends this messsage
    static let DidAddToFavorites = Notification.Name("DidAddToFavorites")       // Add To Favorites Notification
    static let UpdateSceneWithTech = Notification.Name("UpdateSceneWithTech")
    
    /// To Close Views
    static let closeView = Notification.Name("CloseView")
    
    /// To go from Loading screen to Game
    static let startGame = Notification.Name("StartGame")
    
    /// Change Module Properties (Name, Skin, Unbuild)
    static let changeModule = Notification.Name("ChangeModuleProperties")
    
}

struct GameWindow {
    static func closeWindow() {
        NotificationCenter.default.post(Notification(name: .closeView))
    }
}

// MARK: - Errors

enum AddingTrussItemProblem:Error {
    case NoAvailableComponent
    case ItemAlreadyAssigned
    case Invalidated
}

extension AddingTrussItemProblem: LocalizedError {
    var errorDescription: String? {
        switch self {
            case .NoAvailableComponent:
                return NSLocalizedString("No available Truss component", comment: "")
            case .ItemAlreadyAssigned:
                return NSLocalizedString("This item has already been assigned", comment: "")
            case .Invalidated:
                return NSLocalizedString("Unknown error", comment: "")
        }
    }
}


extension TimeInterval {
    
    /// The Time interval that represents 24 hours
    static var oneDay:TimeInterval = 60.0 * 60.0 * 24.0
    
    /// Returns a string with Hours, Minutes and seconds of the TimeInterval value
    func stringFromTimeInterval() -> String {
        
        let time = NSInteger(self)
        
        let seconds = time % 60
        let minutes = (time / 60) % 60
        let hours = (time / 3600)
        
        return String(format: "%dh %0.2dm %0.2ds", hours, minutes, seconds)
        
    }
}
