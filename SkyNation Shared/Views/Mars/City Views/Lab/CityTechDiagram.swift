//
//  CityTechDiagram.swift
//  SkyNation
//
//  Created by Carlos Farini on 7/24/21.
//

import SwiftUI

struct CityTechDiagram: View {
    @State var tree = CityTechTree().uniqueTree
    
    var body: some View {
        VStack {
            Diagram(tree: tree, node: { value in
                //                Text("\(value.value.rawValue): \(value.value.getDuration())")
                VStack {
                    
                    Text("\(value.value.shortName)")
                        .font(.callout)
                        .padding([.top, .leading, .trailing], 6)
                    
                    Text("\(value.value.rawValue)")
                        .font(.caption)
                        .foregroundColor(.gray)
                    //                        .padding([.bottom], /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
                    
                }
                .background(Color.black)
//                .background(value.isUnlocked(station:station) ? Color.blue:Color.black)
                .cornerRadius(6)
                .padding(6)
//                .onTapGesture {
//                    controller.selectedFromDiagram(value.value)
//                }
                
            })
        }
    }
}

struct CityTechDiagram_Previews: PreviewProvider {
    static var previews: some View {
        CityTechDiagram()
    }
}
