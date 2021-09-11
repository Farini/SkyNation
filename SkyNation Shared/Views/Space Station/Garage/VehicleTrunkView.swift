//
//  VehicleTrunkView.swift
//  SkyNation
//
//  Created by Carlos Farini on 2/15/21.
//

import SwiftUI

/**
 A View that shows the contents of `Space Vehicle`. Best shown in a `popover` view.
 */
struct VehicleTrunkView: View {
    
    var vehicle:SpaceVehicle
    
//    @State var addedPeripherals:[PeripheralObject] = []
//    @State var addedIngredients:[StorageBox] = []
    
    var boxes:[StorageBox] = []
    var tanks:[Tank] = []
    var batteries:[Battery] = []
    var peripherals:[PeripheralObject] = []
    var passengers:[Person] = []
    var bioBoxes:[BioBox] = []
    
    let rowColor1:Color = GameColors.darkGray
    let rowColor2:Color = Color(.sRGBLinear, red: 0.1, green: 0.1, blue: 0.1, opacity: 0.3)
    
    var body: some View {
        
        List {
            Text("\(vehicle.name)'s Trunk").font(.title2)
                .foregroundColor(.blue)
            Divider().offset(x:0, y:-5)
            
            // + Tanks
            Section(header: Text("Tanks").font(.title2)) {
                ForEach(vehicle.tanks.indices) { index in
                    let tank = vehicle.tanks[index]
                    HStack {
                        Text("\(tank.type.rawValue.uppercased())")
                        Spacer()
                        Text("\(tank.current)/\(tank.capacity)")
                    }
                    .padding([.leading, .trailing], 6)
                    // Alternating Backgrounds
                    // https://stackoverflow.com/questions/57919062/swiftui-list-with-alternate-background-colors
                    .listRowBackground((index  % 2 == 0) ? rowColor1 : rowColor2)
                }
                ForEach(tanks) { tank in
                    HStack {
                        Text("\(tank.type.rawValue.uppercased())")
                        Spacer()
                        Text("\(tank.current)/\(tank.capacity)")
                    }
                    .padding([.leading, .trailing], 6)
                    .foregroundColor(.red)
                }
                if vehicle.tanks.isEmpty && tanks.isEmpty {
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
                    .padding([.leading, .trailing], 6)
                }
                ForEach(batteries) { battery in
                    HStack {
                        Text("Battery")
                        Spacer()
                        Text("\(battery.current)/\(battery.capacity)")
                    }
                    .padding([.leading, .trailing], 6)
                    .foregroundColor(.red)
                }
                if vehicle.batteries.isEmpty && batteries.isEmpty {
                    Text("< No batteries >").foregroundColor(.gray)
                }
            }
            
            // + Peripherals
            Section(header: Text("Peripherals").font(.title2)) {
                ForEach(vehicle.peripherals) { peripheral in
                    Text("\(peripheral.peripheral.rawValue): \(peripheral.isBroken ? "Broken":"") Powered \(peripheral.powerOn.description)")
                }
                ForEach(peripherals) { peripheral in
                    Text("\(peripheral.peripheral.rawValue): \(peripheral.isBroken ? "Broken":"") Powered \(peripheral.powerOn.description)")
                        .foregroundColor(.red)
                }
                if vehicle.peripherals.isEmpty && peripherals.isEmpty {
                    Text("< No peripherals >").foregroundColor(.gray)
                }
            }
            
            // + Ingredients
            Section(header: Text("Ingredients").font(.title2)) {
                
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
                }
                
                ForEach(boxes) { box in
                    HStack {
                        Text("\(box.type.rawValue)")
                        Text("\(box.current)/\(box.capacity)")
                    }
                    .foregroundColor(.red)
                }
                if boxes.isEmpty && vehicle.boxes.isEmpty {
                    Text("< No boxes >").foregroundColor(.gray)
                }
            }
            
            // People
            Section(header: Text("People").font(.title3)) {
                ForEach(vehicle.passengers) { person in
                    PersonRow(person: person)
                }
                ForEach(passengers) { person in
                    PersonRow(person: person).foregroundColor(.red)
                }
                if vehicle.passengers.isEmpty && passengers.isEmpty {
                    Text("< No passengers >").foregroundColor(.gray)
                }
            }
            
            // Bioboxes
            Section(header: Text("Bioboxes").font(.title3)) {
                
                ForEach(vehicle.bioBoxes) { biobox in
                    HStack {
                        Text(DNAOption(rawValue: biobox.perfectDNA)!.emoji)
                        Text("x \(biobox.population.count) / \(biobox.populationLimit)")
                    }
                }
                ForEach(bioBoxes) { biobox in
                    HStack {
                        Text(DNAOption(rawValue: biobox.perfectDNA)!.emoji)
                        Text("x \(biobox.population.count) / \(biobox.populationLimit)")
                    }
                    .foregroundColor(.red)
                }
                if vehicle.bioBoxes.isEmpty && bioBoxes.isEmpty {
                    Text("< No Bio boxes >").foregroundColor(.gray)
                }
            }
        }
        .frame(width: 250, height: 300, alignment: .top)
        
    }
}
