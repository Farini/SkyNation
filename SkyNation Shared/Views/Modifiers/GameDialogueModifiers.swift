//
//  GameDialogueModifiers.swift
//  SkyNation
//
//  Created by Carlos Farini on 7/23/21.
//

import Foundation
import SwiftUI

struct GameViewMod: ViewModifier {
    
    func body(content: Content) -> some View {
        
        #if os(macOS)
        content
            .frame(minWidth: 500, idealWidth: 600, maxWidth: 700, minHeight: 300, maxHeight: 500)
        #else
        content
            .frame(minWidth: 400, idealWidth: 500, maxWidth: 600, minHeight: 300, maxHeight: 500)
        #endif
    }
}


struct GameTypography: ViewModifier {
    
    var gFont:GameFont
    
    init(_ gFont:GameFont) {
        self.gFont = gFont
    }
    
    func body(content: Content) -> some View {
        
        #if os(macOS)
        content
            .font(makeFont())
        #else
        content
            .font(makeFont())
        #endif
    }
    
    func makeFont() -> Font {
        return gFont.makeFont()
    }
}

struct GameTabModifier: ViewModifier {
    
    var string:String
    var isSelected:Bool = false
    
    init(_ string:String, selected:Bool = false) {
        self.string = string
        self.isSelected = selected
    }
    
    func body(content: Content) -> some View {
        ZStack(alignment: .bottomTrailing) {
            content
                .font(.title)
                .padding(5)
                .background(isSelected ? selLinear:unselinear)
                .cornerRadius(4)
                .clipped()
                .border(isSelected ? Color.blue:Color.clear, width: 1)
                .cornerRadius(6)
            //  .help(controller.selectedTab.rawValue)
        }
    }
    
    // MARK: - Gradients Used
    private static let myGradient = Gradient(colors: [Color.red.opacity(0.6), Color.blue.opacity(0.7)])
    private static let unseGradient = Gradient(colors: [Color.red.opacity(0.3), Color.blue.opacity(0.3)])
    private let selLinear = LinearGradient(gradient: myGradient, startPoint: .topLeading, endPoint: .bottomTrailing)
    private let unselinear = LinearGradient(gradient: unseGradient, startPoint: .topLeading, endPoint: .bottomTrailing)
}

struct Badged: ViewModifier {
    
    var string:String
    
    init(_ string:String) {
        self.string = string
    }
    
    func body(content: Content) -> some View {
        ZStack(alignment: .bottomTrailing) {
            content
            Text(string)
                .font(.caption)
                .foregroundColor(.white)
                .padding([.top, .leading, .trailing], 5)
                .background(Color.red)
                .clipShape(Circle())
        }
    }
}

/// The Game's Degault Background Color
struct GColored: ViewModifier {
    
    func body(content: Content) -> some View {
        return content
            .background(GameColors.darkGray)
    }
}
