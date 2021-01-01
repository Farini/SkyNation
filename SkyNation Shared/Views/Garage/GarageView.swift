//
//  GarageView.swift
//  SkyTestSceneKit
//
//  Created by Farini on 9/22/20.
//  Copyright © 2020 Farini. All rights reserved.
//

import SwiftUI

struct GarageView: View {
    
    @State var popoverGarage:Bool = false
    
    @State var selectedEngine:EngineType?
    @State var vehicle:SpaceVehicle?
    
    @ObservedObject var controller:GarageViewModel = GarageViewModel()
    
    var body: some View {
        VStack {
            
            // Top - Header
            HStack {
                
                VStack(alignment:.leading) {
                    Text("🚀 Garage Module")
                        .font(.largeTitle)
                        .padding([.leading], 6)
                        .foregroundColor(.orange)
                    Text("ID: \(UUID().uuidString)")
                        .foregroundColor(.gray)
                        .font(.caption)
                        .padding(.leading, 6)
                }
                Spacer()
                
                // Settings
                Button(action: {
                    print("Gear action")
                    popoverGarage.toggle()
                }, label: {
                    Image(systemName: "ellipsis.circle")
                        .resizable()
                        .aspectRatio(contentMode:.fit)
                        .frame(width:34, height:34)
                })
                .buttonStyle(GameButtonStyle(foregroundColor: .white, backgroundColor: .black, pressedColor: .orange))
                .popover(isPresented: $popoverGarage, content: {
                    VStack {
                        HStack {
                            Text("Rename")
                            Spacer()
                            Image(systemName: "textformat")
                                .fixedSize()
                                .scaledToFit()
                        }
                        
                        .onTapGesture {
                            print("Rename Action")
                            popoverGarage.toggle()
                        }
                        Divider()
                        HStack {
                            // Text
                            Text("Change Skin")
                            // Spacer
                            Spacer()
                            // Image
                            Image(systemName: "circle.circle")
                                .fixedSize()
                                .scaledToFit()
                        }
                        .onTapGesture {
                            print("Reskin Action")
                            popoverGarage.toggle()
                        }
                        
                        HStack {
                            Text("Tutorial")
                            Spacer()
                            Image(systemName: "questionmark.diamond")
                                .fixedSize()
                                .scaledToFit()
                        }
                        
                        .onTapGesture {
                            print("Reskin Action")
                            popoverGarage.toggle()
                        }
                    }
                    .frame(width: 150)
                    .font(.headline)
                    .foregroundColor(.gray)
                    .padding(.leading, 6)
                })
                
                // Close
                Button(action: {
                    print("Close action")
                    controller.cancelSelection()
                    NotificationCenter.default.post(name: .closeView, object: self)
                }, label: {
                    Image(systemName: "xmark.circle")
                        .resizable()
                        .aspectRatio(contentMode:.fit)
                        .frame(width:34, height:34)
                })
                .buttonStyle(GameButtonStyle(foregroundColor: .white, backgroundColor: .black, pressedColor: .orange))
                .padding(.trailing, 6)
                
            }
            Divider()
            
            // Body
            switch controller.garageStatus {
            case .idle:
                HStack(alignment: .center, spacing: 4) {
                    // List
                    List {
                        // Selection
                        Section(header: Text("Building Vehicles")) {
                            if controller.buildingVehicles.isEmpty {
                                Text("No vehicles")
                                    .foregroundColor(.gray)
                            }else{
                                ForEach(controller.buildingVehicles) { vehicle in
                                    SpaceVehicleRow(vehicle:vehicle, selected:controller.selectedVehicle == vehicle)
                                        .onTapGesture() {
                                            self.didSelectBuilding(vehicle: vehicle)
                                        }
                                }
                            }
                        }
                        // Built Vehicles
                        Section(header: Text("Built Vehicles")) {
                            if controller.builtVehicles.isEmpty {
                                Text("No vehicles")
                                    .foregroundColor(.gray)
                            }else{
                                ForEach(controller.builtVehicles) { vehicle in
                                    SpaceVehicleRow(vehicle:vehicle, selected:controller.selectedVehicle == vehicle)
                                        .onTapGesture() {
                                            self.didSelectBuilt(vehicle: vehicle)
                                        }
                                }
                            }
                        }
                        
                        // Travelling Vehicles
                        Section(header: Text("Travelling")) {
                            if controller.travellingVehicles.isEmpty {
                                Text("No vehicles")
                                    .foregroundColor(.gray)
                            }else{
                                ForEach(controller.travellingVehicles) { vehicle in
                                    SpaceVehicleRow(vehicle:vehicle, selected:controller.selectedVehicle == vehicle)
                                        .onTapGesture() {
                                            self.didSelectTravelling(vehicle: vehicle)
                                        }
                                }
                            }
                        }
                    }
                    .frame(minWidth: 140, idealWidth: 140, maxWidth: 180, minHeight: 500, maxHeight: 600, alignment: Alignment.leading)
                    Spacer(minLength: 4)
                    
                    // Main
                    ScrollView {
                        VStack {
                            Text("GARAGE")
                                .padding(.bottom, 8)
                            Text("Build vehicles to send to Mars")
                                .foregroundColor(.gray)
                                .padding()
                            
                            Text("XP: \(controller.garage.xp)")
                            Text("Simulation: \(controller.garage.simulationXP)")
                            Text("Bot Tech: \(controller.garage.botTech)")
                            Divider()
                            Text("Actions")
                            HStack {
                                Button("Start New Vehicle") {
                                    print("Starting a new vehicle")
                                    controller.startNewVehicle()
                                }
                                
                                Button("View Mission") {
//                                    print("Making some")
                                    controller.improveExperience()
                                }
                            }.padding()
                        }
                        .padding()
                    }
                }
                .frame(minWidth: 600, minHeight: 500, maxHeight: 600, alignment: Alignment.leading)
            case .selectedBuilding(let sev):
                ScrollView {
                    VStack {
                        Group {
                            Text("Building Vehicle")
                                .font(.title)
                                .padding()
                            Text("Engine: \(sev.engine.rawValue) | Limit: \(sev.engine.payloadLimit * 100)Kg.")
                            
                            HStack {
                                Image(systemName: "scalemass")
                                Text("\(sev.engine.payloadLimit * 100)Kg")
                            }
                            .font(.headline)
                            
                            Text("Simulation: \(sev.simulation) hrs")
                            Text("Destination: \(sev.status.rawValue)")
                            Text("Travel Starts: \(GameFormatters.dateFormatter.string(from: sev.dateTravelStarts ?? Date()))")
                            Text("V Engine: \(sev.engine.rawValue)")
                            
                            ForEach(sev.tanks) { tank in
                                Text("Tank: \(tank.type.rawValue)")
                                    .foregroundColor(.blue)
                            }
                            ForEach(sev.batteries) { battery in
                                Text("Battery: \(battery.current) of \(battery.capacity)")
                                    .foregroundColor(.red)
                            }
                            ForEach(sev.solar) { panel in
                                Text("Solar Panel of size: \(panel.size)")
                                    .foregroundColor(.red)
                            }
                        }
                        
                        
                        Text("Status: \(sev.status.rawValue)")
                            .padding()
                            .font(.title)
                            .foregroundColor(.orange)
                        
                        // Progress
                        CirclePercentIndicator(percentage: CGFloat(controller.vehicleProgress ?? 0.0))
                        
                        Divider()
                        HStack {
                            Button("Launch") {
                                controller.launch(vehicle: sev)
                            }
                            .disabled(controller.vehicleProgress ?? 0 < 1)
                            
                            Button("Cancel") {
                                print("Cancelling")
                                controller.cancelSelection()
                            }
                            
                            Button("Simulate") {
                                print("Go Simulate")
                            }
                            
                            Button("Inventory") {
                                print("Go to Inventory")
                                controller.setupInventory(vehicle: sev)
                            }
                        }
                        .padding()
                        
                    }
                }
                .frame(minWidth: 600, minHeight: 500, maxHeight: 600, alignment: Alignment.leading)
                
            case .selectedBuildEnd(let sev):
                ScrollView {
                    VStack {
                        Group {
                            Text("Building Vehicle")
                                .font(.title)
                                .padding()
                            Text("Engine: \(sev.engine.rawValue) | Limit: \(sev.engine.payloadLimit * 100)Kg.")
                            
                            HStack {
                                Image(systemName: "scalemass")
                                Text("\(sev.engine.payloadLimit * 100)Kg")
                            }
                            .font(.headline)
                            
                            Text("Simulation: \(sev.simulation) hrs")
                            Text("Destination: \(sev.status.rawValue)")
                            Text("Travel Starts: \(GameFormatters.dateFormatter.string(from: sev.dateTravelStarts ?? Date()))")
                            Text("V Engine: \(sev.engine.rawValue)")
                            
                            ForEach(sev.tanks) { tank in
                                Text("Tank: \(tank.type.rawValue)")
                                    .foregroundColor(.blue)
                            }
                            ForEach(sev.batteries) { battery in
                                Text("Battery: \(battery.current) of \(battery.capacity)")
                                    .foregroundColor(.red)
                            }
                            ForEach(sev.solar) { panel in
                                Text("Solar Panel of size: \(panel.size)")
                                    .foregroundColor(.red)
                            }
                        }
                        
                        
                        Text("Status: \(sev.status.rawValue)")
                            .padding()
                            .font(.title)
                            .foregroundColor(.orange)
                        
                        // Progress
//                        CirclePercentIndicator(percentage: CGFloat(controller.vehicleProgress ?? 0.0))
                        
                        Divider()
                        HStack {
                            Button("🚀 Launch") {
                                controller.launch(vehicle: sev)
                            }
                            .disabled(controller.vehicleProgress ?? 0 < 1)
                            
                            Button("Cancel") {
                                print("Cancelling")
                                controller.cancelSelection()
                            }
                            
                            Button("Simulate") {
                                print("Go Simulate")
                            }
                            
                            Button("Inventory") {
                                print("Go to Inventory")
                                controller.setupInventory(vehicle: sev)
                            }
                        }
                        .padding()
                    }
                }
                .frame(minWidth: 600, minHeight: 500, maxHeight: 600, alignment: Alignment.leading)
                
            case .selectedTravel( _):
                VStack {
                    TravellingVehicleView(controller: controller)
                }
            
            // Making a new Vehicle
            case .planning(let stage):
                
                switch stage {
                case .Engine:     // Selecting Engine
                    BuildingVehicleView(garageController: controller)
                
                // DEPRECATE
//                case .Satellite:  // Selecting Satellite
//                    Text("Satellite is deprecated. Choose robot instead")

                case .Inventory:  // Adding Tanks, Batteries, etc
                    VehicleInventoryView(controller: controller)
                
                // DEPRECATE
                case .Payload:    // Adding Payload (RSS, robot, etc.)
                    Group {
                        Text("3 - Choose Payload")
                        HStack {
                            VStack {
                                Text("Payload with engine \(self.selectedEngine!.rawValue)")
                                Text("Support limit: \(self.selectedEngine!.payloadLimit)")
                                Button("Add Payload") {
                                    print("Satcom is a go")
//                                    controller.makeProgress(new: .heatshield)
                                }
                                Button("No Payload") {
                                    print("Satcom is a go")
                                }
                            }
                        }.padding()
                    }
                case .Passengers: // Selecting Passengers
                    Group {
                        Text("Passengers")
                        Text("Passengers")
                    }
                case .Hiring:     // Selecting Staff to work on it
                    Group {
                        Text("Passengers")
                        Text("Passengers")
                    }
                case .Paying:     // Paying
                    Group {
                        Text("Passengers")
                        Text("Passengers")
                    }
                    
                    
                case .Confirm:    // Confirming
                    Text("Confirm")
//                    VehicleBuiltView(controller: self.controller, vehicle: (controller.selectedVehicle ?? self.vehicle) ?? SpaceVehicle(engine: .Hex6))
                }
                
            case .simulating:
                VStack {
                    Text("Simulation View")
                    Text("Try the simulator")
                }
            }
        }
    }
    
    func didSelectBuilding(vehicle:SpaceVehicle) {
        controller.didSelectBuilding(vehicle: vehicle)
    }
    
    func didSelectBuilt(vehicle:SpaceVehicle) {
        controller.didSelectBuildEnd(vehicle: vehicle)
    }
    
    func didSelectTravelling(vehicle:SpaceVehicle) {
        controller.didSelectTravelling(vehicle: vehicle)
    }
}

// MARK: - Vehicle Row

struct SpaceVehicleRow: View {
    
    var vehicle:SpaceVehicle
    var selected:Bool = false
    
    var body: some View {
        
        // Total
        let ttlCount = vehicle.tanks.count + vehicle.batteries.count + (vehicle.antenna != nil ? 1:0)
        
        HStack {
            Text(selected ? "●":"○")
            
            VStack(alignment: .leading) {
                Text("🚀 \(vehicle.name): \(vehicle.engine.rawValue)")
                    .font(.headline)
                
                // Add Weight
                HStack {
                    
                    Image(systemName: "scalemass")
                        .font(.headline)
                    
                    Text("\(ttlCount) of \(vehicle.engine.payloadLimit)")
                    
                }
                .foregroundColor(ttlCount == vehicle.engine.payloadLimit ? .orange:.gray)
            }
        }
        
    }
}

// MARK: - Vehicles Selected
/*
struct VehicleBuiltView: View {
    
    @ObservedObject var controller:GarageViewModel
    @State var vehicle:SpaceVehicle
    
    var body: some View {
        VStack {
            Text("Vehicle Built")
                .font(.headline)
                .foregroundColor(.orange)
                .padding(6)
            Divider()
            
            if controller.selectedVehicle != nil {
                
                // Basics (Engine, Antenna, Satellite
                Text("Engine: \(controller.selectedVehicle!.engine.rawValue)")
                if controller.selectedVehicle!.antenna != nil {
                    Text("Antenna: \(controller.selectedVehicle!.antenna!.peripheral.rawValue)")
                }else{
                    Text("Antenna: none")
                }
//                Text("Satellite: \(controller.selectedVehicle!.satellite?.rawValue ?? "none")")
                Divider()
                
                // Tanks
                Text("Tanks(ct): \(vehicle.tanks.count)")
                ForEach(self.vehicle.tanks, id:\.self) { tank in
                    TankViewSmall(tank: tank)
                }
                Divider()
                
                // Batteries
                Text("Batteries: \(vehicle.batteries.count)")
                ForEach(self.vehicle.batteries, id:\.self) { battery in
                    HStack {
                        Image("carBattery")
                            .resizable()
                            .frame(width: 32, height: 32)
                        Text("Battery \(battery.current) of \(battery.capacity)")
                    }
                }
                Divider()
                
            }
            
            // Buttons
            HStack {
                Button("Build") {
                    print("Building Vehicle")
                    controller.startBuilding(vehicle: controller.selectedVehicle!)
                }
                .padding()
                Button("Cancel") {
                    print("Cancel")
                    controller.cancelSelection()
                }
                .padding()
            }
        }
    }
    
}
*/

struct TravellingVehicleView: View {
    
    @ObservedObject var controller:GarageViewModel
    var vehicle:SpaceVehicle
    
    init(controller:GarageViewModel) {
        guard let vehicle = controller.selectedVehicle else { fatalError() }
        self.controller = controller
        self.vehicle = vehicle
    }
    
    var body: some View {
        
        ScrollView {
            
            // Intro
            Group {
                Text("Travelling Vehicle: \(vehicle.name)")
                    .font(.headline)
                    .foregroundColor(.orange)
                    .padding(6)
                Divider()
                
                // Basics (Engine, Antenna, Satellite
                Text("Engine: \(vehicle.engine.rawValue)")
                
//                Text("Satellite: \(vehicle.satellite?.rawValue ?? "none")")
                Divider()
            }
            
            // Tanks
            Group {
                Text("Tanks(ct): \(vehicle.tanks.count)")
                ForEach(self.vehicle.tanks, id:\.self) { tank in
                    TankViewSmall(tank: tank)
                }
                Divider()
            }
            
            // Batteries
            Group {
                Text("Batteries: \(vehicle.batteries.count)")
                
                ForEach(self.vehicle.batteries, id:\.self) { battery in
                    HStack {
                        Image("carBattery")
                            .resizable()
                            .frame(width: 32, height: 32)
                        Text("Battery \(battery.current) of \(battery.capacity)")
                    }
                }
                Divider()
            }
            
            
            // Time
            Group {
                Text("Status")
                    .font(.headline)
                    .padding()
                
                switch vehicle.status {
                    case .Mars:
                        Text("Timing")
                        Text("Destination: \(vehicle.status.rawValue)")
                        Text("Time: \(GameFormatters.dateFormatter.string(from: vehicle.dateTravelStarts ?? Date()))")
                        Text("Arrive: \(GameFormatters.dateFormatter.string(from: vehicle.arriveDate()))")
                        let pct = Date().timeIntervalSince(vehicle.dateTravelStarts!) / vehicle.arriveDate().timeIntervalSince(vehicle.dateTravelStarts!)
                        
                        CirclePercentIndicator(percentage: CGFloat(pct))
                        
                        Text("Simulation: \(vehicle.simulation) hrs")
                        Divider()
                        
                        // Buttons
                        HStack {
                            Button("Stop") {
                                print("You can't stop me!")
                            }
                            Button("Boost") {
                                print("You can't boost me!")
                            }
                            Button("Cancel") {
                                print("Cancelling")
                                controller.cancelSelection()
                                
                            }
                        }
                        .padding()
                    case .MarsOrbit:
                        
                        Text("In Orbit")
                        Text("Simulation: \(vehicle.simulation) hrs")
                        CirclePercentIndicator(percentage: 1.0)
                        Divider()
                        
                        // Buttons
                        HStack {
                            
                            Button("<< Go Back") {
                                print("Cancelling")
                                controller.cancelSelection()
                            }
                            
                            if let bot = vehicle.marsBot {
                                switch bot {
                                    case .Satellite:
                                        Button("Self-destruct") {
                                            print("You can't stop me!")
                                        }
                                        .foregroundColor(.red)
                                    case .Rover, .Transporter:
                                        Button("Drop Bot") {
                                            print("You can't boost me!")
                                        }
                                }
                            }
                        }
                        .padding()
                    case .Diying:
                        Text("💀 Your Vehicle has died 😭")
                            .font(.headline)
                            .foregroundColor(.red)
                            .padding()
                        Text("Take better care of your vehicle next time")
                        .foregroundColor(.gray)
                        Divider()
                        
                        HStack {
                            Button("<< Go Back") {
                                print("Cancelling")
                                controller.cancelSelection()
                            }
                        }
                        .padding()
                    default:
                        Text("Other: \(vehicle.status.rawValue)")
                        Divider()
                        HStack {
                            Button("<< Go Back") {
                                print("Cancelling")
                                controller.cancelSelection()
                            }
                        }
                        .padding()
                        
                }
            }
        }
    }
}

// MARK: - Previews

struct GarageView_Previews: PreviewProvider {
    static var previews: some View {
        GarageView()
    }
}

struct VehicleRow_Preview: PreviewProvider {
    static var previews: some View {
        SpaceVehicleRow(vehicle: SpaceVehicle(engine: .Hex6))
    }
}
