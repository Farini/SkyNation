//
//  CreditsView.swift
//  SkyNation
//
//  Created by Carlos Farini on 10/26/21.
//

import SwiftUI

struct CreditsView: View {
    var body: some View {
        VStack {
            
            HStack {
                Text("Credits")
                    .font(GameFont.section.makeFont())
                    .padding(.top, 8)
                
                Spacer()
            }
            .padding(.horizontal)
//            .background(Color.black.opacity(0.5))
            
            ScrollView {
                VStack(alignment:.leading) {
                    
                    HStack {
                        Text("Music & Sound")
                            .font(.title2)
                            .foregroundColor(.blue)
                            .padding(.bottom, 6)
                        Spacer()
                    }
                    Text(musicString)
                        .lineLimit(26)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Divider()
                    
                    HStack {
                        Text("Images and Assets")
                            .font(.title2)
                            .foregroundColor(.blue)
                            .padding(.bottom, 6)
                        Spacer()
                    }
                    Text(imagesString)
                    Divider()
                    
                    HStack {
                        Text("3D Assets")
                            .font(.title2)
                            .foregroundColor(.blue)
                            .padding(.bottom, 6)
                        Spacer()
                    }
                    Text(assets3D)
                    Divider()
                    
                }
                .padding(.horizontal)
            }
            
        }
    }
    
    let musicString = """
    App: DM1
    App: GarageBand

* In Dreams by Scott Buckley
www.scottbuckley.com.au
Music promoted by https://www.chosic.com/free-music/all/
Attribution 4.0 International (CC BY 4.0)
https://creativecommons.org/licenses/by/4.0/

* Adventure by Alexander Nakarada
https://www.serpentsoundstudios.com
Music promoted by https://www.chosic.com/free-music/all/
Attribution 4.0 International (CC BY 4.0)
https://creativecommons.org/licenses/by/4.0/

* Main Theme (Overture) | The Grand Score by Alexander Nakarada
https://www.serpentsoundstudios.com
Music promoted by https://www.chosic.com/free-music/all/
Attribution 4.0 International (CC BY 4.0)
https://creativecommons.org/licenses/by/4.0/

Sound FX:
    Apps: DM1 + GarageBand
"""
    
    let imagesString:String = """
### 2D Images
    NASA: Reference Images
    Naun Project: TheNaunProject.com
    Google: Reference Images
    Apple's SF Symbols

### Fonts
    Google Fonts: https://fonts.google.com

    Ailerons: Ailerons was inspired by aircraft models from the 40s.
    Designed by Adilson Gonzales.
    www.adilsongonzales.com
"""
    let assets3D:String = """
### 3D Models
    App: Blender https://blender.org
    Blender Guru: https://www.youtube.com/channel/UCOKHwx1VCdgnxwbjyb9Iu1g
    Josh Gambrell: https://www.youtube.com/channel/UCXfGjwohMgPm4Ng2e1FXySw
     
     
    PBX Texturing (Atlasses)
    Decal Machine & Mesh Machine
    https://machin3.io
"""
    
}

struct CreditsView_Previews: PreviewProvider {
    static var previews: some View {
        CreditsView()
    }
}
