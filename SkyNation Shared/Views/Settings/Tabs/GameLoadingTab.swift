//
//  GameLoadingTab.swift
//  SkyNation
//
//  Created by Carlos Farini on 9/19/21.
//

import SwiftUI

// MARK: - Tab1: Loading

struct GameLoadingTab: View {
    
    @ObservedObject var controller:GameSettingsController
    @State private var isExpanded:Bool = false
    
    var body: some View {
        VStack {
            HStack {
                Image("\(controller.player.avatar)")
                    .resizable()
                    .frame(width:82, height:82)
                VStack(alignment:.leading) {
                    Text(controller.player.name)
                    Text("XP: \(controller.player.experience)")
                    Text("Online: \(GameFormatters.dateFormatter.string(from:controller.player.lastSeen))")
                        .foregroundColor(.green)
                    HStack(alignment:.center) {
                        #if os(macOS)
                        Image(nsImage:GameImages.tokenImage)
                            .resizable()
                            .frame(width:32, height:32)
                        #else
                        Image(uiImage:GameImages.tokenImage)
                            .resizable()
                            .frame(width:32, height:32)
                        #endif
                        Text("x\(controller.player.countTokens().count)") //timeTokens.count)")
                        Divider()
                        #if os(macOS)
                        Image(nsImage:GameImages.currencyImage)
                            .resizable()
                            .frame(width:32, height:32)
                        #else
                        Image(uiImage: GameImages.currencyImage)
                            .resizable()
                            .frame(width:32, height:32)
                        #endif
                        Text("\(controller.player.money)")
                    }
                    .frame(height:36)
                }
                Spacer()
                Image("EntranceLogo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width:300)
            }
            
            Divider()
                .padding(.bottom)
            
            if controller.isNewPlayer {
                Text("New Player")
                    .foregroundColor(.orange)
                    .font(.headline)
            }
            
            Group {
                
                if isExpanded {
                    ForEach($controller.loadedList, id:\.self) { litem in
                        Text(litem.wrappedValue)
                            .foregroundColor(.gray)
                            .transition(.move(edge: .top).combined(with: .opacity))
                            .onTapGesture {
                                withAnimation {
                                    self.isExpanded.toggle()
                                }
                            }
                    }
                } else {
                    if let last = controller.loadedList.last {
                        Text(last)
                            .foregroundColor(.gray)
                            .transition(.move(edge: .top).combined(with: .opacity))
                            .onTapGesture {
                                withAnimation() {
                                    self.isExpanded.toggle()
                                }
                            }
                    }
                }
                
                // Warning List
                ForEach($controller.warningList, id:\.self) { litem in
                    Text(litem.wrappedValue).foregroundColor(.orange)
                }
                
                Spacer(minLength: 8)
            }
        }
    }
}
