//
//  RSSView.swift
//  SkyNation
//
//  Created by Carlos Farini on 7/7/21.
//

import SwiftUI

class RSSData {
    
    var ingredients:[StorageBox] = []
    var peripherals:[PeripheralObject] = []
    var tanks:[Tank] = []
    var people:[Person] = []
    var bioboxes:[BioBox] = []
    var batteries:[Battery] = []
    
    static var example:RSSData {
        
        // ingredient boxes
        let alu = Ingredient.Aluminium
        let cop = Ingredient.Copper
        let iro = Ingredient.Iron
        let b1 = StorageBox(ingType: alu, current: alu.boxCapacity() / 2)
        let b2 = StorageBox(ingType: cop, current: cop.boxCapacity())
        let b3 = StorageBox(ingType: iro, current: iro.boxCapacity())
        
        // tanks
        let t1 = Tank(type: .o2, full: true)
        let t2 = Tank(type: .air, full: true)
        let t3 = Tank(type: .h2o, full: true)
        let t4 = Tank(type: .ch4, full: false)
        
        // ppl
        let p1 = Person(random: true)
        let p2 = Person(random: true)
        let p3 = Person(random: true)
        
        // peri
        let peri1 = PeripheralObject(peripheral: .Condensator)
        let peri2 = PeripheralObject(peripheral: .Electrolizer)
        let peri3 = PeripheralObject(peripheral: .Methanizer)
        let peri4 = PeripheralObject(peripheral: .ScrubberCO2)
        
        // batt
        let bat1 = Battery(shopped: true)
        let bat2 = Battery(shopped: true)
        let bat3 = Battery(shopped: true)
        let bat4 = Battery(shopped: false)
        
        let dada = RSSData()
        dada.ingredients = [b1, b2, b3]
        dada.tanks = [t1, t2, t3, t4]
        dada.people = [p1, p2, p3]
        dada.peripherals = [peri1, peri2, peri3, peri4]
        dada.batteries = [bat1, bat2, bat3, bat4]
        
        return dada
    }
}

// Segment
enum RSSSegment:String, CaseIterable {
    
    case ingredients
    case peripherals
    case batteries
    case tanks
    case people
    case bioboxes
    
    var prettyName:String {
        switch self {
            case .ingredients: return "Ingredients"
            case .peripherals: return "Peripherals"
            case .batteries: return "Batteries"
            case .tanks: return "Tanks"
            case .people: return "People"
            case .bioboxes: return "Bio Boxes"
        }
    }
    
    func imageName() -> String {
        switch self {
            case .ingredients: return "archivebox"
            case .people: return "person.2"
            case .bioboxes: return "leaf"
            case .tanks: return "gauge"
            case .peripherals: return "gearshape.2.fill"
            case .batteries: return "bolt.fill.batteryblock"
            // default: return "questionmark"
        }
    }
}

struct RSSView: View {
    
    /// The resources to be selected
    @State var resources:RSSData
    
    /// Available Resource Segments in this view (default: all cases)
    @State var avSegments:[RSSSegment] = RSSSegment.allCases
    
    /// Callback function with selected id's
    var newSelection:(([UUID]) -> ())?
    
    @State private var segment:RSSSegment = .ingredients
    @State private var selected:[UUID] = []
    
    // Gradients
    private static let myGradient = Gradient(colors: [Color.red.opacity(0.6), Color.blue.opacity(0.7)])
    private static let unseGradient = Gradient(colors: [Color.red.opacity(0.3), Color.blue.opacity(0.3)])
    private let selLinear = LinearGradient(gradient: myGradient, startPoint: .topLeading, endPoint: .bottomTrailing)
    private let unselinear = LinearGradient(gradient: unseGradient, startPoint: .topLeading, endPoint: .bottomTrailing)
    
    var body: some View {
        
        VStack {
            
            Text("Select Resources")
            
            HStack {
                ForEach(avSegments, id:\.self) { aTab in
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
                
                Text("x \(selected.count) selected").font(.headline)
            }
            .padding(.horizontal, 6)
            
            Divider()
            
            
            switch segment {
                
                case .ingredients:
                    LazyVGrid(columns: [GridItem(.fixed(150)), GridItem(.fixed(150)), GridItem(.fixed(150))], alignment: .center, spacing: 4, pinnedViews: []) {
                        ForEach(resources.ingredients.sorted(by: { $0.type.rawValue.compare($1.type.rawValue) == .orderedAscending })) { ingredient in
                            IngredientView(ingredient: ingredient.type, hasIngredient: true, quantity: nil)
                                //.foregroundColor(self.isItemSelected(ingredient) ? Color.red:Color.white)
                                .background(self.isItemSelected(ingredient) ? Color.white.opacity(0.15):Color.clear)
                                .onTapGesture {
                                    if selected.contains(ingredient.id) {
                                        selected.removeAll(where: { $0 == ingredient.id })
                                    } else {
                                        selected.append(ingredient.id)
                                    }
                                }
                        }
                    }
                case .tanks:
                    LazyVGrid(columns: [GridItem(.fixed(150)), GridItem(.fixed(150)), GridItem(.fixed(150))], alignment: .center, spacing: 4, pinnedViews: []) {
                        ForEach(resources.tanks.sorted(by: { $0.type.rawValue.compare($1.type.rawValue) == .orderedAscending })) { tank in
                            TankViewSmall(tank: tank)
                                // .foregroundColor(self.isItemSelected(tank) ? Color.red:Color.white)
                                .background(isItemSelected(tank) ? Color.white.opacity(0.15):Color.clear)
                                .onTapGesture {
                                    if selected.contains(tank.id) {
                                        selected.removeAll(where: { $0 == tank.id })
                                    } else {
                                        selected.append(tank.id)
                                    }
                                }
                        }
                    }
                    
                case .peripherals:
                    LazyVGrid(columns: [GridItem(.fixed(150)), GridItem(.fixed(150)), GridItem(.fixed(150))], alignment: .center, spacing: 4, pinnedViews: []) {
                        ForEach(resources.peripherals.sorted(by: { $0.peripheral.rawValue.compare($1.peripheral.rawValue) == .orderedAscending })) { peripheral in
                            // Peripheral View
                            PeripheralSmallView(peripheral: peripheral)
                                //.foregroundColor(peripheralsSelected.contains(peripheral) ? Color.red:Color.white)
                                .background(isItemSelected(peripheral) ? Color.white.opacity(0.15):Color.clear)
                                .onTapGesture {
                                    if selected.contains(peripheral.id) {
                                        selected.removeAll(where: { $0 == peripheral.id })
                                    } else {
                                        selected.append(peripheral.id)
                                    }
                                }
                        }
                    }
                    
                case .batteries:
                    LazyVGrid(columns: [GridItem(.fixed(150)), GridItem(.fixed(150)), GridItem(.fixed(150))], alignment: .center, spacing: 4, pinnedViews: []) {
                        ForEach(resources.batteries.sorted(by: { $0.current > $1.current })) { battery in
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
                            // .background(Color.black)
                            .background(isItemSelected(battery) ? Color.white.opacity(0.15):Color.clear)
                            .cornerRadius(12)
                            .onTapGesture {
                                if selected.contains(battery.id) {
                                    selected.removeAll(where: { $0 == battery.id })
                                } else {
                                    selected.append(battery.id)
                                }
                            }
                        }
                    }
                case .people:
                    
                    LazyVGrid(columns: [GridItem(.fixed(200)), GridItem(.fixed(200)), GridItem(.fixed(200))], alignment: .center, spacing: 4, pinnedViews: []) {
                        ForEach(resources.people) { person in
                            PersonSmallView(person:person)
                                .background(isItemSelected(person) ? Color.white.opacity(0.15):Color.clear)
                                .onTapGesture {
                                    if selected.contains(person.id) {
                                        selected.removeAll(where: { $0 == person.id })
                                    } else {
                                        selected.append(person.id)
                                    }
                                }
                        }
                    }
                    
                    
                case .bioboxes:
                    
                    LazyVGrid(columns: [GridItem(.fixed(150)), GridItem(.fixed(150)), GridItem(.fixed(150))], alignment: .center, spacing: 4, pinnedViews: []) {
                        ForEach(resources.bioboxes) { biobox in
                            VStack {
                                Text("DNA \(biobox.perfectDNA)")
                                Text("x \(biobox.population.count)")
                            }
                            .background(isItemSelected(biobox) ? Color.white.opacity(0.15):Color.clear)
                            .onTapGesture {
                                if selected.contains(biobox.id) {
                                    selected.removeAll(where: { $0 == biobox.id })
                                } else {
                                    selected.append(biobox.id)
                                }
                            }
                        }
                    }
                    
                    
                // default: Text("Default")
            }
        }
        .onChange(of:selected) { newSelect in
            newSelection?(newSelect)
        }
        .onAppear() {
            if !self.avSegments.contains(segment) {
                self.segment = avSegments.randomElement()!
            }
        }
    }
    
    func isItemSelected(_ item:Codable) -> Bool {
        if let box = item as? StorageBox {
            if selected.contains(box.id) {
                return true
            } else {
                return false
            }
        }else if let tank = item as? Tank {
            if selected.contains(tank.id) {
                return true
            } else {
                return false
            }
        }else if let person = item as? Person {
            if selected.contains(person.id) {
                return true
            } else {
                return false
            }
        }
        else if let battery = item as? Battery {
            if selected.contains(battery.id) {
                return true
            } else {
                return false
            }
        }
        else if let peripheral = item as? PeripheralObject {
            if selected.contains(peripheral.id) {
                return true
            } else {
                return false
            }
        }
        else if let biobox = item as? BioBox {
            if selected.contains(biobox.id) {
                return true
            } else {
                return false
            }
        }
        return false
    }
}

struct RSSView_Previews: PreviewProvider {
    static var previews: some View {
        RSSView(resources: RSSData.example)
    }
}
