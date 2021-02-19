//
//  GameSettingsView.swift
//  SkyNation
//
//  Created by Carlos Farini on 12/21/20.
//

import SwiftUI

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
            
            Text("Name: \(controller.playerName)")
                .font(.largeTitle)
            Divider()
            
            if controller.isNewPlayer {
                Text("New Player")
                    .foregroundColor(.green)
                    .font(.headline)
            } else {
                Text("Active Player. Last seen: \(GameFormatters.dateFormatter.string(from: controller.player.lastSeen))")
                    .foregroundColor(.green)
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
                Text("ID: \(controller.playerID.uuidString)")
                    .foregroundColor(.gray)
                
                if let string = controller.fetchedString {
                    Text("Fetched:\n\(string)")
                }
                
                if let loggedUser = controller.user {
                    Text("Fetched User: \(loggedUser.name)")
                }
                
                Spacer(minLength: 8)
            }
            
            
            // Player Info
            Group {
                Text("Player Info")
                    .foregroundColor(.gray)
                    .font(.headline)
                
                Text("S$ \(controller.player.money)")
                Text("Tokens: \(controller.player.timeTokens.count)")
                    .foregroundColor(.blue)
                Text("Delivery Tokens: \(controller.player.deliveryTokens.count)")
                    .foregroundColor(.orange)
                
                Divider()
            }
            
            
            HStack {
                if controller.isNewPlayer {
                    Button("Create Player") {
                        controller.createPlayer()
                    }
                } else {
                    if controller.hasChanges {
                        Button("Save Player") {
                            controller.savePlayer()
                        }
                        .disabled(!controller.hasChanges)
                    }
                    
                }
                
//                Button("Fetch Data") {
//                    print("Fetching Data...")
//                    controller.requestInfo()
//                }
                
                // Guild
                if controller.guild == nil {
                    Button("Create Guild") {
                        controller.createGuild()
                    }
                    .buttonStyle(NeumorphicButtonStyle(bgColor:.blue))
                }
                
                // User
                if controller.user != nil {
                    Button("Fetch User") {
                        controller.fetchUser()
                    }
                    .buttonStyle(NeumorphicButtonStyle(bgColor:.blue))
                }
                
                Button("Load Scene") {
                    let builder = LocalDatabase.shared.stationBuilder
                    if let station = LocalDatabase.shared.station {
                        builder.build(station:station)
                    }
                }
                .buttonStyle(NeumorphicButtonStyle(bgColor:.blue))
                
                Button("Start Game") {
                    let note = Notification(name: .startGame)
                    NotificationCenter.default.post(note)
                }
                .buttonStyle(NeumorphicButtonStyle(bgColor:.blue))
            }
        }
        .padding()
    }
    
}

// MARK: - Previews

struct GameSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        GameSettingsView()
    }
}

struct AvatarPicker_Previews: PreviewProvider {
    static var previews: some View {
        AvatarPickerView()
    }
}

// MARK: - Controller

class GameSettingsController:ObservableObject {
    
    @Published var player:SKNPlayer
    @Published var playerName:String {
        didSet {
            if player.name != playerName {
                self.hasChanges = true
            }
        }
    }
    @Published var user:SKNUser?
    @Published var guild:Guild?
    
    @Published var playerID:UUID
    @Published var isNewPlayer:Bool
    @Published var savedChanges:Bool
    @Published var hasChanges:Bool
    
    @Published var fetchedString:String?
    
    init() {
        
        // Player
        if let player = LocalDatabase.shared.player {
            isNewPlayer = false
            self.player = player
            playerID = player.localID
            playerName = player.name
            hasChanges = false
            savedChanges = true
            user = SKNUser(player: player)
            
        } else {
            let newPlayer = SKNPlayer()
            self.player = newPlayer
            playerName = newPlayer.name
            playerID = newPlayer.localID
            isNewPlayer = true
            hasChanges = true
            savedChanges = false
        }
    }
    
    /// Creates a player **Locally**
    func createPlayer() {
        player.name = playerName
        if LocalDatabase.shared.savePlayer(player: player) {
            savedChanges = true
            hasChanges = false
        }
    }
    
    func savePlayer() {
        player.name = playerName
        if LocalDatabase.shared.savePlayer(player: player) {
            savedChanges = true
            hasChanges = false
        }
    }
    
    func requestInfo() {
        SKNS.getSimpleData { (data, error) in
            if let data = data {
                print("We got data: \(data.count)")
                if let string = String(data: data, encoding: .utf8) {
                    self.fetchedString = string
                    return
                }
                let decoder = JSONDecoder()
                if let a = try? decoder.decode([SKNUser].self, from: data) {
                    self.fetchedString = "Users CT: \(a.count)"
                } else {
                    self.fetchedString = "Somthing else happened"
                }
            } else {
                print("Could not get data. Reason: \(error?.localizedDescription ?? "n/a")")
            }
        }
    }
    
    func fetchUser() {
        
        guard let user = user else {
            print("No user")
            return
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        
        SKNS.fetchPlayer(id: self.player.id) { (sknUser, error) in
            if let user = sknUser {
                print("Found user: \(user.id)")
                self.user = user
            } else {
                // Create
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                    return
                } else {
                    print("No User. Creating...")
                    SKNS.createPlayer(localPlayer: user) { (data, error) in
                        if let data = data, let newUser = try? decoder.decode(SKNUser.self, from: data) {
                            print("We got a new user !!!")
                            self.user = newUser
                        }
                    }
                }
            }
        }
    }
    
    func createGuild() {
        guard let user = user else {
            print("No user")
            return
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        
        SKNS.createGuild(localPlayer: user, guildName: "Test Guild") { (data, error) in
            if let data = data, let guild = try? decoder.decode(Guild.self, from: data) {
                print("We got a Guild: \(guild.name)")
                self.guild = guild
            } else {
                print("Failed creating guild. Reason: \(error?.localizedDescription ?? "n/a")")
            }
        }
    }
    
}

// MARK: - Avatar

class AvatarCard: Identifiable, Equatable {
    static func == (lhs: AvatarCard, rhs: AvatarCard) -> Bool {
        return lhs.id == rhs.id
    }
    
    
    var id:UUID = UUID()
//    var img:String
    var name:String
    var selected:Bool
    
    init(name:String) {
        self.id = UUID()
        self.selected = false
        self.name = name
    }
}

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
            
            CarouselView(itemHeight: 200, views: avtViews) { theCard in
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

struct AvatarCardView: View {
    var card:AvatarCard
    var body: some View {
        ZStack {
            Image(card.name)
                .resizable()
                .frame(width: 180, height: card.selected ? 180:200, alignment: .center)
            
        }
        .frame(width: 200, height: 200, alignment: .center)
        .background(GameColors.darkGray)
        
        .cornerRadius(25)
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
//        let pindex = relativeLoc()/views.count
        selectedName = "\(carouselLocation) \(views[carouselLocation].card.name)"
//        didSelect(views[carouselLocation].card)
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
