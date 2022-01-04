//
//  LaunchingVehicleView.swift
//  SkyNation
//
//  Created by Carlos Farini on 1/7/21.
//

import SwiftUI
import SceneKit

struct LaunchingVehicleView: View {
    
    @ObservedObject var controller:GarageViewModel
    var vehicle:SpaceVehicle
    
    init(vehicle:SpaceVehicle, controller:GarageViewModel) {
        self.vehicle = vehicle
        self.controller = controller
    }
    
    var body: some View {
        ScrollView {
            VStack {
                
                let propulsionCheck = controller.runPropulsionCheck(vehicle: vehicle)
                
                HStack {
                    Text("Prepare for launch").font(GameFont.title.makeFont())
                    Spacer()
                }
                .padding(.top, 6)
                
                HStack(alignment:.top, spacing:12) {
                    
                    VStack {
                        // Checklist
                        VStack(spacing:4) {
                            Text("Propulsion Checklist")
                                .font(GameFont.section.makeFont())
                            
                            Divider().offset(x:0, y:-2)
                            HStack {
                                Text("tank")
                                Spacer()
                                Text("req")
                                Text("av.")
                            }
                            .font(GameFont.mono.makeFont())
                            .padding([.leading, .trailing])
                            
                            HStack {
                                Text(propulsionCheck.n2Check == true ? "✅":"❌")
                                Text("N2")
                                Spacer()
                                Text("\(propulsionCheck.n2Needed)")
                                Text("\(propulsionCheck.n2Available)")
                            }
                            .font(GameFont.mono.makeFont())
                            .padding([.leading, .trailing])
                            
                            HStack {
                                Text(propulsionCheck.ch4Check == true ? "✅":"❌")
                                Text("CH4")
                                Spacer()
                                Text("\(propulsionCheck.ch4Needed)")
                                Text("\(propulsionCheck.ch4Available)")
                            }
                            .font(GameFont.mono.makeFont())
                            .padding([.leading, .trailing])
                            
                        }
                        .padding(6)
                        .background(Color.black)
                        .cornerRadius(8)
                        .padding(.bottom, 8)
                        
                        if propulsionCheck.n2Check == false && propulsionCheck.ch4Check == false {
                            Group {
                                Text("⚠️")
                                Divider()
                                Text("Need Propulsion.")
                                Text("Nitrogen (N2), or Methane (CH4) tanks")
                                Text("provide fuel to your vehicle.")
                            }
                            .foregroundColor(.red)
                        } else {
                            Group {
                                Text("⚠️")
                                Divider()
                                Text("\(vehicle.name) is ready to launch.")
                            }
                            .foregroundColor(.green)
                            
                        }
                    }
                    
                    Spacer()
                    
                    VehicleTrunkView(vehicle: vehicle)
                }
                
                Divider()
                
                // Buttons
                HStack {
                    
                    Button(action: {
                        print("Back Button Pressed")
                        controller.cancelSelection()
                    }) {
                        HStack {
                            Image(systemName: "backward.frame")
                            Text("Back")
                        }
                    }
                    .buttonStyle(NeumorphicButtonStyle(bgColor: .gray))
                    .help("Go back")
                    
                    Button("Inventory") {
                        print("Back To Inventory")
                        controller.goBackToInventory()
                    }
                    .buttonStyle(NeumorphicButtonStyle(bgColor: .gray))
                    
                    Button("Launch") {
                        print("Launch Vehicle")
                        controller.launch(vehicle: vehicle)
                    }
                    .buttonStyle(NeumorphicButtonStyle(bgColor: .gray))
                    .disabled(propulsionCheck.n2Check == false && propulsionCheck.ch4Check == false)
                    
                }
                .padding(.bottom, 8)
            }
            .padding()
        }
    }
}

struct PostLaunchVehicleView: View {
    
    @ObservedObject var garageController:GarageViewModel
    @ObservedObject var launchController:LaunchSceneController
    
    // Shows the Vehicle launching, and later its status
    
    var body: some View {
        ZStack(alignment: Alignment(horizontal: .trailing, vertical: .bottom)) {
            SceneView(scene: launchController.scene, pointOfView: nil, options: .allowsCameraControl, preferredFramesPerSecond: 30, antialiasingMode: .none, delegate: nil, technique: nil)
            VStack {
                Text("V: \(launchController.vehicle.name)")
                Button("Close") {
                    garageController.cancelSelection()
                }
                .buttonStyle(GameButtonStyle())
            }
            
            .padding(20)
            .background(Color.black.luminanceToAlpha())
            .cornerRadius(12)
        }
    }
}

/*
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
*/

/*
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
*/

struct LaunchingVehicleView_Previews: PreviewProvider {
    
    static var previews: some View {
        let ctrl = GarageViewModel()
        if let vehicle = LocalDatabase.shared.station.garage.buildingVehicles.last {
            LaunchingVehicleView(vehicle: vehicle, controller: ctrl)
        } else {
            LaunchingVehicleView(vehicle: SpaceVehicle.builtExample(), controller:ctrl)
        }
        
    }
}

/// Prepare
struct PostLaunch_Previews: PreviewProvider {
    static var previews: some View {
        PostLaunchVehicleView(garageController: GarageViewModel(), launchController: LaunchSceneController(vehicle: SpaceVehicle(engine: .T12)))
    }
}
