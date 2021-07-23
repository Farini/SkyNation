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
    
    func body(content: Content) -> some View {
        
        #if os(macOS)
        content
            .font(.title)
        #else
        content
            .font(.title2)
        #endif
    }
}
