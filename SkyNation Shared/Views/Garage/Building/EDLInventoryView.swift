//
//  DescentInventoryView.swift
//  SkyNation
//
//  Created by Carlos Farini on 2/14/21.
//

import SwiftUI

/// EDL (Entry, Descent, and Landing) Inventory View
struct EDLInventoryView: View {
    
    @ObservedObject var controller:GarageViewModel
    
    // Segment
    enum DescentSegment:String, CaseIterable {
        case ingredients
        case peripherals
        case botTech
        
        var prettyName:String {
            switch self {
                case .ingredients: return "Ingredients"
                case .peripherals: return "Peripherals"
                case .botTech: return "Bot Tech"
            }
        }
    }
    @State var segment:DescentSegment = .peripherals
    
    // Inventory
    @State var popTrunk:Bool = false
    
    // Selection
    @State var ingredientsSelected:[StorageBox] = []
    @State var peripheralsSelected:[PeripheralObject] = []
    @State var bottechSelected:[String] = []
    
    @State var vehicle:SpaceVehicle
    
    // Adding Ingredients, Peripherals, and BotTech
    
    var body: some View {
        VStack {
            
            HStack(spacing:18) {
                VStack {
                    Text("🚀 \(vehicle.name): \(vehicle.engine.rawValue)")
                    Text("EDL - Entry Descent and Landing")
                }
                .foregroundColor(.orange)
                .padding([.leading])
                
                let count = vehicle.calculateWeight() + ingredientsSelected.count + bottechSelected.count
                
                Spacer()
                VStack {
                    HStack {
                        Image(systemName: "scalemass")
                            .font(.title)
                        
                        Text("Payload: \(count) of \(vehicle.engine.payloadLimit) Kg") // \(vehicle.engine.payloadLimit)
                            .foregroundColor(count > vehicle.engine.payloadLimit ? .red:.green)
                    }
                    .padding([.top, .bottom], 8)
                    .frame(width: 170)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(4.0)
                }
                //.foregroundColor(.blue)
                Spacer()
                HStack {
                    Button("Inventory") {
                        popTrunk.toggle()
                    }
                    .buttonStyle(NeumorphicButtonStyle(bgColor: .blue))
                    .popover(isPresented: self.$popTrunk) {
                        VehicleTrunkView(vehicle: vehicle, addedPeripherals: peripheralsSelected, addedIngredients: ingredientsSelected)
                    }
                    Button("Done") {
                        print("Finished Descent Order")
                        controller.finishedDescentInventory(vehicle: vehicle, cargo: ingredientsSelected, devices: peripheralsSelected)
                    }
                    .buttonStyle(NeumorphicButtonStyle(bgColor: .blue))
                    .disabled(count > vehicle.engine.payloadLimit)
                }
                .padding([.trailing])
            }
            .padding([.top], 8)
            
            Divider()
            
            // Segment Picker
            Picker("", selection: $segment) {
                ForEach(DescentSegment.allCases, id:\.self) { dSegment in
                    Text(dSegment.prettyName)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding([.leading, .trailing])
            
            ScrollView {
                switch segment {
                    case .ingredients:
                        LazyVGrid(columns: [GridItem(.fixed(150)), GridItem(.fixed(150)), GridItem(.fixed(150))], alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: 4, pinnedViews: /*@START_MENU_TOKEN@*/[]/*@END_MENU_TOKEN@*/) {
                            ForEach(controller.ingredients.sorted(by: { $0.type.rawValue.compare($1.type.rawValue) == .orderedAscending })) { ingredient in
                                IngredientView(ingredient: ingredient.type, hasIngredient: true, quantity: nil)
                                    .foregroundColor(ingredientsSelected.contains(ingredient) ? Color.red:Color.white)
                                    .onTapGesture {
                                        self.toggleSelection(ingredient: ingredient)
                                    }
                            }
                            
                        }
                    case .peripherals:
                        LazyVGrid(columns: [GridItem(.fixed(150)), GridItem(.fixed(150)), GridItem(.fixed(150))], alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: 4, pinnedViews: /*@START_MENU_TOKEN@*/[]/*@END_MENU_TOKEN@*/) {
                            ForEach(controller.peripherals.sorted(by: { $0.peripheral.rawValue.compare($1.peripheral.rawValue) == .orderedAscending })) { peripheral in
                                // Peripheral View
                                PeripheralSmallView(peripheral: peripheral)
                                    .foregroundColor(peripheralsSelected.contains(peripheral) ? Color.red:Color.white)
                                    
                                    .onTapGesture {
                                        self.toggleSelection(peripheral: peripheral)
                                        print("select peripheral")
                                    }
                            }
                            
                        }
                    case .botTech:
                        LazyVGrid(columns: [GridItem(.fixed(150)), GridItem(.fixed(150)), GridItem(.fixed(150))], alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: 4, pinnedViews: /*@START_MENU_TOKEN@*/[]/*@END_MENU_TOKEN@*/) {
                            ForEach(controller.ingredients.sorted(by: { $0.type.rawValue.compare($1.type.rawValue) == .orderedAscending })) { ingredient in
                                IngredientView(ingredient: ingredient.type, hasIngredient: true, quantity: nil)
                                    .onTapGesture {
                                        self.toggleSelection(ingredient: ingredient)
                                    }
                            }
                            
                        }
                }
            }
            .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, maxHeight: 500, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
            
        }
//        .padding()
        
    }
    
    func toggleSelection(ingredient:StorageBox) {
        if ingredientsSelected.contains(ingredient) {
            ingredientsSelected.removeAll(where: { $0.id == ingredient.id })
        } else {
            ingredientsSelected.append(ingredient)
        }
    }
    
    func toggleSelection(peripheral:PeripheralObject) {
        
        if peripheralsSelected.contains(peripheral) {
            peripheralsSelected.removeAll(where: { $0.id == peripheral.id })
        } else {
            peripheralsSelected.append(peripheral)
        }
        
    }
}



struct DescentInventoryView_Previews: PreviewProvider {
    static var previews: some View {
        EDLInventoryView(controller:GarageViewModel(), vehicle:SpaceVehicle.bigLoad())
    }
}

struct VehicleTrunk_Previews: PreviewProvider {
    static var previews: some View {
        VehicleTrunkView(vehicle:SpaceVehicle.bigLoad())
    }
}
