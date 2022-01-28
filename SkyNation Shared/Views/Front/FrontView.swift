//
//  FrontView.swift
//  SkyNation
//
//  Created by Carlos Farini on 1/26/22.
//

import SwiftUI

struct FrontView: View {
    
    @State var imgOffset:Double = 0
    @State var direction:LayoutDirection = .rightToLeft
    
    var body: some View {
        ZStack {
            Image("FrontImage1")
                .saturation(0.5)
                .brightness(0.01)
//                .hueRotation(Angle.init(degrees: 90))
//                .contrast(0.0)
                .frame(maxWidth:900)
                .offset(x: imgOffset, y: 0)
            Text("Hello, Player!\nOffset:\(Int(imgOffset))")
                .padding()
                .background(Color.black)
                .cornerRadius(10)
        }
        .onAppear{
            effect()
        }
    }
    
    func effect() {
        if imgOffset < -400 {
            self.direction = .leftToRight
        } else if imgOffset > 400 {
            self.direction = .rightToLeft
        }
        
        switch direction {
            case .leftToRight:
                withAnimation(.linear(duration: 2)) {
                    self.imgOffset += 10
                }
                
            case .rightToLeft:
                withAnimation(.linear(duration: 2)) {
                    self.imgOffset -= 10
                }
                
            @unknown default:
                self.imgOffset = 0
                
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.effect()
        }
    }
}

struct FrontView_Previews: PreviewProvider {
    static var previews: some View {
        FrontView()
    }
}
