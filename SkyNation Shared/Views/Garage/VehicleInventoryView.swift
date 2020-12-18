//
//  VehicleInventoryView.swift
//  SkyTestSceneKit
//
//  Created by Carlos Farini on 12/5/20.
//  Copyright © 2020 Farini. All rights reserved.
//

import SwiftUI

struct VehicleInventoryView: View {
    
    @ObservedObject var controller:GarageViewModel
    var vehicle:SpaceVehicle?
    
    // Resources
    @State var tanks:[Tank] = []
    @State var batteries:[Battery] = []
    @State var peripherals:[PeripheralObject] = []
    
    init(controller:GarageViewModel) {
        self.controller = controller
        guard let veh = controller.selectedVehicle else { fatalError() }
        self.vehicle = veh
    }
    
    var body: some View {
        HStack {
            
            // Left (Resourcces)
            List() {
                // Tanks
                Section(header: Text("Tanks")) {
                    ForEach(controller.tanks) { tank in
                        TankRow(tank: tank)
                            .onTapGesture {
                                print("Add Tank here")
                                if controller.addTank(tank: tank) {
                                    self.tanks.append(tank)
                                }else {
                                    self.tanks.removeAll(where: { $0.id == tank.id })
                                }
                            }
                    }
                }
                
                // Batteries
                Section(header: Text("Batteries")) {
                    ForEach(controller.batteries) { battery in
                        Text("Battery \(battery.current) of \(battery.capacity)")
                            .onTapGesture(count: 1, perform: {
                                print("Add Battery here")
                                if controller.addBattery(battery: battery) {
                                    self.batteries.append(battery)
                                }else{
                                    self.batteries.removeAll(where: { $0.id == battery.id })
                                }
                            })
                    }
                }
                
                // Peripherals
                Section(header: Text("Peripherals")) {
                    ForEach(controller.peripherals) { peripheral in
                        Text("Device \(peripheral.peripheral.rawValue)")
                            .onTapGesture(count: 1, perform: {
                                print("Add Peripheral here")
                                controller.addPeripheral(peripheral: peripheral)
                                self.peripherals.append(peripheral)
                            })
                    }
                }
                // Ingredients?
            }
            .frame(minWidth:180, maxWidth:220)
            
            // Right (The view)
            ScrollView {
                
                VStack(alignment: .center) {
                    
                    Text("Vehicle Engine: \(controller.selectedVehicle!.engine.rawValue)")
                    Text("Select Resources")
                        .font(.title)
                        .foregroundColor(.orange)
                        .padding()
                    
                    // Tanks
                    Text("Tanks: \(tanks.count)")
                        .font(.title)
                        .padding()
                    
                    NewTankView(tanks: tanks)
                    
                    // Batteries
                    Text("Batteries: \(batteries.count)")
                        .font(.title)
                        .padding()
                    
                    ForEach(batteries) { battery in
                        HStack {
                            Image("carBattery")
                                .renderingMode(.template)
                                .resizable()
                                .colorMultiply(.red)
                                .frame(width: 32.0, height: 32.0)
                            FixedLevelBar(min: 0.0, max: Double(battery.capacity), current: Double(battery.current), title: "Health", color: .red)
                        }
                    }
                    
                    // Peripherals
                    Text("Peripherals \(peripherals.count)")
                        .font(.title)
                        .padding()
                    
                    ForEach(peripherals) { peripheral in
                        HStack {
                            peripheral.getImage()
                            VStack {
                                Text("\(peripheral.peripheral.rawValue)")
                                Text("Level \(peripheral.level) | \(peripheral.isBroken ? "Broken":"Working")")
                            }
                            
                        }
                    }
                }
                
                // Antenna
                if vehicle?.antenna != nil {
                    Text("Antenna: \(controller.selectedVehicle!.antenna!.peripheral.rawValue)")
                }else{
                    Text("Antenna: none")
                        .foregroundColor(.red)
                }
                
                // Total
                let ttlCount = peripherals.count + tanks.count + batteries.count
                Text("Payload count: \(ttlCount) of \(vehicle!.engine.payloadLimit)")
                    .foregroundColor(ttlCount > vehicle!.engine.payloadLimit ? .red:.green)
                
                
                Divider()
                
                Button("Done") {
                    print("Done adding stuff")
                    guard let sev = self.vehicle else { fatalError() }
                    controller.startBuilding(vehicle: sev)
                }
                .disabled(ttlCount > vehicle!.engine.payloadLimit)
            }
        }
    }
}

struct VehicleInventoryView_Previews: PreviewProvider {
    static var previews: some View {
        let controller = GarageViewModel()
        controller.selectedVehicle = SpaceVehicle(engine: .Hex6)
        return VehicleInventoryView(controller: controller)
    }
}
