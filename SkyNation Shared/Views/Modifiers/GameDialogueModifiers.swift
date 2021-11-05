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
//        #if os(macOS)
//        switch gFont {
//            case .title: return (Font.custom("Ailerons", size: 24))
//            case .section: return (Font.custom("Roboto Slab", size: 16))
//            case .writing: return .body
//            case .little: return .footnote
//        }
//        #else
//        switch gFont {
//            case .title: return (Font.custom("Ailerons", size: 22))
//            case .section: return (Font.custom("Roboto Slab", size: 15))
//            case .writing: return .body
//            case .little: return .footnote
//        }
//        #endif
    }
}

struct Badged: ViewModifier {
    
    func body(content: Content) -> some View {
        ZStack(alignment: .bottomTrailing) {
            content
            Text("!")
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
