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
//                    Text(tank.type.name)
                }
            }
            .foregroundColor(.blue)
            .accentColor(.orange)
            
//            Spacer()
            
        }
//        .padding()
        .frame(minWidth: 50, maxWidth: 200, minHeight: 15, maxHeight: 40, alignment: .leading)
        
    }
}

struct TankView: View {
    @ObservedObject var viewModel:LSSModel
    @State var sliderValue:Float = 0
    var current:Float
    var max:Float
    var tank:Tank
    
    init(tank:Tank, model:LSSModel? = LSSModel()) {
        let cap = Float(tank.capacity)
        self.max = cap
        self.tank = tank
        self.viewModel = model!
        self.current = Float(tank.current)
    }
    
    var body: some View {
        VStack {
            
            Text("Tank: \(tank.type.rawValue)").font(.subheadline).padding()
            
            Image("Tank").resizable()
                .frame(width: 64.0, height: 64.0)
            
            
            Text("\(tank.id)").foregroundColor(.gray)
            Slider(value: $sliderValue, in: 0.0...current) { (changed) in
                print("Slider changed?")
            }
            .frame(maxWidth: 250, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
            .padding(4)
            
            Text("Test: \(Int(sliderValue)) of \(Int(current)) max: \(Int(max))")
            
            Button(action: {
                print("Release tank in air")
//                self.viewModel.releaseInAir(tank: tank, amount: Int(sliderValue))
                //                current = current - sliderValue
            }, label: {
                Text("Release in air")
            }).padding()
        }
        
    }
}

struct TankOrderView: View {
    
    var tank:TankType
    
    var body: some View {
        ZStack(alignment: Alignment(horizontal: .trailing, vertical: .top)) {
            HStack {
//                Spacer()
                Image("Tank").resizable()
                    .frame(width: 64.0, height: 64.0)
                VStack {
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
            
            Text("Tank: - Big")
            TankView(tank:LocalDatabase.shared.station!.truss.getTanks().first!)
            
            Divider()
            
            Text("Tank: - Small")
            TankViewSmall(tank: LocalDatabase.shared.station!.truss.getTanks().first!)
            
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
