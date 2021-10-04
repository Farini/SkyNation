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
    
//    @State var step:ShoppingStep = .product
    @State var promoCode:String = ""
    @State private var isValidatingToken:Bool = false
    @State private var validationMessage:String?
    
//    var packages = GameProductType.allCases//GameRawPackage.allCases
    
    
    var header: some View {
        Group {
            HStack() {
                
                VStack(alignment:.leading) {
                    Text("⚙️ Shopping (\(controller.step.displayName))").font(.largeTitle)
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
        VStack {
            
            header
            
            ScrollView {
                
                switch controller.step {
                    case .product:
                        
                        // Promo Code
                        VStack(alignment:.leading, spacing:4) {
                            Text("Enter promo code:")
                            HStack {
                                if isValidatingToken {
                                    ProgressView()
                                }
                                TextField("Promo Code", text: $promoCode)
                                    .padding(.trailing, 20)
                                Button("Verify") {
                                    print("Verifying Promo code: \(promoCode)")
                                    self.validateToken()
                                }
                                .buttonStyle(NeumorphicButtonStyle(bgColor: .white))
                                .disabled(isValidatingToken)
                            }
                            if let msg = self.validationMessage {
                                Text(msg)
                            }
                        }
                        .padding(.horizontal)
                        
                        Divider()
                        
                        if controller.gameProducts.isEmpty {
                            Text("Fetching products from App Store")
                            ProgressView()
                        } else {
                            ForEach(controller.gameProducts, id:\.self) { gameProduct in
                                ShopProductRow(product: gameProduct.type)
                                    .onTapGesture {
                                        controller.didSelectProduct(gameProduct)
                                    }
                                
                                Divider()
                            }
                        }
                        
                    case .kit(let product):
                    VStack {
                        Text("Show the Kits")
                        ForEach(Purchase.Kit.allCases, id:\.self) { kit in
                            // Text(kit.rawValue).font(.title)
                            ShopKitRow(kit: kit, product: product.type)
                                .onTapGesture {
//                                    self.purchaseProduct(product: product, kit: kit)
                                    controller.didSelectKit(kit)
                                }
                            
                            // Color
                            // Gradient
                            // Description
                            // Items
                            // Image
                            // Button (select)
                        }
                    }
                        
                    case .buying(let product):
                        
                        VStack {
                            Text("App Store").font(.largeTitle)
                            Image(systemName: "creditcard").font(.title)
                            
                            ProgressView()
                            
                            Divider()
                            
                            Text("Product Info:")
                            Text("ID: \(product.id)")
                            Text("Price: \(product.priceString)").foregroundColor(.orange)
                            
                            HStack {
                                Button("Buy") {
                                    controller.confirmPurchase()
                                }
                                .disabled(controller.selectedProduct == nil)
                                
                                Button("Cancel") {
                                    controller.cancelPurchase()
                                }
                            }
                        }
                    case .receipt:
                        VStack {
                            Text("Receipt").font(.largeTitle)
                            Image(systemName: "tag.circle").font(.largeTitle)
                        }
                        
                    case .error(let message):
                        VStack {
                            Text("Error")
                            Text(message).foregroundColor(Color.red)
                            Button("Go back") {
                                controller.cancelPurchase()
                            }
                        }
                }
            }
        }
        .frame(minWidth: 500, idealWidth: 600, maxWidth: 800, minHeight:400, maxHeight:700, alignment: .top)
    }
    
    /*
    func nextStep() {
        switch step {
            case .product: self.step = .kit
            case .kit: self.step = .appStore
            case .appStore: self.step = .receipt
            case .receipt: self.step = .product
        }
    }
    */
    
    // Token Validation
    func validateToken() {
        
        guard !promoCode.isEmpty else { return }
        self.isValidatingToken = true
        
        SKNS.validateTokenFromTextInput(text: self.promoCode) { token, errorString in
            if let token = token {
                print("Got a token: \(token.id)")
                let player = LocalDatabase.shared.player
                player.wallet.tokens.append(token)
                
                // Save
                do {
                    try LocalDatabase.shared.savePlayer(player)
                } catch {
                    print("‼️ Could not save station.: \(error.localizedDescription)")
                }
                
//                let r = LocalDatabase.shared.savePlayer(player: player)
//                print("Saved Player after getting token: \(r)")
                DispatchQueue.main.async {
                    self.validationMessage = "You got an Entry token to Mars !"
                    self.isValidatingToken = false
                }
            } else {
                print("Could not get a token")
                if let string = errorString {
                    DispatchQueue.main.async {
                        self.validationMessage = "Not a valid token. \(string)"
                        self.isValidatingToken = false
                    }
                } else {
                    DispatchQueue.main.async {
                        self.validationMessage = "Invalid token."
                        self.isValidatingToken = false
                    }
                }
            }
        }
    }
    
    // Purchase
    
    
    // Barcode
    
    func generateBarcode(from uuid: UUID) -> Image? {
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

struct ShopKitRow:View {
    
    var kit:Purchase.Kit
    var product:GameProductType
    
    var body: some View {
        HStack {
            VStack {
//                Text("Kit")
                ZStack(alignment: .top) {
                    
                    Rectangle()
                        .foregroundColor(.clear)
                        .background(LinearGradient(gradient: Gradient(colors: [Color.clear, kit.color.opacity(0.5)]), startPoint: .bottom, endPoint: .top))
                        .frame(height:64)
                    
                    HStack {
                        VStack {
                            Text(kit.displayName).font(.title)
                            Image(systemName: kit.imageName)
                                .font(.largeTitle)
                        }
                        .padding()
                        
                        Spacer()
                        
                        VStack(alignment:.leading) {
                            
                            // Tanks
                            HStack {
                                GameImages.imageForTank()
                                    .resizable()
                                    .frame(width: 20, height: 20, alignment: .center)
                                ForEach(kit.tanks.sorted(by: {$0.value > $1.value}), id:\.key) { k, v in
                                    Text("\(k.rawValue.uppercased()): \(v * product.rawValue)")
                                }
                            }
                            
                            // Ingredients
                            HStack {
                                GameImages.boxImage
                                    .resizable()
                                    .frame(width:20, height: 20, alignment: .center)
                                ForEach(kit.boxes.sorted(by: { $0.value > $1.value }), id:\.key) { k, v in
                                    Text("\(k.rawValue.uppercased()): \(v * product.rawValue)")
                                }
                            }
                            
                        }
                        
                        Spacer()
                        
                        HStack {
                            Text("Next")//.padding(.top, 6)
                            Image(systemName: "chevron.right").font(.title)
                            
                        }
                        .padding(.trailing, 8)
                    }
                    
                }
                
                
                // Color
                // Gradient
                // Description
                // Items
                // Image
                // Button (select)
            }
            
        }
    }
}

struct ShopProductRow: View {
    
    var product:GameProductType
    
    var body: some View {
        // Product Row
        HStack(spacing: 22) {
            
            // Title
            VStack {
                Image(systemName: "bag")
                    .font(.largeTitle)
                    .padding(6)
                
                Text(product.displayName)
                    .foregroundColor(.orange)
                    .font(.title2)
                
                //                            Text(package.rawValue.uppercased()).foregroundColor(.orange)
                //                            Text("$ \(package.moneyAmount)")
            }
            .frame(width:120)
            
            Divider()
            
            // Benefits
            VStack(alignment:.leading) {
                
                // Tokens
                HStack {
                    
                    #if os(macOS)
                    Image(nsImage: GameImages.tokenImage)
                        .resizable()
                        .frame(width: 28, height: 28, alignment: .center)
                    #else
                    Image(uiImage: GameImages.tokenImage)
                        .resizable()
                        .frame(width: 28, height: 28, alignment: .center)
                    #endif
                    
                    Text("x\(product.tokenAmount) ")
                        .font(.headline)
                }
                
                // Sky Coins
                HStack {
                    #if os(macOS)
                    Image(nsImage: GameImages.currencyImage)
                        .resizable()
                        .frame(width: 28, height: 28, alignment: .center)
                    #else
                    Image(uiImage: GameImages.currencyImage)
                        .resizable()
                        .frame(width: 28, height: 28, alignment: .center)
                    #endif
                    Text("$ \(GameFormatters.numberFormatter.string(from: NSNumber(value:product.moneyAmount))!)")
                        .font(.headline)
                    
                }
                
                Text("Token \(product.tokenAmount)")
            }
            .frame(width:150)
            
            Divider()
            
            // Button
            VStack {
                //                            Button(action: {
                ////                                self.purchasePackage(package: package)
                //                                self.purchaseProduct(product: package)
                //                            }, label: {
                //                                HStack {
                //                                    Image(systemName: "cart")
                //                                    Text("Buy")
                //                                }
                //                            })
                //                            .buttonStyle(NeumorphicButtonStyle(bgColor: .orange))
                
                generateBarcode(from: LocalDatabase.shared.player.id)
            }
            
            // Chevron
            Image(systemName: "chevron.right").font(.largeTitle)
        }
    }
    
    func generateBarcode(from uuid: UUID) -> Image? {
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

struct GameShoppingView_Previews: PreviewProvider {
    static var previews: some View {
        GameShoppingView(controller: StoreController())
        ShopKitRow(kit: .SurvivalKit, product: .five)
    }
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
