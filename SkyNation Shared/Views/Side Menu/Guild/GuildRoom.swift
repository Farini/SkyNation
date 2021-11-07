//
//  GuildRoom.swift
//  SkyNation
//
//  Created by Carlos Farini on 11/7/21.
//

import SwiftUI

enum GuildRoomTab:String, CaseIterable {
    case elections
    case actions
    case president
    case search
    case chatDoc
    
    var imageName:String {
        switch self {
            case .elections:    return "exclamationmark.shield"
            case .actions:      return "wand.and.stars"
            case .president:    return "crown"
            case .search:       return "magnifyingglass.circle"
            case .chatDoc:      return "doc.text"
        }
    }
}

struct GuildRoom: View {
    
    @State private var popTutorial:Bool = false
    @State private var selection:GuildRoomTab = .elections
    
    // MARK: - Gradients
    private static let myGradient = Gradient(colors: [Color.red.opacity(0.6), Color.blue.opacity(0.7)])
    private static let unseGradient = Gradient(colors: [Color.red.opacity(0.3), Color.blue.opacity(0.3)])
    private let selLinear = LinearGradient(gradient: myGradient, startPoint: .topLeading, endPoint: .bottomTrailing)
    private let unselinear = LinearGradient(gradient: unseGradient, startPoint: .topLeading, endPoint: .bottomTrailing)
    
    var header: some View {
        Group {
            HStack {
                
                Label("Guild Room", systemImage: "shield")
                    .font(GameFont.title.makeFont())
                
                Spacer()
                
                // Tutorial
                Button(action: {
                    print("Question ?")
                    popTutorial.toggle()
                }, label: {
                    Image(systemName: "questionmark.circle")
                        .font(.title2)
                })
                    .buttonStyle(SmallCircleButtonStyle(backColor: .orange))
                    .popover(isPresented: $popTutorial, arrowEdge: Edge.bottom, content: {
                        // Easy Tutorial View
                        TutorialView(tutType: .GuildRoom)
                    })
                
                
                // Close
                Button(action: {
//                    controller.cancelSelection()
                    NotificationCenter.default.post(name: .closeView, object: self)
                }, label: {
                    Image(systemName: "xmark.circle")
                        .font(.title2)
                })
                    .buttonStyle(SmallCircleButtonStyle(backColor: .red))
                
                
                    .padding(.trailing, 6)
                
            }
            .padding([.top, .horizontal], 6)
            Divider()
                .offset(x: 0, y: -5)
            
        }
    }
    
    var body: some View {
        VStack {
            header
            
            // Tabs
            HStack {
                ForEach(GuildRoomTab.allCases, id:\.self) { tab in
                    Image(systemName: tab.imageName).font(.title)
                        .padding(8)
                        .background(selection == tab ? selLinear:unselinear)
                        .cornerRadius(4)
                        .clipped()
                        .overlay(
                            RoundedRectangle(cornerRadius: 4, style: .continuous)
                                .inset(by: 0.5)
                                .stroke(selection == tab ? Color.blue:Color.clear, lineWidth: 2)
                        )
                        .help("\(tab.rawValue)")
                        .onTapGesture {
                            print("Call me")
//                            callBack(.Ingredients)
                        }
                }
                Spacer()
            }
            .padding(.horizontal, 8)
            
            Divider()
            
            Text("Tabs:")
            
            
            Text("Guild Elections")
            Text("Guild Actions + (President)")
            
            Text("Search")
            Text("Chat, or Doc.")
            
        }
    }
}

struct GuildRoom_Previews: PreviewProvider {
    static var previews: some View {
        GuildRoom()
    }
}
