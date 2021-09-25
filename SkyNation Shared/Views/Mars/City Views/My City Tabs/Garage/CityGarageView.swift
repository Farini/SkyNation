//
//  CityGarageView.swift
//  SkyNation
//
//  Created by Carlos Farini on 8/14/21.
//

import SwiftUI

struct CityGarageView: View {
    
    @ObservedObject var controller:CityController
    
    @State var selectedVehicle:SpaceVehicle?
    
    var body: some View {
        HStack {
            
            List {
                Section(header: Text("Arrived")) {
                    ForEach(controller.arrivedVehicles) { vehicle in
                        SpaceVehicleRow(vehicle: vehicle)
                            .onTapGesture {
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
                        SpaceVehicleRow(vehicle: vehicle)
                            .onTapGesture {
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
                if let vehicle = selectedVehicle {
                    HStack {
                        Spacer()
                        VStack {
                            Text(vehicle.name)
                            Text(vehicle.status.rawValue)
                            Text("\(vehicle.calculateProgress() ?? 0.0)")
                            
                            Button("Unload") {
                                controller.unload(vehicle: vehicle)
                            }
                            .buttonStyle(NeumorphicButtonStyle(bgColor: .white))
                            .disabled(controller.travelVehicles.contains(vehicle))
                            
                        }
                        Spacer()
                    }
                    
                } else {
                    HStack {
                        Spacer()
                        Text("Select a Vehicle")
                            .foregroundColor(.gray)
                            .padding()
                        Spacer()
                    }
                }
            }
            .frame(minWidth: 400, idealWidth: 500, maxWidth:700)
        }
        .onAppear() {
            controller.updateVehiclesLists()
        }
    }
}

struct CityGarageView_Previews: PreviewProvider {
    static var previews: some View {
        CityGarageView(controller: CityController())
    }
}
