//
//  FlipView.swift
//  SkyNation
//
//  Created by Carlos Farini on 12/29/20.
//

import SwiftUI

enum FlipViewSide {
    case front
    case back
    
    mutating func toggle() {
        self = self == .front ? .back : .front
    }
}

/**
 A View that Has  `Front` and  `Back` Sides.
 */
struct FlipView<Front: View, Back: View>: View {
    var visibleSide: FlipViewSide
    var front: Front
    var back: Back
    
    init(visibleSide: FlipViewSide = .front, @ViewBuilder front: () -> Front, @ViewBuilder back: () -> Back) {
        self.visibleSide = visibleSide
        self.front = front()
        self.back = back()
    }
    
    var body: some View {
        ZStack {
            front
                .modifier(FlipModifier(side: .front, visibleSide: visibleSide))
            back
                .modifier(FlipModifier(side: .back, visibleSide: visibleSide))
        }
    }
}

/**
 An animation that flips the `FlipView`
 */
struct FlipModifier: AnimatableModifier {
    
    var side: FlipViewSide
    var flipProgress: Double
    
    init(side: FlipViewSide, visibleSide: FlipViewSide) {
        self.side = side
        self.flipProgress = visibleSide == .front ? 0 : 1
    }
    
    public var animatableData: Double {
        get { flipProgress }
        set { flipProgress = newValue }
    }
    
    var visible: Bool {
        switch side {
            case .front:
                return flipProgress <= 0.5
            case .back:
                return flipProgress > 0.5
        }
    }
    
    public func body(content: Content) -> some View {
        ZStack {
            content
                .opacity(visible ? 1 : 0)
                .accessibility(hidden: !visible)
        }
        .scaleEffect(x: scale, y: 1.0)
        .rotation3DEffect(.degrees(flipProgress * -180), axis: (x: 0.0, y: 1.0, z: 0.0), perspective: 0.5)
    }
    
    var scale: CGFloat {
        switch side {
            case .front:
                return 1.0
            case .back:
                return -1.0
        }
    }
}

struct FlipView_Previews: PreviewProvider {
    static var previews: some View {
        FlipView(visibleSide: .front) {
            VStack {
                Image(systemName: "questionmark")
                    .font(.title)
                    .padding(6)
                Text("Front Side")
                    .padding(6)
            }
            .padding()
            
        } back: {
            VStack {
                Image(systemName: "questionmark")
                    .font(.title)
                    .padding(6)
                Text("Back Side")
                    .padding(6)
            }
            .padding()
        }
    }
}
