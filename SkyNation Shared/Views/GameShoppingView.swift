//
//  GameShoppingView.swift
//  SkyNation
//
//  Created by Carlos Farini on 2/17/21.
//

import SwiftUI

struct GameShoppingView: View {
    
    var packages = GameProductType.allCases//GameRawPackage.allCases
    
    var header: some View {
        
        Group {
            HStack() {
                
                VStack(alignment:.leading) {
                    Text("⚙️ Shopping").font(.largeTitle)
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
                
                Text("Shopping").font(.title).foregroundColor(.orange)
                
                ForEach(packages, id:\.self) { package in
                    HStack(spacing: 22) {
                        // Title
                        VStack {
                            Text(package.displayName).foregroundColor(.orange)
//                            Text(package.rawValue.uppercased()).foregroundColor(.orange)
                            Text("$ \(package.moneyAmount)")
                        }
                        
                        Divider()
                        // Stack
                        VStack(alignment:.leading) {
                            HStack {
                                #if os(macOS)
                                Image(nsImage: GameImages.tokenImage)
                                    .resizable()
                                    .frame(width: 32, height: 32, alignment: .center)
                                #else
                                Image(uiImage: GameImages.tokenImage)
                                    .resizable()
                                    .frame(width: 32, height: 32, alignment: .center)
                                #endif
                                
                                Text(" x\(package.tokenAmount)")
                                    .font(.headline)
                            }
                            HStack {
                                #if os(macOS)
                                Image(nsImage: GameImages.currencyImage)
                                #else
                                Image(uiImage: GameImages.currencyImage)
                                #endif
                                Text("$ \(GameFormatters.numberFormatter.string(from: NSNumber(value:package.moneyAmount))!)")
                                    .font(.headline)
                                
                            }
                            
//                            Text("👤 x \(package.peopleAmount)")
                            Text("Token \(package.tokenAmount)")
//                            Text("Tanks \(package.tanksAmount)")
//                            Text("Boxes \(package.boxesAmount)")
                            
                        }
                        // Button
                        VStack {
                            Button(action: {
//                                self.purchasePackage(package: package)
                                self.purchaseProduct(product: package)
                            }, label: {
                                HStack {
                                    Image(systemName: "cart")
                                    Text("Buy")
                                }
                            })
                            .buttonStyle(NeumorphicButtonStyle(bgColor: .orange))
                            
                            generateBarcode(from: LocalDatabase.shared.player?.id ?? UUID())
                        }
                    }
                    Divider()
                }
            }
            
            
        }
    }
    
    // Purchase
    func purchaseProduct(product:GameProductType) {
        
        // Deal with money
        let player = LocalDatabase.shared.player!
        player.money += product.moneyAmount
        player.experience += 1
        
        // Game Message (if want, has to add another achievement type
//        GameMessageBoard.shared.newAchievement(type: ., message: <#T##String?#>)
        
        // FIXME: - Needs receipt and choice of Kit
        
        let newPurchase = Purchase(product: product, kit: .SurvivalKit, receipt: "ABC")
        player.shopped.makePurchase(cart: newPurchase)
        
        // FIXME: - add the kit
        
        let result = LocalDatabase.shared.savePlayer(player: player)
        print("Saved player after purchase.: \(result)")
        
    }
    
    /*
    func purchasePackage(package:GameRawPackage) {
        let player = LocalDatabase.shared.player!
        player.money += package.moneyAmount
        
        // REPLACE THIS FOR THE NEW OBJECT (Shopped R)
//        for _ in 0..<package.tokenAmount {
//            let new = UUID()
//            player.timeTokens.append(new)
//        }
        
        if LocalDatabase.shared.savePlayer(player: player) == true {
            print("Success updating player with new shop")
        }
        // station
        guard let station = LocalDatabase.shared.station else {
            print("Error. No Station")
            return
        }
        // ppl
        for _ in 0...package.peopleAmount {
            let new = Person(random: true)
            if station.addToStaff(person: new) == true {
                // success
            } else {
                // cant add person
            }
        }
        // tanks
        for _ in 0...package.tanksAmount {
            let newType = TankType.allCases.randomElement()!
            let newTank = Tank(type: newType, full: [TankType.co2, TankType.ch4, TankType.empty].contains(newType) ? false:true)
            station.truss.tanks.append(newTank)
        }
        // ingredients'
        for _ in 0...package.boxesAmount {
            let newType = Ingredient.allCases.randomElement()!
            let newBox = StorageBox(ingType: newType, current: [Ingredient.wasteLiquid, Ingredient.wasteSolid].contains(newType) ? 0:newType.boxCapacity())
            station.truss.extraBoxes.append(newBox)
        }
        LocalDatabase.shared.saveStation(station: station)
        
    }
     */
    
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
    /*
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
 */
}

struct GameShoppingView_Previews: PreviewProvider {
    static var previews: some View {
        GameShoppingView()
    }
}
