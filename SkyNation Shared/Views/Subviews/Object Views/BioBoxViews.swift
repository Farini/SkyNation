//
//  BioBoxViews.swift
//  SkyNation
//
//  Created by Carlos Farini on 9/21/21.
//

import SwiftUI

struct BioBoxSelectView: View {
    
    var bioBox:BioBox
    @State var selected:Bool = false
    
    private let shape = RoundedRectangle(cornerRadius: 8, style: .continuous)
    private let unselectedColor:Color = Color.white.opacity(0.4)
    private let selectedColor:Color = Color.blue
    
    var body: some View {
        HStack {
            Text("🧬").font(.largeTitle)
                .padding(6)
            VStack(alignment:.leading) {
                Text("\(DNAOption(rawValue:bioBox.perfectDNA)!.emoji) x \(bioBox.population.filter({ $0 == bioBox.perfectDNA }).count)")
                Text("Pop: \(bioBox.population.count) of \(bioBox.populationLimit)").foregroundColor(.gray)
            }
            .padding(.trailing, 6)
        }
        .padding(4)
        .background(Color.black.opacity(0.5))
        .overlay(
            shape
                .inset(by: selected ? 1.0:0.5)
                .stroke(selected ? selectedColor:unselectedColor, lineWidth: selected ? 1.5:1.0)
        )
        
    }
}


struct BioBoxViews_Previews: PreviewProvider {
    static var previews: some View {
        BioBoxSelectView(bioBox: makeBox(), selected: false)
        BioBoxSelectView(bioBox: makeBox(), selected: true)
    }
    
    static func makeBox() -> BioBox {
        let a = BioBox(chosen: .apple, size: 12)
        return a
    }
}
