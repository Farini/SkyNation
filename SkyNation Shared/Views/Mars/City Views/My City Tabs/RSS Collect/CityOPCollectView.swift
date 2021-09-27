//
//  CityOPCollectView.swift
//  SkyNation
//
//  Created by Carlos Farini on 9/24/21.
//

import SwiftUI

struct CityOPCollectView: View {
    
    @ObservedObject var controller:LocalCityController
    
    var body: some View {
        
        VStack {
            
            Group {
                Text("Outpost Collection")
                    .font(.title2)
                    .foregroundColor(.orange)
                    .padding(.top)
                
                Divider()
            }
            
            ScrollView {
                VStack(alignment:.leading, spacing:4) {
                    
                    ForEach(controller.opCollectArray, id:\.id) { collectable in
                        HStack {
                            VStack(alignment:.leading) {
                                Text(collectable.outpost.type.rawValue)
                                    .font(.title3)
                                    .foregroundColor(.orange)
                                
                                HStack {
                                    Text("Date \(GameFormatters.dateFormatter.string(from: collectable.collected))")
                                    Text("POS.:\(collectable.outpost.posdex)").foregroundColor(.blue)
                                    Text("Level \(collectable.outpost.level)")
                                }
                            }
                            
                            Spacer()
                            
                            Button("Collect") {
                                print("Collect")
                                controller.collectFromOutpost(outpost: collectable.outpost)
                            }
                            .disabled(!collectable.canCollect())
                            .buttonStyle(GameButtonStyle())
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

struct CityOPCollectView_Previews: PreviewProvider {
    static var previews: some View {
        CityOPCollectView(controller: LocalCityController())
    }
}
