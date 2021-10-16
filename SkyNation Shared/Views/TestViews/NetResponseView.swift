//
//  NetResponseView.swift
//  SkyNation
//
//  Created by Carlos Farini on 10/16/21.
//

import SwiftUI

struct NetResponseView: View {
    
    @State var gameResponse:GameResponse? = nil
    
    var body: some View {
        VStack {
            
            // Header
            Group {
                VStack(spacing:6) {
                    Text("Game Status Messages").font(.title)
                    Text("Displays an error, or a successfull message after an action.")
                        .foregroundColor(.gray)
                }
                .padding(.top, 6)
                    
                Divider()
            }
            
            
            // Random View
            Group {
                Text("Random View")
                    .font(Font.custom("Ailerons", size: 24))
                    .padding(.leading)
                
                HStack {
                    PeripheralObject(peripheral: .PowerGen).getImage()
                        .padding()
                        .background(Color.black)
                        .cornerRadius(8)
                    
                    
                    PeripheralObject(peripheral: .BioSolidifier).getImage()
                        .padding()
                        .background(Color.black)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .inset(by: 0.5)
                                .stroke(Color.blue, lineWidth: 2)
                        )
                }
                .padding()
            }
            
            // Errors + Buttons
            VStack {
                
                Divider()
                
                GameResponseView(gameResponse: self.gameResponse)
                    
                HStack {
                    Button("Action") {
                        print("Act")
                        simulate()
                    }
                    .buttonStyle(GameButtonStyle())
                    
                    Button("Destroy") {
                        print("Act")
                        clear()
                    }
                    .buttonStyle(GameButtonStyle(labelColor: .red))
                }
                .padding(.vertical, 6)
            }
        }
    }
    
    func simulate() {
        if Bool.random() {
            self.gameResponse = GameResponse(success: "Did what you have to do :)")
        } else {
            self.gameResponse = GameResponse(error:CustomError.allCases.randomElement()!)
        }
    }
    
    func clear() {
        self.gameResponse = nil
    }
    
}



struct NetResponseView_Previews: PreviewProvider {
    static var previews: some View {
        NetResponseView()
    }
}




