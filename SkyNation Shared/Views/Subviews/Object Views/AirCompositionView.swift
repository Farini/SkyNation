//
//  AirCompositionView.swift
//  SkyNation
//
//  Created by Carlos Farini on 2/12/21.
//

import SwiftUI

struct VerticalBar: View {
    
    var value: Double
    var color:Color
    var minimum:Double
    var maximum:Double
    var name:String
    
    init(min:Double?, max:Double, value:Double, color:Color?, name:String) {
        self.value = value
        self.minimum = min ?? 0
        self.maximum = max
        self.color = color ?? .blue
        self.name = name
    }
    
    var body: some View {
        
        VStack {
            
            HStack(alignment:.bottom, spacing:2) {
                
                GeometryReader { geometry in
                    
                    ZStack(alignment:.bottom) {
                        // Back
                        Rectangle().frame(width: 16 , height: 100)
                            .opacity(0.3)
                            .foregroundColor(.gray)
                        
                        // Front
                        Rectangle().frame(width: 16, height: CGFloat(((min(self.value, self.maximum) - self.minimum) / (self.maximum - self.minimum))) * 100)
                            .foregroundColor(self.color)
                            .animation(.easeOut)
                    }
                    .cornerRadius(geometry.size.height / 2)
                    // This ZStack is 16x100
                }
                .frame(width:16, height:100)
                
                VerticalBarLinesShape()
                    .stroke()
                    .foregroundColor(.gray)
                    .frame(width: 12, height: 100, alignment: .bottom)
                
                VStack(alignment:.leading) {
                    Text("\(Int(maximum))%")
                    Spacer()
                    Text("\(Int((maximum - minimum) / 2))%")
                    Spacer()
                    Text("\(Int(minimum))%")
                }
                .frame(height:100)
                .font(.caption)
                .foregroundColor(.gray)
            }
            Divider()
            Text(name)
            Text(String(format:"%.1f", self.value) + "%")
        }
        //            .padding([.leading], 8)
        
        .frame(minWidth: 48, idealWidth: 50, maxWidth: 64, minHeight: 130, idealHeight: 175, maxHeight: 175, alignment: .center)
        
    }
}

struct VerticalBarLinesShape: Shape {
    
    // MARK:- functions
    func path(in rect: CGRect) -> Path {
        
        // Path
        var path = Path()
        
        // 8 x 100
        let height = rect.size.height
//        let midHeight = height / 2
        path.move(to: CGPoint.zero)
        path.addLine(to: CGPoint(x: 0, y: height))
        
        // Start in Middle
        var posY = 0.0
        path.move(to: CGPoint(x: 0, y: posY))
        path.addLine(to: CGPoint(x: 10, y:posY))
        
        for line in 1...10 {
            posY = (Double(height) / 10.0) * Double(line)
            path.move(to: CGPoint(x: 0.0, y: posY))
            if line == 5 {
                path.addLine(to: CGPoint(x: 10, y:posY))
            } else {
                path.addLine(to: CGPoint(x: 7, y:posY))
            }
        }
        
        return path
    }
}


struct AirCompositionView: View {
    
    var air:AirComposition
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 0) {
            let volume:Double = Double(air.getVolume())
            HStack {
                VerticalBar(min: 0, max: 25, value: Double(air.o2)/volume * 100, color: .blue, name:"O2")
                VerticalBar(min: 0, max: 2, value: Double(air.co2)/volume * 100, color: .orange, name:"CO2")
                VerticalBar(min: 0, max: 85, value: Double(air.n2)/volume * 100, color: .green, name:"N2")
                VerticalBar(min: 0, max: 5, value: Double(air.h2)/volume * 100, color: .blue, name:"H2")
                VerticalBar(min: 0, max: 5, value: Double(air.ch4)/volume * 100, color: .blue, name:"CH4")
                
                VStack {
                    ProgressCircle(value: Double((air.h2o * 100)/air.getVolume()), maxValue: 100, style: .dotted, backgroundEnabled: true, backgroundColor: GameColors.lightBlue, foregroundColor: Color.white, lineWidth: 8)
                    Text("Humidity: \((air.h2o * 100)/air.getVolume()) %").padding(20)
                }
                .frame(minWidth: 100, maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, minHeight:100, maxHeight: 175, alignment: .center)
            }
            .frame(idealHeight: 250, maxHeight: 250, alignment: .leading)
            .padding()
        }
        .frame(maxHeight: 250, alignment: .top)
        
    }
}

struct AirCompositionView_Previews: PreviewProvider {
    static var previews: some View {
        let currentAir = LocalDatabase.shared.station?.air ?? AirComposition()
        return AirCompositionView(air: currentAir)
    }
}

struct VerticalBar_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack {
            VerticalBar(min:0, max:100, value:25, color:Color.blue, name:"Gas")
        }
        
    }
}
