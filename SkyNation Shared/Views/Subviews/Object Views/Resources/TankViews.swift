//
//  TankViews.swift
//  SkyTestSceneKit
//
//  Created by Carlos Farini on 12/4/20.
//  Copyright © 2020 Farini. All rights reserved.
//

import Foundation
import SwiftUI

struct TankViewSmall:View {
    
    var tank:Tank
    @State var selected:Bool = false
    
    private let shape = RoundedRectangle(cornerRadius: 8, style: .continuous)
    private let unselectedColor:Color = Color.white.opacity(0.4)
    private let selectedColor:Color = Color.blue
    
    var body: some View {
        
        HStack {
            
            Image("Tank")
                .resizable()
                .frame(width: 32.0, height: 32.0)
            
            Text("\(tank.type.rawValue.uppercased())")
                .font(.headline)
            
            Spacer()
            
            Text("\(tank.current) of \(tank.capacity)")
                .font(.subheadline)
                // Colors (GREEN > 50%, ORANGE > 0, RED == 0)
                .foregroundColor(tank.current > (tank.capacity / 2) ? Color.green:tank.current > 0 ? Color.orange:Color.red)
            
        }
        .padding(6)
        .frame(maxWidth:180)
        .overlay(
            shape
                .inset(by: selected ? 1.0:0.5)
                .stroke(selected ? selectedColor:unselectedColor, lineWidth: selected ? 1.5:1.0)
        )
    }
}

struct TankRow:View {
    
    @Binding var tank:Tank
    var selected:Bool
    
    var body: some View {
        HStack {
            Image("Tank")
                .resizable()
                .frame(width: 32.0, height: 32.0)
            
            ProgressView(value: Float(tank.current), total:Float(tank.capacity)) {
                HStack {
                    Text(tank.type.rawValue.uppercased())
                    Spacer()
                    Text("\(tank.current) of \(tank.capacity)")
                        .font(.subheadline)
                        // Colors (GREEN > 50%, ORANGE > 0, RED == 0)
                        .foregroundColor(tank.current > (tank.capacity / 2) ? Color.green:tank.current > 0 ? Color.orange:Color.red)
                }
            }
            .foregroundColor(.blue)
            .accentColor(.orange)
        }
        .padding(6)
        .background(Color.black.opacity(0.5))
        .cornerRadius(6)
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(lineWidth: 1.5)
                .foregroundColor(selected ? Color.blue:Color.clear)
        )
        .frame(minWidth: 50, maxWidth: 200, minHeight: 15, maxHeight: 40, alignment: .leading)
        
    }
}

struct TankDetailView: View {
    
    @ObservedObject var controller:LSSController
    @Binding var tank:Tank
    
    @State var sliderValue:Float = 0
    
    var current:Float
    var max:Float
    
    
    @State var discardWhenEmpty:Bool = false
    
    // Popover to change tank type
    @State private var popTankType:Bool = false
    
//    init(tank:Tank, controller:LSSController) {
//
//        self.controller = controller
//
//        let cap = Float(tank.capacity)
//        self.max = cap
//        self.tank = tank
//
//        self.current = Float(tank.current)
//    }
    
    init(controller:LSSController, tank:Binding<Tank>) {
        self.controller = controller
        self._tank = tank
        let cap = Float(tank.wrappedValue.capacity)
        self.current = Float(tank.wrappedValue.current)
        self.max = cap
    }
    
    
    
    var body: some View {
        
        VStack {
            
            Text("Tank \(tank.type.rawValue.uppercased()) \(tank.type.name) ")
                .font(.title3)
                .padding()
            
            HStack {
                // Tank Image
                Image("Tank").resizable()
                    .frame(width: 64.0, height: 64.0)
                
                // Tank Info
                VStack(alignment: .leading) {
                    if tank.capacity > 0 {
                        let frd = Double(tank.current / tank.capacity)
                        Text("\(tank.current) of max \(tank.capacity)")
                        ProgressView("Load \(Int(frd * 100))%", value: frd)
                            .frame(width: 150, alignment: .top)
                    } else {
                        Text("Empty").foregroundColor(.gray)
                    }
                }
            }
            .padding(6)
            .background(Color.black)
            .cornerRadius(12)
            
            generateBarcode(from: tank.id)
            Text(tank.id.uuidString).font(.footnote).foregroundColor(.gray)
            
            // Discard
            Toggle("Discard when empty", isOn: $discardWhenEmpty)
                .onChange(of: discardWhenEmpty, perform: { value in
                    if value == true {
                        tank.discardEmpty = true
                    } else {
                        tank.discardEmpty = false
                    }
                })
            
            // Slider
            Slider(value: $sliderValue, in: 0.0...current) { (changed) in
                print("Slider changed?")
            }
            .frame(maxWidth: 250, alignment: .center)
            Text("\(Int(sliderValue)) of \(Int(current)) max: \(Int(max))")
            
            Spacer()
            
            Divider()
            
            HStack {
                
                Button(action: {
                    print("Throw away (discarding)")
                    controller.discardTank(tank: tank)
                }, label: {
                    HStack {
                        Image(systemName: "trash")
                        Text("Discard")
                    }
                })
                .buttonStyle(GameButtonStyle(labelColor: .red))
                .frame(width:95)
                
                Button(action: {
                    controller.mergeTanks(into: tank)
                }, label: {
                    Text("Merge")
                })
                .buttonStyle(NeumorphicButtonStyle(bgColor: .blue))
                
                Button("Release") {
                    print("Release in air")
                    controller.releaseToAir(tank: tank, amt: Int(self.sliderValue))
                }
                .buttonStyle(NeumorphicButtonStyle(bgColor: .blue))
                .disabled(!controller.canReleaseToAir(tank: tank, amt: Int(sliderValue)))
                
                Button(action: {
                    print("Empty, or define")
                    if tank.current == 0 || tank.type == .empty {
                        // Define
                        popTankType.toggle()
                    } else {
                        // Empty
                    }
                }, label: {
                    if tank.current == 0 || tank.type == .empty {
                        // Define
                        Text("Define")
                    } else {
                        // Empty
                        Text("Empty")
                    }
                })
                .buttonStyle(NeumorphicButtonStyle(bgColor: .blue))
                .popover(isPresented: $popTankType) {
                    VStack {
                        ForEach(TankType.allCases, id:\.self) { tanktype in
                            HStack {
                                Text("\(tanktype.name) \(tanktype.rawValue.uppercased()) Cap:\(tanktype.capacity)")
                                    .padding(6)
                                Spacer()
                            }
                            .frame(maxWidth:200)
                            .onTapGesture {
                                controller.defineTankType(tank: tank, newType: tanktype)
                            }
                        }
                    }
                }
            }
            .padding()
        }
        
        .onAppear() {
            self.tankDiscard(tank: self.tank)
        }
    }
    
    func tankDiscard(tank:Tank) {
        // Checkbox discard empty
        if tank.discardEmpty == true {
            self.discardWhenEmpty = true
        } else {
            self.discardWhenEmpty = false
        }
    }
    
    /// Makes the BarCode from a UUID
    func generateBarcode(from uuid: UUID) -> Image? {
        
        let data = uuid.uuidString.prefix(8).data(using: String.Encoding.ascii)
        if let filter = CIFilter(name: "CICode128BarcodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            
            if let output:CIImage = filter.outputImage {
                
                if let inverter = CIFilter(name:"CIColorInvert") {
                    
                    inverter.setValue(output, forKey:"inputImage")
                    
                    if let invertedOutput = inverter.outputImage {
                        #if os(macOS)
                        let rep = NSCIImageRep(ciImage: invertedOutput)
                        let nsImage = NSImage(size: rep.size)
                        nsImage.addRepresentation(rep)
                        return Image(nsImage:nsImage)
                        #else
                        let uiImage = UIImage(ciImage: invertedOutput)
                        return Image(uiImage: uiImage)
                        #endif
                    }
                    
                } else {
                    #if os(macOS)
                    let rep = NSCIImageRep(ciImage: output)
                    let nsImage = NSImage(size: rep.size)
                    nsImage.addRepresentation(rep)
                    return Image(nsImage:nsImage)
                    #else
                    let uiimage = UIImage(ciImage: output)
                    return Image(uiImage: uiimage)
                    #endif
                }
            }
        }
        
        return nil
    }
}

struct TankOrderView: View {
    
    var tank:TankType
    
    var body: some View {
        ZStack(alignment: Alignment(horizontal: .trailing, vertical: .top)) {
            HStack {
                Image("Tank").resizable()
                    .frame(width: 64.0, height: 64.0)
                VStack(alignment: .leading) {
                    Text(tank.rawValue.uppercased())
                    Text(tank.name)
                    Text("x \(tank.capacity)")
                }
                Spacer()
            }
            .frame(maxWidth:200)
            
            Text("$\(tank.price)")
                // .frame(maxWidth:40)
                .foregroundColor(.gray)
                .padding(4)
                .background(Color.black)
        }
        .padding(4)
        .background(Color.black)
        .cornerRadius(8)
        .frame(maxWidth:200)
        
    }
}

// MARK: - Previews

struct TankRowPreviews:PreviewProvider {
    static var previews: some View {
        VStack {
            TankRow(tank: .constant(LocalDatabase.shared.station.truss.getTanks().first!), selected: false)
            TankRow(tank: .constant(LocalDatabase.shared.station.truss.getTanks().first!), selected: true)
                
            
        }
        .padding()
    }
}

struct TankSmallPreview1: PreviewProvider {
    static var previews: some View {
        VStack {
            TankViewSmall(tank: Tank(type: .co2, full: true))
            TankViewSmall(tank: LocalDatabase.shared.station.truss.getTanks().last!, selected:true)
                .padding()
            
        }
    }
}

struct TankDetailsPreviews:PreviewProvider {
    static var previews: some View {
        VStack {
            TankDetailView(controller: LSSController(scene: .SpaceStation), tank: .constant(LocalDatabase.shared.station.truss.getTanks().first!))
        }
    }
}


struct TankOrder_Previews: PreviewProvider {
    static var previews: some View {
        TankOrderView(tank: TankType.allCases.randomElement()!)
    }
}


