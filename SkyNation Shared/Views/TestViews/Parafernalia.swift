//
//  Parafernalia.swift
//  SkyTestSceneKit
//
//  Created by Farini on 9/19/20.
//  Copyright © 2020 Farini. All rights reserved.
//

import SwiftUI




struct TypographyView2: View {
    var body: some View {
        VStack(alignment:.leading) {
            Text("Roboto Slab")
                .font(Font.custom("Roboto Slab", size: 24))
                .padding(.horizontal)
                .padding(.top)
            
            Divider()
            
            Text("Paragraph. The paragraph should be a fixed width font. Maybe Roboto mono?")
                .font(Font.custom("Roboto Mono", size: 14))
                .fixedSize(horizontal: false, vertical: true)
                .lineLimit(3)
                .padding()
            
            Text("There should also be a paragraph in gray.")
                .font(Font.custom("Roboto Mono", size: 14))
                .padding()
                .foregroundColor(.gray)
            
            CautionStripeShape()
                .fill(Color.orange, style: FillStyle(eoFill: false, antialiased: true))
                .foregroundColor(Color.white)
                .frame(width: 300, height: 20, alignment: .center)
            
            Text("status message")
                .font(Font.custom("Roboto Mono", size: 14))
                .padding()
                .foregroundColor(.red)
            
            Divider()
            
            HStack {
                Button("Action") {
                    print("Act")
                }
                .buttonStyle(GameButtonStyle())
                .padding(.bottom)
                
                
                Button("Destroy") {
                    print("Act")
                }
                .buttonStyle(GameButtonStyle(labelColor: .red))
                .padding(.bottom)
            }
            .padding(.horizontal)
            
        }
        .frame(width:300)
    }
}

struct TypographyView_Previews: PreviewProvider {
    static var previews: some View {
//        TypographyView()
        TypographyView2()
    }
}


