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
        case batteries
        case tanks
        case passengers
        case bioboxes
        
        var prettyName:String {
            switch self {
                case .ingredients: return "Ingredients"
                case .peripherals: return "Peripherals"
                case .batteries: return "Batteries"
                case .tanks: return "Tanks"
                case .passengers: return "Passengers"
                case .bioboxes: return "Bio Boxes"
            }
        }
        
        func imageName() -> String {
            switch self {
                case .ingredients: return "archivebox"
                case .passengers: return "person.2"
                case .bioboxes: return "leaf"
                case .tanks: return "gauge"
                case .peripherals: return "gearshape.2.fill"
                case .batteries: return "bolt.fill.batteryblock"
//                default: return "questionmark"
            }
        }
    }
    
    @State var segment:DescentSegment = .peripherals
    
    // Inventory
    @State var popTrunk:Bool = false
    
    // Selection
    @State var ingredientsSelected:[StorageBox] = []
    @State var peripheralsSelected:[PeripheralObject] = []
    @State var tanksSelected:[Tank] = []
    @State var passengers:[Person] = []
    @State var bioboxes:[BioBox] = []
    @State var batteries:[Battery] = []
    
    @State var bottechSelected:[String] = []
    
    @State var vehicle:SpaceVehicle
    
    /// The Tab View
    var tabber: some View {
        // Tabs
        VStack {
        
            let myGradient = Gradient(colors: [Color.red.opacity(0.6), Color.blue.opacity(0.7)])
            let unseGradient = Gradient(colors: [Color.red.opacity(0.3), Color.blue.opacity(0.3)])
            let selLinear = LinearGradient(gradient: myGradient, startPoint: .topLeading, endPoint: .bottomTrailing)
            let unselinear = LinearGradient(gradient: unseGradient, startPoint: .topLeading, endPoint: .bottomTrailing)
            
            HStack {
                ForEach(DescentSegment.allCases, id:\.self) { aTab in
                    Image(systemName: aTab.imageName()).padding(6).frame(height: 32, alignment: .center)
                        .background(segment == aTab ? selLinear:unselinear)
                        .onTapGesture {
                            self.segment = aTab
                        }
                        .cornerRadius(4)
                        .clipped()
                        .border(segment == aTab ? Color.blue:Color.clear, width: 1)
                        .cornerRadius(6)
                        .help(aTab.prettyName)
                }
                
                Spacer()
            }
            .padding(.horizontal, 6)
            .font(.title3)
            
            Divider()
        }
    }
    
    var body: some View {
        VStack {
            
            HStack(spacing:18) {
                VStack {
                    Text("🚀 \(vehicle.name): \(vehicle.engine.rawValue)")
                    Text("EDL - Entry Descent and Landing")
                }
                .foregroundColor(.orange)
                .padding([.leading])
                
                let count = vehicle.calculateWeight() + ingredientsSelected.count + peripheralsSelected.count + tanksSelected.count + passengers.count + bioboxes.count + batteries.count
                
                Spacer()
                
                // Payload Mass Indicator (PMI)
                VStack {
                    HStack {
                        Image(systemName: "scalemass")
                            .font(.title)
                        Text("Payload: \(count) of \(vehicle.engine.payloadLimit) Kg")
                            .foregroundColor(count > vehicle.engine.payloadLimit ? .red:.green)
                    }
                    .padding([.top, .bottom], 8)
                    .frame(width: 170)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(4.0)
                }
                
                Spacer()
                
                // Top Right Buttons
                HStack {
                    
                    // See Trunk
                    Button("Inventory") {
                        popTrunk.toggle()
                    }
                    .buttonStyle(NeumorphicButtonStyle(bgColor: .blue))
                    .popover(isPresented: self.$popTrunk) {
                        VehicleTrunkView(vehicle: vehicle, boxes: ingredientsSelected, tanks: tanksSelected, batteries: batteries, peripherals: peripheralsSelected, passengers: passengers, bioBoxes: bioboxes)
                    }
                    
                    // Load the vehicle
                    Button("Done") {
                        print("Finished Descent Order")
                        controller.finishedDescentInventory(vehicle: vehicle, cargo: ingredientsSelected, tanks: tanksSelected, batteries: batteries, devices: peripheralsSelected, people: passengers, bioBoxes: bioboxes)
                    }
                    .buttonStyle(NeumorphicButtonStyle(bgColor: .blue))
                    .disabled(count > vehicle.engine.payloadLimit)
                }
                .padding([.trailing])
            }
            .padding([.top], 8)
            
            Divider()
            
            // Segment Picker
            tabber
            
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
                    case .batteries:
                        LazyVGrid(columns: [GridItem(.fixed(150)), GridItem(.fixed(150)), GridItem(.fixed(150))], alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: 4, pinnedViews: /*@START_MENU_TOKEN@*/[]/*@END_MENU_TOKEN@*/) {
                            ForEach(controller.batteries.sorted(by: { $0.current > $1.current })) { battery in
                                VStack {
                                    Image("carBattery")
                                        .renderingMode(.template)
                                        .resizable()
                                        .colorMultiply(.red)
                                        .frame(width: 32.0, height: 32.0)
                                        .padding([.top, .bottom], 8)
                                    ProgressView("\(battery.current) of \(battery.capacity)", value: Float(battery.current), total: Float(battery.capacity))
                                }
                                .frame(width:100)
                                .padding([.leading, .trailing, .bottom], 6)
                                .background(self.batteries.contains(battery) ? Color.black:Color.black.opacity(0.2))
                                .cornerRadius(12)
                                .border(batteries.contains(battery) ? Color.blue:Color.clear, width: 2)
                                .cornerRadius(12)
                                .clipped()
                                .padding(4)
                                .onTapGesture {
                                    self.toggleSelection(battery: battery)
                                }
                            }
                        }
                        
                    // Tanks
                    case .tanks:
                        LazyVGrid(columns: [GridItem(.fixed(150)), GridItem(.fixed(150)), GridItem(.fixed(150))], alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: 4, pinnedViews: /*@START_MENU_TOKEN@*/[]/*@END_MENU_TOKEN@*/) {
                            ForEach(controller.tanks.sorted(by: { $0.type.rawValue.compare($1.type.rawValue) == .orderedAscending })) { tank in
                                TankViewSmall(tank: tank)
                                    .border(tanksSelected.contains(tank) ? Color.blue:Color.clear, width: 2)
                                    .cornerRadius(8)
                                    .clipped()
                                    .padding(.horizontal, 4)
                                    .onTapGesture {
                                        self.toggleSelection(tank: tank)
                                    }
                            }
                        }
                    case .passengers:
                        if [EngineType.T22, EngineType.T18].contains(vehicle.engine) {
                            LazyVGrid(columns: [GridItem(.fixed(200)), GridItem(.fixed(200)), GridItem(.fixed(200))], alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: 4, pinnedViews: /*@START_MENU_TOKEN@*/[]/*@END_MENU_TOKEN@*/) {
                                ForEach(controller.availablePeople) { person in
                                    PersonSmallView(person: person)
                                        .border(passengers.contains(person) ? Color.blue:Color.clear, width: 2)
                                        .cornerRadius(8)
                                        .clipped()
                                        .padding(.horizontal, 4)
                                        .onTapGesture {
                                            self.toggleSelection(person: person)
                                        }
                                }
                            }
                        } else {
                            Text("A better engine is needed to carry passengers.")
                                .foregroundColor(.gray)
                        }
                        
                        
                    case .bioboxes:
                        if [EngineType.T22, EngineType.T18, EngineType.T12].contains(vehicle.engine) {
                        LazyVGrid(columns: [GridItem(.fixed(150)), GridItem(.fixed(150)), GridItem(.fixed(150))], alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: 4, pinnedViews: /*@START_MENU_TOKEN@*/[]/*@END_MENU_TOKEN@*/) {
                            ForEach(controller.bioBoxes) { biobox in
                                VStack {
                                    Text("DNA \(biobox.perfectDNA)")
                                    HStack {
                                        Text(DNAOption(rawValue:biobox.perfectDNA)!.emoji)
                                        Text("x \(biobox.population.count)")
                                    }
                                }
                                .padding(6)
                                .background(Color.black)
                                .border(bioboxes.contains(biobox) ? Color.blue:Color.clear, width: 2)
                                .cornerRadius(8)
                                .clipped()
                                .padding(.horizontal, 4)
                                .onTapGesture {
                                    self.toggleSelection(biobox: biobox)
                                }
                            }
                        }
                        }else{
                            Text("A better engine is needed to carry Bioboxes.")
                                .foregroundColor(.gray)
                        }
                }
            }
            .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, maxHeight: 500, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
            
        }
        .background(GameColors.darkGray)
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
    
    func toggleSelection(person:Person) {
        if passengers.contains(person) {
            passengers.removeAll(where: { $0.id == person.id })
        } else {
            passengers.append(person)
        }
    }
    
    func toggleSelection(tank:Tank) {
        if tanksSelected.contains(tank) {
            tanksSelected.removeAll(where: { $0.id == tank.id })
        } else {
            tanksSelected.append(tank)
        }
    }
    
    func toggleSelection(battery:Battery) {
        if batteries.contains(battery) {
            batteries.removeAll(where: { $0.id == battery.id })
        } else {
            batteries.append(battery)
        }
    }
    
    func toggleSelection(biobox:BioBox) {
        if bioboxes.contains(biobox) {
            bioboxes.removeAll(where: { $0.id == biobox.id })
        } else {
            bioboxes.append(biobox)
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
