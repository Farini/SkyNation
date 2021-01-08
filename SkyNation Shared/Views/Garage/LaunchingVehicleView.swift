//
//  LaunchingVehicleView.swift
//  SkyNation
//
//  Created by Carlos Farini on 1/7/21.
//

import SwiftUI

struct LaunchingVehicleView: View {
    
    @ObservedObject var launchController:VehicleLaunchControl
//    @State var vehicle:SpaceVehicle
    
    init(vehicle:SpaceVehicle) {
        self.launchController = VehicleLaunchControl(vehicle: vehicle)
//        self.vehicle = vehicle
        
    }
    
    var body: some View {
        VStack {
            Text("Launching Vehicle").font(.largeTitle)
                .padding()
                .foregroundColor(.orange)
            Divider()
            
            VStack {
                Text("Vehicle: \(launchController.vehicle.engine.rawValue)")
                Text("Tanks: \(launchController.vehicle.tanks.count)")
                Text("Batteries: \(launchController.vehicle.batteries.count)")
                Text("Peripherals: \(launchController.vehicle.peripherals.count)")
                Text("Passengers: \(launchController.vehicle.passengers.count)")
            }
            .padding()
            .background(Color.black)
            .cornerRadius(8)
            
            if !launchController.warnings.isEmpty {
                VStack {
                    Text("⚠️ Warnings")
                        .padding([.bottom])
                    ForEach(launchController.warnings, id:\.self) { warning in
                        Text(warning)
                            .foregroundColor(.red)
                    }
                }
                .padding(6)
                .background(Color.black)
                .cornerRadius(8)
            }
            
            Divider()
            
            HStack {
                Button("Inventory") {
                    print("Back To Inventory")
                }
                Button("Launch") {
                    print("Launch Vehicle")
                }
                Button("Test") {
                    print("Test")
                }
            }
        }
        .padding()
    }
}

class VehicleLaunchControl:ObservableObject {
    
    @Published var vehicle:SpaceVehicle
    @Published var warnings:[String] = []
    
    init(vehicle:SpaceVehicle) {
        self.vehicle = vehicle
        updateWarnings()
    }
    
    func updateWarnings() {
        
        let tanks = vehicle.tanks
        
        if tanks.isEmpty {
            warnings.append("No Tanks were found")
        } else {
            // Check best Propulsion tanks
            let ch4Tanks = tanks.filter({ $0.type == .ch4 })
            let o2Tanks = tanks.filter({ $0.type == .o2 })
            let n2Tanks = tanks.filter({ $0.type == .n2 })
            if ch4Tanks.isEmpty || o2Tanks.isEmpty {
                warnings.append("No main propulsion")
            }
            if n2Tanks.isEmpty {
                warnings.append("No Secondary propulsion")
            }
            
        }
    }
}

struct LaunchingVehicleView_Previews: PreviewProvider {
    
    static var previews: some View {
        if let vehicle = LocalDatabase.shared.station?.garage.buildingVehicles.last {
            LaunchingVehicleView(vehicle: vehicle)
        } else {
            LaunchingVehicleView(vehicle: SpaceVehicle.builtExample())
        }
        
    }
}
