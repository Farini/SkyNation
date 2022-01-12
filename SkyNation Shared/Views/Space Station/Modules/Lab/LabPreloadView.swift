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
            
            // Label with Time
            Text("\(timeString()) s")
                .foregroundColor(.gray)
                    
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
    /*
    func update() {
        self.elapsed = Date().timeIntervalSince(start)
        if elapsed < 8 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                self.update()
            }
        }
    }
    */
    
}

struct LabPreloadView_Previews: PreviewProvider {
    static var previews: some View {
        LabPreloadView()
    }
}
