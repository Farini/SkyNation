//
//  GameMessagesView.swift
//  SkyNation
//
//  Created by Carlos Farini on 2/17/21.
//

import SwiftUI

struct GameMessagesView: View {
    
    var messages:[GameMessage]
    
    init() {
        let messages = LocalDatabase.shared.gameMessages
        self.messages = messages
    }
    
    var header: some View {
        
        Group {
            HStack() {
                VStack(alignment:.leading) {
                    Text("💬 Messages").font(.largeTitle)
                    Text("Keep up with the news")
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // Tutorial
                Button(action: {
                    print("Question ?")
                }, label: {
                    Image(systemName: "questionmark.circle")
                        .font(.title2)
                })
                .buttonStyle(SmallCircleButtonStyle(backColor: .orange))
                
                // Close
                Button(action: {
                    NotificationCenter.default.post(name: .closeView, object: self)
                }) {
                    Image(systemName: "xmark.circle")
                        .font(.title2)
                }.buttonStyle(SmallCircleButtonStyle(backColor: .pink))
                
            }
            .padding([.leading, .trailing, .top], 8)
            
            Divider()
                .offset(x: 0, y: -5)
        }
        
    }
    
    var body: some View {
        VStack {
            header
            
            ScrollView {
                ForEach(messages, id:\.self.id) { message in
                    //                Text(GameFormatters.dateFormatter.string(from: message.date))
                    Text(message.message)
                }
            }
        }
    }
}

struct GameMessagesView_Previews: PreviewProvider {
    static var previews: some View {
        GameMessagesView()
    }
}
