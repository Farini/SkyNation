//
//  GameSettingsView.swift
//  SkyNation
//  Created by Carlos Farini on 12/21/20.

import SwiftUI
import CoreImage

enum GameSettingsTab: String, CaseIterable {
    
    case Loading            // Loading the scene (can be interrupted)
    case EditingPlayer      // Editing Player Attributes
    case Server             // Checking Server Info
    case Settings           // Going through GameSettings
    
    var tabString:String {
        switch self {
            case .Loading, .Server, .Settings: return self.rawValue
            case .EditingPlayer: return "Player"
        }
    }
}

struct GameSettingsView: View {
    
    @ObservedObject var controller = GameSettingsController()
    
    /// When turned on, this shows the "close" button
    private var inGame:Bool = false
    
    init() {
        print("Initializing Game Settings View")
    }
    
    init(inGame:Bool? = true) {
        self.inGame = true
    }
    
    var header: some View {
        
        Group {
            HStack() {
                VStack(alignment:.leading) {
                    Text("⚙️ Settings").font(.largeTitle)
                    Text("Details")
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // Tutorial
                Button(action: {
                    print("Question ?")
                }, label: {
                    Image(systemName: "questionmark.circle")
                        .font(.title2)
                })
                .buttonStyle(SmallCircleButtonStyle(backColor: .orange))
                
                // Close
                Button(action: {
                    NotificationCenter.default.post(name: .closeView, object: self)
                }) {
                    Image(systemName: "xmark.circle")
                        .font(.title2)
                }.buttonStyle(SmallCircleButtonStyle(backColor: .pink))
                
            }
            .padding([.leading, .trailing, .top], 8)
            
            Divider()
                .offset(x: 0, y: -5)
        }
        
    }
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: nil) {
            
            if (inGame) {
                header
            }
            
            // Segment Control
            Picker("", selection: $controller.viewState) {
                let options = inGame ? [GameSettingsTab.EditingPlayer, GameSettingsTab.Server, GameSettingsTab.Settings]:GameSettingsTab.allCases
                ForEach(options, id:\.self) { tabName in
                    Text(tabName.tabString)
                }
            }.pickerStyle(SegmentedPickerStyle())
            
            
            Divider()
            
            switch controller.viewState {
                
                case .Loading:
                    
                    HStack {
                        Image("\(controller.player.avatar)")
                            .resizable()
                            .frame(width:82, height:82)
                        VStack(alignment:.leading) {
                            Text(controller.player.name)
                            Text("XP: \(controller.player.experience)")
                            Text("Online: \(GameFormatters.dateFormatter.string(from:controller.player.lastSeen))")
                                .foregroundColor(.green)
                            HStack(alignment:.center) {
                                Image(nsImage:GameImages.tokenImage)
                                    .resizable()
                                    .frame(width:32, height:32)
                                Text("x\(controller.player.timeTokens.count)")
                                Divider()
                                Image(nsImage:GameImages.currencyImage)
                                    .resizable()
                                    .frame(width:32, height:32)
                                Text("\(controller.player.money)")
                            }
                            .frame(height:36)
                        }
                        Spacer()
                        generateBarcode(from:controller.player.id)
                    }
                    
                    if controller.isNewPlayer {
                        Text("New Player")
                            .foregroundColor(.orange)
                            .font(.headline)
                    }
                    
                    Group {
                        HStack {
                            Text("Enter name: ")
                            TextField("Name:", text: $controller.playerName)
                                .textFieldStyle(DefaultTextFieldStyle())
                                .padding(4)
                                .frame(width: 100)
                                .cornerRadius(8)
                        }
                        
                        if let string = controller.fetchedString {
                            Text("Fetched:\n\(string)")
                        }
                        
                        if let loggedUser = controller.user {
                            Text("Fetched User: \(loggedUser.name)")
                        }
                        
                        Spacer(minLength: 8)
                    }
                    
                    // Player Info
//                    Group {
//                        Text("Player Info")
//                            .foregroundColor(.gray)
//                            .font(.headline)
//
//                        Text("S$ \(controller.player.money)")
//                        Text("Tokens: \(controller.player.timeTokens.count)")
//                            .foregroundColor(.blue)
//                        Text("Delivery Tokens: \(controller.player.deliveryTokens.count)")
//                            .foregroundColor(.orange)
//
//                        Divider()
//                    }
                case .EditingPlayer:
                    PlayerEditView(controller: controller)
                    
                case .Server:
                    SettingsServerTab(controller:controller)
                case .Settings:
                    GameSettingsTabView()
            }
            
            Divider()
            
            // Buttons Bar
            HStack {
                if controller.isNewPlayer {
                    Button("Create Player") {
                        controller.createPlayer()
                    }
                    .buttonStyle(NeumorphicButtonStyle(bgColor:.blue))
                } else {
//                    if controller.hasChanges {
                        Button("Save Player") {
                            controller.savePlayer()
                        }
                        .buttonStyle(NeumorphicButtonStyle(bgColor:.blue))
                        .disabled(!controller.hasChanges)
//                    }
                    
                }
                
                // Guild
//                if controller.guild == nil {
//                    Button("Create Guild") {
//                        controller.createGuild()
//                    }
//                    .buttonStyle(NeumorphicButtonStyle(bgColor:.blue))
//                }
                
                
                
//                Button("Load Scene") {
//                    let builder = LocalDatabase.shared.stationBuilder
//                    if let station = LocalDatabase.shared.station {
//                        builder.build(station:station)
//                    }
//                }
//                .buttonStyle(NeumorphicButtonStyle(bgColor:.blue))
                
                if (!inGame) {
                    Button("Start Game") {
                        let note = Notification(name: .startGame)
                        NotificationCenter.default.post(note)
                    }
                    .buttonStyle(NeumorphicButtonStyle(bgColor:.blue))
                    .disabled(controller.startGameDisabled())
                }
                
                
            }
        }
        .padding()
        .onAppear() {
            if inGame {
                controller.viewState = .EditingPlayer
            } else {
                controller.loadGameData()
//                self.loadScene()
            }
        }
    }
    
    
//    func loadScene() {
//        let builder = LocalDatabase.shared.stationBuilder
//        if let station = LocalDatabase.shared.station {
//            builder.build(station:station)
//        }
//    }
    
    func generateBarcode(from uuid: UUID) -> Image? {
        let data = uuid.uuidString.prefix(8).data(using: String.Encoding.ascii)
        
        if let filter = CIFilter(name: "CICode128BarcodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            
            if let output:CIImage = filter.outputImage {
                
                if let inverter = CIFilter(name:"CIColorInvert") {
                    
                    inverter.setValue(output, forKey:"inputImage")
                    
                    if let invertedOutput = inverter.outputImage {
                        let rep = NSCIImageRep(ciImage: invertedOutput)
                        let nsImage = NSImage(size: rep.size)
                        nsImage.addRepresentation(rep)
                        return Image(nsImage:nsImage)
                    }
                    
                } else {
                    let rep = NSCIImageRep(ciImage: output)
                    let nsImage = NSImage(size: rep.size)
                    nsImage.addRepresentation(rep)
                    
                    return Image(nsImage:nsImage)
                }
                
                
            }
            
            
//            return NSImage(ciImage: filter.outputImage)
//            let transform = CGAffineTransform(scaleX: 3, y: 3)
//            let out = filter.outputImage?.transformed(by:transform)
//
//            if let output = filter.outputImage?.transformed(by: transform) {
//                let image = NSImage(ciImage:output)
//                return image
//            }
        }
        
        return nil
    }
    
}

// MARK: - Previews

struct GameSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        GameSettingsView()
    }
}

struct GameTabs_Previews: PreviewProvider {
    static var previews:some View {
        
        TabView {
            
            // Server
            SettingsServerTab(controller:GameSettingsController())
                .tabItem {
                    Text("Server")
                }
            
            // Settings
            GameSettingsTabView()
                .tabItem {
                    Text("Settings")
                }
            // Game
            LoadingGameTab()
                .tabItem {
                    Text("Game")
                }
            
            // Player
            PlayerEditView(controller:GameSettingsController())
                .tabItem {
                    Text("Player")
                }
            
            
            
        }
    }
}

/*
struct AvatarPicker_Previews: PreviewProvider {
    static var previews: some View {
        AvatarPickerView()
    }
}
*/


// MARK: - Avatar

class AvatarCard: Identifiable, Equatable {
    
    static func == (lhs: AvatarCard, rhs: AvatarCard) -> Bool {
        return lhs.id == rhs.id
    }
    
    var id:UUID = UUID()
    var name:String
    var selected:Bool
    
    init(name:String) {
        self.id = UUID()
        self.selected = false
        self.name = name
    }
}

//struct AvatarCardView: View {
//    var card:AvatarCard
//    var body: some View {
//        ZStack {
//            Image(card.name)
//                .resizable()
//                .frame(width: 180, height: card.selected ? 180:200, alignment: .center)
//
//        }
//        .frame(width: 200, height: 200, alignment: .center)
//        .background(GameColors.darkGray)
//
//        .cornerRadius(25)
//    }
//}

/*


struct AvatarPickerView:View {
    
    var allNames:[String] // = HumanGenerator().female_avatar_names + HumanGenerator().male_avatar_names
    
    @State var cards:[AvatarCard] = []
    @State var selectedCard:AvatarCard?
    
    var avtViews:[AvatarCardView] = []
    
    init() {
        self.allNames = HumanGenerator().female_avatar_names + HumanGenerator().male_avatar_names
        var newCards:[AvatarCard] = []
        var newViews:[AvatarCardView] = []
        for name in allNames {
            let card = AvatarCard(name: name)
            newCards.append(card)
        }
        for card in newCards {
            let avt = AvatarCardView(card: card)
            newViews.append(avt)
        }
        
        self.cards = newCards
        self.avtViews = newViews
    }
    
    var body: some View {
        VStack {
            Text("Select Avatar").font(.title)
            
            CarouselView(itemHeight: 250
                         , views: avtViews) { theCard in
                print("Selected Avatar: \(theCard.name)")
                self.selectedCard = theCard
            }
            
            Spacer()
        }
        .onAppear() {
            var newCards:[AvatarCard] = []
            
            for name in allNames {
                let card = AvatarCard(name: name)
                newCards.append(card)
            }
            self.cards = newCards
        }
    }
    
    
}



struct CarouselView: View {
    
    @GestureState private var dragState = DragState.inactive
    @State var carouselLocation = 0
    @State var selectedName:String = ""
    
    var itemHeight:CGFloat
    var views:[AvatarCardView]
    
    /// A Closure for this view to respond to its parent
    var chooseWithReturn:(_ card:AvatarCard) -> ()
    
    
    private func onDragEnded(drag: DragGesture.Value) {
        print("drag ended")
        let dragThreshold:CGFloat = 200
        if drag.predictedEndTranslation.width > dragThreshold || drag.translation.width > dragThreshold{
            carouselLocation =  carouselLocation - 1
        } else if (drag.predictedEndTranslation.width) < (-1 * dragThreshold) || (drag.translation.width) < (-1 * dragThreshold)
        {
            carouselLocation =  carouselLocation + 1
        }

        selectedName = "\(carouselLocation) \(views[carouselLocation].card.name)"
        chooseWithReturn(views[carouselLocation].card)
    }
    
    
    
    var body: some View {
        ZStack{
            
            VStack{
                
                ZStack{
                    ForEach(0..<views.count){i in
                        VStack{
                            Spacer()
                            self.views[i]
                                
                                
                                .frame(width:300, height: self.getHeight(i))
                                .animation(.interpolatingSpring(stiffness: 300.0, damping: 30.0, initialVelocity: 10.0))
                                .background(GameColors.transBlack)
                                .cornerRadius(10)
                                .shadow(radius: 3)
                                
                                
                                .opacity(self.getOpacity(i))
                                .animation(.interpolatingSpring(stiffness: 300.0, damping: 30.0, initialVelocity: 10.0))
                                .offset(x: self.getOffset(i))
                                .animation(.interpolatingSpring(stiffness: 300.0, damping: 30.0, initialVelocity: 10.0))
                            Spacer()
                        }
                    }
                    
                }.gesture(
                    
                    DragGesture()
                        .updating($dragState) { drag, state, transaction in
                            state = .dragging(translation: drag.translation)
                            selectedName = "\(carouselLocation) \(views[carouselLocation].card.name)"
                        }
                        .onEnded(onDragEnded)
                    
                )
                
                Spacer()
            }
            VStack{
                Spacer()
                Spacer().frame(height:itemHeight + 50)
//                let pindex = relativeLoc()/views.count
                Text("Name: \(selectedName)")
                Text("\(relativeLoc() + 1)/\(views.count)").padding()
                Spacer()
            }
        }
        .onAppear() {
            selectedName = "\(carouselLocation) \(views[carouselLocation].card.name)"
        }
    }
    
    func relativeLoc() -> Int{
        return ((views.count * 10000) + carouselLocation) % views.count
    }
    
    func getHeight(_ i:Int) -> CGFloat{
        if i == relativeLoc(){
            return itemHeight
        } else {
            return itemHeight - 100
        }
    }
    
    
    func getOpacity(_ i:Int) -> Double{
        
        if i == relativeLoc()
            || i + 1 == relativeLoc()
            || i - 1 == relativeLoc()
            || i + 2 == relativeLoc()
            || i - 2 == relativeLoc()
            || (i + 1) - views.count == relativeLoc()
            || (i - 1) + views.count == relativeLoc()
            || (i + 2) - views.count == relativeLoc()
            || (i - 2) + views.count == relativeLoc()
        {
            return 1
        } else {
            return 0
        }
    }
    
    func getOffset(_ i:Int) -> CGFloat{
        
        //This sets up the central offset
        if (i) == relativeLoc()
        {
            //Set offset of cental
            return self.dragState.translation.width
        }
        //These set up the offset +/- 1
        else if
            (i) == relativeLoc() + 1
                ||
                (relativeLoc() == views.count - 1 && i == 0)
        {
            //Set offset +1
            return self.dragState.translation.width + (300 + 20)
        }
        else if
            (i) == relativeLoc() - 1
                ||
                (relativeLoc() == 0 && (i) == views.count - 1)
        {
            //Set offset -1
            return self.dragState.translation.width - (300 + 20)
        }
        //These set up the offset +/- 2
        else if
            (i) == relativeLoc() + 2
                ||
                (relativeLoc() == views.count-1 && i == 1)
                ||
                (relativeLoc() == views.count-2 && i == 0)
        {
            return self.dragState.translation.width + (2*(300 + 20))
        }
        else if
            (i) == relativeLoc() - 2
                ||
                (relativeLoc() == 1 && i == views.count-1)
                ||
                (relativeLoc() == 0 && i == views.count-2)
        {
            //Set offset -2
            return self.dragState.translation.width - (2*(300 + 20))
        }
        //These set up the offset +/- 3
        else if
            (i) == relativeLoc() + 3
                ||
                (relativeLoc() == views.count-1 && i == 2)
                ||
                (relativeLoc() == views.count-2 && i == 1)
                ||
                (relativeLoc() == views.count-3 && i == 0)
        {
            return self.dragState.translation.width + (3*(300 + 20))
        }
        else if
            (i) == relativeLoc() - 3
                ||
                (relativeLoc() == 2 && i == views.count-1)
                ||
                (relativeLoc() == 1 && i == views.count-2)
                ||
                (relativeLoc() == 0 && i == views.count-3)
        {
            //Set offset -2
            return self.dragState.translation.width - (3*(300 + 20))
        }
        //This is the remainder
        else {
            return 10000
        }
    }
    
    
}

enum DragState {
    case inactive
    case dragging(translation: CGSize)
    
    var translation: CGSize {
        switch self {
            case .inactive:
                return .zero
            case .dragging(let translation):
                return translation
        }
    }
    
    var isDragging: Bool {
        switch self {
            case .inactive:
                return false
            case .dragging:
                return true
        }
    }
}
*/






