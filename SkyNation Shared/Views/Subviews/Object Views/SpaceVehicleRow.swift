//
//  SpaceVehicleRow.swift
//  SkyNation
//
//  Created by Carlos Farini on 11/7/21.
//

import SwiftUI

// MARK: - Vehicle Row

struct SpaceVehicleRow: View {
    
    var vehicle:SpaceVehicle
    var selected:Bool = false
    
    var body: some View {
        
        // Total
        let ttlCount = vehicle.calculateWeight()
        
        HStack {
            
            VStack(alignment: .leading) {
                switch vehicle.status {
                    case .Creating:
                        HStack {
                            Text("🚀 \(vehicle.name)")
                                .font(GameFont.mono.makeFont())
                            Spacer()
                            
                        }
                    case .Mars:
                        // Travelling
                        HStack {
                            Text("🚀 \(vehicle.name)")
                                .font(.headline)
                            Text("\(vehicle.calculateWeight())")
                                .foregroundColor(.gray)
                        }
                    default:
                        Text("? Unidentified Vehicle ?!?")
                }

                // Add Weight
                HStack {
                    
                    if vehicle.status == .Creating {
                        Image(systemName: "scalemass")
                            .font(.headline)
                        Text("\(ttlCount) of \(vehicle.engine.payloadLimit)")
                    }
                    if vehicle.status == .Mars {
                        let progress = vehicle.calculateProgress() ?? 0
                        ProgressView("Travel", value: progress)
                    }
                }
                .foregroundColor(ttlCount == vehicle.engine.payloadLimit ? .orange:.gray)
            }
            
            Spacer()
        }
        .padding(6)
        .background(Color.black.opacity(0.3))
        .cornerRadius(4)
        .overlay(RoundedRectangle(cornerSize: CGSize(width: 4, height: 4))
                    .strokeBorder(style: StrokeStyle())
                    .foregroundColor(selected == true ? Color.blue:Color.clear)
        )
    }
}

struct VehicleRow_Preview: PreviewProvider {
    static var previews: some View {
        SpaceVehicleRow(vehicle: SpaceVehicle(engine: .Hex6))
    }
}
