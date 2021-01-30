//
//  CautionStripes.swift
//  SkyNation
//
//  Created by Carlos Farini on 1/30/21.
//

import SwiftUI

struct CautionStripes: View {
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

// Shapes

struct CautionStripeShape: Shape {
    
    // MARK:- functions
    func path(in rect: CGRect) -> Path {
        
        // Path
        var path = Path()
        
        // Start in Middle
        let midHeight = rect.size.height / 2
        path.move(to: CGPoint(x: 0, y: midHeight))
        path.addLine(to: CGPoint(x:midHeight, y:0))
        path.addLine(to: CGPoint(x:0, y:0))
        path.closeSubpath()
        
        var remainingWidth = rect.width
        var nextIndex = 1
        
        while remainingWidth > 0 {
            let stripe = makeStripe(at: nextIndex, height: rect.height)
            path.addPath(stripe)
            nextIndex += 1
            remainingWidth -= rect.height / 2
        }
        

        return path
    }
    
    func makeStripe(at index:Int, height:CGFloat) -> Path {
        
        // Path
        var path = Path()
        
        let splitzer = Double(index).truncatingRemainder(dividingBy: 2)
        let startX = (CGFloat(index) * (height) + CGFloat(splitzer) * (height)) / 2
        let stripeWidth:CGFloat = height / 2.0
        
        
        path.move(to: CGPoint(x: startX - (stripeWidth) , y: height))
        path.addLine(to: CGPoint(x:startX + stripeWidth, y:0))
        path.addLine(to: CGPoint(x:startX, y:0))
        path.addLine(to: CGPoint(x:startX - (height), y:height))
        path.closeSubpath()
        
//        path.move(to: CGPoint(x: startX - (height / 2) , y: height))
//        path.addLine(to: CGPoint(x:startX + (height / 2), y:0))
//        path.addLine(to: CGPoint(x:startX - (height / 8), y:0))
//        path.addLine(to: CGPoint(x:startX - (height), y:height))
//        path.closeSubpath()
        
        return path
    }
}

struct CautionStripes_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Text("Caution Stripes").font(.title)
            ZStack{
                Color.black
                    .edgesIgnoringSafeArea(.all)
                CautionStripeShape()
                    .fill(Color.orange, style: FillStyle(eoFill: false, antialiased: true))
                    .foregroundColor(Color.white)
            }
            .frame(width: 300, height: 20, alignment: .leading)
            Text("Text Below").font(.title)
        }
        
    }
}
