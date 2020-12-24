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
                                    Text("Vehicle \(vehicle.engine.rawValue)")
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
                                    Text("Vehicle \(vehicle.engine.rawValue)")
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
                                    Text("Vehicle \(vehicle.engine.rawValue)")
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
                                }
                            }.padding()
                        }
                        .padding()
                    }
                }
                .frame(minWidth: 600, minHeight: 500, maxHeight: 600, alignment: Alignment.leading)
            case .selectedBuilding(let sev):
                Group {
                    Text("Building Vehicle")
                        .font(.subheadline)
                        .padding()
                    Text("Engine: \(sev.engine.rawValue) | Limit: \(sev.engine.payloadLimit)Kg.")
                    Text("Simulation: \(sev.simulation) hrs")
                    Text("Destination: \(sev.status.rawValue)")
                    Text("Travel Starts: \(GameFormatters.dateFormatter.string(from: sev.dateTravelStarts ?? Date()))")
                    Text("V Engine: \(sev.engine.rawValue)")
                    Divider()
                    HStack {
                        Button("Launch") {
                            controller.launch(vehicle: sev)
                        }
                        Button("Cancel") {
                            print("Cancelling")
                            controller.cancelPlanning()
                        }
                    }
                }
                .frame(minWidth: 600, minHeight: 500, maxHeight: 600, alignment: Alignment.leading)
            case .selectedBuildEnd(let sev):
                VStack {
                    Text("Build finished")
                    Text("V Engine: \(sev.engine.rawValue)")
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
                    
                case .Satellite:  // Selecting Satellite
                    Text("Satellite is deprecated. Choose robot instead")

                case .Inventory:  // Adding Tanks, Batteries, etc
                    VehicleInventoryView(controller: controller)
                    
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
                    VehicleBuiltView(controller: self.controller, vehicle: (controller.selectedVehicle ?? self.vehicle) ?? SpaceVehicle(engine: .Hex6))
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

// MARK: - Vehicles Selected

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
                    controller.cancelPlanning()
                }
                .padding()
            }
        }
    }
    
}

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
                                controller.cancelPlanning()
                                
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
                                controller.cancelPlanning()
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
                                controller.cancelPlanning()
                            }
                        }
                        .padding()
                    default:
                        Text("Other: \(vehicle.status.rawValue)")
                        Divider()
                        HStack {
                            Button("<< Go Back") {
                                print("Cancelling")
                                controller.cancelPlanning()
                            }
                        }
                        .padding()
                        
                }
            }
        }
    }
}

struct NewTankView: View {
    /// Grid View (1 row)
    private var gridRow:[GridItem] = [
        GridItem(.fixed(100), spacing: 12)
    ]
    
    var tanks:[Tank] // = [Tank(type: .o2), Tank(type: .ch4), Tank(type: .co2)]
    
    init(tanks:[Tank]) {
        self.tanks = tanks
    }
    
    var body: some View {
        ScrollView {
            LazyHGrid(rows: gridRow, alignment: .center, spacing: 12, pinnedViews: [.sectionHeaders, .sectionFooters]) {
                
                    ForEach(tanks) { tank in
                        ZStack {
                            VStack {
                                Image("Tank")
                                    .resizable()
                                    .frame(width: 48, height: 48, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                                    .aspectRatio(contentMode: .fit)
                                
                                HStack {
                                    Text(tank.type.rawValue)
                                        .font(.title)
                                    Button(action: {
                                        print("Remove this tank")
                                    }, label: {
                                        Image(systemName: "trash")
                                    })
                                }
                            }
                            .padding()
                        }
                        .border(Color.gray, width:2)
                        .cornerRadius(12)
                    }
            }
            .padding()
        }
        .frame(minWidth: 300, idealHeight:140, maxHeight: 150, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
    }
}


// MARK: - Previews

struct GarageView_Previews: PreviewProvider {
    static var previews: some View {
        GarageView()
    }
}

struct NewTankview_Previews: PreviewProvider {
    static var previews: some View {
        NewTankView(tanks:[Tank(type: .o2), Tank(type: .ch4), Tank(type: .co2)])
    }
}

/*
struct VehicleBuildingView_Previews: PreviewProvider {
    
    static var previews: some View {
        let model = GarageViewModel()
        let vehicle = SpaceVehicle(engine: .Hex6)
        model.selectedVehicle = vehicle
        return VehicleBuildingView(controller: model)
    }
}
*/
/*
struct VehicleBuilt_Preview: PreviewProvider {
    static var previews: some View {
        let model = GarageViewModel()
        let vehicle = SpaceVehicle.builtExample()
        model.selectedVehicle = vehicle
        return VehicleBuiltView(controller: model, vehicle: vehicle)
    }
}
*/
/*
struct TravellingVehicles_Previews: PreviewProvider {
    static var previews: some View {
        let model = GarageViewModel()
        let vehicle = SpaceVehicle.builtExample()
        model.selectedVehicle = vehicle
        return TravellingVehicleView(controller: model, vehicle: vehicle)
    }
}
*/

