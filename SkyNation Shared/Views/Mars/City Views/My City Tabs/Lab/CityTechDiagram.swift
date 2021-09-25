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
                
                VStack {
                    
                    Text("\(value.value.shortName)")
                        .font(.callout)
                        .padding([.top, .leading, .trailing], 6)
                    
                    Text("\(value.value.rawValue)")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                }
                .background(Color.black)
                .cornerRadius(6)
                .padding(6)
                
            })
        }
    }
}

struct CityTechDiagram_Previews: PreviewProvider {
    static var previews: some View {
        CityTechDiagram()
    }
}
