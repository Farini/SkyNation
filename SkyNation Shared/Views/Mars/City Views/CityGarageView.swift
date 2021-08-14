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
            List() {
                Text("Rockets")
                ForEach(controller.arrivedVehicles) { vehicle in
                    SpaceVehicleRow(vehicle: vehicle)
                        .onTapGesture {
                            self.selectedVehicle = vehicle
                        }
                }
            }
            .frame(width:200)
            
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
                            .disabled(vehicle.arriveDate().compare(Date()) == .orderedDescending)
                            
                        }
                        Spacer()
                    }
                    
                } else {
                    HStack {
                        Spacer()
                        Text("Select a Vehicle")
                            .padding()
                        Spacer()
                    }
                }
            }
        }
    }
}

struct CityGarageView_Previews: PreviewProvider {
    static var previews: some View {
        CityGarageView(controller: CityController())
    }
}
