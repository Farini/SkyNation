//
//  GameButtons.swift
//  SkyNation
//
//  Created by Carlos Farini on 2/11/21.
//

import SwiftUI

struct GameButtons: View {
    var body: some View {
        VStack {
            
            HStack {
                
                Text("Example Header")
                    .font(.largeTitle)
                
                Spacer()
                
                Button(action: {
                    print("Question ?")
                }, label: {
                    Image(systemName: "questionmark.circle")
                        .font(.title2)
                })
                .buttonStyle(SmallCircleButtonStyle(backColor: .orange))
                
                Button(action: {
                    print("tap")
                }) {
                    Image(systemName: "ellipsis.circle")
                        .font(.title2)
                }.buttonStyle(SmallCircleButtonStyle(backColor: .blue))
                
                Button(action: {
                    print("tap")
                }) {
                    Image(systemName: "xmark.circle")
                        .font(.title2)
                }.buttonStyle(SmallCircleButtonStyle(backColor: .pink))
                
            }
            .padding([.top, .leading, .trailing], 8)
            
            Divider()
                .offset(x: 0, y: -6)
            
            // Middle
            Group {
                Text("Body small buttons")
                
                HStack {
                    
                    Button(action: {
                        print("button pressed")
                        
                    }) {
                        Image(systemName: "questionmark.diamond")
                        //                .renderingMode(.original)
                    }
                    .buttonStyle(NeumorphicButtonStyle(bgColor: .gray))
                    .help("Click here to do stuff. What happens then?")
                    //            .padding()
                    
                    Button(action: {
                        print("button pressed")
                        
                    }) {
                        Image(systemName: "ellipsis.circle")
                        //                .renderingMode(.original)
                    }
                    .buttonStyle(NeumorphicButtonStyle(bgColor: .gray))
                    //            .padding()
                    
                    Button(action: {
                        print("button pressed")
                        
                    }) {
                        Image(systemName: "xmark.circle")
                    }
                    .buttonStyle(NeumorphicButtonStyle(bgColor: .gray))
                }
                .padding()
                
                Text("More Text (gray)").foregroundColor(.gray)
                
                Text("Error message").foregroundColor(.red)
            }
            
            
            Divider()
            
            HStack {
                Button(action: {
                    print("Back Button Pressed")
                }) {
                    Image(systemName: "backward.frame")
                }
                .buttonStyle(NeumorphicButtonStyle(bgColor: .gray))
                .help("Go back")
                
                
                Button(action: {
                    print("button pressed")
                    
                }) {
                    Text("Continue")
                }
                .buttonStyle(NeumorphicButtonStyle(bgColor: .gray))
                
                Button(action: {
                    print("button pressed")
                    
                }) {
                    Image(systemName: "xmark.circle")
                    //                .renderingMode(.original)
                }
                .buttonStyle(NeumorphicButtonStyle(bgColor: .gray))
                //            .padding()
            }
            .padding([.bottom], 8)
        }
    }
}

// MARK: - Previews

struct GameButtons_Previews: PreviewProvider {
    static var previews: some View {
        GameButtons()
    }
}

// MARK: - Styles

struct SmallCircleButtonStyle: ButtonStyle {
    
    var backColor:Color
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label.padding(6)
            // .modifier(MakeSquareBounds())
            .background(Circle().fill(backColor))
    }
}

// This originated here
// ABSTRACT: https://sarunw.com/posts/swiftui-buttonstyle/#related-resources

/// The Game's main button style
struct NeumorphicButtonStyle: ButtonStyle {
    
    var bgColor: Color
    
    func makeBody(configuration: Self.Configuration) -> some View {
        MyButton(configuration: configuration)
    }
    
    struct MyButton: View {
        let configuration: ButtonStyle.Configuration
        @Environment(\.isEnabled) private var isEnabled: Bool
        var body: some View {
            
            
            configuration.label
                .padding(8)
                .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .shadow(color: .white,
                                    radius: configuration.isPressed ? 5: 8,
                                    x: configuration.isPressed ? -3: -5,
                                    y: configuration.isPressed ? -3: -5)
                            .blendMode(.overlay)
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            
                            .fill(Color("DarkGray"))
                        
                        RoundedRectangle(cornerRadius: 8, style: .circular)
                            .strokeBorder(configuration.isPressed ? Color.orange:Color.gray)
                        
                    }
                    
                )
                .scaleEffect(configuration.isPressed ? 0.95: 1)
                
                // Disabled State
                .foregroundColor(isEnabled ? Color.white : Color.gray)
                .animation(.spring())
        }
    }
}

