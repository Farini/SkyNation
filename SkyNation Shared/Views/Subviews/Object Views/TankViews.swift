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
    
    var body: some View {
        
        HStack {
            
            Image("Tank")
                .resizable()
                .frame(width: 32.0, height: 32.0)
            
            Text("Tank: \(tank.type.rawValue)")
                .font(.subheadline)
            
            Text("\(tank.current) of \(tank.capacity)")
                .font(.subheadline)
                // Colors (GREEN > 50%, ORANGE > 0, RED == 0)
                .foregroundColor(tank.current > (tank.capacity / 2) ? Color.green:tank.current > 0 ? Color.orange:Color.red)
            
        }
    }
}

struct TankRow:View {
    
    var tank:Tank
    
    var body: some View {
        HStack {
            Image("Tank")
                .resizable()
                .frame(width: 32.0, height: 32.0)
            
            ProgressView(value: Float(tank.current), total:Float(tank.capacity)) {
                HStack {
                    Text(tank.type.rawValue)
                    Text("\(tank.current) of \(tank.capacity)")
                        .font(.subheadline)
                        // Colors (GREEN > 50%, ORANGE > 0, RED == 0)
                        .foregroundColor(tank.current > (tank.capacity / 2) ? Color.green:tank.current > 0 ? Color.orange:Color.red)
                }
            }
            .foregroundColor(.blue)
            .accentColor(.orange)
        }
        .frame(minWidth: 50, maxWidth: 200, minHeight: 15, maxHeight: 40, alignment: .leading)
        
    }
}

struct TankView: View {
    
    @ObservedObject var viewModel:LSSModel
    @State var sliderValue:Float = 0
    
    var current:Float
    var max:Float
    var tank:Tank
    
    // Popover to change tank type
    @State var popTankType:Bool = false
    
    init(tank:Tank, model:LSSModel? = LSSModel()) {
        let cap = Float(tank.capacity)
        self.max = cap
        self.tank = tank
        self.viewModel = model!
        self.current = Float(tank.current)
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
            
            // Slider
//            Slider(value: $sliderValue, in: 0.0...current) { (changed) in
//                print("Slider changed?")
//            }
//            .frame(maxWidth: 250, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
//            Text("\(Int(sliderValue)) of \(Int(current)) max: \(Int(max))")
            
            Spacer()
            
            Divider()
            
            HStack {
//                Button(action: {
//                    print("Release tank in air")
//                }, label: {
//                    Text("Release in air")
//                })
//                .buttonStyle(NeumorphicButtonStyle(bgColor: .blue))
                
                Button(action: {
                    print("Throw away (discarding)")
                    viewModel.discardTank(tank)
                }, label: {
                    Text("Throw away")
                })
                .buttonStyle(NeumorphicButtonStyle(bgColor: .blue))
                
                Button(action: {
//                    print("Release tank in air")
                    self.viewModel.mergeTanks(tank)
                }, label: {
                    Text("Merge")
                })
                .buttonStyle(NeumorphicButtonStyle(bgColor: .blue))
                
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
                    List(TankType.allCases, id:\.self) { tanktype in
                        Text("\(tanktype.name) \(tanktype.rawValue.uppercased()) Cap:\(tanktype.capacity)")
                            .onTapGesture {
                                self.viewModel.defineType(tank, type: tanktype)
                            }
                    }
                }
            }
            .padding()
            

        }
        
    }
    
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
    /*
    func generateBarcode(from uuid: UUID) -> Image? {
        let data = uuid.uuidString.prefix(8).data(using: String.Encoding.ascii)
        
        if let filter = CIFilter(name: "CICode128BarcodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            
            let transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            let smallBarCode = filter.outputImage?.transformed(by:transform)
            
            if let output:CIImage = smallBarCode {
                
                if let inverter = CIFilter(name:"CIColorInvert") {
                    
                    inverter.setValue(output, forKey:"inputImage")
                    
                    if let invertedOutput = inverter.outputImage {
                        let rep = NSCIImageRep(ciImage: invertedOutput)
                        let nsImage = NSImage(size: rep.size)
                        nsImage.addRepresentation(rep)
                        return Image(nsImage:nsImage)
                    }
                    
                } else {
                    let rep = NSCIImageRep(ciImage: output)
                    let nsImage = NSImage(size: rep.size)
                    nsImage.addRepresentation(rep)
                    
                    return Image(nsImage:nsImage)
                }
            }
        }
        
        return nil
    }
 */
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

struct TankViews_Previews: PreviewProvider {
    
    static var previews: some View {
        
        VStack {
            
//            Text("Tank: - Big")
            TankView(tank:LocalDatabase.shared.station!.truss.getTanks().first!)
            
//            Divider()
//
//            Text("Tank: - Small")
//            TankViewSmall(tank: LocalDatabase.shared.station!.truss.getTanks().first!)
            
        }
    }
}

struct TankPreviews2:PreviewProvider {
    static var previews: some View {
        VStack {
            
            TankRow(tank: LocalDatabase.shared.station!.truss.getTanks().first!)
                .padding()
        }
        
    }
}

struct TankOrder_Previews: PreviewProvider {
    static var previews: some View {
        TankOrderView(tank: TankType.allCases.randomElement()!)
    }
}
