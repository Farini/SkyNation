//
//  EngineStack.swift
//  SkyNation
//
//  Created by Carlos Farini on 11/13/21.
//

import SwiftUI

struct EngineStack: View {
    
    @State var selected:EngineType? = nil
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack {
            
            LazyVGrid(columns: columns, alignment: HorizontalAlignment.leading, spacing: 20) {
                ForEach(EngineType.allCases, id:\.self) { eType in
                    EngineCardHolder(eType: eType) { tappedEngine in
                        print("Tapped Engine: \(tappedEngine)")
                        self.selected = tappedEngine
                    }
                }
            }
            .frame(minWidth:600)
            .padding()
            
            Divider()
            
            HStack {
                Button("Cancel") {
                    print("Cancel")
                }
                .buttonStyle(GameButtonStyle())
                
                if let selected = selected {
                    Button {
                        print("Continue with selected \(selected.rawValue)")
                    } label: {
                        Label("Build \(selected.rawValue)", systemImage: "play.circle")
                    }
                    .buttonStyle(GameButtonStyle())
                    .disabled(!isUnlocked(type: selected))
                }
            }
            .padding(.bottom)
        }
        .frame(minWidth:620, minHeight:535)
    }
    
    func isUnlocked(type:EngineType) -> Bool {
        let xp = LocalDatabase.shared.station.garage.xp
        if type.requiredXP <= xp {
            return true
        } else {
            return false
        }
    }
}

struct EngineCardHolder: View {
    
    var eType:EngineType
    var action:((EngineType) -> ())
    
    @State private var visibleSide = FlipViewSide.front
    
    var body: some View {
        VStack {
            
            // Card (back, or front)
            FlipView(visibleSide: visibleSide) {
                EngineCardFront(eType: eType)
            } back: {
                EngineCardBack(eType: eType)
            }
            .contentShape(Rectangle())
            .animation(.flipCard, value: visibleSide)
            .onTapGesture {
                flipCard()
                action(eType)
            }
            
            // Buttons
            HStack {
                
                // Action
                Button(eType.rawValue) {
                    print("action")
                    action(eType)
                }
                .buttonStyle(GameButtonStyle())
                
                Spacer()
                
                // info
                Button(action: {
                    flipCard()
                }) {
                    Image(systemName: "info.circle")
                }
                .buttonStyle(GameButtonStyle())
                
            }
        }
    }
    
    func flipCard() {
        visibleSide.toggle()
    }
}

struct EngineCardFront: View {
    
    var eType:EngineType
    
    var body: some View {
        
        ZStack(alignment:.top) {
            // Image
            Image(eType.imgSysName)
                .resizable()
                .aspectRatio(0.618, contentMode: .fit)
                .cornerRadius(8)
            
            // Overlay Labels
            VStack {
                // Top
                HStack {
                    Text("\(eType.rawValue)").font(GameFont.mono.makeFont())
                        .padding(4)
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(4)
                    Spacer()
                    Text("\(eType.payloadLimit * 100) Kg").font(GameFont.mono.makeFont())
                        .padding(4)
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(4)
                }
                .padding(.horizontal, 4)
                Spacer()
                
                // Bottom (Time)
                Text("⏱ \(eType.time.stringFromTimeInterval())")
                    .padding(6)
                    .background(Color.black.opacity(0.2))
                    .cornerRadius(6)
            }
        }
    }
}

struct EngineCardBack: View {
    
    var eType:EngineType
    
    var body: some View {
        
        ZStack(alignment:.top) {
            // Image
            Image(eType.imgSysName)
                .resizable()
                .aspectRatio(0.618, contentMode: .fit)
                .cornerRadius(8)
            
            // Overlay Labels
            VStack {
                
                Spacer()
                
                HStack {
                    Text("Max Payload")
                    Spacer()
                    Text("\(eType.payloadLimit * 100) Kg")
                }
                
                HStack {
                    Text("Required XP")
                    Spacer()
                    Text("\(eType.requiredXP)")
                }
                
                Divider()
                
                bioTest
                humanTest
                
                Text(eType.about)
                    .padding(.top, 4)
                
                Spacer()
                
                // Bottom (Time)
                Text("⏱ \(eType.time.stringFromTimeInterval())")
                
            }
            .padding(6)
            .background(Color.black.opacity(0.2))
            .cornerRadius(6)
        }
    }
    
    var bioTest: some View {
        switch eType {
            case .Hex6:
                return HStack {
                    Text("Bio Boxes")
                    Spacer()
                    Text("⛔️")
                }
            case .T12:
                return HStack {
                    Text("Bio Boxes")
                    Spacer()
                    Text("✅").foregroundColor(.green)
                }
            case .T18:
                return HStack {
                    Text("Bio Boxes")
                    Spacer()
                    Text("✅").foregroundColor(.green)
                }
            case .T22:
                return HStack {
                    Text("Bio Boxes")
                    Spacer()
                    Text("✅").foregroundColor(.green)
                }
        }
    }
    
    var humanTest: some View {
        switch eType {
            case .Hex6:
                return HStack {
                    Text("Passengers")
                    Spacer()
                    Text("⛔️")
                }
            case .T12:
                return HStack {
                    Text("Passengers")
                    Spacer()
                    Text("⛔️").foregroundColor(.green)
                }
            case .T18:
                return HStack {
                    Text("Passengers")
                    Spacer()
                    Text("✅").foregroundColor(.green)
                }
            case .T22:
                return HStack {
                    Text("Passengers")
                    Spacer()
                    Text("✅").foregroundColor(.green)
                }
        }
    }
}

struct EngineStack_Previews: PreviewProvider {
    static var previews: some View {
        EngineStack()
    }
}

struct EngineCards_Previews: PreviewProvider {
    static var previews: some View {
        //FlipView(front: EngineCardFront(eType: .Hex6), back: EngineCardBack(eType: .Hex6))
        FlipView(visibleSide: .back) {
            EngineCardFront(eType: .Hex6)
        } back: {
            EngineCardBack(eType: .Hex6)
        }
    }
}
