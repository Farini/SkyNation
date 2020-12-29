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
    var vehicle:SpaceVehicle
    
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
            
            // Total
            let ttlCount = peripherals.count + tanks.count + batteries.count
            
            // Right (The view)
            Group {
                
                VStack(alignment: .center) {
                    
                    // Header
                    Group {
                        Text("Vehicle Resources")
                            .font(.headline)
                            .foregroundColor(.orange)
                            .padding(.top)
                        
                        Text("Select items from the list to add to the Space Vehicle. Select them again to remove.")
                            .foregroundColor(.gray)
                            .padding([.leading, .trailing])
                            .font(.footnote)
                        
                        Group {
                            
                            HStack(alignment:.center, spacing:8) {
                                VStack {
                                    Text("🚀").font(.largeTitle)
                                    HStack {
                                        Text(vehicle.name)
                                            .font(.headline)
                                            .foregroundColor(.blue)
                                        
                                        Text("\(vehicle.engine.rawValue)")
                                            .foregroundColor(.gray)
                                    }
                                }
                                Spacer()
                                HStack {
                                    Image(systemName: "scalemass")
                                        .font(.title)
                                    
                                    Text("Payload: \(ttlCount) of \(vehicle.engine.payloadLimit)")
                                        .foregroundColor(ttlCount > vehicle.engine.payloadLimit ? .red:.green)
                                }
                                .padding([.top, .bottom], 8)
                                .frame(width: 170)
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(4.0)
                            }
                        }
                        .padding()
                    }
                    
                    Divider()
                    
                    ScrollView(.vertical, showsIndicators: true) {
                        // Tanks
                        Text("Tanks: \(tanks.count)")
                            .font(.headline)
                            .padding([.top])
                        TankCollectionView(tanks)
                            .padding([.trailing])
                        
                        // Batteries
                        Text("Batteries: \(batteries.count)")
                            .font(.headline)
                            .padding([.top])
                        BatteryCollectionView(batteries)
                            .padding([.trailing])
                        
                        // Peripherals
                        Text("Peripherals: \(peripherals.count)")
                            .font(.headline)
                            .padding([.top])
                        PeripheralCollectionView(peripherals)
                            .padding([.trailing])
                        
                        // Antenna
                        if vehicle.antenna != nil {
                            Text("Antenna level \(controller.selectedVehicle!.antenna!.level)")
                        } else {
                            Text("Antenna: none")
                                .foregroundColor(.red)
                        }
                    }
                    
                    Divider()
                    
                    Button("Done") {
                        print("Done adding stuff")
                        controller.startBuilding(vehicle: vehicle)
                    }
                    .disabled(ttlCount > vehicle.engine.payloadLimit)
                    .padding()
                }
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
