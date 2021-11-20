//
//  ShopPromoInputView.swift
//  SkyNation
//
//  Created by Carlos Farini on 11/20/21.
//

import SwiftUI

struct ShopPromoInputView: View {
    
    var cancelAction:(() -> Void)
    
    @State private var textInput:String = ""
//    @State private var isValidatingToken:Bool = false
    
    @State private var promoStep:PromoCodeStep = .input
    enum PromoCodeStep:Int {
        case input = 1
        case searching = 2
        case confirm = 3
        case finished = 4
        
        var stepLabel:String {
            switch self {
                case .input: return "Input Code"
                case .searching: return "Searching"
                case .confirm: return "Confirm"
                case .finished: return "You're done"
            }
        }
    }
    
    // Warnings
    @State private var promoWarning:String?
    @State private var promoConfirm:String?
    
    @State private var validToken:GameToken? = nil
    
    var body: some View {
        VStack {
            Text("Promo Code").font(GameFont.section.makeFont())
                .padding(.top, 6)
            
            Divider()
            
            StepperView(stepCounts: 3, current: promoStep.rawValue, stepDescription: promoStep.stepLabel)
                .padding(.bottom, 8)
                .onTapGesture {
                    self.textInput = UUID().uuidString
                }
            
            switch promoStep {
                case .input:
                    
                    VStack {
                        HStack {
                            Text("Code")
                            TextField("Promo Code", text: $textInput)
                                .padding(.trailing, 20)
                                .textFieldStyle(.roundedBorder)
                        }
                        .padding(.horizontal)
                        
                        Text("Insert promo code, or any code here").foregroundColor(.gray)
                        
                        Spacer()
                        Divider()
                        HStack {
                            Button("Cancel") {
                                self.cancelAction()
                            }
                            .buttonStyle(GameButtonStyle())
                            
                            Button("Verify") {
                                self.verifyButtonTapped()
                            }
                            .buttonStyle(GameButtonStyle())
                            .disabled(textInput.isEmpty)
                        }
                        .padding()
                    }
                    
                case .searching:
                    
                    VStack {
                        
                        Text("Validating input").font(GameFont.section.makeFont())
                        
                        Text(textInput)
                            .foregroundColor(.gray)
                            .font(GameFont.mono.makeFont())
                        
                        Text("Please be patient")
                            .font(GameFont.mono.makeFont())
                        
                        ProgressView()
                            .transition(.slide.combined(with: .scale))
                            .padding()
                        
                        Spacer()
                    }
                    
                case .confirm:
                    VStack {
                        
                        Text("Confirmation")
                            .font(GameFont.section.makeFont())
                            .transition(.slide)
                            .padding(8)
                        
                        if let promoWarning = promoWarning {
                            Text("⚠️ \(promoWarning)").foregroundColor(.red)
                        } else if let promoConfirm = promoConfirm {
                            Text("✅ \(promoConfirm)")
                        }
                        
                        Spacer()
                        Divider()
                        
                        Button("OK") {
                            self.promoWarning = nil
                            self.promoConfirm = nil
                            withAnimation() {
                                self.promoStep = .finished
                            }
                        }
                        .buttonStyle(GameButtonStyle())
                        .padding(.bottom, 8)
                        
                    }
                    
                case .finished:
                    VStack {
                        
                        Text("Finished")
                            .transition(.slide)
                            .padding()
                        
                        if let token = validToken {
                            
                            Image("Helmet")
                                .resizable()
                                .frame(width: 26, height: 26, alignment: .bottom)
                                .transition(.move(edge: .leading))
                            
                            Text("Token type \(token.origin.rawValue) \(token.id.uuidString)")
                            Text("User ID: \(token.dbUser.uuidString)")
                            Text("Date \(GameFormatters.dateFormatter.string(from: token.date))")
                        } else {
                            
                            Image("Helmet")
                                .resizable()
                                .frame(width: 26, height: 26, alignment: .bottom)
                                .transition(.move(edge: .leading))
                            
                            if let message = promoWarning {
                                Text(message)
                                    .foregroundColor(.red)
                                    .transition(.slide)
                            } else {
                                Text("No Token was found :(").foregroundColor(.gray)
                            }
                        }
                        
                        Spacer()
                        Divider()
                        
                        // Butttons
                        HStack {
                            Button("Cancel") {
                                self.promoWarning = nil
                                self.promoConfirm = nil
                                self.validToken = nil
                                
                                print("Cancelling")
                                // NotificationCenter.default.post(name: .closeView, object: nil)
                                self.cancelAction()
                                
                            }
                            .buttonStyle(GameButtonStyle(labelColor: .red))
                            
                            Button("Collect") {
                                
                                self.saveNewToken()
                            }
                            .buttonStyle(GameButtonStyle(labelColor: .green))
                            .disabled(validToken == nil)
                            
                        }
                        .padding(.bottom, 8)
                        
                    }
            }
        }
    }
    
    // MARK: - Actions
    
    func verifyButtonTapped() {
        
        self.promoWarning = nil
        self.promoConfirm = nil
        
        switch promoStep {
            case .input:
                guard textInput.isEmpty == false else {
                    self.promoWarning = "Text is empty"
                    return
                }
                
                // Change Step to Searching
                withAnimation() {
                    self.promoStep = .searching
                }
                
                // Validate Text (id, or string)
                if let uid = UUID(uuidString: textInput) {
                    // uuid confirm
                    self.promoWarning = "Searching promo code \(uid.uuidString)"
                    self.validateToken(identity: uid)
                } else {
                    // local code confirm
                    self.promoWarning = "Searching game cheat \(textInput)"
                    self.validateText(text: textInput)
                }
                
            case .searching:
                print("Should not click on searching. No button there")
            case .confirm:
                print("Confirming")
            case .finished:
                self.promoWarning = "Should go back to other screen"
        }
    }
    
    // Token Validation
    private func validateToken(identity:UUID) {
        
        self.promoWarning = "Validating Token"
        
//        Test Coding
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
//
//            if Bool.random() == true {
//                self.promoConfirm = "Accepted"
//            } else {
//                self.promoWarning = "Unnacceptable"
//            }
//
//            withAnimation(.flipCard) {
//                self.promoStep = .confirm
//            }
//        }
        
        
        SKNS.validateTokenFromTextInput(text: identity.uuidString) { token, errorString in
            
            if let token = token {
                
                print("Got a token type \(token.origin.rawValue)\n # \(token.id)")
                
                self.validToken = token
                
                DispatchQueue.main.async {
                    withAnimation(.flipCard) {
                        self.promoStep = .confirm
                    }
                }
                
            } else {
                
                print("Could not get a token")
                if let string = errorString {
                    DispatchQueue.main.async {
                        self.promoWarning = "Could not validate token. \(string)"
                        withAnimation() {
                            self.promoStep = .confirm
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.promoWarning = "Could not validate token"
                        withAnimation() {
                            self.promoStep = .confirm
                        }
                    }
                }
            }
        }
        
    }
    
    /// Other text validation
    private func validateText(text:String) {
        
        guard !text.isEmpty else {
            self.promoWarning = "Empty Text"
            self.promoStep = .input
            return
        }
        
        self.promoWarning = "Validating Text"
        
        var response:String = ""
        var textToken:GameToken?
        
        switch text {
            case "test": response = "test failed"
            case "brocolli": response = "money doesn't grow on broccoli"
            case "ilovefarini":
                response = ""
                if let pid = LocalDatabase.shared.player.playerID {
                    textToken = GameToken(entry: pid)
                } else {
                    response = "missing pid"
                }
            default: response = "\(text) doesn't work here."
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.75) {
            
            if let newToken = textToken {
                // Got a token
                self.promoConfirm = "Got a token \(newToken.origin.rawValue)"
                self.validToken = newToken
            } else {
                // Invalid
                self.promoWarning = response
            }
            
            withAnimation() {
                self.promoStep = .confirm
            }
        }
    }
    
    /// Saves the validated Token
    private func saveNewToken() {
        
        guard let token = validToken else {
            self.promoWarning = "No valid token"
            return
        }
        
        let player = LocalDatabase.shared.player
        player.wallet.tokens.append(token)
        
        do {
            try LocalDatabase.shared.savePlayer(player)
            self.promoConfirm = "Token collected."
            self.promoWarning = nil
            self.validToken = nil
        } catch {
            self.promoWarning = "Error: \(error.localizedDescription)"
        }
    }
}

struct ShopPromoInputView_Previews: PreviewProvider {
    static var previews: some View {
        ShopPromoInputView(cancelAction: {})
    }
}
