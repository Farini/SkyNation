//
//  GameDialogueModifiers.swift
//  SkyNation
//
//  Created by Carlos Farini on 7/23/21.
//

import Foundation
import SwiftUI


/// Applies a default selection state. With a dark gray border (unselected) and blue border when selected.
/// Default Padding and corner radius is `8.0`
struct GameSelectionModifier: ViewModifier {
    
    var isSelected:Bool = false
    var padding:Double = 8.0
    var radius:Double = 8.0
    
    private let unselectedColor:Color = Color(white: 0.24, opacity: 1.0)
    private let selectedColor:Color = .blue
    
    func body(content: Content) -> some View {
        ZStack(alignment: .bottomTrailing) {
            content
                .padding(padding)
                .cornerRadius(radius)
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .inset(by: 0.5)
                        .stroke(isSelected ? selectedColor:unselectedColor, lineWidth: 2)
                )
        }
    }
}

/// All Tabs should use this modifier
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
        }
    }
    
    // MARK: - Gradients Used
    private static let myGradient = Gradient(colors: [Color.red.opacity(0.6), Color.blue.opacity(0.7)])
    private static let unseGradient = Gradient(colors: [Color.red.opacity(0.3), Color.blue.opacity(0.3)])
    private let selLinear = LinearGradient(gradient: myGradient, startPoint: .topLeading, endPoint: .bottomTrailing)
    private let unselinear = LinearGradient(gradient: unseGradient, startPoint: .topLeading, endPoint: .bottomTrailing)
}

/// Add a Badge to a Tab. Useful to display new stuff.
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

/// The Game's Default Background Color
struct GColored: ViewModifier {
    
    func body(content: Content) -> some View {
        return content
            .background(GameColors.darkGray)
    }
}
