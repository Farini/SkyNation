//
//  GameRoomView.swift
//  SkyNation
//
//  Created by Carlos Farini on 11/7/21.
//

import SwiftUI

enum GameRoomTab:String, CaseIterable {
    case gameMessages
    case freebie
    case xchange
    case credits
    
    var imageName:String {
        switch self {
            case .gameMessages: return "message"
            case .freebie:      return "gift"
            case .xchange:      return "arrow.triangle.2.circlepath"
            case .credits:      return "scroll"
        }
    }
}

struct GameRoomView: View {
    
    @State private var popTutorial:Bool = false
    @State private var selection:GameRoomTab = .gameMessages
    
    // MARK: - Gradients
    private static let myGradient = Gradient(colors: [Color.red.opacity(0.6), Color.blue.opacity(0.7)])
    private static let unseGradient = Gradient(colors: [Color.red.opacity(0.3), Color.blue.opacity(0.3)])
    private let selLinear = LinearGradient(gradient: myGradient, startPoint: .topLeading, endPoint: .bottomTrailing)
    private let unselinear = LinearGradient(gradient: unseGradient, startPoint: .topLeading, endPoint: .bottomTrailing)
    
    var header: some View {
        Group {
            HStack {
                
                Label("Game Room", systemImage: "gamecontroller")
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
                        TutorialView(tutType: .GameRoom)
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
            
            HStack {
                ForEach(GameRoomTab.allCases, id:\.self) { tab in
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
            
            
            Text("Game Room")
            
            Text("Tabs:")
            
            Text("Game Messages")
            Text("Freebies")
            Text("XChange")
            Text("Credits")
        }
    }
}

struct GameRoomView_Previews: PreviewProvider {
    static var previews: some View {
        GameRoomView()
    }
}
