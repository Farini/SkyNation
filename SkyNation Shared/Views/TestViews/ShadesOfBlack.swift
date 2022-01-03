//
//  ShadesOfBlack.swift
//  SkyNation
//
//  Created by Carlos Farini on 1/2/22.
//

import SwiftUI

struct ShadesOfBlack: View {
    
    static var tenPct = Color(white: 0.1)
    static var twentyPct = Color(white: 0.2)
    static var thirty = Color(white: 0.3)
    
    var body: some View {
        VStack {
            Text("Shades of black").font(GameFont.title.makeFont()).padding(.top, 6)
            Divider()
            Text("White").foregroundColor(.white)
            Text("Gray").foregroundColor(.gray)
            Text("THIRTY").foregroundColor(ShadesOfBlack.thirty)
            Text("TWENTY").foregroundColor(ShadesOfBlack.twentyPct)
            Text("Dark Gray").foregroundColor(GameColors.darkGray)
            Text("Ten Percent").foregroundColor(ShadesOfBlack.tenPct)
            Text("Black").foregroundColor(.black)
            Spacer()
        }
        .background(GameColors.darkGray)
    }
}

struct ShadesOfBlack_Previews: PreviewProvider {
    
    static var previews: some View {
        #if os(macOS)
        if #available(macOS 12.0, *) {
                ShadesOfBlack()
                    .preferredColorScheme(.dark)
            } else {
                // Fallback on earlier versions
                ShadesOfBlack()
                    .preferredColorScheme(.dark)
            }
        
    #else
    if #available(iOS 15.0, *) {
        ShadesOfBlack()
            .preferredColorScheme(.dark)
                            .previewInterfaceOrientation(.landscapeLeft)
    } else {
        // Fallback on earlier versions
        ShadesOfBlack()
            .preferredColorScheme(.dark)
    }
    #endif
        
    }
}
