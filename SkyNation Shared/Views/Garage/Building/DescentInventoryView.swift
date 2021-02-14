//
//  DescentInventoryView.swift
//  SkyNation
//
//  Created by Carlos Farini on 2/14/21.
//

import SwiftUI

struct DescentInventoryView: View {
    
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
            
            Text("Descent").font(.title)
                .padding([.top])
            
            Divider()
            
            HStack(spacing:18) {
                VStack {
                    Text("🚀 \(vehicle.name): \(vehicle.engine.rawValue)")
                    Text("Vehicle other")
                }
                .foregroundColor(.orange)
                .padding([.leading])
                
                Spacer()
                VStack {
                    HStack {
                        Image(systemName: "scalemass")
                            .font(.title)
                        let count = vehicle.calculateWeight() + ingredientsSelected.count + peripheralsSelected.count + bottechSelected.count
                        Text("Payload: \(count) of \(vehicle.engine.payloadLimit) Kg") // \(vehicle.engine.payloadLimit)
                            //.foregroundColor(ttlCount > vehicle.engine.payloadLimit ? .red:.green)
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
                        VehicleTrunkView(vehicle: vehicle)
                    }
                    Button("Done") {
                        print("Finished Descent Order")
                        controller.finishedDescentInventory(vehicle: vehicle)
                    }
                    .buttonStyle(NeumorphicButtonStyle(bgColor: .blue))
                }
                .padding([.trailing])
            }
            
            
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
                                    .onTapGesture {
                                        self.toggleSelection(ingredient: ingredient)
                                    }
                            }
                            
                        }
                    case .peripherals:
                        LazyVGrid(columns: [GridItem(.fixed(150)), GridItem(.fixed(150)), GridItem(.fixed(150))], alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: 4, pinnedViews: /*@START_MENU_TOKEN@*/[]/*@END_MENU_TOKEN@*/) {
                            ForEach(controller.peripherals.sorted(by: { $0.peripheral.rawValue.compare($1.peripheral.rawValue) == .orderedAscending })) { peripheral in
//                                IngredientView(ingredient: ingredient.type, hasIngredient: true, quantity: nil)
//                                PeripheralCollectionView(<#T##peripherals: [PeripheralObject]##[PeripheralObject]#>)
                                PeripheralSmallView(peripheral: peripheral)
                                    
                                    .onTapGesture {
//                                        self.toggleSelection(ingredient: ingredient)
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
}

struct VehicleTrunkView: View {
    
    var vehicle:SpaceVehicle
    
    var body: some View {
        List {
            Text("\(vehicle.name)'s Trunk").font(.title2)
                .foregroundColor(.blue)
//                .padding([.top])
            Divider().offset(x:0, y:-5)
            
            // Tanks
            Section(header: Text("Tanks").font(.title2)) {
                ForEach(vehicle.tanks.indices) { index in
                    let tank = vehicle.tanks[index]
                    HStack {
                        Text("\(tank.type.rawValue.uppercased())")
                        Spacer()
                        Text("\(tank.current)/\(tank.capacity)")
                    }
                    .padding([.leading, .trailing])
                    // Alternating Backgrounds
                    // https://stackoverflow.com/questions/57919062/swiftui-list-with-alternate-background-colors
                    .listRowBackground((index  % 2 == 0) ? GameColors.darkGray : Color(.sRGBLinear, red: 0.1, green: 0.1, blue: 0.1, opacity: 0.3))
                }
                if vehicle.tanks.isEmpty {
                    Text("< No tanks >").foregroundColor(.gray)
                }
            }
            
            // Batteries
            Section(header: Text("Batteries").font(.title2)) {
                ForEach(vehicle.batteries) { battery in
                    HStack {
                        Text("Battery")
                        Spacer()
                        Text("\(battery.current)/\(battery.capacity)")
                    }
                    .padding([.leading, .trailing])
                }
                if vehicle.batteries.isEmpty {
                    Text("< No batteries >").foregroundColor(.gray)
                }
            }
            
            // Peripherals
            Section(header: Text("Peripherals").font(.title2)) {
                ForEach(vehicle.peripherals) { peripheral in
                    Text("\(peripheral.peripheral.rawValue): \(peripheral.isBroken ? "Broken":"") Powered \(peripheral.powerOn.description)")
                }
                if vehicle.peripherals.isEmpty {
                    Text("< No peripherals >").foregroundColor(.gray)
                }
            }
            
            // Ingredients
            Section(header: Text("Ingredients").font(.title2)) {
//                ForEach(vehicle.) { peripheral in
                if let boxes = vehicle.boxes {
                    ForEach(boxes.indices) { index in
                        let box:StorageBox = boxes[index]
                        HStack {
                            Text("\(box.type.rawValue)")
                            Spacer()
                            Text("\(box.current)/\(box.capacity)")
                        }
                        .padding([.leading, .trailing])
                        // Alternating Backgrounds
                        // https://stackoverflow.com/questions/57919062/swiftui-list-with-alternate-background-colors
                        .listRowBackground((index  % 2 == 0) ? GameColors.darkGray : Color(.sRGBLinear, red: 0.1, green: 0.1, blue: 0.1, opacity: 0.3))
                    }
                } else {
                    Text("< No boxes >").foregroundColor(.gray)
                }
            }
            
        }
        .frame(width: 250, height: 300, alignment: .top)
    }
        
}

struct DescentInventoryView_Previews: PreviewProvider {
    static var previews: some View {
        DescentInventoryView(controller:GarageViewModel(), vehicle:SpaceVehicle.bigLoad())
    }
}

struct VehicleTrunk_Previews: PreviewProvider {
    static var previews: some View {
        VehicleTrunkView(vehicle:SpaceVehicle.bigLoad())
    }
}
