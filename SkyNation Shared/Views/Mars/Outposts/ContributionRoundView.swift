//
//  ContributionRoundView.swift
//  SkyNation
//
//  Created by Carlos Farini on 9/21/21.
//

import SwiftUI

struct ContributionRoundView: View {
    
    @ObservedObject var controller:OutpostController
    
    @Binding var contribRound:OutpostSupply
    
    @State var deliveryError:String = ""
    
    var player = LocalDatabase.shared.player ?? SKNPlayer()
    
    let shouldFake:Bool = true
    
    var body: some View {
        
        VStack {
            
            Group {
                
                PlayerCardView(pCard: PlayerCard(playerContent: PlayerContent(player: self.player)))
                Divider()
                    .frame(width:150)
                
                Text(deliveryError).foregroundColor(.red)
                    .onChange(of: controller.deliveryError) { newValue in
                        self.deliveryError = newValue
                    }
            }
            
            Text("Contribution Round").font(.title2).foregroundColor(.orange)
            
            // Items
            Group {
                
                // Ingredients
                ForEach(contribRound.ingredients) { cIngredient in
                    HStack {
                        
                        GameImages.boxImage
                            .resizable()
                            .frame(width:20, height:20)
                            .aspectRatio(contentMode: .fit)
                        Text("\(cIngredient.type.rawValue) x \(cIngredient.current)")
                    }
                }
                
                // Tanks
                ForEach(contribRound.tanks) { cTank in
                    HStack {
                        GameImages.imageForTank()
                            .resizable()
                            .frame(width:20, height:20)
                            .aspectRatio(contentMode: .fit)
                        Text("\(cTank.type.rawValue) x \(cTank.current)")
                    }
                }
                
                // Peripherals
                ForEach(contribRound.peripherals) { cPeripheral in
                    HStack {
                        Image(systemName: "doc.badge.gearshape")
                            .font(.title3)
                        Text(cPeripheral.peripheral.rawValue)
                    }
                }
                
                // Skills
                ForEach(contribRound.skills) { person in
                    HStack {
                        Image(systemName: "person")
                            .font(.title3)
                        Text("\(person.name)")
                    }
                }
                
                // Biobox
                ForEach(contribRound.bioBoxes) { bbox in
                    HStack {
                        Text("🧬").font(.title3)
                        Text("\(bbox.perfectDNA) x \(bbox.population.count)")
                    }
                }
            }
            
            Divider().frame(width:150)
            
            // Buttons
            HStack {
                
                Button("Fake") {
                    
                    let faker:OutpostSupply = self.makeFake()
                    let old = self.contribRound
                    let new = OutpostSupply(merging: old, with: faker)
                    
                    self.contribRound = new
                }
                .buttonStyle(GameButtonStyle())
                
                Button("🚚 Deliver") {
                    print("Delivering...")
                    controller.prepareDelivery()
                }
                .buttonStyle(GameButtonStyle())
                .disabled(controller.contribRound.supplyScore() < 1)
            }
        }
        .padding()
    }
    
    func makeFake() -> OutpostSupply {
        let fake = OutpostSupply()
        let ing1 = Ingredient.allCases.randomElement()!
        fake.ingredients.append(StorageBox(ingType: ing1, current: ing1.boxCapacity()))
        let tank1 = TankType.allCases.randomElement()!
        fake.tanks.append(Tank(type: tank1, full: true))
        return fake
    }
}

struct ContributionRoundView_Previews: PreviewProvider {
    static var previews: some View {
        ContributionRoundView(controller: OutpostController(), contribRound: .constant(makeFake()))
    }
    
    static func makeFake() -> OutpostSupply {
        let fake = OutpostSupply()
        let ing1 = Ingredient.Aluminium
        fake.ingredients.append(StorageBox(ingType: ing1, current: ing1.boxCapacity()))
        let tank1 = TankType.co2
        fake.tanks.append(Tank(type: tank1, full: true))
        let person = Person(random: true)
        fake.skills.append(person)
        let peripheral = PeripheralObject(peripheral: .Condensator)
        fake.peripherals.append(peripheral)
        let bbox = BioBox(chosen: .apple, size: 10)
        fake.bioBoxes.append(bbox)
        
        return fake
    }
}
