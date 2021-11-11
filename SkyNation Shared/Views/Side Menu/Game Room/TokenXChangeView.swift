//
//  TokenXChangeView.swift
//  SkyNation
//
//  Created by Carlos Farini on 11/10/21.
//

import SwiftUI

struct TokenXChangeView: View {
    
    enum XChangeReponse {
        case success
        case outOfTokens
        case notExchanged
    }
    @State var responseString:String = "---"
    @State var responseStatus:XChangeReponse = .notExchanged
    
    var body: some View {
        VStack(spacing: 6) {
            
            Text("Token Exchange")
                .font(GameFont.section.makeFont())
            Divider()
            
            Text("Exchange Tokens for SkyCoins").foregroundColor(.gray)
            
            Text("Sometimes when you are short on supplies, you might want to use a Token to raise some funds.")
                .foregroundColor(.gray)
                .frame(maxWidth:400)
                .multilineTextAlignment(.center)
            
            HStack(alignment:.center) {
                VStack {
                    Image("Helmet")
                        .resizable()
                        .frame(width: 32, height: 32, alignment: .center)
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke()
                        )
                    Text("1 Token")
                    Text("⭐︎")
                }
                
                VStack {
                    Spacer()
                    Image(systemName: "arrowshape.zigzag.right")
                        .font(.title)
                    Spacer()
                }
                
                
                VStack {
                    Image("Currency")
                        .resizable()
                        .frame(width: 32, height: 32, alignment: .center)
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke()
                        )
                    Text("\(GameFormatters.numberFormatter.string(from: NSNumber(value: GameLogic.moneyForToken)) ?? "10,000")")
                    Text("Sky Coins")
                }
                
            }
            
            Spacer()
            Text(responseString).foregroundColor(responseStatus == .notExchanged ? Color.gray:(responseStatus == .success ? Color.green:Color.orange))
            
            Divider()
            
            Button("XChange") {
                print("exchange...")
                let response = self.exchange()
                self.responseStatus = response
            }
            .buttonStyle(GameButtonStyle())
            .padding()
            
        }
    }
    
    func exchange() -> XChangeReponse {
        let player = LocalDatabase.shared.player
        if let token = player.requestToken() {
            if player.spendToken(token: token, save: false) == true {
                player.money += GameLogic.moneyForToken
                do {
                    try LocalDatabase.shared.savePlayer(player)
                    self.responseString = "You exchanged a Token, and now have \(player.money) Sky Coins."
                    return .success
                } catch {
                    fatalError("Couldn't save the player.")
                }
            } else {
                self.responseString = "Out of Tokens."
                return .outOfTokens
            }
        } else {
            self.responseString = "Out of Tokens."
            return .outOfTokens
        }
    }
}

struct TokenXChangeView_Previews: PreviewProvider {
    static var previews: some View {
        TokenXChangeView()
    }
}
