//
//  LSSReportView.swift
//  SkyNation
//
//  Created by Carlos Farini on 1/17/22.
//

import SwiftUI

struct LSSReportView: View {
    
    @ObservedObject var controller:LSSController
    
    var body: some View {
        VStack {
            
            HStack(alignment:.top, spacing:8) {
                
                // General Status
                VStack(alignment:.leading) {
                    Text("★ Status")
                        .font(GameFont.section.makeFont())
                        .padding(.vertical, 4)
                    //.foregroundColor(.orange)
                    
                    HStack {
                        CautionStripeShape()
                            .fill(Color.orange.opacity(0.5), style: FillStyle(eoFill: false, antialiased: true))
                            .frame(width:64, height:8)
                        Spacer()
                    }
                    
                    Text("👤 Head count: \(controller.headCount)")
                    // Text("☀️ Energy Input: \(controller.zProduction)")
                    Text("☁️ Air Quality: \(controller.air.airQuality().rawValue)")
                        .padding([.bottom])
                        .foregroundColor([AirQuality.Good, AirQuality.Great].contains(controller.air.airQuality()) ? Color.green:Color.orange)
                    
                    HStack(spacing:8) {
#if os(macOS)
                        Image(nsImage: GameImages.currencyImage)
                            .aspectRatio(contentMode: .fit)
                            .frame(width:20, height:20)
#else
                        Image(uiImage: GameImages.currencyImage)
                            .aspectRatio(contentMode: .fit)
                            .frame(width:20, height:20)
#endif
                        
                        VStack(alignment:.leading) {
                            let dbShared = LocalDatabase.shared
                            let mot = dbShared.station.truss.moneyFromAntenna()
                            let pot = LocalDatabase.shared.player.money
                            
                            Text("\(GameFormatters.numberFormatter.string(from:NSNumber(value:pot)) ?? "---") Sky Coins")//.font(.title2)
                            Text("📡 lvl \(controller.station?.truss.antenna.level ?? 0), +  \(mot)/Hr").foregroundColor(.gray)
                        }
                    }
                }
                .padding(8)
                
                Divider()
                
                // Waste Management
                VStack(alignment:.leading) {
                    
                    Text("♳ Waste")
                        .font(GameFont.section.makeFont())
                    //.foregroundColor(.orange)
                        .padding(.vertical, 4)
                    
                    HStack {
                        CautionStripeShape()
                            .fill(Color.orange.opacity(0.5), style: FillStyle(eoFill: false, antialiased: true))
                            .frame(width:64, height:8)
                        Spacer()
                    }
                    
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
                        let wasteSolidPct = Int(solidPCT * 100.0)
                        ProgressView("💩 solid |  \(wasteSolid) of \(wasteSolidCap). \(wasteSolidPct)%", value: Float(wasteSolid), total: Float(wasteSolidCap))
                    } else {
                        Text("< No solid waste container >").foregroundColor(.gray)
                    }
                }
                .padding(6)
                .frame(maxWidth:250)
                
                Divider()
                
                // Future (lasting)
                VStack(alignment:.leading) {
                    
                    let foodLasting = Int(controller.food.count / max(1, controller.headCount))
                    let waterLasting = Int(controller.liquidWater / max(1, (controller.headCount * GameLogic.waterConsumption)))
                    let oxygenLasting = Int(controller.air.o2 / max(1, (controller.headCount * 2)))
                    
                    Text("⏱ Future")
                        .font(GameFont.section.makeFont())
                        .padding(.vertical, 4)
                    //                        .foregroundColor(.orange)
                    
                    HStack {
                        CautionStripeShape()
                            .fill(Color.orange.opacity(0.5), style: FillStyle(eoFill: false, antialiased: true))
                            .frame(width:64, height:8)
                        Spacer()
                    }
                    
                    Text("💦 Water: \(controller.liquidWater). ⏱ \(waterLasting) hrs.")
                        .foregroundColor(waterLasting > 8 ? .green:.red)
                    Text("🍽 Food: \(controller.food.count). ⏱ \(foodLasting) hrs.")
                        .foregroundColor(foodLasting > 8 ? .green:.red)
                    Text("☁️ Oxygen: \(Int(controller.air.o2)). ⏱ \(oxygenLasting) hrs.")
                        .foregroundColor(oxygenLasting > 8 ? .blue:.red)
                    
                    // Spacer()
                }
                .padding(8)
            }
            
            if let report = controller.accountingReport {
                AccountingReportView(report: report)
            }
            
            Spacer()
        }
    }
}
