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
                HStack {
                    Text("Outpost Collection")
                        .font(GameFont.section.makeFont())
                        
                    Spacer()
                }
                .padding([.horizontal, .top])
                
                
                Divider()
            }
            
            ScrollView {
                VStack(alignment:.leading, spacing:4) {
                    
                    ForEach(controller.opCollectArray, id:\.id) { collectable in
                        HStack {
                            VStack(alignment:.leading) {
                                HStack(spacing:12) {
                                    Text(collectable.outpost.type.rawValue)
                                        .font(.title3)
                                        .foregroundColor(.orange)
                                    
                                    Text("+ \(collectable.outpost.type.productionForCollection(level: collectable.outpost.level).makeString())")
                                        .foregroundColor(.green)
                                }
                                
                                
                                HStack {
                                    Text("Date \(GameFormatters.dateFormatter.string(from: collectable.collected))")
                                    Text("POS.:\(collectable.outpost.posdex)").foregroundColor(.blue)
                                    Text("Level \(collectable.outpost.level)")
                                }
                            }
                            
                            Spacer()
                            
                            if collectable.isCollectable {
                                if collectable.canCollect() {
                                    Button("Collect") {
                                        controller.collectFromOutpost(outpost: collectable.outpost)
                                    }
                                    .disabled(!collectable.canCollect())
                                    .buttonStyle(GameButtonStyle())
                                } else {
                                    Text("\(collectable.timeToCollect.stringFromTimeInterval())")
                                        .foregroundColor(.gray)
                                }
                            }
                            
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

extension Dictionary {
    
    /**
     Builds a displayable string, with keys and values on each line from a dictionary.
     - parameters:
        - inline: when turned on, returns a one liner.
     
     By default, the inline argument is false. This means each `key` & `value` pair will have one line.
     */
    func makeString(inline:Bool = false) -> String {
        var result:String = ""
        for (key, value) in self {
            result += "\(key):\(value)\(inline ? "":"\n")"
        }
        return result
    }
}
