//
//  BoxedCells.swift
//  SkyNation
//
//  Created by Carlos Farini on 12/27/21.
//

import SwiftUI

struct BoxedCells: View {
    var body: some View {
        VStack {
            
            Text("Selected")
                .modifier(GameSelectionModifier(isSelected: true))
            Text("Padding = 12")
                .modifier(GameSelectionModifier(isSelected: false, padding: 12, radius: 12))
            
            VStack(alignment:.leading) {
                HStack {
                    Text("Line 1")
                    Spacer()
                    Text("detRight")
                }
                
                Text("Details text").foregroundColor(.gray).font(GameFont.mono.makeFont())
            }
            .frame(width:150)
            .modifier(GameSelectionModifier())
            
            VStack(alignment:.leading) {
                HStack {
                    Text("Line 2")
                    Spacer()
                    Text("---")
                }
                
                Text("Footnote goes here").foregroundColor(.gray).font(.footnote)
            }
            .frame(width:150)
            .modifier(GameSelectionModifier(isSelected: true))
            
            VStack(alignment:.leading) {
                HStack {
                    Image(systemName: "bolt.circle").font(.largeTitle)
                    VStack {
                        Text("Power")
                    }
                    Spacer()
                    Text("100").foregroundColor(.yellow)
                }
                
                Text("Footnote goes here").foregroundColor(.gray).font(.footnote)
                ProgressBar(min: 0.0, max: 1.0, value: .constant(0.75), color: .gray)
                    .frame(height:8)
            }
            .frame(width:150)
            .modifier(GameSelectionModifier(isSelected: true))
            
        }
        
    }
}

struct BoxedCells_Previews: PreviewProvider {
    static var previews: some View {
        BoxedCells().padding()
    }
}
