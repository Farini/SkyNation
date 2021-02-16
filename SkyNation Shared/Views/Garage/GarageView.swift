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
    
    var header: some View {
        Group {
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
                
                // Tutorial
                Button(action: {
                    print("Question ?")
                    popoverGarage.toggle()
                }, label: {
                    Image(systemName: "questionmark.circle")
                        .font(.title2)
                })
                .buttonStyle(SmallCircleButtonStyle(backColor: .orange))
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
                    controller.cancelSelection()
                    NotificationCenter.default.post(name: .closeView, object: self)
                }, label: {
                    Image(systemName: "xmark.circle")
                        .font(.title2)
                })
                .buttonStyle(SmallCircleButtonStyle(backColor: .red))
                
                
                .padding(.trailing, 6)
                
            }
            Divider()
                .offset(x: 0, y: -5)
        }
        
    }
    
    var sideList: some View {
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
    }
    
    var body: some View {
        VStack {
            
            // Top - Header
            header
            
            // Body
            switch controller.garageStatus {
            case .idle:
                
                HStack(alignment: .top, spacing: 4) {
                    
                    // List
                    sideList
                        .frame(minWidth: 140, maxWidth: 180, alignment: Alignment.leading)
                    
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
                                .buttonStyle(NeumorphicButtonStyle(bgColor: .gray))
                                
                                Button("Experience +") {
//                                    print("Making some")
                                    controller.improveExperience()
                                }
                                .buttonStyle(NeumorphicButtonStyle(bgColor: .gray))
                                
                                Button("Upgrade ?") {
                                    //                                    print("Making some")
                                    controller.improveExperience()
                                }
                                .buttonStyle(NeumorphicButtonStyle(bgColor: .gray))
                                
                            }.padding()
                        }
                        .padding()
                    }
                }
                
            case .selectedBuilding(let sev):
                
                HStack(alignment: .top, spacing: 4) {
                    
                    // List
                    sideList
                        .frame(minWidth: 140, maxWidth: 180, alignment: Alignment.leading)
                    
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
                            GameActivityView(vehicle: sev)
                            
                            Divider()
                            
                            HStack {
                                
                                Button("Launch") {
                                    controller.launch(vehicle: sev)
                                }
                                .buttonStyle(NeumorphicButtonStyle(bgColor: .blue))
                                .disabled(controller.vehicleProgress ?? 0 < 1)
                                
                                Button("Token") {
                                    controller.useToken(vehicle: sev)
                                }
                                .disabled(controller.vehicleProgress ?? 1.0 >= 1)
                                .buttonStyle(NeumorphicButtonStyle(bgColor: .red))
                                
                                Button("Cancel") {
                                    print("Cancelling")
                                    controller.cancelSelection()
                                }
                                .buttonStyle(NeumorphicButtonStyle(bgColor: .orange))
                                
                                Button("Simulate") {
                                    print("Go Simulate")
                                }
                                .buttonStyle(NeumorphicButtonStyle(bgColor: .orange))
                                
                                Button("Inventory") {
                                    print("Go to Inventory")
                                    controller.setupInventory(vehicle: sev)
                                }
                                .buttonStyle(NeumorphicButtonStyle(bgColor: .orange))
                            }
                            .padding()
                            
                        }
                    }
                }
                
            case .selectedBuildEnd(let sev):
                
                HStack(alignment: .top, spacing: 4) {
                    
                    // List
                    sideList
                        .frame(minWidth: 140, maxWidth: 180, alignment: Alignment.leading)
                    
                    // Main
                    ScrollView {
                        VStack {
                            Group {
                                Text("Ready Vehicle")
                                    .font(.title)
                                    .foregroundColor(.blue)
                                    .padding()
                                Text("Engine: \(sev.engine.rawValue)")
                                
                                HStack {
                                    Image(systemName: "scalemass")
                                    Text("\(sev.engine.payloadLimit * 100)Kg")
                                }
                                .font(.title2)
                                
                                Text("Simulation: \(sev.simulation) hrs")
                                    .padding([.top])
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
                            
                            Divider()
                            HStack {
                                
                                
                                Button("Cancel") {
                                    print("Cancelling")
                                    controller.cancelSelection()
                                }
                                .buttonStyle(NeumorphicButtonStyle(bgColor: Color.blue))
                                
                                Button("Simulate") {
                                    print("Go Simulate")
                                }
                                .buttonStyle(NeumorphicButtonStyle(bgColor: Color.blue))
                                
                                Button("Inventory") {
                                    print("Go to Inventory")
                                    controller.setupInventory(vehicle: sev)
                                }
                                .buttonStyle(NeumorphicButtonStyle(bgColor: Color.blue))
                                
                                if sev.engine != .Hex6 {
                                    Button("Descent") {
                                        print("Go to Descent")
                                        controller.setupDescentInventory()
                                        //                                    controller.setupInventory(vehicle: sev)
                                    }
                                    .buttonStyle(NeumorphicButtonStyle(bgColor: Color.blue))
                                }
                                
                                Divider()
                                
                                Button("🚀 Launch") {
//                                    controller.launch(vehicle: sev)
                                    controller.garageStatus = .planning(stage: .PrepLaunch)
                                }
                                .disabled(controller.vehicleProgress ?? 0 < 1)
                                .buttonStyle(NeumorphicButtonStyle(bgColor: Color.blue))
                                
                            }
                            .padding()
                        }
                    }
                }
                
            case .selectedTravel( _):
                
                HStack(alignment: .top, spacing: 4) {
                    
                    // List
                    sideList
                        .frame(minWidth: 140, maxWidth: 180, alignment: Alignment.leading)
                    
                    // Content
                    ScrollView {
                        TravellingVehicleView(controller: controller)
                    }
                }
                
            // Making a new Vehicle
            case .planning(let stage):
                
                switch stage {
                    
                    case .Engine:       // Selecting Engine
                        BuildingVehicleView(garageController: controller)
                        
                    case .Inventory:    // Adding Tanks, Batteries, and Solar array
                        VehicleInventoryView(controller: controller)
                        
                    case .Descent:      // Adding Ingredients, Peripherals, and BotTech
                        DescentInventoryView(controller:controller, vehicle:controller.selectedVehicle!)
                        
                    case .Crew:         // Selecting Passengers
                        Group {
                            Text("Passengers")
                            Text("Passengers")
                        }
                        
                    case .PrepLaunch:   // Last Warnings
                        LaunchingVehicleView(vehicle: controller.selectedVehicle!, controller:controller)
                        
                    case .Launching:    // Animation
                        PostLaunchVehicleView(garageController: controller, launchController: LaunchSceneController(vehicle: controller.selectedVehicle!))

                        
                }
                
            case .simulating:
                VStack {
                    Text("Simulation View")
                    Text("Try the simulator")
                }
            }
        }
        .frame(minWidth: 700, idealWidth: 800, maxWidth: 800, minHeight: 400, idealHeight: 500, maxHeight: 500, alignment:.top)
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
        }
        
    }
    
}

// MARK: - Vehicles Selected

struct TravellingVehicleView: View {
    
    @ObservedObject var controller:GarageViewModel
    
    /// The popover
    @State var popTrunk:Bool = false
    
    var vehicle:SpaceVehicle
    
    init(controller:GarageViewModel) {
        guard let vehicle = controller.selectedVehicle else { fatalError() }
        self.controller = controller
        self.vehicle = vehicle
    }
    
    var body: some View {
        
        VStack {
            
            // Intro
            Group {
                Text("Travelling Vehicle: \(vehicle.name)")
                    .font(.headline)
                    .foregroundColor(.orange)
                    .padding(6)
                Divider()
                
                // Basics (Engine, Antenna, Satellite
                Text("Engine: \(vehicle.engine.rawValue)")
                
                Button("Trunk") {
                    popTrunk.toggle()
                }
                .buttonStyle(NeumorphicButtonStyle(bgColor: .blue))
                .popover(isPresented: $popTrunk) {
                    VehicleTrunkView(vehicle: vehicle)
                }
                
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

                        GameActivityView(vehicle: vehicle)
                        
                        Text("Simulation: \(vehicle.simulation) hrs")
                        Divider()
                        
                        // Buttons
                        HStack {
//                            Button("Stop") {
//                                print("You can't stop me!")
//                            }
//                            Button("Boost") {
//                                print("You can't boost me!")
//                            }
                            Button("Back") {
                                print("Cancelling")
                                controller.cancelSelection()
                            }
                            .buttonStyle(NeumorphicButtonStyle(bgColor: .blue))
                        }
                        .padding()
                        
                    case .MarsOrbit:
                        
                        Text("In Orbit")
                        Text("Simulation: \(vehicle.simulation) hrs")
//                        CirclePercentIndicator(percentage: 1.0)
                        GameActivityView(vehicle: vehicle)
                        
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
                                        .buttonStyle(NeumorphicButtonStyle(bgColor: .blue))
                                        .foregroundColor(.red)
                                    case .Rover, .Transporter, .Terraformer:
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
                            Button("Farewell !") {
                                print("Cancelling")
                                controller.cancelSelection()
                            }
                            .buttonStyle(NeumorphicButtonStyle(bgColor: .blue))
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
                            .buttonStyle(NeumorphicButtonStyle(bgColor: .blue))
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

//struct TravellingVehicle_Previews: PreviewProvider {
//
//    static var previews: some View {
//        let controller = GarageViewModel()
//        let vehicle = SpaceVehicle.biggerExample()
//        controller.selectedVehicle = vehicle
//
//        return TravellingVehicleView(controller: controller)
//    }
//}
