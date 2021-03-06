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
struct TurtleHexagon: Shape {
    
    // MARK:- functions
    func path(in rect: CGRect) -> Path {
        
        // Path
        var path = Path()
        
        // Start in Middle
        path.move(to: .zero)
        
        let sideLength = rect.size.width / 2
        for _ in 0..<6 {
            // Scuttle
            path = scuttle(length: sideLength, path: path)
            // Turn
            path = turn(.pi/3.0, path: path)
        }
        return close(path: path)
    }
    
    func scuttle(length:CGFloat, path:Path) -> Path {
        var newPath = path //
        newPath.addLine(to: .init(x: length, y: 0))
        newPath = newPath.applying(CGAffineTransform(translationX: -length, y: 0))
        return newPath
    }
    
    func turn(_ radians:CGFloat, path:Path) -> Path {
        var newPath = path
        newPath = path.applying(CGAffineTransform(rotationAngle: radians))
        return newPath
    }
    
    func close(path:Path) -> Path {
        let pt = path.currentPoint ?? .zero
        var newPath = path
        newPath.addLine(to: .init(x: 0, y: 0))
        newPath = newPath.applying(CGAffineTransform(translationX: -pt.x, y: -pt.y))
        newPath.closeSubpath()
        return newPath
    }
    
}

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
            .clipped()
            
            Text("Hexagon")
            
            ZStack {
                Color.black
                TurtleHexagon()
                    .frame(width:64, height:64)
                    .offset(x: 0, y: 64)
                TurtleHexagon()
                    .frame(width:64, height:64)
                    .offset(x: 50, y: 94)
                TurtleHexagon().stroke(lineWidth: 2).foregroundColor(.gray)
                    .frame(width:64, height:64)
                    .offset(x: 0, y: 124)
                
            }.frame(width: .infinity, height: 128, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
            
            
//                .padding()
//            Text("Text Below").font(.title)
//            ContentView()
        }
        
    }
}
/*
struct ContentView: View {
    var body: some View {
        
        HStack {
//            Button(action: {
//                print("tap")
//            }) {
//                Text("#").font(.largeTitle)
//            }.buttonStyle(BlueCircleButtonStyle())
            
            Button(action: {
                print("tap")
            }) {
                Image(systemName: "ellipsis.circle")
            }.buttonStyle(SmallCircleButtonStyle(backColor: .blue))
            
            Button(action: {
                print("tap")
            }) {
                Image(systemName: "xmark.circle")
            }.buttonStyle(SmallCircleButtonStyle(backColor: .pink))
            
        }
        
        HStack {
            Button(action: {
                print("button pressed")
                
            }) {
                Image(systemName: "questionmark.diamond")
                //                .renderingMode(.original)
            }
            .buttonStyle(NeumorphicButtonStyle(bgColor: .gray))
            .help("Click here to do stuff. What happens then?")
//            .padding()
            
            Button(action: {
                print("button pressed")
                
            }) {
                Image(systemName: "ellipsis.circle")
                //                .renderingMode(.original)
            }
            .buttonStyle(NeumorphicButtonStyle(bgColor: .gray))
//            .padding()
            
            Button(action: {
                print("button pressed")
                
            }) {
                Image(systemName: "xmark.circle")
                //                .renderingMode(.original)
            }
            .buttonStyle(NeumorphicButtonStyle(bgColor: .gray))
//            .padding()
        }
        .padding()
        
        Divider()
        
        HStack {
            Button(action: {
                print("button pressed")
                
            }) {
                Image(systemName: "backward.frame")
                //                .renderingMode(.original)
            }
            .buttonStyle(NeumorphicButtonStyle(bgColor: .gray))
            .help("Click here to do stuff. What happens then?")
            //            .padding()
            
            Button(action: {
                print("button pressed")
                
            }) {
                Text("Continue")
                //                .renderingMode(.original)
            }
            .buttonStyle(NeumorphicButtonStyle(bgColor: .gray))
            //            .padding()
            
            Button(action: {
                print("button pressed")
                
            }) {
                Image(systemName: "xmark.circle")
                //                .renderingMode(.original)
            }
            .buttonStyle(NeumorphicButtonStyle(bgColor: .gray))
            //            .padding()
        }
        .padding()
        
    }
}
*/

