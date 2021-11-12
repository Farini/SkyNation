//
//  StepperView.swift
//  SkyNation
//
//  Created by Carlos Farini on 11/11/21.
//

import SwiftUI

struct StepperView: View {
    
    var stepCounts:Int
    @State var current:Int = 1
    
    var grayBright:Color = Color.init(white: 0.75)
    var grayDark:Color = Color.init(white: 0.4)
    
    var body: some View {
        
        VStack {
            HStack {
                
                ForEach(1...stepCounts, id:\.self) { stepNum in
                    ZStack {
                        Text("\(stepNum)")
                            .font(.title2).foregroundColor(current == stepNum ? Color.orange:current > stepNum ? grayDark:grayBright)
                            .padding()
                            .background(
                                Circle()
                                    .stroke(lineWidth: 2.5)
                                    .foregroundColor(current == stepNum ? Color.orange:current > stepNum ? grayDark:grayBright))
                    }
                    
                    GeometryReader { geometry in
                        Line(from: CGPoint(x: 0, y: 18), to: CGPoint(x:geometry.size.width, y:18))
                            .stroke(lineWidth: 3)
                            .foregroundColor(.gray)
                    }
                    .frame(height:36)
                }
                
                Image(systemName: "checkmark.circle").font(.title)
                    .foregroundColor(current > stepCounts ? Color.green:Color.gray)
                    .padding([.leading, .vertical])
                
            }
            .padding(.top, 6)
            
            RoundedRectangle(cornerRadius: 3)
                .background(LinearGradient(colors: [Color.red, Color.orange, Color.yellow, Color.green], startPoint: .leading, endPoint: .trailing))
                .frame(height:6)
                .padding(.bottom, 6)
            
        }
        .padding(.horizontal)
        
    }
}

struct StepperView_Previews: PreviewProvider {
    static var previews: some View {
        StepperView(stepCounts: 4, current: 3)
    }
}
