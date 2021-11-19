//
//  CityGarageView.swift
//  SkyNation
//
//  Created by Carlos Farini on 8/14/21.
//

import SwiftUI

struct CityGarageView: View {
    
    @ObservedObject var controller:LocalCityController
    @State var garageState:CityGarageState
    
    @State private var popTrunk:Bool = false
    @State private var selectedVehicle:SpaceVehicle? = nil
    
    var body: some View {
        HStack {
            
            List {
                Section(header: Text("Arrived")) {
                    ForEach(controller.arrivedVehicles) { vehicle in
                        SpaceVehicleRow(vehicle: vehicle, selected: vehicle == self.selectedVehicle)
                            .onTapGesture {
                                self.garageState = .selected(vehicle: vehicle)
                                self.selectedVehicle = vehicle
                            }
                    }
                    if controller.arrivedVehicles.isEmpty {
                        Text("< No Vehicles Arrived >")
                            .foregroundColor(.gray)
                    }
                }
                
                Section(header: Text("Travelling")) {
                    ForEach(controller.travelVehicles) { vehicle in
                        SpaceVehicleRow(vehicle: vehicle, selected: vehicle == self.selectedVehicle)
                            .onTapGesture {
                                self.garageState = .selected(vehicle: vehicle)
                                self.selectedVehicle = vehicle
                            }
                    }
                    if controller.travelVehicles.isEmpty {
                        Text("< Empty >")
                            .foregroundColor(.gray)
                    }
                }
            }
            .frame(minWidth:180, maxWidth:200, minHeight:300, maxHeight:.infinity)
            
            VStack {
                
                switch garageState {
                    case .noSelection:
                        HStack {
                            Spacer()
                            Text("Select a Vehicle")
                                .foregroundColor(.gray)
                                .padding()
                            Spacer()
                        }
                    case .arrival:
                        
                        let ctrl = EDLSceneController(vehicle: controller.arrivedVehicles.first ?? SpaceVehicle(engine: .T12))
                        ZStack(alignment: Alignment.topTrailing) {
                            EDLSceneView(edlController: ctrl)
                            VStack {
                                Text("Vehicle Arriving")
                                Button("Close") {
                                    self.garageState = .noSelection
                                }
                                .buttonStyle(GameButtonStyle())
                                .padding(.top, 6)
                            }
                            .padding()
                        }
                        
                        
                    case .selected(let vehicle):
                        HStack {
                            Spacer()
                            VStack {
                                Text(vehicle.name)
                                Text(vehicle.status.rawValue)
                                Text("\(vehicle.calculateProgress() ?? 0.0)")
                                
                                GameActivityView(vehicle: vehicle)
                                
                                Divider()
                                
                                HStack {
                                    
                                    Button("Trunk") {
                                        popTrunk.toggle()
                                    }
                                    .buttonStyle(NeumorphicButtonStyle(bgColor: .white))
                                    .popover(isPresented: $popTrunk) {
                                        VehicleTrunkView(vehicle: vehicle)
                                    }
                                    
                                    
                                    Button("Unload") {
                                        controller.unload(vehicle: vehicle)
                                    }
                                    .buttonStyle(NeumorphicButtonStyle(bgColor: .white))
                                    .disabled(vehicle.arriveDate().compare(Date()) == .orderedDescending)
                                    
                                }
                                
                            }
                            Spacer()
                        }
                }
            }
            .frame(minWidth: 400, idealWidth: 500, maxWidth:700)
        }
        .onAppear() {
            if let _ = controller.arrivedVehicles.first {
                self.garageState = .arrival
            }
        }
    }
}

struct CityGarageView_Previews: PreviewProvider {
    static var previews: some View {
        CityGarageView(controller: LocalCityController(), garageState: .noSelection)
    }
}
