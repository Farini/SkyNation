//
//  LifeSupportView.swift
//  SkyTestSceneKit
//
//  Created by Farini on 9/26/20.
//  Copyright © 2020 Farini. All rights reserved.
//

import SwiftUI

enum AirControlOptions: String, CaseIterable {
    case AirLevels
    case Resources
    case Energy
    case Accounting
}

struct LifeSupportView: View {
    
    @ObservedObject var lssModel:LSSModel
    @State private var airOption:AirControlOptions = .Energy
    @State var selectedTank:Tank?
    @State var selectedPeripheral:PeripheralObject?
    @State var selectedBox:StorageBox?
    
    init() {
        self.lssModel = LSSModel()
    }
    
    var body: some View {
        
        VStack {
            
            // Header
            VStack {
                
                HStack(alignment: VerticalAlignment.lastTextBaseline, spacing: nil) {
                    Text("♻️ Life Support Systems").font(.largeTitle)
                    Text("Where life is supported").foregroundColor(.gray)
                    Spacer()
                    Text("S$:3,456").foregroundColor(.gray)
                }
                
                Picker("", selection: $airOption) {
                    ForEach(AirControlOptions.allCases, id:\.self) { airOpt in
                        Text(airOpt.rawValue)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                
                
            }
            .padding([.top, .leading, .trailing])
            Divider()
            
            Group {
                
                switch airOption {
                    case .AirLevels:
                        Group {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Air Quality: \(lssModel.airQuality)")
                                    Text("Volume: \(Double(self.lssModel.air.volume), specifier: "%.2f") m3 | \(Double(self.lssModel.requiredAir), specifier: "%.2f") m3")
                                        .foregroundColor(GameColors.lightBlue)
                                    Text("Pressure: \(Double(self.lssModel.currentPressure), specifier: "%.2f") KPa")
                                        .foregroundColor(.green)
                                    
                                    
                                }
                                
                                Spacer()
                                
                                // Timer
                                VStack {
                                    HStack {
                                        Button(action: {
                                            self.lssModel.prepTimer()
                                        }) {
                                            Text("Start")
                                        }
                                        
                                        Button(action: {
                                            self.lssModel.stop()
                                        }) {
                                            Text("Stop")
                                        }
                                        Button(action: {
                                            self.lssModel.reset()
                                        }) {
                                            Text("Reset")
                                        }
                                        Text("\(lssModel.counter)")
                                            .font(.largeTitle)
                                    }
                                    Text("Account: \(lssModel.accountDate, formatter:GameFormatters.dateFormatter)")
                                    Text("Humans count: \(lssModel.inhabitants)")
                                }
                                
                                
                            }
                            .padding()
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Air Composition").font(.callout).foregroundColor(.blue)
                                    .padding()
                                AirCompositionView(air: lssModel.air)
                                    .padding([.bottom, .top], 20)
                            }
                            .padding([.bottom], 10)
                        }
                    case .Resources:
                        // Tanks + Peripherals
                        Group {
                            
                            HStack {
                                
                                // Left View: List of Resources
                                List() {
                                    // Tanks
                                    Section(header: Text("Tanks")) {
                                        ForEach(lssModel.tanks) { tank in
                                            Text("Tank of \(tank.type.rawValue)")
                                                .onTapGesture(count: 1, perform: {
                                                    selectedPeripheral = nil
                                                    selectedBox = nil
                                                    selectedTank = tank
                                                })
                                        }
                                    }
                                    
                                    // Peripherals
                                    Section(header: Text("Peripherals")) {
                                        ForEach(lssModel.peripherals) { peripheral in
                                            Text("Device \(peripheral.peripheral.rawValue)")
                                                .onTapGesture(count: 1, perform: {
                                                    selectedTank = nil
                                                    selectedBox = nil
                                                    selectedPeripheral = peripheral
                                                })
                                        }
                                    }
                                    // Ingredients - Boxes
                                    Section(header: Text("Boxes")) {
                                        ForEach(lssModel.boxes) { storageBox in
                                            Text("Box of \(storageBox.type.rawValue)")
                                                .onTapGesture(count: 1, perform: {
                                                    // Select Box Here
                                                    selectedTank = nil
                                                    selectedPeripheral = nil
                                                    selectedBox = storageBox
                                                })
                                        }
                                    }
                                }
                                .frame(minWidth:180, maxWidth:220, minHeight:200)
                                
                                // Right: Detail View
                                ScrollView() {
                                    VStack {
                                        if selectedTank != nil {
                                            TankView(tank: selectedTank!, model: self.lssModel)
                                        }else if selectedPeripheral != nil {
                                            VStack {
                                                Text("Peripheral: \(selectedPeripheral!.peripheral.rawValue)")
                                                    .font(.headline)
                                                
                                                // Image
                                                selectedPeripheral!.getImage()
                                                
                                                Text("Breakable: \(selectedPeripheral!.breakable ? "YES":"NO")")
                                                    .foregroundColor(selectedPeripheral!.breakable ? Color.red:Color.green)
                                                
                                                Text("Broken: \(selectedPeripheral!.isBroken ? "YES":"NO")")
                                                    .foregroundColor(selectedPeripheral!.isBroken ? Color.red:Color.green)
                                                
                                                Text("Power: \(selectedPeripheral!.powerOn ? "On":"Off")")
                                                    .foregroundColor(selectedPeripheral!.powerOn ? Color.green:Color.orange)
                                                
                                                HStack {
                                                    Button(action: {
                                                        lssModel.powerToggle(peripheral: selectedPeripheral!)
                                                    }, label: {
                                                        VStack {
                                                            Image(systemName: "power")
                                                                .foregroundColor(selectedPeripheral!.powerOn ? Color.orange:Color.blue)
                                                            Text("Power")
                                                        }
                                                    })
                                                    if selectedPeripheral!.isBroken {
                                                        Button(action: {
                                                            lssModel.fixBroken(peripheral: selectedPeripheral!)
                                                        }, label: {
                                                            VStack {
                                                                Image(systemName: "wrench.and.screwdriver.fill")
                                                                    .foregroundColor(selectedPeripheral!.powerOn ? Color.orange:Color.blue)
                                                                Text("Fix")
                                                            }
                                                        })
                                                        .padding()
                                                    }
                                                }
                                                
                                                // Time since fixed
                                                if let d = selectedPeripheral!.lastFixed?.timeIntervalSince(Date()) {
                                                    Text("Time (let d): \(d) s")
                                                }
                                            }
                                            
                                        }else if selectedBox != nil {
                                            VStack {
                                                Text("Box")
                                                Text("Box of: \(selectedBox!.type.rawValue)")
                                                Text("\(selectedBox!.current) of \(selectedBox!.capacity)")
                                            }
                                        } else {
                                            VStack(alignment: .leading) {
                                                Text("No selection").foregroundColor(.gray)
                                                Divider()
                                                Text("Select something").foregroundColor(.gray)
                                            }
                                            
                                        }
                                    }
                                    
                                }
                                .frame(maxWidth:.infinity, minHeight:200, maxHeight:220)
                            }
                            
                        }.padding(3)
                        
                    case .Accounting:
                        // Accounting
                        ScrollView {
                            Text("Accounting").font(.headline)
                            Text("Air Vol. \(lssModel.air.volume)")
                            Text("O2: \(lssModel.air.o2)")
                            Text("CO2: \(lssModel.air.co2)")
//                            Text("N2: \(lssModel.air.n2)")
                            Divider()
                            VStack {
                                ForEach(lssModel.accountingProblems, id:\.self) { problem in
                                    Text(problem)
                                }
                            }
                            Divider()
                            HStack {
                                Button("Accounting") {
                                    print("Run accounting")
                                    lssModel.runAccounting()
                                }
                                Button("Test") {
                                    print("Test what?")
                                }
                            }
                        }.padding()
                        
                    case .Energy:
                        ScrollView {
                            // Energy
                            EnergyOverview(energyLevel: $lssModel.levelZ, energyMax: $lssModel.levelZCap, energyProduction: lssModel.energyProduction, batteryCount: lssModel.batteries.count, solarPanelCount: lssModel.solarPanels.count, peripheralCount: lssModel.peripherals.count, deltaZ: $lssModel.batteriesDelta, conumptionPeripherals: $lssModel.consumptionPeripherals, consumptionModules: $lssModel.consumptionModules)
                            ForEach(lssModel.batteries) { battery in
                                HStack {
                                    Image("carBattery")
                                        .renderingMode(.template)
                                        .resizable()
                                        .colorMultiply(.red)
                                        .frame(width: 32.0, height: 32.0)
                                    Text("Battery \(battery.current) of \(battery.capacity)")
                                    FixedLevelBar(min: 0.0, max: Double(battery.capacity), current: Double(battery.current), title: "Health", color: .red)
                                }
                                
                            }
//                            ForEach(0..<lssModel.batteries.count) { idx in
//
//                            }
                        }
                }
            }
        }
    }
}

struct EnergyOverview:View {
    
    @Binding var energyLevel:Double
    @Binding var energyMax:Double
    var energyProduction:Int
    var batteryCount:Int
    var solarPanelCount:Int
    var peripheralCount:Int
    @Binding var deltaZ:Int
    @Binding var conumptionPeripherals:Int
    @Binding var consumptionModules:Int
    
    // batteries, solar panels, peripherals, delta
    var body: some View {
        VStack {
            // Start With the energy View
//            Text("Z: \(energyLevel)").font(.headline).foregroundColor(.orange)
            
            
            // Energy
            Group {
                VStack {
                    HStack {
                        Text("Energy")
                        .font(.headline)
                        .foregroundColor(.orange)
                        ZStack {
                            ProgressBar(min: 0.0, max: energyMax, value: $energyLevel, color: .red)
                            Text("Z Level: \(energyLevel, specifier:"%.2f")")
                        }
                    }
                    .frame(idealHeight: 20, maxHeight: 20, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                    
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 8) {
                        
                        Text("Breakdown of energy")
                            .font(.headline)
                            .foregroundColor(.gray)
                        
                        Text("Solar Panels x \(solarPanelCount) Energy produced: \(energyProduction) kW/h")
                            .font(.callout)
                            .foregroundColor(.green)
                        
                        Text("Peripherals: \(peripheralCount) Consumption: \(conumptionPeripherals) kW/h")
                            .font(.callout)
                            .foregroundColor(.orange)
                        Text("Modules Consumption: \(consumptionModules) kW/h")
                            .font(.callout)
                            .foregroundColor(.orange)
                        HStack {
                            Text("Delta Z: \(deltaZ > 0 ? "+":"") \(deltaZ)")
                                .font(.callout)
                                .foregroundColor(deltaZ > 0 ? Color.green:Color.red)
                            Text("Delta Z refers to gaining or losing power in batteries")
                                .foregroundColor(.gray)
                            Spacer()
                        }
                        Spacer()
                        
                    }.padding(.leading, /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
                    
                    /*
                    HStack {
                        Image("carBattery")
                            .resizable()
                            .frame(width: 32.0, height: 32.0)
                        
                        Text("Batteries: \(batteryCount)")
                        Text("Solar Panels: \(solarPanelCount)")
                        Text("Peripherals: \(peripheralCount)")
                        Text("Delta Z: \(deltaZ)")
                    }.font(.callout)
                    */
                    
                }
            }
            .padding()
        }
        
    }
}



struct LifeSupportView_Previews: PreviewProvider {
    static var previews: some View {
        LifeSupportView()
    }
}

struct TankView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Text("Tank: - Big")
            TankView(tank:LocalDatabase.shared.station!.truss.getTanks().first!)
            Divider()
            Text("Tank: - Small")
            TankViewSmall(tank: LocalDatabase.shared.station!.truss.getTanks().first!)
        }
        
    }
}

extension PeripheralObject {
    func getImage() -> Image? {
        switch self.peripheral {
            case .Airlock:
                return Image("Airlock")
            case .Antenna:
                return Image("Antenna")
            case .Condensator:
                return Image("Condensator")
            case .Methanizer:
                return Image("Methanizer")
            case .Radiator:
                return Image("Radiator")
            case .Roboarm:
                return Image("Roboarm")
            case .ScrubberCO2:
                return Image("Scrubber")
            case .solarPanel:
                return Image("SolarPanel")
            case .storageTank:
                return Image("Tank")
            default:
                print("Don't have an image for that yet")
                return nil
        }
    }
}
