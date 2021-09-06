//
//  ProgressViews.swift
//  SkyTestSceneKit
//
//  Created by Farini on 9/22/20.
//  Copyright © 2020 Farini. All rights reserved.
//

import SwiftUI

// MARK: - Progress Bars

struct ProgressCircle: View {
    
    enum Stroke {
        case line
        case dotted
        
        func strokeStyle(lineWidth: CGFloat) -> StrokeStyle {
            switch self {
            case .line:
                return StrokeStyle(lineWidth: lineWidth,
                                   lineCap: .round)
            case .dotted:
                return StrokeStyle(lineWidth: lineWidth,
                                   lineCap: .round,
                                   dash: [16])
            }
        }
    }
    
    private let value: Double
    private let maxValue: Double
    private let style: Stroke
    private let backgroundEnabled: Bool
    private let backgroundColor: Color
    private let foregroundColor: Color
    private let lineWidth: CGFloat
    
    init(value: Double,
         maxValue: Double,
         style: Stroke = .line,
         backgroundEnabled: Bool = true,
         backgroundColor: Color = Color.black,
         foregroundColor: Color = Color.black,
         lineWidth: CGFloat = 8) {
        self.value = value
        self.maxValue = maxValue
        self.style = style
        self.backgroundEnabled = backgroundEnabled
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.lineWidth = lineWidth
    }
    
    var body: some View {
        ZStack {
            VStack {
                Image(systemName: "drop")
                    .font(.title2)
                    .foregroundColor(GameColors.lightBlue)
                    .padding(4)
                Text("\(value, specifier: "%.2f") %")
                    .foregroundColor(self.foregroundColor)
                    .font(.callout)
            }
            
            Circle()
                .stroke(lineWidth: self.lineWidth + 4)
                .foregroundColor(self.backgroundColor)
            
            Circle()
                .trim(from: 0, to: CGFloat(self.value / self.maxValue))
                .stroke(style: self.style.strokeStyle(lineWidth: self.lineWidth))
                .foregroundColor(self.foregroundColor)
                .rotationEffect(Angle(degrees: -90))
        }
        .frame(minWidth: 60, maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, minHeight: 60, maxHeight: 175, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
    }
}

struct ProgressBar: View {
    
    @Binding var value: Double
    var color:Color
    var minimum:Double = 19.2
    var maximum:Double = 23.5
    
    init(min:Double, max:Double, value:Binding<Double>, color:Color?) {
        self._value = value
        self.minimum = min
        self.maximum = max
        self.color = color ?? .blue
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment:.leading) {
                // Back
                Rectangle().frame(width: geometry.size.width , height: geometry.size.height)
                .opacity(0.3)
                .foregroundColor(.gray)
                // Front
                Rectangle().frame(width: CGFloat(((min(self.value, self.maximum) - self.minimum) / (self.maximum - self.minimum))) * geometry.size.width, height: geometry.size.height)
                    .foregroundColor(self.color)
                .animation(.easeOut)
                
            }.cornerRadius(geometry.size.height / 2)
        }
    }
}

/// This is better than Progress Bar (Another type)
struct LevelBar: View {
    
    var min:Double = 19.2
    var max:Double = 23.5
    var title:String = ""
    var color:Color
    @Binding var level:Double
    
    init(amount: Binding<Double>, type:TankType) {
        switch type {
        case .o2:
            title = "Oxygen"
            min = 19.2
            max = 23.5
            color = .blue
        case .co2:
            title = "Carbon Monoxyde"
            min = 0.0
            max = 0.6
            color = .orange
        default:
            title = "Unknown"
            color = .gray
        }
        self._level = amount // beta 4
    }
    
    var body: some View {
        
        GeometryReader { geometry in
            
            VStack {
                ZStack(alignment:.leading) {
                    // Back
                    Rectangle().frame(width: geometry.size.width , height: geometry.size.height)
                        .opacity(0.3)
                        .foregroundColor(.gray)
                    // Front
                    Rectangle().frame(width: CGFloat(((Swift.min(self.level, self.max) - self.min) / (self.max - self.min))) * geometry.size.width, height: geometry.size.height)
                        .foregroundColor(self.color)
                        .animation(.easeOut)
                    
                    Text("\(self.title)")
                        .padding(Edge.Set.leading, 9)
                    
                }.cornerRadius(geometry.size.height / 2)
                
                HStack {
                    Text("\(self.min, specifier: "%.2f")%")
                    Spacer()
                    Text("\(self.max, specifier: "%.2f")%")
                }
            }
        }
    }
}

/// A Progress bar that doesn't update its values
struct FixedLevelBar:View {
    
    var min:Double
    var max:Double
    var current:Double
    
    var title:String
    var color:Color
    
    var body: some View {
        
        GeometryReader { geometry in
            VStack {
                ZStack(alignment:.leading) {
                    // Back
                    Rectangle().frame(width: geometry.size.width , height: geometry.size.height)
                        .opacity(0.3)
                        .foregroundColor(.gray)
                    // Front
                    Rectangle().frame(width: CGFloat(((Swift.min(self.current, self.max) - self.min) / (self.max - self.min))) * geometry.size.width, height: geometry.size.height)
                        .foregroundColor(self.color)
                        .animation(.easeOut)
                    
                    Text("\(self.title) \(self.current, specifier: "%.2f")")
                        .padding(Edge.Set.leading, 9)
                    
                }.cornerRadius(geometry.size.height / 2)
                HStack {
                    Text("\(self.min, specifier: "%.2f")%")
                    Spacer()
                    Text("\(self.max, specifier: "%.2f")%")
                }
            }
        }.frame(minWidth: 150, idealWidth: 175, maxWidth: 200, minHeight: 20, idealHeight: 25, maxHeight: 30, alignment: .center)
        .padding()
    }
}

/// A Contribution Progress bar used in `OutpostView` to display the progress of contributions
struct ContributionProgressBar:View {
    
    @State var value:Int
    @State var total:Int
    
    var title:String = "Contributed"
    var hasSubtitles:Bool = true
    var barColor:Color = .blue.opacity(0.6)
    
    /**
     A Contribution Progress bar used in `OutpostView` to display the progress of contributions
     - Parameters:
        - value: The current value of the progress
        - total: The maximum amount it can be contributed.
        - hasSubtitles: Displays subtitles (defaults to true)
        - barColor: The foreground color of the progress bar (defaults to blue, alpha:0.6)
     */
    init(value:Int, total:Int, title:String? = "", hasSubtitles:Bool? = true, barColor:Color? = nil) {
        self.value = value
        self.total = total
        self.title = title!
        self.hasSubtitles = hasSubtitles!
        if let color = barColor {
            self.barColor = color
        }
    }
    
    var body: some View {
        
        GeometryReader { geometry in
            VStack {
                
                // The Bar
                ZStack(alignment:.leading) {
                    
                    // Back
                    Rectangle().frame(width: geometry.size.width , height: geometry.size.height)
                        .opacity(0.3)
                        .foregroundColor(.gray)
                        .frame(height:30)
                    
                    // Front
                    Rectangle()
                        .frame(width: self.indicatorWidth(geometry.size.width), height: geometry.size.height)
                        .foregroundColor(barColor)
                        .animation(.easeOut)
                        .frame(height:30)
                    
                    // Title
                    if hasTitle() {
                        Text("\(self.title) \(self.value)/\(self.total)")
                            .padding(.leading, 9)
                    } else {
                        HStack {
                            Spacer()
                            Text(" \(self.value)/\(self.total) ")
                                .font(.system(size:12, design: .monospaced))
                                .padding(4)
                                .background(Color.black.opacity(0.5))
                                .cornerRadius(4)
                            Spacer()
                        }
                    }
                }
                .cornerRadius(geometry.size.height / 2)
                
                // Subtitle
                if hasSubtitles {
                    subtitleIndicator
                } else {
                    EmptyView()
                }
            }
        }
        .frame(minWidth: 150, idealWidth: 175, maxWidth: 200, minHeight: 32, idealHeight: 36, maxHeight: 60, alignment: .center)
        .padding([.horizontal])
    }
    
    var subtitleIndicator: some View {
        HStack {
            Text("0")
            Spacer()
            Text("|")
            Spacer()
            Text("\(self.total)")
        }
        .foregroundColor(.gray)
    }
    
    private func hasTitle() -> Bool {
        return !title.isEmpty
    }
    
    /// Returns the value / total. (or 0 if dividing by 0)
    private func calculate() -> Double {
        if value <= 0 { return 0.0 }
        guard total > 0 else { return 0.0 }
        return Double(value) / Double(total)
    }
    
    /// The width of the indicator (foreground bar)
    private func indicatorWidth(_ maxWidth:CGFloat) -> CGFloat {
        return CGFloat(self.calculate()) * max(CGFloat(1), maxWidth)
    }
    
}

struct PercentageIndicator: AnimatableModifier {
    
    var pct: CGFloat = 0
    
    var animatableData: CGFloat {
        get { pct }
        set { pct = newValue }
    }
    
    func body(content: Content) -> some View {
        content
            .overlay(ArcShape(pct: pct).foregroundColor(.orange))
            .overlay(LabelView(pct: pct))
    }
    
    struct ArcShape: Shape {
        let pct: CGFloat
        
        func path(in rect: CGRect) -> Path {
            
            var p = Path()
            
            p.addArc(center: CGPoint(x: rect.width / 2.0, y:rect.height / 2.0),
                     radius: rect.height / 2.0 + 5.0,
                     startAngle: .degrees(0),
                     endAngle: .degrees(360.0 * Double(pct)), clockwise: false)
            
            return p.strokedPath(.init(lineWidth: 10, dash: [6, 3], dashPhase: 10))
        }
    }
    
    struct LabelView: View {
        let pct: CGFloat
        
        var body: some View {
            Text("\(Int(pct * 100))%")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
    }
}


// MARK: - Previews

struct ProgressViews_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ProgressCircle(value: 20, maxValue: 100, style: .dotted, backgroundEnabled: true, backgroundColor: Color.orange, foregroundColor: Color.red, lineWidth: 8)
            Text("Progress Bar").font(.headline).padding(.top)
            FixedLevelBar(min: 0, max: 100, current: 80, title: "Test Progress", color: .pink)
                .padding(.bottom, 8)
            
            Group {
                Text("Contribution")
                ContributionProgressBar(value: 6, total: 8)
                ContributionProgressBar(value: 6, total: 8, title:"Contribution")
                Divider()
            }
            
        }
        .preferredColorScheme(.dark)
        .frame(height:500)
    }
}

struct AirView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Text("Test")
            AirCompositionView(air: AirComposition(amount: nil))
        }
        .preferredColorScheme(.dark)
        
    }
    
}
/*
struct PercentageIndicator_Previews: PreviewProvider {
    @State var ctrl:Double = 0
    static var previews: some View {
        CirclePercentIndicator(percentage: 0.2)
            .preferredColorScheme(.dark)
    }
}
*/

