//
//  GameResponseView.swift
//  SkyNation
//
//  Created by Carlos Farini on 10/16/21.
//

import SwiftUI

/**
 A model responsible for showing an error message, or a success message.
 - parameters:
 - GameResponse: Pass a `@State` optional var here. When nil, it won't show anything.
 */
struct GameResponse {
    
    var error:Error?
    var message:String
    var success:Bool
    
    init(error:Error) {
        self.error = error
        self.success = false
        self.message = error.localizedDescription
    }
    
    init(success message:String) {
        self.message = message
        self.success = true
        self.error = nil
    }
    
    func color() -> Color {
        if error == nil {
            return .green
        } else {
            return .red
        }
    }
}

/**
 A View that shows an `Error`, or a success **message**
 - discussion:
    It already comes with animation.
 
 - parameters:
 - GameResponse: Pass a `@State` optional var here. When nil, it won't show anything.
 */
struct GameResponseView: View {
    
    var gameResponse:GameResponse?
    
    var body: some View {
        VStack {
            if let gResponse = gameResponse {
                VStack {
                    if gResponse.error != nil {
                        CautionStripeShape()
                            .fill(Color.orange, style: FillStyle(eoFill: false, antialiased: true))
                            .foregroundColor(Color.white)
                            .frame(height: 10, alignment: .center)
                            .padding(.horizontal)
                    }
                    HStack {
                        Spacer()
                        Text(gResponse.message)
                            .padding(4)
                            .foregroundColor(gResponse.color())
                        Spacer()
                    }
                }
                .background(Color.black.opacity(0.5))
                .transition(.move(edge:.top).combined(with:AnyTransition.opacity))
                .animation(.spring(response: 0.5, dampingFraction: 0.75))
                
            } else {
                EmptyView()
            }
        }
    }
}

struct GameResponseView_Previews:PreviewProvider {
    static var previews: some View {
        VStack {
            Text("Test Success")
                .font(.title2)
            Divider()
            GameResponseView(gameResponse: GameResponse(success: "Success!"))
        }
        
        VStack {
            Text("Test Success")
                .font(.title2)
            Divider()
            GameResponseView(gameResponse: GameResponse(success: "Success!"))
        }
        
        VStack {
            Text("Test Error")
                .font(.title2)
            Divider()
            GameResponseView(gameResponse: GameResponse(error: OPContribError.badSupplyData))
        }
    }
}
