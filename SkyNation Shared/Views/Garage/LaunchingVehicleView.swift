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
            
            if !launchController.primaryWarnings.isEmpty {
                VStack {
                    Text("⚠️ Warnings")
                        .padding([.bottom])
                    ForEach(launchController.primaryWarnings, id:\.self) { warning in
                        Text(warning)
                            .foregroundColor(.red)
                    }
                    ForEach(launchController.sencondWarnings, id:\.self) { warning in
                        Text(warning)
                            .foregroundColor(.orange)
                    }
                }
                .padding(6)
                .background(Color.black)
                .cornerRadius(8)
            }
            
            VStack(spacing:4) {
                Text("Propulsion Checklist")
                    .padding([.bottom])
                HStack {
                    Text(launchController.propulsionCheck.ch4Check ? "✅":"❌")
                    Text("CH4")
                    Spacer()
                    Text("\(launchController.propulsionCheck.ch4)")
                }
                .padding([.leading, .trailing])
                HStack {
                    Text(launchController.propulsionCheck.o2Check ? "✅":"❌")
                    Text("O2")
                    Spacer()
                    Text("\(launchController.propulsionCheck.o2)")
                }
                .padding([.leading, .trailing])
                HStack {
                    Text(launchController.propulsionCheck.n2Check ? "✅":"❌")
                    Text("N2")
                    Spacer()
                    Text("\(launchController.propulsionCheck.n2)")
                }
                .padding([.leading, .trailing])
            }
            .padding(6)
            .background(Color.black)
            .cornerRadius(8)
            .frame(width: 150)
            
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

struct PropulsionChecklistObject {
    
    var ch4:Int
    var ch4Check:Bool = false
    var o2:Int
    var o2Check:Bool = false
    var n2:Int
    var n2Check:Bool = false
    
    init(vehicle:SpaceVehicle) {
        let tanks = vehicle.tanks
        
        // Check best Propulsion tanks
        let ch4Tanks = tanks.filter({ $0.type == .ch4 })
        let o2Tanks = tanks.filter({ $0.type == .o2 })
        let n2Tanks = tanks.filter({ $0.type == .n2 })
        
        ch4 = ch4Tanks.map({ $0.current }).reduce(0, +)
        o2 = o2Tanks.map({ $0.current }).reduce(0, +)
        n2 = n2Tanks.map({ $0.current }).reduce(0, +)
        
        // After init
        switch vehicle.engine {
            case .Hex6:
                if ch4 > 80 { ch4Check = true }
                if o2 > 40 { o2Check = true }
                if n2 > 24 { n2Check = true }
            case .T12:
                if ch4 > 160 { ch4Check = true }
                if o2 > 80 { o2Check = true }
                if n2 > 24 { n2Check = true }
            case .T18:
                if ch4 > 180 { ch4Check = true }
                if o2 > 100 { o2Check = true }
                if n2 > 48 { n2Check = true }
            case .T22:
                if ch4 > 190 { ch4Check = true }
                if o2 > 110 { o2Check = true }
                if n2 > 72 { n2Check = true }
        }
    }
}

class VehicleLaunchControl:ObservableObject {
    
    @Published var vehicle:SpaceVehicle
    
    @Published var primaryWarnings:[String] = []
    @Published var sencondWarnings:[String] = []
    
    @Published var propulsionCheck:PropulsionChecklistObject
    
    init(vehicle:SpaceVehicle) {
        self.vehicle = vehicle
        self.propulsionCheck = PropulsionChecklistObject(vehicle: vehicle)
        updateWarnings()
    }
    
    func updateWarnings() {
        
        let tanks = vehicle.tanks
        
        if tanks.isEmpty {
            primaryWarnings.append("No Tanks were found")
        } else {
            // Check best Propulsion tanks
            let ch4Tanks = tanks.filter({ $0.type == .ch4 })
            let o2Tanks = tanks.filter({ $0.type == .o2 })
            let n2Tanks = tanks.filter({ $0.type == .n2 })
            
            if ch4Tanks.isEmpty || o2Tanks.isEmpty {
                primaryWarnings.append("No main propulsion")
            }
            if n2Tanks.isEmpty {
                sencondWarnings.append("No Secondary propulsion")
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
