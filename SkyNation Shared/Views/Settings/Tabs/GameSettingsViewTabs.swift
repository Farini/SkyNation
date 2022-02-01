//
//  GameSettingsViewTabs.swift
//  SkyNation
//
//  Created by Carlos Farini on 11/4/21.
//

import SwiftUI

struct GameSettingsViewTabs: View {
    
    @Binding var selection:GameSettingsTab
    var options:[GameSettingsTab] = GameSettingsTab.allCases
    var callBack:((GameSettingsTab) -> ()) = { _ in }
    
    // MARK: - Gradients
    private static let myGradient = Gradient(colors: [Color.red.opacity(0.6), Color.blue.opacity(0.7)])
    private static let unseGradient = Gradient(colors: [Color.red.opacity(0.3), Color.blue.opacity(0.3)])
    private let selLinear = LinearGradient(gradient: myGradient, startPoint: .topLeading, endPoint: .bottomTrailing)
    private let unselinear = LinearGradient(gradient: unseGradient, startPoint: .topLeading, endPoint: .bottomTrailing)
    
    var body: some View {
        VStack {
            VStack {
                HStack {
                    // Tabs
                    ForEach(options, id:\.self) { aTab in
                        Image(systemName: aTab.imageName)
                            .font(.largeTitle)
                            .padding(5)
                            .background(selection == aTab ? selLinear:unselinear)
                            .cornerRadius(4)
                            .clipped()
                            .overlay(
                                RoundedRectangle(cornerRadius: 4, style: .continuous)
                                    .inset(by: 0.5)
                                    .stroke(selection == aTab ? Color.blue:Color.clear, lineWidth: 2)
                            )
                            .help(aTab.rawValue)
                            .onTapGesture {
                                callBack(aTab)
                            }
                    }
                    
                    Spacer()
                    Text("\(selection.rawValue)")
                }
                .padding(.horizontal, 6)
                .font(.title3)
            }
        }
    }
}

struct GameSettingsViewTabs_Previews: PreviewProvider {
    static var previews: some View {
        GameSettingsViewTabs(selection: .constant(GameSettingsTab.Loading))
    }
}
