//  GameConstants.swift
//  SkyNation
//  Created by Carlos Farini on 12/18/20.

import SwiftUI

/**
 General Settings with vars stored in UserDefauls
 */
class GameSettings {
    
    static let shared = GameSettings()
    
    // MARK: - Data
    
    /// To save in Cloud
    var useCloud:Bool = false
    
    
    // MARK: - Game Logic
    
    /// The scene that starts the game
    var startingScene:GameSceneType
    
    /// Bring up tutorial when game starts
    var showTutorial:Bool
    
    /// Wether the game should automatically clear empty tanks
    var clearEmptyTanks:Bool = false
    
    /// Whether to render more expensive lights
    var showLights:Bool = true
    
    // MARK: - Sounds
    
    var musicOn:Bool
    var soundFXOn:Bool
    var dialogueOn:Bool
    
    // MARK: - Debugging
    
    /// Whether to debug Scene objects
    var debugScene:Bool = false
    var debugAccounting:Bool = false
    
    private init () {
        
        // Tutorial
        var shouldShowTutorial:Bool = true
        if let theVal = UserDefaults.standard.value(forKey: "showTutorial") as? Bool {
            shouldShowTutorial = theVal
        } else {
            if let station = LocalDatabase.shared.station {
                if let mod = station.habModules.first {
                    if mod.inhabitants.isEmpty {
                        print("No Inhabitants")
                    } else {
                        // Disable Tutorial
                        shouldShowTutorial = false
                    }
                }
            }
        }
        
        // Gameplay
        self.showTutorial = shouldShowTutorial
        self.startingScene = .SpaceStation
        self.showLights = UserDefaults.standard.value(forKey: "showLights") as? Bool ?? true
        self.clearEmptyTanks = UserDefaults.standard.value(forKey: "clearEmptyTanks") as? Bool ?? false
        
        // Sounds
        self.musicOn = UserDefaults.standard.value(forKey: "musicOn") as? Bool ?? true
        self.soundFXOn = UserDefaults.standard.value(forKey: "soundFXOn") as? Bool ?? true
        self.dialogueOn = UserDefaults.standard.value(forKey: "dialogueOn") as? Bool ?? true
        
    }
    
    /// Saves the User `Settings`, or Preferences
    func save() {
        UserDefaults.standard.setValue(self.showTutorial, forKey: "showTutorial")
        UserDefaults.standard.setValue(self.useCloud, forKey: "useCloud")
        // Gameplay
        UserDefaults.standard.setValue(self.startingScene, forKey: "startingScene")
        UserDefaults.standard.setValue(self.clearEmptyTanks, forKey: "clearEmptyTanks")
        UserDefaults.standard.setValue(self.showLights, forKey: "showLights")
        // Sounds
        UserDefaults.standard.setValue(self.musicOn, forKey: "musicOn")
        UserDefaults.standard.setValue(self.soundFXOn, forKey: "soundFXOn")
        UserDefaults.standard.setValue(self.dialogueOn, forKey: "dialogueOn")
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
    
    /// Cost of building a `BioBox` (Water)
    static let bioBoxWaterConsumption:Int = 3
    /// Cost of building a `BioBox` (Energy)
    static let bioBoxEnergyConsumption:Int = 7
    
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

// MARK: - Shopping

enum GameRawPackage:String, Codable, CaseIterable {
    
    case fiveDollars
    case tenDollars
    case twentyDollars
    
    var tokenAmount:Int {
        switch self {
            case .fiveDollars: return 5
            case .tenDollars: return 10
            case .twentyDollars: return 20
        }
    }
    
    var moneyAmount:Int {
        switch self {
            case .fiveDollars: return 150000
            case .tenDollars: return 320000
            case .twentyDollars: return 750000
        }
    }
    
    var boxesAmount:Int {
        switch self {
            case .fiveDollars: return 5
            case .tenDollars: return 12
            case .twentyDollars: return 25
        }
    }
    
    var tanksAmount:Int {
        switch self {
            case .fiveDollars: return 8
            case .tenDollars: return 18
            case .twentyDollars: return 45
        }
    }
    
    var peopleAmount:Int {
        switch self {
            case .fiveDollars: return 2
            case .tenDollars: return 5
            case .twentyDollars: return 12
        }
    }
    
    var gamePackage:GamePackage {
        
        let tokens = tokenAmount
        let money = moneyAmount
        let boxAmt = boxesAmount
        let tankAmt = tanksAmount
        let staffAmount = peopleAmount
        
        
        let boxes = generateBoxes(amt: boxAmt)
        let tanks = generateTanks(amt: tankAmt)
        let ppl = generateNewPeople(amt: staffAmount)
        
        return GamePackage(id: UUID(), tokens: tokens, money: money, boxes: boxes, tanks: tanks, staff: ppl)
    }
    
    func generateBoxes(amt:Int) -> [StorageBox] {
        var boxes:[StorageBox] = []
        for _ in 0...amt {
            let newType = Ingredient.allCases.randomElement()!
            var newVar = newType.boxCapacity()
            if [Ingredient.wasteSolid, Ingredient.wasteLiquid, Ingredient.Battery].contains(newType) {
                // Set current to zero (for some cases)
                newVar = 0
            }
            let newBox = StorageBox(ingType: newType, current: newVar)
            boxes.append(newBox)
        }
        return boxes
    }
    
    func generateTanks(amt:Int) -> [Tank] {
        var tanks:[Tank] = []
        for _ in 0...amt {
            let newType = TankType.allCases.randomElement()!
            var newVar = newType.capacity
            if [TankType.co2, TankType.ch4].contains(newType) {
                newVar = 0
            }
            let newTank = Tank(type: newType, full: newVar == 0 ? false:true)
            tanks.append(newTank)
        }
        return tanks
    }
    
    func generateNewPeople(amt:Int) -> [Person] {
        var people:[Person] = []
        for _ in 0...amt {
            let newPerson = Person(random: true)
            newPerson.intelligence = max(80, newPerson.intelligence)
            newPerson.happiness = 100
            newPerson.healthPhysical = 100
            
            while newPerson.skills.count < 4 {
                let newSkill = Skills.allCases.randomElement()!
                if let idx = newPerson.skills.firstIndex(where: { $0.skill == newSkill }) {
                    newPerson.skills[idx].level += 1
                } else {
                    newPerson.skills.append(SkillSet(skill: newSkill, level: 1))
                }
            }
            people.append(newPerson)
        }
        return people
    }
    
}

/// A Package that can be purchased at the store
struct GamePackage {
    
    var id:UUID
    var tokens:Int
    var money:Int
    var boxes:[StorageBox]
    var tanks:[Tank]
    var staff:[Person]
    
    static func makePackage(price:Int) -> GamePackage {
        let new = GamePackage(id: UUID(), tokens: price, money: price * 1000, boxes: [], tanks: [], staff: [])
        return new
    }
    
}

// EDL - Entry Descent and Landing
