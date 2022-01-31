//
//  GameShoppingView.swift
//  SkyNation
//
//  Created by Carlos Farini on 2/17/21.
//

import SwiftUI

// Store Steps
// 1. Choose Product (5, 10, 20)
// 2. Choose Kit
// 3. Make Purchase
// 4. Add to Player + Station

struct GameShoppingView: View {
    
    @ObservedObject var controller:StoreController
    
    
    @State var promoCode:String = ""
    @State private var isValidatingToken:Bool = false
    @State private var validationMessage:String?
    
    var header: some View {
        Group {
            HStack() {
                
                VStack(alignment:.leading) {
                    Label("Shopping", systemImage: "cart").font(GameFont.title.makeFont())
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
        VStack {
            
            header
            
            ScrollView {
                
                switch controller.step {
                    case .product:
                        VStack {
                            
                            if controller.gameProducts.isEmpty {
                                VStack {
                                    Text("Fetching products from App Store")
                                    ProgressView()
                                    Spacer()
                                }
                                
                            } else {
                                HStack(spacing:12) {
                                    
                                    ForEach(controller.gameProducts, id:\.self) { gameProduct in
                                        PackageCardView(productType: gameProduct.type) {
                                            controller.didSelectProduct(gameProduct)
                                        }
                                    }
                                }
                            }
                            
                            Spacer()
                            Divider()
                            
                            /*
                            // Promo Code
                            Button("Promo Code") {
                                controller.step = .promocode
                            }
                            .buttonStyle(GameButtonStyle())
                            .padding(.bottom)
                            */
                        }
                        
                    case .kit(let product):
                        
                        VStack {
                            // Header
                            HStack {
                                Text("Product: \(product.displayName)")
                                    .font(GameFont.section.makeFont())
                                    .foregroundColor(.gray)
                                
                                Text("Select a bonus kit")
                                Spacer()
                            }
                            .padding(.horizontal)
                            
                            GeometryReader { geometry in
                                LazyVGrid(
                                    columns: [GridItem(.fixed(geometry.size.width / 2), spacing:1), GridItem(.fixed(geometry.size.width / 2), spacing:1)],
                                    alignment: .center,
                                    spacing: 12,
                                    pinnedViews: []
                                ) {
                                    ForEach(Purchase.Kit.allCases, id:\.self) { kit in
                                        KitCardView(kit: kit, product: product.type) {
                                            controller.didSelectKit(kit)
                                        }
                                        .modifier(GameSelectionModifier(isSelected: kit == controller.selectedKit))
                                        .onTapGesture {
                                            controller.selectedKit = kit
                                        }
                                    }
                                }
                            }
                            
                            Spacer()
                        }
                        
                    case .buying(let product):
                        
                        VStack {
                            if let message = controller.alertMessage {
                                Text(message).foregroundColor(.orange)
                                    .transition(.slide)
                            }
                            
                            if !controller.errorMessage.isEmpty {
                                Text(controller.errorMessage).foregroundColor(.red)
                                    .transition(.slide)
                            }
                            
                            PurchasingView(product: product, productType: product.type, kit: controller.selectedKit) { didBuy in
                                if didBuy == true {
                                    controller.confirmPurchase()
                                } else {
                                    controller.cancelPurchase()
                                }
                            }
                        }
                        

                    case .receipt:
                        VStack {
                            
                            if !controller.errorMessage.isEmpty {
                                Text(controller.errorMessage).foregroundColor(.red)
                                    .transition(.slide)
                            } else if let message = controller.alertMessage {
                                Text(message).foregroundColor(.orange)
                                    .transition(.slide)
                            } else {
                                Text("Purchase success").foregroundColor(.green)
                            }
                            
                            Image(systemName: "tag.circle").font(.title)
                            
                            Spacer()
                            Divider()
                            
                            Button("Ok") {
                                self.controller.step = .product
                            }
                            .buttonStyle(GameButtonStyle())
                            .padding(.bottom)
                        }
                        
                    case .error(let message):
                        VStack(spacing:8) {
                            Text("Error").font(.title)
                            Text(message).foregroundColor(Color.red)
                            Button("Go back") {
                                controller.cancelPurchase()
                            }
                            .buttonStyle(GameButtonStyle())
                            .padding(.bottom)
                        }
                        
                    case .promocode:
                        ShopPromoInputView(cancelAction: {
                            controller.step = .product
                        })
                        
                }
            }
        }
        .frame(minWidth: 620, idealWidth: 620, maxWidth: 800, minHeight:400, maxHeight:700, alignment: .top)
    }
    
}

/// View that represents a `GameProductType` object
struct PackageCardView:View {
    
    var productType:GameProductType
    var action:(() -> Void)
    
    var body: some View {
        
        VStack(spacing: 8) {
            
            Label(productType.displayName, systemImage: "bag")
                    .font(GameFont.section.makeFont())
            .padding(.top, 8)
            
            
            Divider()
            
            HStack {
                tokenImage()
                    .resizable()
                    .frame(width: 26, height: 26, alignment: .center)
                
                Text("x\(productType.tokenAmount) ")
                    .font(GameFont.section.makeFont())
                Spacer()
            }
            .padding(.leading)
            
            HStack {
                currencyImage()
                    .resizable()
                    .frame(width: 26, height: 26, alignment: .center)
                
                Text("\(GameFormatters.currency.string(from: NSNumber(value:productType.moneyAmount))!)")
                    .font(GameFont.section.makeFont())
                Spacer()
            }
            .padding(.leading)
            
            HStack {
                Image(systemName: "arrow.right.to.line.circle")
                    .resizable()
                    .frame(width: 26, height: 26, alignment: .center)
                    .font(Font.system(size: 16, weight: .light, design: .default))
                Text("2 Entry Tokens")
                Spacer()
            }
            .padding(.leading)
            
            Divider()
            
            VStack(alignment:.center) {
                Label("\(GameFormatters.currency.string(from: NSNumber(value:productType.fakePrice)) ?? "---")", systemImage:"tag")
                    .font(GameFont.section.makeFont())
            }
            Divider()
            
            Button("Get it") {
                print("get")
                self.action()
            }
            .buttonStyle(GameButtonStyle())
            .padding([.bottom], 8)
            
        }
        .frame(width:185)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(lineWidth: 2))
        // .background(LinearGradient(colors: [Color.black.opacity(0.1), Color.black.opacity(0.4), Color.black.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing))
        .cornerRadius(8)
        
        
    }
    
    func tokenImage() -> Image {
#if os(macOS)
        return Image(nsImage: GameImages.tokenImage)
#else
        return Image(uiImage: GameImages.tokenImage)
#endif
    }
    
    func currencyImage() -> Image {
#if os(macOS)
        return Image(nsImage: GameImages.currencyImage)
#else
        return Image(uiImage: GameImages.currencyImage)
#endif
    }
}

/// View that represents a `Purchase.Kit` object
struct KitCardView:View {
    
    var kit:Purchase.Kit
    var product:GameProductType
    var action:(() -> Void)
    
    private let columns: [GridItem] = [
        GridItem(.fixed(110), spacing: 16),
        GridItem(.fixed(110), spacing: 16)
    ]
    
    var body: some View {
        
        VStack(alignment:.leading) {
            
            HStack {
                Label(kit.displayName, systemImage: kit.imageName)
                    .font(GameFont.section.makeFont())
                Spacer()
                Button("Get it") {
                    action()
                }
                .buttonStyle(GameButtonStyle())
                //.padding(.bottom, 6)
                
            }
            
            Divider()
            
            // Tanks
            HStack(spacing:8) {
                GameImages.imageForTank()
                    .resizable()
                    .frame(width: 20, height: 20, alignment: .center)
                ForEach(kit.tanks.sorted(by: {$0.value > $1.value}), id:\.key) { k, v in
                    Text("\(k.rawValue.uppercased()): \(v * product.rawValue)")
                }
                if kit.tanks.isEmpty {
                    Text("No tanks").foregroundColor(.gray)
                }
            }
            
            
            // Boxes
            HStack(spacing:4) {
                GameImages.boxImage
                    .resizable()
                    .frame(width:16, height: 16, alignment: .center)
                ForEach(kit.boxes.sorted(by: { $0.value > $1.value }), id:\.key) { k, v in
                    ZStack {
                        (k.image() ?? Image(systemName: "questionmark"))
                            .resizable()
                            .frame(width: 42, height: 42)
                        Text("\(v * product.rawValue)")
                            .padding(2)
                            .foregroundColor(.orange)
                            .background(Color.black.opacity(0.5))
                            .offset(x: 0, y: +10)
                    }
                    
                }
                if kit.boxes.isEmpty {
                    Text("No boxes").foregroundColor(.gray)
                }
            }
        }
        .padding(.horizontal)
        .frame(minWidth:220, maxWidth:240, minHeight:120, maxHeight:160)
    }
}

struct PurchasingView:View {
    
    var product:GameProduct?
    var productType:GameProductType
    var kit:Purchase.Kit?
    
    /// The responding action when user clicks "buy"
    var buyAction:((Bool) -> Void)
    
    @State private var isSpinningWheel:Bool = true
    
    var body: some View {
        
        VStack {
            
            VStack(spacing:8) {
                
                HStack {
                    Image(systemName: "cart").font(.largeTitle)
                    Text("Review Purchase").font(GameFont.title.makeFont())
                }
                .padding(.bottom, 8)
                
                if isSpinningWheel {
                    ProgressView()
                        .padding(.bottom, 8)
                        .hueRotation(Angle(degrees: 30))
                        .transition(.asymmetric(insertion: .opacity.combined(with: .move(edge: Edge.leading)), removal: .slide.combined(with: .scale)))
                } else {
                    EmptyView().frame(height:32)
                }
            }
            .padding(.vertical, 8)
            
            Divider()
            
            VStack(spacing:8) {
                Text("Product Info:")
                    .font(GameFont.section.makeFont())
                
                if let product = product {
//                    Text("Product ID: \(product.id)")
                    Text("Product Price: \(product.priceString)").foregroundColor(.orange)
                    
                    
                } else {
                    Text("Fake Product. PREVIEW MODE").foregroundColor(.red)
                    Text("Product ID: \(productType.storeIdentifier)")
                    Text("Product Price: \(GameFormatters.currency.string(from: NSNumber(value:productType.fakePrice)) ?? "n/a")")
                        .foregroundColor(.orange)
                }
                
                Divider()
                
                Text("Rewards")
                    .font(GameFont.section.makeFont())
                    .foregroundColor(GameColors.airBlue)
                
                if let product = product {
                    Text("Tokens: \(product.type.tokenAmount)").foregroundColor(.orange)
                    Text("Sky Coins: \(product.type.moneyAmount)").foregroundColor(.orange)
                }
                
                if let kit = kit {
                    Text("Bonus").font(GameFont.section.makeFont()).foregroundColor(.green)

                    Text("Tanks").foregroundColor(.blue)
                    Text("\(iterateTanks(kit))")

                    Text("Boxes").foregroundColor(.blue)
                    Text("\(iterateBoxes(kit))")
                }
            }
            
            Spacer()
            Divider()
            
            HStack {
                
                Button {
                    buyAction(false)
                } label: {
                    Label("Cancel", systemImage: "nosign")
                }
                .buttonStyle(GameButtonStyle(labelColor: .red))
                
                Button {
                    buyAction(true)
                } label: {
                    Label("Buy", systemImage: "suitcase.cart.fill")
                }
                .buttonStyle(GameButtonStyle(labelColor: .green))
                
            }
            .padding(.bottom)
        }
        .onAppear {
            DispatchQueue.init(label: "Wheel").asyncAfter(deadline: .now() + 2) {
                self.toggleWheel()
            }
        }
    }
    
    func toggleWheel() {
        DispatchQueue.main.async {
            self.isSpinningWheel.toggle()
        }
    }
    
    func iterateTanks(_ kit:Purchase.Kit) -> String {
        var string = ""
        for (k, v) in kit.tanks {
            string += "\(k.name) x \(v) \t"
        }
        return string
    }
    
    func iterateBoxes(_ kit:Purchase.Kit) -> String {
        var string = ""
        for (k, v) in kit.boxes {
            string += "\(k.rawValue) x \(v) \t"
        }
        return string
    }
    
    func makeThis(type:TankType, val:Int) -> String {
        return String("\(type.name) x \(val)")
    }
}

// MARK: - Previews

struct GameShoppingView_Previews: PreviewProvider {
    static var previews: some View {
        GameShoppingView(controller: StoreController())
//        KitCardView(kit: .SurvivalKit, product: .ten, action: {})
//        PackageCardView(productType: .ten, action: {})
        PurchasingView(product: nil, productType: .ten) { buyAction in
            print("buy action: \(buyAction)")
        }
    }
    
    static var controller:StoreController = StoreController()
}

extension Purchase.Kit {
    var imageName:String {
        switch self {
            case .SurvivalKit: return "flashlight.on.fill"
            case .BotanistGarden: return "leaf.fill"
            case .Humanitarian: return "staroflife.fill"
            case .BuildersTech: return "wrench.and.screwdriver.fill"
        }
    }
    
    var color:Color {
        switch self {
            case .SurvivalKit: return Color.red
            case .BotanistGarden: return Color.green
            case .Humanitarian: return Color.orange
            case .BuildersTech: return Color.blue
        }
    }
}
