//
//  LSSView.swift
//  SkyNation
//
//  Created by Carlos Farini on 9/12/21.
//

import SwiftUI

struct LSSView: View {
    
    @ObservedObject var controller:LSSController
    @State var popTutorial:Bool = false
    
    private static let myGradient = Gradient(colors: [Color.red.opacity(0.6), Color.blue.opacity(0.7)])
    private static let unseGradient = Gradient(colors: [Color.red.opacity(0.3), Color.blue.opacity(0.3)])
    private let selLinear = LinearGradient(gradient: myGradient, startPoint: .topLeading, endPoint: .bottomTrailing)
    private let unselinear = LinearGradient(gradient: unseGradient, startPoint: .topLeading, endPoint: .bottomTrailing)
    
    init(scene:GameSceneType) {
        self.controller = LSSController(scene: scene)
    }
    
    var body: some View {
        VStack {
            // Header
            header
            
            switch controller.viewState {
                case .Air:
                    ScrollView {
                        VStack {
                            LSSAirView(air:$controller.air, requiredAirVol:controller.requiredAir)
                        }
                    }
                // Tank, or Box
                case .Resources(let type):
                    HStack {
                        // Left View: List of Resources
                        List() {
                            // Tanks
                            Section(header:
                                        HStack {
                                            Text("Tanks")
                                            Spacer()
                                            Button("⇣") {
                                                let tks = self.controller.tanks
                                                let tks2 = tks.sorted(by: { $0.current < $1.current })
                                                self.controller.tanks = tks2
                                            }
                                            .padding(.trailing, 6)
                                        }) {
                                ForEach(controller.tanks) { tank in
                                    TankRow(tank: tank)
                                        .onTapGesture(count: 1, perform: {
                                            controller.updateState(newState: .Resources(type: .Tank(tank: tank)))
                                        })
                                }
                            }
                            
                            // Ingredients - Boxes
                            Section(header: Text("Ingredients")) {
                                ForEach(controller.boxes) { storageBox in
                                    HStack {
                                        storageBox.type.image()! //?? Image(systemName:"questionmark")
                                            .resizable()
                                            .frame(width:28, height:28)
                                            .aspectRatio(contentMode: .fit)
                                        
                                        VStack(alignment:.leading) {
                                            Text("\(storageBox.type.rawValue)")
                                            Text("\(storageBox.current)/\(storageBox.type.boxCapacity())")
                                        }
                                        
                                    }
                                    .onTapGesture(count: 1, perform: {
                                        // Select Box Here
//                                        controller.didSelect(utility: storageBox)
                                        controller.updateState(newState: .Resources(type: .Box(box: storageBox)))
                                    })
                                }
                            }
                        }
                        .frame(minWidth:180, maxWidth:220, minHeight:200, maxHeight: .infinity)
                        
                        // Right View (Detail)
                        switch type {
                            case .Tank(let tankObject):
                                
                                ScrollView {
                                    TankDetailView(tank: tankObject, controller: controller)
                                }
                                .frame(maxWidth:.infinity, minHeight:200, maxHeight:.infinity)
                                
                            case .Box(let storage):
                                
                                // Storage Box
                                StorageBoxDetailView(box:storage)
                                    .frame(maxWidth:.infinity, minHeight:200, maxHeight:.infinity)
                                
                            case .None:
                                // No Selection
                                noSelectionView
                        }
                    }
                
                case .Machinery(let mType):
                    HStack {
                        List(controller.peripherals) { peripheral in
                            HStack {
                                // Image
                                peripheral.getImage()
                                    .frame(width:42, height:42)
                                VStack {
                                    Text("\(peripheral.peripheral.rawValue)")
                                    Text("Power: \(peripheral.powerOn ? "on":"false")\(peripheral.isBroken ? " broken":"")")
                                        .foregroundColor((peripheral.isBroken || !peripheral.powerOn) ? .red:.white)
                                }
                            }
                            .background(mType.isSelected(peripheral:peripheral) == true ? Color.blue.opacity(0.3):Color.clear)
                            .onTapGesture {
                                controller.updateState(newState: .Machinery(type: .Machine(peripheral: peripheral)))
                            }
                        }
                        .frame(minWidth:180, maxWidth:220, minHeight:200, maxHeight: .infinity)
                        
                        // Detail View
                        // ScrollView {
                            switch mType {
                                case .None:
                                    noSelectionView
                                    
                                case .Machine(let peripheral):
                                    LSSMachineView(controller:controller, peripheral:peripheral)
                            }
                        // }
//                        .frame(minWidth: 400, maxWidth:.infinity)
                    }
                    
                case .Energy:
                    
                    ScrollView {
                        LSSEnergy(controller:controller)
                    }
                    .frame(maxHeight:800)
                    
                case .Systems:
                    ScrollView {
                        LSSReportView(controller:controller)
                    }
                    .frame(maxHeight:800)
                    
            }
        }
        .frame(minWidth: 700, minHeight: 350, idealHeight:500, maxHeight: .infinity, alignment:.topLeading)
    }
    
    var tabber: some View {
        // Tabs
        VStack {
            HStack {
                ForEach(LSSTab.allCases, id:\.self) { aTab in
                    Text(aTab.emoji).font(.largeTitle)
                        .padding(5)
                        .background(controller.selectedTab == aTab ? selLinear:unselinear)
                        .cornerRadius(4)
                        .clipped()
                        .border(controller.selectedTab == aTab ? Color.blue:Color.clear, width: 1)
                        .cornerRadius(6)
                        .help(controller.selectedTab.rawValue)
                        .onTapGesture {
                            controller.updateTabSelection(tab: aTab)
                        }
                }
                
                Spacer()
            }
            .padding(.horizontal, 6)
            .font(.title3)
        }
    }
    
    var header: some View {
        Group {
            HStack() {
                VStack(alignment:.leading) {
                    Text("♻️ Life Support Systems")
                        .font(.largeTitle)
                    Text("Where life is supported")
                        .foregroundColor(.gray)
                        .font(.caption)
                }
                Spacer()
                
                // Tutorial
                Button(action: {
                    print("Question ?")
                    popTutorial.toggle()
                }, label: {
                    Image(systemName: "questionmark.circle")
                        .font(.title2)
                })
                .buttonStyle(SmallCircleButtonStyle(backColor: .orange))
                .popover(isPresented: $popTutorial) {
                    TutorialView(tutType: .LSSView)
                }
                
                // Close
                Button(action: {
                    NotificationCenter.default.post(name: .closeView, object: self)
                }) {
                    Image(systemName: "xmark.circle")
                        .font(.title2)
                }.buttonStyle(SmallCircleButtonStyle(backColor: .pink))
            }
            .padding([.leading, .trailing, .top], 8)
            
            // Segment Picker
            tabber
            
            Divider().offset(x: 0, y: -5)
        }
    }
    
    var noSelectionView: some View {
        // No Selection
        VStack(alignment: .center) {
            Spacer()
            Text("< Nothing selected >").foregroundColor(.gray)
            Divider()
            Text("Select something to view details").foregroundColor(.gray)
            Spacer()
        }
        .frame(maxWidth:.infinity, minHeight:200, maxHeight:.infinity)
    }
    
}

struct LSSAirView:View {
    
    @Binding var air:AirComposition
    var requiredAirVol:Int
    
    private let goodQualities:[AirQuality] = [.Great, .Good]
    
    var body: some View {
        VStack(alignment:.leading) {
            let airPressure = Double(air.getVolume()) / max(1.0, Double(requiredAirVol)) * 100.0
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Air Quality: \(air.airQuality().rawValue)")
                        .font(.title)
                        .foregroundColor(goodQualities.contains(air.airQuality()) ? .green:.orange)
                    
                    Text("Volume: \(Double(air.getVolume()), specifier: "%.2f") m3 | Required: \(Double(requiredAirVol), specifier: "%.2f") m3")
                        .foregroundColor(GameColors.lightBlue)
                    Text("Pressure: \(airPressure, specifier: "%.2f") KPa")
                        .foregroundColor(.green)
                }
                
                Spacer()
                
            }
            .padding()
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Air Composition")
                    .font(.title)
                    .foregroundColor(.blue)
                    .padding()
                AirCompositionView(air: air)
                    .padding([.bottom, .top], 20)
            }
            .padding([.bottom], 10)
        }
    }
}

struct LSSMachineView:View {
    
    @ObservedObject var controller:LSSController
    var peripheral:PeripheralObject
    
    var body: some View {
        
        // Detail View
        ScrollView {
            
            VStack {
                
                // Presentation
                Text("\(peripheral.peripheral.rawValue)")
                    .font(.title)
                
                if let _ = peripheral.getImage() {
                    peripheral.getImage()
                        .fixedSize()
                        .frame(width: 64, height: 64, alignment: .center)
                } else {
                    Image(systemName: "questionmark")
                        .fixedSize()
                        .frame(width: 64, height: 64, alignment: .center)
                }
                
                Text(peripheral.peripheral.describer)
                    .foregroundColor(.gray)
                    .frame(width: 300, alignment: .center)
                
                Divider()
                
                // Conditions
                Group {
                    Text("Breakable: \(peripheral.breakable ? "YES":"NO")")
                        .foregroundColor(peripheral.breakable ? Color.orange:Color.green)
                    
                    Text("Broken: \(peripheral.isBroken ? "YES":"NO")")
                        .foregroundColor(peripheral.isBroken ? Color.red:Color.green)
                    
                    Text("Power: \(peripheral.powerOn ? "On":"Off")")
                        .foregroundColor(peripheral.powerOn ? Color.green:Color.orange)
                    
                    // Time since fixed
                    if let d = peripheral.lastFixed?.timeIntervalSince(Date()) {
                        Text("Time (let d): \(d) s")
                    }
                }
                
                Divider()
                
                if !peripheral.peripheral.instantUse.isEmpty {
                    Group {
                        Text("For 100 energy, this Peripheral can be used intantly to perform the following operation:")
                            .frame(width: 300, alignment: .center)
                            .foregroundColor(.gray)
                            .padding([.bottom], 6)
                        
                        Text(peripheral.peripheral.instantUse)
                            .frame(width: 300, alignment: .center)
                            .padding([.bottom], 6)
                        
                        ForEach(controller.periUseMessages, id:\.self) { msg in
                            Text(msg)
                                .foregroundColor(.orange)
                                .frame(width: 300, alignment: .center)
                        }
                        
                        ForEach(controller.periUseIssues, id:\.self) { msg in
                            Text(msg)
                                .foregroundColor(.red)
                                .frame(width: 300, alignment: .center)
                        }
                        
                        Button("Instant Use") {
                            //                        print("Instause!")
                            //                        controller.instantUse(peripheral: peripheral)
                            controller.instantUse(peripheral: peripheral)
                        }
                        .buttonStyle(NeumorphicButtonStyle(bgColor:.orange))
                        
                        Divider()
                    }
                }
                
                // Buttons
                HStack {
                    Button("Fix") {
                        controller.fixBroken(peripheral: peripheral)
                    }
                    .buttonStyle(NeumorphicButtonStyle(bgColor:.orange))
                    .disabled(!peripheral.isBroken)
                    
                    Button("Break") {
                        peripheral.isBroken.toggle()
                    }
                    .buttonStyle(NeumorphicButtonStyle(bgColor:.orange))
                    .disabled(peripheral.isBroken)
                    
                    Button(peripheral.powerOn ? "Power off":"Power on") {
                        peripheral.powerOn.toggle()
                    }
                    .buttonStyle(NeumorphicButtonStyle(bgColor:.orange))
                    .disabled(peripheral.isBroken)
                    //                Toggle("Power", isOn: $peripheral.powerOn)
                }
                .padding()
            }
        }
        
        .frame(minWidth: 400, maxWidth:.infinity)
    }
}

struct LSSEnergy: View {
    
    @ObservedObject var controller:LSSController
    
    var body: some View {
        
        VStack {
            Group {
                VStack {
                    HStack {
                        Text("Energy")
                            .font(.headline)
                            .foregroundColor(.orange)
                        ZStack {
                            ProgressBar(min: 0.0, max: Double(controller.zCapLevel), value: .constant(Double(controller.zCurrentLevel)), color: .red)
                            Text("Z Level: \(controller.zCurrentLevel, specifier:"%.2f")")
                        }
                    }
                    .frame(idealHeight: 20, maxHeight: 20)
                    
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 8) {
                        
                        Text("Breakdown of energy")
                            .font(.headline)
                            .foregroundColor(.gray)
                        
                        Text("Solar Panels x \(controller.zPanels.count) Energy produced: \(controller.zProduction) kW/h")
                            .font(.callout)
                            .foregroundColor(.green)
                        
                        Text("Peripherals: \(controller.peripherals.count) Consumption: \(controller.zConsumeMachine) kW/h")
                            .font(.callout)
                            .foregroundColor(.orange)
                        
                        Text("Other Consumption: \(controller.zConsumeModules) kW/h")
                            .font(.callout)
                            .foregroundColor(.orange)
                        
                        Text("Human Consumption: \(controller.zConsumeHumans) kW/h")
                            .font(.callout)
                            .foregroundColor(.orange)
                        
                        HStack {
                            Text("Delta Z: \(controller.zDelta > 0 ? "+":"") \(controller.zDelta)")
                                .font(.callout)
                                .foregroundColor(controller.zDelta > 0 ? Color.green:Color.red)
                            Text("Delta Z refers to gaining or losing power in batteries")
                                .foregroundColor(.gray)
                            Spacer()
                        }
                        Spacer()
                        
                    }.padding(.leading)
                }
            }
            .padding()
            
            // Batteries
            LazyVGrid(columns: [GridItem(.fixed(120)), GridItem(.fixed(120)), GridItem(.fixed(120)), GridItem(.fixed(120))], alignment: .center, spacing: 16, pinnedViews: /*@START_MENU_TOKEN@*/[]/*@END_MENU_TOKEN@*/, content: {
                ForEach(controller.batteries) { battery in
                    VStack {
                        Image("carBattery")
                            .renderingMode(.template)
                            .resizable()
                            .colorMultiply(.red)
                            .frame(width: 32.0, height: 32.0)
                            .padding([.top, .bottom], 8)
                        ProgressView("\(battery.current) of \(battery.capacity)", value: Float(battery.current), total: Float(battery.capacity))
                    }
                    .frame(width:100)
                    .padding([.leading, .trailing, .bottom], 6)
                    .background(Color.black)
                    .cornerRadius(12)
                    
                }
            })
            .padding([.bottom], 32)
        }
    }
}

struct LSSReportView: View {
    
    @ObservedObject var controller:LSSController
    
    var body: some View {
        VStack {
            
            HStack(spacing:12) {
                
                // General Status
                VStack(alignment:.leading) {
                    Text("★ Status").foregroundColor(.orange)
                    Text("👤 Head count: \(controller.headCount)")
                    Text("☀️ Energy Input: \(controller.zProduction)")
                    Text("☁️ Air Quality: \(controller.air.airQuality().rawValue)")
                        .padding([.bottom])
                        .foregroundColor([AirQuality.Good, AirQuality.Great].contains(controller.air.airQuality()) ? Color.green:Color.orange)
                    
                    HStack(spacing:12) {
                        #if os(macOS)
                        Image(nsImage: GameImages.currencyImage)
                            .aspectRatio(contentMode: .fit)
                            .frame(width:22, height:22)
                        #else
                        Image(uiImage: GameImages.currencyImage)
                            .aspectRatio(contentMode: .fit)
                            .frame(width:22, height:22)
                        #endif
                        
                        VStack(alignment:.leading) {
                            let dbShared = LocalDatabase.shared
                            let mot = dbShared.station?.truss.moneyFromAntenna() ?? 0
                            let pot = LocalDatabase.shared.player?.money ?? 0
                            
                            Text("\(GameFormatters.numberFormatter.string(from:NSNumber(value:pot)) ?? "---") Sky Coins")//.font(.title2)
                            Text("📡 lvl \(controller.station?.truss.antenna.level ?? 0), + 🪙 \(mot)").foregroundColor(.gray)
                        }
                    }
                }
                .padding(8)
                
                Divider()
                
                // Waste Management
                VStack(alignment:.leading) {
                    
                    Text("♳ Waste Management")
                        .font(.title2)
                        .foregroundColor(.orange)
                        .padding([.bottom])
                    
                    let wasteLiquid = controller.wLiquidCurrent
                    let wasteLiquidCap = controller.wLiquidCapacity
                    
                    if wasteLiquidCap > 0 {
                        let wasteRatio:Double = Double(wasteLiquid) / Double(wasteLiquidCap)
                        let wasteLiquidPct = Int(wasteRatio * 100.0)
                        ProgressView("💦 liquid | \(wasteLiquid) of \(wasteLiquidCap). \(wasteLiquidPct)%", value: Float(wasteLiquid), total: Float(wasteLiquidCap))
                    } else {
                        Text("< No liquid waste container >").foregroundColor(.gray)
                    }
                    
                    let wasteSolid = controller.wSolidCurrent
                    let wasteSolidCap = controller.wSolidCapacity
                    
                    if wasteSolidCap > 0 {
                        let solidPCT:Double = max(1.0, Double(wasteSolid)) / max(1.0, Double(wasteSolidCap))
                        let wasteSolidPct = Int(solidPCT) * 100
                        ProgressView("💩 solid |  \(wasteSolid) of \(wasteSolidCap). \(wasteSolidPct)%", value: Float(wasteSolid), total: Float(wasteSolidCap))
                    } else {
                        Text("< No solid waste container >").foregroundColor(.gray)
                    }
                }
                .padding(8)
                .frame(maxWidth:250)
                
                Divider()
                
                // Future (lasting)
                VStack(alignment:.leading) {
                    
                    let foodLasting = Int(controller.food.count / max(1, controller.headCount))
                    let waterLasting = Int(controller.liquidWater / max(1, (controller.headCount * GameLogic.waterConsumption)))
                    let oxygenLasting = Int(controller.air.o2 / max(1, (controller.headCount * 2)))
                    
                    Text("⏱ Future")
                        .font(.title3)
                        .foregroundColor(.orange)
                    
                    HStack {
                        CautionStripeShape()
                            .fill(Color.orange.opacity(0.5), style: FillStyle(eoFill: false, antialiased: true))
                            .frame(width:64, height:14)
                        Spacer()
                    }
                    
                    Text("💦 Water: \(controller.liquidWater). ⏱ \(waterLasting) hrs.")
                        .foregroundColor(waterLasting > 8 ? .green:.red)
                    Text("🍽 Food: \(controller.food.count). ⏱ \(foodLasting) hrs.")
                        .foregroundColor(foodLasting > 8 ? .green:.red)
                    Text("☁️ Oxygen: \(Int(controller.air.o2)). ⏱ \(oxygenLasting) hrs.")
                        .foregroundColor(oxygenLasting > 8 ? .blue:.red)
                    
                    Spacer()
                }
                .padding(8)
            }
            
            if let report = controller.accountingReport {
                AccountingReportView(report: report)
            }
        }
    }
}

struct AccountingReportView: View {
    
    @State var report:AccountingReport
    
    var body: some View {
        VStack {
            
            HStack(spacing:12) {
                Text("🗒 Accounting").font(.title).foregroundColor(.orange)
                Text("📆 \(GameFormatters.dateFormatter.string(from: report.date))")
                    .font(.title).foregroundColor(.orange)
                Spacer()
            }
            .padding(6)
            .padding(.top, 10)
            
            Divider()
            
            HStack {
                
                // Compare Table
                VStack {
                    Text("Compare").foregroundColor(.orange).font(.title2)
                    
                    HStack(spacing:12) {
                        VStack(alignment:.trailing) {
                            Text("Name").foregroundColor(.gray)
                            Text("Energy")
                            Text("Water")
                            Text("Air Vol.")
                            Text("O2")
                            Text("CO2")
                        }
                        
                        VStack {
                            Text("Start").foregroundColor(.gray)
                            Text("\(report.energyStart)")
                            Text("\(report.waterStart)")
                            Text("\(report.airStart.getVolume())")
                            Text("\(report.airStart.o2)")
                            Text("\(report.airStart.co2)")
                        }
                        
                        VStack {
                            Text("Finish").foregroundColor(.gray)
                            Text("\(report.energyFinish ?? 0)")
                            Text("\(report.waterFinish ?? 0)")
                            Text("\(report.airFinish?.getVolume() ?? 0)")
                            Text("\(report.airFinish?.o2 ?? 0)")
                            Text("\(report.airFinish?.co2 ?? 0)")
                        }
                        
                        VStack {
                            Text("+/-").foregroundColor(.gray)
                            Text("\((report.energyFinish ?? 0) - report.energyStart)")
                            Text("\((report.waterFinish ?? 0) - report.waterStart)")
                            Text("\((report.airFinish?.getVolume() ?? 0) - report.airStart.getVolume())")
                            Text("\((report.airFinish?.o2 ?? 0) - report.airStart.o2)")
                            Text("\((report.airFinish?.co2 ?? 0) - report.airStart.co2)")
                        }
                    }
                }
                .padding()
                
                Spacer()
            }
            
            // Problems + Notes
            VStack(alignment:.leading) {
                // Problems
                Group {
                    Text("⚠️ Issues")
                        .foregroundColor(.orange)
                        .font(.title3)
                    Divider()
                    
                    ForEach(report.listProblems(), id:\.self) { aProblem in
                        Text(aProblem).foregroundColor(.red)
                    }
                }
                
                Group {
                    Text("⚙️ Machinery")
                        .foregroundColor(.orange)
                        .font(.title3)
                        .padding(.vertical, 6)
                    Divider()
                    
                    ForEach(report.peripheralNotes, id:\.self) { perinote in
                        Text(perinote)
                    }
                }
                
                Group {
                    Text("👩‍🚀 Astronauts")
                        .foregroundColor(.green)
                        .font(.title3)
                        .padding(.vertical, 6)
                    
                    Divider()
                    ForEach(report.humanNotes, id:\.self) { humannote in
                        Text(humannote)
                    }
                    
                    Text("--- Waste Production ----").foregroundColor(.gray)
                    Text("💩  \(report.poopFinish ?? 0)")
                    Text("💦  \(report.wasteWaterFinish ?? 0)")
                    Divider()
                }
                
                
                Text("🗒 Notes")
                    .foregroundColor(.blue)
                    .font(.title3)
                    .padding(.vertical, 6)
                ForEach(report.listNotes(), id:\.self) { aNote in
                    Text(aNote).foregroundColor(.gray)
                }
            }
            
        }
        .padding()
        
    }
}

// MARK: - Previews

struct LSSView_Previews: PreviewProvider {
    static var previews: some View {
        LSSView(scene: .SpaceStation)
    }
}

struct StationAccounting_Previews: PreviewProvider {
    static var previews: some View {
        AccountingReportView(report: AccountingReport.example()!)
            .frame(height:1500)
    }
}
