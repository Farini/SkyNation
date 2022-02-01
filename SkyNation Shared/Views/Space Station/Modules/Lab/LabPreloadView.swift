//
//  LabPreloadView.swift
//  SkyNation
//
//  Created by Carlos Farini on 1/11/22.
//

import SwiftUI

/**
    A View that acts as a `placeholder`, until the LabView tech tree is fully loaded.
*/
struct LabPreloadView: View {
    
    @State private var elapsed:Double = 0
    @State private var start:Date = Date()
    
    @State private var isAtMaxScale = false
    private let maxScale: CGFloat = 1.25
    private let animation = Animation.easeInOut(duration: 1.75).repeatCount(5, autoreverses: true)
    
    var body: some View {
        
        VStack {
            Spacer()
            Text("Lab Module").font(GameFont.title.makeFont())
            Divider()
            Text("Loading Data").foregroundColor(.gray)
                .scaleEffect(isAtMaxScale ? maxScale : 1)
                .padding()
                .onAppear {
                    withAnimation(animation) {
                        isAtMaxScale.toggle()
                    }
                }
                .onDisappear {
                    let delta = Date().timeIntervalSince(start)
                    self.elapsed = delta
                    let nf = NumberFormatter()
                    nf.maximumFractionDigits = 2
                    nf.maximumIntegerDigits = 2
                    nf.minimumIntegerDigits = 1
                    nf.minimumFractionDigits = 2
                    print("Lab preloading time: \(nf.string(from: NSNumber(value: delta)) ?? "n/a")")
                }
            
            // Progress view
            ProgressView("Tech tree")
                .padding()
            
            Text("Recipes: Build Peripherals (machines) that can renew some resources.")
                .padding(4)
                .foregroundColor(.yellow)
            
            Text("Research: Explore the tech tree, and expand your Space Station")
                .padding(4)
                .foregroundColor(.blue)
            
            Spacer()
        }
        .onAppear {
            let delta = Date().timeIntervalSince(start)
            self.elapsed = delta
        }
    }
    
    func timeString() -> String {
        let nf = NumberFormatter()
        nf.maximumFractionDigits = 2
        nf.maximumIntegerDigits = 2
        nf.minimumIntegerDigits = 1
        nf.minimumFractionDigits = 2
        return nf.string(from: NSNumber(value: elapsed)) ?? "--"
    }
}

struct LabPreloadView_Previews: PreviewProvider {
    static var previews: some View {
        LabPreloadView()
    }
}
